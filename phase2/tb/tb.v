module tb;
    
    reg clk;
    reg rst;

    // 寄存器x3：表示我们第几个test
    // 寄存器x26：表示我们测试结束 x26 =1
    // 寄存器x27：为0时表示fail，为1时表示pass
    wire x3 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
    wire x26 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[26];
    wire x27 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27];



    always #10 clk = ~clk;

    initial begin
        rst <= 1'b0;
        clk <= 1'b0;

        #30;
        rst <= 1'b1;
    end

    // rom initial
    initial begin
        $readmemb(".\inst_txt\rv32ui-p-add.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem);
    end

    initial begin
        // while (1) begin
        //     @(posedge clk)
        //     $display("-----------------------");
        //     $display("x27 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
        //     $display("x28 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
        //     $display("x29 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
        //     $display("-----------------------");
        // end
        wait(x26 == 32'b1); // 当 x26 = 1 时程序执行完毕
        if(x27 == 32'b1) begin
            $display("###########     pass !     ###########");
        end
        else begin
            $display("###########     fail !     ###########");
            for (r = 0; r < 31; r = r + 1) begin
                $display("x %2d register value is %d", r, tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);
            end
        end
    end




    open_risc_v_soc open_risc_v_soc_inst(
        .clk        (clk),
        .rst        (rst)
    );

endmodule