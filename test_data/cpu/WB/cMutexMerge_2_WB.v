//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    二路互斥融合; 不带数据版
//===============================================================================
//! 收到i_free后再发o_free

`timescale 1ns / 1ps

module cMutexMerge_2_WB(
    // in0 -->
    (* dont_touch="true" *)input       i_drive0    ,
    (* dont_touch="true" *)output      o_free0     , 
    // in1 -->
    (* dont_touch="true" *)input       i_drive1    ,
    (* dont_touch="true" *)output      o_free1     ,
    // --> out
    (* dont_touch="true" *)output      o_driveNext ,
    (* dont_touch="true" *)input       i_freeNext  ,
    (* dont_touch="true" *)input       rst
);

(* dont_touch="true" *)wire        w_firstTrig, w_secondTrig;
(* dont_touch="true" *)wire        w_firstReq ,  w_secondReq;
(* dont_touch="true" *)wire        w_freeNext ;

assign w_firstTrig = i_drive0&(~w_firstReq) | w_freeNext&(w_firstReq);
contTap firstTap(
    .trig       ( w_firstTrig   ),
    .req        ( w_firstReq    ),
    .rst        ( rst           )
);

assign w_secondTrig = i_drive1&(~w_secondReq) | w_freeNext&(w_secondReq);
contTap secondTap(
    .trig       ( w_secondTrig  ),
    .req        ( w_secondReq   ),
    .rst        ( rst           )
);


assign o_driveNext = i_drive0 | i_drive1;

assign w_free0 = i_freeNext & w_firstReq;
assign w_free1 = i_freeNext & w_secondReq;
delay1U delay0 (.inR(i_freeNext), .outR(w_freeNext), .rst(rst));

assign o_free0 = w_free0;
assign o_free1 = w_free1;

endmodule
