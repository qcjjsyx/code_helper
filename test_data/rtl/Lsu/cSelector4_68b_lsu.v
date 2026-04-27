`timescale 1ns / 1ps

module cSelector4_68b_lsu(
i_drive, i_data_68, o_free,
o_driveNext0, i_freeNext0, o_data0_64,
o_driveNext1, o_data1_64, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_64,
o_driveNext3, o_data3_64, i_freeNext3,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3;
input rst;
input [67:0] i_data_68;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3;
output [63:0] o_data0_64;
output [63:0] o_data1_64;
output [63:0] o_data2_64;
output [63:0] o_data3_64;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext1;
wire w_freeNext;
wire w_driveNext0;
wire [3:0] w_pathCode_4;
assign w_pathCode_4 = i_data_68[3:0];
(* dont_touch="true" *)wire [1:0] w_valid_2;
reg [1:0] r_valid_2;
assign w_valid_2 =w_pathCode_4== 4'b1000 ? 2'b00 :w_pathCode_4== 4'b0100 ? 2'b01 : w_pathCode_4== 4'b0010 ? 2'b10 :w_pathCode_4== 4'b0001 ? 2'b11 : 2'b00;

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
		r_valid_2 <= 2'b0; 
	end else begin
		r_data0_64 <= i_data_68[67:4];
		r_valid_2 <= w_valid_2;
	end
end

assign o_data0_64 = r_data0_64 	& {64{~w_valid_2[1]}} & {64{~w_valid_2[0]}};
assign o_data1_64 = r_data0_64 	& {64{~w_valid_2[1]}} & {64{w_valid_2[0]}};
assign o_data2_64 = r_data0_64 	& {64{w_valid_2[1]}} & {64{~w_valid_2[0]}};
assign o_data3_64 = r_data0_64 	& {64{w_valid_2[1]}} & {64{w_valid_2[0]}};


//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay6U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_2[1] & ~w_valid_2[0];    //00
assign o_driveNext1 = w_driveNext0 & ~w_valid_2[1] & w_valid_2[0];     //01
assign o_driveNext2 = w_driveNext0 & w_valid_2[1] & ~w_valid_2[0];     //10
assign o_driveNext3 = w_driveNext0 & w_valid_2[1] & w_valid_2[0];      //11
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule


