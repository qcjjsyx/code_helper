`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  cMutexMerge2
// Author:  longtao zhang,zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized two-input cMutexMerge
//======================================================


module cMutexMergeN_modName #(
    parameter DATA_WIDTH = 32
)(
    input                   i_drive0, i_drive1,
    input  [DATA_WIDTH-1:0] i_data0, i_data1,
    input                   i_freeNext,

    output                  o_free0,o_free1,
    output                  o_driveNext,
    output [DATA_WIDTH-1:0] o_data,

    input rstn

);

    wire                  w_firstTrig, w_secondTrig;
    wire                  w_firstReq, w_secondReq;
    wire                  w_firstFree,w_secondFree;
    wire                  w_drive;
    wire                  w_freeNext;
    wire                  w_linkbuf;
    wire [DATA_WIDTH-1:0] w_data;
    wire [1:0]            w_ofree_2;

    (* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay0_donttouch (.i_pulse(w_ofree_2[0]), .o_pulse(o_free0), .rstn(rstn));
    (* dont_touch="true" *) freeSetDelay #(.DELAY_UNIT_NUM(2)) outdelay1_donttouch (.i_pulse(w_ofree_2[1]), .o_pulse(o_free1), .rstn(rstn));

    assign w_firstTrig  = i_drive0 & (~w_firstReq)  | (w_ofree_2[0] & w_firstReq);
    assign w_secondTrig = i_drive1 & (~w_secondReq) | (w_ofree_2[1] & w_secondReq);

    contTap firstTap(
        .trig (w_firstTrig),
        .req  (w_firstReq),
        .rstn (rstn)
    );
    contTap secondTap(
        .trig (w_secondTrig),
        .req  (w_secondReq),
        .rstn (rstn)
    );

    assign w_drive = i_drive0 | i_drive1;

    freeSetDelay #(
        .DELAY_UNIT_NUM(4)
    ) u_driveDelay (
        .i_pulse (w_drive), 
        .o_pulse (o_driveNext), 
        .rstn    (rstn)
    );

    assign w_freeNext   = i_freeNext;
    assign w_firstFree  = w_freeNext & w_firstReq;
    assign w_secondFree =  w_freeNext & w_secondReq;

    (* dont_touch="true" *) freeSetDelay #(
        .DELAY_UNIT_NUM(2)
    ) u_freeDelay0_donttouch (
        .i_pulse (w_firstFree), 
        .o_pulse (w_ofree_2[0]), 
        .rstn    (rstn)
    );

    (* dont_touch="true" *) freeSetDelay #(
        .DELAY_UNIT_NUM(2)
    ) u_freeDelay1_donttouch (
        .i_pulse (w_secondFree), 
        .o_pulse (w_ofree_2[1]), 
        .rstn    (rstn)
    );

    assign w_data = (w_firstReq == 1'b1) ? i_data0 :
                    ((w_secondReq == 1'b1) ? i_data1 : {DATA_WIDTH{1'b0}});

    assign o_data = w_data;

endmodule
