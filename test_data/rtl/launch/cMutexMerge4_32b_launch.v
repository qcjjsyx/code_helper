/*=============================================================
Project:ARMCPU
Module:cMutexMerge4_32b
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cMutexMerge4_32b of launch
==============================================================*/

module cMutexMerge4_32b_launch(
i_drive0, i_data0_32, o_free0,
i_drive1, i_data1_32, o_free1,
i_drive2, i_data2_32, o_free2,
i_drive3, i_data3_32, o_free3,
i_freeNext, o_driveNext, o_data_32,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2, i_drive3;
input [31:0] i_data0_32, i_data1_32, i_data2_32, i_data3_32;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2, o_free3;
output o_driveNext;
output [31:0] o_data_32;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire_1,w_forthFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig, w_forthTrig;
wire w_firstReq,w_secondReq, w_thirdReq, w_forthReq;
wire w_driveNext0,w_driveNext1,w_driveNext, w_driveNext2, w_driveNext3;
wire w_free0,w_free1,w_free, w_free2, w_free3;
wire [31:0] w_data0_32,w_data1_32,w_data_32, w_data2_32, w_data3_32;
reg [31:0] r_data0_32,r_data1_32,r_data_32, r_data2_32, r_data3_32;




wire w_freeDelay0, w_freeDelay1, w_freeDelay2, w_freeDelay3;
delay4U outdelay0(.inR(o_free0), .outR(w_freeDelay0), .rst(rst));
assign w_firstTrig = i_drive0 | w_freeDelay0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);




delay2U outdelay1(.inR(o_free1), .outR(w_freeDelay1), .rst(rst));
assign w_secondTrig = i_drive1 | w_freeDelay1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);



delay2U outdelay2(.inR(o_free2), .outR(w_freeDelay2), .rst(rst));
assign w_thirdTrig = i_drive2 | w_freeDelay2;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);


delay2U outdelay3(.inR(o_free3), .outR(w_freeDelay3), .rst(rst));
assign w_forthTrig = i_drive3 | w_freeDelay3;

contTap forthTap(
.trig(w_forthTrig),
.req(w_forthReq),
.rst(rst)
);



assign o_driveNext = i_drive0
				   | i_drive1
				   | i_drive2
				   | i_drive3;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;
assign o_free2 = i_freeNext & w_thirdReq;
assign o_free3 = i_freeNext & w_forthReq;
assign w_data_32 = (w_firstReq == 1'b1) ? i_data0_32 :
			((w_secondReq == 1'b1) ? i_data1_32 : 
            ((w_thirdReq == 1'b1) ? i_data2_32 : 
			((w_forthReq == 1'b1) ? i_data3_32 : 32'b0)));
assign o_data_32 = w_data_32;

endmodule
