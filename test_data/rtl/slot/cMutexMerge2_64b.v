//-----------------------------------------------
//	module name: cMutexMerge2_64b
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-17)
//-----------------------------------------------

module cMutexMerge2_64b(
i_drive0,i_drive1,i_data0_64,i_data1_64,
i_freeNext,rst,
o_free0,o_free1,o_driveNext,o_data_64
);

//input & output port
input i_drive0,i_drive1;
input [63:0] i_data0_64,i_data1_64;
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
wire [63:0] w_data_64;
reg [63:0] r_data_64;

//firstFifo
cMergeFifo1 firstFifo
(
.i_drive(i_drive0),
.i_freeNext(w_free0),
.o_free(o_free0),
.o_driveNext(w_driveNext0),
.o_fire_1(w_firstFire_1),
.rst(rst)
);


assign w_firstTrig = w_firstFire_1 | w_free0;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

//secondFifo
cMergeFifo1 secondFifo(
.i_drive(i_drive1),
.i_freeNext(w_free1),
.o_free(o_free1),
.o_driveNext(w_driveNext1),
.o_fire_1(w_secondFire_1),
.rst(rst)
);

assign w_secondTrig = w_secondFire_1 | w_free1;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

//sendFifo
cMergeFifo1 sendFifo(
.i_drive(w_driveNext),
.i_freeNext(i_freeNext), 
.o_free(w_free),
.o_driveNext(o_driveNext),
.o_fire_1(w_sendFire_1),
.rst(rst)
);

wire w_fire2_1,w_fire3_1,w_fire4_1,w_fire5_1,w_fire6_1,w_fire7_1,w_fire8_1;

BUFM2HM buf0(.A(w_sendFire_1), .Z(w_fire2_1));
BUFM2HM buf1(.A(w_fire2_1), .Z(w_fire3_1));
BUFM2HM buf2(.A(w_fire3_1), .Z(w_fire4_1));
BUFM2HM buf3(.A(w_fire4_1), .Z(w_fire5_1));
BUFM2HM buf4(.A(w_fire5_1), .Z(w_fire6_1));
BUFM2HM buf5(.A(w_fire6_1), .Z(w_fire7_1));
BUFM2HM buf6(.A(w_fire7_1), .Z(w_fire8_1));

always@(posedge w_fire8_1 or negedge rst)
begin
    if(!rst) begin
		r_data_64 <= 64'b0;
		end
	else begin
		r_data_64 <= w_data_64;
		end
end

assign w_driveNext = w_driveNext0 | w_driveNext1;
assign w_free0 = w_free & w_firstReq;
assign w_free1 = w_free & w_secondReq;
assign w_data_64 = (w_firstReq == 1'b1) ? i_data0_64 :
			((w_secondReq == 1'b1) ? i_data1_64 : 64'b0);
assign o_data_64 = r_data_64;

endmodule
