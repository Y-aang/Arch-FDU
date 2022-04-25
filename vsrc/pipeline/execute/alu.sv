`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c
);
	u32 e;
	always_comb begin
		c = '0;
		e = '0;
		unique case(alufunc)
		
			ALU_DIRECT: begin c = a; e='0; end
			ALU_ADD: begin c = a + b; e='0; end
			ALU_SUB: begin c = a - b; e='0; end
			ALU_AND: begin c = a & b; e='0; end
			ALU_OR: begin c = a | b; e='0; end
			ALU_XOR: begin c = a ^ b; e='0; end

			ALU_SSMALL: begin c = {63'b0,  $signed(a) < $signed(b) }; e='0; end
			ALU_USMALL: begin c = {63'b0,  a < b }; e='0; end
			ALU_LEFT: begin c = a << b[5:0]; e='0; end
			ALU_URIGHT: begin c = a >> b[5:0]; e='0; end
			ALU_SRIGHT: begin c = $signed(a) >>> b[5:0]; e='0; end
			ALU_URIGHT_32: begin
				e = a[31:0] >> b[5:0];
				c = {{32{e[31]}}, e };
			end
			ALU_SRIGHT_32: begin
				e = $signed(a[31:0]) >>> b[5:0];
				c = {{32{e[31]}}, e };
			end
			default: begin
				
			end
		endcase
	end
	
endmodule

`endif
