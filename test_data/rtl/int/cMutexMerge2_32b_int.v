

module cMutexMerge2_32b_int(
i_drive0, i_data0_32, o_free0,
i_drive1, i_data1_32, o_free1,
i_freeNext, o_driveNext, o_data_32,
rst
);

//input & output port
input i_drive0, i_drive1;
input [31:0] i_data0_32, i_data1_32;
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
output [31:0] o_data_32;


//wire & reg
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_free0,w_free1,w_free;
wire [31:0] w_data0_32,w_data1_32,w_data_32;




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
wire w_driveNextdelay;
assign w_driveNextdelay = i_drive0 & ~w_secondReq 
				   | i_drive1 & ~w_firstReq;
delay8U Delay0(.inR(w_driveNextdelay), .outR(o_driveNext), .rst(rst)); //延时打拍
assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;
assign w_data_32 = (w_firstReq == 1'b1) ? i_data0_32 :
			((w_secondReq == 1'b1) ? i_data1_32 : 32'b0);
assign o_data_32 = w_data_32;

endmodule
