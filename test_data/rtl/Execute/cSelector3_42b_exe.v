
`timescale 1ns / 1ps

module cSelector3_42b_exe(
i_drive, i_data_42, o_free,
o_driveNext0, i_freeNext0, o_data0_8,
o_driveNext1, o_data1_32, i_freeNext1,
o_driveNext2, o_data2_32, i_freeNext2,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2;
input rst;
input [41:0] i_data_42;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2;
output [7:0] o_data0_8;
output [31:0] o_data1_32; 
output [31:0] o_data2_32;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;

reg [7:0] r_data0_8;
reg [31:0] r_data1_32;
reg [31:0] r_data2_32;

(* dont_touch="true" *)wire[1:0] w_valid_2;
reg [1:0] r_valid_2;
wire w_grfFlag_1;
wire w_op3Flag_1;
assign w_grfFlag_1 = i_data_42[40];
assign w_op3Flag_1 = i_data_42[41];
assign w_valid_2 = w_grfFlag_1 == 1'b1 ? 2'b00 : w_op3Flag_1 == 1'b1 ? 2'b01 : 2'b10;


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
		r_data0_8 <= 8'b0; 
		r_data1_32 <= 32'b0; 
		r_data2_32 <= 32'b0; 
		r_valid_2 <= 2'b0;
	end else begin
		r_data0_8 <= i_data_42[7:0];
		r_data1_32 <= i_data_42[39:8];
		r_data2_32 <= i_data_42[39:8];
		r_valid_2 <= w_valid_2;
	end
end

assign o_data0_8 = r_data0_8  & {8{~r_valid_2[1]}} & {8{~r_valid_2[0]}};
assign o_data1_32 = r_data1_32 & {32{~r_valid_2[1]}} & {32{r_valid_2[0]}};
assign o_data2_32 = r_data2_32 & {32{r_valid_2[1]}} & {32{~r_valid_2[0]}};

//control signal
(* dont_touch="true" *)delay1U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay3U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_2[1] & ~w_valid_2[0];//00
assign o_driveNext1 = w_driveNext0 & ~w_valid_2[1] & w_valid_2[0];//01
assign o_driveNext2 = w_driveNext0 & w_valid_2[1] & ~w_valid_2[0];//10
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));

endmodule

