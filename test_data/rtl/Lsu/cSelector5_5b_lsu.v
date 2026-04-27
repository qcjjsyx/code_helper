`timescale 1ns / 1ps

module cSelector5_5b_lsu(
i_drive, i_data_5, o_free,
o_driveNext0, i_freeNext0, o_data0_5,
o_driveNext1, o_data1_5, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_5,
o_driveNext3, o_data3_5, i_freeNext3,
o_driveNext4, o_data4_5, i_freeNext4,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4;
input rst;
input [4:0] i_data_5;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3,o_driveNext4;
output [4:0] o_data0_5;
output [4:0] o_data1_5;
output [4:0] o_data2_5;
output [4:0] o_data3_5;
output [4:0] o_data4_5;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
(* dont_touch="true" *)wire [2:0] w_valid_3;
reg [2:0] r_valid_3 ;
assign w_valid_3 =i_data_5[0]==1? 3'b000 :
(i_data_5[2]==1 && i_data_5[1]==0 && i_data_5[0]==0) ? 3'b001 : 
(i_data_5[2]==0)? 3'b010 :
(i_data_5[4]==1 && i_data_5[2]==1 && i_data_5[1]==1 && i_data_5[0]==0) ? 3'b011 :
(i_data_5[3]==1 && i_data_5[2]==1 && i_data_5[1]==1 && i_data_5[0]==0) ? 3'b100 : 3'b000;

reg [4:0] r_data0_5;


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
		r_data0_5 <= 5'b0;
		r_valid_3 <= 3'b0; 
	end else begin
		r_data0_5 <= i_data_5;
		r_valid_3 <= w_valid_3;
	end
end

assign o_data0_5 = r_data0_5 & {5{~r_valid_3[2]}}& {5{~r_valid_3[1]}} & {5{~r_valid_3[0]}};
assign o_data1_5 = r_data0_5 & {5{~r_valid_3[2]}}& {5{~r_valid_3[1]}} & {5{r_valid_3[0]}};
assign o_data2_5 = r_data0_5 & {5{~r_valid_3[2]}}& {5{r_valid_3[1]}} & {5{~r_valid_3[0]}};
assign o_data3_5 = r_data0_5 & {5{~r_valid_3[2]}}& {5{r_valid_3[1]}} & {5{r_valid_3[0]}};
assign o_data4_5 = r_data0_5 & {5{r_valid_3[2]}}& {5{~r_valid_3[1]}} & {5{~r_valid_3[0]}};

//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay4U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];    //000
assign o_driveNext1 = w_driveNext0 & ~w_valid_3[2] & ~w_valid_3[1] & w_valid_3[0];     //001
assign o_driveNext2 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & ~w_valid_3[0];     //010
assign o_driveNext3 = w_driveNext0 & ~w_valid_3[2] & w_valid_3[1] & w_valid_3[0];      //011
assign o_driveNext4 = w_driveNext0 & w_valid_3[2] & ~w_valid_3[1] & ~w_valid_3[0];     //100
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule


