//-----------------------------------------------
//	module name: bidirDelay1U_umc40
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-05)
//	description: 
//		1. bidirected delay, e.g., equal delays
//		for both req from left to right and
//		ack from right to left
//		2. 1U for 1 delay unit
//		3. tech: umc40
//-----------------------------------------------

`timescale 1ns / 1ps

module bidirDelay1U(inR, inA, outR, outA);
	
input	inR, outA;

output	outR, inA;

wire delayR0, delayR1, delayR2, delayR3;
wire delayA0, delayA1, delayA2, delayA3;

//request delay
//DEL4UHDV1 inDelay ( .I(inR), .Z(outR) );
DEL1M4HM inDelay ( .A(inR), .Z(outR) );
//acknowlege delay
//DEL4UHDV1 outDelay ( .I(outA), .Z(inA) );
DEL1M4HM outDelay ( .A(outA), .Z(inA) );
endmodule
