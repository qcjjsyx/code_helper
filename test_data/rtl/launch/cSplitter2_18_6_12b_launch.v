/*=============================================================
Project:ARMCPU
Module:cSplitter2_18_6_12b_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSplitter2_18_6_12b_launch of launch
==============================================================*/

`timescale 1ns / 1ps

module cSplitter2_18_6_12b_launch(
i_drive, i_data_18, o_free,
o_driveNext0, i_freeNext0, o_data0_6,
o_driveNext1, o_data1_12, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [17:0] i_data_18;

output o_free;
output o_driveNext0,o_driveNext1;
output [5:0] o_data0_6;
output [11:0] o_data1_12;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext,w_free0Next,w_free1Next;
wire w_driveNext0;
wire w_sendFree;
wire w_sendDrive;
wire w_firstTrig, w_firstReq;
wire w_secondTrig, w_secondReq;
wire w_delayFree0Next,w_delayFree1Next;
(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

assign o_data0_6 = i_data_18[5:0];
assign o_data1_12 = i_data_18[17:6];

(* dont_touch="true" *)delay3U outdelay1 (.inR(w_delayFree0Next), .outR(w_free0Next), .rst(rst));

assign w_firstTrig = w_delayFree0Next | w_sendDrive;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay3U outdelay2 (.inR(w_delayFree1Next), .outR(w_free1Next), .rst(rst));

assign w_secondTrig = w_delayFree1Next | w_sendDrive;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;

endmodule

