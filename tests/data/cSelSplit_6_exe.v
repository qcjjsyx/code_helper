//===============================================================================
// Project:        RCA
// Module:         SelSplit_5
// Author:         YiHua Lu
// Date:           2025/07/20
// Description:    有条件分支; 不带数据版; 把数据和控制位分开;
//                 支持5路输出控制链，测试值：1ns即可传递
//===============================================================================
`timescale 1ns / 1ps


//@cc: schema: cc_header_v1
//@cc: name: cSelSplit_6_exe
//@cc: family: SelSplit
//@cc: params:
//@cc:   NUM_PORTS: 6
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   upstream: []
//@cc:   downstream: []
//@cc:   fire: []
//@cc: contract:
//@cc:   TODO: fill contract

module cSelSplit_6_exe (
    input  wire i_drive,
    input  wire i_freeNext0, i_freeNext1, i_freeNext2, i_freeNext3,
                i_freeNext4, i_freeNext5,

    input  wire valid0, valid1, valid2, valid3,
                valid4, valid5,
    output wire o_free,

    output wire o_driveNext0, o_driveNext1, o_driveNext2, o_driveNext3,
                o_driveNext4, o_driveNext5, 

    input  wire rst
);

    // 修改路数时：修改此处的N，并修改端口
    localparam N = 6;

    wire w_dirveReq;
    wire w_sendFree;
    wire w_d_sendFree;
    wire w_andReq;
    wire w_d_andReq;

    wire [N-1:0] w_req;
    wire [N-1:0] i_freeNext;
    wire [N-1:0] valid;

    assign i_freeNext = {
        i_freeNext5, i_freeNext4, i_freeNext3,
        i_freeNext2, i_freeNext1, i_freeNext0
    };

    assign valid = {
        valid5, valid4, valid3,
        valid2, valid1, valid0
    };

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : req_taps
            contTap u_tap (
                .trig((i_freeNext[i] & ~w_req[i]) | (w_d_sendFree & w_req[i])),
                .req(w_req[i]),
                .rst(rst)
            );
        end
    endgenerate

    // --------------------- 同步控制 ---------------------
    assign w_andReq = 
        (w_req[0] | ~valid[0]) &
        (w_req[1] | ~valid[1]) &
        (w_req[2] | ~valid[2]) &
        (w_req[3] | ~valid[3]) &
        (w_req[4] | ~valid[4]) &
        (w_req[5] | ~valid[5]);

    assign w_sendFree = w_dirveReq & w_andReq;

    delay2U delay_dandreq (
        .inR(w_andReq),
        .outR(w_d_andReq),
        .rst(rst)
    );

    delay1U delay_sendFree (
        .inR(w_sendFree),
        .outR(w_d_sendFree),
        .rst(rst)
    );

    delay1U delayDSendfree (
        .inR(w_d_sendFree),
        .outR(o_free),
        .rst(rst)
    );

    contTap driveTap (
        .trig((i_drive & ~w_dirveReq) | (w_d_andReq & w_dirveReq)),
        .req(w_dirveReq),
        .rst(rst)
    );

    // --------------------- 输出驱动 ---------------------
    assign o_driveNext0 = i_drive & valid0;
    assign o_driveNext1 = i_drive & valid1;
    assign o_driveNext2 = i_drive & valid2;
    assign o_driveNext3 = i_drive & valid3;
    assign o_driveNext4 = i_drive & valid4;
    assign o_driveNext5 = i_drive & valid5;

endmodule
