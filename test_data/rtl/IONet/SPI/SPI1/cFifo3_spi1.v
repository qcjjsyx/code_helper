//-----------------------------------------------
//	module name: cfifo3
//	author: Hiayi Wang
//	version: 1st version (2024-01-11)
//-----------------------------------------------
`timescale 1ns / 1ps

module cFifo3_spi1(
    // rst
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input           rst,
    // From Last
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input           i_drive, 
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output          o_free, 
    // To Next
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output          o_driveNext,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input           i_freeNext,
    // fire signal
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output  [2:0]   o_fire_3
);

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [3:0]  w_outRRelay_4,  w_outARelay_4;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        w_driveNext;

// Pipeline Stages
sender sender_inst(
    .i_drive(i_drive),
    .o_free(o_free),
    .outR(w_outRRelay_4[0]),
    .i_free(w_driveNext),
    .rst(rst)
);


relay relay0_inst(
    .inR(w_outRRelay_4[0]),
    .inA(w_outARelay_4[0]),
    .outR(w_outRRelay_4[1]),
    .outA(w_outARelay_4[1]),
    .fire(o_fire_3[0]),
	.rst(rst)
);

wire w_outRRelay_4_1_delay;
delay4U outdelay0_fire0 (.inR(w_outRRelay_4[1]), .outR(w_outRRelay_4_1_delay), .rst(rst));

relay relay1_inst(
    .inR(w_outRRelay_4_1_delay),
    .inA(w_outARelay_4[1]),
    .outR(w_outRRelay_4[2]),
    .outA(w_outARelay_4[2]),
    .fire(o_fire_3[1]),
	.rst(rst)
);

wire w_outRRelay_4_2_delay;
delay4U outdelay0_fire2 (.inR(w_outRRelay_4[2]), .outR(w_outRRelay_4_2_delay), .rst(rst));

relay relay2_inst(
    .inR(w_outRRelay_4_2_delay),
    .inA(w_outARelay_4[2]),
    .outR(w_outRRelay_4[3]),
    .outA(w_outARelay_4[3]),
    .fire(o_fire_3[2]),
	.rst(rst)
);

receiver receiver_inst(
    .inR(w_outRRelay_4[3]),
    .inA(w_outARelay_4[3]),
    .i_freeNext(i_freeNext),
	.rst(rst)
);

delay1U outdelay0_inst (.inR(o_fire_3[2]), .outR(w_driveNext), .rst(rst));
delay1U outdelay1_inst (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));

endmodule

