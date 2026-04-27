`timescale 1ns / 1ps
module cMutexMerge2_8b(
i_drive0, i_data0_8, o_free0,
i_drive1, i_data1_8, o_free1,
i_freeNext, o_driveNext, o_data_8,
rst
);

//input & output port
input i_drive0, i_drive1;
input [7:0] i_data0_8, i_data1_8;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [7:0] o_data_8;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext0,w_driveNext1,w_driveNext;
wire w_free0,w_free1,w_free;
wire [7:0] w_data_8 ;
reg [7:0] r_data_4 ;



assign w_firstTrig = i_drive0 | o_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);



assign w_secondTrig = i_drive1 | o_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);



assign w_driveNext = i_drive0 | i_drive1;
delay6U Delay0(.inR(w_driveNext), .outR(o_driveNext), .rst(rst)); 




assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;

assign w_data_8 = (w_firstReq == 1'b1) ? i_data0_8 :
			((w_secondReq == 1'b1) ? i_data1_8 : 8'b0);

assign o_data_8 = w_data_8;

endmodule
