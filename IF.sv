`timescale 1ns/1ps
module IF(
    input logic clk, reset, stall, pc_src,
    input logic [31:0] pc_signed_offset,
    output logic [31:0] address,
    output logic [31:0] pc_new
);
    logic [31:0] pc_next;
    assign pc_new = address + 32'd4;
    always_comb begin
        pc_next = pc_src ? pc_signed_offset : pc_new;
    end
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= 32'h80000000;
        else if (!stall)
            address <= pc_next;
    end
endmodule
