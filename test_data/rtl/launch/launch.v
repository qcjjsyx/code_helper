/*=============================================================
Project:ARMCPU
Module:launch
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:launch
==============================================================*/

`timescale 1ns/1ps

module launch (
    //! 鏉ヨ嚜璇戠爜鐨勮剦锟�??????????????
    input i_decoderDriveToLaunch_1,
    //! 璇戠爜鏉ョ殑鏁版�?????????
    input [184:0] i_decoderData_185,
    //! 缁欒瘧鐮佺殑澶嶄�?????????
    output o_launchFreeToDecoder_1,

    //! 璇戠爜鍙︿竴璺殑鑴夊啿
    input i_decoDrive1ToLaunch_1,
    //! 璇戠爜鍙︿竴璺暟锟�??????????????
    input i_s_1,
    //! 鍙︿竴绫荤粰璇戠爜澶嶄綅
    output o_launchFree1ToDecoder_1,

    //! LSU鏉ョ殑鏃佽矾
    input i_LsuDriveToLunch_1,
    //! LSU鏃佽矾鏁版嵁
    input [63:0] i_lsuData_64,
    //! 缁橪SU鏃佽矾鐨勫锟�?????
    output o_launchFreeToLsu_1,

    //! EXE鏉ョ殑鏃佽矾
    input i_ExeDriveToLunch_1,
    //! EXE鏃佽矾鏁版嵁
    input [95:0] i_ExeData_96,
    //! 缁橢XE鏃佽矾澶嶄綅
    output o_launchFreeToExe_1,

    //! 鏉ヨ嚜GRF鐨勮剦锟�??????????????
    input i_GrfDriveToLaunch_1,
    //! GFR鏁版�?????????
    input [63:0] i_rsData_64,
    //! 缁橤RF澶嶄�?????????
    output o_launchFreeToGrf_1,

    //! 鏉ヨ嚜SRF鐨勮剦锟�??????????????
    input i_SrfDriveToLaunch_1,
    //! SRF鏁版�?????????
    input [31:0] i_sRsData_32,
    //! 缁橲RF澶嶄�?????????
    output o_launchFreeToSrf_1,

    //! 鏉ヨ嚜PSR鐨勮剦锟�??????????????
    input i_PSRDriveToLaunch_1,
    //! PSR鏁版�?????????
    input [31:0] i_psrData_32,
    //! 缁橮SR澶嶄�?????????
    output o_launchFreeToPSR_1,

    //! 缁橤RF鐨勮剦锟�??????????????
    output o_launchDriveToGrf_1,
    //! GRF鍦板�?????????
    output [7:0] o_regAddr_8,
    //! 鏉ヨ嚜GRF鐨勫锟�??????????????
    input i_grfFreeTolaunch_1,

    //! 缁橲RF鐨勮剦锟�??????????????
    output o_launchDriveToSrf_1,
    //! SRF鍦板�?????????
    output [7:0] o_SRegAddr_8,
    //! 鏉ヨ嚜SRF鐨勫锟�??????????????
    input i_srfFreeTolaunch_1,

    //! 缁橮SR鐨勮剦锟�??????????????
    output o_launchDriveToPsr_1,
    //! 鏉ヨ嚜PSR鐨勫锟�??????????????
    input i_PSRFreeToLaunch_1,

    //! 缁橢XE鐨勮剦锟�??????????????
    output o_launchDriveToExe_1,
    //! 鎵撳寘濂界殑鏁版�?????????
    output [206:0] o_launchDataToExe_207,
    //! 鏉ヨ嚜EXE鐨勫锟�??????????????
    input i_ExeFreeToLaunch_1,

    //! 缁橧F鐨勮剦锟�??????????????
    output o_launchDriveToIf_1,
    //! 鍙栨寚鍦板潃
    output [31:0] o_pc_32,
    //! 鏉ヨ嚜IF鐨勫锟�??????????????
    input i_IfFreeToLaunch_1,

    //! 缁橧F鐨勮剦锟�??????????????
    output o_bDriToIf,
    //! 鍙栨寚鍦板潃
    output [31:0] o_branchPc_32,
    //! 鏉ヨ嚜IF鐨勫锟�??????????????-
    input i_bFreeFromIf,

    input [8:0] i_blImm9_9,


    //12/10 zwm need the w_wen_2 from the top
    input [1:0] i_wen_2,

    input rst,

    output o_b_1,

    //1/10 zwm
    input i_isInInt,
    // //1/11 zwm
    // input [3:0] decNum_4,
    // input [3:0] exeNum_4,
    //1/11 zwm use i_driveFExcToIf_1 to reset r_cont_2
    input i_driveFExcToIf_1,
    input i_excToIfFlag_1
  );

    (* dont_touch="true" *)wire [15:0] w_imm_16;
    (* dont_touch="true" *)wire [15:0] w_zeroImm_16, w_signImm_16, w_decoImm_16, w_thumbImm_16;
    (* dont_touch="true" *)wire [1:0] w_immType_2;
    (* dont_touch="true" *)wire [3:0] w_rs1_4;
    (* dont_touch="true" *)wire [3:0] w_rs2_4;
    (* dont_touch="true" *)wire [7:0] w_psrAddr_8;
    (* dont_touch="true" *)wire [1:0] w_ABForkValid_2;
    (* dont_touch="true" *)wire [7:0] w_rs1AndRs2_8;
    (* dont_touch="true" *)wire [11:0] w_ABForkData0_12, w_RImmForkData0_12, w_AMergeData_12;
    (* dont_touch="true" *)wire [31:0] w_rs1Data_32, w_rs2Data_32;

    (* dont_touch="true" *)wire [15:0] w_launchSpliData0_16;
    (* dont_touch="true" *)wire [25:0] w_launchSpliData1_26;
    (* dont_touch="true" *)wire [142:0] w_launchForkData2_143;
    (* dont_touch="true" *)wire [25:0] w_RAndImm_26, w_ABForkData1_33;
    (* dont_touch="true" *)wire [17:0] w_ABForkData2_21, w_RImmForkData1_21, w_BMergeData_21;

    (* dont_touch="true" *)wire [3:0] w_rs1Addr_4;
    (* dont_touch="true" *)wire [3:0] w_rs2Addr_4;
    (* dont_touch="true" *)wire [7:0] w_sRsAddr_8;

    (* dont_touch="true" *)wire [3:0] w_preRd1Addr_4;
    (* dont_touch="true" *)wire [3:0] w_preRd2Addr_4;
    (* dont_touch="true" *)wire [3:0] w_preRdL1Addr_4;
    (* dont_touch="true" *)wire [3:0] w_preRdL2Addr_4;

    (* dont_touch="true" *)wire [7:0] w_preSRd1Addr_8;
    (* dont_touch="true" *)wire [7:0] w_preSRd2Addr_8;

    (* dont_touch="true" *)wire [5:0] w_rele_6;
    (* dont_touch="true" *)wire [5:0] w_rele2_6;

    (* dont_touch="true" *)wire [3:0] w_rdAddr_4;
    (* dont_touch="true" *)wire [3:0] w_rdAddr1_4;
    (* dont_touch="true" *)wire [7:0] w_sRdAddr_8;
    (* dont_touch="true" *)wire [7:0] w_sRdAddr1_8;

    (* dont_touch="true" *)  wire [32:0] w_rele0Data_33, w_rele1Data_33, w_rele2Data_33,
       w_rele3Data_33, w_rele4Data_33, w_rele5Data_33;
    (* dont_touch="true" *)  wire [31:0] w_lsuRs1Data_32, w_exeRs1Data_32, w_grfRs1Data_32,
       w_lsuRs2Data_32, w_exeRs2Data_32, w_grfRs2Data_32,
       w_lastRs1Data_32, w_lastRs2Data_32;

    (* dont_touch="true" *)wire [31:0] w_pc_32, w_pc1_32, w_pc2_32, w_lastImm_32;
    (* dont_touch="true" *)wire [31:0] w_branchPc_32, w_branchPc1_32;

    (* dont_touch="true" *)wire [63:0] w_lastRs1AndRs2Data_64, w_Rs1AndRs2Data_64;

    (* dont_touch="true" *)wire [1:0] w_psrRele_2;
    (* dont_touch="true" *)wire w_s_1;
    (* dont_touch="true" *)wire w_PerS_1;

    (* dont_touch="true" *)wire w_rs1Lsu_1;
    (* dont_touch="true" *)wire w_rs1Exe_1;
    (* dont_touch="true" *)wire w_rs1Grf_1;
    (* dont_touch="true" *)wire w_rs2Lsu_1;
    (* dont_touch="true" *)wire w_rs2Exe_1;
    (* dont_touch="true" *)wire w_rs2Grf_1;
    (* dont_touch="true" *)wire w_ALIGN_1;

    (* dont_touch="true" *)wire [2:0] w_immNumType_3;
    (* dont_touch="true" *)wire w_imm5_1, w_imm8_1, w_imm12_1, w_imm16_1, w_imm2_1; //  32浣嶆寚锟�???????????????
    (* dont_touch="true" *)wire w_imm3_1, w_imm7_1, w_imm11_1;
    (* dont_touch="true" *)wire w_zeroimm16_1, w_zeroimm12_1, w_zeroimm8_1, w_zeroimm5_1, w_zeroimm2_1, w_zeroimm11_1, w_zeroimm7_1, w_zeroimm3_1;
    (* dont_touch="true" *)wire w_signimm16_1, w_signimm12_1, w_signimm8_1, w_signimm5_1, w_signimm2_1, w_signimm11_1, w_signimm7_1, w_signimm3_1;
    (* dont_touch="true" *)wire w_decoimm16_1, w_decoimm12_1, w_decoimm8_1, w_decoimm5_1, w_decoimm2_1, w_decoimm11_1, w_decoimm7_1, w_decoimm3_1;
    (* dont_touch="true" *)wire w_thumbimm16_1, w_thumbimm12_1, w_thumbimm8_1, w_thumbimm5_1, w_thumbimm2_1, w_thumbimm11_1, w_thumbimm7_1, w_thumbimm3_1;
    (* dont_touch="true" *)wire [31:0] w_immZero_32, w_immSign_32, w_immDecode_32, w_immThumb_32;
    (* dont_touch="true" *)wire [31:0] w_immZero1_32, w_immSign1_32, w_immDecode1_32, w_immThumb1_32;
    (* dont_touch="true" *)wire [4:0] w_imm_5;
    (* dont_touch="true" *)wire [4:0] w_satImmOrWidthm_5; // 楗卞拰杩愮畻鐀��埌锟�???????????????5浣嶇珛鍗虫暟
    (* dont_touch="true" *)wire [4:0] w_saturate_5;
    (* dont_touch="true" *)wire w_isImm_1;// 5.24 璇戠爜杩樻病鏈夌粺锟�???????????????

    (* dont_touch="true" *)wire [31:0] w_rnData_32, w_rmData_32, w_raData_32, w_last1Imm_32, w_last2Imm_32;
    (* dont_touch="true" *)wire [31:0] w_rnData1_32, w_rmData1_32;
    (* dont_touch="true" *)wire [95:0] w_op_96, w_op123_96;

    
    //鍙互鐢ㄦ潵鍖哄垎鏈変簺鎸囦护鏈夋病鏈夌敤鍒皉s2鍜宺s1锛屽鏋滄病鏈夌敤鍒扮殑璇濊偗瀹氭病鏈夌浉鍏筹�?????????? 
    (* dont_touch="true" *)wire w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bit_1;
    (* dont_touch="true" *)wire w_isRn, w_isRm;


    (* dont_touch="true" *)wire [1:0] w_shift_2, w_shiftType_2;
    (* dont_touch="true" *)wire [2:0] w_shift_3;

    (* dont_touch="true" *)wire w_apsrC_1;
    (* dont_touch="true" *)wire w_addCarry_1, w_addC0_1, w_addC1_1, w_addC_1;
    (* dont_touch="true" *)wire w_add5_1, w_add64_1;
    (* dont_touch="true" *)wire [2:0] w_addType_3, w_addType1_3;

    (* dont_touch="true" *)wire w_z_1, w_c_1, w_n_1, w_v_1;
    (* dont_touch="true" *)wire w_z1_1, w_c1_1, w_n1_1, w_v1_1;
    (* dont_touch="true" *)wire w_z2_1, w_c2_1, w_n2_1, w_v2_1;
    (* dont_touch="true" *)wire w_b_1;
    (* dont_touch="true" *)wire w_cbz_1, w_cbnz_1;
    (* dont_touch="true" *)wire w_isB_1;
    (* dont_touch="true" *)wire [3:0] w_cond_4;
    (* dont_touch="true" *)wire [3:0] w_cond1_4;
    (* dont_touch="true" *)reg [7:0] r_insPath_8;
    (* dont_touch="true" *)wire [7:0] w_insPath_8;
    (* dont_touch="true" *)wire [15:0] w_insType_16;
    assign o_b_1 = w_b_1;


  wire w_launchForkDriveToABSelector_1, w_ABForkFreeToLaunchSplitter_1;
  wire w_ABForkDriveToAMerge_1, w_AMergeFreeToABSelector_1, w_ABForkDriveToRImmSplitter_1, w_RImmForkFreeToABSelector_1,
       w_RImmForkDriveToAMerge_1, w_AMergeFreeToRImmSplitter_1, w_RImmForkDriveToBMerge_1,
       w_BMergeFreeToRImmSplitter_1, w_BMergeFreeToABSelector_1, w_AMergeDriveToRegSelitter_1, w_BMergeDriveToImmSplitter_1,
       w_regForkFreeToAMerge_1, w_ImmForkFreeToBMerge_1,w_regSplitterDriveToReleSplitter_1,
       w_WriteRdFifoFreeToReleFifo_1,w_releSplitterDriveToWriteRdFifo_1,w_releSplitterDriveToRele6Splitter_1,
       w_writeRdFifoDrive_1,w_WriteRdFifoFreeToReleSplitter_1,w_releSplitterFreeToRegSplitter_1,w_rele6SplitterFreeToReleSplitter_1;

  wire w_rele0MergeFreeToLsu_1,w_rele1MergeFreeToExe_1,w_rele4MergeFreeToLsu_1,w_rele5MergeFreeToExe_1,w_rele0MergeDriveToRele0Selector_1,
       w_rele1MergeDriveToRele1Selector_1,w_rele2MergeDriveToRele2Selector_1,w_rele3MergeDriveToRele3Selector_1,w_rele4MergeDriveToRele4Selector_1,
       w_rele5MergeDriveToRele5Selector_1,w_rele0SelectorFreeToRele0Merge_1,w_rele1SelectorFreeToRele1Merge_1,w_rele2SelectorFreeToRele2Merge_1,
       w_rele3SelectorFreeToRele3Merge_1,w_rele4SelectorFreeToRele4Merge_1,w_rele5SelectorFreeToRele5Merge_1;

  wire w_rele0SelectorDriveToRs1Merge_1,w_rele1SelectorDriveToRs1Merge_1,w_rele2SelectorDriveToRs1Merge_1,w_rele3SelectorDriveToRs2Merge_1,
       w_rele4SelectorDriveToRs2Merge_1,w_rele5SelectorDriveToRs2Merge_1,w_rele0SelectorDriveToMe_1,w_rele1SelectorDriveToMe_1,w_rele2SelectorDriveToMe_1,
       w_rele3SelectorDriveToMe_1,w_rele4SelectorDriveToMe_1,w_rele2MergeFreeToGrfSplitter_1,w_rele5MergeFreeToGrfSplitter_1,w_rs1MergeFreeToRele0Selector_1,
       w_rs1MergeFreeToRele1Selector_1,w_rs1MergeFreeToRele2Selector_1,w_rs2MergeFreeToRele0Selector_1,w_rs2MergeFreeToRele1Selector_1,w_rs2MergeFreeToRele2Selector_1;

  // assign w_rs1Data_32 = i_rs1AndRs2Data_100[31:0];
  // assign w_rs2Data_32 = i_rs1AndRs2Data_100[63:32];

  wire w_launchForkDriveToExeMerge_1,w_exeMergeFreeToLaunchFork_1;

  wire w_launchSpliDriveToRegSpli_1, w_regSpliFreeToLaunchSpli_1, w_launchSpliDriToImmSele_1, w_ImmSeleFreeToLaunchSpli_1;

  wire w_regSpliDriToGrfSrf_1, w_grfSrfSeleFreeToRegSpli_1;
  wire w_driveToMe_1, w_launchForkDrive1ToExeMerge_1,w_exeMergeFree1ToLaunchFork_1,w_launchForkDriveToExeMerge1_1;
  wire w_regMergeDriveToRegSelector_1;
  wire w_free;
  
  // 浣嶅鍐嶅畾
  (* dont_touch="true" *) cSplitter3_185_16_26_143b_launch launchSplitter(.i_drive(i_decoderDriveToLaunch_1), .i_data_185(i_decoderData_185), .o_free(o_launchFreeToDecoder_1),
      .o_driveNext0(w_launchSpliDriveToRegSpli_1), .i_freeNext0(w_free), .o_data0_16(w_launchSpliData0_16), // reg
      .o_driveNext1(w_launchSpliDriToImmSele_1), .i_freeNext1(w_ImmSeleFreeToLaunchSpli_1), .o_data1_26(w_launchSpliData1_26), // imm
      .o_driveNext2(w_launchForkDriveToExeMerge_1), .i_freeNext2(w_regMergeDriveToRegSelector_1), .o_data2_143(w_launchForkData2_143), // 涓嶉渶瑕佸弬涓庤繍锟�???????????????
      .rst(rst)); // 2024.11.14 -->zlt-->i_freeNext2 ago is w_exeMergeFree1ToLaunchFork_1    

  (* dont_touch="true" *) wire w_load_1, w_loadSign_1, w_isLS_1, w_aluWritePC_1, w_P_1, w_W_1, w_U_1, w_S_1, w_S1_1, w_opNot_1,w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_isMultiLS_1;
  (* dont_touch="true" *) wire w_isXt_1, w_satqS_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1, w_mulDivS_1, w_cB_1, w_ucB_1, w_bl_1, w_bx_1, w_blx_1, w_mrs_1, w_msr_1;
  (* dont_touch="true" *) wire w_movAluWritePC_1, w_addAluPC_1, w_writeRd_1; 
  (* dont_touch="true" *) wire [1:0] w_loadStoreWidth_2, w_revType_2;
  (* dont_touch="true" *) wire [3:0] w_dHi_4, w_dLo_4, w_n_4;
  (* dont_touch="true" *) wire w_immNot_1, w_rnNot_1, w_rmNot_1, w_pushPopReg_1, w_thumbExpandRor_1, w_grfFlag_1, w_is16_1;
  wire [4:0] w_msbit_5, w_lsbit_5;
//w_launchForkData2_143浣嶅涓嶅
  assign {
      w_satImmOrWidthm_5, w_isImm_1, w_pushPopReg_1, w_pc_32, w_cond_4, w_addC0_1, w_addC1_1, w_addC_1, w_add5_1, w_add64_1, w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bit_1,w_thumbExpandRor_1,
      w_ALIGN_1, w_aluWritePC_1, w_cB_1, w_ucB_1, w_bl_1, w_bx_1, w_blx_1, w_cbz_1, w_cbnz_1, w_mrs_1, w_msr_1, w_insType_16, w_shift_3, w_load_1, w_loadStoreWidth_2,
      w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, w_sRdAddr_8, w_P_1, w_W_1, w_U_1, w_grfFlag_1, w_rnNot_1, w_rmNot_1, w_immNot_1, w_opNot_1, w_isXt_1, w_revType_2, w_satqS_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1,
      w_mulDivS_1, w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4, w_is16_1
    } = w_launchForkData2_143;

  wire w_isCb_1;
  assign w_isB_1 = w_aluWritePC_1 | w_cB_1 | w_ucB_1 | w_bl_1 | w_cbz_1 | w_cbnz_1 | w_blx_1 | w_bx_1;
  assign w_isCb_1 = w_cB_1 | w_ucB_1 | w_blx_1 | w_bx_1;
  assign w_isRn = w_rnOp1 | w_rnOp3;
  assign w_isRm = w_rmOp1 | w_rmOp2;

  //update

  delay4U launchDelay0(.inR(w_launchForkDriveToExeMerge_1), .outR(w_launchForkDriveToExeMerge1_1), .rst(rst));

  // 2024.22.3 -->zlt-->璺宠浆鎸囦护涔熷線鍚庤蛋
  // (* dont_touch="true" *) cSelector2_1b_launch Selector(.i_drive(w_launchForkDriveToExeMerge1_1), .i_data_1(w_isB_1), .o_free(w_exeMergeFreeToLaunchFork_1),
  // .o_driveNext0(w_driveToMe_1), .i_freeNext0(w_driveToMe_1), .o_data0_1(1'b0),
  // .o_driveNext1(w_launchForkDrive1ToExeMerge_1), .i_freeNext1(w_exeMergeFree1ToLaunchFork_1), .o_data1_1(1'b0),
  // .rst(rst));



  // 涓や釜瀵勫瓨鍣ㄧ浉鍏筹�??????????锟藉锟�???????????????
  (* dont_touch="true" *) cSplitter2_16b_launch regSplitter(.i_drive(w_launchSpliDriveToRegSpli_1), .i_data_16(w_launchSpliData0_16), .o_free(w_regSpliFreeToLaunchSpli_1),
      .o_driveNext0(w_regSplitterDriveToReleSplitter_1), .i_freeNext0(w_releSplitterFreeToRegSplitter_1), .o_data0_8(w_rs1AndRs2_8),
      .o_driveNext1(w_regSpliDriToGrfSrf_1), .i_freeNext1(w_grfSrfSeleFreeToRegSpli_1), .o_data1_8(w_sRsAddr_8),
      .rst(rst));

  wire w_regSpliDri1ToGrfSrf_1;
  // delay2U grfdelay0(.inR(w_regSpliDriToGrfSrf_1), .outR(w_regSpliDri1ToGrfSrf_1));
  (* dont_touch="true" *) cSelector2_17b_launch grfSrfSele(.i_drive(w_regSpliDriToGrfSrf_1), .i_data_17({w_mrs_1, {w_sRsAddr_8, w_rs1AndRs2_8}}), .o_free(w_grfSrfSeleFreeToRegSpli_1),
      .o_driveNext0(o_launchDriveToGrf_1), .o_data0_8(o_regAddr_8), .i_freeNext0(i_grfFreeTolaunch_1),
      .o_driveNext1(o_launchDriveToSrf_1), .o_data1_8(o_SRegAddr_8), .i_freeNext1(i_srfFreeTolaunch_1),
      .rst(rst));

  // 鐩稿叧鎬ф娴嬬粍鍚堬�??????????锟借緫------->鐢熸垚涓や綅鐨勬爣蹇椾綅琛ㄧずrs1鍜宺s2鏄惁鏈夌浉鍏筹�???????????
      (* dont_touch="true" *) reg [5:0] r_rele_6,r_releData_6;
      (* dont_touch="true" *) wire [5:0] w_releData_6;
      (* dont_touch="true" *) wire [31:0] w_lsuData_32, w_exeData_32;
      (* dont_touch="true" *) reg [31:0] r_lsuData_32, r_exeData_32;
  assign w_rs1Addr_4 = w_rs1AndRs2_8[3:0];
  assign w_rs2Addr_4 = w_rs1AndRs2_8[7:4];


  // 杩欓噷锟�???????????????瑕佸姞寤惰繜
  (* dont_touch="true" *) cSplitter2_18_6_12b_launch releSplitter(.i_drive(w_regSplitterDriveToReleSplitter_1), .i_data_18({w_dHi_4, w_sRdAddr_8, w_releData_6}), .o_free(w_releSplitterFreeToRegSplitter_1),
      .o_driveNext0(w_releSplitterDriveToWriteRdFifo_1), .i_freeNext0(w_WriteRdFifoFreeToReleSplitter_1), .o_data0_6(),
      .o_driveNext1(w_releSplitterDriveToRele6Splitter_1), .i_freeNext1(w_free), .o_data1_12({w_rdAddr1_4, w_sRdAddr1_8}),
      .rst(rst));

  wire w_releSplitterDriveToWriteRdFifoDelay_1;
      delay8U releSplitterDelay0(.inR(w_releSplitterDriveToWriteRdFifo_1), .outR(w_WriteRdFifoFreeToReleSplitter_1), .rst(rst));  

      // 2024.11.13 -->zlt
      // delay16U releSplitterDelay1(.inR(w_releSplitterDriveToWriteRdFifo_1), .outR(w_releSplitterDriveToWriteRdFifoDelay_1), .rst(rst)); 
      // always @(posedge w_releSplitterDriveToWriteRdFifoDelay_1 or negedge rst) begin
      //   if(!rst)begin
      //     r_rele_6 <= 6'b0; 
      //     r_releData_6 <= 6'b0;
      //     r_exeData_32 <= 32'b0;
      //     r_lsuData_32 <= 32'b0;
      //   end else begin
      //     //杩涙潵涔嬪墠鍏堝锟�??????????????
      //     //r_rele_6 <= 6'b0; 
      //     //rd2鏄痩su锟�?????,exe鐨勭浉鍏虫€т紭鍏堢骇瑕佷綆锟�??????????????0锟�?????4鏄痩su,1锟�?????5鏄痚xe,2锟�?????3鏄痝rf
      //     //涓庣殑浼樺厛绾ф瘮鎴栬楂橈紝杩欓噷锟�??????????????0锟�?????4鍔犱簡鎷�?????????
      //     // r_rele_6[1] <= (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) & !r_rele_6[0] & !w_isLS_1 ? 1'b1 : 1'b0;
      //     // r_rele_6[0] <= ((w_rs1Addr_4 == w_preRd2Addr_4 | w_rs1Addr_4 == w_preRdL2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) | r_rele_6[1]) & w_isLS_1 ? 1'b1 : 1'b0;
      //     // r_rele_6[5] <= (w_rs2Addr_4 == w_preRd1Addr_4 | w_rs2Addr_4 == w_preRdL1Addr_4) & !r_rele_6[4] & !w_isLS_1? 1'b1 : 1'b0;
      //     // r_rele_6[4] <= ((w_rs2Addr_4 == w_preRd2Addr_4 | w_rs2Addr_4 == w_preRdL2Addr_4) | r_rele_6[5]) & w_isLS_1 ? 1'b1 : 1'b0;
      //     // r_rele_6[2] <= (!r_rele_6[0]) & (!r_rele_6[1]);
      //     // r_rele_6[3] <= (!r_rele_6[4]) & (!r_rele_6[5]);
      //     // // exe鏉ョ殑鏁版嵁鍋氶€夋嫨rs1
      //     // r_releData_6[1] <= (w_rs1Addr_4 == w_preRd1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) ? 1'b1 : 1'b0;
      //     // r_exeData_32 <= (r_rele_6[1] == 1'b1 | r_rele_6[5] == 1'b1) ? i_ExeData_96[31:0] : i_ExeData_96[63:32];
      //     // // lsu鏉ョ殑鏁版嵁鍋氶€夋嫨rs1
      //     // r_releData_6[0] <= (w_rs1Addr_4 == w_preRd2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) ? 1'b1 : 1'b0;
      //     // r_lsuData_32 <= (r_rele_6[0] == 1'b1 | r_rele_6[4] == 1'b1) ? i_lsuData_64[31:0] : i_lsuData_64[63:32];
      //     // // exe鏉ョ殑鏁版嵁鍋氶€夋嫨rs2
      //     // r_releData_6[5] <= w_rs2Addr_4 == w_preRd1Addr_4 ? 1'b1 : 1'b0;
      //     // // lsu鏉ョ殑鏁版嵁鍋氶€夋嫨rs2
      //     // r_releData_6[4] <= w_rs2Addr_4 == w_preRd2Addr_4 ? 1'b1 : 1'b0;
      //     // r_releData_6[2] <= r_rele_6[2];
      //     // r_releData_6[3] <= r_rele_6[3];
      //     r_rele_6 <= w_rele_6;
      //     r_releData_6 <= w_releData_6;
      //     // r_exeData_32 <= w_exeData_32;
      //     // r_lsuData_32 <= w_lsuData_32;                  
          
      //   end
      // end

      // 2024.11.3浠巃lways涓嬁鍑烘潵锛岃繖鏄釜缁勫悎閫昏緫銆傛斁鍦╝lways鍐呬細鏈夋椂搴忛棶锟�??????????????
      // 2024.11.4浠庢墽琛屽拰璁垮瓨鏉ョ殑鏃佽矾鍒ゆ柇闇€瑕佷笌涓婃槸涓嶆槸鏈塕n鍜孯m锛屽鏋滄病鏈夌殑璇濅笉浼氭湁鐩稿叧锟�?????
      //11/10 zwm store ins also need 
      // wire w_exeRele0_1, w_exeRele1_1;
      // reg r_preLoad_1;
      // assign w_exeRele0_1 = (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) & !w_rele_6[0] & w_isRn;
      // assign w_exeRele1_1 = (w_rs2Addr_4 == w_preRd1Addr_4 | w_rs2Addr_4 == w_preRdL1Addr_4) & !w_rele_6[4] & w_isRm;


      // assign w_rele_6[1] = (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) & !w_rele_6[0] & w_isRn & ~r_preLoad_1? 1'b1 : 1'b0;
      // assign w_rele_6[0] = ((w_rs1Addr_4 == w_preRd2Addr_4 | w_rs1Addr_4 == w_preRdL2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8)) & w_isRn | w_exeRele0_1 & r_preLoad_1 ? 1'b1 : 1'b0;
      assign w_rele_6[1] = (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8)  & w_isRn ? 1'b1 : 1'b0;
      assign w_rele_6[0] = (w_rs1Addr_4 == w_preRd2Addr_4 | w_rs1Addr_4 == w_preRdL2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8)  & !w_rele_6[1] & w_isRn ? 1'b1 : 1'b0;
      assign w_rele_6[5] = (w_rs2Addr_4 == w_preRd1Addr_4 | w_rs2Addr_4 == w_preRdL1Addr_4) & w_isRm ? 1'b1 : 1'b0;
      assign w_rele_6[4] = (w_rs2Addr_4 == w_preRd2Addr_4 | w_rs2Addr_4 == w_preRdL2Addr_4) & !w_rele_6[5] & w_isRm ? 1'b1 : 1'b0;
      // assign w_rele_6[5] = w_exeRele1_1 & ~r_preLoad_1 ? 1'b1 : 1'b0;
      // assign w_rele_6[4] = ((w_rs2Addr_4 == w_preRd2Addr_4 | w_rs2Addr_4 == w_preRdL2Addr_4))  & w_isRm  | w_exeRele1_1 & r_preLoad_1 ? 1'b1 : 1'b0;
      assign w_rele_6[2] = (!w_rele_6[0]) & (!w_rele_6[1]);
      assign w_rele_6[3] = (!w_rele_6[4]) & (!w_rele_6[5]); 

  // exe鏉ョ殑鏁版嵁鍋氶€夋嫨rs1
  //---------------------------------------------------------big change-------------------------------------------------------//
  //12/10 zwm this need a flag to confirm data from the high or the low
      wire w_exeDataFromHigh_1,w_lsuDataFromHigh_1;
      assign w_exeDataFromHigh_1 = ((w_rs1Addr_4 == w_preRd1Addr_4) & w_isRn | (w_rs2Addr_4 == w_preRd1Addr_4) & w_isRm ) ? 1'b1 : 1'b0;
       assign w_exeData_32 = (w_rele_6[1] == 1'b1 | w_rele_6[5] == 1'b1) ? (w_exeDataFromHigh_1 ? i_ExeData_96[63:32] : i_ExeData_96[31:0] ): 32'b0;
      // lsu鏉ョ殑鏁版嵁鍋氶€夋嫨rs1
      assign w_lsuDataFromHigh_1 = ((w_rs1Addr_4 == w_preRd2Addr_4) & w_isRn | (w_rs2Addr_4 == w_preRd2Addr_4) & w_isRm ) ? 1'b1 : 1'b0;
      assign w_lsuData_32 = (w_rele_6[0] == 1'b1 | w_rele_6[4] == 1'b1) ? (w_lsuDataFromHigh_1 ? i_lsuData_64[63:32] : i_lsuData_64[31:0] ): 32'b0;
    
      // exe鏉ョ殑鏁版嵁鍋氶€夋嫨rs2
      assign w_releData_6[5] = w_rs2Addr_4 == w_preRd1Addr_4 ? 1'b1 : 1'b0;
      // lsu鏉ョ殑鏁版嵁鍋氶€夋嫨rs2
      assign w_releData_6[4] = w_rs2Addr_4 == w_preRd2Addr_4 ? 1'b1 : 1'b0;
    
      assign w_releData_6[2] = w_rele_6[2];
      assign w_releData_6[3] = w_rele_6[3];



  //---------------------------------------------------------big change end-------------------------------------------------------//
      
      wire [5:0] w_rele1_6, w_releData1_6;
      wire [31:0] w_lsuData1_32, w_exeData1_32;
      assign w_rele1_6 = w_rele_6;
      assign w_releData1_6 = w_releData_6;
      assign w_lsuData1_32 = w_lsuData_32;
      assign w_exeData1_32 = w_exeData_32;



  wire w_rs1MergeDriveToRegMerge_1, w_rs2MergeDriveToRegMerge_1,w_regMergeFreeToRs1Merge_1,w_regMergeFreeToRs2Merge_1,
  w_regSelectorDriveToPsrSplitter_1,w_psrSplitterFreeToRegSelector_1,w_regSelectorFreeToRegMerge_1,w_regSeleDriveToExeMerge_1,w_exeMergeFreeToRegSele_1,
  w_psrSpliDriveToIfMerge_1,w_ifMergeFreeToPsrSpli_1, w_regSeleDriToRegImmMerge_1 ;

//update:writeRdFifo杩欎竴閮ㄥ垎绉诲埌鍚庨潰鍘讳�?????????

  wire w_rele6SplitterDriveToRele0MergeSelector_1,w_rele6SplitterDriveToRele1MergeSelector_1, w_rele6SplitterDriveToRele2MergeSelector_1, 
  w_rele6SplitterDriveToRele3MergeSelector_1,w_rele6SplitterDriveToRele4MergeSelector_1, w_rele6SplitterDriveToRele5MergeSelector_1, 
       w_rele0MergeSelectorFreeToRele6Splitter_1,w_rele1MergeSelectorFreeToRele6Splitter_1, w_rele2MergeSelectorFreeToRele6Splitter_1,
       w_rele3MergeSelectorFreeToRele6Splitter_1,w_rele4MergeSelectorFreeToRele6Splitter_1, w_rele5MergeSelectorFreeToRele6Splitter_1, w_psrFreeToExe_1;


  wire w_rele6SplitterDriveToRelo1Merge_1, w_rele6SplitterDriveToRelo2Merge_1, w_rele6SplitterDriveToRelo3Merge_1,
       w_rele6SplitterDriveToRelo4Merge_1, w_rele6SplitterDriveToRelo5Merge_1, w_rele0MergeFreeToRele6Splitter_1,
       w_rele1MergeFreeToRele6Splitter_1, w_rele2MergeFreeToRele6Splitter_1, w_rele3MergeFreeToRele6Splitter_1,
       w_rele4MergeFreeToRele6Splitter_1, w_rele5MergeFreeToRele6Splitter_1, w_rele6SplitterDriveToRelo0Merge_1;

  wire w_releSplitterDriveToRele6SplitterDelay_1;      


//  2025.2.28-->zwm
 delay8U rele6SplitterDelay(.inR(w_releSplitterDriveToRele6Splitter_1), .outR(w_releSplitterDriveToRele6SplitterDelay_1), .rst(rst));  
  //2024/11.14-->zlt ofree too slow
   (* dont_touch="true" *) cSplitter6_6b_launch rele6Splitter(.i_drive(w_releSplitterDriveToRele6SplitterDelay_1), .i_data_6(w_rele1_6), .o_free(w_free),
      .o_driveNext0(w_rele6SplitterDriveToRelo0Merge_1), .i_freeNext0(w_rele0MergeFreeToRele6Splitter_1), .o_data0_1(w_rs1Lsu_1),
      .o_driveNext1(w_rele6SplitterDriveToRelo1Merge_1), .i_freeNext1(w_rele1MergeFreeToRele6Splitter_1), .o_data1_1(w_rs1Exe_1),
      .o_driveNext2(w_rele6SplitterDriveToRelo2Merge_1), .i_freeNext2(w_rele2MergeFreeToRele6Splitter_1), .o_data2_1(w_rs1Grf_1),
      .o_driveNext3(w_rele6SplitterDriveToRelo3Merge_1), .i_freeNext3(w_rele3MergeFreeToRele6Splitter_1), .o_data3_1(w_rs2Grf_1),
      .o_driveNext4(w_rele6SplitterDriveToRelo4Merge_1), .i_freeNext4(w_rele4MergeFreeToRele6Splitter_1), .o_data4_1(w_rs2Lsu_1),
      .o_driveNext5(w_rele6SplitterDriveToRelo5Merge_1), .i_freeNext5(w_rele5MergeFreeToRele6Splitter_1), .o_data5_1(w_rs2Exe_1),
      .rst(rst));

  reg r_isExeOne_1, r_isLsuOne_1;
  wire w_isExeOne_1, w_isLsuOne_1;

  assign w_isExeOne_1 = r_isExeOne_1;
  assign w_isLsuOne_1 = r_isLsuOne_1;


  wire w_rele0driveToMe1_1, w_rele1driveToMe1_1, w_rele1driveToMe_1, w_rele0driveToMe_1;
  wire w_driveToExeMer, w_driveToLsuMer;
  wire w_exeMerFree, w_lsuMerFree;

  // zlt --2024.10.24 淇�????????? -->閫夋嫨鐢ㄥ摢涓猟rive锛屽垽鏂潯浠朵负鍚庣画娴佹按绾ф湁娌℃湁鎸囦�?????????-->璁℃暟鏂瑰紡锛涘悗闈㈡祦姘寸骇娌℃湁鏁版嵁鏃堕€氳繃鍒氳繘鍏ュ垎娲炬ā鍧楃殑drive鏉ラ┍锟�??????????????
  (* dont_touch="true" *) cSelector2_1b exeSele0(.i_drive(i_decoderDriveToLaunch_1), .i_data_1(!w_isExeOne_1), .o_free(),
      .o_driveNext0(w_driveToExeMer), .i_freeNext0(w_exeMerFree), .o_data0_1(),
      .o_driveNext1(w_rele0driveToMe_1), .i_freeNext1(w_rele0driveToMe1_1), .o_data1_1(),
      .rst(rst)); // exe     // 澶勭悊绗竴娆℃病鏈夋墽琛岀殑鏃佽矾
  delay4U isOneSeleDelay0(.inR(w_rele0driveToMe_1), .outR(w_rele0driveToMe1_1), .rst(rst));  

  (* dont_touch="true" *) cSelector2_1b lsuSele1(.i_drive(i_decoderDriveToLaunch_1), .i_data_1(!w_isLsuOne_1), .o_free(),
    .o_driveNext0(w_driveToLsuMer), .i_freeNext0(w_lsuMerFree), .o_data0_1(),
    .o_driveNext1(w_rele1driveToMe_1), .i_freeNext1(w_rele1driveToMe1_1), .o_data1_1(),
    .rst(rst)); // lsu        // 澶勭悊绗竴娆℃病鏈夎瀛樼殑鏃佽矾
  delay4U isOneSeleDelay1(.inR(w_rele1driveToMe_1), .outR(w_rele1driveToMe1_1), .rst(rst)); 
  
  // zlt ---2024.10.24 鏂板�????????? -->鍚庨潰娴佹按绾ф病鏈夋暟鎹椂閫氳繃鍒氳繘鍏ュ垎娲炬ā鍧楃殑drive鏉ラ┍鍔紝鍚庨潰娴佹按鏈夋寚浠ょ殑璇濆氨鐩存帴鐀��梺璺殑drive锟�?????

  wire w_ExeDriveToLunch_1, w_LsuDriveToLunch_1,w_LsuDriveToLunch1_1;
  
  wire w_launchFreeToExe_1, w_launchFreeToLsu_1,w_launchFreeToLsu1_1;
  


  wire i_exeDriveToLunch1_1;
  delay4U exeDelay0(.inR(i_ExeDriveToLunch_1), .outR(i_exeDriveToLunch1_1), .rst(rst)); 
  (* dont_touch="true" *) cMutexMerge2_1b exeMerge(.i_drive0(i_exeDriveToLunch1_1), .i_data0_1(1'b0), .o_free0(o_launchFreeToExe_1),
      .i_drive1(w_driveToExeMer), .i_data1_1(1'b0), .o_free1(w_exeMerFree),
      .i_freeNext(w_launchFreeToExe_1), .o_driveNext(w_ExeDriveToLunch_1), .o_data_1(),
      .rst(rst));
  

  wire i_LsuDriveToLunch1_1;
  delay4U lsuDelay0(.inR(i_LsuDriveToLunch_1), .outR(i_LsuDriveToLunch1_1), .rst(rst)); 
  (* dont_touch="true" *) cMutexMerge2_1b lsuMerge(.i_drive0(i_LsuDriveToLunch1_1), .i_data0_1(1'b0), .o_free0(o_launchFreeToLsu_1),
      .i_drive1(w_driveToLsuMer), .i_data1_1(1'b0), .o_free1(w_lsuMerFree),
      .i_freeNext(w_launchFreeToLsu_1), .o_driveNext(w_LsuDriveToLunch_1), .o_data_1(),
      .rst(rst));
  
  //1/8 zwm can add a cfifo
      // cFifo1 lsuDelayFifo(.i_drive(w_LsuDriveToLunch1_1), .i_freeNext(w_launchFreeToLsu_1), .rst(rst),
      // .o_free(w_launchFreeToLsu1_1), .o_driveNext(w_LsuDriveToLunch_1), .o_fire_1());
  
  // grf鏉ョ殑drive

  wire [63:0] w_rsData_64;
  wire w_grfSrfMerDriToGrfSpli_1,w_grfSpliFreeToGrfSrfMer_1,w_rs2MergeFreeToRele3Selector_1,w_rs2MergeFreeToRele5Selector_1,w_rele5SelectorDriveToMe_1,w_grfSplitterDriveToRele3Merge_1;

  (* dont_touch="true" *) cMutexMerge2_64b_launch grfSrfMerge(.i_drive0(i_GrfDriveToLaunch_1), .i_data0_64(i_rsData_64), .o_free0(o_launchFreeToGrf_1),
      .i_drive1(i_SrfDriveToLaunch_1), .i_data1_64({32'b0, i_sRsData_32}), .o_free1(o_launchFreeToSrf_1),
      .i_freeNext(w_grfSpliFreeToGrfSrfMer_1), .o_driveNext(w_grfSrfMerDriToGrfSpli_1), .o_data_64(w_rsData_64),
      .rst(rst));

  wire w_grfSplitterDriveToRele2Merge_1, w_rs2MergeFreeToRele4Selector_1;
  wire w_rele3MergeFreeToGrfSplitter_1;

  (* dont_touch="true" *) cSplitter2_64b_launch grfSplitter(.i_drive(w_grfSrfMerDriToGrfSpli_1), .i_data_64(w_rsData_64), .o_free(w_grfSpliFreeToGrfSrfMer_1),
      .o_driveNext0(w_grfSplitterDriveToRele2Merge_1), .i_freeNext0(w_rele2MergeFreeToGrfSplitter_1), .o_data0_32(w_rs1Data_32),
      .o_driveNext1(w_grfSplitterDriveToRele3Merge_1), .i_freeNext1(w_rele3MergeFreeToGrfSplitter_1), .o_data1_32(w_rs2Data_32),
      .rst(rst));


//----------------------------------------------big change---------------------------------------------//
/*
1/27 zwm 由于waitmerge的两个drive可能有先后顺序，数据先稳定的drive1的数据需要暂存一�???
*/
reg r_rs1Exe_1,r_rs2Exe_1;
wire w_rs1Exe1_1,w_rs2Exe1_1;
wire w_rele6SplitterDriveToRelo1MergeDelay_1;
delay6U rele1AndRele5MergeDelay1(.inR(w_rele6SplitterDriveToRelo1Merge_1), .outR(w_rele6SplitterDriveToRelo1MergeDelay_1), .rst(rst)); 
always @(posedge w_rele6SplitterDriveToRelo1MergeDelay_1 or negedge rst) begin
  if(!rst)begin
    r_rs1Exe_1 <= 1'b0;
    r_rs2Exe_1 <= 1'b0;
  end else begin
    r_rs1Exe_1 <= w_rs1Exe_1;
    r_rs2Exe_1 <= w_rs2Exe_1;
  end
end
assign w_rs1Exe1_1 = r_rs1Exe_1;
assign w_rs2Exe1_1 = r_rs2Exe_1;
//----------------------------------------------change end---------------------------------------------//

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele0Merge(.i_drive0(w_LsuDriveToLunch_1), .i_data0_32(w_lsuData_32), .o_free0(w_rele0MergeFreeToLsu_1),
      .i_drive1(w_rele6SplitterDriveToRelo0Merge_1), .i_data1_1(w_rs1Lsu_1), .o_free1(w_rele0MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele0MergeDriveToRele0Selector_1), .o_data_33(w_rele0Data_33), .i_freeNext(w_rele0SelectorFreeToRele0Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele1Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(w_exeData_32), .o_free0(w_rele1MergeFreeToExe_1),
      .i_drive1(w_rele6SplitterDriveToRelo1Merge_1), .i_data1_1(w_rs1Exe1_1), .o_free1(w_rele1MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele1MergeDriveToRele1Selector_1), .o_data_33(w_rele1Data_33), .i_freeNext(w_rele1SelectorFreeToRele1Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele2Merge(.i_drive0(w_grfSplitterDriveToRele2Merge_1), .i_data0_32(w_rs1Data_32), .o_free0(w_rele2MergeFreeToGrfSplitter_1),
      .i_drive1(w_rele6SplitterDriveToRelo2Merge_1), .i_data1_1(w_rs1Grf_1), .o_free1(w_rele2MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele2MergeDriveToRele2Selector_1), .o_data_33(w_rele2Data_33), .i_freeNext(w_rele2SelectorFreeToRele2Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele3Merge(.i_drive0(w_grfSplitterDriveToRele3Merge_1), .i_data0_32(w_rs2Data_32), .o_free0(w_rele3MergeFreeToGrfSplitter_1),
      .i_drive1(w_rele6SplitterDriveToRelo3Merge_1), .i_data1_1(w_rs2Grf_1), .o_free1(w_rele3MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele3MergeDriveToRele3Selector_1), .o_data_33(w_rele3Data_33), .i_freeNext(w_rele3SelectorFreeToRele3Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele4Merge(.i_drive0(w_LsuDriveToLunch_1), .i_data0_32(w_lsuData_32), .o_free0(w_rele4MergeFreeToLsu_1),
      .i_drive1(w_rele6SplitterDriveToRelo4Merge_1), .i_data1_1(w_rs2Lsu_1), .o_free1(w_rele4MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele4MergeDriveToRele4Selector_1), .o_data_33(w_rele4Data_33), .i_freeNext(w_rele4SelectorFreeToRele4Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele5Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(w_exeData_32), .o_free0(w_rele5MergeFreeToExe_1),
      .i_drive1(w_rele6SplitterDriveToRelo5Merge_1), .i_data1_1(w_rs2Exe1_1), .o_free1(w_rele5MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele5MergeDriveToRele5Selector_1), .o_data_33(w_rele5Data_33), .i_freeNext(w_rele5SelectorFreeToRele5Merge_1),
      .rst(rst));


  // assign w_launchFreeToLsu_1 = w_rele0MergeFreeToLsu_1 | w_rele4MergeFreeToLsu_1;
  // assign w_launchFreeToExe_1 = w_rele1MergeFreeToExe_1 | w_rele5MergeFreeToExe_1 | w_psrFreeToExe_1;
  assign w_launchFreeToLsu_1 = w_rele0MergeFreeToLsu_1;
  assign w_launchFreeToExe_1 = w_rele1MergeFreeToExe_1;

  wire w_rele1MergeDrive1ToRele1Selector_1, w_rele2MergeDrive1ToRele2Selector_1, w_rele3MergeDrive1ToRele3Selector_1,
       w_rele4MergeDrive1ToRele4Selector_1, w_rele5MergeDrive1ToRele5Selector_1,w_rele0MergeDrive1ToRele0Selector_1;

  wire w_rele0SelectorDriveToMeDelay_1,w_rele1SelectorDriveToMeDelay_1,w_rele2SelectorDriveToMeDelay_1,w_rele3SelectorDriveToMeDelay_1,w_rele4SelectorDriveToMeDelay_1,w_rele5SelectorDriveToMeDelay_1;    
  (* dont_touch="true" *) cSelector2_33b_launch rele0Selector(.i_drive(w_rele0MergeDriveToRele0Selector_1), .i_data_33(w_rele0Data_33), .o_free(w_rele0SelectorFreeToRele0Merge_1),
                               .o_driveNext0(w_rele0SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele0Selector_1), .o_data0_32(w_lsuRs1Data_32),
                               .o_driveNext1(w_rele0SelectorDriveToMe_1), .i_freeNext1(w_rele0SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay0 (.inR(w_rele0SelectorDriveToMe_1), .outR(w_rele0SelectorDriveToMeDelay_1), .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele1Selector(.i_drive(w_rele1MergeDriveToRele1Selector_1), .i_data_33(w_rele1Data_33), .o_free(w_rele1SelectorFreeToRele1Merge_1),
                               .o_driveNext0(w_rele1SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele1Selector_1), .o_data0_32(w_exeRs1Data_32),
                               .o_driveNext1(w_rele1SelectorDriveToMe_1), .i_freeNext1(w_rele1SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay1 (.inR(w_rele1SelectorDriveToMe_1), .outR(w_rele1SelectorDriveToMeDelay_1), .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele2Selector(.i_drive(w_rele2MergeDriveToRele2Selector_1), .i_data_33(w_rele2Data_33), .o_free(w_rele2SelectorFreeToRele2Merge_1),
                               .o_driveNext0(w_rele2SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele2Selector_1), .o_data0_32(w_grfRs1Data_32),
                               .o_driveNext1(w_rele2SelectorDriveToMe_1), .i_freeNext1(w_rele2SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay2 (.inR(w_rele2SelectorDriveToMe_1), .outR(w_rele2SelectorDriveToMeDelay_1), .rst(rst));                               
  (* dont_touch="true" *) cSelector2_33b_launch rele3Selector(.i_drive(w_rele3MergeDriveToRele3Selector_1), .i_data_33(w_rele3Data_33), .o_free(w_rele3SelectorFreeToRele3Merge_1),
                               .o_driveNext0(w_rele3SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele3Selector_1), .o_data0_32(w_grfRs2Data_32),
                               .o_driveNext1(w_rele3SelectorDriveToMe_1), .i_freeNext1(w_rele3SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay3 (.inR(w_rele3SelectorDriveToMe_1), .outR(w_rele3SelectorDriveToMeDelay_1), .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele4Selector(.i_drive(w_rele4MergeDriveToRele4Selector_1), .i_data_33(w_rele4Data_33), .o_free(w_rele4SelectorFreeToRele4Merge_1),
                               .o_driveNext0(w_rele4SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele4Selector_1), .o_data0_32(w_lsuRs2Data_32),
                               .o_driveNext1(w_rele4SelectorDriveToMe_1), .i_freeNext1(w_rele4SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay4 (.inR(w_rele4SelectorDriveToMe_1), .outR(w_rele4SelectorDriveToMeDelay_1), .rst(rst));                               
  (* dont_touch="true" *) cSelector2_33b_launch rele5Selector(.i_drive(w_rele5MergeDriveToRele5Selector_1), .i_data_33(w_rele5Data_33), .o_free(w_rele5SelectorFreeToRele5Merge_1),
                               .o_driveNext0(w_rele5SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele5Selector_1), .o_data0_32(w_exeRs2Data_32),
                               .o_driveNext1(w_rele5SelectorDriveToMe_1), .i_freeNext1(w_rele5SelectorDriveToMeDelay_1), .o_data1_32(),
                               .rst(rst));
(* dont_touch="true" *)delay4U outdelay5 (.inR(w_rele5SelectorDriveToMe_1), .outR(w_rele5SelectorDriveToMeDelay_1), .rst(rst));
  wire w_regSeleDriToIfMerge_1, w_ifMergeFreeToRegSele_1;

  wire w_regSeleDriToOpDataFifo_1, w_opDataFifoFreeToRegSele_1,w_regImmMergeFreeToRegSele_1;
  wire w_regSeleDriToPcsele_1,w_PcSeleFreeToRegSele_1,w_PcSeleDriToMe_1;

  (* dont_touch="true" *) cMutexMerge3_32b_launch rs1Merge(.i_drive0(w_rele0SelectorDriveToRs1Merge_1), .i_data0_32(w_lsuRs1Data_32), .o_free0(w_rs1MergeFreeToRele0Selector_1),
      .i_drive1(w_rele1SelectorDriveToRs1Merge_1), .i_data1_32(w_exeRs1Data_32), .o_free1(w_rs1MergeFreeToRele1Selector_1),
      .i_drive2(w_rele2SelectorDriveToRs1Merge_1), .i_data2_32(w_grfRs1Data_32), .o_free2(w_rs1MergeFreeToRele2Selector_1),
      .i_freeNext(w_regMergeFreeToRs1Merge_1), .o_driveNext(w_rs1MergeDriveToRegMerge_1), .o_data_32(w_lastRs1Data_32),
      .rst(rst));

  (* dont_touch="true" *) cMutexMerge3_32b_launch rs2Merge(.i_drive0(w_rele3SelectorDriveToRs2Merge_1), .i_data0_32(w_grfRs2Data_32), .o_free0(w_rs2MergeFreeToRele3Selector_1),
                            .i_drive1(w_rele4SelectorDriveToRs2Merge_1), .i_data1_32(w_lsuRs2Data_32), .o_free1(w_rs2MergeFreeToRele4Selector_1),
                            .i_drive2(w_rele5SelectorDriveToRs2Merge_1), .i_data2_32(w_exeRs2Data_32), .o_free2(w_rs2MergeFreeToRele5Selector_1),
                            .i_freeNext(w_regMergeFreeToRs2Merge_1), .o_driveNext(w_rs2MergeDriveToRegMerge_1), .o_data_32(w_lastRs2Data_32),
                            .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_64b_launch regMerge(.i_drive0(w_rs1MergeDriveToRegMerge_1), .i_data0_32(w_lastRs1Data_32), .o_free0(w_regMergeFreeToRs1Merge_1),
      .i_drive1(w_rs2MergeDriveToRegMerge_1), .i_data1_32(w_lastRs2Data_32), .o_free1(w_regMergeFreeToRs2Merge_1),
      .i_freeNext(w_regSelectorFreeToRegMerge_1), .o_driveNext(w_regMergeDriveToRegSelector_1), .o_data_64(w_Rs1AndRs2Data_64),
      .rst(rst));

//瀛樹笂涓€鏉℃寚浠ょ殑鍦板潃

      reg [3:0] r_preRd1Addr_4;
      reg [3:0] r_preRd2Addr_4;
      reg [3:0] r_preRdL1Addr_4;
      reg [3:0] r_preRdL2Addr_4;
      
      reg [7:0] r_preSRd1Addr_8;
      reg [7:0] r_preSRd2Addr_8;
      
      reg [1:0] r_cont_2; // 浠ｈ〃鍓嶉潰鏈夊嚑鏉℃寚锟�?????
      
      //update:鍒濆澶嶄綅鐨勫€兼湁鏀瑰姩
      //姣忔寮€濮嬫椂锛氱┖娉℃垨鑰呬腑鏂紓甯革紝閮借鎶妏rerd鐨勫€奸噸鏂板彉涓哄垵濮嬶拷? -->zlt--->2024.11.4
      //闇€瑕佸湪cont鏀瑰彉涔嬪悗鍐嶅仛-->zlt-->11,4-->瑙﹀彂鑴夊啿鏀瑰彉锟�?????


//------------------------------------------big change------------------------------------------------//
//12/10 zwm if the inst is just has 1 rd,we should first store the r_preRdL the the r_preRdH
      always @(posedge o_launchDriveToExe_1 or negedge rst) begin
        if (!rst) begin
          r_preRd1Addr_4 = 4'hf;
          r_preRd2Addr_4 = 4'hf;
          r_preRdL1Addr_4 = 4'hf;
          r_preRdL2Addr_4 = 4'hf;
          r_preSRd1Addr_8 = 8'b0;
          r_preSRd2Addr_8 = 8'b0;
          // r_preLoad_1 = 1'b0;
        end else begin
          if(r_cont_2 == 0) begin
            r_preRd1Addr_4 = 4'hf;
            r_preRd2Addr_4 = 4'hf;
            r_preRdL1Addr_4 = 4'hf;
            r_preRdL2Addr_4 = 4'hf;
            r_preSRd1Addr_8 = 8'b0;
            r_preSRd2Addr_8 = 8'b0;
            // r_preLoad_1 = 1'b0;
          end else if(w_isLS_1 & !w_load_1 & !w_isMultiLS_1) begin
            r_preRd2Addr_4 = r_preRd1Addr_4;
            r_preRd1Addr_4 = 4'hf;
            r_preRdL2Addr_4 = r_preRdL1Addr_4;
            r_preRdL1Addr_4 = 4'hf;
            r_preSRd2Addr_8 = r_preSRd1Addr_8;
            r_preSRd1Addr_8 = w_sRdAddr1_8; 
            // r_preLoad_1 = 1'b0;
          end 
          // else if(w_isLS_1 & w_load_1 & !w_isMultiLS_1) begin
          //   r_preRd2Addr_4 = w_rdAddr1_4;
          //   r_preRd1Addr_4 = 4'hf;
          //   r_preRdL2Addr_4 = w_dLo_4;
          //   r_preRdL1Addr_4 = 4'hf;
          //   r_preSRd2Addr_8 = r_preSRd1Addr_8;
          //   r_preSRd1Addr_8 = w_sRdAddr1_8; 
            // r_preLoad_1 = 1'b0;
          // end 
          else begin
            // r_preLoad_1 = w_load_1;
            if(i_wen_2 == 2'b11)begin
              r_preRd2Addr_4 = r_preRd1Addr_4;
              r_preRd1Addr_4 = w_rdAddr1_4;
              r_preRdL2Addr_4 = r_preRdL1Addr_4;
              r_preRdL1Addr_4 = w_dLo_4;
              r_preSRd2Addr_8 = r_preSRd1Addr_8;
              r_preSRd1Addr_8 = w_sRdAddr1_8;    
            end else begin
              r_preRd2Addr_4 =  r_preRd1Addr_4;
              r_preRd1Addr_4 =  4'hf;
              r_preRdL2Addr_4 = r_preRdL1Addr_4;
              r_preRdL1Addr_4 = w_rdAddr1_4;
              r_preSRd2Addr_8 = r_preSRd1Addr_8;
              r_preSRd1Addr_8 = w_sRdAddr1_8;  
            end
          end
      end
    end
      // 鏂板�?????????--->zlt
      //11/10 zwm -> if no multiLS for long time ,r_cont_2 will boom!!!
    //11/27 zwm ->w_load_1 = 1 maybe not load inst
    wire w_regMergeDriveToRegSelector1_1;
    wire w_driveFExcToIf_1;
    delay8U driveFExcToIfDelay(.inR(i_driveFExcToIf_1), .outR(w_driveFExcToIf_1), .rst(rst));  

    assign w_regMergeDriveToRegSelector1_1 = w_driveFExcToIf_1 | w_regMergeDriveToRegSelector_1;
      always @(posedge w_regMergeDriveToRegSelector1_1 or negedge rst) begin
        if (!rst) begin
          r_cont_2 <= 2'b0;
          r_isExeOne_1 <= 1'b0;
          r_isLsuOne_1 <= 1'b0;
        end else begin
          // if(w_isMultiLS_1 | w_load_1 & w_isLS_1 | i_isInInt & w_bx_1 | decNum_4 != 4'b1111 | exeNum_4!= 4'b1111 | i_excToIfFlag_1) begin
          if(w_isMultiLS_1 | w_load_1 & w_isLS_1 | i_isInInt & w_bx_1 | i_excToIfFlag_1 | w_bit_1) begin
            r_cont_2 <= 2'b0;
            r_isExeOne_1 <= 1'b0;
            r_isLsuOne_1 <= 1'b0;
          end else begin
              r_isExeOne_1 <= 1'b1;
            if (r_cont_2 <= 2'b01) begin
              r_cont_2 <= r_cont_2 + 1;
            end
            if(r_cont_2 >= 2'b01) begin
              r_isLsuOne_1 <= 1'b1;
            end
          end
        end
      end
      // 2024.11.3 鍙兘闇€瑕佷慨鏀规潯浠讹紝姣忔鐨勫姞绌烘场鎴栬€呬腑鏂紓甯搁兘瑕佽嚜宸变骇鐢熸梺锟�?????

     assign {w_preRdL2Addr_4, w_preRdL1Addr_4,w_preRd2Addr_4, w_preRd1Addr_4, w_preSRd2Addr_8, w_preSRd1Addr_8} =  {r_preRdL2Addr_4,r_preRdL1Addr_4,r_preRd2Addr_4,r_preRd1Addr_4,r_preSRd2Addr_8,r_preSRd1Addr_8};



    //  wire w_writeRdFifoDrive1_1;
//   (* dont_touch="true" *) cFifo1_16_32b_launch writeRdFifo(.i_drive(w_releSplitterDriveToWriteRdFifo_1), .i_data_16({w_dLo_4, w_rdAddr1_4, w_sRdAddr1_8}), .o_free(w_WriteRdFifoFreeToReleSplitter_1),
//   .o_driveNext(w_writeRdFifoDrive_1), .o_data_32({w_preRdL2Addr_4, w_preRdL1Addr_4,w_preRd2Addr_4, w_preRd1Addr_4, w_preSRd2Addr_8, w_preSRd1Addr_8}), .i_freeNext(w_writeRdFifoDrive1_1),
//   .rst(rst)); // 鍙互鍐欐參鐐瑰氨鍙互鍘绘帀涓婇潰鐨勫瘎瀛樺櫒锛岃繖鏍锋暟鎹氨宸茬粡浼犲埌鍚庨潰鏇存敼浜嗕篃鏃犳墍锟�?????
// delay4U writeDelay0(.inR(w_writeRdFifoDrive_1), .outR(w_writeRdFifoDrive1_1), .rst(rst));

  //杩欓噷鍚嶅瓧鏄痵elector浣嗘槸瀹為檯涓婃槸splitter
  (* dont_touch="true" *) cSplitter2_96b_launch regSelector(.i_drive(w_regMergeDriveToRegSelector_1), .i_data_96({w_pc_32, w_Rs1AndRs2Data_64}), .o_free(w_regSelectorFreeToRegMerge_1),
      .o_driveNext0(w_regSeleDriToPcsele_1), .o_data0_32(w_pc1_32), .i_freeNext0(w_regImmMergeFreeToRegSele_1),// ifree0 is w_PcSeleFreeToRegSele_1;
      .o_driveNext1(w_regSeleDriToRegImmMerge_1), .o_data1_64(w_lastRs1AndRs2Data_64), .i_freeNext1(w_regImmMergeFreeToRegSele_1),
      .rst(rst));

  wire w_regSeleDri1ToPcsele_1,w_regSeleDri1ToPcsele1_1;
  //12/8 !!! zwm due to PC maybe come from wb,so this should add condition and delay
  (* dont_touch="true" *) wire [15:0] w_registers_16;
  wire w_pcComeFromWbFlag_1;
  wire w_pcFlag_1;
  assign w_pcFlag_1 = ~w_isB_1 & ~w_pcComeFromWbFlag_1;
  assign w_pcComeFromWbFlag_1 = w_load_1 & (w_dHi_4 == 4'b1111 || w_registers_16[15] == 1'b1) & w_isLS_1;
  delay8U pcDelay0(.inR(i_decoderDriveToLaunch_1), .outR(w_regSeleDri1ToPcsele_1), .rst(rst));
  delay8U pcDelay1(.inR(w_regSeleDri1ToPcsele_1), .outR(w_regSeleDri1ToPcsele1_1), .rst(rst));
  (* dont_touch="true" *) cSelector2_1b_launch PcSelector(.i_drive(w_regSeleDri1ToPcsele1_1), .i_data_1(w_pcFlag_1), .o_free(w_PcSeleFreeToRegSele_1),
      .o_driveNext0(o_launchDriveToIf_1), .i_freeNext0(i_IfFreeToLaunch_1), .o_data0_1(),
      .o_driveNext1(w_PcSeleDriToMe_1), .i_freeNext1(w_PcSeleDriToMe_1), .o_data1_1(),
      .rst(rst));
  assign o_pc_32 = w_is16_1 ? w_pc1_32 + 2 : w_pc1_32 + 4;
  // 5.23 杩橀渶锟�???????????????鐐规敼鍔紝鍚庨潰鎺ヤ竴涓嫨璺紝锟�??????璺幓椤哄簭鍙栨寚锛屽彟锟�??????璺幓澶勭悊璺宠浆锟�???????????????


  wire w_immSplitterDriveToZeroFifo_1,w_immSplitterDriveToSignFifo_1,w_immSplitterDriveToDecoFifo_1,w_immSplitterDriveToThumbFifo_1,
       w_zeroFifoFreeToImmSplitter_1,w_signFifoFreeToImmSplitter_1,w_decoFifoFreeToImmSplitter_1,w_thumbFifoFreeToImmSplitter_1,
       w_zeroFifoDriveToImmMerge_1,w_signFifoDriveToImmMerge_1,w_decoFifoDriveToImmMerge_1,w_thumbFifoDriveToImmMerge_1,
       w_immMergeFreeToZeroFifo_1,w_immMergeFreeToSignFifo_1,w_immMergeFreeToDecoFifo_1,w_immMergeFreeToThumbFifo_1,
       w_immMergeToImmExeMerge_1,w_exeMergeFreeToImmMerge_1,w_ifMergeFreeToExeSpli_1,w_exeSpliDriveToIfMerge_1,w_wGrfSpliDriToIfMerge_1,
       w_ifMergeFreeTowGrfSpli_1 ;



  // imm鎵╁�?????????

    (* dont_touch="true" *) wire w_ImmSeleDriToImmSpli_1, w_ImmSeleDriToImmExeMerge_1,w_immExeMergeFreeToImmSele_1,w_ImmSpliFreeToImmSele_1;
    (* dont_touch="true" *) wire w_ImmSeleDri1ToImmExeMerge_1, w_immExeMergeFree1ToImmSele_1;
    (* dont_touch="true" *) wire [25:0] w_ImmSeleData0_26;
    (* dont_touch="true" *) wire [25:0] w_ImmSeleData1_26;
    (* dont_touch="true" *) wire [23:0] w_zeroData_24, w_signData_24, w_decoData_24, w_thumbData_24;


  wire w_launchSpliDri1ToImmSele_1,w_launchSpliDri2ToImmSele_1;
  delay4U immDelay0(.inR(w_launchSpliDriToImmSele_1), .outR(w_launchSpliDri1ToImmSele_1), .rst(rst));  
  delay4U immDelay1(.inR(w_launchSpliDri1ToImmSele_1), .outR(w_launchSpliDri2ToImmSele_1), .rst(rst));
    
  (* dont_touch="true" *) cSelector3_28b_launch ImmSelector (.i_drive(w_launchSpliDri2ToImmSele_1), .i_data_28({w_isImm_1, w_pushPopReg_1, w_launchSpliData1_26}), .o_free(w_ImmSeleFreeToLaunchSpli_1),
      .o_driveNext0(w_ImmSeleDriToImmSpli_1), .i_freeNext0(w_ImmSpliFreeToImmSele_1), .o_data0_26(w_ImmSeleData0_26),
      .o_driveNext1(w_ImmSeleDriToImmExeMerge_1), .i_freeNext1(w_immExeMergeFreeToImmSele_1), .o_data1_26(w_ImmSeleData1_26),
      .o_driveNext2(w_ImmSeleDri1ToImmExeMerge_1), .i_freeNext2(w_immExeMergeFree1ToImmSele_1), .o_data2_16(w_registers_16),
      .rst(rst)); // 淇敼鏉′欢

  (* dont_touch="true" *) cSelector4_26b_launch ImmSplitter (.i_drive(w_ImmSeleDriToImmSpli_1), .i_data_26(w_ImmSeleData0_26), .o_free(w_ImmSpliFreeToImmSele_1),
      .o_driveNext0(w_immSplitterDriveToZeroFifo_1), .i_freeNext0(w_zeroFifoFreeToImmSplitter_1), .o_data0_24(w_zeroData_24),
      .o_driveNext1(w_immSplitterDriveToSignFifo_1), .i_freeNext1(w_signFifoFreeToImmSplitter_1),.o_data1_24(w_signData_24),
      .o_driveNext2(w_immSplitterDriveToDecoFifo_1), .i_freeNext2(w_decoFifoFreeToImmSplitter_1),.o_data2_24(w_decoData_24),
      .o_driveNext3(w_immSplitterDriveToThumbFifo_1), .i_freeNext3(w_thumbFifoFreeToImmSplitter_1),.o_data3_24(w_thumbData_24),
      .rst(rst)); //鍏跺疄鏄嫨璺紝鍚嶅瓧璧烽敊锟�???????????????

  // 锟�??????瑕佽瘧鐮佹ā鍧楃粺璁′竴鍏卞灏戠imm锛宨mm鎵╁睍绫诲瀷鍜屽灏戜綅鐨刬mm   5锟�??????8锟�??????12锟�??????16 -> 00锟�??????01 锟�??????10锟�?????? 11
  // 16浣嶇殑鎸囦护 imm锟�??????3浣嶏�???????????5浣嶏�???????????7浣嶏�???????????8浣嶏�???????????11锟�??????

  // imm 16浣嶏�??????????锟芥墿灞曟柟锟�??????2浣嶏紝imm绉嶇被涓変綅 3锟�??????5锟�??????7锟�??????8锟�??????11锟�??????12锟�??????16

  assign w_saturate_5 = w_satImmOrWidthm_5 + 1;

  assign {w_zeroimm16_1, w_zeroimm12_1, w_zeroimm8_1, w_zeroimm5_1, w_zeroimm2_1, w_zeroimm11_1, w_zeroimm7_1, w_zeroimm3_1} = w_zeroData_24[23:16];
  assign {w_signimm16_1, w_signimm12_1, w_signimm8_1, w_signimm5_1, w_signimm2_1, w_signimm11_1, w_signimm7_1, w_signimm3_1} = w_signData_24[23:16];
  assign {w_decoimm16_1, w_decoimm12_1, w_decoimm8_1, w_decoimm5_1, w_decoimm2_1, w_decoimm11_1, w_decoimm7_1, w_decoimm3_1} = w_decoData_24[23:16];
  assign {w_thumbimm16_1, w_thumbimm12_1, w_thumbimm8_1, w_thumbimm5_1, w_thumbimm2_1, w_thumbimm11_1, w_thumbimm7_1, w_thumbimm3_1} = w_thumbData_24[23:16];
  assign w_zeroImm_16 = w_zeroData_24[15:0];
  assign w_signImm_16 = w_signData_24[15:0];
  assign w_decoImm_16 = w_decoData_24[15:0];
  assign w_thumbImm_16 = w_thumbData_24[15:0];

  assign w_imm_5 = w_launchSpliData1_26[4:0];

  // 0鎵╁�?????????-->锟�??????瑕佷袱涓浂鎵╁睍锛屽洜涓烘湁鎸囦护鍖呮嫭涓や釜鎿嶄綔鏁帮紝浣嗘槸閮芥槸浜斾綅鐨勬搷浣滄�?????????-->浣嶆搷浣滃拰楗卞拰杩愮畻---->鍚庨潰閭ｄ竴浣嶄笉绠楀仛imm锛屽綋浣滀竴涓櫘閫氱殑鎿嶄綔锟�??????
  // 楗卞拰杩愮畻鏈変竴锟�???????????????5浣嶇殑绔嬪嵆鏁伴渶瑕侊紜1---->杩樻湭澶勭悊-->宸茬粡澶勭悊
  //11/22 zwm w_zeroImm_16 may be combine with {a,b,2'b0},so we just use w_zeroImm_16,not w_zeroImm_16[3:0] etc

  // assign w_immZero_32 = {{32{w_zeroimm5_1}} & {28'b0, w_zeroImm_16[3:0]}}
  //        | {{32{w_zeroimm8_1}} & {25'b0, w_zeroImm_16[6:0]}}
  //        | {{32{w_zeroimm12_1}} & {20'b0, w_zeroImm_16[11:0]}}
  //        | {{32{w_zeroimm16_1}} & {16'b0, w_zeroImm_16}}
  //        | {{32{w_zeroimm3_1}} & {29'b0, w_zeroImm_16[2:0]}}
  //        | {{32{w_zeroimm2_1}} & {30'b0, w_zeroImm_16[1:0]}}
  //        | {{32{w_zeroimm7_1}} & {15'b0, w_zeroImm_16[6:0]}}
  //        | {{32{w_zeroimm11_1}} & {22'b0, w_zeroImm_16[10:0]}};
  assign w_immZero_32 = {{32{w_zeroimm5_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm8_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm12_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm16_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm3_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm2_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm7_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm11_1}} & {16'b0, w_zeroImm_16}};

  wire w_ucb32Bit_1;
  assign w_ucb32Bit_1 = w_ucB_1 & ~w_is16_1;
  //not consider cb32bit

  // 绗﹀彿鎵╁睍
  //12/3 zwm w_bl_1 is not 32bit change 6{i_blImm9_9[8]}} to 7{i_blImm9_9[8]}}
  assign w_immSign_32 = {{32{w_signimm5_1 & ~w_bl_1 & ~w_ucb32Bit_1}} & {{28{w_signImm_16[4]}}, w_signImm_16[4:0]}}
         | {{32{w_signimm8_1 & ~w_bl_1 & ~w_ucb32Bit_1}} & {{23{w_signImm_16[8]}}, w_signImm_16[8:0]}}
         | {{32{w_signimm12_1 & ~w_bl_1 & ~w_ucb32Bit_1}} & {{21{w_signImm_16[11]}}, w_signImm_16[11:0]}}
         | {{32{w_signimm16_1 & ~w_bl_1 & ~w_ucb32Bit_1}}& {{16{w_signImm_16[15]}}, w_signImm_16}}
         | {{32{w_bl_1 | w_ucb32Bit_1}} & {{7{i_blImm9_9[8]}}, i_blImm9_9, w_signImm_16}}
         | {{32{w_signimm11_1 & ~w_bl_1 & ~w_ucb32Bit_1}} & {{16{w_signImm_16[15]}}, w_signImm_16}};

  // decode鎵╁�?????????
  // 杩斿洖鍊硷細1銆乮mm_32 2銆乻hift_type_3

  // 5.24 11:50瀛樻。鐐癸拷?锟斤�???????????


  assign w_shiftType_2 = w_shift_3[1:0];
  reg [31:0] r_immDecode_32;

  always @(posedge w_immSplitterDriveToDecoFifo_1 or negedge rst)
  begin
    if (!rst)
    begin
      r_immDecode_32 = 32'b0;
    end
    else
    begin
      if (w_shiftType_2 == 2'b00)
        r_immDecode_32 = {27'b0, w_imm_5};
      if (w_shiftType_2 == 2'b01 | w_shiftType_2 == 2'b10)
      begin
        if (w_imm_5 == 5'b00000)
          r_immDecode_32 = 32'h0000_0010;
        else
          r_immDecode_32 = {27'b0, w_imm_5};
      end
      if (w_shiftType_2 == 2'b11)
      begin
        if (w_imm_5 == 5'b00000)
        begin
          r_immDecode_32 = 32'h0000_0001;
        end

        else
        begin
          r_immDecode_32 = {27'b0, w_imm_5};
        end
      end
    end
  end

  assign w_immDecode_32 = r_immDecode_32;


  // thumb鎵╁�?????????

  (* dont_touch="true" *) wire [11:0] w_thumbImm_12;
  assign w_thumbImm_12 = w_thumbImm_16[11:0];

  assign w_immThumb_32 = w_thumbImm_12[11:10] == 2'b00 ?
         (
           w_thumbImm_12[9:8] == 2'b00 ? {24'b0, w_thumbImm_12[7:0]} :
           (
             w_thumbImm_12[9:8] == 2'b01 ? {8'b0, w_thumbImm_12[7:0], 8'b0, w_thumbImm_12[7:0]} :
             (
               w_thumbImm_12[9:8] == 2'b10 ? {w_thumbImm_12[7:0], 8'b0, w_thumbImm_12[7:0], 8'b0} :
               {w_thumbImm_12[7:0], w_thumbImm_12[7:0], w_thumbImm_12[7:0], w_thumbImm_12[7:0]}
             )
           )
         ) : {24'b0, 1'b1, w_thumbImm_12[6:0]};

  (* dont_touch="true" *) wire [3:0] w_bitCount_4;
  (* dont_touch="true" *) wire [31:0] w_4BitCount_4;

// 璁＄畻pop鍜宲ush鎸囦护瀵勫瓨鍣ㄥ垪琛ㄤ腑鏈夊嚑锟�?????1
//12/11 zwm loss the 8-13
  // assign w_bitCount_4 = w_registers_16[0] + w_registers_16[1] + w_registers_16[2] + w_registers_16[3]
  //                     + w_registers_16[4] + w_registers_16[5] + w_registers_16[6] + w_registers_16[7]
  //                     + w_registers_16[14] + w_registers_16[15];
    assign w_bitCount_4 = w_registers_16[0] + w_registers_16[1] + w_registers_16[2] + w_registers_16[3]
                      + w_registers_16[4] + w_registers_16[5] + w_registers_16[6] + w_registers_16[7]
                      + w_registers_16[8] + w_registers_16[9] + w_registers_16[10] + w_registers_16[11]
                      + w_registers_16[12] + w_registers_16[13]
                      + w_registers_16[14] + w_registers_16[15];
  assign w_4BitCount_4 = 4 * w_bitCount_4;

  (* dont_touch="true" *) wire w_immSplitterDrive1ToDecoFifo_1, w_immSplitterDrive1ToThumbFifo_1;
  // 锟�??????瑕佸姞寤惰繜
  (* dont_touch="true" *) cFifo1_32b_launch zeroFifo(.i_drive(w_immSplitterDriveToZeroFifo_1), .i_data_32(w_immZero_32), .o_free(w_zeroFifoFreeToImmSplitter_1),
      .o_driveNext(w_zeroFifoDriveToImmMerge_1), .o_data_32(w_immZero1_32), .i_freeNext(w_immMergeFreeToZeroFifo_1),
      .rst(rst));

  (* dont_touch="true" *) cFifo1_32b_launch signFifo(.i_drive(w_immSplitterDriveToSignFifo_1), .i_data_32(w_immSign_32), .o_free(w_signFifoFreeToImmSplitter_1),
                      .o_driveNext(w_signFifoDriveToImmMerge_1), .o_data_32(w_immSign1_32), .i_freeNext(w_immMergeFreeToSignFifo_1),
                      .rst(rst));

  delay1U decoDelay0(.inR(w_immSplitterDriveToDecoFifo_1), .outR(w_immSplitterDrive1ToDecoFifo_1), .rst(rst));
 (* dont_touch="true" *)cFifo1_32b_launch decoFifo(.i_drive(w_immSplitterDrive1ToDecoFifo_1), .i_data_32(w_immDecode_32), .o_free(w_decoFifoFreeToImmSplitter_1),
                      .o_driveNext(w_decoFifoDriveToImmMerge_1), .o_data_32(w_immDecode1_32), .i_freeNext(w_immMergeFreeToDecoFifo_1),
                      .rst(rst));

 delay1U Thumbdelay0(.inR(w_immSplitterDriveToThumbFifo_1), .outR(w_immSplitterDrive1ToThumbFifo_1), .rst(rst));
 (* dont_touch="true" *) cFifo1_32b_launch thumbFifo(.i_drive(w_immSplitterDrive1ToThumbFifo_1), .i_data_32(w_immThumb_32), .o_free(w_thumbFifoFreeToImmSplitter_1),
                       .o_driveNext(w_thumbFifoDriveToImmMerge_1), .o_data_32(w_immThumb1_32), .i_freeNext(w_immMergeFreeToThumbFifo_1),
                       .rst(rst));


  wire w_immExeMergeFreeToImmMerge_1,w_immExeMergeDriToExeMer_1, w_exeMergeFreeToImmExeMer_1,w_immExeMerDriToRegImmMer_1,w_regImmMerFreeToImmExeMer_1,
       w_regImmMerDriToOpData_1,w_opDataFifoFreeToregImmMerge_1;

  (* dont_touch="true" *) wire [31:0] w_immData_32;

  (* dont_touch="true" *) cMutexMerge4_32b_launch immMerge(.i_drive0(w_zeroFifoDriveToImmMerge_1), .i_data0_32(w_immZero1_32), .o_free0(w_immMergeFreeToZeroFifo_1),
      .i_drive1(w_signFifoDriveToImmMerge_1), .i_data1_32(w_immSign1_32), .o_free1(w_immMergeFreeToSignFifo_1),
      .i_drive2(w_decoFifoDriveToImmMerge_1), .i_data2_32(w_immDecode1_32), .o_free2(w_immMergeFreeToDecoFifo_1),
      .i_drive3(w_thumbFifoDriveToImmMerge_1), .i_data3_32(w_immThumb1_32), .o_free3(w_immMergeFreeToThumbFifo_1),
      .i_freeNext(w_immExeMergeFreeToImmMerge_1), .o_driveNext(w_immMergeToImmExeMerge_1), .o_data_32(w_lastImm_32),
      .rst(rst));

  (* dont_touch="true" *) cMutexMerge3_32b_launch immExeMerge(.i_drive0(w_immMergeToImmExeMerge_1), .i_data0_32(w_lastImm_32), .o_free0(w_immExeMergeFreeToImmMerge_1),
      .i_drive1(w_ImmSeleDriToImmExeMerge_1), .i_data1_32(32'b0), .o_free1(w_immExeMergeFreeToImmSele_1),
      .i_drive2(w_ImmSeleDri1ToImmExeMerge_1), .i_data2_32(w_4BitCount_4), .o_free2(w_immExeMergeFree1ToImmSele_1),
      .i_freeNext(w_regImmMerFreeToImmExeMer_1), .o_driveNext(w_immExeMerDriToRegImmMer_1), .o_data_32(w_immData_32), 
      .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_96b_launch regImmMerge(.i_drive0(w_regSeleDriToRegImmMerge_1), .i_data0_64(w_lastRs1AndRs2Data_64), .o_free0(w_regImmMergeFreeToRegSele_1),
      .i_drive1(w_immExeMerDriToRegImmMer_1), .i_data1_32(w_immData_32), .o_free1(w_regImmMerFreeToImmExeMer_1),
      .i_freeNext(w_opDataFifoFreeToregImmMerge_1), .o_driveNext(w_regImmMerDriToOpData_1), .o_data_96(w_op123_96),
      .rst(rst));

  // op1,op2,op3 -----> w_rnData_32, w_rmData_32, w_raData_32, w_last1Imm_32 缁勫悎鎴愪笁涓搷浣滄暟
  // rn鏄痳s1,rm鏄痳s2
  // push 锟�????? pop鐨勭浜屼釜鎿嶄綔鏁拌繕娌℃湁寮勶紝绗簩涓搷浣滄暟鏄痳egisters -- 锟�?????
  assign {w_last1Imm_32, w_rmData1_32, w_rnData1_32} = w_op_96;
  assign w_last2Imm_32 = w_immNot_1 ? (~ w_last1Imm_32) : w_last1Imm_32;
  assign w_rmData_32 = w_rmNot_1 ? ~w_rmData1_32 : w_rmData1_32;
  assign w_rnData_32 = w_rnNot_1 ? ~w_rnData1_32 : w_rnData1_32;

  wire w_opDataFifoDriToSele_1,w_opDataSeleFreeToFifo_1,w_opDataSeleDriToBOPMerge_1,w_BOPMergeFreeToOpDataSele_1;
    (* dont_touch="true" *) wire [95:0] w_opDataToExe_96, w_opDataToB_96;
    (* dont_touch="true" *) wire [31:0] w_lr_32, w_nextInsAddr_32;
  assign w_lr_32 = {w_nextInsAddr_32[31:1], 1'b1};
  assign w_nextInsAddr_32 = w_pc_32 - 2;

  // 杩樺緱淇敼-->PC锛屾湁涓や釜绔嬪嵆鏁扮殑鎯呭�?????????-->褰撳墠鎸囦护鐨刾c澶氭暣鍑烘潵锟�??????娈碉紝涓や釜绔嬪嵆鏁扮殑绗簩涓珛鍗虫暟锟�???????????????0鎵╁睍锟�???????????????

  (* dont_touch="true" *) wire [31:0] w_op1_32, w_op2_32, w_op3_32;
  wire [31:0] w_blPc_32;
  assign w_blPc_32 = w_pc_32 + 4;

  //楗卞拰杩愮畻绗簩涓搷浣滄暟涓烘甯告墿灞昳mm锛岀涓変釜鎿嶄綔鏁颁负w_saturate_5锛涗綅鎿嶄綔绗竴涓搷浣滄暟涓烘甯告墿灞曠珛鍗虫暟锛岀浜屼釜鎿嶄綔鏁颁负w_satImmOrWidthm_5
  assign w_op1_32 = w_rnOp1 & !w_ALIGN_1 ? w_rnData_32 : (w_rmOp1 ? w_rmData_32 : w_ALIGN_1 ? w_pc_32 : w_thumbExpandRor_1 ? w_immThumb_32 : w_bl_1 ? {w_blPc_32[31:1], 1'b0} : w_last2Imm_32); // 鐗规畩瀵勫瓨鍣ㄥ簲璇ヤ篃鏀捐繘op1锟�??????-->鏈锟�???????????????-->鍦ㄨ瘧鐮佷腑澶勭�?????????
  assign w_op2_32 = w_rmOp2 ? w_rmData_32 : (w_bit_1 ? {27'b0, w_satImmOrWidthm_5} : w_thumbExpandRor_1 ? {27'b0, w_thumbImm_12[11:7]} : w_last2Imm_32);// 浣嶈繍绠楃殑绗簩涓珛鍗虫�?????????
  assign w_op3_32 = w_rnOp3 ? w_rnData_32 : (w_immOp3 ? {27'b0, w_saturate_5} : w_blx_1 ? w_lr_32 : 32'b0); // 楗卞拰杩愮畻鐨勭涓変釜绔嬪嵆锟�??????????????
  // 濡傛灉涓嶈繃鎵ц鐨勬寚浠よ鎬庝箞浼犻€掑噯澶囧洖鍐欑殑鏁版嵁锛屾斁鍦ㄧ涓変釜鎿嶄綔鏁板悧锛熷ソ鍍忔槸绗竴涓搷浣滄�?????????

  // wire w_regImmMerDri1ToOpData_1;
  // delay2U opDelay0(.inR(w_immSplitterDriveToDecoFifo_1), .outR(w_immSplitterDrive1ToDecoFifo_1));

  //鍔犲欢杩熷悗鐨剋_regImmMerDriToOpData_1锟�??????瑕佹帴鍒拌烦杞鐞嗛偅锟�??????,鍚庨潰瑕佸姞锟�??????涓嫨锟�???????????????-->宸插�?????????
  (* dont_touch="true" *) cFifo1_96b_launch opDataFifo(.i_drive(w_regImmMerDriToOpData_1), .i_data_96(w_op123_96), .o_free(w_opDataFifoFreeToregImmMerge_1),
      .o_driveNext(w_opDataFifoDriToSele_1), .o_data_96(w_op_96), .i_freeNext(w_opDataSeleFreeToFifo_1),
      .rst(rst));

      wire w_opDataFifoDri1ToSele_1;
      delay4U opDelay0(.inR(w_opDataFifoDriToSele_1), .outR(w_opDataFifoDri1ToSele_1), .rst(rst));  

  wire w_opDataSeleDriToBSele_1, w_BSeleFreeToOpDataSele_1;
  // 2024.11.1 --鎷╄矾鏀规垚鍒嗘�?????????-->璺宠浆鎸囦护涔熻寰€鍚庤蛋鏂逛究寮傚父澶勭悊鍚屾椂鍚庨潰鐨剋aitMerge鎬昏涓夎矾閮藉�?????????-->zlt  //11.2 free1鍜宖ree0涓€鏍锋殏鏃朵负浜嗘祴锟�?????????????? -->hrq -->宸叉�?????????--zlt
  (* dont_touch="true" *) cSplitter2_1b opDataSpli(.i_drive(w_opDataFifoDri1ToSele_1), .i_data_1(1'b0), .o_free(w_opDataSeleFreeToFifo_1),
      .o_driveNext0(w_opDataSeleDriToBSele_1), .i_freeNext0(w_BSeleFreeToOpDataSele_1), .o_data0_1(),
      .o_driveNext1(w_regSeleDriveToExeMerge_1), .i_freeNext1(w_exeMergeFreeToRegSele_1), .o_data1_1(),
      .rst(rst));

  wire w_driveToMe1_1;
  // 2024.11.3 鏂板姞鎷╄矾-->涓嶆槸璺宠浆鎸囦护鐨勮瘽涓嶅幓璧颁笅闈㈢殑锟�??????????????
  (* dont_touch="true" *) cSelector2_1b Selector(.i_drive(w_opDataSeleDriToBSele_1), .i_data_1(w_isB_1), .o_free(w_BSeleFreeToOpDataSele_1),
  .o_driveNext0(w_opDataSeleDriToBOPMerge_1), .i_freeNext0(w_BOPMergeFreeToOpDataSele_1), .o_data0_1(1'b0),
  .o_driveNext1(w_driveToMe_1), .i_freeNext1(w_driveToMe1_1), .o_data1_1(1'b0),
  .rst(rst));
  delay4U bDelay1(.inR(w_driveToMe_1), .outR(w_driveToMe1_1), .rst(rst));  
  // 鍒嗘淳鐨勫彟锟�??????鏉¤矾--鈥旓�???????????>涓昏鏄烦杞锟�???????????????-->鐀��埌aluWritePc()鐨勬寚浠や篃鏀惧湪杩欓噷澶勭悊

  wire w_branchDriToPsrReleSpli_1,w_psrReleSpliFreeToBranchSpli_1,w_psrReleSpliDriToMe_1,w_psrReleSpliDriveToPsrRele0MergeSelector,w_psrRele0MergeSelectorFreeToPsrReleSpli_1,
       w_psrReleSpliDriveToPsrRele1Merge,w_psrRele1MergeFreeToPsrReleSpli_1,w_psrRele0MergeDriToPsrRele0Sele_1,w_psrRele0SeleFreeToPsrRele0Merge_1,
       w_psrRele1SeleFreeToPsrRele1Merge_1,w_psrRele1MergeDriToPsrRele1Sele_1,w_psrRele0SeleDriToMe_1,w_psrRele1SeleDriToMe_1,w_psrRele0SeleDriveToPsrDataMerge_1,
       w_psrDataMergeFreeToPsrRele0Sele_1,w_psrDataMergeFreeToPsrRele1Sele_1,w_psrRele1SeleDriveToPsrDataMerge_1,w_psrDataMergeDriveToBranchSele_1,
       w_branchSeleFreeToPsrDataMerge_1;


  (* dont_touch="true" *)wire [32:0] w_psrRele0Data_33, w_psrRele1Data_33;
  (* dont_touch="true" *)wire [31:0] w_psrData0_32,w_psrData1_32,w_psrData_32,w_grfData_32;


  (* dont_touch="true" *) cSplitter2_1b branchSpli(.i_drive(i_decoDrive1ToLaunch_1), .i_data_1(i_s_1), .o_free(o_launchFree1ToDecoder_1),
      .o_driveNext0(w_branchDriToPsrReleSpli_1), .i_freeNext0(w_psrReleSpliFreeToBranchSpli_1), .o_data0_1(w_S_1),
      .o_driveNext1(o_launchDriveToPsr_1), .i_freeNext1(i_PSRFreeToLaunch_1), .o_data1_1(),
      .rst(rst));

  // 11/29 zwm add two cfifo
      // wire w_branchDriToPsrReleSpli1_1,w_psrReleSpliFreeToBranchSpli1_1;
      // cFifo1 branchSpliDelayFifo1(.i_drive(w_branchDriToPsrReleSpli_1), .i_freeNext(w_psrReleSpliFreeToBranchSpli1_1), .rst(rst),
      // .o_free(w_psrReleSpliFreeToBranchSpli_1), .o_driveNext(w_branchDriToPsrReleSpli1_1), .o_fire_1());   

      // wire w_PSRDriveToLaunch_1,w_launchFreeToPSR_1;
      // cFifo1 branchSpliDelayFifo2(.i_drive(i_PSRDriveToLaunch_1), .i_freeNext(w_launchFreeToPSR_1), .rst(rst),
      // .o_free(o_launchFreeToPSR_1), .o_driveNext(w_PSRDriveToLaunch_1), .o_fire_1());    

  assign w_psrRele_2[0] = w_PerS_1 == 1 ? 1'b1 : 1'b0;
  assign w_psrRele_2[1] = w_PerS_1 == 1 ? 1'b0 : 1'b1;

  (* dont_touch="true" *) wire w_psrExe_1, w_psrPsr_1, w_PerS1_1;
  wire w_psrReleSpliDriToWriteSFifo_1,w_writeSFifoFreeToPsrReleSpli_1;
  wire w_psrReleSpliDriveToPsrRele0Merge, w_psrRele0MergeFreeToPsrReleSpli_1;
//11/27 zwm w_writeSFifoFreeToPsrReleSpli_1 -> w_psrRele0MergeFreeToPsrReleSpli_1
//update:锛燂紵锛燂紵纭畾鏈€鍚庝竴璺殑鍘诲悜
  (* dont_touch="true" *) cSplitter3_3b_launch psrReleSpli(.i_drive(w_branchDriToPsrReleSpli_1), .i_data_3({w_S_1, w_psrRele_2}), .o_free(w_psrReleSpliFreeToBranchSpli_1),
      .o_driveNext0(w_psrReleSpliDriveToPsrRele0Merge), .i_freeNext0(w_psrRele0MergeFreeToPsrReleSpli_1), .o_data0_1(w_psrExe_1),
      .o_driveNext1(w_psrReleSpliDriveToPsrRele1Merge), .i_freeNext1(w_psrRele1MergeFreeToPsrReleSpli_1), .o_data1_1(w_psrPsr_1),
      .o_driveNext2(w_psrReleSpliDriToWriteSFifo_1), .i_freeNext2(w_psrRele0MergeFreeToPsrReleSpli_1), .o_data2_1(w_PerS1_1), // 璁板綍褰撳墠鎸囦护鐨凷锟�???????????????
      .rst(rst));

  wire w_writeSFifoDrive_1,w_writeSFifoDriveDelay_1;
  //11/27 zwm w_psrReleSpliDriToWriteSFifo_1 -> o_launchDriveToExe_1
  wire w_launchDriveToExe1_1;
  delay8U writeSDelay0(.inR(o_launchDriveToExe_1), .outR(w_launchDriveToExe1_1), .rst(rst));  
  (* dont_touch="true" *) cFifo1_1b_launch writeSFifo(.i_drive(w_launchDriveToExe1_1), .i_data_1(w_PerS1_1), .o_free(w_writeSFifoFreeToPsrReleSpli_1),
      .o_driveNext(w_writeSFifoDrive_1), .o_data_1(w_PerS_1), .i_freeNext(w_writeSFifoDriveDelay_1),
      .rst(rst)); // 鍙互鍐欐參鐐瑰氨鍙互鍘绘帀涓婇潰鐨勫瘎瀛樺櫒锛岃繖鏍锋暟鎹氨宸茬粡浼犲埌鍚庨潰鏇存敼浜嗕篃鏃犳墍锟�?????
      delay4U writeSFifoDelay(.inR(w_writeSFifoDrive_1), .outR(w_writeSFifoDriveDelay_1), .rst(rst));

  // 2024.10.24 zlt 淇�????????? 

  // wire w_psrRele0MergeSelectorDriveToPsrRele0Merge_1,w_psrRele0MergeFreeToPsrRele0MergeSelector_1;
  // wire w_psrRele0MergeSelectorDriveToMe_1;
  // (* dont_touch="true" *) cSelector2_1b psrRele0MergeSelector(.i_drive(w_psrReleSpliDriveToPsrRele0MergeSelector), .i_data_1(w_isOne_1), .o_free(w_psrRele0MergeSelectorFreeToPsrReleSpli_1),
  // .o_driveNext0(w_psrRele0MergeSelectorDriveToPsrRele0Merge_1), .i_freeNext0(w_psrRele0MergeFreeToPsrRele0MergeSelector_1), .o_data0_1(),
  // .o_driveNext1(w_psrRele0MergeSelectorDriveToMe_1), .i_freeNext1(w_psrRele0MergeSelectorDriveToMe_1), .o_data1_1(),
  // .rst(rst));
    reg r_psrExe_1;
    always @(posedge w_psrReleSpliDriveToPsrRele0Merge or negedge rst) begin
      if (!rst) begin
        r_psrExe_1 <= 1'b0;
      end else begin
        r_psrExe_1 <= w_psrExe_1;
      end
    end

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch psrRele0Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(i_ExeData_96[95:64]), .o_free0(w_psrFreeToExe_1),
      .i_drive1(w_psrReleSpliDriveToPsrRele0Merge), .i_data1_1(r_psrExe_1), .o_free1(w_psrRele0MergeFreeToPsrReleSpli_1),
      .o_driveNext(w_psrRele0MergeDriToPsrRele0Sele_1), .o_data_33(w_psrRele0Data_33), .i_freeNext(w_psrRele0SeleFreeToPsrRele0Merge_1),
      .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch psrRele1Merge(.i_drive0(w_psrReleSpliDriveToPsrRele1Merge), .i_data0_32(i_psrData_32), .o_free0(w_psrRele1MergeFreeToPsrReleSpli_1),
      .i_drive1(i_PSRDriveToLaunch_1), .i_data1_1(w_psrPsr_1), .o_free1(o_launchFreeToPSR_1),
      .o_driveNext(w_psrRele1MergeDriToPsrRele1Sele_1), .o_data_33(w_psrRele1Data_33), .i_freeNext(w_psrRele1SeleFreeToPsrRele1Merge_1),
      .rst(rst));

      wire w_psrRele0MergeDri1ToPsrRele0Sele_1;
      //11/27 zwm w_psrRele0SeleDriToMe_1 change to w_branchSeleFreeToPsrDataMerge_1
      delay2U psrDelay0(.inR(w_psrRele0MergeDriToPsrRele0Sele_1), .outR(w_psrRele0MergeDri1ToPsrRele0Sele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_33b_launch psrRele0Selector(.i_drive(w_psrRele0MergeDri1ToPsrRele0Sele_1), .i_data_33(w_psrRele0Data_33), .o_free(w_psrRele0SeleFreeToPsrRele0Merge_1),
      .o_driveNext0(w_psrRele0SeleDriveToPsrDataMerge_1), .i_freeNext0(w_psrDataMergeFreeToPsrRele0Sele_1), .o_data0_32(w_psrData0_32),
      .o_driveNext1(w_psrRele0SeleDriToMe_1), .i_freeNext1(w_psrRele0SeleDriToMe_1), .o_data1_32(),
      .rst(rst));

      //11/29 zwm change back from w_branchSeleFreeToPsrDataMerge_1 to w_psrRele1SeleDriToMe_1
      wire w_psrRele1MergeDri1ToPsrRele1Sele_1;
      delay2U psr1Delay0(.inR(w_psrRele1MergeDriToPsrRele1Sele_1), .outR(w_psrRele1MergeDri1ToPsrRele1Sele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_33b_launch psrRele1Selector(.i_drive(w_psrRele1MergeDri1ToPsrRele1Sele_1), .i_data_33(w_psrRele1Data_33), .o_free(w_psrRele1SeleFreeToPsrRele1Merge_1),
      .o_driveNext0(w_psrRele1SeleDriveToPsrDataMerge_1), .i_freeNext0(w_psrDataMergeFreeToPsrRele1Sele_1), .o_data0_32(w_psrData1_32),
      .o_driveNext1(w_psrRele1SeleDriToMe_1), .i_freeNext1(w_branchSeleFreeToPsrDataMerge_1), .o_data1_32(),
      .rst(rst));
//11/28 zwm w_branchSeleFreeToPsrDataMerge_1 change to o_launchDriveToExe_1
  (* dont_touch="true" *) cMutexMerge2_32b_launch psrDataMerge(.i_drive0(w_psrRele0SeleDriveToPsrDataMerge_1), .i_data0_32(w_psrData0_32), .o_free0(w_psrDataMergeFreeToPsrRele0Sele_1),
      .i_drive1(w_psrRele1SeleDriveToPsrDataMerge_1), .i_data1_32(w_psrData1_32), .o_free1(w_psrDataMergeFreeToPsrRele1Sele_1),
      .i_freeNext(w_branchSeleFreeToPsrDataMerge_1), .o_driveNext(w_psrDataMergeDriveToBranchSele_1), .o_data_32(w_psrData_32),
      .rst(rst));

  wire [1:0] w_addnum_2;     
  assign w_addnum_2 = {2{w_add5_1}} & 2'b01
                    | {2{w_add64_1}} & 2'b10
                    | {2{~(w_add5_1 | w_add64_1)}} & 2'b00; 

  assign w_v_1 = w_psrData_32[28];
  assign w_c_1 = w_psrData_32[29];
  assign w_z_1 = w_psrData_32[30];
  assign w_n_1 = w_psrData_32[31];

  assign w_addCarry_1 = w_addC0_1 & 1'b0
         | w_addC1_1 & 1'b1
         | w_addC_1 & w_c_1;

  assign w_addType_3 = {w_addCarry_1, w_addnum_2}; // 杩樿澶氫竴浣嶈〃绀烘槸涓嶆�?????????64浣嶅姞锟�???????????????
        

  wire w_branchDriToExeMerge_1, w_exeMergeFreeToBranchSele_1;
  wire w_bSpliDriToBSele_1, w_bSeleFreeToBSpli_1, w_bSeleDriToBFifo_1, w_bSeleDriToMe_1, w_bFifoFreeToBSele_1, w_bFifoDriToIfMer_1;

  (* dont_touch="true" *) cSplitter2_7_3_4b_launch branchSplitter(.i_drive(w_psrDataMergeDriveToBranchSele_1), .i_data_7({w_addType_3, w_c_1, w_z_1, w_n_1, w_v_1}), .o_free(w_branchSeleFreeToPsrDataMerge_1),
      .o_driveNext0(w_branchDriToExeMerge_1), .i_freeNext0(w_exeMergeFreeToBranchSele_1), .o_data0_3(w_addType1_3),
      .o_driveNext1(w_bSpliDriToBSele_1), .i_freeNext1(w_bSeleFreeToBSpli_1), .o_data1_4({w_c1_1, w_z1_1, w_n1_1, w_v1_1}),
      .rst(rst));

  wire w_bSeleDriToBOpMer_1,w_BOpFreeToBSele_1;

  wire w_bSpliDri1ToBSele_1,w_bSpliDri2ToBSele_1;
  delay6U bDelay0(.inR(w_bSpliDriToBSele_1), .outR(w_bSpliDri1ToBSele_1), .rst(rst)); 
  delay6U bDelay2(.inR(w_bSpliDri1ToBSele_1), .outR(w_bSpliDri2ToBSele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_9b_launch branchSelector(.i_drive(w_bSpliDri2ToBSele_1), .i_data_9({w_isB_1, w_c1_1, w_z1_1, w_n1_1, w_v1_1, w_cond_4}), .o_free(w_bSeleFreeToBSpli_1),
      .o_driveNext0(w_bSeleDriToBOpMer_1), .i_freeNext0(w_BOpFreeToBSele_1), .o_data0_8({w_c2_1, w_z2_1, w_n2_1, w_v2_1, w_cond1_4}),
      .o_driveNext1(w_bSeleDriToMe_1), .i_freeNext1(w_bSeleDriToMe_1), .o_data1_8(),
      .rst(rst));
  // 5.23 杩橀渶锟�???????????????鐐瑰ぇ鏀瑰姩->涓昏鏄洜涓篴luWritePC()涔熼渶瑕佺敤鍒板瘎瀛樺櫒锛岄渶瑕佸垽鏂浉鍏筹�??????????锟藉紩璧风殑鏀瑰姩
 
  (* dont_touch="true" *) cWaitMerge2_1b_launch bAndOpMerge(.i_drive0(w_opDataSeleDriToBOPMerge_1), .i_data0_1(1'b0), .o_free0(w_BOPMergeFreeToOpDataSele_1),
      .i_drive1(w_bSeleDriToBOpMer_1), .i_data1_1(1'b0), .o_free1(w_BOpFreeToBSele_1),
      .o_driveNext(w_bSeleDriToBFifo_1), .o_data_1(), .i_freeNext(w_bFifoFreeToBSele_1),
      .rst(rst));


  // 璺宠浆澶勭悊 涓昏鏄湅閭ｄ簺鐘讹拷?锟戒�?????????

  // aluWritePC()-->涓ゆ潯鎸囦护锛寃_addAluPC_1, w_movAluWritePC_1

  // w_addAluPC_1鍏堢Щ浣嶅啀鍋氬姞娉曪紝 w_movAluWritePC_1鐩存帴璧嬶拷??
//12/2 zwm change w_cond1_4 == 4'b1101 & w_z2_1 == 1 & w_n2_1 != w_v2_1 & w_isCb_1 == 1'b1 to w_cond1_4 == 4'b1101 & (w_z2_1 == 1 | w_n2_1 != w_v2_1) & w_isCb_1 == 1'b1
  // 姣旇緝鏉′欢锛屼�?????????1鏃惰烦杞紝锟�??????0鏃舵潯浠朵笉鎴愮珛锛屼笉璺宠�?????????
  assign w_b_1 = (w_cond1_4 == 4'b0000 & w_z2_1 == 1'b1  & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0001 & w_z2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0010 & w_c2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0011 & w_c2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0100 & w_n2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0101 & w_n2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0110 & w_v2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0111 & w_v2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1000 & w_c2_1 == 1'b1 & w_z2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1001 & (w_c2_1 == 1'b0 | w_z2_1 == 1'b1) & w_isCb_1 == 1'b1)
        //  | (w_cond1_4 == 4'b1001 & w_c2_1 == 1'b0 & w_z2_1 == 1'b1 & w_isCb_1 == 1'b1)---->error.2025/11/24
         | (w_cond1_4 == 4'b1010 & w_n2_1 == w_v2_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1011 & w_n2_1 != w_v2_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1100 & w_z2_1 == 0 & w_n2_1 == w_v2_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1101 & (w_z2_1 == 1 | w_n2_1 != w_v2_1) & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1110 & w_isCb_1 == 1'b1)
         | (w_cbz_1 == 1'b1 & w_op1_32 == 32'b0)
         | (w_cbnz_1 == 1'b1 & w_op1_32 != 32'b0);


  (* dont_touch="true" *) reg [31:0] r_branchPc_32;

  wire w_bSeleDriToBFifo1_1,w_bSeleDriToBFifo2_1,w_bSeleDriToBFifo3_1;
  //11/25 zwm change 4U to 8U
  delay16U b1Delay0(.inR(w_bSeleDriToBFifo_1), .outR(w_bSeleDriToBFifo1_1), .rst(rst)); 
  delay8U b1Delay1(.inR(w_bSeleDriToBFifo1_1), .outR(w_bSeleDriToBFifo2_1), .rst(rst)); 
  delay6U b1Delay2(.inR(w_bSeleDriToBFifo2_1), .outR(w_bSeleDriToBFifo3_1), .rst(rst)); 
  always @(posedge w_bSeleDriToBFifo3_1 or negedge rst)
  begin
    if (!rst)
    begin
      r_branchPc_32 = 32'b0;
    end
    else
    begin
      if (w_b_1 & w_cB_1 | w_ucB_1)
      begin
        r_branchPc_32 = w_pc_32 + w_last2Imm_32 + 4;
      end

      if (~w_b_1 & w_cB_1)
      begin
        if(w_is16_1)
        r_branchPc_32 = w_pc_32 + 2;
        else r_branchPc_32 = w_pc_32 + 4;
      end

      if (w_movAluWritePC_1 | w_blx_1 | w_bx_1)
      begin
        r_branchPc_32 = w_op1_32;
      end

      if (w_bl_1)
      begin
        r_branchPc_32 = w_pc_32 + 4 + w_last2Imm_32;
      end

      if (w_addAluPC_1)
      begin
        if (w_shift_3 == 3'b000)
        begin
          r_branchPc_32 = w_op1_32 << w_op2_32 + w_op3_32;
        end
        if (w_shift_3 == 3'b001)
        begin
          r_branchPc_32 = w_op1_32 >> w_op2_32 + w_op3_32;
        end
        if (w_shift_3 == 3'b010)
        begin
          r_branchPc_32 = w_op1_32 >>> w_op2_32 + w_op3_32;
        end
        if (w_shift_3 == 3'b011)
        begin

        end
        if (w_shift_3 == 3'b111)
        begin

        end
      end
    end
  end

  assign w_branchPc_32 = r_branchPc_32;
  // wire w_bSeleDriToBFifo2_1;
  // delay16U b1Delay1(.inR(w_bSeleDriToBFifo1_1), .outR(w_bSeleDriToBFifo2_1), .rst(rst)); 
  (* dont_touch="true" *) cFifo1_32b_launch bFifo(.i_drive(w_bSeleDriToBFifo3_1), .i_data_32(w_branchPc_32), .o_free(w_bFifoFreeToBSele_1),
      .o_driveNext(o_bDriToIf), .o_data_32(o_branchPc_32), .i_freeNext(i_bFreeFromIf),
      .rst(rst));



  // 鎸囦护璺緞缂栫�?????????-->锟�??????锟�??????16锟�??????

  wire w_add_1; // 鍙仛鍔犳硶鐨勬寚锟�???????????????
  wire w_alignAndAdd_1; //ALIGN,ADD
  wire w_shiftAdd_1;// shift,add
  wire w_mulAdd_1;// mul,add
  wire w_onlyMul_1;// 鍙仛涔樻硶
  wire w_onlyDiv_1;// 鍙仛闄ゆ硶
  wire w_onlyAnd_1;// 鍙仛锟�???????????????
  wire w_onlyEor_1;// 鍙仛寮傛垨
  wire w_onlyOr_1;// 鍙仛锟�???????????????
  wire w_shiftAnd_1;// shift,and
  wire w_shiftEor_1;// shift,eor
  wire w_shiftOr_1;// shift,or
  wire w_onlyShift_1;// 鍙仛绉讳綅
  wire w_shiftSatQ_1;// shifr,satq
  wire w_hsbAdd_1;
  wire w_onlyRev_1;// 鍙仛缈昏浆



  always @(*)
  begin
    case (w_insType_16)
      16'h0001:
        r_insPath_8 = 8'b1111_0000;
      16'h0002:
        r_insPath_8 = 8'b0000_1010;
      16'h0003:
        r_insPath_8 = 8'b0000_0011;
      16'h0004:
        r_insPath_8 = 8'b0000_0010;

      16'h0010:
        r_insPath_8 = 8'b1111_0010;
      16'h0020:
        r_insPath_8 = 8'b1111_0001;
      16'h0030:
        r_insPath_8 = 8'b1111_0100;
      16'h0040:
        r_insPath_8 = 8'b1111_0110;

      16'h0100:
        r_insPath_8 = 8'b1111_0101;
      16'h0200:
        r_insPath_8 = 8'b0100_0011;
      16'h0300:
        r_insPath_8 = 8'b0110_0011;
      16'h0400:
        r_insPath_8 = 8'b0101_0011;

      16'h1000:
        r_insPath_8 = 8'b1111_0011;
      16'h2000:
        r_insPath_8 = 8'b0111_0011;
      16'h3000:
        r_insPath_8 = 8'b0000_1000;
      16'h4000:
        r_insPath_8 = 8'b1111_1001;
      default:
        r_insPath_8 = 8'b1111_1111;
    endcase 
  end

  assign w_insPath_8 = r_insPath_8;




  wire [166:0] w_launchDataToExe_168;

  (* dont_touch="true" *) wire [98:0] w_launchDataToExe1_99;
  // msbit 涓簑_satImm_5锛宭sbit涓虹珛鍗虫暟 
  assign w_launchDataToExe1_99 = {w_msr_1, w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4, w_registers_16,
                                  w_pc_32, w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, w_shift_3, 
                                  w_P_1, w_W_1, w_U_1, w_S_1, w_grfFlag_1, w_opNot_1, w_isXt_1,
                                  w_shiftC_1, w_shiftS_1, w_shiftNum_1, w_revType_2, w_satqS_1, w_mulDivS_1}; // w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4


//dirve1鍔犲欢锟�??????????????

               
wire w_launchForkDrive1ToExeMergeDelay_1;               
wire w_launchForkDrive1ToExeMergeDelay1_1,w_exeMergeFree1ToLaunchFork1_1;
wire w_branchDriToExeMerge1_1,w_exeMergeFreeToBranchSele1_1;
(* dont_touch="true" *)delay8U exeMerge2Delay(.inR(w_launchForkDriveToExeMerge1_1), .outR(w_launchForkDrive1ToExeMergeDelay_1), .rst(rst));

//11/20 zwm give each way add cfifo
cFifo1 launchDelayFifo1(.i_drive(w_launchForkDrive1ToExeMergeDelay_1), .i_freeNext(w_exeMergeFree1ToLaunchFork1_1), .rst(rst),
               .o_free(w_exeMergeFree1ToLaunchFork_1), .o_driveNext(w_launchForkDrive1ToExeMergeDelay1_1), .o_fire_1());


cFifo1 launchDelayFifo2(.i_drive(w_branchDriToExeMerge_1), .i_freeNext(w_exeMergeFreeToBranchSele1_1), .rst(rst),
               .o_free(w_exeMergeFreeToBranchSele_1), .o_driveNext(w_branchDriToExeMerge1_1), .o_fire_1());    
               
                                                                 
  // 鍑嗗濂芥暟鎹繘鎵ц鍜屽彇锟�?????
  (* dont_touch="true" *) cWaitMerge3_104_99_4_207b_launch exeMerge2(.i_drive0(w_regSeleDriveToExeMerge_1), .i_data0_104({w_insPath_8, w_op3_32, w_op2_32, w_op1_32}), .o_free0(w_exeMergeFreeToRegSele_1),
      .i_drive1(w_launchForkDrive1ToExeMergeDelay1_1), .i_data1_99(w_launchDataToExe1_99), .o_free1(w_exeMergeFree1ToLaunchFork1_1),
      .i_drive2(w_branchDriToExeMerge1_1), .i_data2_4({w_c_1,w_addType1_3}), .o_free2(w_exeMergeFreeToBranchSele1_1),
      .i_freeNext(i_ExeFreeToLaunch_1), .o_driveNext(o_launchDriveToExe_1), .o_data_207(o_launchDataToExe_207),
      .rst(rst));

endmodule
