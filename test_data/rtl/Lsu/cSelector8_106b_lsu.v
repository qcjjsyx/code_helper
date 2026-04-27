`timescale 1ns / 1ps

module cSelector8_106b_lsu(
i_drive, i_data_106, o_free,
o_driveNext0, i_freeNext0, o_data0_98,
o_driveNext1, o_data1_98, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_98,
o_driveNext3, o_data3_98, i_freeNext3,
o_driveNext4, o_data4_98, i_freeNext4,
o_driveNext5, o_data5_98, i_freeNext5,
o_driveNext6, o_data6_98, i_freeNext6,
o_driveNext7, o_data7_98, i_freeNext7,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,i_freeNext5,i_freeNext6,i_freeNext7;
input rst;
input [105:0] i_data_106;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4,o_driveNext5,o_driveNext6,o_driveNext7;
output [97:0] o_data0_98;
output [97:0] o_data1_98;
output [97:0] o_data2_98;
output [97:0] o_data3_98;
output [97:0] o_data4_98;
output [97:0] o_data5_98;
output [97:0] o_data6_98;
output [97:0] o_data7_98;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
wire [7:0] w_pathCode_8;
assign w_pathCode_8 = i_data_106[7:0];
(* dont_touch="true" *)wire [2:0] w_valid_3;
reg [2:0] r_valid_3 ;
assign w_valid_3 =w_pathCode_8== 8'b1000_0000 ? 3'b000 :w_pathCode_8== 8'b0100_0000 ? 3'b001 : w_pathCode_8== 8'b0010_0000 ? 3'b010 :w_pathCode_8== 8'b0001_0000 ? 3'b011 :w_pathCode_8== 8'b0000_1000 ? 3'b100 :w_pathCode_8== 8'b0000_0100 ? 3'b101 :
w_pathCode_8== 8'b0000_0010 ? 3'b110 :w_pathCode_8== 8'b0000_0001 ? 3'b111 : 3'b000;

reg [97:0] r_data0_98;


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
		r_data0_98 <= 98'b0;
		r_valid_3 <= 3'b0; 
	end else begin
		r_data0_98 <= i_data_106[105:8];
		r_valid_3 <= w_valid_3;
	end
end

assign o_data0_98 = r_data0_98 	& {98{~r_valid_3[2]}}& {98{~r_valid_3[1]}} & {98{~r_valid_3[0]}};
assign o_data1_98 = r_data0_98 	& {98{~r_valid_3[2]}}& {98{~r_valid_3[1]}} & {98{r_valid_3[0]}};
assign o_data2_98 = r_data0_98 	& {98{~r_valid_3[2]}}& {98{r_valid_3[1]}} & {98{~r_valid_3[0]}};
assign o_data3_98 = r_data0_98 	& {98{~r_valid_3[2]}}& {98{r_valid_3[1]}} & {98{r_valid_3[0]}};
assign o_data4_98 = r_data0_98 	& {98{r_valid_3[2]}}& {98{~r_valid_3[1]}} & {98{~r_valid_3[0]}};
assign o_data5_98 = r_data0_98 	& {98{r_valid_3[2]}}& {98{~r_valid_3[1]}} & {98{r_valid_3[0]}};
assign o_data6_98 = r_data0_98 	& {98{r_valid_3[2]}}& {98{r_valid_3[1]}} & {98{~r_valid_3[0]}};
assign o_data7_98 = r_data0_98 	& {98{r_valid_3[2]}}& {98{r_valid_3[1]}} & {98{r_valid_3[0]}};

//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay4U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];    //000
assign o_driveNext1 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & w_valid_3[0];     //001
assign o_driveNext2 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & ~w_valid_3[0];     //010
assign o_driveNext3 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & w_valid_3[0];      //011
assign o_driveNext4 = w_driveNext0 & w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];     //100
assign o_driveNext5 = w_driveNext0 & w_valid_3[2] & ~w_valid_3[1] & w_valid_3[0];      //101
assign o_driveNext6 = w_driveNext0 & w_valid_3[2] & w_valid_3[1] & ~w_valid_3[0];      //110
assign o_driveNext7 = w_driveNext0 & w_valid_3[2] & w_valid_3[1] & w_valid_3[0];       //111
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4 | i_freeNext5 | i_freeNext6 | i_freeNext7;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule


