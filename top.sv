`timescale 1ns/1ps
module top(
    input logic clk,
    input logic reset,
    input logic stall,
    input logic pc_src,
    input logic [31:0] instruction, // instruction-memory data at address
    input logic [31:0] read_data,   // data-memory read data at alu_out
    output logic [31:0] address,    // instruction-memory address (PC)
    output logic [31:0] pc_new,     // sequential PC + 4
    output logic [4:0] rs1, rs2, rd,
    output logic [6:0] opcode, imm11_5,
    output logic [2:0] fn3,
    output logic [12:0] imm,
    output logic func7_5,
    output logic [19:0] imm_uj,
    output logic [31:0] rs1_data, rs2_data,
    output logic [31:0] imm_output,
    output logic branch, mux_inp, memread, memwrite, alusrc, reg_write,
    output logic [1:0] memtoreg,
    output logic [2:0] aluop,
    output logic [31:0] alu_out,
    output logic [31:0] rs2_selected,
    output logic [31:0] exe_pc_new,
    output logic zero,
    output logic [31:0] wb_data
);
    // IF/ID pipeline-register outputs: all Stage-2 values must belong
    // to the same instruction.
    logic [31:0] instruction_s2, pc_s2, pc_plus4_s2;
    logic branch_s2, mux_inp_s2, memread_s2, memwrite_s2;
    logic alusrc_s2, reg_write_s2;
    logic [1:0] memtoreg_s2;
    logic [2:0] aluop_s2;
    logic branch_taken, jump_taken, redirect, flush;
    logic [31:0] target_pc;

    // Stage 1: Instruction Fetch. The PC is redirected when a
    // Stage-2 branch/jump resolves as taken.
    IF IF1(
        .clk(clk), .reset(reset), .stall(stall),
        .pc_src(redirect), .pc_signed_offset(target_pc),
        .address(address), .pc_new(pc_new)
    );

    // Pipeline register between IF and the combined ID/EX/MEM/WB stage.
    IF_ID PIPELINE_REG(
        .clk(clk), .reset(reset), .stall(stall), .flush(flush),
        .instruction_in(instruction), .pc_in(address),
        .pc_plus4_in(pc_new),
        .instruction_out(instruction_s2), .pc_out(pc_s2),
        .pc_plus4_out(pc_plus4_s2)
    );

    // Stage 2: Decode and register-file read.
    top_ID ID1(
        .clk(clk), .reset(reset), .stall(stall),
        .instruction(instruction_s2), .wb_data(wb_data),
        .rs1(rs1), .rs2(rs2), .rd(rd), .opcode(opcode),
        .imm11_5(imm11_5), .fn3(fn3), .imm(imm),
        .func7_5(func7_5), .imm_uj(imm_uj),
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .imm_output(imm_output), .branch(branch_s2),
        .mux_inp(mux_inp_s2), .memread(memread_s2),
        .memwrite(memwrite_s2), .alusrc(alusrc_s2),
        .reg_write(reg_write_s2), .memtoreg(memtoreg_s2),
        .aluop(aluop_s2)
    );

    // Stage 2: Execute and calculate a possible control-transfer target.
    top_EXE EXE1(
        .rs1_data(rs1_data), .rs2_data(rs2_data),
        .imm(imm_output), .pc(pc_s2), .opcode(opcode),
        .alu_src(alusrc_s2), .alu_op(aluop_s2),
        .fn3(fn3), .fu7_5(func7_5), .imm11_5(imm11_5),
        .alu_out(alu_out), .rs2_selected(rs2_selected),
        .pc_new(exe_pc_new), .zero(zero)
    );

    // The ALU's zero output represents the selected branch condition
    // for BEQ/BNE/BLT/BGE/BLTU/BGEU.
    assign branch_taken = branch_s2 && zero;
    assign jump_taken = (opcode == 7'b1101111) ||
                        (opcode == 7'b1100111);
    assign redirect = branch_taken || jump_taken || pc_src;
    assign flush = redirect;
    assign target_pc = exe_pc_new;

    // Stage 2: External data memory is addressed by alu_out.
    // Keep side-effect enables low while the stage is stalled.
    assign branch   = branch_s2;
    assign mux_inp  = mux_inp_s2;
    assign memread  = memread_s2 && !stall;
    assign memwrite = memwrite_s2 && !stall;
    assign alusrc   = alusrc_s2;
    assign reg_write = reg_write_s2 && !stall;
    assign memtoreg = memtoreg_s2;
    assign aluop    = aluop_s2;

    // Writeback uses the PC and PC+4 saved with this Stage-2 instruction.
    WB WB1(
        .alu_out(alu_out), .return_address(pc_plus4_s2),
        .imm_out(imm_output), .PC_exe(pc_s2),
        .read_data(read_data), .opcode(opcode),
        .memtoreg(memtoreg_s2), .wb_data(wb_data)
    );
endmodule
