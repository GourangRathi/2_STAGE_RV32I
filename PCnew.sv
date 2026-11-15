`timescale 1ns/1ps
module PCnew(
    input logic [6:0] opcode,
    input logic [31:0] pc,
    input logic [31:0] imm,
    input logic [31:0] rs1_data,
    output logic [31:0] pc_new
);
    always_comb begin
        case (opcode)
            7'b1100011: pc_new = pc + imm; // conditional branch target
            7'b1101111: pc_new = pc + imm; // JAL target
            7'b1100111: pc_new = (rs1_data + imm) & 32'hFFFFFFFE; // JALR
            default:    pc_new = pc + 32'd4;
        endcase
    end
endmodule
