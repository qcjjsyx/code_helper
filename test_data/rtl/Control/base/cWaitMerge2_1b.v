

module cWaitMerge2_1b(
i_drive0,i_data0_1,o_free0,
i_drive1,i_data1_1,o_free1,rst,
o_driveNext,o_data_1,i_freeNext
);

//input & output port
input i_drive0,i_drive1;
input i_data0_1;
input i_data1_1;
input i_freeNext;
input rst;

output o_free0,o_free1;
output o_driveNext;
output o_data_1;

//wire & reg
wire w_drive0Next,w_drive1Next;
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire w_data0_1;
wire w_data1_1;


assign w_firstTrig = i_drive0 | w_sendFree;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);


assign w_secondTrig = i_drive1 | w_sendFree;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

(* dont_touch="true" *)delay6U outdelay0 (.inR(i_drive0), .outR(w_drive0Next), .rst(rst));
(* dont_touch="true" *)delay6U outdelay1 (.inR(i_drive1), .outR(w_drive1Next), .rst(rst));

assign w_driveNext = w_drive0Next | w_drive1Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_data_1 = i_data0_1;
assign o_driveNext = w_sendDrive;

endmodule
