`timescale 1ns/1ps
module IF_ID(
    input  logic clk, reset, stall, flush,
    input  logic [31:0] instruction_in,
    input  logic [31:0] pc_in,
    input  logic [31:0] pc_plus4_in,
    output logic [31:0] instruction_out,
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus4_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= 32'b0;
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
        end else if (flush) begin
            instruction_out <= 32'b0; // bubble/NOP
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
        end else if (!stall) begin
            instruction_out <= instruction_in;
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
        end
    end
endmodule
