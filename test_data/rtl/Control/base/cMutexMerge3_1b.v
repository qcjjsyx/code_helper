

module cMutexMerge3_1b(
i_drive0, i_data0_1, o_free0,
i_drive1, i_data1_1, o_free1,
i_drive2, i_data2_1, o_free2,
i_freeNext, o_driveNext, o_data_1,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2;
input i_data0_1, i_data1_1, i_data2_1;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2;
output o_driveNext;
output o_data_1;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire2_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig;
wire w_firstReq,w_secondReq, w_thirdReq;
wire w_driveNext0,w_driveNext1,w_driveNext, w_driveNext2;
wire w_free0,w_free1,w_free, w_free2;
wire w_data0_1,w_data1_1,w_data_1, w_data2_1;
reg r_data0_1,r_data1_1,r_data_1, r_data2_1;



assign w_firstTrig = i_drive0 | w_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);




assign w_secondTrig = i_drive1 | w_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);



assign w_thirdTrig = i_drive2 | w_free2;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

wire i_freeNext_delay;
delay2U delay(.inR(i_freeNext), .outR(i_freeNext_delay), .rst(rst));

delay2U ofree_delay0(.inR(o_free0), .outR(w_free0), .rst(rst));
delay2U ofree_delay1(.inR(o_free1), .outR(w_free1), .rst(rst));
delay2U ofree_delay2(.inR(o_free1), .outR(w_free2), .rst(rst));

assign o_driveNext = i_drive0 & ~w_secondReq & ~w_thirdReq 
				   | i_drive1 & ~w_firstReq & ~w_thirdReq 
				   | i_drive2 & ~w_secondReq & ~w_firstReq;

assign o_free0 = i_freeNext_delay & w_firstReq;
assign o_free1 = i_freeNext_delay & w_secondReq;
assign o_free2 = i_freeNext_delay & w_thirdReq;
assign w_data_1 = (w_firstReq == 1'b1) ? i_data0_1 :
			((w_secondReq == 1'b1) ? i_data1_1 : 
            ((w_thirdReq == 1'b1) ? i_data2_1 : 1'b0));
assign o_data_1 = w_data_1;

endmodule
