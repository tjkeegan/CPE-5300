`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2025 06:23:05 PM
// Design Name: 
// Module Name: TargetGenerator
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


module TargetGenerator(
    input logic SEL,
    input logic [31:0] PC,
    input logic [31:0] RS1,
    input logic [31:0] IMM,
    output logic [31:0] OUT
    );
    
    //Create a generic two-to-one MUX to be used for the ALU.
    always_comb begin
        case(SEL)
            1'b0: begin OUT = PC + IMM; end
            1'b1: begin OUT = RS1 + IMM; end
        endcase
    end
endmodule
