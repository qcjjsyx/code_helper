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
//@cc: name: cSelSplitN_modName
//@cc: family: SelSplit
//@cc: params:
//@cc:   NUM_PORTS: <NUM_PORTS_PARAM_OR_LITERAL>
//@cc:   DATA_WIDTH: <DATA_WIDTH_PARAM_OR_LITERAL>
//@cc: roles:
//@cc:   reset: {port: rstn, active_low: true}
//@cc:   up:
//@cc:     drive: <i_drive_port_or_expr>
//@cc:     free:  <o_free_port_or_expr>
//@cc:   sel:
//@cc:     encoding: one_hot|binary|custom
//@cc:     source: <sel_port_or_expr_or_slice>   # 可与 payload 融合或分离
//@cc:   payload:
//@cc:     source: <payload_port_or_expr_or_slice>|none
//@cc:   channels:
//@cc:     - k: 0
//@cc:       drive: <o_drive0_port_or_expr>
//@cc:       free:  <i_free0_port_or_expr>
//@cc:       data:  <o_data0_port_or_expr>|none
//@cc:     - k: 1
//@cc:       drive: <o_drive1...>
//@cc:       free:  <i_free1...>
//@cc:       data:  <o_data1...>|none
//@cc: contract:
//@cc:   routing: select_one_channel_per_event
//@cc:   release: selected_only            # o_free 由被选中通道的 free 导出（若不是必须写 custom）
//@cc:   notes: ["Selection/payload may be fused or separated; only role mapping is invariant."]



module cSelSplitN_modName #(
    parameter NUM_PORTS    = 2,
    parameter DATA_WIDTH   = 32,
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
	assign o_data0 = w_data_n & {DATA_WIDTH{w_valid_n[0]}};
	assign o_data1 = w_data_n & {DATA_WIDTH{w_valid_n[1]}};

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

	assign o_drive0 = w_driveNext & w_valid_n[0];
	assign o_drive1 = w_driveNext & w_valid_n[1];

	assign w_freeNext = i_free0 | i_free1;
endmodule

