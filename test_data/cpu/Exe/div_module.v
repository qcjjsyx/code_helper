`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  div_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/17
// Description: Responsible for calculating signed division, unsigned division, signed remainder, and unsigned remainder.
//======================================================


module div_module(
(* dont_touch="true" *)input  [234:0]   i_divdata_235,
(* dont_touch="true" *)output [245:0]   o_divResult_246
    );

(* dont_touch="true" *)wire        w_Compress_1;
(* dont_touch="true" *)wire [31:0] w_inst_32;
(* dont_touch="true" *)wire [4:0]  w_rd_5; 
(* dont_touch="true" *)wire [63:0] w_rs1Value_64;
(* dont_touch="true" *)wire [63:0] w_rs2Value_64;
(* dont_touch="true" *)wire [63:0] w_PC_64;
(* dont_touch="true" *)wire        w_div_1;
(* dont_touch="true" *)wire        w_remainder_1;
(* dont_touch="true" *)wire [1:0]  w_mulDivSign_2;
(* dont_touch="true" *)wire        w_rv64_1;
(* dont_touch="true" *)wire [31:0] w_divResult_32;

(* dont_touch="true" *)wire        w_op1NeedToBeTrans_64;
(* dont_touch="true" *)wire        w_op2NeedToBeTrans_64;		
(* dont_touch="true" *)wire        w_quotientSign_64;	
(* dont_touch="true" *)wire        w_remainderSign_64;
(* dont_touch="true" *)wire        w_quoNeedToBeTrans_64;	
(* dont_touch="true" *)wire        w_remNeedToBeTrans_64;	
(* dont_touch="true" *)wire [31:0] rs1_32;
(* dont_touch="true" *)wire [31:0] rs2_32;
(* dont_touch="true" *)wire        w_op1NeedToBeTrans_32;
(* dont_touch="true" *)wire        w_op2NeedToBeTrans_32;
(* dont_touch="true" *)wire        w_quotientSign_32;
(* dont_touch="true" *)wire        w_remainderSign_32;
(* dont_touch="true" *)wire        w_quoNeedToBeTrans_32;
(* dont_touch="true" *)wire        w_remNeedToBeTrans_32;
(* dont_touch="true" *)wire [63:0] w_unsignedOperand1_64;
(* dont_touch="true" *)wire [63:0] w_unsignedOperand2_64;
(* dont_touch="true" *)wire [31:0] w_unsignedOperand1_32;
(* dont_touch="true" *)wire [31:0] w_unsignedOperand2_32;
(* dont_touch="true" *)wire [63:0] w_tempQuotient_64;
(* dont_touch="true" *)wire [63:0] w_tempRemainder_64;
(* dont_touch="true" *)wire [31:0] w_tempQuotient_32;
(* dont_touch="true" *)wire [31:0] w_tempRemainder_32;
(* dont_touch="true" *)wire [63:0] w_signedQuotient_64;
(* dont_touch="true" *)wire [63:0] w_signedRemainder_64;
(* dont_touch="true" *)wire [63:0] w_signedQuotient_32_sext;
(* dont_touch="true" *)wire [63:0] w_signedQuotient_32_final;
(* dont_touch="true" *)wire [63:0] w_signedRemainder_32_sext;
(* dont_touch="true" *)wire [63:0] w_signedRemainder_32_final;
(* dont_touch="true" *)wire [63:0] w_quotient_64;
(* dont_touch="true" *)wire [63:0] w_remainder_64;
(* dont_touch="true" *)wire [63:0] w_quotient_32;
(* dont_touch="true" *)wire [63:0] w_remainder_32;

(* dont_touch="true" *)wire [63:0] w_divResult_64;

(* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_div_1, w_remainder_1, w_mulDivSign_2, w_rv64_1} = i_divdata_235;

//////////////////////////////////////////////////////////////////////////////////////////////
// -------- 1️⃣ 符号判断 --------
(* dont_touch="true" *)assign w_op1NeedToBeTrans_64 = w_mulDivSign_2[0] & w_rs1Value_64[63];
(* dont_touch="true" *)assign w_op2NeedToBeTrans_64 = w_mulDivSign_2[0] & w_rs2Value_64[63];

(* dont_touch="true" *)assign w_quotientSign_64  = w_rs1Value_64[63] ^ w_rs2Value_64[63];
(* dont_touch="true" *)assign w_remainderSign_64 = w_rs1Value_64[63];

(* dont_touch="true" *)assign w_quoNeedToBeTrans_64 = w_mulDivSign_2[0] & w_quotientSign_64;
(* dont_touch="true" *)assign w_remNeedToBeTrans_64 = w_mulDivSign_2[0] & w_remainderSign_64;

// -------- 2️⃣ 操作符号判断 --------
(* dont_touch="true" *)assign rs1_32 = w_rs1Value_64[31:0];
(* dont_touch="true" *)assign rs2_32 = w_rs2Value_64[31:0];

(* dont_touch="true" *)assign w_op1NeedToBeTrans_32 = w_mulDivSign_2[0] & rs1_32[31];
(* dont_touch="true" *)assign w_op2NeedToBeTrans_32 = w_mulDivSign_2[0] & rs2_32[31];

(* dont_touch="true" *)assign w_quotientSign_32  = rs1_32[31] ^ rs2_32[31];
(* dont_touch="true" *)assign w_remainderSign_32 = rs1_32[31];

(* dont_touch="true" *)assign w_quoNeedToBeTrans_32 = w_mulDivSign_2[0] & w_quotientSign_32;
(* dont_touch="true" *)assign w_remNeedToBeTrans_32 = w_mulDivSign_2[0] & w_remainderSign_32;

// -------- 3️⃣ 取绝对值 --------
(* dont_touch="true" *)assign w_unsignedOperand1_64 =
       ({64{~w_op1NeedToBeTrans_64}} & w_rs1Value_64) |
       ({64{ w_op1NeedToBeTrans_64}} & (~w_rs1Value_64 + 1'b1));

(* dont_touch="true" *)assign w_unsignedOperand2_64 =
       ({64{~w_op2NeedToBeTrans_64}} & w_rs2Value_64) |
       ({64{ w_op2NeedToBeTrans_64}} & (~w_rs2Value_64 + 1'b1));

(* dont_touch="true" *)assign w_unsignedOperand1_32 =
       ({32{~w_op1NeedToBeTrans_32}} & rs1_32) |
       ({32{ w_op1NeedToBeTrans_32}} & (~rs1_32 + 1'b1));

(* dont_touch="true" *)assign w_unsignedOperand2_32 =
       ({32{~w_op2NeedToBeTrans_32}} & rs2_32) |
       ({32{ w_op2NeedToBeTrans_32}} & (~rs2_32 + 1'b1));

// -------- 4️⃣ 无符号除法 --------
(* dont_touch="true" *)assign w_tempQuotient_64  = $unsigned(w_unsignedOperand1_64) / $unsigned(w_unsignedOperand2_64);
(* dont_touch="true" *)assign w_tempRemainder_64 = $unsigned(w_unsignedOperand1_64) % $unsigned(w_unsignedOperand2_64);

(* dont_touch="true" *)assign w_tempQuotient_32  = $unsigned(w_unsignedOperand1_32) / $unsigned(w_unsignedOperand2_32);
(* dont_touch="true" *)assign w_tempRemainder_32 = $unsigned(w_unsignedOperand1_32) % $unsigned(w_unsignedOperand2_32);

// -------- 5️⃣ 符号修正 --------
(* dont_touch="true" *)assign w_signedQuotient_64 =
       ({64{~w_quoNeedToBeTrans_64}} & w_tempQuotient_64) |
       ({64{ w_quoNeedToBeTrans_64}} & (~w_tempQuotient_64 + 1'b1));

(* dont_touch="true" *)assign w_signedRemainder_64 =
       ({64{~w_remNeedToBeTrans_64}} & w_tempRemainder_64) |
       ({64{ w_remNeedToBeTrans_64}} & (~w_tempRemainder_64 + 1'b1));

(* dont_touch="true" *)assign w_signedQuotient_32_sext = {{32{~w_quoNeedToBeTrans_32}}, w_tempQuotient_32};
(* dont_touch="true" *)assign w_signedQuotient_32_final  =
       ({64{~w_quoNeedToBeTrans_32}} & {{32{w_tempQuotient_32[31]}}, w_tempQuotient_32}) |
       ({64{ w_quoNeedToBeTrans_32}} & {{32{~w_tempQuotient_32[31]}}, (~w_tempQuotient_32 + 1'b1)});

(* dont_touch="true" *)assign w_signedRemainder_32_sext = {{32{~w_remNeedToBeTrans_32}}, w_tempRemainder_32};
(* dont_touch="true" *)assign w_signedRemainder_32_final  =
       ({64{~w_remNeedToBeTrans_32}} & {{32{w_tempRemainder_32[31]}}, w_tempRemainder_32}) |
       ({64{ w_remNeedToBeTrans_32}} & {{32{~w_tempRemainder_32[31]}}, (~w_tempRemainder_32 + 1'b1)});

// -------- 6️⃣ 除以0特判 --------
(* dont_touch="true" *)assign w_quotient_64 =
       ({64{~|w_rs2Value_64}} & 64'hFFFF_FFFF_FFFF_FFFF) |
       ({64{|w_rs2Value_64}} & w_signedQuotient_64);

(* dont_touch="true" *)assign w_remainder_64 =
       ({64{~|w_rs2Value_64}} & w_rs1Value_64) |
       ({64{|w_rs2Value_64}} & w_signedRemainder_64);

(* dont_touch="true" *)assign w_quotient_32 =
       ({64{~|rs2_32}} & 64'hFFFF_FFFF_FFFF_FFFF) |
       ({64{|rs2_32}} & w_signedQuotient_32_final);

(* dont_touch="true" *)assign w_remainder_32 =
       ({64{~|rs2_32}} & {{32{1'b0}}, rs1_32}) |
       ({64{|rs2_32}} & w_signedRemainder_32_final);

// -------- 7️⃣ 输出选择 --------
(* dont_touch="true" *)assign w_divResult_64 =
       (w_rv64_1 == 1'b0) ? ((w_remainder_1==1'b0)? w_quotient_64 : w_remainder_64) :
       (w_rv64_1 == 1'b1) ? ((w_remainder_1==1'b0)? {{32{w_quotient_32[31]}}, w_quotient_32} : {{32{w_remainder_32[31]}}, w_remainder_32}) :
       64'b0;

/////////////////////////////////////////////////////////////////////////////////////////////
(* dont_touch="true" *)assign o_divResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0000, w_rd_5, 12'b0, 64'b0, w_divResult_64};

endmodule
