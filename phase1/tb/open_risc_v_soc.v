module open_risc_v_soc(
    input wire clk,
    input wire rst_n
);

// cpu to rom
wire[31:0] open_risc_v_inst_addr_o;

// rom to cpu
wire[31:0] rom_inst_i;

open_risc_v open_risc_v_inst(
    .clk                (clk),
    .rst_n              (rst_n),
    .inst_i             (rom_inst_i),
    .inst_addr_o        (open_risc_v_inst_addr_o)
);

rom rom_inst(
    .inst_addr_i        (open_risc_v_inst_addr_o),
    .inst_o             (rom_inst_i)
);

endmodule

