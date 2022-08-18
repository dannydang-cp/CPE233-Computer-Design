`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 01/07/2020 09:12:54 PM
// Design Name: 
// Module Name: top_level
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Control Unit Template/Starter File for RISC-V OTTER
//
//     //- instantiation template 
//     CU_FSM my_fsm(
//        .intr     (xxxx),
//        .clk      (xxxx),
//        .RST      (xxxx),
//        .opcode   (xxxx),   // ir[6:0]
//        .pcWrite  (xxxx),
//        .regWrite (xxxx),
//        .memWE2   (xxxx),
//        .memRDEN1 (xxxx),
//        .memRDEN2 (xxxx),
//        .reset    (xxxx)   );
//   
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created - 02-01-2020 (from other people's files)
//          1.01 - (02-08-2020) switched states to enum type
//          1.02 - (02-25-2020) made PS assignment blocking
//                              made rst output asynchronous
//          1.03 - (04-24-2020) added "init" state to FSM
//                              changed rst to reset
//          1.04 - (04-29-2020) removed typos to allow synthesis
//          1.05 - (10-14-2020) fixed instantiation comment (thanks AF)
//          1.06 - (12-10-2020) cleared most outputs, added commentes
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input intr,
    input clk,
    input RST,
    input [6:0] opcode, // ir[6:0]
    input [2:0] func3,
    output logic pcWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken
);

    typedef  enum logic [2:0] {
        INIT,
        FETCH,
        EXECUTE,
        WRITEBACK,
        INTERRUPT
    }  state_type;
    state_type  NS,PS;

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
    opcode_t OPCODE; //- symbolic names for instruction opcodes

    assign OPCODE = opcode_t'(opcode); //- Cast input as enum 


    //- state registers (PS)
    always @ (posedge clk)
    begin
        if (RST == 1'b1)
            begin
                PS <= INIT;
            end
        else
            begin
                PS <= NS;
            end
    end

    always_comb
    begin
        //- schedule all outputs to avoid latch
        pcWrite = 1'b0;    regWrite = 1'b0;    reset = 1'b0;
        memWE2 = 1'b0;     memRDEN1 = 1'b0;    memRDEN2 = 1'b0;
        csr_WE = 1'b0;     int_taken = 1'b0;

        case (PS)

            INIT: //waiting state  
            begin
                pcWrite = 1'b0;
                regWrite = 1'b0;
                reset = 1'b1;
                memWE2 = 1'b0;
                memRDEN1 = 1'b0;
                memRDEN2 = 1'b0;
                csr_WE = 1'b0;
                int_taken = 1'b0;
                NS = FETCH;
            end

            FETCH: //waiting state  
            begin
                pcWrite = 1'b0;
                regWrite = 1'b0;
                reset = 1'b0;
                memWE2 = 1'b0;
                memRDEN1 = 1'b1;
                memRDEN2 = 1'b0;
                csr_WE = 1'b0;
                int_taken = 1'b0;
                NS = EXECUTE;
            end

            EXECUTE: //decode + execute
            begin
                pcWrite = 1'b1;
                case (OPCODE)
                    LUI:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    AUIPC:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    BRANCH:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b0;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    SW:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b0;
                        reset = 1'b0;
                        memWE2 = 1'b1;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    LW:
                    begin
                        pcWrite = 1'b0;
                        regWrite = 1'b0;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b1;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        NS = WRITEBACK;
                    end

                    OP_IMM: // addi 
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    OP_RG3:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    JAL:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    JALR:
                    begin
                        pcWrite = 1'b1;
                        regWrite = 1'b1;
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = 1'b0;
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end

                    CSR:
                    begin
                        pcWrite = 1'b1;
                        regWrite = func3[0];
                        reset = 1'b0;
                        memWE2 = 1'b0;
                        memRDEN1 = 1'b0;
                        memRDEN2 = 1'b0;
                        csr_WE = func3[0];
                        int_taken = 1'b0;
                        if (intr)
                            NS = INTERRUPT;
                        else
                            NS = FETCH;
                    end
                    endcase
                    end


                WRITEBACK:
                begin
                    pcWrite = 1'b1;
                    regWrite = 1'b1;
                    memWE2 = 1'b0;
                    memRDEN1 = 1'b0;
                    memRDEN2 = 1'b0;
                    reset = 1'b0;
                    csr_WE = 1'b0;
                    int_taken = 1'b0;
                    if (intr)
                        begin
                            NS = INTERRUPT;
                        end
                    else
                        begin
                            NS = FETCH;
                        end
                end



                INTERRUPT:
                begin
                    pcWrite = 1'b1;
                    regWrite = 1'b0;
                    memWE2 = 1'b0;
                    memRDEN1 = 1'b0;
                    memRDEN2 = 1'b0;
                    reset = 1'b0;
                    csr_WE = 1'b0;
                    int_taken = 1'b1;
                    NS = FETCH;
                end

            
            default:
            begin
                pcWrite = 1'b0;
                regWrite = 1'b0;
                reset = 1'b1;
                memWE2 = 1'b0;
                memRDEN1 = 1'b0;
                memRDEN2 = 1'b0;
                csr_WE = 1'b0;
                int_taken = 1'b0;

                NS = INIT;
            end

        endcase //- case statement for FSM states
    end

endmodule
