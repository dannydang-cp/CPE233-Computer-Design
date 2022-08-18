`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Danny Dang, Dylan Sandall, Felix Demharter
// 
// Create Date: 05/02/2022 12:42:37 AM
// Design Name: 
// Module Name: IMMED_GEN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Module responsible for generating five different instructional formats from the instrution register
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN(ir, U_type, I_type, S_type, J_type, B_type);

    input [31:0] ir;
    output [31:0] U_type, I_type, S_type, J_type, B_type;

    assign I_type = {{21{ir[31]}}, ir[30:25], ir[24:20]};
    assign S_type = {{21{ir[31]}}, ir[30:25], ir[11:7]};
    assign B_type = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    assign U_type = {ir[31:12], {12{1'b0}}};
    assign J_type = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};

endmodule
