//-----------------------------------------------
//	module name: pmtClick
//	author: Fu Tong, Baoxia WAN 
//      modify author: Kang Li Zhao
//	version: 1st version (2021-11-20)
//	description: 
//		standard click with permit 
//		while permit is 1 , pmtClick is the same with click,
//      while permit is 0 , pmtClick is paused
//-----------------------------------------------
`timescale 1ns / 1ps

module pmtRelay(inR, inA, outR, outA, pmt, fire, rst);

input inR, outA, rst,pmt;

output inA, outR, fire;

wire inAR, outAR, notR;
wire Rtemp0, Rtemp1, Rtemp2, Rtemp3, Rtemp4,Rtemp5,Rtemp6;
wire fire0;
XOR2M0HM neqIn ( .A(inR), .B(inA), .Z(inAR) );

XNR2M0HM eqOut ( .A(outA), .B(inA), .Z(outAR) );

AN2M0HM andFire ( .A(inAR), .B(outAR), .Z(fire0) );
AN2M0HM fire_pmt ( .A(fire0), .B(pmt), .Z(fire) );
//AND2_X1M_A9TRULP_C40_W3 Fire ( .A(fire0), .B(pmt), .Y(fire) );
INVM0HM invTmp ( .A(inA), .Z(notR) );

DFQRM2HM ffState ( .D(notR), .CK(fire), .RB(rst), .Q(Rtemp0) );

DEL1M1HM delay7 ( .A(Rtemp0), .Z(inA) );
BUFM2HM U1 ( .A(inA), .Z(outR) );
endmodule


