//-----------------------------------------------
//	module name: Receiver
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------
`timescale 1ns / 1ps

module receiver(inR, inA, i_free, rstn);

input inR, i_free, rstn;
wire outR, outA;
output inA;

DRNQV2_140P9T35R ffState_donttouch ( .D(inR), .CK(i_free), .RDN(rstn), .Q(inA) );

endmodule