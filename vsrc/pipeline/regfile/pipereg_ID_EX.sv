`ifndef __PIPEREG_ID_EX_SV
`define __PIPEREG_ID_EX_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pipereg_ID_EX
    import common::*;
    import pipes::*;(
        input logic clk, reset,
        input reset_t reset_ID_EX,
        input decode_data_t dataD_in,
        output decode_data_t dataD_out,

        input decode_data_t last_dataD,
        // output decode_data_t copy_dataD,

        input logic Iwait,
        input logic Dwait,
        input u1 exe_is_waiting
);
    logic my_reset;
    always_comb begin
        my_reset = '0;
        unique case(reset_ID_EX)
            RESET_CONTINUE:begin
                my_reset =  1'b0;
            end
            RESET_RESET:begin
                my_reset =  1'b1;
            end
            default:begin
                
            end
        endcase 
    end


    always_ff @ (posedge clk)
    begin
        // copy_dataD <= dataD_in;
        if(Dwait == 1 || exe_is_waiting == 1 ) begin
            dataD_out <= last_dataD;
        end
        else if(my_reset|| reset) begin    
            dataD_out.srca <= '0;
            dataD_out.srcb <= '0;
            dataD_out.immediate <= '0;
            dataD_out.ctl.op <= UNKNOWN;
            dataD_out.ctl.alufunc <= ALU_UNKNOWN;
            dataD_out.ctl.regwrite <= '0;
            dataD_out.dst <= '0;
            dataD_out.pc <= 64'h8000_0000;
            dataD_out.is_bubble <= 1'b1;
            dataD_out.shamt <= '0;
            dataD_out.csr <= '0;
            dataD_out.csr_reg_write <= '0;
        end
        else begin
            dataD_out <= dataD_in;
        end
     end
    
endmodule


`endif