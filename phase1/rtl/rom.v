module rom(
    input wire[31:0] inst_addr_i,
    output reg[31:0] inst_o
);

    reg[31:0] rom_mem[0:11]; // 2^{12}=4096个32b的空间

    always @(*) begin
        //reg 类型的组合逻辑需要在always语句下赋值
         inst_o = rom_mem[inst_addr_i>>2]; // 由于此时的inst_addr_i被PC+4了，需要减去。右移两位
    end
endmodule