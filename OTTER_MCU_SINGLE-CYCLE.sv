`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2025 10:33:42 AM
// Design Name: 
// Module Name: OTTER_MCU_SINGLE-CYCLE
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


typedef struct packed {
    // data
    logic [31:0]    instr, //current instruction
                    pc, // current pc
                    pc_4; // pc + 4
    logic [4:0]     rs1, // register address 1 from instr
                    rs2, // register address 2 from instr
                    rd; // return register address from instr
    logic [31:0]    rd1, // data from regfile
                    rd2; // data from regfile 2
    logic [31:0]    imm_ext;
    logic [1:0]     forward_a,
                    forward_b;
    logic [31:0]    write_data;
    logic [31:0]    alu_result, //result of ALU
                    mem_data,
                    result; //data read from memory
    // ctrl
    logic           jump,
                    pc_target_ctrl,
                    branch,
                    branch_ctrl;
    logic           reg_write; //write enable for regfile
    logic [1:0]     reg_src_ctrl; //mux control for regfile
    logic [2:0]     imm_sel;
    logic           alu_srca_ctrl,
                    alu_srcb_ctrl; //mux control for input to ALU
    logic [3:0]     alu_ctrl; //mux control for ALU operation
    logic           mem_write; //write enable to memory
} preg; //pipelined register

module OTTER_MCU_SINGLE_CYCLE(
    input CLK,
    input INTR,
    input RESET,
    input [31:0] IOBUS_IN,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
    );
    
    preg pfet, pdec, pexec, pmem, pwb;
    
    logic stall_fet, flush_dec, flush_exec, pc_src, branch_out;
    logic stall_dec = 0;
    logic [31:0] pc_target, pc_4, pc_in, forward_a_out, alu_src_a, alu_src_b;
    
    logic reg_write, mem_write, jump, pc_target_ctrl, branch, branch_ctrl, alu_srca_ctrl, alu_srcb_ctrl;
    logic [1:0] reg_src_ctrl, forward_a, forward_b;
    logic [2:0] imm_sel;
    logic [3:0] alu_ctrl;
    
    always_ff @ (posedge CLK) begin
        
        if (RESET) begin
            pfet <= '0;
            pdec <= '0;
            pexec <= '0;
            pmem <= '0;
            pwb <= '0;
        end
      
        else begin
            
            if (stall_dec == 1'b1) begin
                pdec <= pdec;
            end
            
            else if (flush_dec == 1'b1) begin
                pdec.pc           <= '0;
                pdec.pc_4         <= '0;
                pdec.instr         <= '0;
                pdec.rs1          <= '0;
                pdec.rs2          <= '0;
                pdec.rd           <= '0;
                pdec.rd1          <= '0;
                pdec.rd2          <= '0;
                pdec.imm_ext      <= '0;
                pdec.forward_a    <= 2'b00;
                pdec.forward_b    <= 2'b00;
                pdec.jump         <= 1'b0;
                pdec.branch       <= 1'b0;
                pdec.branch_ctrl  <= 1'b0;
                pdec.reg_write    <= 1'b0;
                pdec.reg_src_ctrl <= 2'b00;
                pdec.imm_sel      <= 3'b000;
                pdec.alu_srca_ctrl <= 1'b0;
                pdec.alu_srcb_ctrl <= 1'b0;
                pdec.alu_ctrl     <= 3'b000;
                pdec.mem_write    <= 1'b0;
            end
            
            else begin
                pdec.pc             <= pfet.pc;
                pdec.pc_4           <= pfet.pc_4;
                pdec.instr          <= pfet.instr; 
            end
            
            if (stall_dec == 1'b1) begin
                pexec.pc           <= 32'h00000013;
                pexec.pc_4         <= 32'h00000013;
                pexec.instr         <= 32'h00000013;
                pexec.rs1          <= 32'h00000013;
                pexec.rs2          <= 32'h00000013;
                pexec.rd           <= 32'h00000013;
                pexec.rd1          <= 32'h00000013;
                pexec.rd2          <= 32'h00000013;
                pexec.imm_ext      <= 32'h00000013;
                pexec.forward_a    <= 2'b00;
                pexec.forward_b    <= 2'b00;
                pexec.write_data   <= 32'h00000013;
                pexec.alu_result   <= 32'h00000013;
                pexec.jump         <= 1'b0;
                pexec.pc_target_ctrl <= 1'b0;
                pexec.branch       <= 1'b0;
                pexec.branch_ctrl  <= 1'b0;
                pexec.reg_write    <= 1'b0;
                pexec.reg_src_ctrl <= 2'b00;
                pexec.imm_sel      <= 3'b000;
                pexec.alu_srca_ctrl <= 1'b0;
                pexec.alu_srcb_ctrl <= 1'b0;
                pexec.alu_ctrl     <= 3'b000;
                pexec.mem_write    <= 1'b0;
            end
            
            else if (flush_exec == 1'b1) begin
                pexec.pc           <= '0;
                pexec.pc_4         <= '0;
                pexec.instr         <= '0;
                pexec.rs1          <= '0;
                pexec.rs2          <= '0;
                pexec.rd           <= '0;
                pexec.rd1          <= '0;
                pexec.rd2          <= '0;
                pexec.imm_ext      <= '0;
                pexec.forward_a    <= 2'b00;
                pexec.forward_b    <= 2'b00;
                pexec.write_data   <= '0;
                pexec.alu_result   <= '0;
                pexec.jump         <= 1'b0;
                pexec.pc_target_ctrl <= 1'b0;
                pexec.branch       <= 1'b0;
                pexec.branch_ctrl  <= 1'b0;
                pexec.reg_write    <= 1'b0;
                pexec.reg_src_ctrl <= 2'b00;
                pexec.imm_sel      <= 3'b000;
                pexec.alu_srca_ctrl <= 1'b0;
                pexec.alu_srcb_ctrl <= 1'b0;
                pexec.alu_ctrl     <= 3'b000;
                pexec.mem_write    <= 1'b0;
            end
            
            else begin
                pexec.pc           <= pdec.pc;
                pexec.pc_4         <= pdec.pc_4;
                pexec.instr         <= pdec.instr;
                pexec.rs1          <= pdec.rs1;
                pexec.rs2          <= pdec.rs2;
                pexec.rd           <= pdec.rd;
                pexec.rd1          <= pdec.rd1;
                pexec.rd2          <= pdec.rd2;
                pexec.imm_ext      <= pdec.imm_ext;
                pexec.forward_a    <= forward_a;
                pexec.forward_b    <= forward_b;
                pexec.jump         <= jump;
                pexec.pc_target_ctrl <= pc_target_ctrl;
                pexec.branch       <= branch;
                pexec.branch_ctrl  <= branch_ctrl;
                pexec.reg_write    <= reg_write;
                pexec.reg_src_ctrl <= reg_src_ctrl;
                pexec.imm_sel      <= imm_sel;
                pexec.alu_srca_ctrl <= alu_srca_ctrl;
                pexec.alu_srcb_ctrl <= alu_srcb_ctrl;
                pexec.alu_ctrl     <= alu_ctrl;
                pexec.mem_write    <= mem_write;
            end
            
            pmem.pc_4         <= pexec.pc_4;
            pmem.instr        <= pexec.instr;
            pmem.rd           <= pexec.rd;
            pmem.write_data   <= pexec.write_data;
            pmem.alu_result   <= pexec.alu_result;
            pmem.reg_write    <= pexec.reg_write;
            pmem.reg_src_ctrl <= pexec.reg_src_ctrl;
            pmem.mem_write    <= pexec.mem_write;
            
            pwb.pc_4         <= pmem.pc_4;
            pwb.instr        <= pmem.instr;
            pwb.rd           <= pmem.rd;
            pwb.alu_result   <= pmem.alu_result;
            pwb.mem_data     <= pmem.mem_data;
            pwb.reg_write    <= pmem.reg_write;
            pwb.reg_src_ctrl <= pmem.reg_src_ctrl;

        end
    end
        
//==== Instruction Fetch ===========================================

    TwoMux OTTER_PC_MUX (
        .SEL(pc_src),
        .ZERO(pc_4),
        .ONE(pc_target),
        .OUT(pc_in));

    PC OTTER_PC (
        .CLK(CLK), 
        .RST(RESET), 
        .PC_WRITE(~stall_fet),
        .PC_IN(pc_in),
        .PC_OUT(pfet.pc), 
        .PC_OUT_INC(pc_4));
           
    assign pfet.pc_4 = pc_4;
           
    IMEM OTTER_IMEM (
        .IMEM_A(pfet.pc), 
        .IMEM_OUT(pfet.instr));

//==== Instruction Decode ===========================================
    
    assign pdec.rs1 = pdec.instr[19:15];
    assign pdec.rs2 = pdec.instr[24:20];
    assign pdec.rd = pdec.instr[11:7];
    
    REG_FILE OTTER_REG_FILE(
        .CLK(CLK), 
        .EN(pwb.reg_write), 
        .ADR1(pdec.instr[19:15]), 
        .ADR2(pdec.instr[24:20]), 
        .WA(pwb.rd),
        .WD(pwb.result),
        .RS1(pdec.rd1), 
        .RS2(pdec.rd2));

    CU_DCDR OTTER_DCDR(
        .OPCODE(pdec.instr[6:0]),
        .FUNCT7(pdec.instr[14:12]), 
        .FUNCT3(pdec.instr[30]),
        .REG_WRITE(reg_write),
        .REG_SRC_CTRL(reg_src_ctrl),
        .MEM_WRITE(mem_write),
        .JUMP(jump),
        .PC_TARGET(pc_target_ctrl),
        .BRANCH(branch),
        .BRANCH_CTRL(branch_ctrl),
        .ALU_FUN(alu_ctrl), 
        .ALU_SRCA_CTRL(alu_srca_ctrl),
        .ALU_SRCB_CTRL(alu_srcb_ctrl),
        .IMM_SEL(imm_sel));    
    
    ImmediateGenerator OTTER_EXTEND(
        .IR(pdec.instr),
        .IMM_SEL(imm_sel),
        .IMM_EXT(pdec.imm_ext));
    
//==== Execute ======================================================
  
    FourMux OTTER_FWD_MUXA(
        .SEL(pexec.forward_a),
        .ZERO(pexec.rd1), 
        .ONE(pwb.result), 
        .TWO(pmem.alu_result), 
        .THREE(0), 
        .OUT(forward_a_out));
  
    FourMux OTTER_FWD_MUXB(
        .SEL(pexec.forward_b),
        .ZERO(pexec.rd2),
        .ONE(pwb.result),
        .TWO(pmem.alu_result),
        .THREE(0),
        .OUT(pexec.write_data));
  
    TwoMux OTTER_ALU_MUXA(
        .SEL(pexec.alu_srca_ctrl), 
        .ZERO(forward_a_out), 
        .ONE(pexec.pc), 
        .OUT(alu_src_a));

    TwoMux OTTER_ALU_MUXB(
        .SEL(pexec.alu_srcb_ctrl),
        .ZERO(pexec.write_data),
        .ONE(pexec.imm_ext),
        .OUT(alu_src_b));
    
    ALU OTTER_ALU(
        .SRC_A(alu_src_a), 
        .SRC_B(alu_src_b), 
        .ALU_FUN(pexec.alu_ctrl), 
        .BRANCH_OUT(branch_out),
        .RESULT(pexec.alu_result));  
        
    TargetGenerator OTTER_PC_TARGET_GEN (
        .SEL(pexec.pc_target_ctrl),
        .PC(pexec.pc),
        .RS1(forward_a_out),
        .IMM(pexec.imm_ext),
        .OUT(pc_target));
        
    assign pc_src = (pexec.jump | (pexec.branch & (pexec.branch_ctrl ^ branch_out)));

//==== Memory ======================================================

    DMEM OTTER_DMEM(
        .CLK(CLK),
        .DMEM_WRITE(pmem.mem_write),
        .DMEM_D(pmem.write_data),
        .DMEM_A(pmem.alu_result),
        .DMEM_OUT(pmem.mem_data));
    
    assign IOBUS_OUT = pmem.rs2;
    assign IOBUS_ADDR = pmem.alu_result;

//==== Write Back ==================================================

    FourMux OTTER_REG_MUX(
        .SEL(pwb.reg_src_ctrl),
        .ZERO(pwb.alu_result),
        .ONE(pwb.mem_data),
        .TWO(pwb.pc_4),
        .THREE(8'h00000000),
        .OUT(pwb.result));
    
//===== Hazard Detection ================================================

    

    HazardUnit OTTER_HU (
        .RS1_DEC(pdec.rs1),
        .RS2_DEC(pdec.rs2),
        .RS1_EXEC(pexec.rs1),
        .RS2_EXEC(pexec.rs2),
        .RD_EXEC(pexec.rd),
        .PC_SRC(pc_src),
        .REG_WRITE_MEM(pexec.reg_src_ctrl[0]),
        .RD_MEM(pmem.rd),
        .DMEM_READ_EXEC(pexec.reg_src_ctrl[0]),
        .RD_WB(pwb.rd),
        .REG_WRITE_WB(pwb.reg_write),
        .STALL_FET(stall_fet),
        .STALL_DEC(stall_dec),
        .FLUSH_DEC(flush_dec),
        .FLUSH_EXEC(flush_exec),
        .FORWARD_A(forward_a),
        .FORWARD_B(forward_b));
    
endmodule
