module ifetch(
    // from PC 输入指令的地址
    input wire[31:0] pc_addr_i,
    // from ROM 从ROM获取指令内容
    input wire[31:0] rom_inst_i,
    // to ROM 将指令的地址传给ROM获取指令
    output wire[31:0] if2rom_addr_o,
    // to if_id 将指令信息传给下一级（地址addr和内容inst）
    output wire[31:0] inst_addr_o,
    output wire[31:0] inst_o
);

    assign if2rom_addr_o = pc_addr_i; //将从PC得到的指令地址传给ROM

    assign inst_addr_o = pc_addr_i; //将从PC得到的指令地址传给下一级

    assign inst_o = rom_inst_i; //将从ROM中得到的指令内容传给下一级


endmodule