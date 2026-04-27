//-----------------------------------------------
//	module name: Receiver
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------
`timescale 1ns / 1ps

module receiver(inR, inA, i_freeNext, rst);

input inR, i_freeNext, rst;
wire outR, outA;
output inA;

DFQRM2HM ffState ( .D(inR), .CK(i_freeNext), .RB(rst), .Q(inA) );

endmodule

