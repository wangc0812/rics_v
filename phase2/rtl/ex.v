`include "defines.v"

module ex(
	//from id_ex
	input wire[31:0] inst_i,	
	input wire[31:0] inst_addr_i,
	input wire[31:0] op1_i,
	input wire[31:0] op2_i,
	input wire[4:0]  rd_addr_i,
	input wire 		 rd_wen_i,
	input wire[31:0] base_addr_i,
	input wire[31:0] addr_offset_i,
	//to regs
	output reg[4:0] rd_addr_o,
	output reg[31:0]rd_data_o,
	output reg 	    rd_wen_o,
	
	//to ctrl
	output reg[31:0]jump_addr_o,
	output reg   	jump_en_o,
	output reg  	hold_flag_o
);

	wire[6:0] opcode; 
	wire[4:0] rd; 
	wire[2:0] func3; 
	wire[4:0] rs1;
	wire[4:0] rs2;
	wire[6:0] func7;
	wire[11:0]imm;
	// wire[4:0] shamt;
	
	assign opcode = inst_i[6:0];
	assign rd 	  = inst_i[11:7];
	assign func3  = inst_i[14:12];
	assign rs1 	  = inst_i[19:15];
	assign rs2 	  = inst_i[24:20];
	assign func7  = inst_i[31:25];
	assign imm    = inst_i[31:20];
	// assign shamt  = inst_i[24:20];
	
	
	
	// branch
	// wire[31:0] jump_imm = {{19{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
	wire  	   op1_i_equal_op2_i;
	wire 	   op1_i_less_op2_i_signed;
	wire 	   op1_i_less_op2_i_unsigned;
	
	assign	   op1_i_equal_op2_i         = (op1_i == op2_i)?1'b1:1'b0;
	assign	   op1_i_less_op2_i_signed   = ($signed(op1_i) < $signed(op2_i))?1'b1:1'b0;
	assign	   op1_i_less_op2_i_unsigned = (op1_i) < (op2_i)?1'b1:1'b0;

	// Type I
	wire[31:0] SRA_mask;
	assign 	   SRA_mask = (32'hffff_ffff) >> op2_i[4:0];

	// ALU
	wire[31:0] op1_i_add_op2_i;
	wire[31:0] op1_i_and_op2_i;
	wire[31:0] op1_i_xor_op2_i;
	wire[31:0] op1_i_or_op2_i;
	wire[31:0] op1_i_shift_left_op2_i;
	wire[31:0] op1_i_shift_right_op2_i;
	wire[31:0] base_addr_add_addr_offset;

	assign op1_i_add_op2_i  			= op1_i + op2_i;					//  加法器
	assign op1_i_and_op2_i 				= op1_i & op2_i;					//  与门
	assign op1_i_xor_op2_i 				= op1_i ^ op2_i;					//	异或门
	assign op1_i_or_op2_i 				= op1_i | op2_i;					//	或门
	assign op1_i_shift_left_op2_i 		= op1_i << op2_i;					//  左移单元
	assign op1_i_shift_right_op2_i 		= op1_i >> op2_i;					//	右移单元
	assign base_addr_add_addr_offset 	= base_addr_i + addr_offset_i;		//	计算地址单元


	
	always @(*)begin
		
		case(opcode)		
			`INST_TYPE_I:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
				case(func3)

					`INST_ADDI:begin
						rd_data_o = op1_i_add_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_SLTI:begin
						rd_data_o = {30'b0, op1_i_less_op2_i_signed};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_SLTIU:begin
						rd_data_o = {30'b0, op1_i_less_op2_i_unsigned};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_XORI:begin
						rd_data_o = op1_i_xor_op2_i ;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_ORI:begin
						rd_data_o = op1_i_or_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_ANDI:begin
						rd_data_o = op1_i_and_op2_i ;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_SLLI:begin
						rd_data_o = op1_i_shift_left_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end

					`INST_SRI:begin
						if (func7[5] == 1'b1) begin // SRAI
							rd_data_o = (op1_i_shift_right_op2_i & SRA_mask) | ({32{op1_i[31]}} & (~SRA_mask));
						    rd_addr_o = rd_addr_i;
						    rd_wen_o  = 1'b1;
						end

						else begin   // SRLI
						   rd_data_o =op1_i_shift_right_op2_i;
						   rd_addr_o = rd_addr_i;
						   rd_wen_o  = 1'b1;
						end
					end

					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;
					end						
				endcase
			end	
			
			`INST_TYPE_R_M:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
				case(func3)

					`INST_ADD_SUB:begin
						if(func7[5] == 1'b0)begin//add
							rd_data_o = op1_i_add_op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;
						end

						else begin
							rd_data_o = op1_i - op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1; 								
						end
					end

					`INST_SLL:begin
						rd_data_o = op1_i_shift_left_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1; 								
					end

					`INST_SLT:begin
						rd_data_o = {30'b0, op1_i_less_op2_i_signed};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1; 
					end

					`INST_SLTU:begin
						rd_data_o = {30'b0, op1_i_less_op2_i_unsigned};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1; 
					end

					`INST_XOR:begin
						rd_data_o = op1_i_xor_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1; 
					end

					`INST_SR:begin
						if (func7[5] == 1'b1) begin // SRAI
							rd_data_o = (op1_i_shift_right_op2_i & SRA_mask) | ({32{op1_i[31]}} & (~SRA_mask));
						    rd_addr_o = rd_addr_i;
						    rd_wen_o  = 1'b1;
						end
						else begin   // SRLI
						   rd_data_o = op1_i_shift_right_op2_i;
						   rd_addr_o = rd_addr_i;
						   rd_wen_o  = 1'b1;
						end
					end
					
					`INST_OR:begin
					   	rd_data_o = op1_i_or_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1; 
					end

					`INST_AND:begin
						rd_data_o = op1_i_and_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;  
					end
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;					
					end
				endcase
			end	
			
			`INST_TYPE_B:begin
				rd_data_o = 32'b0; 
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;			
				case(func3)
					`INST_BEQ:begin
						jump_addr_o = base_addr_add_addr_offset; 
						jump_en_o	= op1_i_equal_op2_i;
						hold_flag_o = 1'b0;					
					end					
					`INST_BNE:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_equal_op2_i;
						hold_flag_o = 1'b0;					
					end
					`INST_BLT:begin
						jump_addr_o = base_addr_add_addr_offset};
						jump_en_o	= op1_i_less_op2_i_signed;
						hold_flag_o = 1'b0;					
					end
					`INST_BLTU:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= op1_i_less_op2_i_unsigned;
						hold_flag_o = 1'b0;					
					end
					`INST_BGE:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_less_op2_i_signed;
						hold_flag_o = 1'b0;					
					end
					`INST_BGEU:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_less_op2_i_unsigned;
						hold_flag_o = 1'b0;					
					end	
					default:begin
						jump_addr_o = 32'b0;
						jump_en_o	= 1'b0;
						hold_flag_o = 1'b0;					
					end
				endcase
			end

			`INST_JAL:begin
				rd_data_o   = op1_i_and_op2_i;
				rd_addr_o   = rd_addr_i;
				rd_wen_o    = 1'b1;
				jump_addr_o = base_addr_add_addr_offset;
				jump_en_o	= 1'b1;
				hold_flag_o = 1'b0;				
			end

			`INST_JALR:begin
				rd_data_o = op1_i_and_op2_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = base_addr_add_addr_offset;
				jump_en_o	= 1'b1;
				hold_flag_o = 1'b0;				
			end		

			`INST_LUI:begin
				rd_data_o = op1_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
			end	

			`INST_AUIPC:begin
				rd_data_o = op1_i_add_op2_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
			end

			default:begin
				rd_data_o = 32'b0;
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;				
			end
		endcase
	end

	
	
	
endmodule