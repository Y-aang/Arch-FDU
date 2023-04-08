`ifndef __CSR_SV
`define __CSR_SV


`ifdef VERILATOR
`include "pipeline/csr/csr_pkg.sv"
`else
`include "pipeline/csr/csr_pkg.sv"
`endif

module csr
	import common::*;
	import csr_pkg::*;(
	input logic clk, reset,
	input u1 valid, is_mret,
	input u12 csr_write_addr,
	input u12 csr_read_addr,
	input u64 write_data,
	output u64 read_data,
	output u64 pcselect_mepc

);
	csr_regs_t regs, regs_nxt;

	always_ff @(posedge clk) begin
		if (reset) begin
			regs <= '0;
			regs.mcause[1] <= 1'b1;
			regs.mepc[31] <= 1'b1;
		end else begin
			regs <= regs_nxt;
		end
	end

	// read
	always_comb begin
		read_data = '0;
		unique case(csr_read_addr)
			CSR_MIE: read_data = regs.mie;
			CSR_MIP: read_data = regs.mip;
			CSR_MTVEC: read_data = regs.mtvec;
			CSR_MSTATUS: read_data = regs.mstatus;
			CSR_MSCRATCH: read_data = regs.mscratch;
			CSR_MEPC: read_data = regs.mepc;
			CSR_MCAUSE: read_data = regs.mcause;
			CSR_MCYCLE: read_data = regs.mcycle;
			CSR_MTVAL: read_data = regs.mtval;
			default: begin
				read_data = '0;
			end
		endcase
	end

	// write
	always_comb begin
		regs_nxt = regs;
		regs_nxt.mcycle = regs.mcycle + 1;
		// Writeback: W stage
		unique if (valid) begin
			unique case(csr_write_addr)
				CSR_MIE: regs_nxt.mie = write_data;
				CSR_MIP:  regs_nxt.mip = write_data;
				CSR_MTVEC: regs_nxt.mtvec = write_data;
				CSR_MSTATUS: regs_nxt.mstatus = write_data;
				CSR_MSCRATCH: regs_nxt.mscratch = write_data;
				CSR_MEPC: regs_nxt.mepc = write_data;
				CSR_MCAUSE: regs_nxt.mcause = write_data;
				CSR_MCYCLE: regs_nxt.mcycle = write_data;
				CSR_MTVAL: regs_nxt.mtval = write_data;
				default: begin
					
				end
				
			endcase
			regs_nxt.mstatus.sd = regs_nxt.mstatus.fs != 0;
		end else if (is_mret) begin
			regs_nxt.mstatus.mie = regs_nxt.mstatus.mpie;
			regs_nxt.mstatus.mpie = 1'b1;
			regs_nxt.mstatus.mpp = 2'b0;
			regs_nxt.mstatus.xs = 0;
		end
		else begin end
	end
	assign pcselect_mepc = regs.mepc;
	
	
endmodule

`endif