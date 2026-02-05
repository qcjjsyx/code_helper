`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  alu_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/17
// Description: The result calculation of arithmetic instructions, numerical comparison instructions, logical instructions and shift instructions.
//======================================================


module alu_module(
(* dont_touch="true" *)input  [306:0]   i_aludata_307,     //{w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_rv64_1, w_aluControl_12}
(* dont_touch="true" *)output [245:0]    o_aluResult_246      // result
    );

//-----{aluControl解码}begin
    (* dont_touch="true" *)wire w_auipc_1;                             // 加法操作
    (* dont_touch="true" *)wire w_add_1;                               // 加法操作
    (* dont_touch="true" *)wire w_sub_1;                               // 减法操作
    (* dont_touch="true" *)wire w_slt_1;                               // 小于置位操作
    (* dont_touch="true" *)wire w_sltu_1;                              // 无符号小于置位操作
    (* dont_touch="true" *)wire w_and_1;                               // 与操作
    (* dont_touch="true" *)wire w_or_1;                                // 或操作
    (* dont_touch="true" *)wire w_xor_1;                               // 异或操作
    (* dont_touch="true" *)wire w_sll_1;                               // 逻辑左移操作
    (* dont_touch="true" *)wire w_srl_1;                               // 逻辑右移操作
    (* dont_touch="true" *)wire w_sra_1;                               // 算术右移操作
    (* dont_touch="true" *)wire w_lui_1;                               // 高位加载操作

    (* dont_touch="true" *)wire [63:0] w_auipcResult_64; 
    (* dont_touch="true" *)wire [63:0] w_addSubResult1_64;
    (* dont_touch="true" *)wire [63:0] w_addSubResult2_64;
    (* dont_touch="true" *)wire [63:0] w_addSubResult_64; 
    (* dont_touch="true" *)wire [63:0] w_sltResult_64;
    (* dont_touch="true" *)wire [63:0] w_sltuResult_64;
    (* dont_touch="true" *)wire [63:0] w_andResult_64;
    (* dont_touch="true" *)wire [63:0] w_orResult_64;
    (* dont_touch="true" *)wire [63:0] w_xorResult_64;
    (* dont_touch="true" *)wire [63:0] w_sllResult_64;
    (* dont_touch="true" *)wire [63:0] w_srlResult_64;
    (* dont_touch="true" *)wire [63:0] w_sraResult_64;
    (* dont_touch="true" *)wire [63:0] w_luiResult_64;

    (* dont_touch="true" *)wire        w_Compress_1;
    (* dont_touch="true" *)wire [31:0] w_inst_32;
    (* dont_touch="true" *)wire [4:0]  w_rd_5;
    (* dont_touch="true" *)wire [63:0] w_rs1Value_64;
    (* dont_touch="true" *)wire [63:0] w_rs2Value_64;
    (* dont_touch="true" *)wire [63:0] w_PC_64;
    (* dont_touch="true" *)wire [63:0] w_imm_64;
    (* dont_touch="true" *)wire        w_rv64_1;
    (* dont_touch="true" *)wire [11:0] w_aluControl_12;
    (* dont_touch="true" *)wire        w_sign1;
    (* dont_touch="true" *)wire        w_sign2;
    (* dont_touch="true" *)wire [31:0] w_auipcop1_32;
    (* dont_touch="true" *)wire [63:0] w_auipcop1_64;
    (* dont_touch="true" *)wire [63:0] w_aluResult_64;
    (* dont_touch="true" *)wire           rdExist_1;

    (* dont_touch="true" *)wire [63:0]w_sllResult1_64;
    (* dont_touch="true" *)wire [31:0] w_slllow_32;
    (* dont_touch="true" *)wire [31:0] w_shifted_32;
    (* dont_touch="true" *)wire [63:0] w_sllResult2_64;
    (* dont_touch="true" *)wire [63:0] w_srlResult1_64;
    (* dont_touch="true" *)wire [31:0] w_srllow_32;
    (* dont_touch="true" *)wire [31:0] w_righted_32;
    (* dont_touch="true" *)wire [63:0] w_srlResult2_64;
    (* dont_touch="true" *)wire [31:0] w_sralow_32;
    (* dont_touch="true" *)wire [31:0] w_sraw_32;
    (* dont_touch="true" *)wire [63:0] w_sraResult1_64;
    (* dont_touch="true" *)wire [63:0] w_sraResult2_64;

    (* dont_touch="true" *)assign w_auipc_1 = i_aludata_307[0];
    (* dont_touch="true" *)assign w_add_1   = i_aludata_307[1];
    (* dont_touch="true" *)assign w_sub_1   = i_aludata_307[2];
    (* dont_touch="true" *)assign w_slt_1   = i_aludata_307[3];
    (* dont_touch="true" *)assign w_sltu_1  = i_aludata_307[4];
    (* dont_touch="true" *)assign w_and_1   = i_aludata_307[5];
    (* dont_touch="true" *)assign w_or_1    = i_aludata_307[6];
    (* dont_touch="true" *)assign w_xor_1   = i_aludata_307[7];
    (* dont_touch="true" *)assign w_sll_1   = i_aludata_307[8];
    (* dont_touch="true" *)assign w_srl_1   = i_aludata_307[9];
    (* dont_touch="true" *)assign w_sra_1   = i_aludata_307[10];
    (* dont_touch="true" *)assign w_lui_1   = i_aludata_307[11];

    (* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_imm_64, w_rv64_1, w_aluControl_12} = i_aludata_307;
//-----{aluControl解码}end


    (* dont_touch="true" *)assign w_andResult_64   =  w_rs1Value_64 &  w_rs2Value_64;          // and
    (* dont_touch="true" *)assign w_orResult_64    =  w_rs1Value_64 |  w_rs2Value_64;          // or
    (* dont_touch="true" *)assign w_xorResult_64   =  w_rs1Value_64 ^  w_rs2Value_64;          // xor
    (* dont_touch="true" *)assign w_luiResult_64   =  w_rs2Value_64;                          // lui

   
    (* dont_touch="true" *)assign  w_addSubResult1_64  =   w_rs1Value_64 + (w_sub_1 ?          //add sub
                        (~ w_rs2Value_64 + 1'b1) : ( w_rs2Value_64));
    (* dont_touch="true" *)assign  w_addSubResult2_64  =   {{32{w_addSubResult1_64[31]}}, w_addSubResult1_64[31:0]};  //{{32{data_32[31]}}, data_32} addiw addw subw
    (* dont_touch="true" *)assign  w_addSubResult_64   =   w_rv64_1? w_addSubResult2_64 : w_addSubResult1_64;
                                  //(w_addSubResult1_64 & (~ w_rv64_1)) | (w_addSubResult2_64 & w_rv64_1);

    (* dont_touch="true" *)assign  w_sign1  =   w_rs1Value_64[63];                            //slt
    (* dont_touch="true" *)assign  w_sign2  =   w_rs2Value_64[63];
    (* dont_touch="true" *)assign  w_sltResult_64[63:1]  =  63'b0;
    (* dont_touch="true" *)assign  w_sltResult_64[0]  =  (w_sign1 ^ w_sign2) & w_sign1 |
                           ~(w_sign1 ^ w_sign2) & ( w_rs1Value_64[62:0] <  w_rs2Value_64[62:0]);
    (* dont_touch="true" *)assign  w_sltuResult_64[63:1]  =  w_sltResult_64[63:1];          //sltu
    (* dont_touch="true" *)assign  w_sltuResult_64[0]  =   w_rs1Value_64 <  w_rs2Value_64;


    (* dont_touch="true" *)assign w_sllResult1_64 =($unsigned( w_rs1Value_64)) <<  w_rs2Value_64[5:0];  //sll
    (* dont_touch="true" *)assign w_slllow_32 = w_rs1Value_64[31:0];                                    //sllw slliw
    (* dont_touch="true" *)assign w_shifted_32 = w_slllow_32 << w_rs2Value_64[4:0];
    (* dont_touch="true" *)assign w_sllResult2_64 = {{32{w_shifted_32[31]}}, w_shifted_32};
    (* dont_touch="true" *)assign w_sllResult_64 = w_rv64_1? w_sllResult2_64 : w_sllResult1_64;

    (* dont_touch="true" *)assign w_srlResult1_64 =($unsigned( w_rs1Value_64)) >>  w_rs2Value_64[5:0];  //srl
    (* dont_touch="true" *)assign w_srllow_32 = w_rs1Value_64[31:0];                                    //srlw srliw
    (* dont_touch="true" *)assign w_righted_32 = w_srllow_32 >> w_rs2Value_64[4:0];
    (* dont_touch="true" *)assign w_srlResult2_64 = {{32{w_righted_32[31]}}, w_righted_32};
    (* dont_touch="true" *)assign w_srlResult_64 = w_rv64_1? w_srlResult2_64 : w_srlResult1_64;

    (* dont_touch="true" *)assign w_sraResult1_64 =(($signed( w_rs1Value_64)) >>>  w_rs2Value_64[5:0]); //sra
    (* dont_touch="true" *)assign w_sralow_32 = w_rs1Value_64[31:0];                                    //sraw
    (* dont_touch="true" *)assign w_sraw_32 = ($signed(w_sralow_32)) >>> w_rs2Value_64[4:0];
    (* dont_touch="true" *)assign w_sraResult2_64 = {{32{w_sraw_32[31]}}, w_sraw_32};
    (* dont_touch="true" *)assign w_sraResult_64 = w_rv64_1? w_sraResult2_64 : w_sraResult1_64;

 
    //(* dont_touch="true" *)assign w_auipcop1_32 = { w_rs2Value_64[31:12], 12'b0};
    //(* dont_touch="true" *)assign w_auipcop1_64 = {{32{w_auipcop1_32[31]}}, w_auipcop1_32};
    (* dont_touch="true" *)assign w_auipcResult_64 = w_imm_64 + w_PC_64;

     (* dont_touch="true" *)assign w_aluResult_64   = {{64{w_add_1 | w_sub_1}}  & w_addSubResult_64 }   
                            | {{64{w_slt_1          }}  & w_sltResult_64    }   
                            | {{64{w_sltu_1         }}  & w_sltuResult_64   }   
                            | {{64{w_and_1          }}  & w_andResult_64    }   
                            | {{64{w_or_1           }}  & w_orResult_64     }   
                            | {{64{w_xor_1          }}  & w_xorResult_64    }   
                            | {{64{w_sll_1          }}  & w_sllResult_64    }   
                            | {{64{w_srl_1          }}  & w_srlResult_64    }   
                            | {{64{w_sra_1          }}  & w_sraResult_64    }   
                            | {{64{w_lui_1          }}  & w_luiResult_64    }
                            | {{64{w_auipc_1          }}  & w_auipcResult_64    };

    //(* dont_touch="true" *)assign o_aluResult_122 = {rdExist_1, w_inst_32, w_exceptionInfo_5, 3'b000, w_rd_5, 12'b0, 32'b0, w_aluResult_64};
    (* dont_touch="true" *)assign o_aluResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0000, w_rd_5, 12'b0, 64'b0, w_aluResult_64};


endmodule
