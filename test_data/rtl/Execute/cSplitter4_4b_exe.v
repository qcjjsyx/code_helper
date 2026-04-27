

`timescale 1ns / 1ps

module cSplitter4_4b_exe(
i_drive, i_data_4, o_free,
o_driveNext0, o_data0_1, i_freeNext0, 
o_driveNext1, o_data1_1, i_freeNext1,
o_driveNext2, o_data2_1, i_freeNext2, 
o_driveNext3, o_data3_1, i_freeNext3,
rst);

input i_drive;
input i_freeNext0, i_freeNext1;
input i_freeNext2, i_freeNext3;
input rst;
input [3:0] i_data_4;

output o_free;
output o_driveNext0, o_driveNext1;
output o_driveNext2, o_driveNext3;
output o_data0_1, o_data1_1;
output o_data2_1, o_data3_1;


wire w_freeNext,w_free0Next,w_free1Next,w_free2Next,w_free3Next;
wire w_sendFree;
wire w_sendDrive;
(* dont_touch="true" *)wire w_firstTrig, w_firstReq;
(* dont_touch="true" *)wire w_secondTrig, w_secondReq;
(* dont_touch="true" *)wire w_thirdTrig, w_thirdReq;
(* dont_touch="true" *)wire w_forthTrig, w_forthReq;
wire w_delayFree0Next,w_delayFree1Next,w_delayFree2Next,w_delayFree3Next;
(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay3 (.inR(i_freeNext2), .outR(w_delayFree2Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay4 (.inR(i_freeNext3), .outR(w_delayFree3Next), .rst(rst));
assign o_data0_1 = i_data_4[0];
assign o_data1_1 = i_data_4[1];
assign o_data2_1 = i_data_4[2];
assign o_data3_1 = i_data_4[3];

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

assign w_forthTrig = w_delayFree3Next | w_sendDrive;

contTap forthTap(
.trig(w_forthTrig),
.req(w_forthReq),
.rst(rst) 
);


assign w_freeNext = w_free0Next | w_free1Next | w_free2Next | w_free3Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq | w_thirdReq | w_forthReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;
assign o_driveNext3 = i_drive;
endmodule










