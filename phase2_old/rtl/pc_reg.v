module pc_reg(
    input wire       clk,
    input wire       rst,
    input wire[31:0] jump_addr_i,
    input wire       jump_en,
    output reg[31:0] pc_o
);

    always @(posedge clk) begin
        if(rst == 1'b0)
            pc_o <= 32'b0;
        else if(jump_en)begin
          pc_o <= jump_addr_i;
        end
        else begin
            pc_o <= pc_o + 3'd4; // PC + 4
        end
    end
endmodule