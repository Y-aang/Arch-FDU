`ifndef __PIPEREG_EX_MEM_SV
`define __PIPEREG_EX_MEM_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pipereg_EX_MEM
    import common::*;
    import pipes::*;(
        input logic clk, reset,
        input execute_data_t dataE_in,
        output execute_data_t dataE_out
);

    always_ff @ (posedge clk)
    begin
        if(reset) begin    
            dataE_out.result <= '0;
            dataE_out.pc <= 64'h8000_0000;
            dataE_out.ctl <= '0;
            dataE_out.dst <= '0;
            dataE_out.is_bubble <= 1'b1;
        end
        else begin
            dataE_out <= dataE_in;
        end
     end
    
endmodule


`endif