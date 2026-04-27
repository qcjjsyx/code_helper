//-----------------------------------------------
//	module name: clickfifo1
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo1ArbSend(
i_drive,i_freeNext,rst,
o_free,o_driveNext,
o_fire_1
);

input i_drive, i_freeNext, rst;
output o_free, o_driveNext;
output o_fire_1;

wire [2:0] w_outRRelay_2;
wire [1:0] w_outARelay_2;
wire w_driveNext0, w_driveNext1,w_driveNext;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_2[0]),
	.i_free(w_driveNext),
	.rst(rst)
);

//delay6Unit relayDelay0(.inR(w_outRRelay_2[0]), .outR(w_outRRelay_2[1]), .rst(rst));
delay6U relayDelay0(.inR(w_outRRelay_2[0]), .outR(w_outRRelay_2[1]), .rst(rst));

relay relay0(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[2]),
	.outA(w_outARelay_2[1]),
	.fire(o_fire_1),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[2]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(i_freeNext),
	.rst(rst)
);

delay2U outdelay0 (.inR(o_fire_1), .outR(w_driveNext));
//delay6U outdelay2 (.inR(w_driveNext0), .outR(w_driveNext1), .rst(rst));
delay4U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule
