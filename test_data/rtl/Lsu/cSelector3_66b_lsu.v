`timescale 1ns / 1ps

module cSelector3_66b_lsu(
i_drive, i_data_66, o_free,
o_driveNext0, i_freeNext0, o_data0_64,
o_driveNext1, o_data1_64, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_64,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
input [65:0] i_data_66;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2;
output [63:0] o_data0_64;
output [63:0] o_data1_64;
output [63:0] o_data2_64;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext1; 
wire w_freeNext; 
wire w_driveNext0;
(* dont_touch="true" *)wire [1:0] w_valid_2;
reg [1:0] r_valid_2;
assign w_valid_2 =i_data_66[1:0]== 2'b01 ? 2'b00 :i_data_66[0]== 1'b0 ? 2'b01 : 2'b10;

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
		r_data0_64 <= i_data_66[65:2];
		r_valid_2 <= w_valid_2;
	end
end

assign o_data0_64 = r_data0_64 	& {64{~r_valid_2[1]}} & {64{~r_valid_2[0]}};
assign o_data1_64 = r_data0_64 	& {64{~r_valid_2[1]}} & {64{r_valid_2[0]}};
assign o_data2_64 = r_data0_64 	& {64{r_valid_2[1]}} & {64{~r_valid_2[0]}};


//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay4U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_2[1] & ~w_valid_2[0];    //00
assign o_driveNext1 = w_driveNext0 & ~w_valid_2[1] & w_valid_2[0];     //01
assign o_driveNext2 = w_driveNext0 & w_valid_2[1] & ~w_valid_2[0];     //10
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule


