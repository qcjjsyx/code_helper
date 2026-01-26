//-----------------------------------------------
//	module name: Sender
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------

`timescale 1ns / 1ps
module sender(i_drive,o_free,outR,i_free,rstn);
input i_drive, i_free, rstn;
output o_free, outR;

wire outRNeg;
INV2_140P9T35R inv6_donttouch ( .I(outR), .ZN(outRNeg) );
DRNQV2_140P9T35R ffState_donttouch ( .D(outRNeg), .CK(i_drive), .RDN(rstn), .Q(outR) );

DEL1V4_140P9T35R inDelay0_donttouch ( .I(i_free), .Z(o_free) );

endmodule