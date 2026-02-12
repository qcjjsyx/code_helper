//===============================================================================
// Project:        RCA
// Module:         WaitMerge_2_d
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路融合;带数据版;不对数据做持久化
//                 测试值：1ns给出去
//===============================================================================
//! 收到i_free后向前发送o_free

`timescale 1ns / 1ps


//@cc: schema: cc_header_v1
//@cc: name: cWaitMerge_2_d_fetch
//@cc: family: WaitMergeN
//@cc: params:
//@cc:   NUM_PORTS: 2
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   upstream: []
//@cc:   downstream: []
//@cc:   fire: []
//@cc: contract:
//@cc:   TODO: fill contract

module cWaitMerge_2_d_fetch
(    // in0 -->
    input                   i_drive0    ,
    output                  o_free0     , 
    input[255:0]            i_data0     ,
    // in1 -->
    input                   i_drive1    ,
    output                  o_free1     ,
    input[79:0]             i_data1     ,
    // --> out
    output                  o_driveNext ,
    input                   i_freeNext  ,
    output[335:0]           o_data      ,
    input                   rst
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

assign w_allReqCome = w_firstReq & w_secondReq;

// 控制两个都到后通过延迟的方式产生o_drive，
assign w_allReqCome = w_firstReq & w_secondReq;
delay4U u_delay(
    .inR  ( w_allReqCome ),
    .rst  ( rst ),
    .outR ( w_d_andReq )
);

assign o_driveNext = w_allReqCome ^ w_d_andReq & w_secondReq & w_firstReq;


assign o_data = {i_data1,i_data0};
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;

endmodule
