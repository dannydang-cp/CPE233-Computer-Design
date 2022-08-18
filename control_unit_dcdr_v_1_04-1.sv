`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/29/2019 04:56:13 PM
// Design Name: 
// Module Name: CU_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies:
// 
// CU_DCDR my_cu_dcdr(
//   .br_eq     (), 
//   .br_lt     (), 
//   .br_ltu    (),
//   .opcode    (),    //-  ir[6:0]
//   .func7     (),    //-  ir[30]
//   .func3     (),    //-  ir[14:12] 
//   .alu_fun   (),
//   .pcSource  (),
//   .alu_srcA  (),
//   .alu_srcB  (), 
//   .rf_wr_sel ()   );
//
// 
// Revision:
// Revision 1.00 - File Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed unneeded else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_DCDR(

    input br_eq,
    input br_lt,
    input br_ltu,
    input [6:0] opcode, //-  ir[6:0]
    input func7, //-  ir[30]
    input [2:0] func3, //-  ir[14:12] 
    input int_taken,
    output logic [3:0] alu_fun,
    output logic [2:0] pcSource,
    output logic alu_srcA,
    output logic [1:0] alu_srcB,
    output logic [1:0] rf_wr_sel   );

    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LW   = 7'b0000011,
        SW  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        CSR = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type

    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;
    func3_t FUNC3; //- define variable of new opcode type

    assign FUNC3 = func3_t'(func3); //- Cast input enum 

    always_comb
    begin

        // When an intr occurs
        if (int_taken)
            begin
                alu_fun = 4'b0000; // Don't care
                alu_srcA = 1'b0; // Don't care
                alu_srcB = 2'b00; // Don't care
                pcSource = 3'b0100; //mtvec
                rf_wr_sel = 2'b00; // Don't care
            end

            // Cases by opcode
        else
            begin
                //- schedule all values to avoid latch
                pcSource = 3'b000;  alu_srcB = 2'b00;    rf_wr_sel = 2'b00;
                alu_srcA = 1'b0;   alu_fun  = 4'b0000;

                case(OPCODE)
                    LUI:
                    begin
                        alu_fun = 4'b1001; // LUI Copy
                        alu_srcA = 1'b1; // U type
                        alu_srcB = 2'b00; // Don't care
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b11; // ALU output
                    end

                    AUIPC:
                    begin
                        alu_fun = 4'b0000; // add
                        alu_srcA = 1'b1; // U type  
                        alu_srcB = 2'b11; //  PC
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b11; // ALU result 
                    end

                    JAL:
                    begin
                        alu_fun = 4'b0000; // Don't care
                        alu_srcA = 1'b0; // rs1
                        alu_srcB = 2'b00; // rs2
                        pcSource = 3'b011; // PC Mux for JAL
                        rf_wr_sel = 2'b00; // Memory out (DOUT1)
                    end

                    JALR:
                    begin
                        alu_fun = 4'b0000; // Don't care
                        alu_srcA = 1'b0; // Don't care
                        alu_srcB = 2'b00; // Dont' care	
                        pcSource = 3'b001; // JALR		
                        rf_wr_sel = 2'b00; // PC + 4
                    end

                    BRANCH:
                    begin
                        alu_fun = 4'b0000; // Don't care
                        alu_srcA = 1'b0; // Don't care
                        alu_srcB = 2'b00; // Don't care	
                        rf_wr_sel = 2'b00; // Don't care
                        if ((func3 == 3'b000) && (br_eq == 1))
                            pcSource = 3'b010;
                        else if ((func3 == 3'b001) && (br_eq == 0))
                            pcSource = 3'b010;
                        else if ((func3 == 3'b100) && (br_lt == 1))
                            pcSource = 3'b010;
                        else if((func3 == 3'b101) && ((br_lt == 0) || (br_eq == 1)))
                            pcSource = 3'b010;
                        else if((func3 == 3'b110) && (br_ltu == 1))
                            pcSource = 3'b010;
                        else if((func3 == 3'b111) && ((br_ltu == 0) || (br_eq == 1)))
                            pcSource = 3'b010;
                        else
                            pcSource = 3'b000;
                    end

                    LW:
                    begin
                        alu_fun = 4'b0000; // add
                        alu_srcA = 1'b0; // rs1
                        alu_srcB = 2'b01; // I-Type
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b10; // MemoryOut2 (DOUT2)
                    end

                    SW:
                    begin
                        alu_fun = 4'b0000; // Don't care
                        alu_srcA = 1'b0; // rs1  
                        alu_srcB = 2'b10; // S-Type
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b00; // PC_OUT + 4
                    end

                    OP_IMM: //addi
                    begin
                        if (func3 == 3'b101)
                            alu_fun = {func7, func3};
                        else
                            alu_fun = {1'b0, func3};
                        alu_srcA = 1'b0; // rs1
                        alu_srcB = 2'b01; // I-type
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b11; // ALU output 
                    end

                    OP_RG3:
                    begin
                        alu_fun = {func7, func3};
                        alu_srcA = 1'b0; // rs1
                        alu_srcB = 2'b00; // rs2
                        pcSource = 3'b000; // PC + 4
                        rf_wr_sel = 2'b11; // ALU output
                    end


                    CSR:
                    begin
                        alu_fun = 4'b0000; // Don't care
                        alu_srcA = 1'b0; // Don't care
                        alu_srcB = 2'b00; // Don't Ccare
                        rf_wr_sel = 2'b01; // CSR_RD
                        if (func3 == 3'b000)
                            begin
                                pcSource = 3'b101; // mepc
                            end
                        else
                            begin
                                pcSource = 3'b000; // PC + 4
                            end
                    end


                    default:
                    begin
                        alu_fun = 4'b0000;
                        alu_srcA = 1'b0;
                        alu_srcB = 2'b00;
                        pcSource = 3'b000;
                        rf_wr_sel = 2'b00;
                    end
                endcase
            end
    end

endmodule