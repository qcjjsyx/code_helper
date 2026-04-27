`timescale 1ns / 1ps
module cMutexMerge2_104b_socmem(
i_drive0, i_data0_104, o_free0,
i_drive1, i_data1_104, o_free1,
i_freeNext, o_driveNext, o_data_104,
rst
);

//input & output port
input i_drive0, i_drive1;
input [103:0] i_data0_104, i_data1_104;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [103:0] o_data_104;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext0,w_driveNext1,w_driveNext;
wire w_free0,w_free1;
wire [103:0] w_data0_104,w_data1_104,w_data_104;

(* dont_touch="true" *)delay1U outdelay1 (.inR(o_free0), .outR(w_free0), .rst(rst));
assign w_firstTrig = i_drive0 | w_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay2 (.inR(o_free1), .outR(w_free1), .rst(rst));
assign w_secondTrig = i_drive1 | w_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign o_driveNext = i_drive0 
				   | i_drive1 ;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;

assign w_data_104 = (w_firstReq == 1'b1) ? i_data0_104 :
			((w_secondReq == 1'b1) ? i_data1_104 : 104'b0);

assign o_data_104 = w_data_104;

endmodule
