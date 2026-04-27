//-----------------------------------------------
//	module name: delay1U
//	author: Fu Tong , Baoxia Wan , Mingshu Chen
//  modifier: 
//  	modifyer: Anping HE (heap@lzu.edu.cn)
//  		adopting FDPE explicitly
//	version: 2nd version (2021-11-17)
//	description: 
//		one unit delay
//      output ==> input (==>:one uint delay)
//-----------------------------------------------
`timescale 1ns / 1ps

module delay1U(inR, outR, rst);
input inR, rst;
output outR;

wire A,B;
DEL1M1HM delay1 ( .A(inR), .Z(A) );
AN2M0HM AND (.A(A), .B(rst), .Z(outR) );
endmodule
