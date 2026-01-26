`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  cFifo1
// Author:  Tong Fu, Lingzhuang Zhang
// Reviser: jinyu Yang
// Mail：   zhanglzh22@lzu.edu.cn
// Date:    2022-11-15
// Description: cFifo
//======================================================


module cFifo1_modName (
	i_drive,
	i_freeNext,
	o_free,
	o_driveNext,
	o_fire_1,
	rstn
);


	input  i_drive, i_freeNext;
	output o_free, o_driveNext;
	output o_fire_1;
	input  rstn;

	(* dont_touch="true" *) wire [1:0] w_outRRelay_2,w_outARelay_2;
	(* dont_touch="true" *) wire w_driveNext;

	// 发送-中继-接收
	(* dont_touch="true" *) sender sender(
		.i_drive (i_drive),
		.o_free  (o_free),
		.outR    (w_outRRelay_2[0]),
		.i_free  (w_driveNext),
		.rstn    (rstn)
	);

	(* dont_touch="true" *) relay relay0(
		.inR  (w_outRRelay_2[0]),
		.inA  (w_outARelay_2[0]),
		.outR (w_outRRelay_2[1]),
		.outA (w_outARelay_2[1]),
		.fire (o_fire_1),
		.rstn (rstn)
	);

	(* dont_touch="true" *) receiver receiver(
		.inR    (w_outRRelay_2[1]),
		.inA    (w_outARelay_2[1]),
		.i_free (i_freeNext),
		.rstn   (rstn)
	);

	(* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay0_donttouch (.i_pulse(o_fire_1), .o_pulse(w_driveNext), .rstn(rstn));
	(* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay1_donttouch (.i_pulse(w_driveNext), .o_pulse(o_driveNext), .rstn(rstn));

endmodule
