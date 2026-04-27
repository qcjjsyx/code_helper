//-----------------------------------------------
//	module name: clickfifo1
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo1_grf(
i_drive,i_freeNext,rst,
o_free,o_driveNext,
o_fire_1
);

input i_drive, i_freeNext, rst;
output o_free, o_driveNext;
output o_fire_1;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire1_1, w_fire2_1;
wire w_fire3_1, w_fire4_1;
wire w_fire5_1, w_fire6_1;
wire w_fire7_1, w_fire8_1;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_2[0]),
	.i_free(w_driveNext),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire1_1),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(i_freeNext),
	.rst(rst)
);

BUFM2HM buf0(.A(w_fire1_1), .Z(w_fire2_1));
BUFM2HM buf1(.A(w_fire2_1), .Z(w_fire3_1));
BUFM2HM buf2(.A(w_fire3_1), .Z(w_fire4_1));
BUFM2HM buf3(.A(w_fire4_1), .Z(w_fire5_1));
BUFM2HM buf4(.A(w_fire5_1), .Z(w_fire6_1));
BUFM2HM buf5(.A(w_fire6_1), .Z(w_fire7_1));
BUFM2HM buf6(.A(w_fire7_1), .Z(w_fire8_1));
BUFM2HM buf7(.A(w_fire8_1), .Z(o_fire_1));

delay4U outdelay0 (.inR(o_fire_1), .outR(w_driveNext), .rst(rst));
delay4U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule

