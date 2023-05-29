`include "defines.v"
module id_ex(
    input wire clk,
    input wire rst,
    // from id
    input wire[31:0] inst_i,
    input wire[31:0] inst_addr_i,
    input wire[31:0] op1_i,
    input wire[31:0] op2_i,
    input wire[4:0]  rd_addr_i,
    input wire       reg_wen_i,
    // to ex
    output wire[31:0] inst_o,
    output wire[31:0] inst_addr_o,
    output wire[31:0] op1_o,
    output wire[31:0] op2_o,
    output wire[4:0]  rd_addr_o,
    output wire       reg_wen_o
);

dff_set #(32) dff_inst(clk, rst, `INST_NOP, inst_i, inst_o);

dff_set #(32) dff_inst_addr(clk, rst, 32'b0, inst_addr_i, inst_addr_o);

dff_set #(32) dff_op1(clk, rst, 32'b0, op1_i, op1_o);

dff_set #(32) dff_op2(clk, rst, 32'b0, op2_i, op2_o);

dff_set #(5) dff_rd_addr(clk, rst, `INST_NOP, rd_addr_i, rd_addr_o);

dff_set #(1) dff_reg_wen(clk, rst, 1'b0, reg_wen_i, reg_wen_o);

endmodule