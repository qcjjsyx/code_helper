`timescale 1ns / 1ps
module cMutexMerge3_104b_lsu(
i_drive0, i_data0_104, o_free0,
i_drive1, i_data1_104, o_free1,
i_drive2, i_data2_104, o_free2,
i_freeNext, o_driveNext, o_data_104,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2;
input [103:0] i_data0_104, i_data1_104, i_data2_104;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2;
output o_driveNext;
output [103:0] o_data_104;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig;
wire w_firstReq,w_secondReq, w_thirdReq;
wire w_driveNext0,w_driveNext1, w_driveNext2,w_driveNext;
wire [103:0] w_data0_104,w_data1_104, w_data2_104;
wire [103:0] w_data_104;
reg [103:0] r_data0_104,r_data1_104, r_data2_104;
reg [103:0] r_data_104;
wire w_free0,w_free1,w_free2;

(* dont_touch="true" *)delay4U outdelay1 (.inR(o_free0), .outR(w_free0), .rst(rst));
assign w_firstTrig = i_drive0 | w_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay4U outdelay2 (.inR(o_free1), .outR(w_free1), .rst(rst));
assign w_secondTrig = i_drive1 | w_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

(* dont_touch="true" *)delay4U outdelay3 (.inR(o_free2), .outR(w_free2), .rst(rst));
assign w_thirdTrig = i_drive2 | w_free2;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

assign o_driveNext = i_drive0
				   | i_drive1
				   | i_drive2;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;
assign o_free2 = i_freeNext & w_thirdReq;
assign w_data_104 = (w_firstReq == 1'b1) ? i_data0_104 :
			((w_secondReq == 1'b1) ? i_data1_104 : 
            ((w_thirdReq == 1'b1) ? i_data2_104 : 104'b0));
assign o_data_104 = w_data_104;

endmodule
