

module cMutexMerge3_end_74b(
i_drive0, i_data0_74, o_free0,
i_drive1, i_data1_74, o_free1,
i_drive2, i_data2_74, o_free2,
i_freeNext, o_driveNext, o_data_74,
rst
);

//input & output port
input i_drive0, i_drive1, i_drive2;
input [73:0] i_data0_74, i_data1_74, i_data2_74;
input i_freeNext;
input rst;

output o_free0, o_free1, o_free2;
output o_driveNext;
output [73:0] o_data_74;


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_thirdFire2_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig, w_thirdTrig;
wire w_firstReq,w_secondReq, w_thirdReq;
wire w_driveNext0,w_driveNext1,w_driveNext, w_driveNext2;
wire w_free0,w_free1,w_free, w_free2;
wire [73:0] w_data0_74,w_data1_74,w_data_74, w_data2_74;
reg [73:0] r_data0_74,r_data1_74,r_data_74, r_data2_74;



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


assign w_thirdTrig = i_drive2 | o_free2;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

//sendFifo
cFifo1 sendFifo(
.i_drive(w_driveNext0),
.i_freeNext(i_freeNext),
.o_free(w_free),
.o_driveNext(w_driveNext1),
.o_fire_1(w_sendFire_1),
.rst(rst)
);

always@(posedge w_sendFire_1 or negedge rst)
begin
    if(!rst) begin
		r_data_74 <= 74'b0;
		end
	else begin
		r_data_74 <= w_data_74;
		end
end

delay8U Delay0(.inR(w_driveNext), .outR(w_driveNext0), .rst(rst)); 

delay8U Delay1(.inR(w_driveNext1), .outR(o_driveNext), .rst(rst)); 

assign w_driveNext = i_drive0 | i_drive1 | i_drive2;

assign o_free0 = w_free & w_firstReq;
assign o_free1 = w_free & w_secondReq;
assign o_free2 = w_free & w_thirdReq;
assign w_data_74 = (w_firstReq == 1'b1) ? i_data0_74 :
			((w_secondReq == 1'b1) ? i_data1_74 : 
            ((w_thirdReq == 1'b1) ? i_data2_74 : 74'b0));
assign o_data_74 = r_data_74;

endmodule
