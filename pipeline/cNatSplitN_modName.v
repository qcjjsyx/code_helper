`timescale 1ns / 1ps
//======================================================
// Project: SOLVA
// Module:  cSplitter3
// Author:  zhuangzhuang Liao
// Mail：   lzhuangzhuang2023@lzu.edu.cn
// Date:    2025-05-28
// Description: parameterized 3-input cSplitter
//======================================================






//@cc: schema: cc_header_v1
//@cc: name: cNatSplitN_modName
//@cc: family: NatSplitN
//@cc: params:
//@cc:   NUM_PORTS: TODO
//@cc:   DATA_WIDTH: {TODO}
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   TODO: fill roles; ports: i_data, i_drive, i_freeNext_n, o_data0, o_data1, o_data2, o_driveNext_n, o_free, rstn
//@cc:   upstream: []
//@cc:   downstream: []
//@cc:   fire:[]
//@cc: contract:
//@cc:   TODO: fill contract

 module cNatSplitN_modName#(
    parameter NUM_PORTS      = 3,
    parameter DATA_WIDTHI    = 32,
    parameter DATA_WIDTHOUT0 = 12,
    parameter DATA_WIDTHOUT1 = 32,
    parameter DATA_WIDTHOUT2 = 24
)(
    input  wire                   i_drive,
    input  wire [NUM_PORTS-1:0]   i_freeNext_n,
    input  wire [DATA_WIDTHI-1:0] i_data,

    output wire                      o_free,
    output wire [NUM_PORTS-1:0]      o_driveNext_n,
    output wire [DATA_WIDTHOUT0-1:0] o_data0,
    output wire [DATA_WIDTHOUT1-1:0] o_data1,
    output wire [DATA_WIDTHOUT2-1:0] o_data2,

    input wire rstn
);
 
   wire                 w_sendFree;
   wire [NUM_PORTS-1:0] w_Trig_n;
   wire [NUM_PORTS-1:0] w_Req_n;
   wire                 w_dirveReq;
   wire                 w_driveTap;
   wire                 w_andReq;
   wire                 w_d_andReq;
   
   /*******自定义输出数据*******/
   assign o_data0 = i_data[DATA_WIDTHOUT0-1:0];
   assign o_data1 = i_data[DATA_WIDTHOUT1-1:0];
   assign o_data2 = i_data[DATA_WIDTHOUT2-1:0];
   /***************************/

   assign w_andReq   = & w_Req_n;
   assign w_sendFree = w_dirveReq & w_andReq;
   
   delay2U delay_dandreq (.inR(w_andReq), .outR(w_d_andReq), .rstn(rstn));

   (* dont_touch="true" *) freeSetDelay #(
      .DELAY_UNIT_NUM ( 4 )
   ) delay_ofree_donttouch (
      .i_pulse ( w_sendFree ),
      .o_pulse ( o_free ),
      .rstn     ( rstn )
   );

   assign w_driveTap = (i_drive & (~w_dirveReq)) | w_d_andReq;
   contTap driveTap(
      .trig (w_driveTap),
      .req  (w_dirveReq),
      .rstn (rstn)
   ); 

   genvar tap_i;
   generate
      for (tap_i =0; tap_i<NUM_PORTS; tap_i=tap_i+1 ) begin: gen_contap
         assign w_Trig_n[tap_i] = i_freeNext_n[tap_i] & (~w_Req_n[tap_i]) | o_free;
         assign o_driveNext_n[tap_i] = i_drive;
         contTap tapifree(
            .trig (w_Trig_n[tap_i]),
            .req  (w_Req_n[tap_i]),
            .rstn (rstn)
            );
      end
   endgenerate

 
 endmodule
 
 