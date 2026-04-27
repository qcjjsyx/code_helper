/*=============================================================
Project:ARMCPU
Module:cSplitter6_6b_launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cSplitter6_6b_launch of launch
==============================================================*/

`timescale 1ns / 1ps

module cSplitter6_6b_launch(
i_drive, i_data_6, o_free,
o_driveNext0, o_data0_1, i_freeNext0, 
o_driveNext1, o_data1_1, i_freeNext1,
o_driveNext2, o_data2_1, i_freeNext2, 
o_driveNext3, o_data3_1, i_freeNext3,
o_driveNext4, o_data4_1, i_freeNext4, 
o_driveNext5, o_data5_1, i_freeNext5,
rst);

input i_drive;
input i_freeNext0, i_freeNext1;
input i_freeNext2, i_freeNext3;
input i_freeNext4, i_freeNext5;
input rst;
input [5:0] i_data_6;

output o_free;
output o_driveNext0, o_driveNext1;
output o_driveNext2, o_driveNext3;
output o_driveNext4, o_driveNext5;
output o_data0_1, o_data1_1;
output o_data2_1, o_data3_1;
output o_data4_1, o_data5_1;


wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext;
wire w_free0Next,w_free1Next, w_free2Next, w_free3Next, w_free4Next, w_free5Next;
wire w_driveNext0,w_driveNext1,w_driveNext2,w_driveNext3,w_driveNext4,w_driveNext5;

wire w_firstTrig, w_firstReq;
wire w_secondTrig, w_secondReq;
wire w_thirdTrig, w_thirdReq;
wire w_4Trig, w_4Req;
wire w_5Trig, w_5Req;
wire w_6Trig, w_6Req;
wire w_sendFree;
wire w_sendDrive;

wire w_delayFree0Next,w_delayFree1Next, w_delayFree2Next;
wire w_delayFree3Next,w_delayFree4Next, w_delayFree5Next;

(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay3 (.inR(i_freeNext2), .outR(w_delayFree2Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay4 (.inR(i_freeNext3), .outR(w_delayFree3Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay5 (.inR(i_freeNext4), .outR(w_delayFree4Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay6 (.inR(i_freeNext5), .outR(w_delayFree5Next), .rst(rst));


assign o_data0_1 = i_data_6[0];
assign o_data1_1 = i_data_6[1];
assign o_data2_1 = i_data_6[2];
assign o_data3_1 = i_data_6[3];
assign o_data4_1 = i_data_6[4];
assign o_data5_1 = i_data_6[5];


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

(* dont_touch="true" *)delay3U outdelay3 (.inR(w_delayFree2Next), .outR(w_free2Next), .rst(rst));

assign w_thirdTrig = w_delayFree2Next | w_sendDrive;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

(* dont_touch="true" *)delay3U outdelay4 (.inR(w_delayFree3Next), .outR(w_free3Next), .rst(rst));

assign w_4Trig = w_delayFree3Next | w_sendDrive;

contTap fourthTap(
.trig(w_4Trig),
.req(w_4Req),
.rst(rst)
);

(* dont_touch="true" *)delay3U outdelay5 (.inR(w_delayFree4Next), .outR(w_free4Next), .rst(rst));

assign w_5Trig = w_delayFree4Next | w_sendDrive;

contTap fifthTap(
.trig(w_5Trig),
.req(w_5Req),
.rst(rst)
);

(* dont_touch="true" *)delay3U outdelay6 (.inR(w_delayFree5Next), .outR(w_free5Next), .rst(rst));

assign w_6Trig = w_delayFree5Next | w_sendDrive;

contTap sixthTap(
.trig(w_6Trig),
.req(w_6Req),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next | w_free2Next | w_free3Next | w_free4Next | w_free5Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq | w_thirdReq | w_4Req | w_5Req | w_6Req);
assign w_sendDrive = i_drive;



//control signal
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;
assign o_driveNext3 = i_drive;
assign o_driveNext4 = i_drive;
assign o_driveNext5 = i_drive;
assign o_free = w_sendFree;

endmodule

