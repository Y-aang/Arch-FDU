`ifndef __PIPES_SV
`define __PIPES_SV

`ifndef VERILATOR
`include "include/common.sv"
`endif
package pipes;
	import common::*;
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;
parameter F7_ADDI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ORI = 3'b110;
parameter F3_ANDI = 3'b111;
parameter F7_LUI = 7'b0110111;
parameter F7_JAL = 7'b1101111;
parameter F7_BEQ = 7'b1100011;
parameter F3_BEQ = 3'b000;
parameter F7_LD = 7'b0000011;
parameter F3_LD = 3'b011;
parameter F7_SD = 7'b0100011;
parameter F3_SD = 3'b011;

parameter F7_ADD = 7'b0110011;
parameter F3_ADD = 3'b000;
parameter F7_1_ADD = 7'b0000000;
parameter F3_SUB = 3'b000;
parameter F7_1_SUB = 7'b0100000;
parameter F3_AND = 3'b111;
parameter F7_1_AND = 7'b0000000;
parameter F3_OR = 3'b110;
parameter F7_1_OR = 7'b0000000;
parameter F3_XOR = 3'b100;
parameter F7_1_XOR = 7'b0000000;
parameter F7_AUIPC = 7'b0010111;
parameter F7_JALR = 7'b1100111;
parameter F3_JALR = 3'b000;

parameter F3_BNE = 3'b001;
parameter F3_BLT = 3'b100;
parameter F3_BGE = 3'b101;
parameter F3_BLTU = 3'b110;
parameter F3_BGEU = 3'b111;
parameter F3_SLTI = 3'b010;
parameter F3_SLTIU = 3'b011;
parameter F3_SLLI = 3'b001;
parameter F3_SRLI = 3'b101;
parameter F6_SRLI = 6'b000000;
parameter F6_SRAI = 6'b010000;
parameter F3_SLL = 3'b001;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_SRL = 3'b101;
parameter F7_1_SLL = 7'b0000000;
parameter F7_1_SRA = 7'b0100000;
parameter F7_ADDIW = 7'b0011011;
parameter F3_ADDIW = 3'b000;
parameter F3_SLLIW = 3'b001;
parameter F3_SRLIW = 3'b101;
parameter F6_SLLIW = 6'b000000;
parameter F6_SRAIW = 6'b010000;
parameter F7_ADDW = 7'b0111011;
parameter F3_ADDW = 3'b000;
parameter F3_SLLW = 3'b001;
parameter F3_SRLW = 3'b101;
parameter F7_1_ADDW = 7'b0000000;
parameter F7_1_SUBW = 7'b0100000;
parameter F7_1_SRLW = 7'b0000000;
parameter F7_1_SRAW = 7'b0100000;
parameter F7_1_SLLW = 7'b0000000;



/* Define pipeline structures here */
typedef struct packed {
	u32 raw_instr;
	u64 pc;
	u1 is_bubble;
} fetch_data_t;

typedef enum logic[5:0] { 
	UNKNOWN, ADDI, XORI, ORI, ANDI, 
	LUI, JAL, BEQ, LD, SD,
	ADD, SUB, AND, OR,
	XOR, AUIPC, JALR,

	BNE, BLT, BGE, BLTU, BGEU,
	SLTI, SLTIU, SLLI, SRLI, SRAI,
	SLL, SLT, SLTU, SRL, SRA,
	ADDIW, SLLIW, SRLIW, SRAIW,
	ADDW, SUBW, SLLW, SRLW, SRAW
 } decode_op_t;

typedef enum logic [4:0] {
	ALU_UNKNOWN, ALU_DIRECT, ALU_PASS,
	ALU_ADD, ALU_SUB, ALU_AND, ALU_OR,
	ALU_XOR,
	ALU_SSMALL, ALU_USMALL, ALU_LEFT, 
	ALU_URIGHT, ALU_SRIGHT
} alufunc_t;

typedef enum logic [4:0] {
	MAINTAIN, PLUS4, BEQ_P, BEQ_N, JAL_P, JALR_P
} instfunc_t;

typedef enum logic [1:0] {
	RESET_CONTINUE, RESET_RESET
} reset_t;

typedef enum logic [1:0] {
	INSTR_CONTINUE, INSTR_MAINTAIN
} instr_FETCH_t;

typedef struct packed {
	decode_op_t op;
	alufunc_t alufunc;
	u1 regwrite;
	u1 memwrite;
} control_t;

typedef struct packed {
	word_t srca, srcb, immediate, shamt;
	control_t ctl;
	creg_addr_t dst;
	word_t memory_address;
	u64 pc;
	u1 is_bubble;
} decode_data_t;

typedef struct packed {
	u64 pc;
	u64 result;
	control_t ctl;
	creg_addr_t dst;
	word_t memory_address;
	u1 is_bubble;
} execute_data_t;

typedef struct packed {
	u64 pc;
	u64 result;
	control_t ctl;
	creg_addr_t dst;
	word_t memory_address;
	u1 is_bubble;
} memory_data_t;

typedef struct packed {
	u64 pc;
	u64 result;
	control_t ctl;
	creg_addr_t dst;
	word_t memory_address;
	u1 is_bubble;
} writeback_data_t;

typedef struct packed {
	reset_t reset_IF_ID, reset_ID_EX;
	instr_FETCH_t instr_FETCH;
	logic ireq_valid;
	u64 pc_out;
	u64 offset_out;
	instfunc_t instfunc;
} hazard_data_t;

endpackage

`endif
