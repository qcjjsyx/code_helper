/*=============================================================
Project:ARMCPU
Module:cMutexMerge2_64b
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cMutexMerge2_64b of launch
==============================================================*/

`timescale 1ns / 1ps
module cMutexMerge2_64b_launch(
i_drive0, i_data0_64, o_free0,
i_drive1, i_data1_64, o_free1,
i_freeNext, o_driveNext, o_data_64,
rst
);

//input & output port
input i_drive0, i_drive1;
input [63:0] i_data0_64, i_data1_64;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [63:0] o_data_64;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext0,w_driveNext1,w_driveNext;
wire w_free0,w_free1,w_free;
wire [63:0] w_data0_64,w_data1_64,w_data_64 ;
// reg [63:0] r_data0_64,r_data1_64,r_data_64 ;



wire w_freeDelay0, w_freeDelay1;
delay2U outdelay0(.inR(o_free0), .outR(w_freeDelay0), .rst(rst));
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

assign o_driveNext = i_drive0 
				   | i_drive1 ;

assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;

assign w_data_64 = (w_firstReq == 1'b1) ? i_data0_64 :
			((w_secondReq == 1'b1) ? i_data1_64 : 64'b0);

assign o_data_64 = w_data_64;

endmodule
