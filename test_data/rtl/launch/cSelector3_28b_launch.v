/*=============================================================
Project:ARMCPU
Module:cSelector3_28b_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSelector3_28b_launch of launch
==============================================================*/


`timescale 1ns / 1ps

module cSelector3_28b_launch(
i_drive, i_data_28, o_free,
o_driveNext0, i_freeNext0, o_data0_26,
o_driveNext1, o_data1_26, i_freeNext1,
o_driveNext2, o_data2_16, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
input [27:0] i_data_28;

output o_free;
output o_driveNext0,o_driveNext1, o_driveNext2;
output [25:0] o_data0_26;
output [25:0] o_data1_26; 
output [15:0] o_data2_16; 

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

assign w_valid_1 = i_data_28[27];
assign w_valid1_1 = i_data_28[26];


reg [25:0] r_data0_26;


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
		r_data0_26 <= 26'b0;
	end else begin
		r_data0_26 <= i_data_28[26:0];
		r_valid_1 <= w_valid_1;
		r_valid1_1 <= w_valid1_1;
		
	end
end

assign o_data0_26 = r_data0_26 & {26{r_valid_1}} & {26{~r_valid1_1}};
assign o_data1_26 = r_data0_26 & {26{~r_valid_1}} & {26{~r_valid1_1}};
assign o_data2_16 = r_data0_26 & {26{~r_valid_1}} & {26{r_valid1_1}};

//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay4U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & w_valid_1 & ~w_valid1_1;
assign o_driveNext1 = w_driveNext0 & ~w_valid_1 & ~w_valid1_1;
assign o_driveNext2 = w_driveNext0 & ~w_valid_1 & w_valid1_1;
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule

