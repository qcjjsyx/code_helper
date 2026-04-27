//-----------------------------------------------
//	module name: cfifo2
//	author: Tong Fu, Lingzhuang Zhang
//	version: 2st version (2023-03-09)
//-----------------------------------------------
`timescale 1ns / 1ps

module cFifo2_wd(
    // rst
    input           rst,
    // From Last
    input           i_drive, 
    output          o_free, 
    // To Next
    output          o_driveNext,
    input           i_freeNext,
    // fire signal
    output  [1:0]   o_fire_2
);

wire [2:0]  w_outRRelay_3,  w_outARelay_3;
wire        w_driveNext;
wire [1:0]       delayR;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_3[0]),
	.i_free(w_driveNext),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_3[0]),
	.inA(w_outARelay_3[0]),
	.outR(w_outRRelay_3[1]),
	.outA(w_outARelay_3[1]),
	.fire(o_fire_2[0]),
	.rst(rst)
);

delay8U delay1(.inR(w_outRRelay_3[1]),.outR(delayR[0]), .rst(rst));

relay relay1(
	.inR(delayR[0]),
	.inA(w_outARelay_3[1]),
	.outR(w_outRRelay_3[2]),
	.outA(w_outARelay_3[2]),
	.fire(o_fire_2[1]),
	.rst(rst)
);

delay8U delay2(.inR(w_outRRelay_3[2]),.outR(delayR[1]), .rst(rst));

receiver receiver(
	.inR(delayR[1]),
	.inA(w_outARelay_3[2]),
	.i_freeNext(i_freeNext),
	.rst(rst)
);

delay8U outdelay0 (.inR(o_fire_2[1]), .outR(w_driveNext), .rst(rst));
delay8U outdelay1 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule
