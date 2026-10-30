`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2025 06:16:29 PM
// Design Name: 
// Module Name: OTTER_DMEM
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

//data memory
module DMEM(
    input   wire        CLK,
    input   wire        DMEM_WRITE,
    input   wire [31:0] DMEM_D,
    input   wire [31:0] DMEM_A, //address to read from or write to
    output  wire [31:0] DMEM_OUT //data that has been read
    );
    
    logic [31:0] RAM[65535:0]; //memory
    initial $readmemh("imem.mem",RAM); //input program
    
    always_ff @ (posedge CLK) begin
        if (DMEM_WRITE) begin
            RAM[DMEM_A[31:2]] <= DMEM_D;
        end
    end
    
    assign DMEM_OUT = RAM[DMEM_A[31:2]]; //send out

endmodule
