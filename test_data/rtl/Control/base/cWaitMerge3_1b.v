

module cWaitMerge3_1b(
i_drive0,i_data0_1,o_free0,
i_drive1,i_data1_1,o_free1,
i_drive2,i_data2_1,o_free2,
o_driveNext,o_data_1,i_freeNext,rst
);

//input & output port
input i_drive0,i_drive1;
input i_drive2;
input i_data0_1, i_data1_1, i_data2_1;
input i_freeNext;
input rst;

output o_free0,o_free1,o_free2;
output o_driveNext;
output o_data_1;

//wire & reg
wire w_drive0Next,w_drive1Next, w_drive2Next;
wire w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig;
wire w_firstReq,w_secondReq, w_thirdReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire w_data0_1;
wire w_data1_1;
wire w_data2_1;


reg r_data0_1;
reg r_data1_1;
reg r_data2_1;



assign w_data0_1 = i_data0_1;
assign w_firstTrig = i_drive0 | w_sendFree;
(* dont_touch="true" *)delay2U outdelay0 (.inR(i_drive0), .outR(w_drive0Next), .rst(rst));
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

assign w_data1_1 = i_data1_1;
assign w_secondTrig = i_drive1 | w_sendFree;
(* dont_touch="true" *)delay2U outdelay1 (.inR(i_drive1), .outR(w_drive1Next), .rst(rst));
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_data2_1 = i_data2_1;
assign w_thirdTrig = i_drive2 | w_sendFree;
(* dont_touch="true" *)delay2U outdelay2 (.inR(i_drive2), .outR(w_drive2Next), .rst(rst));
contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);


assign w_driveNext = w_drive0Next | w_drive1Next | w_drive2Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq & w_thirdReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_free2 = i_freeNext;
assign o_data_1 = w_data1_1;
assign o_driveNext = w_sendDrive;

endmodule
