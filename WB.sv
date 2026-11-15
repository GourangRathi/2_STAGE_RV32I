`timescale 1ns/1ps
module WB(
    input logic [31:0] alu_out, return_address, imm_out, PC_exe, read_data,
    input logic [6:0] opcode,
    input logic [1:0] memtoreg,
    output logic [31:0] wb_data
);
    always_comb begin
        wb_data = 32'b0;
        case (memtoreg)
            2'b00: wb_data = alu_out;
            2'b01: wb_data = read_data;
            2'b10: begin
                case (opcode)
                    7'b1101111, 7'b1100111: wb_data = return_address;
                    7'b0110111: wb_data = imm_out;
                    7'b0010111: wb_data = PC_exe + imm_out;
                    default:    wb_data = 32'b0;
                endcase
            end
            default: wb_data = 32'b0; // store/invalid: no register write
        endcase
    end
endmodule
