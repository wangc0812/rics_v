module tb;
    
    reg clk;
    reg rst;

    always #10 clk = ~clk;

    initial begin
        rst <= 1'b0;
        clk <= 1'b0;

        #30;
        rst <= 1'b1;
    end

    // rom initial
    initial begin
        $readmemb("inst_data_ADD.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
    end

    initial begin
        while (1) begin
            @(posedge clk)
            $display("-----------------------");
            $display("x27 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
            $display("x28 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
            $display("x29 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
            $display("-----------------------");
        end
    end




    open_risc_v_soc open_risc_v_soc_inst(
        .clk        (clk),
        .rst      (rst)
    );

endmodule