//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    互斥融合;带数据版;对数据不做持久化保存；
//                 在控制链加入数据的模型中，mutex的实现逻辑是导致数据非持久化的原因
//                 测试值：1ns左右可出去
//===============================================================================
//! 收到i_free后再发o_free

`timescale 1ns / 1ps







//@cc: schema: cc_header_v1
//@cc: name: cMutexMerge_4_d_fetch
//@cc: family: MutexMerge
//@cc: params:
//@cc:   NUM_PORTS: 4
//@cc:   DATA_WIDTH: 81
//@cc: roles:
//@cc:   upstream: [i_drive0, i_drive1, i_drive2, i_drive3, o_free0, o_free1, o_free2, o_free3]
//@cc:   downstream: [o_driveNext, i_freeNext]
//@cc:   fire: []

module cMutexMerge_4_d_fetch#(
    parameter DATA_WIDTH = 81
)(
    // in0 -->
    (* dont_touch="true" *)input                    i_drive0    ,
    (* dont_touch="true" *)output                   o_free0     , 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data0     ,
    // in1 -->
    (* dont_touch="true" *)input                    i_drive1    ,
    (* dont_touch="true" *)output                   o_free1     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data1     ,

    (* dont_touch="true" *)input                    i_drive2    ,
    (* dont_touch="true" *)output                   o_free2     , 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data2     ,
    // in1 -->
    (* dont_touch="true" *)input                    i_drive3    ,
    (* dont_touch="true" *)output                   o_free3     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data3     ,
    // --> out
    (* dont_touch="true" *)output                   o_driveNext ,
    (* dont_touch="true" *)input                    i_freeNext  ,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0]  o_data      ,

    (* dont_touch="true" *)input                    rst
);

localparam N = 4;

(* dont_touch="true" *)wire [N-1:0] w_idrive;

(* dont_touch="true" *)wire [N-1:0] w_trig;
(* dont_touch="true" *)wire [N-1:0] w_req;
(* dont_touch="true" *)wire [N-1:0] w_free;
(* dont_touch="true" *)wire [N-1:0] w_free_delay;

assign w_idrive = {i_drive3, i_drive2, i_drive1, i_drive0};

genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : tap

        assign w_free[i] = i_freeNext & w_req[i];
        delay1U delayFree(.inR(w_free[i]), .outR(w_free_delay[i]), .rst(rst));

        assign w_trig[i] = w_idrive[i]&(~w_req[i]) | w_free_delay[i]&w_req[i];

        contTap u_tap (
            .trig   (w_trig[i]  ),
            .req    (w_req[i]   ),
            .rst    (rst        )
        );
    end
endgenerate


// 数据需要一定的时间被赋值，这里让o_drive出去前数据已经准备好
(* dont_touch="true" *)wire w_driveNext = |w_idrive;
freeSetDelay #(.N(30)) delay_out(.inR(w_driveNext), .outR(o_driveNext), .rst(rst));

assign o_free0 = w_free[0];
assign o_free1 = w_free[1];
assign o_free2 = w_free[2];
assign o_free3 = w_free[3];

assign o_data =  (w_req[0] == 1'b1) ? i_data0 :
		    	 (w_req[1] == 1'b1) ? i_data1 : 
                 (w_req[2] == 1'b1) ? i_data2 :
		    	 (w_req[3] == 1'b1) ? i_data3 : {DATA_WIDTH{1'b0}};

endmodule
