/*=============================================================
Project:ARMCPU
Module:cFifo1_16_32b
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cFifo1_16_32b of launch
==============================================================*/


`timescale 1ns / 1ps

module cFifo1_16_32b_launch(
i_drive, i_data_16, o_free,rst,
o_driveNext, o_data_32, i_freeNext
);

input i_drive, i_freeNext, rst;
input [15:0] i_data_16;
output o_free, o_driveNext;
output [31:0] o_data_32;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [3:0] r_preRd1Addr_4;
reg [3:0] r_preRd2Addr_4;
reg [3:0] r_preRdL1Addr_4;
reg [3:0] r_preRdL2Addr_4;

reg [7:0] r_preSRd1Addr_8;
reg [7:0] r_preSRd2Addr_8;


//update:初始复位的值有改动
always @(posedge i_drive or negedge rst) begin
	if (!rst) begin
		r_preRd1Addr_4 = 4'hf;
		r_preRd2Addr_4 = 4'hf;
		r_preRdL1Addr_4 = 4'hf;
		r_preRdL2Addr_4 = 4'hf;
		r_preSRd1Addr_8 = 8'b0;
		r_preSRd2Addr_8 = 8'b0;
	end else begin
		r_preRd2Addr_4 = r_preRd1Addr_4;
		r_preRd1Addr_4 = i_data_16[11:8];
		r_preRdL2Addr_4 = r_preRdL1Addr_4;
		r_preRdL1Addr_4 = i_data_16[15:12];
		r_preSRd2Addr_8 = r_preSRd1Addr_8;
		r_preSRd1Addr_8 = i_data_16[7:0];
	end
end

assign o_data_32 = {r_preRdL2Addr_4, r_preRdL1Addr_4, r_preRd2Addr_4, r_preRd1Addr_4, r_preSRd2Addr_8, r_preSRd1Addr_8};

delay8U outdelay0 (.inR(i_drive), .outR(o_driveNext),.rst(rst));
delay8U outdelay1 (.inR(i_freeNext), .outR(o_free),.rst(rst));
// delay1U outdelay1 (.inR(w_driveNext),.outR(o_driveNext));
// assign o_driveNext = i_drive;
// assign o_free = i_freeNext;
endmodule

