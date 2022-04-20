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
    wire [6:0] f7_1 = raw_instr[31:25];
    wire [2:0] f3 = raw_instr[14:12];
    wire [6:0] f6 = raw_instr[31:25];
    always_comb begin
        ctl = '0;
        unique case(f7)
            F7_ADDI:begin
                unique case(f3)
                    F3_ADDI:begin
                        ctl.op = ADDI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_ADD;
                        ctl.memwrite = 1'b0;
                    end
                    F3_XORI:begin
                        ctl.op = XORI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_XOR;
                        ctl.memwrite = 1'b0;
                    end
                    F3_ORI:begin
                        ctl.op = ORI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_OR;
                        ctl.memwrite = 1'b0;
                    end
                    F3_ANDI:begin
                        ctl.op = ANDI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_AND;
                        ctl.memwrite = 1'b0;
                    end
                    F3_SLTI:begin
                        ctl.op = SLTI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_SSMALL;
                        ctl.memwrite = 1'b0;
                    end
                    F3_SLTIU:begin
                        ctl.op = ALU_USMALL;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_AND;
                        ctl.memwrite = 1'b0;
                    end
                    F3_SLLI:begin
                        ctl.op = SLLI;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_LEFT;
                        ctl.memwrite = 1'b0;
                    end
                    F3_SRLI:begin
                        unique case(f6)
                            F6_SRLI:begin
                                ctl.op = SRLI;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_URIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            F6_SRAI:begin
                                ctl.op = SRAI;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SRIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
                    end
                    default:begin
                        
                    end
                endcase
            end
            F7_LUI:begin
                ctl.op = LUI;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_DIRECT;
                ctl.memwrite = 1'b0;
            end
            F7_JAL:begin
                ctl.op = JAL;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ctl.memwrite = 1'b0;
            end
            F7_BEQ:begin
                unique case(f3)
                    F3_BEQ:begin
                        ctl.op = BEQ;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    F3_BNE:begin
                        ctl.op = BNE;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    F3_BLT:begin
                        ctl.op = BLT;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    F3_BGE:begin
                        ctl.op = BGE;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    F3_BLTU:begin
                        ctl.op = BLTU;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    F3_BGEU:begin
                        ctl.op = BGEU;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b0;
                    end
                    default:begin
                        
                    end
                endcase
            end
            F7_LD:begin
                unique case(f3)
                    F3_LD:begin
                        ctl.op = LD;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_PASS;
                        ctl.memwrite = 1'b1;
                    end
                    default:begin
                        
                    end
                endcase
            end
            F7_SD:begin
                unique case(f3)
                    F3_SD:begin
                        ctl.op = SD;
                        ctl.regwrite = 1'b0;
                        ctl.alufunc = ALU_DIRECT;
                        ctl.memwrite = 1'b1;
                    end
                    default:begin
                        
                    end
                endcase
            end
            F7_ADD:begin
               unique case(f3)
                   F3_ADD:begin
                      unique case(f7_1)
                          F7_1_ADD:begin
                                ctl.op = ADD;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_ADD;
                                ctl.memwrite = 1'b0;
                          end
                          F7_1_SUB:begin
                                ctl.op = SUB;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SUB;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_AND:begin
                      unique case(f7_1)
                          F7_1_AND:begin
                                ctl.op = AND;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_AND;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_OR:begin
                      unique case(f7_1)
                          F7_1_OR:begin
                                ctl.op = OR;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_OR;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_XOR:begin
                      unique case(f7_1)
                          F7_1_XOR:begin
                                ctl.op = XOR;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_XOR;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_SLL:begin
                      unique case(f7_1)
                          F7_1_SLL:begin
                                ctl.op = SLL;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_LEFT;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_SLT:begin
                      unique case(f7_1)
                          F7_1_SLL:begin
                                ctl.op = SLT;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SSMALL;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_SLTU:begin
                      unique case(f7_1)
                          F7_1_SLL:begin
                                ctl.op = SLTU;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_USMALL;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   F3_SRL:begin
                      unique case(f7_1)
                          F7_1_SLL:begin
                                ctl.op = SRL;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_URIGHT;
                                ctl.memwrite = 1'b0;
                          end
                          F7_1_SRA:begin
                                ctl.op = SRA;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SRIGHT;
                                ctl.memwrite = 1'b0;
                          end
                          default:begin
                              
                          end
                      endcase 
                   end
                   default:begin
                       
                   end
               endcase 
            end
            F7_AUIPC:begin
                ctl.op = AUIPC;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ctl.memwrite = 1'b0;
            end
            F7_JALR:begin
                unique case(f3)
                    F3_JALR:begin
                        ctl.op = JALR;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_ADD;
                        ctl.memwrite = 1'b0;
                    end
                    default:begin
                        
                    end
                endcase
            end
            JAL:begin
                ctl.op = JAL;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ctl.memwrite = 1'b0;
            end
            F7_ADDIW:begin
                unique case(f3)
                    F3_ADDIW:begin
                        ctl.op = ADDIW;
                        ctl.regwrite = 1'b1;
                        ctl.alufunc = ALU_ADD;
                        ctl.memwrite = 1'b0;
                    end
                    F3_SLLIW:begin
                        unique case(f6)
                            F6_SLLIW:begin
                                ctl.op = SLLIW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_LEFT;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
                    end
                    F3_SRLIW:begin
                        unique case(f6)
                            F6_SLLIW:begin
                                ctl.op = SRLIW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_URIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            F6_SRAIW:begin
                                ctl.op = SRAIW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SRIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
                    end
                    default:begin
                        
                    end
                endcase
            end
            F7_ADDW:begin
                unique case(f3)
                    F3_ADDW:begin
                        unique case(f7_1)
                            F7_1_ADDW:begin
                                ctl.op = ADDW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_ADD;
                                ctl.memwrite = 1'b0;
                            end
                            F7_1_SUBW:begin
                                ctl.op = SUBW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SUB;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
                    end
                    F3_SLLW:begin
                        unique case(f7_1)
                            F7_1_SLLW:begin
                                ctl.op = SLLW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_LEFT;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
                    end
                    F3_SRLW:begin
                        unique case(f7_1)
                            F7_1_SRLW:begin
                                ctl.op = SRLW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_URIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            F7_1_SRAW:begin
                                ctl.op = SRAW;
                                ctl.regwrite = 1'b1;
                                ctl.alufunc = ALU_SRIGHT;
                                ctl.memwrite = 1'b0;
                            end
                            default:begin
                                
                            end
                        endcase
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