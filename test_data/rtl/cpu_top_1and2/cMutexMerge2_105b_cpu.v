`timescale 1ns / 1ps
module cMutexMerge2_105b_cpu(
i_drive0, i_data0_105, o_free0,
i_drive1, i_data1_105, o_free1,
i_freeNext, o_driveNext, o_data_105,
rst
);

//input & output port
input i_drive0, i_drive1;
input [104:0] i_data0_105, i_data1_105;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [104:0] o_data_105;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext0,w_driveNext1,w_driveNext;
wire w_free0,w_free1,w_free;
wire [104:0] w_data0_105,w_data1_105,w_data_105 ;
// reg [104:0] r_data0_105,r_data1_105,r_data_105 ;



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

assign w_data_105 = (w_firstReq == 1'b1) ? i_data0_105 :
			((w_secondReq == 1'b1) ? i_data1_105 : 105'b0);

assign o_data_105 = w_data_105;

endmodule
