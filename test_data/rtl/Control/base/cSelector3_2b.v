
`timescale 1ns / 1ps

module cSelector3_2b(
i_drive, i_data_2, o_free,
o_driveNext0, i_freeNext0, o_data0_1,
o_driveNext1, o_data1_1, i_freeNext1,
o_driveNext2, o_data2_1, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
input [1:0] i_data_2;

output o_free;
output o_driveNext0,o_driveNext1, o_driveNext2;
output o_data0_1;
output o_data1_1; 
output o_data2_1; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_fire0, w_fire1, w_fire2;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;

wire w_valid_1;
wire w_valid1_1;
reg r_valid_1;
reg r_valid1_1;

assign w_valid_1 = i_data_2[0];
assign w_valid1_1 = i_data_2[1];

assign w_fire0 = w_fire & w_valid_1 & ~w_valid1_1;
assign w_fire1 = w_fire & ~w_valid_1 & ~w_valid1_1;
assign w_fire2 = w_fire & ~w_valid_1 & w_valid1_1;


//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(w_free_1),
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
	.i_freeNext(w_freeNext1),
	.rst(rst)
);


assign o_data0_1 = 0;
assign o_data1_1 = 0;
assign o_data2_1 = 0;

//control signal
(* dont_touch="true" *)delay2U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay2U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & w_valid_1 & ~w_valid1_1;
assign o_driveNext1 = w_driveNext0 & ~w_valid_1 & ~w_valid1_1;
assign o_driveNext2 = w_driveNext0 & ~w_valid_1 & w_valid1_1;
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule

