//===============================================================================
// Project:        RCA
// Module:         SelSplit_3
// Author:         YiHua Lu
// Date:           2025/07/20
// Description:    有条件分支; 不带数据版; 把数据和控制位分开;
//                 支持3路输出控制链，测试值：1ns即可传递
//===============================================================================
`timescale 1ns / 1ps



//@cc: schema: cc_header_v1
//@cc: name: cSelSplit_3_fetch
//@cc: family: SelSplit
//@cc: params:
//@cc:   NUM_PORTS: 3
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   upstream: [i_drive, o_free]
//@cc:   downstream: [o_driveNext0, o_driveNext1, o_driveNext2, i_freeNext0, i_freeNext1, i_freeNext2]
//@cc:   fire: []
//@cc: contract:
//@cc:   TODO: fill contract

module cSelSplit_3_fetch (
    input  wire i_drive,

    input  wire i_freeNext0,
    input  wire i_freeNext1,
    input  wire i_freeNext2,

    input  wire valid0,
    input  wire valid1,
    input  wire valid2,

    output wire o_free,

    output wire o_driveNext0,
    output wire o_driveNext1,
    output wire o_driveNext2,

    input  wire rst
);

    localparam N = 3;

    wire w_dirveReq;
    wire w_sendFree;
    wire w_d_sendFree;
    wire w_andReq;
    wire w_d_andReq;

    wire [N-1:0] w_req;
    wire [N-1:0] i_freeNext;
    wire [N-1:0] valid;

    assign i_freeNext = {i_freeNext2, i_freeNext1, i_freeNext0};
    assign valid      = {valid2, valid1, valid0};

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
        (w_req[2] | ~valid[2]);

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

endmodule
