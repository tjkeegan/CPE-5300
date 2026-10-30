`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2025 06:15:13 PM
// Design Name: 
// Module Name: OTTER_IMEM
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

//instruction memory
module IMEM(
    input   wire [31:0] IMEM_A, //address to read from (set by PC)
    output  wire [31:0] IMEM_OUT //instruct that has been read
    );

    logic [31:0] RAM[65535:0]; //memory
    initial $readmemh("imem.mem",RAM); //input program
    
    assign IMEM_OUT = RAM[IMEM_A[31:2]]; //send out

endmodule
