`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module decoder
    import common::*;
    import pipes::*;(
    input u32 raw_instr,
    output control_t ctl
);
    wire [6:0] f7 = raw_instr[6:0];
    wire [2:0] f3 = raw_instr[14:12];
    always_comb begin
        ctl = '0;
        unique case(f7)
            F7_ADDI:begin
                unique case(f3)
                    F3_ADDI:begin
                        ctl.op = ADDI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_ADD;
                    end
                    default:begin
                        
                    end
                endcase
            end
            
            default:begin
                
            end
        endcase
    end
    
endmodule



`endif