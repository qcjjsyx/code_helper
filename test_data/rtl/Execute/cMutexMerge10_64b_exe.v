`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/09 22:09:44
// Design Name: 
// Module Name: cMutexMerge10_64b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module cMutexMerge10_64b_exe(
i_drive0, i_data0_64, o_free0,
i_drive1, i_data1_64, o_free1,
i_drive2, i_data2_64, o_free2,
i_drive3, i_data3_64, o_free3,
i_drive4, i_data4_64, o_free4,
i_drive5, i_data5_64, o_free5,
i_drive6, i_data6_64, o_free6,
i_drive7, i_data7_64, o_free7,
i_drive8, i_data8_64, o_free8,
i_drive9, i_data9_64, o_free9,
i_freeNext, o_driveNext, o_data_64,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2, i_drive3,i_drive4, i_drive5, i_drive6, i_drive7,i_drive8,i_drive9;
input [63:0] i_data0_64, i_data1_64, i_data2_64, i_data3_64,i_data4_64, i_data5_64, i_data6_64, i_data7_64,i_data8_64,i_data9_64;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2, o_free3,o_free4,o_free5, o_free6, o_free7,o_free8,o_free9;
output o_driveNext;
output [63:0] o_data_64;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire_1,w_forthFire_1,w_fifthFire_1,w_sixthFire_1,w_seventhFire_1,w_eighthFire_1,w_ninethFire_1,w_tenthFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig, w_forthTrig,w_fifthTrig,w_sixthTrig,w_seventhTrig, w_eighthTrig, w_ninethTrig,w_tenthTrig;
wire w_firstReq,w_secondReq, w_thirdReq, w_forthReq,w_fifthReq,w_sixthReq,w_seventhReq, w_eighthReq, w_ninethReq,w_tenthReq;
wire w_driveNext0,w_driveNext1, w_driveNext2, w_driveNext3,w_driveNext4,w_driveNext5,w_driveNext6, w_driveNext7, w_driveNext8,w_driveNext9,w_driveNext;
wire [63:0] w_data_64;
reg [63:0] r_data_64;

wire w_free0,w_free1,w_free2,w_free3,w_free4,w_free5,w_free6,w_free7,w_free8,w_free9;

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

(* dont_touch="true" *)delay1U outdelay6 (.inR(o_free5), .outR(w_free5), .rst(rst));
assign w_sixthTrig = i_drive5 | w_free5;

contTap sixthTap(
.trig(w_sixthTrig),
.req(w_sixthReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay7 (.inR(o_free6), .outR(w_free6), .rst(rst));
assign w_seventhTrig = i_drive6 | w_free6;

contTap seventhTap(
.trig(w_seventhTrig),
.req(w_seventhReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay8 (.inR(o_free7), .outR(w_free7), .rst(rst));
assign w_eighthTrig = i_drive7 | w_free7;

contTap eighthTap(
.trig(w_eighthTrig),
.req(w_eighthReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay9 (.inR(o_free8), .outR(w_free8), .rst(rst));
assign w_ninethTrig = i_drive8 | w_free8;

contTap ninethTap(
.trig(w_ninethTrig),
.req(w_ninethReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay10 (.inR(o_free9), .outR(w_free9), .rst(rst));
assign w_tenthTrig = i_drive9 | w_free9;

contTap tenthTap(
.trig(w_tenthTrig),
.req(w_tenthReq),
.rst(rst)
);

assign o_driveNext = i_drive0
				   | i_drive1
				   | i_drive2
				   | i_drive3
				   | i_drive4
				   | i_drive5
				   | i_drive6
				   | i_drive7
				   | i_drive8
				   | i_drive9;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;
assign o_free2 = i_freeNext & w_thirdReq;
assign o_free3 = i_freeNext & w_forthReq;
assign o_free4 = i_freeNext & w_fifthReq;
assign o_free5 = i_freeNext & w_sixthReq;
assign o_free6 = i_freeNext & w_seventhReq;
assign o_free7 = i_freeNext & w_eighthReq;
assign o_free8 = i_freeNext & w_ninethReq;
assign o_free9 = i_freeNext & w_tenthReq;
assign w_data_64 = (w_firstReq == 1'b1) ? i_data0_64 :
			((w_secondReq == 1'b1) ? i_data1_64 : 
            ((w_thirdReq == 1'b1) ? i_data2_64 : 
			((w_forthReq == 1'b1) ? i_data3_64 : 
			((w_fifthReq == 1'b1) ? i_data4_64 : 
			((w_sixthReq == 1'b1) ? i_data5_64 :
			((w_seventhReq == 1'b1) ? i_data6_64 :
			((w_eighthReq == 1'b1) ? i_data7_64 :
			((w_ninethReq == 1'b1) ? i_data8_64 :
			((w_tenthReq == 1'b1) ? i_data9_64 :0)))))))));
assign o_data_64 = w_data_64;

endmodule
