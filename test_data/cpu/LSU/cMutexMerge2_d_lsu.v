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

module cMutexMerge2_d_lsu#(
    parameter DATA_WIDTH = 128
)(
    // in0 -->
    (* dont_touch="true" *)input                    i_drive0    ,
    (* dont_touch="true" *)output                   o_free0     , 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data0     ,
    // in1 -->
    (* dont_touch="true" *)input                    i_drive1    ,
    (* dont_touch="true" *)output                   o_free1     ,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0]  i_data1     ,
    // --> out
    (* dont_touch="true" *)output                   o_driveNext ,
    (* dont_touch="true" *)input                    i_freeNext  ,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0]  o_data      ,

    (* dont_touch="true" *)input                    rst
);

(* dont_touch="true" *)wire        w_firstTrig      , w_secondTrig  ;
(* dont_touch="true" *)wire        w_firstReq       , w_secondReq   ;
(* dont_touch="true" *)wire        w_free0          , w_free1       ;
(* dont_touch="true" *)wire        w_free0_delay    , w_free1_delay ;

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;

(* dont_touch="true" *)delay1U delay0(.inR(w_free0), .outR(w_free0_delay), .rst(rst));
assign w_firstTrig = i_drive0&(~w_firstReq) | w_free0_delay&(w_firstReq);

(* dont_touch="true" *)contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

(* dont_touch="true" *)delay1U delay1(.inR(w_free1), .outR(w_free1_delay), .rst(rst));
assign w_secondTrig = i_drive1&(~w_secondReq) | w_free1_delay&(w_secondReq);

(* dont_touch="true" *)contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

// 数据需要一定的时间被赋值，这里让o_drive出去前数据已经准备好
(* dont_touch="true" *)wire w_driveNext = i_drive0 | i_drive1;
(* dont_touch="true" *)freeSetDelay_lsu #(.DELAY_NUM(15),.DELAY_WIDTH(8)) delay_out(.inR(w_driveNext), .outR(o_driveNext), .rst(rst));


assign o_free0 = w_free0;
assign o_free1 = w_free1;

assign o_data =  (w_firstReq ) ? i_data0 :
		    	 (w_secondReq) ? i_data1 : {DATA_WIDTH{1'b0}};

endmodule
