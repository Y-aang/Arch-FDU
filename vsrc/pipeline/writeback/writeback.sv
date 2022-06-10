`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module writeback
    import common::*;
    import pipes::*;(
        
    input memory_data_t dataM,
    output writeback_data_t dataW
);

    
    assign dataW.is_bubble = dataM.is_bubble;
    always_comb begin
        dataW.pc = '0;
        dataW.result = '0;
        dataW.ctl = '0;
        dataW.dst = '0;
        dataW.memory_address = '0;
        unique case(dataM.ctl.op)
            default:begin
                dataW.pc = dataM.pc;
                dataW.result = dataM.result;
                dataW.ctl = dataM.ctl;
                dataW.dst = dataM.dst;
                dataW.memory_address = dataM.memory_address;
            end
        endcase
    end
    
endmodule


`endif