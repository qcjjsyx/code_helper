
`timescale 1ns / 1ps

module cSelector3_66b_int(
i_drive, i_data_66, o_free,
o_driveNext0, i_freeNext0, o_data0_64,
o_driveNext1, o_data1_64, i_freeNext1,
o_driveNext2, o_data2_64, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
input [65:0] i_data_66;

output o_free;
output o_driveNext0,o_driveNext1, o_driveNext2;
output [63:0] o_data0_64;
output [63:0] o_data1_64; 
output [63:0] o_data2_64; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_fire0, w_fire1, w_fire2;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;

wire w_valid_1;
wire w_valid1_1;
reg r_valid_1;
reg r_valid1_1;

assign w_valid_1 = i_data_66[65];
assign w_valid1_1 = i_data_66[64];

assign w_fire0 = w_fire & ~w_valid_1 & ~w_valid1_1;
assign w_fire1 = w_fire & ~w_valid_1 & w_valid1_1;
assign w_fire2 = w_fire & w_valid_1 & ~w_valid1_1;


reg [63:0] r_data0_64;
reg [63:0] r_data1_64;
reg [63:0] r_data2_64;

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
	.i_freeNext(w_freeNext),
        .rst(rst)
);

always @(posedge w_fire0 or negedge rst) begin
	if (!rst) begin
		r_data0_64 <= 64'b0;
	end else begin
		r_data0_64 <= i_data_66[63:0];
	end
end

always @(posedge w_fire1 or negedge rst) begin
	if (!rst) begin
		r_data1_64 <= 64'b0;
	end else begin
		r_data1_64 <= i_data_66[63:0];
	end
end

always @(posedge w_fire2 or negedge rst) begin
	if (!rst) begin
		r_data2_64 <= 64'b0;
	end else begin
		r_data2_64 <= i_data_66[63:0];
	end
end

assign o_data0_64 = r_data0_64;
assign o_data1_64 = r_data1_64;
assign o_data2_64 = r_data2_64;

//control signal
(* dont_touch="true" *)delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay1U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_1 & ~w_valid1_1;
assign o_driveNext1 = w_driveNext0 & ~w_valid_1 & w_valid1_1;
assign o_driveNext2 = w_driveNext0 & w_valid_1 & ~w_valid1_1;
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2;

endmodule

