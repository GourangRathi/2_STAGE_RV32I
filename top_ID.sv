`timescale 1ns/1ps
module top_ID(
    input logic clk, reset, stall,
    input logic [31:0] instruction,
    input logic [31:0] wb_data,
    output logic [4:0] rs1, rs2, rd,
    output logic [6:0] opcode, imm11_5,
    output logic [2:0] fn3,
    output logic [12:0] imm,
    output logic func7_5,
    output logic [19:0] imm_uj,
    output logic [31:0] rs1_data, rs2_data,
    output logic [31:0] imm_output,
    output logic branch, mux_inp, memread, memwrite,
    output logic alusrc, reg_write,
    output logic [1:0] memtoreg,
    output logic [2:0] aluop
);
    logic rf_write_enable;

    ID ID1(
        .instruction(instruction), .rs1(rs1), .rs2(rs2), .rd(rd),
        .opcode(opcode), .imm11_5(imm11_5), .fn3(fn3), .imm(imm),
        .func7_5(func7_5), .imm_uj(imm_uj)
    );

    MAIN_CONTROL MC1(
        .opcode(opcode), .branch(branch), .mux_inp(mux_inp),
        .memread(memread), .memwrite(memwrite), .alusrc(alusrc),
        .reg_write(reg_write), .memtoreg(memtoreg), .aluop(aluop)
    );

    imm_generator IMM1(
        .imm_input(imm[11:0]), .fn3(fn3), .opcode(opcode),
        .imm_input_uj(imm_uj), .imm_output(imm_output)
    );

    assign rf_write_enable = reg_write && !stall;

    registerfile RF1(
        .rs1_sel(rs1), .rs2_sel(rs2), .rd_sel(rd),
        .wb_data(wb_data), .reg_write(rf_write_enable),
        .clk(clk), .reset(reset), .rs1_data(rs1_data), .rs2_data(rs2_data)
    );
endmodule
