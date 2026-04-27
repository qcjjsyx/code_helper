`timescale 1ns / 1ps

module cWaitMerge2_163b_exe(
i_drive0,i_data0_68,o_free0,
i_drive1,i_data1_95,o_free1,rst,
o_driveNext,o_data_163,i_freeNext
);

//input & output port
input i_drive0,i_drive1;
input [67:0] i_data0_68;
input [94:0] i_data1_95;
input i_freeNext;
input rst;

output o_free0,o_free1;
output o_driveNext;
output [162:0] o_data_163;

//wire & reg
wire w_drive0Next,w_drive1Next;
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire [67:0] w_data0_68;
wire [94:0] w_data1_95;

reg [67:0] r_data0_68;
reg [94:0] r_data1_95;



assign w_data0_68 = i_data0_68;
assign w_firstTrig = i_drive0 | w_sendFree;
(* dont_touch="true" *)delay1U outdelay0 (.inR(i_drive0), .outR(w_drive0Next), .rst(rst));

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst) 
);

 
assign w_data1_95 = i_data1_95;
assign w_secondTrig = i_drive1 | w_sendFree;
(* dont_touch="true" *)delay1U outdelay1 (.inR(i_drive1), .outR(w_drive1Next), .rst(rst));

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst) 
);

assign w_driveNext = w_drive0Next | w_drive1Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_data_163 = {w_data1_95,w_data0_68};
assign o_driveNext = w_sendDrive;

endmodule
