`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Danny Dang, Dylan Sandall, Felix Demharter 
// 
// Create Date: 04/27/2022 04:42:28 PM
// Design Name: 
// Module Name: alu
// Project Name: Lab3 Arithmetic Logic Unit
// Target Devices: 
// Tool Versions: 
// Description: Arithmetic Logic Unit module that is responsible for all the number crunching operations in the system and is controlled by feeding in opcodes to choose which opperation is to be done
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [31:0] A, B,
    input [3:0] alu_fun,
    output reg [31:0] alu_out
);

    always @ (A, B, alu_fun)
    begin
        case(alu_fun)
            4'b0000: alu_out = A + B; //add
            4'b1000: alu_out = A - B; //sub
            4'b0110: alu_out = A | B; //or
            4'b0111: alu_out = A & B; //and
            4'b0100: alu_out = A ^ B; //xor
            4'b0101: alu_out = A >> B[4:0]; //srl
            4'b0001: alu_out = A << B[4:0]; //sll
            4'b1101: alu_out = $signed(A) >>> B[4:0]; //sra
            4'b0010: alu_out = ($signed(A) < $signed(B)) ? 1 : 0; //slt                        
            4'b0011: alu_out = (A < B) ? 1 : 0; //sltu 
            4'b1001: alu_out = A; //lui
            default: alu_out = 0;
        endcase
    end
endmodule
