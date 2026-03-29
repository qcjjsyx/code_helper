`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  agu_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/17
// Description: Used to calculate the target address for LOAD and STORE memory access instructions.
//======================================================


module agu_module(
(* dont_touch="true" *)input  [299:0]   i_agudata_300,
(* dont_touch="true" *)output [245:0]   o_aguResult_246
    );

(* dont_touch="true" *)wire        w_Compress_1;
(* dont_touch="true" *)wire [31:0] w_inst_32;
(* dont_touch="true" *)wire [4:0]  w_exceptionInfo_5;
(* dont_touch="true" *)wire [4:0]  w_rd_5;
(* dont_touch="true" *)wire [63:0] w_rs1Value_64; 
(* dont_touch="true" *)wire [63:0] w_rs2Value_64;
(* dont_touch="true" *)wire [63:0] w_PC_64;
(* dont_touch="true" *)wire [63:0] w_imm_64;
(* dont_touch="true" *)wire        w_rv64_1;
(* dont_touch="true" *)wire        w_store_1;
(* dont_touch="true" *)wire        w_load_1; 
(* dont_touch="true" *)wire        w_loadSign_1; 
(* dont_touch="true" *)wire [1:0]  w_loadStoreWidth_2;

(* dont_touch="true" *)wire [63:0] w_aguResult_64;


(* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_imm_64, w_rv64_1, w_store_1, w_load_1, w_loadSign_1, w_loadStoreWidth_2} = i_agudata_300;

(* dont_touch="true" *)assign w_aguResult_64 = w_rs1Value_64 + w_imm_64;
(* dont_touch="true" *)assign o_aguResult_246 = w_store_1 ?({w_PC_64, w_Compress_1, w_inst_32, 4'b0010, w_rd_5, 9'b0,w_loadSign_1,w_loadStoreWidth_2, w_aguResult_64, w_rs2Value_64}):({w_PC_64, w_Compress_1, w_inst_32, 4'b0011, w_rd_5, 9'b0,w_loadSign_1,w_loadStoreWidth_2, w_aguResult_64, w_rs2Value_64});


endmodule
