//-----------------------------------------------
//	module name: decoder
//	author: zhangLongtao
//  modifier:
//	version: 1nd version (2024-06-4)
//	description:
//
//
//-----------------------------------------------

/*=============================================================
Project:ARMCPU
Module:decoder
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:decoder_16 and decoder32
==============================================================*/


`timescale 1ns/1ps

module decoder (
  input          i_driveFromIF     ,
  input  [ 63:0] i_pcAndIns_64     ,
  input          i_is16_1          ,
  output         o_freeToIF        ,
  output         o_driveToLaunch_1 ,
  output [186:0] o_decoderData_187 ,
  input          i_freeFromLaunch_1,
  output         o_driveToExc_1    ,
  output [ 35:0] o_decPCAndNum_36  ,
  input          i_freeFromExc_1   ,
  input          i_isInInt         ,// 2025.1.3 zlt-->add
  output [1:0]   o_wen_2,
  output [8:0]   o_blImm9_9,
  output [3:0]   o_nzcvWen_4,

  //1/4 zwm
  // output o_decInUseFlag_1,
  input          rst
);

  wire        w_DecSeleDriToDec16_1, w_dec16FreeToDecSele_1;
  wire        w_DecSeleDriToDec32_1, w_dec32FreeToDecSele_1;
  wire [63:0] w_pcAndIns_64        ;
  wire [63:0] w_pcAndIns1_64       ;
  wire        w_dec16DriToMer_1, w_merFreeToDec16_1;
  wire        w_dec32DriToMer_1, w_merFreeToDec32_1;
  wire [ 3:0] w_excNum16_4         ;
  wire [ 3:0] w_excNum32_4         ;

  wire [186:0] w_decode16Data_187;
  wire [186:0] w_decode32Data_187;

   reg r_is16_1;



  (* dont_touch="true" *)  cSelector2_65b_dec decoderSele (
    .i_drive     (i_driveFromIF),         .i_data_65({i_is16_1, i_pcAndIns_64}), .o_free(o_freeToIF        ),
    .o_driveNext0(w_DecSeleDriToDec16_1), .i_freeNext0(w_dec16FreeToDecSele_1),  .o_data0_64(w_pcAndIns_64 ),
    .o_driveNext1(w_DecSeleDriToDec32_1), .i_freeNext1(w_dec32FreeToDecSele_1),  .o_data1_64(w_pcAndIns1_64),
    .rst         (rst                                                                                      )
  );


wire w_is16_1;
wire [8:0] w_blImm9_9;
wire [3:0] w_nzcvWen16_4;
wire [3:0] w_nzcvWen32_4;

  wire w_DecSeleDriToDec16Delay_1,w_DecSeleDriToDec32Delay_1;
(* dont_touch="true" *)delay4U topdelay0 (.inR(w_DecSeleDriToDec16_1), .outR(w_DecSeleDriToDec16Delay_1), .rst(rst));
(* dont_touch="true" *)delay4U topdelay1 (.inR(w_DecSeleDriToDec32_1), .outR(w_DecSeleDriToDec32Delay_1), .rst(rst));

  (* dont_touch="true" *)  decoder_16 decoder16 (
    .i_drive   (w_DecSeleDriToDec16_1), .i_data_64(i_pcAndIns_64), .o_free(w_dec16FreeToDecSele_1  ),
    .i_isInInt (i_isInInt),// 2025.1.3 zlt-->add
    .o_drive1   (w_dec16DriToMer_1),     .o_data_187(w_decode16Data_187), .i_free(w_merFreeToDec16_1),
    .o_excNum_4(w_excNum16_4                                                                       ),
    .o_nzcvWen_4(w_nzcvWen16_4),
    .rst       (rst                                                                                )
  );

  (* dont_touch="true" *)  decoder_32 decoder32 (
    .i_drive   (w_DecSeleDriToDec32_1), .i_data_64(i_pcAndIns_64), .o_free(w_dec32FreeToDecSele_1 ),
    .o_drive   (w_dec32DriToMer_1),     .o_data_187(w_decode32Data_187), .i_free(w_merFreeToDec32_1),
    .o_excNum_4(w_excNum32_4                                                                       ),
    .o_blImm9_9(w_blImm9_9),
    .o_nzcvWen_4(w_nzcvWen32_4),
    .rst       (rst                                                                                )
  );

  (* dont_touch="true" *)    wire decoDriToDecSpli_1, w_freeFromDecSpli_1,w_freeFromDecSpli1_1;

  (* dont_touch="true" *)    wire [190:0] w_decoderData_191, w_decoderData1_191;

  (* dont_touch="true" *)  cMutexMerge2_191b_dec decoMerge (
    .i_drive0  (w_dec16DriToMer_1), .i_data0_191({w_excNum16_4, w_decode16Data_187}), .o_free0(w_merFreeToDec16_1    ),
    .i_drive1  (w_dec32DriToMer_1), .i_data1_191({w_excNum32_4, w_decode32Data_187}), .o_free1(w_merFreeToDec32_1    ),
    .i_freeNext(w_freeFromDecSpli1_1), .o_driveNext(decoDriToDecSpli_1), .o_data_191(w_decoderData_191),
    .rst       (rst                                                                              )
  );



//给驱动加个延�????
wire decoDriToDecSpliDelay_1, decoDriToDecSpliDelay1_1, w_fire;
// wire w_decSpliDriveToExcSelector_1,w_excSelectorFreeToDecSpli_1;
reg [190:0] r_decoderData_191;
(* dont_touch="true" *)delay8U outdelay1 (.inR(decoDriToDecSpli_1), .outR(decoDriToDecSpliDelay1_1), .rst(rst));

cFifo1 decodeFifo(.i_drive(decoDriToDecSpliDelay1_1), .i_freeNext(w_freeFromDecSpli_1), .rst(rst),
               .o_free(w_freeFromDecSpli1_1), .o_driveNext(decoDriToDecSpliDelay_1), .o_fire_1(w_fire));

reg [8:0] r_blImm9_9;
reg [3:0]r_nzcvWen_4;


always @(posedge w_fire or negedge rst) begin
  if (!rst) begin
    r_decoderData_191 <= {4'hf,187'b0};
    r_blImm9_9 <= 0;
    r_nzcvWen_4 <= 0;
  end else begin
    r_decoderData_191 <= w_decoderData_191;
    r_blImm9_9 <= w_blImm9_9;
    r_nzcvWen_4 <= i_is16_1 ?  w_nzcvWen16_4 : w_nzcvWen32_4;
  end
end

always @(posedge w_fire or negedge rst) begin
  if(!rst)begin
   r_is16_1 <= 1'b0;
  end 
  else begin
   r_is16_1 <= i_is16_1;
  end
end

assign w_is16_1 = r_is16_1;
assign w_decoderData1_191 = r_decoderData_191;
wire w_b_1;
  (* dont_touch="true" *)  cSplitter2_1b decSpli (
    .i_drive     (decoDriToDecSpliDelay_1), .i_data_1(1'b0), .o_free(w_freeFromDecSpli_1    ),
    .o_driveNext0(o_driveToLaunch_1), .i_freeNext0(i_freeFromLaunch_1), .o_data0_1(),
    .o_driveNext1(o_driveToExc_1), .i_freeNext1(w_b_1), .o_data1_1(      ),
    .rst         (rst                                                              )
  );
  (* dont_touch="true" *)delay8U decSpliDelay (.inR(o_driveToExc_1), .outR(w_b_1), .rst(rst));

  // //这里少了去异常模块的择路逻辑
  // wire w_excSelectorDriveToMe_1;
  // //w_decoderData_189[134:103]PC位置有问题，要改
  // (* dont_touch="true" *) cSelector2_37b_dec excSelector(.i_drive(w_decSpliDriveToExcSelector_1), .i_data_37({w_isExc_1,w_decoderData_191[134:103],w_excNum_4}), .o_free(w_excSelectorFreeToDecSpli_1),
  // .o_driveNext0(w_excSelectorDriveToMe_1), .i_freeNext0(w_excSelectorDriveToMe_1), .o_data0_36(o_decPCAndNum_36),
  // .o_driveNext1(o_driveToExc_1), .i_freeNext1(i_freeFromExc_1), .o_data1_36(),
  // .rst(rst));

  //10/19
  //后面可以不要最高位
  assign o_decoderData_187 = {1'b0, w_decoderData1_191[186:2], w_is16_1};
  assign o_wen_2 = w_decoderData1_191[1:0];
  assign o_blImm9_9 = r_blImm9_9;
  assign o_nzcvWen_4 = r_nzcvWen_4;
  assign o_decPCAndNum_36 = {w_decoderData1_191[136:105],w_decoderData1_191[190:187]};
  // assign o_decPCAndNum_36 = {w_decoderData1_191[136:105],4'b1111}; // 后面得改PC的位�????

//1/4 zwm
// //need a contap 
//   contTap decoderTap(
//     .trig(i_driveFromIF | o_driveToLaunch_1),
//     .req(o_decInUseFlag_1),
//     .rst(rst)
//     );



endmodule

