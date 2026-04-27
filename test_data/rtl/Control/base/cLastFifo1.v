//-----------------------------------------------
//	module name: cLastFifo2
//	author: Tong Fu, Lingzhuang Zhang
//	version: 1st version (2022-11-15)
//-----------------------------------------------

`timescale 1ns / 1ps

module cLastFifo1(
    // reset signal
    input       rst     ,
    // in -->
    input       i_drive ,
    output      o_free  ,
    // --> out
    output      o_driveNext,
    output      o_fire_1
);

wire w_outRRelay_1,w_outARelay_1;
wire w_outR;
wire w_driveNext;
wire w_fire_1;

//pipeline
sender sender(
	.i_drive        ( i_drive       ),
	.o_free         ( o_free        ),
	.outR           ( w_outRRelay_1 ),
	.i_free         ( w_driveNext   ),
	.rst            ( rst           )
);

relay relay0(
	.inR            ( w_outRRelay_1 ),
	.inA            ( w_outARelay_1 ),
	.outR           ( w_outR        ),
	.outA           ( w_outR        ),
	.fire           ( w_fire_1      ),
	.rst            ( rst           )
);

assign o_fire_1 = w_fire_1;
delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext), .rst(rst));
delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));

endmodule

