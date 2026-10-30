`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2025 10:13:53 AM
// Design Name: 
// Module Name: ImmediateGenerator
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


module ImmediateGenerator(
    input logic [31:0] IR,
    input logic [2:0] IMM_SEL,
    output logic [31:0] IMM_EXT
    );
    
    always_comb begin
        
        IMM_EXT = 8'h00000000;
        
        case (IMM_SEL)
            3'b000: begin // ITYPE
                IMM_EXT = {{21{IR[31]}}, IR[30:25], IR[24:20]};
            end
            3'b001: begin // STYPE
                IMM_EXT = {{21{IR[31]}}, IR[30:25], IR[11:7]};
            end
            3'b010: begin // BTYPE
                IMM_EXT = {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
            end
            3'b011: begin // UTYPE
                IMM_EXT = {IR[31:12], 12'b0};
            end
            3'b100: begin // JTYPE
                IMM_EXT = {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
            end
            default: begin end
        endcase
    end
    
endmodule
