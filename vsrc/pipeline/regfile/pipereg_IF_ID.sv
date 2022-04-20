`ifndef __PIPEREG_IF_ID_SV
`define __PIPEREG_IF_ID_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module pipereg_IF_ID
    import common::*;
    import pipes::*;(
        input logic clk, reset,
        input reset_t reset_IF_ID,
        input fetch_data_t dataF_in,
        output fetch_data_t dataF_out
);
    logic my_reset;
    always_comb begin
        unique case(reset_IF_ID)
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
        if(my_reset || reset) begin    
            dataF_out.raw_instr <= '0;
            dataF_out.pc <= 64'h8000_0000;
            dataF_out.is_bubble <= 1'b1;
        end
        else begin
            dataF_out <= dataF_in;
        end
     end
    
endmodule


`endif