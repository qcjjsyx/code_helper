`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  mul_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/17
// Description: Responsible for calculating signed multiplication, unsigned multiplication, and signed and unsigned multiplication.
//======================================================


module mul_module(
(* dont_touch="true" *)input  [234:0]  i_muldata_235,
(* dont_touch="true" *)output [245:0]  o_mulResult_246
    );

    (* dont_touch="true" *)reg  [63:0] r_operand1tf_64;
    (* dont_touch="true" *)wire [127:0] w_mulResult_128;
    (* dont_touch="true" *)reg  [127:0] temp;

    (* dont_touch="true" *)wire        w_rv64_1;
    (* dont_touch="true" *)wire [31:0] w_inst_32;
    (* dont_touch="true" *)wire [4:0]  w_rd_5; 
    (* dont_touch="true" *)wire [63:0] w_rs1Value_64;
    (* dont_touch="true" *)wire [63:0] w_rs2Value_64;
    (* dont_touch="true" *)wire [63:0] w_PC_64;
    (* dont_touch="true" *)wire        w_mul_1;
    (* dont_touch="true" *)wire        w_mulLowHigh_1;
    (* dont_touch="true" *)wire [1:0]  w_mulDivSign_2;
    (* dont_touch="true" *)wire [63:0] w_mulResult1_64;
    (* dont_touch="true" *)wire [63:0] w_mulResult2_64;
    (* dont_touch="true" *)wire [63:0] w_mulResult_64;
    (* dont_touch="true" *)wire [31:0] w_mulResult_32;

    (* dont_touch="true" *)assign {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_mul_1, w_mulLowHigh_1, w_mulDivSign_2, w_rv64_1} = i_muldata_235;
  
    always @(*) begin
        if(w_mulDivSign_2 == 2'b11) begin
            temp = $signed(w_rs1Value_64) * $signed(w_rs2Value_64);
        end else if(w_mulDivSign_2 == 2'b00) begin
            temp = $unsigned(w_rs1Value_64) * $unsigned(w_rs2Value_64);
        end else begin
            if(w_rs1Value_64[63] == 1'b1 )
                 begin
                      r_operand1tf_64 = ~(w_rs1Value_64-1'b1);
                      temp = ~(r_operand1tf_64*$unsigned(w_rs2Value_64))+1'b1;
                 end else
                      temp = (($unsigned(w_rs1Value_64) * $unsigned(w_rs2Value_64))); 
        end
    end

(* dont_touch="true" *)assign w_mulResult_128 = temp;

(* dont_touch="true" *)assign w_mulResult1_64 = (w_mulLowHigh_1 == 1'b0) ? w_mulResult_128[127:64] :
                        (w_mulLowHigh_1 == 1'b1) ? w_mulResult_128[63:0] : 64'b0;
(* dont_touch="true" *)assign w_mulResult_32 = w_mulResult_128[31:0];
(* dont_touch="true" *)assign w_mulResult2_64 = {{32{w_mulResult_32[31]}}, w_mulResult_32};
(* dont_touch="true" *)assign w_mulResult_64  =  w_rv64_1 ? w_mulResult2_64 : w_mulResult1_64;

(* dont_touch="true" *)assign o_mulResult_246 = {w_PC_64, w_Compress_1, w_inst_32, 4'b0000, w_rd_5, 12'b0, 64'b0, w_mulResult_64};



endmodule
