`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 02/23/2023 09:39:49 AM
// Module Name: CU_DCDR
//////////////////////////////////////////////////////////////////////////////////

module CU_DCDR(
    input logic [6:0] OPCODE,
    input logic [2:0] FUNCT7,
    input logic FUNCT3,
    output logic REG_WRITE,
    output logic [1:0] REG_SRC_CTRL,
    output logic MEM_WRITE,
    output logic JUMP,
    output logic PC_TARGET,
    output logic BRANCH,
    output logic BRANCH_CTRL,
    output logic [3:0] ALU_FUN, 
    output logic ALU_SRCA_CTRL,
    output logic ALU_SRCB_CTRL,
    output logic [2:0] IMM_SEL
    );
    
    //Create always comb clock for decoder logic
    always_comb begin
        //Instantiate all outputs to 0 so as to avoid
        //unwanted leftovers from previous operations
        //and maintain direct control of outputs through
        //case statement below
        REG_WRITE = 1'b0;
        REG_SRC_CTRL = 2'b00;
        MEM_WRITE = 1'b0;
        JUMP = 1'b0;
        PC_TARGET = 1'b0;
        BRANCH = 1'b0;
        BRANCH_CTRL = 1'b0;
        ALU_FUN = 4'b0000;
        ALU_SRCA_CTRL = 1'b0;
        ALU_SRCB_CTRL = 1'b0;
        IMM_SEL = 3'b000;
        
        //Case statement depending on the opcode for the 
        //instruction, or the last seven bits of each instruction
        case (OPCODE)
            7'b0010111: begin // AUIPC
                REG_WRITE = 1'b1;
                REG_SRC_CTRL = 2'b00;
                ALU_SRCA_CTRL = 1'b1;
                ALU_SRCB_CTRL = 1'b1;
                IMM_SEL = 3'b011;
            end
            7'b1101111: begin // JAL
                REG_WRITE = 1'b1;
                REG_SRC_CTRL = 2'b10;
                JUMP = 1'b1;
                IMM_SEL = 3'b100;
            end
            7'b1100111: begin // JALR
                REG_WRITE = 1'b1;
                REG_SRC_CTRL = 2'b10;
                JUMP = 1'b1;
                PC_TARGET = 1'b1;
                IMM_SEL = 3'b000; // jalr uses itype
            end
            7'b0100011: begin // Store Instructions
                MEM_WRITE = 1'b1;
                ALU_SRCB_CTRL = 1'b1;
                IMM_SEL = 3'b001;
            end
            7'b0000011: begin // Load Instructions
                REG_WRITE = 1'b1;
                ALU_SRCB_CTRL = 1'b1;
                REG_SRC_CTRL = 2'b01;
            end
            7'b0110111: begin // LUI
                REG_WRITE = 1'b1;
                ALU_FUN = 4'b1001;
                ALU_SRCA_CTRL = 1'b1;
                ALU_SRCB_CTRL = 1'b1;
                IMM_SEL = 3'b011;
            end
            7'b0010011: begin // I-Type
                //set constants for all I-type instructions
                REG_WRITE = 1'b1;
                ALU_SRCB_CTRL = 1'b1;
                REG_SRC_CTRL = 2'b00;
                
                //Nested case statement
                //dependent on the function 3 bits
                case (FUNCT7)
                    3'b000: begin ALU_FUN = 4'b0000; end
                    3'b001: begin ALU_FUN = 4'b0001; end
                    3'b010: begin ALU_FUN = 4'b0010; end
                    3'b011: begin ALU_FUN = 4'b0011; end
                    3'b100: begin ALU_FUN = 4'b0100; end
                    3'b101: begin
                        //nested case statement
                        //dependent on the 30th bit for 
                        //instructions that have the same opcode and 
                        //fucntion 3 bits
                        case(FUNCT3)
                            1'b0: begin ALU_FUN = 4'b0101; end
                            1'b1: begin ALU_FUN = 4'b1101; end
                            default: begin end
                        endcase
                    end
                    3'b110: begin ALU_FUN = 4'b0110; end
                    3'b111: begin ALU_FUN = 4'b0111; end
                endcase
            end
            7'b0110011: begin // R-Type
                //set constants for all R-types;
                //ALU_FUN is just the concatenation of
                //the 30th bit and the function 3 bits
                REG_WRITE = 1'b1;
                REG_SRC_CTRL = 2'b00;
                ALU_FUN = {FUNCT3, FUNCT7};
            end
            7'b1100011: begin // B-Type
                //nested case statement dependent on the
                //function three bits.
                //Because there are six real branch instructions, there
                //are six pairs of if-else statements in each of six cases
                //for the branch instructions.
                IMM_SEL = 3'b010;
                BRANCH = 1'b1;
                case(FUNCT7)
                    3'b000: begin   // BEQ
                        ALU_FUN = 4'b1000;
                    end
                    3'b001: begin   // BNE
                        ALU_FUN = 4'b1000;
                        BRANCH_CTRL = 1'b1;
                    end
                    3'b100: begin   // BLT
                        ALU_FUN = 4'b0010;
                    end
                    3'b101: begin   // BGT
                        ALU_FUN = 4'b0010;
                        BRANCH_CTRL = 1'b1;
                    end
                    3'b110: begin   // BLTU
                        ALU_FUN = 4'b0011;
                    end
                    3'b111: begin   // BGTU
                        ALU_FUN = 4'b0011;
                        BRANCH_CTRL = 1'b1;
                    end
                endcase
            end
            default: begin end
        endcase
    end
    
endmodule
