`include "defines.v"

module ex(
    // from id_ex
    input wire[31:0] inst_i,
    input wire[31:0] inst_addr_i,
    input wire[31:0] op1_i,
    input wire[31:0] op2_i,
    input wire[4:0]  rd_addr_i,
    input wire       rd_wen_i,
    // to regs 回写
    output reg[4:0]  rd_addr_o,
    output reg[31:0] rd_data_o,
    output reg       rd_wen_o,
    // to ctrl
    output reg[31:0] jump_addr_o,
    output reg       jump_en_o,
    output reg       hold_flag_o        
);
    wire[6:0] opcode;
    wire[4:0] rd;
    wire[2:0] funct3;
    wire[4:0] rs1;
    wire[4:0] rs2;
    wire[6:0] funct7;
    wire[11:0] imm;

    assign opcode = inst_i[6:0] ;
    assign rd     = inst_i[11:7];
    assign funct3 = inst_i[14:12];
    assign rs1    = inst_i[19:15];
    assign rs2    = inst_i[24:20];
    assign funct7 = inst_i[31:25];
    assign imm    = inst_i[31:20];

    // Branch Instruction
    wire[31:0] jump_imm;
    assign jump_imm = {{19{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}; // 符号位扩展补齐
    wire   op1_i_equal_op2_i;
    assign op1_i_equal_op2_i = (op1_i == op2_i) ? 1'b1 : 1'b0; // 三位运算符 如果两个操作数相等，op1_i_equal_op2_i = 1'b1

always @(*) begin
    case (opcode)

        `INST_TYPE_I:begin
            jump_addr_o = 32'b0;
            jump_en_o   = 1'b0;
            hold_flag_o = 1'b0;
            case (funct3)
            `INST_ADDI: begin
                rd_data_o = op1_i + op2_i;
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

        `INST_TYPE_R_M:begin
            jump_addr_o = 32'b0;
            jump_en_o   = 1'b0;
            hold_flag_o = 1'b0;
            case (funct3)
            `INST_ADD_SUB: begin
                if(funct7 == 7'b000_0000)begin // ADD
                    rd_data_o = op1_i + op2_i;
                    rd_addr_o = rd_addr_i;
                    rd_wen_o  = 1'b1;
                end
                else begin  //SUB
                    rd_data_o = op2_i - op1_i;
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

        `INST_TYPE_B:begin
            // 为了防止出现锁存器，所有信号需要赋值
            rd_data_o = 32'b0;
            rd_addr_o = 5'b0;
            rd_wen_o  = 1'b0;
            case (funct3)
            `INST_BEQ:begin   // BEQ 相等时跳转，即op1_i_equal_op2_i=1'b1时跳转
                jump_addr_o = (inst_addr_i + jump_imm) & {32{op1_i_equal_op2_i}};
                jump_en_o   = op1_i_equal_op2_i;
                hold_flag_o = 1'b0;
            end
            `INST_BNE:begin
                jump_addr_o = (inst_addr_i + jump_imm) & ~{32{op1_i_equal_op2_i}}; // 如果不跳转，jump_addr_o 赋全0
                jump_en_o   = ~op1_i_equal_op2_i;
                hold_flag_o = 1'b0;
            end 
            default:begin
                jump_addr_o = 32'b0;
                jump_en_o   = 1'b0;
                hold_flag_o = 1'b0;
            end 
            endcase
        end

        `INST_JAL:begin
            rd_data_o   = inst_addr_i + 32'h4;
            rd_addr_o   = rd_addr_i;
            rd_wen_o    = 1'b1;
            jump_addr_o = op1_i + inst_addr_i;
            jump_en_o   = 1'b1;
            hold_flag_o = 1'b0; 
        end

        `INST_LUI:begin
            rd_data_o   = op1_i;
            rd_addr_o   = rd_addr_i;
            rd_wen_o    = 1'b1;
            jump_addr_o = 32'b0;
            jump_en_o   = 1'b0;
            hold_flag_o = 1'b0;
        end     

        default: begin
            rd_data_o   = 32'b0;
            rd_addr_o   = 5'b0;
            rd_wen_o    = 1'b0;
            jump_addr_o = 32'b0;
            jump_en_o   = 1'b0;
            hold_flag_o = 1'b0;
        end
    endcase
end

endmodule