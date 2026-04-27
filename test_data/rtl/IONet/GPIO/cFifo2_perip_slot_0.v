//-----------------------------------------------
//	module name: cfifo
//	author: Tong Fu, Lingzhuang Zhang
//	version: 2st version (2023-03-09)
//-----------------------------------------------

`timescale 1ns / 1ps

module cFifo2_perip_slot_0(
input        rst,
input        i_drive,
output       o_free,
output       o_driveNext,
input        i_freeNext,
output [1:0] o_fire_2
);

wire [5:0] w_outRRelay_3,w_outARelay_3;
wire w_driveNext, w_outRTemp;

//pipeline
sender sender(
	.i_drive    (i_drive            ),
	.o_free     (o_free             ),
	.outR       (w_outRRelay_3[0]   ),
	.i_free     (w_driveNext        ),
	.rst        (rst                )
);

relay relay0(
	.inR        (w_outRRelay_3[0]   ),
	.inA        (w_outARelay_3[0]   ),
	.outR       (w_outRRelay_3[1]   ),
	.outA       (w_outARelay_3[1]   ),
	.fire       (o_fire_2[0]        ),
	.rst        (rst                )
);

delay32U delay1(.inR(w_outRRelay_3[1]), .outR(w_outRRelay_3[2]), .rst(rst));
delay32U delay2(.inR(w_outRRelay_3[2]), .outR(w_outRRelay_3[3]), .rst(rst));
delay32U delay3(.inR(w_outRRelay_3[3]), .outR(w_outRRelay_3[4]), .rst(rst));
delay32U delay4(.inR(w_outRRelay_3[4]), .outR(w_outRTemp), .rst(rst));

relay relay1(
	.inR        (w_outRTemp         ),
	.inA        (w_outARelay_3[1]   ),
	.outR       (w_outRRelay_3[5]   ),
	.outA       (w_outARelay_3[2]   ),
	.fire       (o_fire_2[1]        ),
	.rst        (rst                )
);

receiver receiver(
	.inR        (w_outRRelay_3[5]   ),
	.inA        (w_outARelay_3[2]   ),
	.i_freeNext (i_freeNext         ),
	.rst        (rst                )
);

delay2U outdelay0 (.inR(o_fire_2[1]), .outR(w_driveNext), .rst(rst));
delay2U outdelay1 (.inR(w_driveNext), .outR(o_driveNext), .rst(rst));
endmodule

