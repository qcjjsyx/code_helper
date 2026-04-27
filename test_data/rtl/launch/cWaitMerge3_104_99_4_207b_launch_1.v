/*=============================================================
Project:ARMCPU
Module:cWaitMerge3
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cWaitMerge3 of launch
==============================================================*/


module cWaitMerge3_104_99_4_207b_launch(
i_drive0,i_data0_104,o_free0,
i_drive1,i_data1_99,o_free1,rst,
i_drive2,i_data2_4,o_free2,
o_driveNext,o_data_207,i_freeNext
);

//input & output port
input i_drive0,i_drive1,i_drive2;
input [103:0] i_data0_104;
input [98:0] i_data1_99;
input [3:0] i_data2_4;
input i_freeNext;
input rst;

output o_free0,o_free1,o_free2;
output o_driveNext;
output [206:0] o_data_207;

//wire & reg
wire w_drive0Next,w_drive1Next,w_drive2Next;
wire w_firstFire_1,w_secondFire_1,w_thirdFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig,w_thirdTrig;
wire w_firstReq,w_secondReq,w_thirdReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree,w_thirdFree;
wire [103:0] w_data0_104;
wire [98:0] w_data1_99;
wire [3:0] w_data2_4;

reg [103:0] r_data0_104;
reg [98:0] r_data1_99;
reg [3:0] r_data2_4;


//firstFifo
cFifo1 firstFifo(
.i_drive(i_drive0),
.i_freeNext(w_sendFree),
.o_free(),
.o_driveNext(w_drive0Next),
.o_fire_1(w_firstFire_1),
.rst(rst)
);

always@(posedge w_firstFire_1 or negedge rst)
begin
    if(!rst) begin
		r_data0_104 <= 104'b0;
		end
	else begin
		r_data0_104 <= i_data0_104;
		end
end
assign w_data0_104 = r_data0_104;
assign w_firstTrig = w_firstFire_1 | w_sendFree;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

//secondFifo
cFifo1 secondFifo(
.i_drive(i_drive1),
.i_freeNext(w_sendFree),
.o_free(),
.o_driveNext(w_drive1Next),
.o_fire_1(w_secondFire_1),
.rst(rst)
);

always@(posedge w_secondFire_1 or negedge rst)
begin
    if(!rst) begin
		r_data1_99 <= 99'b0;
		end
	else begin
		r_data1_99 <= i_data1_99;
		end
end
assign w_data1_99 = r_data1_99;
assign w_secondTrig = w_secondFire_1 | w_sendFree;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

//thirdFifo
cFifo1 thirdFifo(
.i_drive(i_drive2),
.i_freeNext(w_sendFree),
.o_free(),
.o_driveNext(w_drive2Next),
.o_fire_1(w_thirdFire_1),
.rst(rst)
);

always@(posedge w_thirdFire_1 or negedge rst)
begin
    if(!rst) begin
		r_data2_4 <= 2'b0;
		end
	else begin
		r_data2_4 <= i_data2_4;
		end
end
assign w_data2_4 = r_data2_4; 
assign w_thirdTrig = w_thirdFire_1 | w_sendFree;

contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

assign w_driveNext = w_drive0Next | w_drive1Next | w_drive2Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq & w_thirdReq;
assign w_sendFree = i_freeNext;
assign o_free0 = o_driveNext;
assign o_free1 = o_driveNext;
assign o_free2 = o_driveNext;
assign o_data_207 = {w_data2_4, w_data1_99, w_data0_104};
assign o_driveNext = w_sendDrive;

endmodule
