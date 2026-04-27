//-----------------------------------------------
//	module name: cSelector2_73b_intAndExc_pop
//	author: xing.yunpeng
//	version: 2024/12/23
//-----------------------------------------------
`timescale 1ns / 1ps

module cSelector2_73b_intAndExc_pop(
i_drive, i_data_73, o_free,
o_driveNext0, i_freeNext0, o_data0_72,
o_driveNext1, o_data1_32, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [72:0] i_data_73;

output o_free;
output o_driveNext0,o_driveNext1;
output [71:0] o_data0_72;
output [31:0] o_data1_32; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;
wire w_fire0, w_fire1;

wire w_valid_1;

assign w_valid_1 = i_data_73[72];

reg [71:0] r_data0_72;
reg [31:0] r_data1_32;
reg r_valid_1;

//pipeline
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
sender sender(
	.i_drive(i_drive),
	.o_free(w_free_1),
	.outR(w_outRRelay_2[0]),
	.i_free(w_fire),
	.rst(rst)
);

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire),
	.rst(rst)
);

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(w_freeNext),
	.rst(rst)
);

always @(posedge w_fire or negedge rst) begin
	if (!rst) begin
		r_data0_72 <= 72'b0; 
        r_data1_32 <= 32'b0; 
        r_valid_1  <= 1'b0;
	end else begin
		r_data0_72 <= i_data_73[71:0];
        r_data1_32 <= i_data_73[31:0];
        r_valid_1  <= w_valid_1;
	end
end

assign o_data0_72 = (r_valid_1 == 1'b1)? r_data0_72: 72'b0;
assign o_data1_32 = (r_valid_1 == 1'b0)? r_data1_32: 32'b0;

//control signal
(* dont_touch="true" *)delay1Unit outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
(* dont_touch="true" *)delay2U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));

assign o_driveNext0 = w_driveNext0 & r_valid_1;
assign o_driveNext1 = w_driveNext0 & ~r_valid_1;
assign w_freeNext = i_freeNext0 | i_freeNext1;

endmodule

