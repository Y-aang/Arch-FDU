`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`include "pipeline/execute/multiplier.sv"
`include "pipeline/execute/divider.sv"
`else

`endif

module execute
	import common::*;
	import pipes::*;(
    input logic clk, reset,
	input decode_data_t dataD,
    output execute_data_t dataE

);
    u64 result;
    u128 divide_result;
    u64 multiply_result;
	u1 multiply_done, divide_done;
    u1 is_multiply, is_divide;
    u32 div_tmp;

    word_t alu_a, alu_b;

//取ALU操作数
    always_comb begin
        alu_a = '0;
        alu_b = '0;
        unique case(dataD.ctl.op)
            ADDI:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            XORI:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            ORI:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            ANDI:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            LUI:begin
                alu_a = dataD.immediate;
                alu_b = '0;
            end
            JAL:begin
                alu_a = dataD.pc;
                alu_b = {61'b0, 3'b100};
            end
            BEQ:begin
                alu_a = '0;
                alu_b = '0;
            end
            LD:begin
                alu_a = '0;
                alu_b = '0;
            end
            SD:begin
                alu_a = dataD.srcb;
                alu_b = '0;
            end
            SB:begin
                alu_a = dataD.srcb;
                alu_b = '0;
            end
            SH:begin
                alu_a = dataD.srcb;
                alu_b = '0;
            end
            SW:begin
                alu_a = dataD.srcb;
                alu_b = '0;
            end
            ADD:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            SUB:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            AND:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            OR:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            XOR:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;;
            end
            AUIPC:begin
                alu_a = dataD.pc;
                alu_b = dataD.immediate;
            end
            JALR:begin
                alu_a = dataD.pc;
                alu_b = {61'b0, 3'b100};
            end

            BNE:begin
                alu_a = '0;
                alu_b = '0;
            end
            BLT:begin
                alu_a = '0;
                alu_b = '0;
            end
            BGE:begin
                alu_a = '0;
                alu_b = '0;
            end
            BLTU:begin
                alu_a = '0;
                alu_b = '0;
            end
            BGEU:begin
                alu_a = '0;
                alu_b = '0;
            end
            SLTI:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            SLTIU:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            SLLI:begin
                alu_a = dataD.srca;
                alu_b = dataD.shamt;
            end
            SRLI:begin
                alu_a = dataD.srca;
                alu_b = dataD.shamt;
            end
            SRAI:begin
                alu_a = dataD.srca;
                alu_b = dataD.shamt;
            end
            SLL:begin
                alu_a = dataD.srca;
                // alu_b = {59'b0, dataD.srcb[4:0]};
                alu_b = dataD.srcb;
            end
            SLT:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            SLTU:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            SRL:begin
                alu_a = dataD.srca;
                alu_b = {58'b0, dataD.srcb[5:0]};
            end
            SRA:begin
                alu_a = dataD.srca;
                // alu_b = {59'b0, dataD.srcb[4:0]};
                alu_b = dataD.srcb;
            end
            ADDIW:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            SLLIW:begin
                alu_a = dataD.srca;
                alu_b = dataD.immediate;
            end
            SRLIW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = dataD.shamt;
            end
            SRAIW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = dataD.shamt;
            end
            ADDW:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            SUBW:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            SLLW:begin
                alu_a = dataD.srca;
                alu_b = {59'b0, dataD.srcb[4:0]};
            end
            SRLW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = {59'b0, dataD.srcb[4:0]};
            end
            SRAW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = {59'b0, dataD.srcb[4:0]};
            end

            //乘除法
            MUL:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            DIV:begin
                if(dataD.srca[63] == 1'b0)begin
                    alu_a = dataD.srca;
                end
                else begin
                    alu_a = ~dataD.srca + {63'b0, 1'b1};
                end
                if(dataD.srcb[63] == 1'b0)begin
                    alu_b = dataD.srcb;
                end
                else begin
                    alu_b = ~dataD.srcb + {63'b0, 1'b1};
                end
            end
            DIVU:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            REM:begin
                if(dataD.srca[63] == 1'b0)begin
                    alu_a = dataD.srca;
                end
                else begin
                    alu_a = ~dataD.srca + {63'b0, 1'b1};
                end
                if(dataD.srcb[63] == 1'b0)begin
                    alu_b = dataD.srcb;
                end
                else begin
                    alu_b = ~dataD.srcb + {63'b0, 1'b1};
                end
            end
            REMU:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            MULW:begin
                alu_a = dataD.srca;
                alu_b = dataD.srcb;
            end
            DIVW:begin
                if(dataD.srca[31] == 1'b0)begin
                    alu_a = {32'b0, dataD.srca[31:0]};
                end
                else begin
                    alu_a = {32'b0, ~dataD.srca[31:0]} + {63'b0, 1'b1};
                end
                if(dataD.srcb[31] == 1'b0)begin
                    alu_b = {32'b0, dataD.srcb[31:0]};
                end
                else begin
                    alu_b = {32'b0, ~dataD.srcb[31:0]} + {63'b0, 1'b1};
                end
            end
            DIVUW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = {32'b0, dataD.srcb[31:0]};
            end
            REMW:begin
                if(dataD.srca[31] == 1'b0)begin
                    alu_a = {32'b0, dataD.srca[31:0]};
                end
                else begin
                    alu_a = {32'b0, ~dataD.srca[31:0]} + {63'b0, 1'b1};
                end
                if(dataD.srcb[31] == 1'b0)begin
                    alu_b = {32'b0, dataD.srcb[31:0]};
                end
                else begin
                    alu_b = {32'b0, ~dataD.srcb[31:0]} + {63'b0, 1'b1};
                end
            end
            REMUW:begin
                alu_a = {32'b0, dataD.srca[31:0]};
                alu_b = {32'b0, dataD.srcb[31:0]};
            end

            CSRRW:begin
                alu_a = dataD.srca;
                alu_b = '0;
            end
            CSRRS:begin
                alu_a = dataD.csr_reg_write;
                alu_b = dataD.srca;
            end
            CSRRC:begin
                alu_a = dataD.csr_reg_write;
                alu_b = ~dataD.srca;
            end
            CSRRWI:begin
                alu_a = dataD.immediate;
                alu_b = '0;
            end
            CSRRSI:begin
                alu_a = dataD.csr_reg_write;
                alu_b = dataD.immediate;
            end
            CSRRCI:begin
                alu_a = dataD.csr_reg_write;
                alu_b = ~dataD.immediate;
            end

            default:begin
                alu_a = '0;
                alu_b = '0;
            end
        endcase
    end

    always_comb begin
        is_multiply = '0;
        is_divide = '0;
        dataE.is_waiting = '0;
        dataE.is_bubble = '0;
        if(dataD.pc != '0 &&//不知道有没有用的尝试
            dataD.is_bubble == 1'b0 &&( dataD.ctl.op == MUL || 
            dataD.ctl.op == MULW ))begin
            is_multiply = 1'b1;
            is_divide = 1'b0;
            dataE.is_waiting = ~multiply_done;
            dataE.is_bubble = ~multiply_done;
        end
        else if(dataD.pc != '0 &&//不知道有没有用的尝试
            dataD.is_bubble == 1'b0 && (dataD.ctl.op == DIV ||
            dataD.ctl.op == DIVU ||
            dataD.ctl.op == REM ||
            dataD.ctl.op == REMU ||
            dataD.ctl.op == DIVW ||
            dataD.ctl.op == DIVUW ||
            dataD.ctl.op == REMW ||
            dataD.ctl.op == REMUW ))begin
            is_multiply = 1'b0;
            is_divide = 1'b1;
            dataE.is_waiting = ~divide_done;
            dataE.is_bubble = ~divide_done;
        end
        else begin
            is_multiply = 1'b0;
            is_divide = 1'b0;
            dataE.is_waiting = 1'b0;
            dataE.is_bubble = dataD.is_bubble;
        end
    end
 
    alu alu(
        .a(alu_a), .b(alu_b),
        .alufunc(dataD.ctl.alufunc),
        .c(result)
    );

    multiplier_multicycle_from_single Multiplier(
        .clk, .resetn(reset), .valid(is_multiply),
        .a(alu_a), .b(alu_b),
        .done(multiply_done),
        .c(multiply_result)
    );

    divider_multicycle_from_single Divider(
        .clk, .resetn(reset), .valid(is_divide),
        .a(alu_a), .b(alu_b),
        .done(divide_done),
        .c(divide_result)
    );


    assign dataE.pc = dataD.pc;
    assign dataE.ctl = dataD.ctl;
    assign dataE.dst = dataD.dst;
    assign dataE.memory_address = dataD.memory_address;
    // assign dataE.is_bubble = dataD.is_bubble;

//写结果
    always_comb begin
        dataE.result = '0;
        unique case(dataD.ctl.op)
            ADDIW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SLLIW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            ADDW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SUBW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SLLW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SRLW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SRAW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end
            SRAIW:begin
                dataE.result = { {32{result[31]}},result[31:0] };
            end

            //乘除法
            DIV:begin
                if(dataD.srcb == '0)begin
                    dataE.result = '1;
                end
                else if((dataD.srca[63] == 1'b0 && 
                    dataD.srcb[63] == 1'b0) || 
                    (dataD.srca[63] == 1'b1 && 
                    dataD.srcb[63] == 1'b1))begin
                    dataE.result = divide_result[63:0];
                end
                else begin
                    dataE.result = ~divide_result[63:0] + {63'b0, 1'b1};
                end
            end
            DIVU:begin
                if(dataD.srcb == '0)begin
                    dataE.result = '1;
                end
                else begin
                    dataE.result = divide_result[63:0];
                end
            end
            REM:begin
                if(dataD.srcb == '0)begin
                    dataE.result = dataD.srca;
                end
                else if(dataD.srca[63] == 1'b0 )begin
                    dataE.result = divide_result[127:64];
                end
                else begin
                    dataE.result = ~divide_result[127:64] + {63'b0, 1'b1};
                end
            end
            REMU:begin
                if(dataD.srcb == '0)begin
                    dataE.result = dataD.srca;
                end
                else begin
                    dataE.result = divide_result[127:64];
                end
            end
            DIVW:begin
                if(dataD.srcb[31:0] == '0)begin
                    dataE.result = '1;
                end
                else if((dataD.srca[31] == 1'b0 && 
                    dataD.srcb[31] == 1'b0) || 
                    (dataD.srca[31] == 1'b1 && 
                    dataD.srcb[31] == 1'b1))begin
                    dataE.result = {{32{divide_result[31]}}, divide_result[31:0]};
                end
                else begin
                    // div_tmp = ~divide_result[31:0] + {31'b0, 1'b1};
                    dataE.result = {{32{div_tmp[31]}}, ~divide_result[31:0] + {31'b0, 1'b1}};
                end
            end
            DIVUW:begin
                if(dataD.srcb[31:0] == '0)begin
                    dataE.result = '1;
                end
                else begin
                    dataE.result = {{32{divide_result[31]}}, divide_result[31:0]};
                end
            end
            REMW:begin
                if(dataD.srcb[31:0] == '0)begin
                    dataE.result = {{32{dataD.srca[31]}}, dataD.srca[31:0]};
                end
                else if(dataD.srca[31] == 1'b0 )begin
                    dataE.result = {{32{divide_result[95]}}, divide_result[95:64]};
                end
                else begin
                    // div_tmp = ~divide_result[95:64] + {31'b0, 1'b1};
                    dataE.result = {{32{div_tmp[31]}}, div_tmp};
                end
            end
            REMUW:begin
                if(dataD.srcb[31:0] == '0)begin
                    dataE.result = {{32{dataD.srca[31]}}, dataD.srca[31:0]};
                end
                else begin
                    dataE.result = {{32{divide_result[95]}}, divide_result[95:64]};
                end
            end
            MUL:begin
                dataE.result = multiply_result;
            end
            MULW:begin
                dataE.result = { {32{multiply_result[31]}},multiply_result[31:0] };
            end

        //中断与异常
            CSRRW:begin
                dataE.result = dataD.csr_reg_write;
            end
            CSRRS:begin
                dataE.result = dataD.csr_reg_write;
            end
            CSRRC:begin
                dataE.result = dataD.csr_reg_write;
            end
            CSRRWI:begin
                dataE.result = dataD.csr_reg_write;
            end
            CSRRSI:begin
                dataE.result = dataD.csr_reg_write;
            end
            CSRRCI:begin
                dataE.result = dataD.csr_reg_write;
            end
            default:begin
                dataE.result = result;
            end
        endcase
    end
	
//div_tmp
    always_comb begin
        div_tmp = '0;
        unique case (dataD.ctl.op)
            DIVW:begin
                div_tmp = ~divide_result[31:0] + {31'b0, 1'b1};
            end
            REMW:begin
                div_tmp = ~divide_result[95:64] + {31'b0, 1'b1};
            end
            default: begin
                div_tmp = '0; 
            end
        endcase 
    end

//csr_result
    always_comb begin
        dataE.csr_result = '0;
        unique case (dataD.ctl.op)
            CSRRW:begin
                dataE.csr_result = result;
            end
            CSRRS:begin
                dataE.csr_result = result;
            end
            CSRRC:begin
                dataE.csr_result = result;
            end
            CSRRWI:begin
                dataE.result = result;
            end
            CSRRSI:begin
                dataE.csr_result = result;
            end
            CSRRCI:begin
                dataE.csr_result = result;
            end
            default: begin
                dataE.csr_result = '0;
            end
        endcase 
    end


endmodule

`endif
