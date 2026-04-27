//-----------------------------------------------
//	module name: cSplitter3_NoData_xyp
//	author: xing.yunpeng
//	version: 2025/1/2
//-----------------------------------------------
`timescale 1ns / 1ps

module cSplitter3_NoData_xyp(
i_drive, o_free,
o_driveNext0, i_freeNext0, 
o_driveNext1, i_freeNext1,
o_driveNext2, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
// input [15:0] i_data_16;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2;
// output [7:0] o_data0_8;
// output [7:0] o_data1_8;

// wire [1:0] w_outRRelay_2,w_outARelay_2;
// wire w_fire;
wire w_freeNext,w_free0Next,w_free1Next,w_free2Next;
// wire w_driveNext0;
wire w_sendFree;
wire w_sendDrive;
wire w_firstTrig, w_firstReq;
wire w_secondTrig, w_secondReq;
wire w_thirdTrig, w_thirdReq;
// reg [7:0] r_data0_8;
// reg [7:0] r_data1_8;

//pipeline
// sender sender(
// 	.i_drive(i_drive),
// 	.o_free(o_free),
// 	.outR(w_outRRelay_2[0]),
// 	.i_free(w_fire),
// 	.rst(rst)
// );

// relay relay0(
// 	.inR(w_outRRelay_2[0]),
// 	.inA(w_outARelay_2[0]),
// 	.outR(w_outRRelay_2[1]),
// 	.outA(w_outARelay_2[1]),
// 	.fire(w_fire)
// );

// receiver receiver(
// 	.inR(w_outRRelay_2[1]),
// 	.inA(w_outARelay_2[1]),
// 	.i_freeNext(w_freeNext)
// );

// always @(posedge w_fire or negedge rst) begin
// 	if (!rst) begin
// 		r_data0_8 <= 8'b0; 
// 		r_data1_8 <= 8'b0; 
// 	end else begin
// 		r_data0_8 <= i_data_16[7:0];
// 		r_data1_8 <= i_data_16[15:8];
// 	end
// end

// assign o_data0_8 = i_data_16[15:8];
// assign o_data1_8 = i_data_16[7:0];

//control signal
// delay2U outdelay0(.inR(w_fire), .outR(w_driveNext0));
// assign o_driveNext0 = i_drive;
// assign o_driveNext1 = i_drive;
// assign o_free = i_freeNext0 | i_freeNext1;

(* dont_touch="true" *)delay1Unit outdelay1 (.inR(i_freeNext0), .outR(w_free0Next), .rst(rst));

(* dont_touch="true" *)assign w_firstTrig = i_freeNext0 | w_sendDrive;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay1Unit outdelay2 (.inR(i_freeNext1), .outR(w_free1Next), .rst(rst));

(* dont_touch="true" *)assign w_secondTrig = i_freeNext1 | w_sendDrive;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

(* dont_touch="true" *)delay1Unit outdelay3 (.inR(i_freeNext2), .outR(w_free2Next), .rst(rst));

(* dont_touch="true" *)assign w_thirdTrig = i_freeNext2 | w_sendDrive;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
contTap thirdTap(
.trig(w_thirdTrig),
.req(w_thirdReq),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next | w_free2Next;
assign w_sendFree = w_freeNext & !(w_thirdReq | w_secondReq | w_firstReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
assign o_driveNext2 = i_drive;

endmodule

