//-----------------------------------------------
//	module name: Sender
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-02)
//-----------------------------------------------

`timescale 1ns / 1ps
module sender(i_drive,o_free,outR,i_free,rst);
input i_drive, i_free, rst;
output o_free, outR;

wire outRNeg;
INVM0HM inv6 ( .A(outR), .Z(outRNeg) );
DFQRM2HM ffState ( .D(outRNeg), .CK(i_drive), .RB(rst), .Q(outR) );

DEL1M4HM inDelay0 ( .A(i_free), .Z(o_free) );

endmodule
