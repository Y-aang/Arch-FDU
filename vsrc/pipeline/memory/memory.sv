`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/readdata.sv"
`include "pipeline/memory/writedata.sv"
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

    msize_t msize;
    u1 mem_unsigned;
    u64 readdata_result, writedata_result;
    strobe_t strobe;
    
    readdata readdata(
        ._rd(dresp.data), .rd(readdata_result),
        .addr( dataE.memory_address[2:0] ),
        .msize,
        .mem_unsigned
    );

    writedata writedata(
        .addr( dataE.memory_address[2:0] ),
        ._wd(dataE.result),
        .msize,
        .wd(writedata_result),
        .strobe
    );

    
    assign dreq.size = msize;

    assign dataM.is_bubble = dataE.is_bubble;
    always_comb begin
        unique case(dataE.ctl.op)
            SD:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE8;
                dreq.strobe = strobe;
                dreq.data = writedata_result;
                mem_unsigned= 0;
            end
            SB:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE1;
                dreq.strobe = strobe;
                dreq.data = writedata_result;
                mem_unsigned= 0;
            end
            SH:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE2;
                dreq.strobe = strobe;
                dreq.data = writedata_result;
                mem_unsigned= 0;
            end
            SW:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE4;
                dreq.strobe = strobe;
                dreq.data = writedata_result;
                mem_unsigned= 0;
            end

            LD:begin
                dataM.pc = dataE.pc;
                dataM.result = dresp.data;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE8;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 0;
            end
            LB:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE1;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 0;
            end
            LH:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE2;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 0;
            end
            LW:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE4;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 0;
            end
            LBU:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE1;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 1;
            end
            LHU:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE2;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 1;
            end
            LWU:begin
                dataM.pc = dataE.pc;
                dataM.result = readdata_result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b1 & ~dataE.is_bubble;
                dreq.addr = dataE.memory_address;
                msize = MSIZE4;
                dreq.strobe = 8'b0000_0000;
                dreq.data = '0;
                mem_unsigned = 1;
            end
            default:begin
                dataM.pc = dataE.pc;
                dataM.result = dataE.result;
                dataM.ctl = dataE.ctl;
                dataM.dst = dataE.dst;
                dataM.memory_address = dataE.memory_address;

                dreq.valid = 1'b0;
                dreq.addr = '0;
                msize = MSIZE8;
                dreq.strobe = '0;
                dreq.data = '0;
                mem_unsigned = 0;

            end
        endcase
    end
endmodule


`endif