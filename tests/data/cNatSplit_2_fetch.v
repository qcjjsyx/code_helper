//======================================================
// Project:        RCA
// Module:         NatSplit_2
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    无条件分支;无数据版;
//                 测试值：1ns给出去
//======================================================
`timescale 1ns / 1ps







//@cc: schema: cc_header_v1
//@cc: name: cNatSplit_2_fetch
//@cc: family: NatSplit
//@cc: params:
//@cc:   NUM_PORTS: 2
//@cc:   DATA_WIDTH: {TODO}
//@cc: roles:
//@cc:   upstream: [i_drive, o_free]
//@cc:   downstream: [o_driveNext0, o_driveNext1, i_freeNext0, i_freeNext1]
//@cc:   fire: []

module cNatSplit_2_fetch(
    input  wire i_drive,
    input  wire i_freeNext0,i_freeNext1,

    output wire o_free,
    output wire o_driveNext0,o_driveNext1,

    input wire rst
);

(*dont_touch = "yes"*)wire w_sendFree;
(*dont_touch = "yes"*)wire w_d_sendFree;
(*dont_touch = "yes"*)wire w_firstReq;
(*dont_touch = "yes"*)wire w_secondReq;
(*dont_touch = "yes"*)wire w_dirveReq;
(*dont_touch = "yes"*)wire w_andReq;
 
 assign w_andReq = w_firstReq & w_secondReq;
 assign w_sendFree = w_dirveReq & w_andReq;

 wire w_d_andReq;
 delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rst(rst));
 delay1U delay_sendFree (.inR(w_sendFree), .outR(w_d_sendFree), .rst(rst));

 delay1U delayDSendfree (.inR(w_d_sendFree), .outR(o_free), .rst(rst));

 contTap driveTap(
   .trig((i_drive&(~w_dirveReq)) | (w_d_andReq&w_dirveReq)),
   .req(w_dirveReq),
   .rst(rst)
 ); 
 
 contTap firstTap(
 .trig((i_freeNext0&(~w_firstReq)) | (w_d_sendFree&w_firstReq)),
 .req(w_firstReq),
 .rst(rst)
 );
 
 contTap secondTap(
 .trig((i_freeNext1&(~w_secondReq)) | (w_d_sendFree&w_secondReq)),
 .req(w_secondReq),
 .rst(rst)
 );

 assign o_driveNext0 = i_drive;
 assign o_driveNext1 = i_drive;

endmodule

