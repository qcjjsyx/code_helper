
`timescale 1ns/1ps

module launch (
    //! 来自译码的脉冲
    input i_decoderDriveToLaunch_1,
    //! 译码来的数据
    input [184:0] i_decoderData_185,
    //! 给译码的复位
    output o_launchFreeToDecoder_1,

    //! 译码另一路的脉冲
    input i_decoDrive1ToLaunch_1,
    //! 译码另一路数据
    input i_s_1,
    //! 另一类给译码复位
    output o_launchFree1ToDecoder_1,

    //! LSU来的旁路
    input i_LsuDriveToLunch_1,
    //! LSU旁路数据
    input [63:0] i_lsuData_64,
    //! 给LSU旁路的复位
    output o_launchFreeToLsu_1,

    //! EXE来的旁路
    input i_ExeDriveToLunch_1,
    //! EXE旁路数据
    input [95:0] i_ExeData_96,
    //! 给EXE旁路复位
    output o_launchFreeToExe_1,

    //! 来自GRF的脉冲
    input i_GrfDriveToLaunch_1,
    //! GFR数据
    input [63:0] i_rsData_64,
    //! 给GRF复位
    output o_launchFreeToGrf_1,

    //! 来自SRF的脉冲
    input i_SrfDriveToLaunch_1,
    //! SRF数据
    input [31:0] i_sRsData_32,
    //! 给SRF复位
    output o_launchFreeToSrf_1,

    //! 来自PSR的脉冲
    input i_PSRDriveToLaunch_1,
    //! PSR数据
    input [31:0] i_psrData_32,
    //! 给PSR复位
    output o_launchFreeToPSR_1,

    //! 给GRF的脉冲
    output o_launchDriveToGrf_1,
    //! GRF地址
    output [7:0] o_regAddr_8,
    //! 来自GRF的复位
    input i_grfFreeTolaunch_1,

    //! 给SRF的脉冲
    output o_launchDriveToSrf_1,
    //! SRF地址
    output [7:0] o_SRegAddr_8,
    //! 来自SRF的复位
    input i_srfFreeTolaunch_1,

    //! 给PSR的脉冲
    output o_launchDriveToPsr_1,
    //! 来自PSR的复位
    input i_PSRFreeToLaunch_1,

    //! 给EXE的脉冲
    output o_launchDriveToExe_1,
    //! 打包好的数据
    output [206:0] o_launchDataToExe_207,
    //! 来自EXE的复位
    input i_ExeFreeToLaunch_1,

    //! 给IF的脉冲
    output o_launchDriveToIf_1,
    //! 取指地址
    output [31:0] o_pc_32,
    //! 来自IF的复位
    input i_IfFreeToLaunch_1,

    //! 给IF的脉冲
    output o_bDriToIf,
    //! 取指地址
    output [31:0] o_branchPc_32,
    //! 来自IF的复位
    input i_bFreeFromIf,

    input rst
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
    (* dont_touch="true" *)wire w_imm5_1, w_imm8_1, w_imm12_1, w_imm16_1, w_imm2_1; //  32位指�?
    (* dont_touch="true" *)wire w_imm3_1, w_imm7_1, w_imm11_1;
    (* dont_touch="true" *)wire w_zeroimm16_1, w_zeroimm12_1, w_zeroimm8_1, w_zeroimm5_1, w_zeroimm2_1, w_zeroimm11_1, w_zeroimm7_1, w_zeroimm3_1;
    (* dont_touch="true" *)wire w_signimm16_1, w_signimm12_1, w_signimm8_1, w_signimm5_1, w_signimm2_1, w_signimm11_1, w_signimm7_1, w_signimm3_1;
    (* dont_touch="true" *)wire w_decoimm16_1, w_decoimm12_1, w_decoimm8_1, w_decoimm5_1, w_decoimm2_1, w_decoimm11_1, w_decoimm7_1, w_decoimm3_1;
    (* dont_touch="true" *)wire w_thumbimm16_1, w_thumbimm12_1, w_thumbimm8_1, w_thumbimm5_1, w_thumbimm2_1, w_thumbimm11_1, w_thumbimm7_1, w_thumbimm3_1;
    (* dont_touch="true" *)wire [31:0] w_immZero_32, w_immSign_32, w_immDecode_32, w_immThumb_32;
    (* dont_touch="true" *)wire [31:0] w_immZero1_32, w_immSign1_32, w_immDecode1_32, w_immThumb1_32;
    (* dont_touch="true" *)wire [4:0] w_imm_5;
    (* dont_touch="true" *)wire [4:0] w_satImm_5; // 饱和运算用到�?5位立即数
    (* dont_touch="true" *)wire [4:0] w_saturate_5;
    (* dont_touch="true" *)wire w_isImm_1;// 5.24 译码还没有统�?

    (* dont_touch="true" *)wire [31:0] w_rnData_32, w_rmData_32, w_raData_32, w_last1Imm_32, w_last2Imm_32;
    (* dont_touch="true" *)wire [31:0] w_rnData1_32, w_rmData1_32;
    (* dont_touch="true" *)wire [95:0] w_op_96, w_op123_96;
    (* dont_touch="true" *)wire w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bit_1;

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

  // 位宽再定
  (* dont_touch="true" *) cSplitter3_185_16_26_143b_launch launchSplitter(.i_drive(i_decoderDriveToLaunch_1), .i_data_185(i_decoderData_185), .o_free(o_launchFreeToDecoder_1),
      .o_driveNext0(w_launchSpliDriveToRegSpli_1), .i_freeNext0(w_regSpliFreeToLaunchSpli_1), .o_data0_16(w_launchSpliData0_16), // reg
      .o_driveNext1(w_launchSpliDriToImmSele_1), .i_freeNext1(w_ImmSeleFreeToLaunchSpli_1), .o_data1_26(w_launchSpliData1_26), // imm
      .o_driveNext2(w_launchForkDriveToExeMerge_1), .i_freeNext2(w_exeMergeFree1ToLaunchFork_1), .o_data2_143(w_launchForkData2_143), // 不需要参与运�?
      .rst(rst));


  (* dont_touch="true" *) wire w_load_1, w_loadSign_1, w_isLS_1, w_aluWritePC_1, w_P_1, w_W_1, w_U_1, w_S_1, w_S1_1, w_opNot_1,w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_isMultiLS_1;
  (* dont_touch="true" *) wire w_isXt_1, w_satqS_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1, w_mulDivS_1, w_cB_1, w_ucB_1, w_bl_1, w_bx_1, w_blx_1, w_mrs_1, w_msr_1;
  (* dont_touch="true" *) wire w_movAluWritePC_1, w_addAluPC_1, w_writeRd_1; 
  (* dont_touch="true" *) wire [1:0] w_loadStoreWidth_2, w_revType_2;
  (* dont_touch="true" *) wire [3:0] w_dHi_4, w_dLo_4, w_n_4;
  (* dont_touch="true" *) wire w_immNot_1, w_rnNot_1, w_rmNot_1, w_pushPopReg_1, w_thumbExpandRor_1, w_grfFlag_1, w_is16_1;
  wire [4:0] w_msbit_5, w_lsbit_5;
//w_launchForkData2_143位宽不对
  assign {
      w_satImm_5, w_isImm_1, w_pushPopReg_1, w_pc_32, w_cond_4, w_addC0_1, w_addC1_1, w_addC_1, w_add5_1, w_add64_1, w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bit_1,w_thumbExpandRor_1,
      w_ALIGN_1, w_aluWritePC_1, w_cB_1, w_ucB_1, w_bl_1, w_bx_1, w_blx_1, w_cbz_1, w_cbnz_1, w_mrs_1, w_msr_1, w_insType_16, w_shift_3, w_load_1, w_loadStoreWidth_2,
      w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, w_sRdAddr_8, w_P_1, w_W_1, w_U_1, w_grfFlag_1, w_rnNot_1, w_rmNot_1, w_immNot_1, w_opNot_1, w_isXt_1, w_revType_2, w_satqS_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1,
      w_mulDivS_1, w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4, w_is16_1
    } = w_launchForkData2_143;

  wire w_isCb_1;
  assign w_isB_1 = w_aluWritePC_1 | w_cB_1 | w_ucB_1 | w_bl_1 | w_cbz_1 | w_cbnz_1 | w_blx_1 | w_bx_1;
  assign w_isCb_1 = w_cB_1 | w_ucB_1 | w_bl_1 | w_blx_1 | w_bx_1;

  //update

  delay4U launchDelay0(.inR(w_launchForkDriveToExeMerge_1), .outR(w_launchForkDriveToExeMerge1_1), .rst(rst));

  // 2024.22.3 -->zlt-->跳转指令也往后走
  // (* dont_touch="true" *) cSelector2_1b_launch Selector(.i_drive(w_launchForkDriveToExeMerge1_1), .i_data_1(w_isB_1), .o_free(w_exeMergeFreeToLaunchFork_1),
  // .o_driveNext0(w_driveToMe_1), .i_freeNext0(w_driveToMe_1), .o_data0_1(1'b0),
  // .o_driveNext1(w_launchForkDrive1ToExeMerge_1), .i_freeNext1(w_exeMergeFree1ToLaunchFork_1), .o_data1_1(1'b0),
  // .rst(rst));



  // 两个寄存器相关�?�处�?
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

  // 相关性检测组合�?�辑------->生成两位的标志位表示rs1和rs2是否有相关�??
      (* dont_touch="true" *) reg [5:0] r_rele_6,r_releData_6;
      (* dont_touch="true" *) wire [5:0] w_releData_6;
      (* dont_touch="true" *) wire [31:0] w_lsuData_32, w_exeData_32;
      (* dont_touch="true" *) reg [31:0] r_lsuData_32, r_exeData_32;
  assign w_rs1Addr_4 = w_rs1AndRs2_8[3:0];
  assign w_rs2Addr_4 = w_rs1AndRs2_8[7:4];
  // 这里�?要加延迟
  (* dont_touch="true" *) cSplitter2_18_6_12b_launch releSplitter(.i_drive(w_regSplitterDriveToReleSplitter_1), .i_data_18({w_dHi_4, w_sRdAddr_8, w_releData_6}), .o_free(w_releSplitterFreeToRegSplitter_1),
      .o_driveNext0(w_releSplitterDriveToWriteRdFifo_1), .i_freeNext0(w_WriteRdFifoFreeToReleSplitter_1), .o_data0_6(),
      .o_driveNext1(w_releSplitterDriveToRele6Splitter_1), .i_freeNext1(w_rele6SplitterFreeToReleSplitter_1), .o_data1_12({w_rdAddr1_4, w_sRdAddr1_8}),
      .rst(rst));
      delay8U releSplitterDelay(.inR(w_releSplitterDriveToWriteRdFifo_1), .outR(w_WriteRdFifoFreeToReleSplitter_1), .rst(rst));  

      always @(posedge w_releSplitterDriveToWriteRdFifo_1 or negedge rst) begin
        if(!rst)begin
          r_rele_6 <= 6'b0; 
          r_releData_6 <= 6'b0;
          r_exeData_32 <= 32'b0;
          r_lsuData_32 <= 32'b0;
        end else begin
          //进来之前先复位
          //r_rele_6 <= 6'b0; 
          //rd2是lsu的,exe的相关性优先级要低，0和4是lsu,1和5是exe,2和3是grf
          //与的优先级比或要高，这里给0和4加了括号
          // r_rele_6[1] <= (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) & !r_rele_6[0] & !w_isLS_1 ? 1'b1 : 1'b0;
          // r_rele_6[0] <= ((w_rs1Addr_4 == w_preRd2Addr_4 | w_rs1Addr_4 == w_preRdL2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) | r_rele_6[1]) & w_isLS_1 ? 1'b1 : 1'b0;
          // r_rele_6[5] <= (w_rs2Addr_4 == w_preRd1Addr_4 | w_rs2Addr_4 == w_preRdL1Addr_4) & !r_rele_6[4] & !w_isLS_1? 1'b1 : 1'b0;
          // r_rele_6[4] <= ((w_rs2Addr_4 == w_preRd2Addr_4 | w_rs2Addr_4 == w_preRdL2Addr_4) | r_rele_6[5]) & w_isLS_1 ? 1'b1 : 1'b0;
          // r_rele_6[2] <= (!r_rele_6[0]) & (!r_rele_6[1]);
          // r_rele_6[3] <= (!r_rele_6[4]) & (!r_rele_6[5]);
          // // exe来的数据做选择rs1
          // r_releData_6[1] <= (w_rs1Addr_4 == w_preRd1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) ? 1'b1 : 1'b0;
          // r_exeData_32 <= (r_rele_6[1] == 1'b1 | r_rele_6[5] == 1'b1) ? i_ExeData_96[31:0] : i_ExeData_96[63:32];
          // // lsu来的数据做选择rs1
          // r_releData_6[0] <= (w_rs1Addr_4 == w_preRd2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) ? 1'b1 : 1'b0;
          // r_lsuData_32 <= (r_rele_6[0] == 1'b1 | r_rele_6[4] == 1'b1) ? i_lsuData_64[31:0] : i_lsuData_64[63:32];
          // // exe来的数据做选择rs2
          // r_releData_6[5] <= w_rs2Addr_4 == w_preRd1Addr_4 ? 1'b1 : 1'b0;
          // // lsu来的数据做选择rs2
          // r_releData_6[4] <= w_rs2Addr_4 == w_preRd2Addr_4 ? 1'b1 : 1'b0;
          // r_releData_6[2] <= r_rele_6[2];
          // r_releData_6[3] <= r_rele_6[3];
          r_rele_6 <= w_rele_6; 
          r_releData_6 <= w_releData_6;
          r_exeData_32 <= w_exeData_32;
          r_lsuData_32 <= w_lsuData_32;          
          
        end
      end

      // 2024.11.3从always中拿出来，这是个组合逻辑。放在always内会有时序问题
      assign w_rele_6[1] = (w_rs1Addr_4 == w_preRd1Addr_4 | w_rs1Addr_4 == w_preRdL1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) & !w_rele_6[0] & !w_isLS_1 ? 1'b1 : 1'b0;
      assign w_rele_6[0] = ((w_rs1Addr_4 == w_preRd2Addr_4 | w_rs1Addr_4 == w_preRdL2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) | r_rele_6[1]) & w_isLS_1 ? 1'b1 : 1'b0;
      assign w_rele_6[5] = (w_rs2Addr_4 == w_preRd1Addr_4 | w_rs2Addr_4 == w_preRdL1Addr_4) & !w_rele_6[4] & !w_isLS_1? 1'b1 : 1'b0;
      assign w_rele_6[4] = ((w_rs2Addr_4 == w_preRd2Addr_4 | w_rs2Addr_4 == w_preRdL2Addr_4) | r_rele_6[5]) & w_isLS_1 ? 1'b1 : 1'b0;
      assign w_rele_6[2] = (!w_rele_6[0]) & (!w_rele_6[1]);
      assign w_rele_6[3] = (!w_rele_6[4]) & (!w_rele_6[5]); 

  // exe来的数据做选择rs1
      assign w_releData_6[1] = (w_rs1Addr_4 == w_preRd1Addr_4 | w_sRsAddr_8 == w_preSRd1Addr_8) ? 1'b1 : 1'b0;
      assign w_exeData_32 = (w_rele_6[1] == 1'b1 | w_rele_6[5] == 1'b1) ? i_ExeData_96[31:0] : i_ExeData_96[63:32];
      // lsu来的数据做选择rs1
      assign w_releData_6[0] = (w_rs1Addr_4 == w_preRd2Addr_4 | w_sRsAddr_8 == w_preSRd2Addr_8) ? 1'b1 : 1'b0;
      assign w_lsuData_32 = (w_rele_6[0] == 1'b1 | w_rele_6[4] == 1'b1) ? i_lsuData_64[31:0] : i_lsuData_64[63:32];
    
      // exe来的数据做选择rs2
      assign w_releData_6[5] = w_rs2Addr_4 == w_preRd1Addr_4 ? 1'b1 : 1'b0;
      // lsu来的数据做选择rs2
      assign w_releData_6[4] = w_rs2Addr_4 == w_preRd2Addr_4 ? 1'b1 : 1'b0;
    
      assign w_releData_6[2] = w_rele_6[2];
      assign w_releData_6[3] = w_rele_6[3];


      
      wire [5:0] w_rele1_6, w_releData1_6;
      wire [31:0] w_lsuData1_32, w_exeData1_32;
      assign w_rele1_6 = r_rele_6;
      assign w_releData1_6 = r_releData_6;
      assign w_lsuData1_32 = r_lsuData_32;
      assign w_exeData1_32 = r_exeData_32;



  wire w_rs1MergeDriveToRegMerge_1, w_rs2MergeDriveToRegMerge_1,w_regMergeFreeToRs1Merge_1,w_regMergeFreeToRs2Merge_1,w_regMergeDriveToRegSelector_1,
  w_regSelectorDriveToPsrSplitter_1,w_psrSplitterFreeToRegSelector_1,w_regSelectorFreeToRegMerge_1,w_regSeleDriveToExeMerge_1,w_exeMergeFreeToRegSele_1,
  w_psrSpliDriveToIfMerge_1,w_ifMergeFreeToPsrSpli_1, w_regSeleDriToRegImmMerge_1 ;

//update:writeRdFifo这一部分移到后面去了

  wire w_rele6SplitterDriveToRele0MergeSelector_1,w_rele6SplitterDriveToRele1MergeSelector_1, w_rele6SplitterDriveToRele2MergeSelector_1, 
  w_rele6SplitterDriveToRele3MergeSelector_1,w_rele6SplitterDriveToRele4MergeSelector_1, w_rele6SplitterDriveToRele5MergeSelector_1, 
       w_rele0MergeSelectorFreeToRele6Splitter_1,w_rele1MergeSelectorFreeToRele6Splitter_1, w_rele2MergeSelectorFreeToRele6Splitter_1,
       w_rele3MergeSelectorFreeToRele6Splitter_1,w_rele4MergeSelectorFreeToRele6Splitter_1, w_rele5MergeSelectorFreeToRele6Splitter_1, w_psrFreeToExe_1;


  wire w_rele6SplitterDriveToRelo1Merge_1, w_rele6SplitterDriveToRelo2Merge_1, w_rele6SplitterDriveToRelo3Merge_1,
       w_rele6SplitterDriveToRelo4Merge_1, w_rele6SplitterDriveToRelo5Merge_1, w_rele0MergeFreeToRele6Splitter_1,
       w_rele1MergeFreeToRele6Splitter_1, w_rele2MergeFreeToRele6Splitter_1, w_rele3MergeFreeToRele6Splitter_1,
       w_rele4MergeFreeToRele6Splitter_1, w_rele5MergeFreeToRele6Splitter_1, w_rele6SplitterDriveToRelo0Merge_1;

  wire w_releSplitterDriveToRele6SplitterDelay_1;      
  delay8U rele6SplitterDelay(.inR(w_releSplitterDriveToRele6Splitter_1), .outR(w_releSplitterDriveToRele6SplitterDelay_1), .rst(rst));  

  // 变成6路的择路-->2024.11.4 -->zlt
   (* dont_touch="true" *) cSplitter6_6b_launch rele6Splitter(.i_drive(w_releSplitterDriveToRele6SplitterDelay_1), .i_data_6(w_rele1_6), .o_free(w_rele6SplitterFreeToReleSplitter_1),
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

  // zlt --2024.10.24 修改 -->选择用哪个drive，判断条件为后续流水级有没有指令-->计数方式；后面流水级没有数据时通过刚进入分派模块的drive来驱动
  (* dont_touch="true" *) cSelector2_1b exeSele0(.i_drive(i_decoderDriveToLaunch_1), .i_data_1(!w_isExeOne_1), .o_free(),
      .o_driveNext0(w_driveToExeMer), .i_freeNext0(w_exeMerFree), .o_data0_1(),
      .o_driveNext1(w_rele0driveToMe_1), .i_freeNext1(w_rele0driveToMe1_1), .o_data1_1(),
      .rst(rst)); // exe     // 处理第一次没有执行的旁路
  delay8U isOneSeleDelay0(.inR(w_rele0driveToMe_1), .outR(w_rele0driveToMe1_1), .rst(rst));  

  (* dont_touch="true" *) cSelector2_1b lsuSele1(.i_drive(i_decoderDriveToLaunch_1), .i_data_1(!w_isLsuOne_1), .o_free(),
    .o_driveNext0(w_driveToLsuMer), .i_freeNext0(w_lsuMerFree), .o_data0_1(),
    .o_driveNext1(w_rele1driveToMe_1), .i_freeNext1(w_rele1driveToMe1_1), .o_data1_1(),
    .rst(rst)); // lsu        // 处理第一次没有访存的旁路
  delay8U isOneSeleDelay1(.inR(w_rele1driveToMe_1), .outR(w_rele1driveToMe1_1), .rst(rst)); 
  
  // zlt ---2024.10.24 新加 -->后面流水级没有数据时通过刚进入分派模块的drive来驱动，后面流水有指令的话就直接用旁路的drive。

  wire w_ExeDriveToLunch_1, w_LsuDriveToLunch_1;
  
  wire w_launchFreeToExe_1, w_launchFreeToLsu_1;
  
  (* dont_touch="true" *) cMutexMerge2_1b exeMerge(.i_drive0(i_ExeDriveToLunch_1), .i_data0_1(), .o_free0(o_launchFreeToExe_1),
      .i_drive1(w_driveToExeMer), .i_data1_1(), .o_free1(w_exeMerFree),
      .i_freeNext(w_launchFreeToExe_1), .o_driveNext(w_ExeDriveToLunch_1), .o_data_1(),
      .rst(rst));
  
  (* dont_touch="true" *) cMutexMerge2_1b lsuMerge(.i_drive0(i_LsuDriveToLunch_1), .i_data0_1(), .o_free0(o_launchFreeToLsu_1),
      .i_drive1(w_driveToLsuMer), .i_data1_1(), .o_free1(w_lsuMerFree),
      .i_freeNext(w_launchFreeToLsu_1), .o_driveNext(w_LsuDriveToLunch_1), .o_data_1(),
      .rst(rst));
  
  
  
  // grf来的drive

  wire [63:0] w_rsData_64;
  wire w_grfSrfMerDriToGrfSpli_1,w_grfSpliFreeToGrfSrfMer_1,w_rs2MergeFreeToRele3Selector_1,w_rs2MergeFreeToRele5Selector_1,w_rele5SelectorDriveToMe_1,w_grfSplitterDriveToRele3Merge_1;

  (* dont_touch="true" *) cMutexMerge2_64b_launch grfSrfMerge(.i_drive0(i_GrfDriveToLaunch_1), .i_data0_64(i_rsData_64), .o_free0(o_launchFreeToGrf_1),
      .i_drive1(i_SrfDriveToLaunch_1), .i_data1_64({32'b0, i_sRsData_32}), .o_free1(o_launchFreeToSrf_1),
      .i_freeNext(w_grfSpliFreeToGrfSrfMer_1), .o_driveNext(w_grfSrfMerDriToGrfSpli_1), .o_data_64(w_rsData_64),
      .rst(rst));
  assign w_rs1Data_32 = w_rsData_64[31:0];
  assign w_rs2Data_32 = w_rsData_64[63:32];
  wire w_grfSplitterDriveToRele2Merge_1, w_rs2MergeFreeToRele4Selector_1;
  wire w_rele3MergeFreeToGrfSplitter_1;
  
  // 实际上是择路-->2024.11.4-->zlt
  (* dont_touch="true" *) cSplitter2_64b_launch grfSplitter(.i_drive(w_grfSrfMerDriToGrfSpli_1), .i_data_64({62'b0,w_rele1_6[3:2]}), .o_free(w_grfSpliFreeToGrfSrfMer_1),
      .o_driveNext0(w_grfSplitterDriveToRele2Merge_1), .i_freeNext0(w_rele2MergeFreeToGrfSplitter_1), .o_data0_32(),
      .o_driveNext1(w_grfSplitterDriveToRele3Merge_1), .i_freeNext1(w_rele3MergeFreeToGrfSplitter_1), .o_data1_32(),
      .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele0Merge(.i_drive0(w_LsuDriveToLunch_1), .i_data0_32(w_lsuData1_32), .o_free0(w_rele0MergeFreeToLsu_1),
      .i_drive1(w_rele6SplitterDriveToRelo0Merge_1), .i_data1_1(w_rs1Lsu_1), .o_free1(w_rele0MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele0MergeDriveToRele0Selector_1), .o_data_33(w_rele0Data_33), .i_freeNext(w_rele0SelectorFreeToRele0Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele1Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(w_exeData1_32), .o_free0(w_rele1MergeFreeToExe_1),
      .i_drive1(w_rele6SplitterDriveToRelo1Merge_1), .i_data1_1(w_rs1Exe_1), .o_free1(w_rele1MergeFreeToRele6Splitter_1),
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
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele4Merge(.i_drive0(w_LsuDriveToLunch_1), .i_data0_32(w_lsuData1_32), .o_free0(w_rele4MergeFreeToLsu_1),
      .i_drive1(w_rele6SplitterDriveToRelo4Merge_1), .i_data1_1(w_rs2Lsu_1), .o_free1(w_rele4MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele4MergeDriveToRele4Selector_1), .o_data_33(w_rele4Data_33), .i_freeNext(w_rele4SelectorFreeToRele4Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch rele5Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(w_exeData1_32), .o_free0(w_rele5MergeFreeToExe_1),
      .i_drive1(w_rele6SplitterDriveToRelo5Merge_1), .i_data1_1(w_rs2Exe_1), .o_free1(w_rele5MergeFreeToRele6Splitter_1),
      .o_driveNext(w_rele5MergeDriveToRele5Selector_1), .o_data_33(w_rele5Data_33), .i_freeNext(w_rele5SelectorFreeToRele5Merge_1),
      .rst(rst));


  assign w_launchFreeToLsu_1 = w_rele0MergeFreeToLsu_1 | w_rele4MergeFreeToLsu_1;
  assign w_launchFreeToExe_1 = w_rele1MergeFreeToExe_1 | w_rele5MergeFreeToExe_1 | w_psrFreeToExe_1;

  wire w_rele1MergeDrive1ToRele1Selector_1, w_rele2MergeDrive1ToRele2Selector_1, w_rele3MergeDrive1ToRele3Selector_1,
       w_rele4MergeDrive1ToRele4Selector_1, w_rele5MergeDrive1ToRele5Selector_1,w_rele0MergeDrive1ToRele0Selector_1;

  (* dont_touch="true" *) cSelector2_33b_launch rele0Selector(.i_drive(w_rele0MergeDriveToRele0Selector_1), .i_data_33(w_rele0Data_33), .o_free(w_rele0SelectorFreeToRele0Merge_1),
                               .o_driveNext0(w_rele0SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele0Selector_1), .o_data0_32(w_lsuRs1Data_32),
                               .o_driveNext1(w_rele0SelectorDriveToMe_1), .i_freeNext1(w_rele0SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele1Selector(.i_drive(w_rele1MergeDriveToRele1Selector_1), .i_data_33(w_rele1Data_33), .o_free(w_rele1SelectorFreeToRele1Merge_1),
                               .o_driveNext0(w_rele1SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele1Selector_1), .o_data0_32(w_exeRs1Data_32),
                               .o_driveNext1(w_rele1SelectorDriveToMe_1), .i_freeNext1(w_rele1SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele2Selector(.i_drive(w_rele2MergeDriveToRele2Selector_1), .i_data_33(w_rele2Data_33), .o_free(w_rele2SelectorFreeToRele2Merge_1),
                               .o_driveNext0(w_rele2SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele2Selector_1), .o_data0_32(w_grfRs1Data_32),
                               .o_driveNext1(w_rele2SelectorDriveToMe_1), .i_freeNext1(w_rele2SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele3Selector(.i_drive(w_rele3MergeDriveToRele3Selector_1), .i_data_33(w_rele3Data_33), .o_free(w_rele3SelectorFreeToRele3Merge_1),
                               .o_driveNext0(w_rele3SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele3Selector_1), .o_data0_32(w_grfRs2Data_32),
                               .o_driveNext1(w_rele3SelectorDriveToMe_1), .i_freeNext1(w_rele3SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele4Selector(.i_drive(w_rele4MergeDriveToRele4Selector_1), .i_data_33(w_rele4Data_33), .o_free(w_rele4SelectorFreeToRele4Merge_1),
                               .o_driveNext0(w_rele4SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele4Selector_1), .o_data0_32(w_lsuRs2Data_32),
                               .o_driveNext1(w_rele4SelectorDriveToMe_1), .i_freeNext1(w_rele4SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_launch rele5Selector(.i_drive(w_rele5MergeDriveToRele5Selector_1), .i_data_33(w_rele5Data_33), .o_free(w_rele5SelectorFreeToRele5Merge_1),
                               .o_driveNext0(w_rele5SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele5Selector_1), .o_data0_32(w_exeRs2Data_32),
                               .o_driveNext1(w_rele5SelectorDriveToMe_1), .i_freeNext1(w_rele5SelectorDriveToMe_1), .o_data1_32(),
                               .rst(rst));

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

//存上一条指令的地址

      reg [3:0] r_preRd1Addr_4;
      reg [3:0] r_preRd2Addr_4;
      reg [3:0] r_preRdL1Addr_4;
      reg [3:0] r_preRdL2Addr_4;
      
      reg [7:0] r_preSRd1Addr_8;
      reg [7:0] r_preSRd2Addr_8;
      
      reg [1:0] r_cont_2; // 代表前面有几条指令
      
      //update:初始复位的值有改动
      always @(posedge w_regMergeDriveToRegSelector_1 or negedge rst) begin
        if (!rst) begin
          r_preRd1Addr_4 = 4'hf;
          r_preRd2Addr_4 = 4'hf;
          r_preRdL1Addr_4 = 4'hf;
          r_preRdL2Addr_4 = 4'hf;
          r_preSRd1Addr_8 = 8'b0;
          r_preSRd2Addr_8 = 8'b0;
        end else begin
          r_preRd2Addr_4 = r_preRd1Addr_4;
          r_preRd1Addr_4 = w_rdAddr1_4;
          r_preRdL2Addr_4 = r_preRdL1Addr_4;
          r_preRdL1Addr_4 = w_dLo_4;
          r_preSRd2Addr_8 = r_preSRd1Addr_8;
          r_preSRd1Addr_8 = w_sRdAddr1_8;
        end
      end

      // 新加--->zlt
      always @(posedge w_regMergeDriveToRegSelector_1 or negedge rst) begin
        if (!rst) begin
          r_cont_2 <= 2'b0;
          r_isExeOne_1 <= 1'b0;
          r_isLsuOne_1 <= 1'b0;
        end else begin
          r_cont_2 <= r_cont_2 + 1;
          r_isExeOne_1 <= 1'b1;
          if (r_cont_2 <= 2'b10) r_isLsuOne_1 <= 1'b1;
        end
      end
      // 2024.11.3 可能需要修改条件，每次的加空泡或者中断异常都要自己产生旁路

     assign {w_preRdL2Addr_4, w_preRdL1Addr_4,w_preRd2Addr_4, w_preRd1Addr_4, w_preSRd2Addr_8, w_preSRd1Addr_8} =  {r_preRdL2Addr_4,r_preRdL1Addr_4,r_preRd2Addr_4,r_preRd1Addr_4,r_preSRd2Addr_8,r_preSRd1Addr_8};



    //  wire w_writeRdFifoDrive1_1;
//   (* dont_touch="true" *) cFifo1_16_32b_launch writeRdFifo(.i_drive(w_releSplitterDriveToWriteRdFifo_1), .i_data_16({w_dLo_4, w_rdAddr1_4, w_sRdAddr1_8}), .o_free(w_WriteRdFifoFreeToReleSplitter_1),
//   .o_driveNext(w_writeRdFifoDrive_1), .o_data_32({w_preRdL2Addr_4, w_preRdL1Addr_4,w_preRd2Addr_4, w_preRd1Addr_4, w_preSRd2Addr_8, w_preSRd1Addr_8}), .i_freeNext(w_writeRdFifoDrive1_1),
//   .rst(rst)); // 可以写慢点就可以去掉上面的寄存器，这样数据就已经传到后面更改了也无所谓
// delay4U writeDelay0(.inR(w_writeRdFifoDrive_1), .outR(w_writeRdFifoDrive1_1), .rst(rst));

  //这里名字是selector但是实际上是splitter
  (* dont_touch="true" *) cSplitter2_96b_launch regSelector(.i_drive(w_regMergeDriveToRegSelector_1), .i_data_96({w_pc_32, w_Rs1AndRs2Data_64}), .o_free(w_regSelectorFreeToRegMerge_1),
      .o_driveNext0(w_regSeleDriToPcsele_1), .o_data0_32(w_pc1_32), .i_freeNext0(w_PcSeleFreeToRegSele_1),
      .o_driveNext1(w_regSeleDriToRegImmMerge_1), .o_data1_64(w_lastRs1AndRs2Data_64), .i_freeNext1(w_regImmMergeFreeToRegSele_1),
      .rst(rst));

  wire w_regSeleDri1ToPcsele_1;
  delay2U pcDelay0(.inR(w_regSeleDriToPcsele_1), .outR(w_regSeleDri1ToPcsele_1), .rst(rst));
  (* dont_touch="true" *) cSelector2_1b_launch PcSelector(.i_drive(w_regSeleDri1ToPcsele_1), .i_data_1(~w_isB_1), .o_free(w_PcSeleFreeToRegSele_1),
      .o_driveNext0(o_launchDriveToIf_1), .i_freeNext0(i_IfFreeToLaunch_1), .o_data0_1(),
      .o_driveNext1(w_PcSeleDriToMe_1), .i_freeNext1(w_PcSeleDriToMe_1), .o_data1_1(),
      .rst(rst));
  assign o_pc_32 = w_is16_1 ? w_pc1_32 + 2 : w_pc1_32 + 4;
  // 5.23 还需�?点改动，后面接一个择路，�?路去顺序取指，另�?路去处理跳转�?


  wire w_immSplitterDriveToZeroFifo_1,w_immSplitterDriveToSignFifo_1,w_immSplitterDriveToDecoFifo_1,w_immSplitterDriveToThumbFifo_1,
       w_zeroFifoFreeToImmSplitter_1,w_signFifoFreeToImmSplitter_1,w_decoFifoFreeToImmSplitter_1,w_thumbFifoFreeToImmSplitter_1,
       w_zeroFifoDriveToImmMerge_1,w_signFifoDriveToImmMerge_1,w_decoFifoDriveToImmMerge_1,w_thumbFifoDriveToImmMerge_1,
       w_immMergeFreeToZeroFifo_1,w_immMergeFreeToSignFifo_1,w_immMergeFreeToDecoFifo_1,w_immMergeFreeToThumbFifo_1,
       w_immMergeToImmExeMerge_1,w_exeMergeFreeToImmMerge_1,w_ifMergeFreeToExeSpli_1,w_exeSpliDriveToIfMerge_1,w_wGrfSpliDriToIfMerge_1,
       w_ifMergeFreeTowGrfSpli_1 ;



  // imm扩展

    (* dont_touch="true" *) wire w_ImmSeleDriToImmSpli_1, w_ImmSeleDriToImmExeMerge_1,w_immExeMergeFreeToImmSele_1,w_ImmSpliFreeToImmSele_1;
    (* dont_touch="true" *) wire w_ImmSeleDri1ToImmExeMerge_1, w_immExeMergeFree1ToImmSele_1;
    (* dont_touch="true" *) wire [25:0] w_ImmSeleData0_26;
    (* dont_touch="true" *) wire [25:0] w_ImmSeleData1_26;
    (* dont_touch="true" *) wire [23:0] w_zeroData_24, w_signData_24, w_decoData_24, w_thumbData_24;
    (* dont_touch="true" *) wire [15:0] w_registers_16;

  wire w_launchSpliDri1ToImmSele_1,w_launchSpliDri2ToImmSele_1;
  delay4U immDelay0(.inR(w_launchSpliDriToImmSele_1), .outR(w_launchSpliDri1ToImmSele_1), .rst(rst));  
  delay4U immDelay1(.inR(w_launchSpliDri1ToImmSele_1), .outR(w_launchSpliDri2ToImmSele_1), .rst(rst));
    
  (* dont_touch="true" *) cSelector3_28b_launch ImmSelector (.i_drive(w_launchSpliDri2ToImmSele_1), .i_data_28({w_isImm_1, w_pushPopReg_1, w_launchSpliData1_26}), .o_free(w_ImmSeleFreeToLaunchSpli_1),
      .o_driveNext0(w_ImmSeleDriToImmSpli_1), .i_freeNext0(w_ImmSpliFreeToImmSele_1), .o_data0_26(w_ImmSeleData0_26),
      .o_driveNext1(w_ImmSeleDriToImmExeMerge_1), .i_freeNext1(w_immExeMergeFreeToImmSele_1), .o_data1_26(w_ImmSeleData1_26),
      .o_driveNext2(w_ImmSeleDri1ToImmExeMerge_1), .i_freeNext2(w_immExeMergeFree1ToImmSele_1), .o_data2_16(w_registers_16),
      .rst(rst)); // 修改条件

  (* dont_touch="true" *) cSelector4_26b_launch ImmSplitter (.i_drive(w_ImmSeleDriToImmSpli_1), .i_data_26(w_ImmSeleData0_26), .o_free(w_ImmSpliFreeToImmSele_1),
      .o_driveNext0(w_immSplitterDriveToZeroFifo_1), .i_freeNext0(w_zeroFifoFreeToImmSplitter_1), .o_data0_24(w_zeroData_24),
      .o_driveNext1(w_immSplitterDriveToSignFifo_1), .i_freeNext1(w_signFifoFreeToImmSplitter_1),.o_data1_24(w_signData_24),
      .o_driveNext2(w_immSplitterDriveToDecoFifo_1), .i_freeNext2(w_decoFifoFreeToImmSplitter_1),.o_data2_24(w_decoData_24),
      .o_driveNext3(w_immSplitterDriveToThumbFifo_1), .i_freeNext3(w_thumbFifoFreeToImmSplitter_1),.o_data3_24(w_thumbData_24),
      .rst(rst)); //其实是择路，名字起错�?

  // �?要译码模块统计一共多少种imm，imm扩展类型和多少位的imm   5�?8�?12�?16 -> 00�?01 �?10�? 11
  // 16位的指令 imm�?3位�??5位�??7位�??8位�??11�?

  // imm 16位�?�扩展方�?2位，imm种类三位 3�?5�?7�?8�?11�?12�?16

  assign w_saturate_5 = w_satImm_5 + 1;

  assign {w_zeroimm16_1, w_zeroimm12_1, w_zeroimm8_1, w_zeroimm5_1, w_zeroimm2_1, w_zeroimm11_1, w_zeroimm7_1, w_zeroimm3_1} = w_zeroData_24[23:16];
  assign {w_signimm16_1, w_signimm12_1, w_signimm8_1, w_signimm5_1, w_signimm2_1, w_signimm11_1, w_signimm7_1, w_signimm3_1} = w_signData_24[23:16];
  assign {w_decoimm16_1, w_decoimm12_1, w_decoimm8_1, w_decoimm5_1, w_decoimm2_1, w_decoimm11_1, w_decoimm7_1, w_decoimm3_1} = w_decoData_24[23:16];
  assign {w_thumbimm16_1, w_thumbimm12_1, w_thumbimm8_1, w_thumbimm5_1, w_thumbimm2_1, w_thumbimm11_1, w_thumbimm7_1, w_thumbimm3_1} = w_thumbData_24[23:16];
  assign w_zeroImm_16 = w_zeroData_24[15:0];
  assign w_signImm_16 = w_signData_24[15:0];
  assign w_decoImm_16 = w_decoData_24[15:0];
  assign w_thumbImm_16 = w_thumbData_24[15:0];

  assign w_imm_5 = w_launchSpliData1_26[4:0];

  // 0扩展-->�?要两个零扩展，因为有指令包括两个操作数，但是都是五位的操作数-->位操作和饱和运算---->后面那一位不算做imm，当作一个普通的操作�?
  // 饱和运算有一�?5位的立即数需要＋1---->还未处理-->已经处理
  assign w_immZero_32 = {{32{w_zeroimm5_1}} & {28'b0, w_zeroImm_16[3:0]}}
         | {{32{w_zeroimm8_1}} & {25'b0, w_zeroImm_16[6:0]}}
         | {{32{w_zeroimm12_1}} & {20'b0, w_zeroImm_16[11:0]}}
         | {{32{w_zeroimm16_1}} & {16'b0, w_zeroImm_16}}
         | {{32{w_zeroimm3_1}} & {29'b0, w_zeroImm_16[2:0]}}
         | {{32{w_zeroimm2_1}} & {30'b0, w_zeroImm_16[1:0]}}
         | {{32{w_zeroimm7_1}} & {15'b0, w_zeroImm_16[6:0]}}
         | {{32{w_zeroimm11_1}} & {22'b0, w_zeroImm_16[10:0]}};

  // 符号扩展
  assign w_immSign_32 = {{32{w_signimm5_1}} & {{28{w_signImm_16[4]}}, w_signImm_16[4:0]}}
         | {{32{w_signimm8_1}} & {{25{w_signImm_16[7]}}, w_signImm_16[7:0]}}
         | {{32{w_signimm12_1}} & {{21{w_signImm_16[11]}}, w_signImm_16[11:0]}}
         | {{32{w_signimm16_1}}& {{16{w_signImm_16[15]}}, w_signImm_16}};

  // decode扩展
  // 返回值：1、imm_32 2、shift_type_3

  // 5.24 11:50存档点�?��??


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


  // thumb扩展

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

// 计算pop和push指令寄存器列表中有几个1
  assign w_bitCount_4 = w_registers_16[0] + w_registers_16[1] + w_registers_16[2] + w_registers_16[3]
                      + w_registers_16[4] + w_registers_16[5] + w_registers_16[6] + w_registers_16[7]
                      + w_registers_16[14] + w_registers_16[15];
  assign w_4BitCount_4 = 4 * w_bitCount_4;

  (* dont_touch="true" *) wire w_immSplitterDrive1ToDecoFifo_1, w_immSplitterDrive1ToThumbFifo_1;
  // �?要加延迟
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

  // op1,op2,op3 -----> w_rnData_32, w_rmData_32, w_raData_32, w_last1Imm_32 组合成三个操作数
  // rn是rs1,rm是rs2
  // push 和 pop的第二个操作数还没有弄，第二个操作数是registers -- √
  assign {w_last1Imm_32, w_rmData1_32, w_rnData1_32} = w_op_96;
  assign w_last2Imm_32 = w_immNot_1 ? (~ w_last1Imm_32) : w_last1Imm_32;
  assign w_rmData_32 = w_rmNot_1 ? ~w_rmData1_32 : w_rmData1_32;
  assign w_rnData_32 = w_rnNot_1 ? ~w_rnData1_32 : w_rnData1_32;

  wire w_opDataFifoDriToSele_1,w_opDataSeleFreeToFifo_1,w_opDataSeleDriToBOPMerge_1,w_BOPMergeFreeToOpDataSele_1;
    (* dont_touch="true" *) wire [95:0] w_opDataToExe_96, w_opDataToB_96;
    (* dont_touch="true" *) wire [31:0] w_lr_32, w_nextInsAddr_32;
  assign w_lr_32 = {w_nextInsAddr_32[31:1], 1'b1};
  assign w_nextInsAddr_32 = w_pc_32 - 2;

  // 还得修改-->PC，有两个立即数的情况-->当前指令的pc多整出来�?段，两个立即数的第二个立即数�?0扩展�?

  (* dont_touch="true" *) wire [31:0] w_op1_32, w_op2_32, w_op3_32;

  //饱和运算第二个操作数为正常扩展imm，第三个操作数为w_saturate_5；位操作第一个操作数为正常扩展立即数，第二个操作数为w_satImm_5
  assign w_op1_32 = w_rnOp1 & !w_ALIGN_1 ? w_rnData_32 : (w_rmOp1 ? w_rmData_32 : w_ALIGN_1 ? w_pc_32 : w_thumbExpandRor_1 ? w_immThumb_32 : w_last2Imm_32); // 特殊寄存器应该也放进op1�?-->未处�?-->在译码中处理
  assign w_op2_32 = w_rmOp2 ? w_rmData_32 : (w_bit_1 ? {27'b0, w_satImm_5} : w_thumbExpandRor_1 ? {27'b0, w_thumbImm_12[11:7]} : w_last2Imm_32);// 位运算的第二个立即数
  assign w_op3_32 = w_rnOp3 ? w_rnData_32 : (w_immOp3 ? {27'b0, w_saturate_5} : w_blx_1 ? w_lr_32 : 32'b0); // 饱和运算的第三个立即数
  // 如果不过执行的指令要怎么传递准备回写的数据，放在第三个操作数吗？好像是第一个操作数

  // wire w_regImmMerDri1ToOpData_1;
  // delay2U opDelay0(.inR(w_immSplitterDriveToDecoFifo_1), .outR(w_immSplitterDrive1ToDecoFifo_1));

  //加延迟后的w_regImmMerDriToOpData_1�?要接到跳转处理那�?,后面要加�?个择�?-->已加
  (* dont_touch="true" *) cFifo1_96b_launch opDataFifo(.i_drive(w_regImmMerDriToOpData_1), .i_data_96(w_op123_96), .o_free(w_opDataFifoFreeToregImmMerge_1),
      .o_driveNext(w_opDataFifoDriToSele_1), .o_data_96(w_op_96), .i_freeNext(w_opDataSeleFreeToFifo_1),
      .rst(rst));

      wire w_opDataFifoDri1ToSele_1;
      delay4U opDelay0(.inR(w_opDataFifoDriToSele_1), .outR(w_opDataFifoDri1ToSele_1), .rst(rst));  

  wire w_opDataSeleDriToBSele_1, w_BSeleFreeToOpDataSele_1;
  // 2024.11.1 --择路改成分流-->跳转指令也要往后走方便异常处理同时后面的waitMerge总要三路都到-->zlt  //11.2 free1和free0一样暂时为了测试 -->hrq -->已改--zlt
  (* dont_touch="true" *) cSplitter2_1b opDataSpli(.i_drive(w_opDataFifoDri1ToSele_1), .i_data_1(), .o_free(w_opDataSeleFreeToFifo_1),
      .o_driveNext0(w_opDataSeleDriToBSele_1), .i_freeNext0(w_BSeleFreeToOpDataSele_1), .o_data0_1(),
      .o_driveNext1(w_regSeleDriveToExeMerge_1), .i_freeNext1(w_exeMergeFreeToRegSele_1), .o_data1_1(),
      .rst(rst));

  wire w_driveToMe1_1;
  // 2024.11.3 新加择路-->不是跳转指令的话不去走下面的路
  (* dont_touch="true" *) cSelector2_1b Selector(.i_drive(w_opDataSeleDriToBSele_1), .i_data_1(w_isB_1), .o_free(w_BSeleFreeToOpDataSele_1),
  .o_driveNext0(w_opDataSeleDriToBOPMerge_1), .i_freeNext0(w_BOPMergeFreeToOpDataSele_1), .o_data0_1(1'b0),
  .o_driveNext1(w_driveToMe_1), .i_freeNext1(w_driveToMe1_1), .o_data1_1(1'b0),
  .rst(rst));
  delay4U bDelay1(.inR(w_driveToMe_1), .outR(w_driveToMe1_1), .rst(rst));  
  // 分派的另�?条路--—�??>主要是跳转处�?-->用到aluWritePc()的指令也放在这里处理

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

  assign w_psrRele_2[0] = w_PerS_1 == 1 ? 1'b1 : 1'b0;
  assign w_psrRele_2[1] = w_PerS_1 == 1 ? 1'b0 : 1'b1;

  (* dont_touch="true" *) wire w_psrExe_1, w_psrPsr_1, w_PerS1_1;
  wire w_psrReleSpliDriToWriteSFifo_1,w_writeSFifoFreeToPsrReleSpli_1;
  wire w_psrReleSpliDriveToPsrRele0Merge, w_psrRele0MergeFreeToPsrReleSpli_1;

//update:？？？？确定最后一路的去向
  (* dont_touch="true" *) cSplitter3_3b_launch psrReleSpli(.i_drive(w_branchDriToPsrReleSpli_1), .i_data_3({w_S_1, w_psrRele_2}), .o_free(w_psrReleSpliFreeToBranchSpli_1),
      .o_driveNext0(w_psrReleSpliDriveToPsrRele0Merge), .i_freeNext0(w_psrRele0MergeFreeToPsrReleSpli_1), .o_data0_1(w_psrExe_1),
      .o_driveNext1(w_psrReleSpliDriveToPsrRele1Merge), .i_freeNext1(w_psrRele1MergeFreeToPsrReleSpli_1), .o_data1_1(w_psrPsr_1),
      .o_driveNext2(w_psrReleSpliDriToWriteSFifo_1), .i_freeNext2(w_writeSFifoFreeToPsrReleSpli_1), .o_data2_1(w_PerS1_1), // 记录当前指令的S�?
      .rst(rst));

  wire w_writeSFifoDrive_1,w_writeSFifoDriveDelay_1;
  (* dont_touch="true" *) cFifo1_1b_launch writeSFifo(.i_drive(w_psrReleSpliDriToWriteSFifo_1), .i_data_1(w_PerS1_1), .o_free(w_writeSFifoFreeToPsrReleSpli_1),
      .o_driveNext(w_writeSFifoDrive_1), .o_data_1(w_PerS_1), .i_freeNext(w_writeSFifoDriveDelay_1),
      .rst(rst)); // 可以写慢点就可以去掉上面的寄存器，这样数据就已经传到后面更改了也无所谓
      delay8U writeSFifoDelay(.inR(w_writeSFifoDrive_1), .outR(w_writeSFifoDriveDelay_1), .rst(rst));

  // 2024.10.24 zlt 修改 

  // wire w_psrRele0MergeSelectorDriveToPsrRele0Merge_1,w_psrRele0MergeFreeToPsrRele0MergeSelector_1;
  // wire w_psrRele0MergeSelectorDriveToMe_1;
  // (* dont_touch="true" *) cSelector2_1b psrRele0MergeSelector(.i_drive(w_psrReleSpliDriveToPsrRele0MergeSelector), .i_data_1(w_isOne_1), .o_free(w_psrRele0MergeSelectorFreeToPsrReleSpli_1),
  // .o_driveNext0(w_psrRele0MergeSelectorDriveToPsrRele0Merge_1), .i_freeNext0(w_psrRele0MergeFreeToPsrRele0MergeSelector_1), .o_data0_1(),
  // .o_driveNext1(w_psrRele0MergeSelectorDriveToMe_1), .i_freeNext1(w_psrRele0MergeSelectorDriveToMe_1), .o_data1_1(),
  // .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch psrRele0Merge(.i_drive0(w_ExeDriveToLunch_1), .i_data0_32(i_ExeData_96[95:64]), .o_free0(w_psrFreeToExe_1),
      .i_drive1(w_psrReleSpliDriveToPsrRele0Merge), .i_data1_1(w_psrExe_1), .o_free1(w_psrRele0MergeFreeToPsrReleSpli_1),
      .o_driveNext(w_psrRele0MergeDriToPsrRele0Sele_1), .o_data_33(w_psrRele0Data_33), .i_freeNext(w_psrRele0SeleFreeToPsrRele0Merge_1),
      .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_32_1_33b_launch psrRele1Merge(.i_drive0(w_psrReleSpliDriveToPsrRele1Merge), .i_data0_32(i_psrData_32), .o_free0(w_psrRele1MergeFreeToPsrReleSpli_1),
      .i_drive1(i_PSRDriveToLaunch_1), .i_data1_1(w_psrPsr_1), .o_free1(o_launchFreeToPSR_1),
      .o_driveNext(w_psrRele1MergeDriToPsrRele1Sele_1), .o_data_33(w_psrRele1Data_33), .i_freeNext(w_psrRele1SeleFreeToPsrRele1Merge_1),
      .rst(rst));

      wire w_psrRele0MergeDri1ToPsrRele0Sele_1;
      delay2U psrDelay0(.inR(w_psrRele0MergeDriToPsrRele0Sele_1), .outR(w_psrRele0MergeDri1ToPsrRele0Sele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_33b_launch psrRele0Selector(.i_drive(w_psrRele0MergeDri1ToPsrRele0Sele_1), .i_data_33(w_psrRele0Data_33), .o_free(w_psrRele0SeleFreeToPsrRele0Merge_1),
      .o_driveNext0(w_psrRele0SeleDriveToPsrDataMerge_1), .i_freeNext0(w_psrDataMergeFreeToPsrRele0Sele_1), .o_data0_32(w_psrData0_32),
      .o_driveNext1(w_psrRele0SeleDriToMe_1), .i_freeNext1(w_psrRele0SeleDriToMe_1), .o_data1_32(),
      .rst(rst));

      wire w_psrRele1MergeDri1ToPsrRele1Sele_1;
      delay2U psr1Delay0(.inR(w_psrRele1MergeDriToPsrRele1Sele_1), .outR(w_psrRele1MergeDri1ToPsrRele1Sele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_33b_launch psrRele1Selector(.i_drive(w_psrRele1MergeDri1ToPsrRele1Sele_1), .i_data_33(w_psrRele1Data_33), .o_free(w_psrRele1SeleFreeToPsrRele1Merge_1),
      .o_driveNext0(w_psrRele1SeleDriveToPsrDataMerge_1), .i_freeNext0(w_psrDataMergeFreeToPsrRele1Sele_1), .o_data0_32(w_psrData1_32),
      .o_driveNext1(w_psrRele1SeleDriToMe_1), .i_freeNext1(w_psrRele1SeleDriToMe_1), .o_data1_32(),
      .rst(rst));

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

  assign w_addType_3 = {w_addCarry_1, w_addnum_2}; // 还要多一位表示是不是64位加�?


  wire w_branchDriToExeMerge_1, w_exeMergeFreeToBranchSele_1;
  wire w_bSpliDriToBSele_1, w_bSeleFreeToBSpli_1, w_bSeleDriToBFifo_1, w_bSeleDriToMe_1, w_bFifoFreeToBSele_1, w_bFifoDriToIfMer_1;

  (* dont_touch="true" *) cSplitter2_7_3_4b_launch branchSplitter(.i_drive(w_psrDataMergeDriveToBranchSele_1), .i_data_7({w_addType_3, w_c_1, w_z_1, w_n_1, w_v_1}), .o_free(w_branchSeleFreeToPsrDataMerge_1),
      .o_driveNext0(w_branchDriToExeMerge_1), .i_freeNext0(w_exeMergeFreeToBranchSele_1), .o_data0_3(w_addType1_3),
      .o_driveNext1(w_bSpliDriToBSele_1), .i_freeNext1(w_bSeleFreeToBSpli_1), .o_data1_4({w_c1_1, w_z1_1, w_n1_1, w_v1_1}),
      .rst(rst));

  wire w_bSeleDriToBOpMer_1,w_BOpFreeToBSele_1;

  wire w_bSpliDri1ToBSele_1;
  delay2U bDelay0(.inR(w_bSpliDriToBSele_1), .outR(w_bSpliDri1ToBSele_1), .rst(rst)); 
  (* dont_touch="true" *) cSelector2_9b_launch branchSelector(.i_drive(w_bSpliDri1ToBSele_1), .i_data_9({w_isB_1, w_c1_1, w_z1_1, w_n1_1, w_v1_1, w_cond_4}), .o_free(w_bSeleFreeToBSpli_1),
      .o_driveNext0(w_bSeleDriToBOpMer_1), .i_freeNext0(w_BOpFreeToBSele_1), .o_data0_8({w_c2_1, w_z2_1, w_n2_1, w_v2_1, w_cond1_4}),
      .o_driveNext1(w_bSeleDriToMe_1), .i_freeNext1(w_bSeleDriToMe_1), .o_data1_8(),
      .rst(rst));
  // 5.23 还需�?点大改动->主要是因为aluWritePC()也需要用到寄存器，需要判断相关�?�引起的改动

  (* dont_touch="true" *) cWaitMerge2_1b_launch bAndOpMerge(.i_drive0(w_opDataSeleDriToBOPMerge_1), .i_data0_1(1'b0), .o_free0(w_BOPMergeFreeToOpDataSele_1),
      .i_drive1(w_bSeleDriToBOpMer_1), .i_data1_1(1'b0), .o_free1(w_BOpFreeToBSele_1),
      .o_driveNext(w_bSeleDriToBFifo_1), .o_data_1(), .i_freeNext(w_bFifoFreeToBSele_1),
      .rst(rst));


  // 跳转处理 主要是看那些状�?�位

  // aluWritePC()-->两条指令，w_addAluPC_1, w_movAluWritePC_1

  // w_addAluPC_1先移位再做加法， w_movAluWritePC_1直接赋�??

  // 比较条件，为1时跳转，�?0时条件不成立，不跳转
  assign w_b_1 = (w_cond1_4 == 4'b0000 & w_z2_1 == 1'b1  & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0001 & w_z2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0010 & w_c2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0011 & w_c2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0100 & w_n2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0101 & w_n2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0110 & w_v2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b0111 & w_v2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1000 & w_c2_1 == 1'b1 & w_z2_1 == 1'b0 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1001 & w_c2_1 == 1'b0 & w_z2_1 == 1'b1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1010 & w_n2_1 == w_v_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1011 & w_n2_1 != w_v_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1100 & w_z2_1 == 0 & w_n2_1 == w_v2_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1100 & w_z2_1 == 1 & w_n2_1 != w_v2_1 & w_isCb_1 == 1'b1)
         | (w_cond1_4 == 4'b1110 & w_isCb_1 == 1'b1)
         | (w_cbz_1 == 1'b1 & w_op1_32 == 32'b0)
         | (w_cbnz_1 == 1'b1 & w_op1_32 != 32'b0);

  (* dont_touch="true" *) reg [31:0] r_branchPc_32;

  wire w_bSeleDriToBFifo1_1;
  delay4U b1Delay0(.inR(w_bSeleDriToBFifo_1), .outR(w_bSeleDriToBFifo1_1), .rst(rst)); 

  always @(posedge w_bSeleDriToBFifo1_1 or negedge rst)
  begin

    if (!rst)
    begin
      r_branchPc_32 = 32'b0;
    end
    else
    begin
      if (w_b_1)
      begin
        r_branchPc_32 = w_pc_32 + w_last2Imm_32;
      end

      if (~w_b_1)
      begin
        if(w_is16_1)
        r_branchPc_32 = w_pc_32 + 2;
        else r_branchPc_32 = w_pc_32 + 4;
      end

      if (w_movAluWritePC_1 | w_blx_1 | w_bx_1)
      begin
        r_branchPc_32 = w_op1_32;
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

  (* dont_touch="true" *) cFifo1_32b_launch bFifo(.i_drive(w_bSeleDriToBFifo1_1), .i_data_32(w_branchPc_32), .o_free(w_bFifoFreeToBSele_1),
      .o_driveNext(o_bDriToIf), .o_data_32(o_branchPc_32), .i_freeNext(i_bFreeFromIf),
      .rst(rst));



  // 指令路径编码-->�?�?16�?

  wire w_add_1; // 只做加法的指�?
  wire w_alignAndAdd_1; //ALIGN,ADD
  wire w_shiftAdd_1;// shift,add
  wire w_mulAdd_1;// mul,add
  wire w_onlyMul_1;// 只做乘法
  wire w_onlyDiv_1;// 只做除法
  wire w_onlyAnd_1;// 只做�?
  wire w_onlyEor_1;// 只做异或
  wire w_onlyOr_1;// 只做�?
  wire w_shiftAnd_1;// shift,and
  wire w_shiftEor_1;// shift,eor
  wire w_shiftOr_1;// shift,or
  wire w_onlyShift_1;// 只做移位
  wire w_shiftSatQ_1;// shifr,satq
  wire w_hsbAdd_1;
  wire w_onlyRev_1;// 只做翻转



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
  // msbit 为w_satImm_5，lsbit为立即数 
  assign w_launchDataToExe1_99 = {w_msr_1, w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1, w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4, w_registers_16,
                                  w_pc_32, w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, w_shift_3, 
                                  w_P_1, w_W_1, w_U_1, w_S_1, w_grfFlag_1, w_opNot_1, w_isXt_1,
                                  w_shiftC_1, w_shiftS_1, w_shiftNum_1, w_revType_2, w_satqS_1, w_mulDivS_1}; // w_msbit_5, w_lsbit_5, w_isMultiLS_1, w_n_4


//dirve1加延时
wire w_launchForkDrive1ToExeMergeDelay_1;
  (* dont_touch="true" *)delay8U exeMerge2Delay(.inR(w_launchForkDriveToExeMerge1_1), .outR(w_launchForkDrive1ToExeMergeDelay_1), .rst(rst));                                                                   
  // 准备好数据进执行和取指
  (* dont_touch="true" *) cWaitMerge3_104_99_4_207b_launch exeMerge2(.i_drive0(w_regSeleDriveToExeMerge_1), .i_data0_104({w_insPath_8, w_op3_32, w_op2_32, w_op1_32}), .o_free0(w_exeMergeFreeToRegSele_1),
      .i_drive1(w_launchForkDrive1ToExeMergeDelay_1), .i_data1_99(w_launchDataToExe1_99), .o_free1(w_exeMergeFree1ToLaunchFork_1),
      .i_drive2(w_branchDriToExeMerge_1), .i_data2_4({w_c_1,w_addType1_3}), .o_free2(w_exeMergeFreeToBranchSele_1),
      .i_freeNext(i_ExeFreeToLaunch_1), .o_driveNext(o_launchDriveToExe_1), .o_data_207(o_launchDataToExe_207),
      .rst(rst));

  // (* dont_touch="true" *) wire w_regSeleDri1ToIfMerge_1, w_regSeleDri2ToIfMerge_1, w_regSeleDri3ToIfMerge_1;
  // (* dont_touch="true" *) wire w_bFifoDri1ToIfMer_1, w_bFifoDri2ToIfMer_1, w_bFifoDri3ToIfMer_1;
  // (* dont_touch="true" *) delay4U ifDelay0(.inR(w_regSeleDriToIfMerge_1), .outR(w_regSeleDri1ToIfMerge_1)); 
  // (* dont_touch="true" *) delay4U ifDelay1(.inR(w_regSeleDri1ToIfMerge_1), .outR(w_regSeleDri2ToIfMerge_1)); 
  // (* dont_touch="true" *) delay4Unit outdelay1 (.inR(w_regSeleDri2ToIfMerge_1), .outR(w_regSeleDri3ToIfMerge_1), .rst(rst));

  // (* dont_touch="true" *) delay4U ifDelay2(.inR(w_bFifoDriToIfMer_1), .outR(w_bFifoDri1ToIfMer_1)); 
  // (* dont_touch="true" *) delay4U ifDelay3(.inR(w_bFifoDri1ToIfMer_1), .outR(w_bFifoDri2ToIfMer_1)); 
  // (* dont_touch="true" *) delay4U ifDelay4(.inR(w_bFifoDri2ToIfMer_1), .outR(w_bFifoDri3ToIfMer_1)); 
    // 取指
  // (* dont_touch="true" *) cMutexMerge2_32b_launch ifMerge(.i_drive0(w_regSeleDriToIfMerge_1), .i_data0_32(w_pc1_32 + 4), .o_free0(w_ifMergeFreeToRegSele_1),
  // .i_drive1(w_bFifoDriToIfMer_1), .i_data1_32(w_branchPc1_32), .o_free1(w_ifMergeFreeToBFifo_1),
  // .i_freeNext(i_IfFreeToLaunch_1), .o_driveNext(o_launchDriveToIf_1), .o_data_32(o_pc_32),
  // .rst(rst));

endmodule
