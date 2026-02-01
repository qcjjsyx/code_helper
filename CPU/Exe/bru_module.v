`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  bru_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/5/28
// Description: It is used to determine whether the conditional jump instruction meets the jump condition, and check whether the jump target address is consistent with the branch prediction result. It is also responsible for calculating the actual jump address of the instruction.
//======================================================


module bru_module(
(* dont_touch="true" *)input  [302:0]   i_brudata_303,
(* dont_touch="true" *)output [245:0]   o_bruResult_246
    );

(* dont_touch="true" *)wire        w_Compress_1;
(* dont_touch="true" *)wire [31:0] w_inst_32;
(* dont_touch="true" *)wire [4:0]  w_rd_5; 
(* dont_touch="true" *)wire [63:0] w_rs1Value_64;
(* dont_touch="true" *)wire [63:0] w_rs2Value_64;
(* dont_touch="true" *)wire [63:0] w_PC_64; 
(* dont_touch="true" *)wire [63:0] w_imm_64;
(* dont_touch="true" *)wire        w_rv64_1;
(* dont_touch="true" *)wire        w_Jal_1;
(* dont_touch="true" *)wire        w_Jalr_1; 
(* dont_touch="true" *)wire        w_BType_1; 
(* dont_touch="true" *)wire [3:0]  w_BTypeCon_4; 
(* dont_touch="true" *)wire        w_branchSign_1; 

(* dont_touch="true" *)wire [63:0] w_Jalresult_64;
(* dont_touch="true" *)wire [63:0] w_Jalpc_64;
(* dont_touch="true" *)wire [63:0] w_Jalrresult_64;
(* dont_touch="true" *)wire [63:0] w_Jalrpc_64;
(* dont_touch="true" *)wire        w_beq;
(* dont_touch="true" *)wire        w_bne;
(* dont_touch="true" *)wire        w_bl;
(* dont_touch="true" *)wire        w_bge;
(* dont_touch="true" *)wire        w_bJump;
(* dont_touch="true" *)wire [63:0] w_pcresult_64;
(* dont_touch="true" *)wire [63:0] w_resultvalue_64;
(* dont_touch="true" *)wire        w_JalrRight_1;

(* dont_touch="true" *)wire [245:0]w_jalResult_246;
(* dont_touch="true" *)wire [245:0]w_jalrResult_246;
(* dont_touch="true" *)wire [245:0]w_bResult_246;

(* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_imm_64, w_rv64_1, w_Jal_1, w_Jalr_1, w_BType_1, w_BTypeCon_4, w_branchSign_1} = i_brudata_303;

//JAL
(* dont_touch="true" *)assign w_Jalresult_64 = w_Compress_1? (w_PC_64 + 2) : (w_PC_64 + 4); //pc+4or2
(* dont_touch="true" *)assign w_Jalpc_64 = w_PC_64 + w_imm_64; //pc+imm
//JALR
(* dont_touch="true" *)assign w_Jalrresult_64 = w_Compress_1? (w_PC_64 + 2) : (w_PC_64 + 4); //pc+4
(* dont_touch="true" *)assign w_Jalrpc_64 = w_rs1Value_64 + w_imm_64; //op1+imm
(* dont_touch="true" *)assign w_JalrRight_1 = (w_Jalrresult_64 == w_Jalrpc_64);
//BRANCH
(* dont_touch="true" *)assign w_beq = (w_rs1Value_64 == w_rs2Value_64);
(* dont_touch="true" *)assign w_bne = (w_rs1Value_64 != w_rs2Value_64);
(* dont_touch="true" *)assign w_bl = w_BType_1 & (w_branchSign_1 & ((w_rs1Value_64[63] ^ w_rs2Value_64[63]) & w_rs1Value_64[63] |
                           ~(w_rs1Value_64[63] ^ w_rs2Value_64[63]) & (w_rs1Value_64[62:0] < w_rs2Value_64[62:0])) |
             ~w_branchSign_1 & (w_rs1Value_64 < w_rs2Value_64));
(* dont_touch="true" *)assign w_bge = w_BType_1 & ~(w_branchSign_1 & ((w_rs1Value_64[63] ^ w_rs2Value_64[63]) & w_rs1Value_64[63] |
                           ~(w_rs1Value_64[63] ^ w_rs2Value_64[63]) & (w_rs1Value_64[62:0] < w_rs2Value_64[62:0])) |
             ~w_branchSign_1 & (w_rs1Value_64 < w_rs2Value_64));          
(* dont_touch="true" *)assign w_bJump = (w_BTypeCon_4[3] & w_beq) |
                 (w_BTypeCon_4[2] & w_bne) |
                 (w_BTypeCon_4[1] & w_bge) |
                 (w_BTypeCon_4[0] & w_bl);
(* dont_touch="true" *)assign w_pcresult_64 = w_bJump ? (w_PC_64 + w_imm_64) : (w_Compress_1 ? (w_PC_64 + 2) : (w_PC_64 + 4));
(* dont_touch="true" *)assign w_resultvalue_64 = w_Compress_1 ? (w_PC_64 + 2) : (w_PC_64 + 4);


(* dont_touch="true" *)assign w_jalResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0101, w_rd_5, 12'b0, w_Jalpc_64, w_Jalresult_64};
(* dont_touch="true" *)assign w_jalrResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0110, w_rd_5, w_JalrRight_1,11'b0, w_Jalrpc_64, w_Jalrresult_64};
(* dont_touch="true" *)assign w_bResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0100, w_rd_5, 12'b0, w_pcresult_64, w_resultvalue_64};
(* dont_touch="true" *)assign o_bruResult_246 = (w_jalResult_246 & {246{w_Jal_1}})|
                         (w_jalrResult_246 & {246{w_Jalr_1}})|
                         (w_bResult_246 & {246{w_BType_1}});


endmodule
