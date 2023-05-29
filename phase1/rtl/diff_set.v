module dff_set #(
    parameter DW = 32
)
(
    input wire clk,
    input wire rst,
    input wire[DW-1:0] set_data,
    input wire[DW-1:0] data_i,
    output reg[DW-1:0] data_o
);
always @(posedge clk) begin
        if(rst == 1'b0)
            data_o <= set_data; //NOP指令
        else
            data_o <= data_i;     
    end

endmodule