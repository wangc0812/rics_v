module open_risc_v_soc(
	input  wire 		  clk   		,
	input  wire 		  rst     		,
	input  wire 		  uart_rxd		,
	input  wire 		  debug_button	, //debug 按键
	output wire			  led_debug		,//debug 灯
	output wire			  led2		  
);
	
	
	
	
	
	// open_risc_v to rom 
	wire[31:0] open_risc_v_inst_addr_o;
	//rom to open_risc_v
	wire[31:0] rom_inst_o;
	
	// open_risc_v to ram
	wire       open_risc_v_mem_wr_req_o ;
	wire[3:0]  open_risc_v_mem_wr_sel_o ;
	wire[31:0] open_risc_v_mem_wr_addr_o;
	wire[31:0] open_risc_v_mem_wr_data_o;
	wire 	   open_risc_v_mem_rd_req_o ;
	wire[31:0] open_risc_v_mem_rd_addr_o;
	//ram to open_risc_v
	wire[31:0] ram_rd_data_o;
	//uart_debug to rom
	
	wire 		uart_debug_ce;
	wire 		uart_debug_wen;
	wire[31:0]  uart_debug_addr_o;
	wire[31:0]  uart_debug_data_o;	
	
	//debug_button_debounce to debug
	wire 		debug;
		
	debug_button_debounce debug_button_debounce_inst(
		.clk   				(clk			),
		.rst     			(rst			),
		.debug_button		(debug_button	),
		.debug				(debug			),
		.led_debug			(led_debug		)
		
	);
	
	
	open_risc_v open_risc_v_inst(
		.clk  			    (clk  						),
		.rst 				(rst						),
		.inst_i				(rom_inst_o					),
		.inst_addr_o		(open_risc_v_inst_addr_o	),
		.mem_rd_req_o		(open_risc_v_mem_rd_req_o	),
		.mem_rd_addr_o		(open_risc_v_mem_rd_addr_o	),
		.mem_rd_data_i		(ram_rd_data_o				),
		.mem_wr_req_o		(open_risc_v_mem_wr_req_o	),
		.mem_wr_sel_o		(open_risc_v_mem_wr_sel_o	),
		.mem_wr_addr_o		(open_risc_v_mem_wr_addr_o	),
		.mem_wr_data_o		(open_risc_v_mem_wr_data_o	)	
    );

	assign led2 = open_risc_v_mem_wr_data_o[2];
	
	ram ram_inst(
		.clk		(clk								),
		.rst		(rst 								),
		.wen		(open_risc_v_mem_wr_sel_o			),//写端口
		.w_addr_i	(open_risc_v_mem_wr_addr_o			),
		.w_data_i	(open_risc_v_mem_wr_data_o			),
		.ren		(open_risc_v_mem_rd_req_o			),//读端口	
		.r_addr_i	(open_risc_v_mem_rd_addr_o			),
		.r_data_o	(ram_rd_data_o						)
	);
	
	
	

	rom rom_inst(
		.clk		(clk					 ),
		.rst		(debug					 ),	
		.wen		(uart_debug_wen			 ),//写端口  来自串口
		.w_addr_i	(uart_debug_addr_o 		 ),
		.w_data_i	(uart_debug_data_o 		 ),
		.ren		(1'b1					 ),//指令读端口	
		.r_addr_i	(open_risc_v_inst_addr_o ),
		.r_data_o	(rom_inst_o				 )
	);

	uart_debug uart_debug_inst(
		.clk				(clk				),
		.debug				(debug				),
		.uart_rxd 			(uart_rxd			), 	
		.ce			    	(uart_debug_ce		),
		.wen			    (uart_debug_wen		),
		.addr_o			    (uart_debug_addr_o	),
		.data_o			    (uart_debug_data_o	)

	);

endmodule