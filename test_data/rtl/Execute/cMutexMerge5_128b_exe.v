`timescale 1ns / 1ps
module cMutexMerge5_128b_exe(
i_drive0, i_data0_64, o_free0,
i_drive1, i_data1_64, o_free1,
i_drive2, i_data2_64, o_free2,
i_drive3, i_data3_64, o_free3,
i_drive4, i_data4_128, o_free4,
i_freeNext, o_driveNext, o_data_128,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2, i_drive3,i_drive4;
input [63:0] i_data0_64, i_data1_64, i_data2_64, i_data3_64;
input [127:0] i_data4_128;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2, o_free3,o_free4;
output o_driveNext;
output [127:0] o_data_128;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire_1,w_forthFire_1,w_fifthFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig, w_forthTrig,w_fifthTrig;
wire w_firstReq,w_secondReq, w_thirdReq, w_forthReq,w_fifthReq;
wire w_driveNext0,w_driveNext1, w_driveNext2, w_driveNext3,w_driveNext4,w_driveNext;
wire [63:0] w_data0_64,w_data1_64, w_data2_64, w_data3_64;
wire [127:0] w_data4_128,w_data_128;
reg [63:0] r_data0_64,r_data1_64, r_data2_64, r_data3_64;
reg [127:0] r_data4_128,r_data_128;

wire w_free0,w_free1,w_free2,w_free3,w_free4;

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

(* dont_touch="true" *)delay1U outdelay3 (.inR(o_free2), .outR(w_free2), .rst(rst));
assign w_thirdTrig = i_drive2 | w_free2;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay4 (.inR(o_free3), .outR(w_free3), .rst(rst));
assign w_forthTrig = i_drive3 | w_free3;

contTap forthTap(
.trig(w_forthTrig),
.req(w_forthReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay5 (.inR(o_free4), .outR(w_free4), .rst(rst));
assign w_fifthTrig = i_drive4 | w_free4;

contTap fifthTap(
.trig(w_fifthTrig),
.req(w_fifthReq),
.rst(rst)
);

assign o_driveNext = i_drive0
				   | i_drive1
				   | i_drive2
				   | i_drive3
				   | i_drive4;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;
assign o_free2 = i_freeNext & w_thirdReq;
assign o_free3 = i_freeNext & w_forthReq;
assign o_free4 = i_freeNext & w_fifthReq;
assign w_data_128 = (w_firstReq == 1'b1) ? {{32{1'b0}},i_data0_64[63:32],{32{1'b0}},i_data0_64[31:0]} :
			((w_secondReq == 1'b1) ? {{32{1'b0}},i_data1_64[63:32],{32{1'b0}},i_data1_64[31:0]} : 
            ((w_thirdReq == 1'b1) ? {{32{1'b0}},i_data2_64[63:32],{32{1'b0}},i_data2_64[31:0]} : 
			((w_forthReq == 1'b1) ? {{32{1'b0}},i_data3_64[63:32],{32{1'b0}},i_data3_64[31:0]} : 
			((w_fifthReq == 1'b1) ? i_data4_128 : 128'b0))));
assign o_data_128 = w_data_128;

endmodule
