`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Live Wire Engineering
// Engineer:  Dylan Sandall, Danny Dang, Felix Demharter
// 
// Create Date: 05/14/2022
// Design Name: 
// Module Name: RISC-V OTTER MCU
// Project Name: RISC-V OTTER
// Target Devices: Basys 3 Development Board
// Tool Versions: 
// Description: MCU module, merges various submodules
// 
// Dependencies: Memory, PC, REG_FILE, ALU, BAG, IMM_GEN, CU_DCDR, CU_FSM, Branch Condition Generator, and intermediary hardware
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module  OTTER_MCU (
    input       rst,
    input       intr,
    input       clk,
    input       [31:0] iobus_in,
    output      [31:0] iobus_addr,
    output      [31:0] iobus_out,
    output      iobus_wr
);
    //PC wires
    wire [31:0] mux_out, PC;

    //MEMORY wires
    wire [31:0] ir, DOUT2;
    wire IO_WR;

    //REG wires
    wire [31:0] rs1, rs2, wd;

    //IMMED_GEN wires
    wire [31:0] U_type, I_type, S_type, J_type, B_type;

    //BAG wires
    wire [31:0] jalr, branch, jal;

    //ALU wires
    wire [31:0] srcA, srcB, result;

    //insert BCD wires here

    //CU_FSM wires
    wire PCWrite, regWrite, memWE2, memRDEN1, memRDEN2, reset, csr_WE, int_taken, intr_fsm;

    //CU_DCDR wires
    wire [3:0] alu_fun;
    wire [1:0] alu_srcB, rf_wr_sel;
    wire [2:0] pcSource;
    wire alu_srcA;

    //BRANCH_COND_GEN wires
    wire br_eq, br_lt, br_ltu;

    //CSR wires
    wire [31:0] mepc, mtvec, RD;
    wire CSR_MIE; 
 
    mux_8t1_nb  #(.n(32)) PC_mux  (
        .SEL   (pcSource),
        .D0    (PC + 4),
        .D1    (jalr),
        .D2    (branch),
        .D3    (jal),
        .D4    (mtvec),
        .D5    (mepc),
        .D6    (),
        .D7    (),
        .D_OUT (mux_out)
    );

    cntr_up_clr_nb #(.n(32)) my_PC (
        .clk   (clk),
        .clr   (reset),
        .up    (0),
        .ld    (PCWrite),
        .D     (mux_out), //input
        .count (PC), //output
        .rco   ()
    );

    Memory          my_memory(
        .MEM_CLK    (clk),
        .MEM_RDEN1  (memRDEN1),
        .MEM_RDEN2  (memRDEN2),
        .MEM_WE2    (memWE2),
        .MEM_ADDR1  (PC[15:2]),
        .MEM_ADDR2  (result),
        .MEM_DIN2   (rs2),
        .MEM_SIZE   (ir[13:12]),
        .MEM_SIGN   (ir[14]),
        .IO_IN      (iobus_in),
        .IO_WR      (iobus_wr),
        .MEM_DOUT1  (ir),
        .MEM_DOUT2  (DOUT2)
    );

    mux_4t1_nb  #(.n(32)) my_regmux(
        .SEL        (rf_wr_sel),
        .D0         (PC + 4),
        .D1         (0), //this will be replaced with CSR_reg
        .D2         (DOUT2),
        .D3         (result),
        .D_OUT      (wd)
    );

    RegFile         my_regfile(
        .wd         (wd),
        .clk        (clk),
        .en         (regWrite),
        .adr1       (ir[19:15]),
        .adr2       (ir[24:20]),
        .wa         (ir[11:7]),
        .rs1        (rs1),
        .rs2        (rs2)
    );

    IMMED_GEN        my_immedgen(
        .ir         (ir),
        .U_type     (U_type),
        .I_type     (I_type),
        .S_type     (S_type),
        .J_type     (J_type),
        .B_type     (B_type)
    );

    BRANCH_ADDR_GEN my_bag(
        .J_type     (J_type),
        .B_type     (B_type),
        .I_type     (I_type),
        .rs1        (rs1),
        .PC         (PC),
        .jal        (jal),
        .branch     (branch),
        .jalr       (jalr)
    );

    mux_2t1_nb      #(.n(32)) my_alumux_A(
        .SEL        (alu_srcA),
        .D0         (rs1),
        .D1         (U_type),
        .D_OUT      (srcA)
    );

    mux_4t1_nb      #(.n(32)) my_alumux_B(
        .SEL        (alu_srcB),
        .D0         (rs2),
        .D1         (I_type),
        .D2         (S_type),
        .D3         (PC),
        .D_OUT      (srcB)
    );

    ALU             my_alu(
        .A          (srcA),
        .B          (srcB),
        .alu_fun    (alu_fun),
        .alu_out    (result)
    );

    BRANCH_COND_GEN my_bcg(
        .rs1        (rs1),
        .rs2        (rs2),
        .br_eq      (br_eq),
        .br_lt      (br_lt),
        .br_ltu     (br_ltu)
    );

    assign intr_fsm = intr & CSR_MIE; 

    CU_FSM          my_fsm(
        .intr       (intr_fsm), //inputs
        .clk        (clk),
        .RST        (rst),
        .opcode     (ir[6:0]),
        .func3      (ir[14:12]),
        .pcWrite    (PCWrite),
        .regWrite   (regWrite),
        .memWE2     (memWE2),
        .memRDEN1   (memRDEN1),
        .memRDEN2   (memRDEN2),
        .reset      (reset),
        .csr_WE     (csr_WE),
        .int_taken  (int_taken)
    );

    CU_DCDR         my_cu_dcdr(
        .br_eq      (br_eq), // inputs
        .br_lt      (br_lt),
        .br_ltu     (br_ltu),
        .opcode     (ir[6:0]),
        .func7      (ir[30]),
        .func3      (ir[14:12]),
        .int_taken  (int_taken),
        .alu_fun    (alu_fun),
        .pcSource   (pcSource), //output
        .alu_srcA   (alu_srcA),
        .alu_srcB   (alu_srcB),
        .rf_wr_sel  (rf_wr_sel)
    );


    CSR  my_csr (
        .CLK       (clk),
        .RST       (reset),
        .INT_TAKEN (int_taken),
        .ADDR      (ir[31:20]),
        .PC        (PC),
        .WD        (rs1),
        .WR_EN     (csr_WE),
        .RD        (RD),
        .CSR_MEPC  (mepc),
        .CSR_MTVEC (mtvec),
        .CSR_MIE   (CSR_MIE)
    );

    assign iobus_addr = result;
    assign iobus_out = rs2;
    assign iobus_wr = IO_WR;

endmodule
