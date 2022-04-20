`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/fetch/pcselect.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/regfile/pipereg_IF_ID.sv"
`include "pipeline/regfile/pipereg_ID_EX.sv"
`include "pipeline/regfile/pipereg_EX_MEM.sv"
`include "pipeline/regfile/pipereg_MEM_WB.sv"
`include "pipeline/hazard/hazard.sv"
`else

`endif

module core 
	import common::*;
	import pipes::*;(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
);
	/* TODO: Add your pipeline here. */
	u64 pc, pc_nxt;
	always_ff @( posedge clk ) begin
		if(reset)	begin
			pc <= 64'h8000_0000; 
		end else begin
			pc <= pc_nxt;
		end
	end
	assign ireq.addr = pc;
	assign ireq.valid = dataH.ireq_valid;

	u32 raw_instr;
	assign raw_instr=iresp.data;

	fetch_data_t dataF, dataF_next;
	decode_data_t dataD, dataD_next;
	execute_data_t dataE, dataE_next;
	memory_data_t dataM, dataM_next;
	writeback_data_t dataW;
	hazard_data_t dataH;
	
	creg_addr_t ra1, ra2;
	word_t rd1, rd2;

	instfunc_t op;
    u64 offset;

//fetch
	pcselect pcselect(
		.pc(pc),
		.stall_pc(dataH.pc_out),
		.op(dataH.instfunc),
		.offset(dataH.offset_out),
		.pc_selected(pc_nxt)
	);

	fetch fetch(
		.raw_instr(raw_instr),
		.pc,
		.instr_FETCH(dataH.instr_FETCH),
		.dataF_next,
		.dataF
	);

	pipereg_IF_ID pipereg_IF_ID(
		.clk, .reset,
		.reset_IF_ID(dataH.reset_IF_ID),
		.dataF_in(dataF),
		.dataF_out(dataF_next)
	);

//decode
	decode decode(
		.dataF(dataF_next),
		.dataD,

		.ra1, .ra2, .rd1, .rd2,
		.op, .offset
	);

	regfile regfile(
		.clk, .reset,
		.ra1,
		.ra2,
		.rd1,
		.rd2,
		.wvalid(dataW.ctl.regwrite),
		.wa(dataW.dst),
		.wd(dataW.result)
	);

	pipereg_ID_EX pipereg_ID_EX(
		.clk, .reset,
		.reset_ID_EX(dataH.reset_ID_EX),
		.dataD_in(dataD),
		.dataD_out(dataD_next)
	);

	execute execute(
		.dataD(dataD_next),
		.dataE
	);

	pipereg_EX_MEM pipereg_EX_MEM(
		.clk, .reset,
		.dataE_in(dataE),
		.dataE_out(dataE_next)
	);

	memory memory(
		.dataE(dataE_next),
		.dresp,
		.dreq,
		.dataM
	);

	pipereg_MEM_WB pipereg_MEM_WB(
		.clk, .reset,
		.dataM_in(dataM),
		.dataM_out(dataM_next)
	);

	writeback writeback(
		.dataM(dataM_next),
		.dataW
	);

	hazard hazard(
		.dataE_dst(dataE.dst), .dataM_dst(dataM.dst), .dataW_dst(dataW.dst),
		.ra1, .ra2,
		.rd1, .rd2,
		.pc_in(dataD.pc),
		.ctl(dataD.ctl),
		.offset_in(offset),
		.op,

		.dataH
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (~dataW.is_bubble),
		.pc                 (dataW.pc),
		.instr              (0),
		.skip               (dataW.ctl.memwrite),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataW.ctl.regwrite),
		.wdest              ({3'b0, dataW.dst}),
		.wdata              (dataW.result)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif