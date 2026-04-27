`timescale 1ns / 1ps

module cSplitter3_169_41_4_132b_exe(
i_drive, i_data_169, o_free,
o_driveNext0, i_freeNext0, o_data0_4,
o_driveNext1, o_data1_41, i_freeNext1,
o_driveNext2, o_data2_132, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1, i_freeNext2;
input rst;
input [168:0] i_data_169;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2;
output [3:0] o_data0_4;
output [40:0] o_data1_41;
output [131:0] o_data2_132;

wire w_freeNext,w_free0Next,w_free1Next,w_free2Next;
wire w_sendFree;
wire w_sendDrive;
(* dont_touch="true" *)wire w_firstTrig, w_firstReq;
(* dont_touch="true" *)wire w_secondTrig, w_secondReq;
(* dont_touch="true" *)wire w_thirdTrig, w_thirdReq;

wire w_delayFree0Next,w_delayFree1Next,w_delayFree2Next;
(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay3 (.inR(i_freeNext2), .outR(w_delayFree2Next), .rst(rst));
assign o_data0_4 = i_data_169[168:165];
assign o_data1_41 = {i_data_169[21],i_data_169[68:29]};
assign o_data2_132 = {i_data_169[164:69],i_data_169[36:22],i_data_169[20:0]};

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


assign w_freeNext = w_free0Next | w_free1Next | w_free2Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq | w_thirdReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;


endmodule

