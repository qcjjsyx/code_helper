/*=============================================================
Project:ARMCPU
Module:cSelector2_33b_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSelector2_33b_launch of launch
==============================================================*/

`timescale 1ns / 1ps

module cSelector2_33b_launch(
i_drive, i_data_33, o_free,
o_driveNext0, i_freeNext0, o_data0_32,
o_driveNext1, o_data1_32, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [32:0] i_data_33;

output o_free;
output o_driveNext0,o_driveNext1;
output [31:0] o_data0_32;
output [31:0] o_data1_32; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
wire w_fire0, w_fire1;

wire w_valid_1;

assign w_valid_1 = i_data_33[32];

reg [31:0] r_data0_32;
reg [31:0] r_data1_32;
reg r_valid_1, r_valid1_1;

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

always @(posedge w_fire or negedge rst) begin
	if (!rst) begin
		r_data0_32 <= 32'b0; 
		r_valid_1 <= 1'b0;
		r_valid1_1 <= 1'b0;
	end else begin
		r_data0_32 <= i_data_33[31:0];
		r_valid_1 <= w_valid_1;
		r_valid1_1 <= ~w_valid_1;
	end
end

assign o_data0_32 = r_data0_32 & {32{r_valid_1}};
assign o_data1_32 = r_data0_32 & {32{~r_valid_1}};

//control signal
wire w_driveNextDelay,w_driveNextDelay0;
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay6U outdelay0(.inR(w_fire), .outR(w_driveNextDelay), .rst(rst));
delay4U outdelay1(.inR(w_driveNextDelay), .outR(w_driveNextDelay0), .rst(rst));
delay4U outdelay4(.inR(w_driveNextDelay0), .outR(w_driveNext0), .rst(rst));//2/18 zwm add 
assign o_driveNext0 = w_driveNext0 & r_valid_1;
assign o_driveNext1 = w_driveNext0 & r_valid1_1;
assign w_freeNext = i_freeNext0 | i_freeNext1;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule

