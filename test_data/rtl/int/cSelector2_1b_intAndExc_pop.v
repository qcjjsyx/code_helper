//-----------------------------------------------
//	module name: cSelector2_1b_intAndExc_pop
//	author: xing.yunpeng
//	version: 2024/12/23
//-----------------------------------------------
`timescale 1ns / 1ps

// 如果不传输数据，仅仅是为了区分事件去向，则sender,relay,receiver等可以去掉
// 实际就是将输入drive信号与valid信号进行与操作
module cSelector2_1b_intAndExc_pop(
i_drive, i_data, o_free,
o_driveNext0, i_freeNext0,
o_driveNext1, i_freeNext1, rst
);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input i_data;

output o_free;
output o_driveNext0,o_driveNext1;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_free_1;
wire w_freeNext;
wire w_driveNext0;

wire w_valid_1;

assign w_valid_1 = i_data;

// pipeline
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


//control signal
(* dont_touch="true" *)delay1Unit outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
(* dont_touch="true" *)delay1U outdelay0(.inR(w_fire), .outR(w_driveNext0), .rst(rst));
assign o_driveNext0 = w_driveNext0 & w_valid_1;
assign o_driveNext1 = w_driveNext0 & ~w_valid_1;
assign w_freeNext = i_freeNext0 | i_freeNext1;

// assign o_driveNext0 = i_drive & w_valid_1;
// assign o_driveNext1 = i_drive & ~w_valid_1;
// assign o_free = i_freeNext0 | i_freeNext1;

endmodule

