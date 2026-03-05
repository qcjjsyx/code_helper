`timescale 1ns / 1ps
//======================================================
// Project:     
// Module:      cSelSplitN_modName
// Author:      longtao zhang , zhuangzhuang Liao
// Mail：       whaiyi2024@lzu.edu.cn
// Date:        2025-05-28
// Description: 使用参数化定义的 SelSplit
//======================================================








//@cc: schema: cc_header_v1
//@cc: name: cSelSplit2_CPU2NOC_51
//@cc: family: SelSplit
//@cc: params:
//@cc:   NUM_PORTS: 2
//@cc:   DATA_WIDTH: 50
//@cc:   DELAY_IDRIVE: 7
//@cc:   DELAY_OFREE: 1
//@cc: roles:
//@cc:   upstream: [i_drive, o_free]
//@cc:   downstream: [o_drive0, o_drive1, i_free0, i_free1]
//@cc:   fire: []

module cSelSplit2_CPU2NOC_51 #(
    parameter NUM_PORTS    = 2,
    parameter DATA_WIDTH   = 50,
	parameter DELAY_IDRIVE = 7,  // i_drive - o_drive 上加的延时
	parameter DELAY_OFREE  = 1   // i_free - o_free 上加的延时
) (
    input [DATA_WIDTH + NUM_PORTS - 1:0] i_data,   // 高位为使用独热码编码的选择条件
    input                                i_drive,
    input                                i_free0, i_free1,

    output                  o_free,
    output                  o_drive0, o_drive1,
    output [DATA_WIDTH-1:0] o_data0, o_data1,
    input                   rstn
);

	wire [1:0] w_outRRelay_2,w_outARelay_2;
	wire       w_fire;
	wire       w_free_1;
	wire       w_freeNext;
	wire       w_driveNext;

	wire [NUM_PORTS - 1 : 0]  w_valid_n;
	wire [DATA_WIDTH - 1 : 0] w_data_n;

	// 截取高 NUM_PORTS 位选择数据、低 DATA_WIDTH 位数据
	assign w_valid_n = i_data[DATA_WIDTH + NUM_PORTS - 1 : DATA_WIDTH];   
	assign w_data_n  = i_data[DATA_WIDTH : 0];

	// 选择输出数据端口
	assign o_data0 = w_data_n & {DATA_WIDTH{w_valid_n[1]}};
	assign o_data1 = w_data_n & {DATA_WIDTH{w_valid_n[0]}};

	// drive 与 free 事件延时
	(* dont_touch="true" *)freeSetDelay #(
		.DELAY_UNIT_NUM ( DELAY_OFREE )
	) delay_ofree_donttouch (
		.i_pulse ( w_freeNext ),
		.o_pulse ( o_free ),
		.rstn     ( rstn )
	);

	(* dont_touch="true" *)freeSetDelay #(
		.DELAY_UNIT_NUM ( DELAY_IDRIVE )
	) delay_odrive_donttouch (
		.i_pulse ( i_drive ),
		.o_pulse ( w_driveNext ),
		.rstn     ( rstn )
	);

	assign o_drive0 = w_driveNext & w_valid_n[1];
	assign o_drive1 = w_driveNext & w_valid_n[0];

	assign w_freeNext = i_free0 | i_free1;
endmodule

