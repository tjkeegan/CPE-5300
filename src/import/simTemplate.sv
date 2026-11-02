`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2025 07:05:32 PM
// Design Name: 
// Module Name: simTemplate
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


module simTemplate();

    logic CLK_TB = 0;
    logic RESET_TB;
    
    OTTER_MCU_SINGLE_CYCLE UUT (.CLK(CLK_TB), .RESET(RESET_TB));
    
    initial begin
        #10
        RESET_TB = 1;           // need to fix reset issue
        #20 
        RESET_TB = 0;
    end
    
    initial forever #10  CLK_TB =  ! CLK_TB;
    
endmodule
