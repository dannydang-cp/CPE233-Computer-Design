`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2022 06:37:40 PM
// Design Name: 
// Module Name: BRANCH_COND_GEN
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BRANCH_COND_GEN(
    input [31:0] rs1,
    input [31:0] rs2,
    output br_eq,
    output br_lt,
    output br_ltu
    );
    
//    always @(rs1, rs2) 
//    begin
//        if (rs1 == rs2)
//        begin   
//            br_eq = 1;
//            br_lt = 0;
//            br_ltu = 0;
//        end
//        else if (rs1 < rs2)
//        begin   
//            br_eq = 0;
//            br_lt = 0;
//            br_ltu = 1;
//        end    
//        else if ($signed(rs1) < $signed(rs2))
//        begin
//            br_eq = 0;
//            br_lt = 1;
//            br_ltu = 0;
//        end
//    end


    assign br_eq = (rs1 == rs2);
    assign br_ltu = (rs1 < rs2);
    assign br_lt = ($signed(rs1) < $signed(rs2));
    
    
     
endmodule
