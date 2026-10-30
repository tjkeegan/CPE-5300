`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2025 11:53:23 AM
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input logic [4:0] RS1_DEC,
    input logic [4:0] RS2_DEC,
    input logic [4:0] RS1_EXEC,
    input logic [4:0] RS2_EXEC,
    input logic [4:0] RD_EXEC,
    input logic PC_SRC,
    input logic DMEM_READ_EXEC,
    input logic [4:0] RD_MEM,
    input logic REG_WRITE_MEM,
    input logic [4:0] RD_WB,
    input logic REG_WRITE_WB,
    output logic STALL_FET,
    output logic STALL_DEC,
    output logic FLUSH_DEC,
    output logic FLUSH_EXEC,
    output logic [1:0] FORWARD_A,
    output logic [1:0] FORWARD_B
    );
    
    always_comb begin
        STALL_FET = 1'b0;
        STALL_DEC = 1'b0;
        FLUSH_DEC = 1'b0;
        FLUSH_EXEC = 1'b0;
        FORWARD_A = 2'b00;
        FORWARD_B = 2'b00;
        
        if ((RS1_DEC == RD_EXEC) && (RS1_DEC != 32'h00000000)) begin
            FORWARD_A = 2'b10;
            if (DMEM_READ_EXEC) begin
                STALL_FET = 1'b1;
                STALL_DEC = 1'b1;
            end
        end
        
        else if ((RS1_DEC == RD_MEM) && (RS1_DEC != 32'h00000000)) begin
            FORWARD_A = 2'b01;
        end
        
        if ((RS2_DEC == RD_EXEC) && (RS2_DEC != 32'h00000000)) begin
            FORWARD_B = 2'b10;
            if (DMEM_READ_EXEC) begin
                STALL_FET = 1'b1;
                STALL_DEC = 1'b1;
            end
        end
        
        else if ((RS2_DEC == RD_MEM) && (RS2_DEC != 32'h00000000)) begin
            FORWARD_B = 2'b01;
        end
        
        if (PC_SRC) begin
            FLUSH_DEC = 1'b1;
            FLUSH_EXEC = 1'b1;
        end
    end
endmodule
