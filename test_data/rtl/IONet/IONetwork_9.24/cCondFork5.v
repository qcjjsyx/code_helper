//-----------------------------------------------
//	module name: cCondfork5
//	author: Tong Fu
//	version: 1st version (2023-06-20)
//-----------------------------------------------

`timescale 1ns / 1ps

module cCondFork5(
i_drive,i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,
valid0,valid1,valid2,valid3,valid4,o_fire,rst,
o_free,o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4;
input valid0,valid1,valid2,valid3,valid4;
input rst;


output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4;
output o_fire;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext;
wire w_driveNext0,w_driveNext1;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_2[0]),
	.i_free(w_fire),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(w_freeNext),
	.rst(rst)
);

//control signal
delay2U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & valid0;
assign o_driveNext1 = w_driveNext0 & valid1;
assign o_driveNext2 = w_driveNext0 & valid2;
assign o_driveNext3 = w_driveNext0 & valid3;
assign o_driveNext4 = w_driveNext0 & valid4;
assign o_fire = w_fire;
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4;

endmodule
