`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  cWaitMerge3
// Author:  zhuangzhuang Liao
// Mail?   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 3-input cWaitMerge
//======================================================




//@cc: schema: cc_header_v1
//@cc: name: cWaitMergeN_modName
//@cc: family: WaitMergeN
//@cc: params:
//@cc:   NUM_PORTS: TODO
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   TODO: fill roles; ports: i_data0, i_data1, i_data2, i_drive0, i_drive1, i_drive2, i_freeNext, o_data, o_driveNext, o_free0, o_free1, o_free2, rstn
//@cc:   upstream: []
//@cc:   downstream: []
//@cc:   fire:[]
//@cc: contract:
//@cc:   TODO: fill contract

module cWaitMergeN_modName #(
    parameter NUM_PORTS     = 3,
    parameter DATA_WIDTH_I0 = 1,
    parameter DATA_WIDTH_I1 = 3,
    parameter DATA_WIDTH_I2 = 3,
    parameter DATA_WIDTH_O  = 10
)(
    input wire i_drive0,i_drive1,i_drive2,
    input wire [DATA_WIDTH_I0-1:0] i_data0,
    input wire [DATA_WIDTH_I1-1:0] i_data1,
    input wire [DATA_WIDTH_I2-1:0] i_data2,
    input wire i_freeNext,

    output wire o_free0,o_free1,o_free2,
    output wire o_driveNext,
    output wire [DATA_WIDTH_O-1:0] o_data,

    input wire rstn

);

    // wire & reg
    wire [NUM_PORTS-1:0] w_trig_n;
    wire [NUM_PORTS-1:0] w_req_n;

    wire  w_driveNext;
    wire  w_andReq;
    wire  w_d_andReq;
    wire  w_sendDrive,w_sendFree;


    assign w_trig_n[0] = i_drive0&(~w_req_n[0]) | w_sendFree;
    contTap Tap0(
    .trig(w_trig_n[0]),
    .req(w_req_n[0]),
    .rstn(rstn)
    );

    assign w_trig_n[1] = i_drive1&(~w_req_n[1]) | w_sendFree;
    contTap Tap1(
    .trig(w_trig_n[1]),
    .req(w_req_n[1]),
    .rstn(rstn)
    );

    assign w_trig_n[2] = i_drive2&(~w_req_n[2]) | w_sendFree;
    contTap Tap2(
    .trig(w_trig_n[2]),
    .req(w_req_n[2]),
    .rstn(rstn)
    );

    assign w_andReq = & w_req_n;
    delay2U u_delay2U_donttouch(.inR(w_andReq), .outR(w_d_andReq), .rstn(rstn));
    assign w_driveNext = w_andReq ^ w_d_andReq;
    assign w_sendDrive = w_driveNext & w_andReq;
    assign w_sendFree  = i_freeNext;
    assign o_free0     = i_freeNext;
    assign o_free1     = i_freeNext;
    assign o_free2     = i_freeNext;

    /*****modify as you wish*****/
    assign o_data = {i_data2,i_data1,i_data0};
    /*************************/

    assign o_driveNext = w_sendDrive;

endmodule
