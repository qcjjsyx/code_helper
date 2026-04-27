`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/11 21:23:39
// Design Name: 
// Module Name: cSelector6_36b
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


module cSelector5_36b_exe(
i_drive, i_data_36, o_free,
o_driveNext0, i_freeNext0, o_data0_32,
o_driveNext1, o_data1_32, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_32,
o_driveNext3, o_data3_32, i_freeNext3,
o_driveNext4, o_data4_32, i_freeNext4,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4;
input rst;
input [35:0] i_data_36;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4;
output [31:0] o_data0_32;
output [31:0] o_data1_32;
output [31:0] o_data2_32;
output [31:0] o_data3_32;
output [31:0] o_data4_32;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
wire [3:0] w_pathCode_4;
assign w_pathCode_4 = i_data_36[3:0];
(* dont_touch="true" *)wire [2:0] w_valid_3;
reg [2:0] r_valid_3;
assign w_valid_3 =w_pathCode_4== 4'b0000 ? 3'b000 :w_pathCode_4== 4'b0100 ? 3'b001 :w_pathCode_4== 4'b0110 ? 3'b010 :w_pathCode_4== 4'b0101 ? 3'b011 :w_pathCode_4== 4'b0111 ? 3'b100 : 3'b111;

reg [31:0] r_data0_32;


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
		r_data0_32 <= 119'b0;
		r_valid_3 <= 3'b0; 
	end else begin
		r_data0_32 <= i_data_36[35:4];
		r_valid_3 <= w_valid_3;
	end
end

assign o_data0_32 = r_data0_32 & {32{~r_valid_3[2]}} & {32{~r_valid_3[1]}} & {32{~r_valid_3[0]}};
assign o_data1_32 = r_data0_32 & {32{~r_valid_3[2]}} & {32{~r_valid_3[1]}} & {32{r_valid_3[0]}};
assign o_data2_32 = r_data0_32 & {32{~r_valid_3[2]}} & {32{r_valid_3[1]}} & {32{~r_valid_3[0]}};
assign o_data3_32 = r_data0_32 & {32{~r_valid_3[2]}} & {32{r_valid_3[1]}} & {32{r_valid_3[0]}};
assign o_data4_32 = r_data0_32 & {32{r_valid_3[2]}} & {32{~r_valid_3[1]}} & {32{~r_valid_3[0]}};

//control signal
(* dont_touch="true" *)delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay1U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];    //000
assign o_driveNext1 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & w_valid_3[0];     //001
assign o_driveNext2 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & ~w_valid_3[0];     //010
assign o_driveNext3 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & w_valid_3[0];      //011
assign o_driveNext4 = w_driveNext0 & w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];     //100
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));

endmodule


