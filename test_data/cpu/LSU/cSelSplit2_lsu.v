//===============================================================================
// Project:        RCA
// Module:         SelSplit_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    有条件分支;不带数据版;把数据和控制位分开;
//                 测试值：1ns即可传递
//===============================================================================
`timescale 1ns / 1ps

module cSelSplit2_lsu
    (
    (* dont_touch="true" *)input  i_drive,
    (* dont_touch="true" *)input  i_freeNext0,i_freeNext1,

    (* dont_touch="true" *)input  valid0,
    (* dont_touch="true" *)input  valid1,

    (* dont_touch="true" *)output o_free,
    (* dont_touch="true" *)output o_driveNext0,o_driveNext1,

    (* dont_touch="true" *)input  rst
);



(* dont_touch="true" *)wire [1:0] w_outRRelay_2, w_outARelay_2;
(* dont_touch="true" *)wire w_freeNext, w_fire;

    assign w_freeNext   = i_freeNext0 | i_freeNext1;
    assign o_driveNext0 = w_fire & valid0;
    assign o_driveNext1 = w_fire & valid1;

    (* dont_touch="true" *)sender sender (
        .i_drive    (i_drive            ),
        .o_free     (o_free             ),  // sender的o_free是收到i_free后才发的
        .outR       (w_outRRelay_2[0]   ),
        .i_free     (w_freeNext         ),
        .rst        (rst                )
    );

    (* dont_touch="true" *)relay relay (
        .inR        (w_outRRelay_2[0]  ),
        .inA        (w_outARelay_2[0]  ),
        .outR       (w_outRRelay_2[1]  ),
        .outA       (w_outARelay_2[1]  ),
        .fire       (w_fire            ),
        .rst        (rst               )
    );

    (* dont_touch="true" *)receiver receiver (
        .inR        (w_outRRelay_2[1]),
        .inA        (w_outARelay_2[1]),
        .i_freeNext (w_freeNext      ),
        .rst        (rst             )
    );

endmodule
