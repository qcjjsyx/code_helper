`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  csr_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/5/28
// Description: Responsible for the calculation of three CSR instructions: direct write, reset and set.
//======================================================


module csr_module(
(* dont_touch="true" *)input  [246:0]   i_csrdata_247,
(* dont_touch="true" *)output [245:0]   o_csrResult_246
    );

(* dont_touch="true" *)wire        w_Compress_1;
(* dont_touch="true" *)wire [31:0] w_inst_32; 
(* dont_touch="true" *)wire [4:0]  w_rd_5;
(* dont_touch="true" *)wire [63:0] w_rs1Value_64;
(* dont_touch="true" *)wire [63:0] w_rs2Value_64;
(* dont_touch="true" *)wire [63:0] w_PC_64;
(* dont_touch="true" *)wire        w_rv64_1;
(* dont_touch="true" *)wire        w_CsrType_1;
(* dont_touch="true" *)wire [2:0]  w_CsrCsw_3;
(* dont_touch="true" *)wire [11:0] w_rs2Csr_12;

(* dont_touch="true" *)wire        w_Clear;
(* dont_touch="true" *)wire        w_Set;
(* dont_touch="true" *)wire        w_Write;
(* dont_touch="true" *)wire [63:0] w_resultRd_64;
(* dont_touch="true" *)wire [63:0] w_resultCsr_64;

(* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_rv64_1, w_CsrType_1, w_CsrCsw_3, w_rs2Csr_12} = i_csrdata_247;

 
(* dont_touch="true" *)assign w_Clear = w_CsrCsw_3[2];
(* dont_touch="true" *)assign w_Set = w_CsrCsw_3[1];
(* dont_touch="true" *)assign w_Write = w_CsrCsw_3[0];

(* dont_touch="true" *)assign w_resultRd_64 = w_rs2Value_64;
(* dont_touch="true" *)assign w_resultCsr_64 = ({64{w_Clear}} & (w_rs2Value_64 & ~w_rs1Value_64)) |
                        ({64{w_Set}} & (w_rs2Value_64 | w_rs1Value_64)) |
                        ({64{w_Write}} & w_rs1Value_64);

(* dont_touch="true" *)assign o_csrResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0001, w_rd_5, w_rs2Csr_12, w_resultCsr_64, w_resultRd_64};

endmodule
