`timescale 1ns/1ps
module top_EXE(
    input logic [31:0] rs1_data, rs2_data, imm, pc,
    input logic [6:0] opcode,
    input logic alu_src,
    input logic [2:0] alu_op, fn3,
    input logic fu7_5,
    input logic [6:0] imm11_5,
    output logic [31:0] alu_out,
    output logic [31:0] rs2_selected,
    output logic [31:0] pc_new,
    output logic zero
);
    logic [4:0] alu_control;

    ALU_CONTROL ALU_CTRL(
        .alu_op(alu_op), .fn3(fn3), .fu7_5(fu7_5),
        .imm11_5(imm11_5), .control_out(alu_control)
    );

    rs2_mux MUX_RS2(
        .rs2_data(rs2_data), .imm(imm), .alu_src(alu_src),
        .opcode(opcode), .rs2(rs2_selected)
    );

    ALU ALU_EXE(
        .alu_control(alu_control), .rs1_data(rs1_data),
        .rs2_data(rs2_selected), .alu_out(alu_out), .zero(zero)
    );

    PCnew PC_EX(
        .opcode(opcode), .pc(pc), .imm(imm),
        .rs1_data(rs1_data), .pc_new(pc_new)
    );
endmodule
