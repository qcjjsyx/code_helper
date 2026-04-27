//-----------------------------------------------
//	module name: subtr4b
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-05)
//	description: 
//		substraction of 4 bit numbers
//		differ = a-b
//-----------------------------------------------
`timescale 1ns / 1ps

module subtr4b(a, b, differ);

parameter BORROW0 = 1'b0;

input [3:0] a,b;

output [3:0] differ;

wire [3:0] w_pSub_4;
wire [4:1] w_borrow_5;

assign w_pSub_4[0] = a[0]^b[0];
assign w_pSub_4[1] = a[1]^b[1];
assign w_pSub_4[2] = a[2]^b[2];
assign w_pSub_4[3] = a[3]^b[3];

assign w_borrow_5[1]=(w_pSub_4[0]&b[0])|(~w_pSub_4[0]&BORROW0);
assign w_borrow_5[2]=(w_pSub_4[1]&b[1])|(~w_pSub_4[1]&w_borrow_5[1]);
assign w_borrow_5[3]=(w_pSub_4[2]&b[2])|(~w_pSub_4[2]&w_borrow_5[2]);

assign differ[0]=w_pSub_4[0]^BORROW0;
assign differ[1]=w_pSub_4[1]^w_borrow_5[1];
assign differ[2]=w_pSub_4[2]^w_borrow_5[2];
assign differ[3]=w_pSub_4[3]^w_borrow_5[3];

endmodule
