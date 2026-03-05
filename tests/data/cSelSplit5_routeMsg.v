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
//@cc: name: cSelSplit5_routeMsg
//@cc: family: SelSplit
//@cc: params:
//@cc:   NUM_PORTS: 5
//@cc:   DATA_WIDTH: 51
//@cc:   DELAY_IDRIVE: 7
//@cc:   DELAY_OFREE: 1
//@cc: roles:
//@cc:   upstream: [i_drive, o_free]
//@cc:   downstream: [o_drive0, o_drive1, o_drive2, o_drive3, o_drive4, i_free0, i_free1, i_free2, i_free3, i_free4]
//@cc:   fire: []

module cSelSplit5_routeMsg #(
    parameter NUM_PORTS    = 5,
    parameter DATA_WIDTH   = 51, // 数据宽度
	parameter DELAY_IDRIVE = 7,  // i_drive - o_drive 上加的延时
	parameter DELAY_OFREE  = 1   // i_free - o_free 上加的延时
) (
    input [DATA_WIDTH + NUM_PORTS - 1:0] i_data,   // 高位为使用独热码编码的选择条件
    input                                i_drive,
    input                                i_free0, i_free1,i_free2,i_free3,i_free4,

    output                  o_free,
    output                  o_drive0, o_drive1, o_drive2, o_drive3, o_drive4,
    output [DATA_WIDTH-1:0] o_data0, o_data1, o_data2, o_data3, o_data4,
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
	assign w_data_n  = i_data[DATA_WIDTH - 1 : 0];  // Corrected data width assignment

	// 选择输出数据端口
	assign o_data0 = w_data_n & {DATA_WIDTH{w_valid_n[0]}};
	assign o_data1 = w_data_n & {DATA_WIDTH{w_valid_n[1]}};
	assign o_data2 = w_data_n & {DATA_WIDTH{w_valid_n[2]}};
	assign o_data3 = w_data_n & {DATA_WIDTH{w_valid_n[3]}};
	assign o_data4 = w_data_n & {DATA_WIDTH{w_valid_n[4]}};

	// drive 与 free 事件延时
	freeSetDelay #(
		.DELAY_UNIT_NUM ( DELAY_OFREE )
	) delay_ofree_donttouch (
		.i_pulse ( w_freeNext ),
		.o_pulse ( o_free ),
		.rstn     ( rstn )
	);

	freeSetDelay #(
		.DELAY_UNIT_NUM ( DELAY_IDRIVE )
	) delay_odrive_donttouch (
		.i_pulse ( i_drive ),
		.o_pulse ( w_driveNext ),
		.rstn     ( rstn )
	);

	assign o_drive0 = w_driveNext & w_valid_n[0];
	assign o_drive1 = w_driveNext & w_valid_n[1];
	assign o_drive2 = w_driveNext & w_valid_n[2];
	assign o_drive3 = w_driveNext & w_valid_n[3];
	assign o_drive4 = w_driveNext & w_valid_n[4];
	assign w_freeNext = i_free0 | i_free1 | i_free2 | i_free3 | i_free4;
endmodule

