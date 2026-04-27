

`timescale 1ns / 1ps

module cSplitter2_51b(
i_drive, i_data_51, o_free,
o_driveNext0, i_freeNext0, o_data0_51,
o_driveNext1, o_data1_51, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [50:0]i_data_51;

output o_free;
output o_driveNext0,o_driveNext1;
output [50:0]o_data0_51;
output [50:0]o_data1_51;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext,w_free0Next,w_free1Next;
wire w_driveNext0;
wire w_sendFree;
wire w_sendDrive;
wire w_firstTrig, w_firstReq;
wire w_secondTrig, w_secondReq;

reg [50:0]r_data0_51;
reg [50:0]r_data1_51;


// always @(posedge w_fire or negedge rst) begin
// 	if (!rst) begin
// 		r_data0_1 <= 1'b0; 
// 		r_data1_1 <= 1'b0; 
// 	end else begin
// 		r_data0_1 <= i_data_1[31:0];
// 		r_data1_1 <= i_data_1[31:1];
// 	end
// end

assign o_data0_51 = i_data_51;
assign o_data1_51 = i_data_51;

(* dont_touch="true" *)delay1U outdelay1 (.inR(i_freeNext0), .outR(w_free0Next), .rst(rst));

assign w_firstTrig = i_freeNext0 | w_sendDrive;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay1U outdelay2 (.inR(i_freeNext1), .outR(w_free1Next), .rst(rst));

assign w_secondTrig = i_freeNext1 | w_sendDrive;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;

endmodule

