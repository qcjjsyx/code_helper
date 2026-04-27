//-----------------------------------------------
//	module name: bidirDelay4U
//	author: Anping HE (heap@lzu.edu.cn)
//	version: 1st version (2021-11-05)
//	description: 
//		1. bidirected delay, e.g., equal delays for both req from left to right and ack from right to left
//		2. 4U for 4 bidirected delay units
//-----------------------------------------------

`timescale 1ns / 1ps

module bidirDelay2U(inR, inA, outR, outA);

input   inR, outA;

output  outR, inA; 

wire w_req_0, w_ack_0, w_req_1, w_ack_1, w_req_2, w_ack_2;

bidirDelay1U delay0(inR, inA, w_req_0, w_ack_0);
bidirDelay1U delay1(w_req_0, w_ack_0, outR, outA);

endmodule
