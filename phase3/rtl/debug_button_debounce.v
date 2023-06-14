module debug_button_debounce(
	input  wire 		  clk   		,
	input  wire 		  rst     		,
	input  wire 		  debug_button	,
	output reg			  debug			,
	output reg			  led_debug		
);
	wire key_flag;
	wire key_value;
	key_debounce key_debounce_inst1(
		.sys_clk				(clk		 ),         //外部50M时钟
		.sys_rst_n				(rst		 ),         //外部复位信号，低有效
		.key					(debug_button),         //外部按键输入
		.key_flag				(key_flag	 ),         //按键数据有效信号
		.key_value         		(key_value	 )		  		//按键消抖后的数据  
    );
	
	
	always @(posedge clk)begin
		if(!rst) begin
			led_debug <= 1'b0;
			debug	  <= 1'b1;
		end
		else if(key_flag && !key_value) begin //消抖后的数据
			led_debug <= ~led_debug;
			debug	  <= ~debug;
		end
	end
	
endmodule


module key_debounce(
    input            sys_clk,          //外部50M时钟
    input            sys_rst_n,        //外部复位信号，低有效
    
    input            key,              //外部按键输入
    output reg       key_flag,         //按键数据有效信号
	output reg       key_value         //按键消抖后的数据  
    );

//reg define    
reg [31:0] delay_cnt;
reg        key_reg;

//*****************************************************
//**                    main code
//*****************************************************
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        key_reg   <= 1'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg <= key;
        if(key_reg != key)             //一旦检测到按键状态发生变化(有按键被按下或释放)
            delay_cnt <= 32'd1000000;  //给延时计数器重新装载初始值（计数时间为20ms）
        else if(key_reg == key) begin  //在按键状态稳定时，计数器递减，开始20ms倒计时
                 if(delay_cnt > 32'd0)
                     delay_cnt <= delay_cnt - 1'b1;
                 else
                     delay_cnt <= delay_cnt;
             end           
    end   
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        key_flag  <= 1'b0;
        key_value <= 1'b1;          
    end
    else begin
        if(delay_cnt == 32'd1) begin   //当计数器递减到1时，说明按键稳定状态维持了20ms
            key_flag  <= 1'b1;         //此时消抖过程结束，给出一个时钟周期的标志信号
            key_value <= key;          //并寄存此时按键的值
        end
        else begin
            key_flag  <= 1'b0;
            key_value <= key_value; 
        end  
    end   
end
    
endmodule 