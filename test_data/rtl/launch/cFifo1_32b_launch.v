/*=============================================================
Project:ARMCPU
Module:cFifo1_32b
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cFifo1_32b of launch
==============================================================*/

`timescale 1ns / 1ps

module cFifo1_32b_launch(
i_drive, i_data_32, o_free,rst,
o_driveNext, o_data_32, i_freeNext
);

input i_drive, i_freeNext, rst;
input [31:0] i_data_32;
output o_free, o_driveNext;
output [31:0] o_data_32;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [31:0] r_data_32;



assign o_data_32 = i_data_32;


assign  o_driveNext = i_drive;
assign  o_free = i_freeNext;

endmodule

