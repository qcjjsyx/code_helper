//===============================================================================
// Project:        RCA
// Module:         WaitMerge_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路融合;不带数据版;
//                 测试值：1ns左右可出去
//===============================================================================
`timescale 1ns / 1ps

module cWaitMerge_2_WB(
    // in0 -->
    (* dont_touch = "true" *)input       i_drive0    ,
    (* dont_touch = "true" *)output      o_free0     , 
    // in1 -->
    (* dont_touch = "true" *)input       i_drive1    ,
    (* dont_touch = "true" *)output      o_free1     ,
    // --> out
    (* dont_touch = "true" *)output      o_driveNext ,
    (* dont_touch = "true" *)input       i_freeNext  ,
    (* dont_touch = "true" *)input       rst
);

wire        w_firstTrig, w_secondTrig;
wire        w_firstReq , w_secondReq;
wire        w_free0    , w_free1;
wire        w_drive0   , w_drive1;
wire        w_d_andReq;

wire        w_allReqCome, w_outARelay, w_outRRelay, w_driveNext;

assign w_firstTrig = i_drive0 | i_freeNext;
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1 | i_freeNext;
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);

// 控制两个都到后通过延迟的方式产生o_drive，
assign w_allReqCome = w_firstReq & w_secondReq;
delay4U u_delay(
    .inR  ( w_allReqCome ),
    .rst  ( rst ),
    .outR ( w_d_andReq )
);

assign o_driveNext = w_allReqCome ^ w_d_andReq & w_secondReq & w_firstReq;

assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;

endmodule
