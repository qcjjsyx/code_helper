
`timescale 1ns / 1ps

module cSelector2_181b_int(
i_drive, i_data_181, o_free,
o_driveNext0, i_freeNext0, o_data0_180,
o_driveNext1, o_data1_180, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [180:0] i_data_181;

output o_free;
output o_driveNext0,o_driveNext1;
output [179:0] o_data0_180;
output [179:0] o_data1_180;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;
// wire w_fire0, w_fire1;

wire w_valid_1;

assign w_valid_1 = i_data_181[180];

reg [179:0] r_data0_180;
reg r_valid_1;

// assign w_fire0 = w_fire & w_valid_1;
// assign w_fire1 = w_fire & ~w_valid_1;

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

always @(posedge w_fire or negedge rst) begin
	if (!rst) begin
		r_data0_180 <= 180'b0;
		r_valid_1 <= 1'b0; 
	end else begin
		r_data0_180 <= i_data_181[180:0];
		r_valid_1 <= w_valid_1;
	end
end

// always @(posedge w_fire1 or negedge rst) begin
// 	if (!rst) begin
// 		r_data1_1 <= 1'b0; 
// 	end else begin
// 		r_data1_1 <= 1'b0;
// 	end
// end

assign o_data0_180 = r_data0_180 & {180{r_valid_1}};
assign o_data1_180 = r_data0_180 & {180{~r_valid_1}};

//control signal
(* dont_touch="true" *)delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay8U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & r_valid_1;
assign o_driveNext1 = w_driveNext0 & ~r_valid_1;
assign w_freeNext = i_freeNext0 | i_freeNext1;


endmodule

