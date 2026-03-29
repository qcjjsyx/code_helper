`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  cPmtFifo1
// Author:  Tong Fu, Lingzhuang Zhang ,zhuangzhuang Liao
// Mail：   zhanglzh22@lzu.edu.cn
// Date:    2025-05-28
// Description: cPmtFifo1
//======================================================








//@cc: schema: cc_header_v1
//@cc: name: cPmtFifo1_modName
//@cc: family: PmtFifo1
//@cc: params:
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   upstream: [i_drive]
//@cc:   downstream: [o_driveNext]
//@cc:   fire: [o_fire_1]
//@cc: contract:
//@cc:   TODO: fill contract

module cPmtFifo1_modName(
	input i_drive,
	input i_freeNext, 
	output o_free,
	output o_driveNext,
	output o_fire_1,
	input rstn,
	input pmt
);

	// input  i_drive, i_freeNext;
	// output o_free, o_driveNext;
	// output o_fire_1;
	// input  rstn;
	// input  pmt;

	wire [2:0] w_outRRelay_3, w_outARelay_3;
	wire         w_driveNext;

	//pipeline
	(* dont_touch="true" *) sender sender(
		.i_drive (i_drive),
		.o_free  (o_free),
		.outR    (w_outRRelay_3[0]),
		.i_free  (w_driveNext),
		.rstn    (rstn)
	);

	(* dont_touch="true" *) pmtRelay pmtRelay0(
		.inR  (w_outRRelay_3[0]),
		.inA  (w_outARelay_3[0]),
		.outR (w_outRRelay_3[1]),
		.outA (w_outARelay_3[1]),
		.fire (),
		.pmt  (pmt),
		.rstn (rstn)
	);
	(* dont_touch="true" *) relay u_relay(
		.inR   (w_outRRelay_3[1]),
		.inA   (w_outARelay_3[1]),
		.outR  (w_outRRelay_3[2]),
		.outA  (w_outARelay_3[2]),
		.fire  (o_fire_1),
		.rstn  (rstn)
	);

	(* dont_touch="true" *) receiver receiver(
		.inR        (w_outRRelay_3[2]),
		.inA        (w_outARelay_3[2]),
		.i_free 	(i_freeNext),
		.rstn       (rstn)
	);

	(* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay0_donttouch (.i_pulse(o_fire_1), .o_pulse(w_driveNext), .rstn(rstn));
	(* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay1_donttouch (.i_pulse(w_driveNext), .o_pulse(o_driveNext), .rstn(rstn));


endmodule