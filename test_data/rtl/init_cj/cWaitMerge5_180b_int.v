

module cWaitMerge5_180b_int(
i_drive0,i_data0_36,o_free0,
i_drive1,i_data1_36,o_free1,
i_drive2,i_data2_36,o_free2,
i_drive3,i_data3_36,o_free3,
i_drive4,i_data4_36,o_free4,
o_driveNext,o_data_180,i_freeNext,rst
);

//input & output port
input i_drive0,i_drive1;
input i_drive2,i_drive3, i_drive4;
input [35:0] i_data0_36, i_data1_36, i_data2_36, i_data3_36, i_data4_36;
input i_freeNext;
input rst;

output o_free0,o_free1,o_free2,o_free3,o_free4;
output o_driveNext;
output [179:0] o_data_180;

//wire & reg
wire w_drive0Next,w_drive1Next, w_drive2Next, w_drive3Next, w_drive4Next;
wire w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig, w_forthTrig, w_fifthTrig;
wire w_firstReq,w_secondReq, w_thirdReq, w_forthReq, w_fifthReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire [35:0] w_data0_36;
wire [35:0] w_data1_36;
wire [35:0] w_data2_36;
wire [35:0] w_data3_36;
wire [35:0] w_data4_36;

reg [35:0] r_data0_36;
reg [35:0] r_data1_36;
reg [35:0] r_data2_36;
reg [35:0] r_data3_36;
reg [35:0] r_data4_36;


assign w_data0_36 = i_data0_36;
assign w_firstTrig = i_drive0 | w_sendFree;
(* dont_touch="true" *)delay8U outdelay0 (.inR(i_drive0), .outR(w_drive0Next), .rst(rst));
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

assign w_data1_36 = i_data1_36;
assign w_secondTrig = i_drive1 | w_sendFree;
(* dont_touch="true" *)delay8U outdelay1 (.inR(i_drive1), .outR(w_drive1Next), .rst(rst));
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_data2_36 = i_data2_36;
assign w_thirdTrig = i_drive2 | w_sendFree;
(* dont_touch="true" *)delay8U outdelay2 (.inR(i_drive2), .outR(w_drive2Next), .rst(rst));
contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

assign w_data3_36 = i_data3_36;
assign w_forthTrig = i_drive3 | w_sendFree;
(* dont_touch="true" *)delay8U outdelay3 (.inR(i_drive3), .outR(w_drive3Next), .rst(rst));
contTap forthTap(
.trig(w_forthTrig),
.req(w_forthReq),
.rst(rst)
);

assign w_data4_36 = i_data4_36;
assign w_fifthTrig = i_drive4 | w_sendFree;
(* dont_touch="true" *)delay8U outdelay4 (.inR(i_drive4), .outR(w_drive4Next), .rst(rst));
contTap fifthTap(
.trig(w_fifthTrig),
.req(w_fifthReq),
.rst(rst)
);
wire i_freeNextdelay;
delay8U freeNextdelay4 (.inR(i_freeNext), .outR(i_freeNextdelay), .rst(rst));

assign w_driveNext = w_drive0Next | w_drive1Next | w_drive2Next | w_drive3Next | w_drive4Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq & w_thirdReq & w_forthReq & w_fifthReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_free2 = i_freeNext;
assign o_free3 = i_freeNext;
assign o_free4 = i_freeNext;
assign o_data_180 = {w_data0_36[35:32],w_data1_36[35:32], w_data2_36[35:32], w_data3_36[35:32], w_data4_36[35:32],w_data0_36[31:0] ,w_data1_36[31:0], w_data2_36[31:0], w_data3_36[31:0], w_data4_36[31:0]};
assign o_driveNext = w_sendDrive;

endmodule
