`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`else

`endif

module execute
	import common::*;
	import pipes::*;(
	input decode_data_t dataD,
    output execute_data_t dataE

);
    u64 result;
	

    word_t alu_a, alu_b;

//取ALU操作数
    always_comb begin
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

            default:begin
                alu_a = '0;
                alu_b = '0;
            end
        endcase
    end

    alu alu(
        .a(alu_a), .b(alu_b),
        .alufunc(dataD.ctl.alufunc),
        .c(result)
    );

    // assign dataE.result = result;

    assign dataE.pc = dataD.pc;
    // assign dataE.result = result;
    assign dataE.ctl = dataD.ctl;
    assign dataE.dst = dataD.dst;
    assign dataE.memory_address = dataD.memory_address;
    assign dataE.is_bubble = dataD.is_bubble;

    always_comb begin
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
            default:begin
                dataE.result = result;
            end
        endcase
    end
	
endmodule

`endif
