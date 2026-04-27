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

module delay8U(inR, outR, rst);
input inR, rst;
output outR;

wire outR0;
wire outR1;


delay4U delay1(.inR(inR), .outR(outR0), .rst(rst));
cFifo1 delayFifo(.i_drive(outR0), .i_freeNext(outR), .rst(rst),
               .o_free(), .o_driveNext(outR1), .o_fire_1());
delay4U delay2(.inR(outR1), .outR(outR), .rst(rst));
endmodule

