//-----------------------------------------------
//	module name: delay1U
//	author: Fu Tong , Baoxia Wan , Mingshu Chen , sun.yingjie
//  modifier: 
//  	modifyer: Anping HE (heap@lzu.edu.cn)
//  		adopting FDPE explicitly
//	version: 3nd version (2025-7-1)
//	description: 
//		one unit delay
//      output ==> input (==>:one uint delay)
//      SMIC 28 RVT
//-----------------------------------------------
`timescale 1ns / 1ps
//36ps
module delay1U(inR, outR, rstn);
input inR, rstn;
output outR;
wire C,D;
wire A,B;

DEL1V4_140P9T35R delay1_donttouch ( .I(inR), .Z(A));
CLKAND2V3_140P9T35R AND_donttouch (.A1(A), .A2(rstn), .Z(outR) );

endmodule
