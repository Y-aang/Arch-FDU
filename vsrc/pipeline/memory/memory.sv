`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module memory
    import common::*;
    import pipes::*;(
        
    input execute_data_t dataE,
    input  dbus_resp_t dresp,
    output dbus_req_t  dreq,
    output memory_data_t dataM
);

    assign dataM.is_bubble = dataE.is_bubble;
    always_comb begin
        unique case(dataE.ctl.op)
            SD:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1;
                dreq.addr = dataE.memory_address;
                dreq.size = MSIZE8;
                dreq.strobe = 8'b1111_1111;
                dreq.data = dataE.result;
            end
            LD:begin
                dataM.pc = dataE.pc;
                dataM.result = dresp.data;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1;
                dreq.addr = dataE.memory_address;
                dreq.size = MSIZE8;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
            end
            default:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b0;
                dreq.addr = '0;
                dreq.size = MSIZE8;
                dreq.strobe = '0;
                dreq.data = '0;

            end
        endcase
    end
endmodule


`endif