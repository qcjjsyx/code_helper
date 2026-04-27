`timescale 1ns / 1ps
module reverse (
        oprand,reverseType,result,rst
);
    input [31:0] oprand;
    input [1:0] reverseType;
    output [31:0] result;
    input rst;

wire [31:0] w_rbitResult_32;
//RBIT
assign w_rbitResult_32[31] = oprand[0];
assign w_rbitResult_32[30] = oprand[1];
assign w_rbitResult_32[29] = oprand[2];
assign w_rbitResult_32[28] = oprand[3];
assign w_rbitResult_32[27] = oprand[4];
assign w_rbitResult_32[26] = oprand[5];
assign w_rbitResult_32[25] = oprand[6];
assign w_rbitResult_32[24] = oprand[7];
assign w_rbitResult_32[23] = oprand[8];
assign w_rbitResult_32[22] = oprand[9];
assign w_rbitResult_32[21] = oprand[10];
assign w_rbitResult_32[20] = oprand[11];
assign w_rbitResult_32[19] = oprand[12];
assign w_rbitResult_32[18] = oprand[13];
assign w_rbitResult_32[17] = oprand[14];
assign w_rbitResult_32[16] = oprand[15];
assign w_rbitResult_32[15] = oprand[16];
assign w_rbitResult_32[14] = oprand[17];
assign w_rbitResult_32[13] = oprand[18];
assign w_rbitResult_32[12] = oprand[19];
assign w_rbitResult_32[11] = oprand[20];
assign w_rbitResult_32[10] = oprand[21];
assign w_rbitResult_32[9] = oprand[22];
assign w_rbitResult_32[8] = oprand[23];
assign w_rbitResult_32[7] = oprand[24];
assign w_rbitResult_32[6] = oprand[25];
assign w_rbitResult_32[5] = oprand[26];
assign w_rbitResult_32[4] = oprand[27];
assign w_rbitResult_32[3] = oprand[28];
assign w_rbitResult_32[2] = oprand[29];
assign w_rbitResult_32[1] = oprand[30];
assign w_rbitResult_32[0] = oprand[31];

wire [31:0] w_revResult_32;
//REV
assign w_revResult_32[31:24] = oprand[7:0];
assign w_revResult_32[23:16] = oprand[15:8];
assign w_revResult_32[15:8] = oprand[23:16];
assign w_revResult_32[7:0] = oprand[31:24];


wire [31:0] w_rev16Result_32;
//REV16
assign w_rev16Result_32[31:24] = oprand[23:16];
assign w_rev16Result_32[23:16] = oprand[31:24];
assign w_rev16Result_32[15:8] =  oprand[7:0];
assign w_rev16Result_32[7:0] =   oprand[15:8];

wire [31:0] w_revshResult_32;
wire [23:0] w_signExtendOp1_24;
assign w_signExtendOp1_24 = oprand[7] == 1'b1 ? {{16{1'b1}},oprand[7:0]} : {{16{1'b0}},oprand[7:0]};
//REVSH
assign w_revshResult_32[31:8] = w_signExtendOp1_24;
assign w_revshResult_32[7:0] =   oprand[15:8];

assign result = reverseType == 2'b00 ? w_rbitResult_32 :(reverseType == 2'b01 ? w_revResult_32 : (reverseType == 2'b10 ? w_rev16Result_32 :(reverseType == 2'b11 ? w_revshResult_32 : 32'b0)));
endmodule