`timescale 1ns / 1ps

module cSelector2_12b_lsu(
i_drive, i_data_12, o_free,
o_driveNext0, i_freeNext0, o_data0_12,
o_driveNext1, o_data1_12, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [11:0] i_data_12;

output o_free;
output o_driveNext0,o_driveNext1;
output [11:0] o_data0_12;
output [11:0] o_data1_12;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_freeNext1;
wire w_driveNext0;
(* dont_touch="true" *)wire w_valid_1;
reg r_valid_1;
assign w_valid_1 = i_data_12[11] == 1'b1 ? 1'b0 : 1'b1;
reg [11:0] r_data0_12;


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
		r_data0_12 <= 12'b0;
		r_valid_1 <= 1'b0; 
	end else begin
		r_data0_12 <= i_data_12;
		r_valid_1 <= w_valid_1;
	end
end

assign o_data0_12 = r_data0_12 	& {12{~r_valid_1}};
assign o_data1_12 = r_data0_12 	& {12{r_valid_1}};


//control signal
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay6U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));

assign o_driveNext0 = w_driveNext0  & ~r_valid_1;    //0
assign o_driveNext1 = w_driveNext0  & r_valid_1;     //1
assign w_freeNext = i_freeNext0 | i_freeNext1;
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext1), .rst(rst));
endmodule


