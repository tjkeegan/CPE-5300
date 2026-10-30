`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 01/24/2023 09:30:07 AM
// Module Name: PC
//////////////////////////////////////////////////////////////////////////////////

module PC(
    input logic CLK,
    input logic RST,
    input logic PC_WRITE,
    input logic [31:0] PC_IN,
    output logic [31:0] PC_OUT,
    output logic [31:0] PC_OUT_INC
    );
      
    always_ff@(posedge CLK) begin
        if (RST == 1'b1) begin //If reset is high, set PC output to 0
            PC_OUT <= 0;
        end
        else if (PC_WRITE == 1'b1) begin //if Reset is low and D is high,
            PC_OUT <= PC_IN;              //set PC output to the input!
        end
    end

    //Assign values to outputs
    assign PC_OUT_INC = PC_OUT + 4;
      
endmodule
