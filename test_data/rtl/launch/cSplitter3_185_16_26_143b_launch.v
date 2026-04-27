/*=============================================================
Project:ARMCPU
Module:cSplitter3_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSplitter3_launch of launch
==============================================================*/

`timescale 1ns / 1ps

module cSplitter3_185_16_26_143b_launch(
i_drive, i_data_185, o_free,
o_driveNext0, i_freeNext0, o_data0_16,
o_driveNext1, o_data1_26, i_freeNext1,
o_driveNext2, o_data2_143, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1, i_freeNext2;
input rst;
input [184:0] i_data_185;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2;
output [15:0] o_data0_16;
output [25:0] o_data1_26;
output [142:0] o_data2_143;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext,w_free0Next,w_free1Next,w_free2Next;
wire w_driveNext0;
wire w_sendFree;
wire w_sendDrive;
 wire w_firstTrig, w_firstReq;
 wire w_secondTrig, w_secondReq;
 wire w_thirdTrig, w_thirdReq;

wire w_delayFree0Next,w_delayFree1Next, w_delayFree2Next;
(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay3 (.inR(i_freeNext2), .outR(w_delayFree2Next), .rst(rst));

assign o_data0_16 = i_data_185[184:169];
assign o_data1_26 = i_data_185[168:143];
assign o_data2_143 = i_data_185[142:0];



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

(* dont_touch="true" *)delay4U outdelay3 (.inR(w_delayFree2Next), .outR(w_free2Next), .rst(rst));

assign w_thirdTrig = w_delayFree2Next | w_sendDrive;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next | w_free2Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq | w_thirdReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;


endmodule

