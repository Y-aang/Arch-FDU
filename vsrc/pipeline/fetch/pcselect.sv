`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pcselect
    import common::*;
    import pipes::*;(
        
    input u64 pc,
    input u64 stall_pc,
    input instfunc_t op,
    input u64 offset,
    output u64 pc_selected
);
    always_comb begin
        unique case ( op )
            BEQ_P:begin
                pc_selected = stall_pc + offset;
            end
            BEQ_N:begin
                pc_selected = stall_pc + 4;
            end
            PLUS4:begin
                pc_selected = pc + 4;
            end
            MAINTAIN:begin
                pc_selected = pc;
            end
            JAL_P:begin
                pc_selected = stall_pc + offset;
            end
            JALR_P:begin
                pc_selected = offset;
            end
            default: begin
                pc_selected = pc + 4; 
            end
        endcase
    end
    
    
endmodule


`endif