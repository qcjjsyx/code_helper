//======================================================
// Project:        RCA
// Module:         Fifo1
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    普通Fifo，加了一个delay1U通过
//======================================================
//! o_free在fire之后直接给

`timescale 1ns / 1ps





//@cc: schema: cc_header_v1
//@cc: name: cFifo1_cpu
//@cc: family: Fifo1
//@cc: params:
//@cc:   DATA_WIDTH: {TODO}
//@cc: roles:
//@cc:   upstream: [i_drive, o_free]
//@cc:   downstream: [o_driveNext, i_freeNext]
//@cc:   fire: [o_fire]

module cFifo1_cpu(
    // last -->
    (* dont_touch="true" *)input           i_drive,
    (* dont_touch="true" *)output          o_free,
    // --> next
    (* dont_touch="true" *)output          o_driveNext,
    (* dont_touch="true" *)input           i_freeNext,

    (* dont_touch="true" *)output          o_fire,
    // reset signal
    (* dont_touch="true" *)input           rst
);

(* dont_touch="true" *)wire [1:0] w_outRRelay_2,w_outARelay_2;
(* dont_touch="true" *)wire w_driveNext;
// pipeline
(* dont_touch="true" *)sender sender(
	.i_drive    ( i_drive           ),
	.o_free     ( o_free            ),
	.outR       ( w_outRRelay_2[0]  ),
	.i_free     ( w_driveNext       ),
	.rst        ( rst               )
);

(* dont_touch="true" *)wire w_relay0_delay;
(* dont_touch="true" *)delay11U relay0Delay (.inR(w_outRRelay_2[0]), .outR(w_relay0_delay), .rst(rst));

(* dont_touch="true" *)relay relay0(
	.inR        ( w_relay0_delay    ),
	.inA        ( w_outARelay_2[0]  ),
	.outR       ( w_outRRelay_2[1]  ),
	.outA       ( w_outARelay_2[1]  ),
	.fire       ( o_fire            ),
	.rst        ( rst               )
);

(* dont_touch="true" *)receiver receiver(
	.inR        ( w_outRRelay_2[1]  ),
	.inA        ( w_outARelay_2[1]  ),
	.i_freeNext ( i_freeNext        ),
	.rst        ( rst               )
);


(* dont_touch="true" *)delay1U delay2    (.inR(o_fire),      .outR(w_driveNext), .rst(rst));
(* dont_touch="true" *)delay1U outdelay0 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));

endmodule

