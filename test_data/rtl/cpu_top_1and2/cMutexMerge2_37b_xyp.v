//-----------------------------------------------
//	module name: cMutexMerge2_37b_xyp
//	author: xing.yunpeng
//	version: 2024/1/3
//-----------------------------------------------
`timescale 1ns / 1ps

module cMutexMerge2_37b_xyp(
i_drive0, i_data0_37 , o_free0,
i_drive1, i_data1_37 , o_free1,
i_freeNext, o_driveNext, o_data_37,
rst
);

//input & output port
input i_drive0, i_drive1;
input [36:0] i_data0_37, i_data1_37;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [36:0] o_data_37;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;

wire [36:0] w_data_37;
wire w_free0,w_free1;

// first
(* dont_touch="true" *)delay1U outdelay1 (.inR(o_free0), .outR(w_free0), .rst(rst));
assign w_firstTrig = i_drive0 | w_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

// second
(* dont_touch="true" *)delay1U outdelay2 (.inR(o_free1), .outR(w_free1), .rst(rst));
assign w_secondTrig = i_drive1 | w_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);


assign o_driveNext = i_drive0 | i_drive1;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;

assign w_data_37 = (w_firstReq == 1'b1) ? i_data0_37 :
			((w_secondReq == 1'b1) ? i_data1_37 : 37'b0);

assign o_data_37 = w_data_37;

endmodule
