`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Danny Dang, Dylan Sandall, Felix Demharter
// 
// Create Date: 05/02/2022 12:42:37 AM
// Design Name: 
// Module Name: BRANCH_ADDR_GEN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Module responsible for generating branches from different instructional formats
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BRANCH_ADDR_GEN(J_type, B_type, I_type, rs1, PC, jal, branch, jalr);
    input [31:0] J_type, B_type, I_type, rs1, PC;
    output [31:0] jal, branch, jalr;

    assign jal = (PC + J_type);
    assign jalr = (rs1 + I_type);
    assign  branch = (PC + B_type);

endmodule
