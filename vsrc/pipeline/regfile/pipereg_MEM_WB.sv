`ifndef __PIPEREG_MEM_WB_SV
`define __PIPEREG_MEM_WB_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pipereg_MEM_WB
    import common::*;
    import pipes::*;(
        input logic clk, reset,
        input memory_data_t dataM_in,
        output memory_data_t dataM_out
);

    always_ff @ (posedge clk)
    begin
        if(reset) begin    
            dataM_out.result <= '0;
            dataM_out.pc <= 64'h8000_0000;
            dataM_out.ctl <= '0;
            dataM_out.dst <= '0;
            dataM_out.is_bubble <= 1'b1;
        end
        else begin
            dataM_out <= dataM_in;
        end
     end
    
endmodule


`endif