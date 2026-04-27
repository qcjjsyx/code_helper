/*=============================================================
Project:ARMCPU
Module:cSplitter2_7_3_4b_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSplitter2_7_3_4b_launch of launch
==============================================================*/


`timescale 1ns / 1ps

module cSplitter2_7_3_4b_launch(
i_drive, i_data_7, o_free,
o_driveNext0, i_freeNext0, o_data0_3,
o_driveNext1, o_data1_4, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [6:0] i_data_7;

output o_free;
output o_driveNext0,o_driveNext1;
output [2:0] o_data0_3;
output [3:0] o_data1_4;

wire [2:0] w_outRRelay_3,w_outARelay_3;
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

assign o_data0_3 = i_data_7[6:4];
assign o_data1_4 = i_data_7[3:0];


(* dont_touch="true" *)delay4U outdelay1 (.inR(w_delayFree0Next), .outR(w_free0Next), .rst(rst));

assign w_firstTrig = w_delayFree0Next | w_sendDrive;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay4U outdelay2 (.inR(w_delayFree1Next), .outR(w_free1Next), .rst(rst));

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

