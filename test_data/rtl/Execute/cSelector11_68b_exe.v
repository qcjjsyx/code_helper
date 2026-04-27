`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/13 23:58:34
// Design Name: 
// Module Name: cSelector11_68b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cSelector11_68b_exe(
i_drive, i_data_68, o_free,
o_driveNext0, i_freeNext0, o_data0_64,
o_driveNext1, o_data1_64, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_64,
o_driveNext3, o_data3_64, i_freeNext3,
o_driveNext4, o_data4_64, i_freeNext4,
o_driveNext5, o_data5_64, i_freeNext5,
o_driveNext6, o_data6_64, i_freeNext6,
o_driveNext7, o_data7_64, i_freeNext7,
o_driveNext8, o_data8_64, i_freeNext8,
o_driveNext9, o_data9_64, i_freeNext9,
o_driveNext10, o_data10_64, i_freeNext10,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,i_freeNext5,i_freeNext6,i_freeNext7,i_freeNext8,i_freeNext9,i_freeNext10;
input rst;
input [67:0] i_data_68;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4,o_driveNext5,o_driveNext6,o_driveNext7,o_driveNext8,o_driveNext9,o_driveNext10;
output [63:0] o_data0_64;
output [63:0] o_data1_64;
output [63:0] o_data2_64;
output [63:0] o_data3_64;
output [63:0] o_data4_64;
output [63:0] o_data5_64;
output [63:0] o_data6_64;
output [63:0] o_data7_64;
output [63:0] o_data8_64;
output [63:0] o_data9_64;
output [63:0] o_data10_64;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
wire [3:0] w_pathCode_4;
assign w_pathCode_4 = i_data_68[3:0];
(* dont_touch="true" *)wire [3:0] w_valid_4;
reg [3:0] r_valid_4 ;
assign w_valid_4 =w_pathCode_4== 4'b0000 ? 4'b0000 :w_pathCode_4== 4'b0001 ? 4'b0001 :w_pathCode_4== 4'b1001 ? 4'b0010 :w_pathCode_4== 4'b0100 ? 4'b0011 :w_pathCode_4== 4'b0110 ? 4'b0100 :w_pathCode_4== 4'b0101 ? 4'b0101 :
w_pathCode_4== 4'b0011 ? 4'b0110 :w_pathCode_4== 4'b1000 ? 4'b0111 :w_pathCode_4== 4'b1010 ? 4'b1000 :w_pathCode_4== 4'b0010 ? 4'b1001 :w_pathCode_4== 4'b1111 ? 4'b1010 : 4'b1111;

reg [63:0] r_data0_64;


//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(w_free_1),
	.outR(w_outRRelay_2[0]),
	.i_free(w_fire),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(w_freeNext1),
	.rst(rst)
);


always @(posedge w_fire or negedge rst) begin
	if (!rst) begin
		r_data0_64 <= 64'b0;
		r_valid_4 <= 4'b0; 
	end else begin
		r_data0_64 <= i_data_68[67:4];
		r_valid_4 <= w_valid_4;
	end
end

assign o_data0_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{~w_valid_4[0]}};
assign o_data1_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{w_valid_4[0]}};
assign o_data2_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{w_valid_4[1]}} & {64{~w_valid_4[0]}};
assign o_data3_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{w_valid_4[1]}} & {64{w_valid_4[0]}};
assign o_data4_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{~w_valid_4[0]}};
assign o_data5_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{w_valid_4[0]}};
assign o_data6_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{w_valid_4[2]}}& {64{w_valid_4[1]}} & {64{~w_valid_4[0]}};
assign o_data7_64 = r_data0_64 & {64{~w_valid_4[3]}} & {64{w_valid_4[2]}}& {64{w_valid_4[1]}} & {64{w_valid_4[0]}};
assign o_data8_64 = r_data0_64 & {64{w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{~w_valid_4[0]}};
assign o_data9_64 = r_data0_64 & {64{w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{~w_valid_4[1]}} & {64{w_valid_4[0]}};
assign o_data10_64 = r_data0_64& {64{w_valid_4[3]}} & {64{~w_valid_4[2]}}& {64{w_valid_4[1]}} & {64{~w_valid_4[0]}};

//control signal
(* dont_touch="true" *)delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay1U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_4[3] & ~w_valid_4[2] & ~w_valid_4[1] & ~w_valid_4[0];      // 0000
assign o_driveNext1 = w_driveNext0 & ~w_valid_4[3] & ~w_valid_4[2] & ~w_valid_4[1] & w_valid_4[0];      //0001
assign o_driveNext2 = w_driveNext0 & ~w_valid_4[3] & ~w_valid_4[2] & w_valid_4[1] & ~w_valid_4[0];     //0010
assign o_driveNext3 = w_driveNext0 & ~w_valid_4[3] & ~w_valid_4[2] & w_valid_4[1] & w_valid_4[0];      //0011
assign o_driveNext4 = w_driveNext0 & ~w_valid_4[3] & w_valid_4[2] & ~w_valid_4[1] & ~w_valid_4[0];      // 0100
assign o_driveNext5 = w_driveNext0 & ~w_valid_4[3] & w_valid_4[2] & ~w_valid_4[1] & w_valid_4[0];      //0101
assign o_driveNext6 = w_driveNext0 & ~w_valid_4[3] & w_valid_4[2] & w_valid_4[1] & ~w_valid_4[0];     //0110
assign o_driveNext7 = w_driveNext0 & ~w_valid_4[3] & w_valid_4[2] & w_valid_4[1] & w_valid_4[0];      //0111
assign o_driveNext8 = w_driveNext0 & w_valid_4[3] & ~w_valid_4[2] & ~w_valid_4[1] & ~w_valid_4[0];      //1000
assign o_driveNext9 = w_driveNext0 & w_valid_4[3] & ~w_valid_4[2] & ~w_valid_4[1] & w_valid_4[0];      //1001
assign o_driveNext10 = w_driveNext0 & w_valid_4[3] & ~w_valid_4[2] & w_valid_4[1] & ~w_valid_4[0];      //1010
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4 | i_freeNext5 | i_freeNext6 | i_freeNext7 |i_freeNext8 |i_freeNext9|i_freeNext10;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));

endmodule


