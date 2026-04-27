
`timescale 1ns / 1ps

module cSelector4_2b(
i_drive, i_data_2, o_free,
o_driveNext0, i_freeNext0, o_data0_1,
o_driveNext1, o_data1_1, i_freeNext1,
o_driveNext2, i_freeNext2, o_data2_1,
o_driveNext3, o_data3_1, i_freeNext3,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3;
input rst;
input [1:0] i_data_2;

output o_free;
output o_driveNext0,o_driveNext1,o_driveNext2,o_driveNext3;
output o_data0_1;
output o_data1_1; 
output o_data2_1; 
output o_data3_1; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;

(* dont_touch="true" *) wire [1:0] w_valid_2;

assign w_valid_2 = i_data_2;

reg [23:0] r_data0_1;
reg [1:0] r_valid_2;


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
		r_valid_2 <= 2'b0;
	end else begin
		r_valid_2 <= w_valid_2;
	end
end

assign o_data0_1 = r_data0_1 & {1{~r_valid_2[1]}} & {1{~r_valid_2[0]}};
assign o_data1_1 = r_data0_1 & {1{~r_valid_2[1]}} & {1{r_valid_2[0]}};
assign o_data2_1 = r_data0_1 & {1{r_valid_2[1]}} & {1{~r_valid_2[0]}};
assign o_data3_1 = r_data0_1 & {1{r_valid_2[1]}} & {1{r_valid_2[0]}};

//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay4U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_2[1] & ~w_valid_2[0];      // 00
assign o_driveNext1 = w_driveNext0 & ~w_valid_2[1] & w_valid_2[0];      //01
assign o_driveNext2 = w_driveNext0 & w_valid_2[1] & ~w_valid_2[0];     //10
assign o_driveNext3 = w_driveNext0 & w_valid_2[1] & w_valid_2[0];      //11
assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule

