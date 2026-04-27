`timescale 1 ns / 1 ps
module execute(
    rst,
    i_launchDriveToExecute_1, i_wen_2, i_launchDataToExe_207,o_executeFreeToLaunch_1,

    i_executeFreeFromLsu_1,o_executeDataToLsu_163,o_executeDriveToLsu_1,

    i_executeFreeFromExcp_1,o_exeToExcpData_36,o_exeDriveToExcp_1,

    i_executeFreeFromGrf_1,o_executeToGrfData_8,o_executeDriveToGrf_1,
    i_grfDriveToExecute_1,i_grfToExecuteData_64,o_executeFreeToGrf_1,

    i_LsuDriveToExe_1,i_lsuToExeData_64,o_lsuFreeFromExecute_1,
    i_executeFreeFromLaunchByPath_1,o_exeToLaunchData_96,o_exeByPathDriveToLaunch_1,

    o_executeInUseFlag_1,
    i_launchDrive_1,


    //11/6 zwm ->ȡgrf��־λ
    o_grfFlag_1, o_wen_2
);
//! ��λ
input rst;
//! ����
input i_launchDriveToExecute_1;
input i_executeFreeFromLsu_1;
//�쳣��ִ�еĸ�λ
input i_executeFreeFromExcp_1;
//��grf�����ź�
input i_executeFreeFromGrf_1;
input i_grfDriveToExecute_1;
//��lsu������·
input i_LsuDriveToExe_1;
input [63:0] i_lsuToExeData_64;
//���ɸ�ִ��ģ������ݰ�????????
input [1:0] i_wen_2;
input [206:0] i_launchDataToExe_207;
input [63:0] i_grfToExecuteData_64;
//�ӷ�����·����free
input i_executeFreeFromLaunchByPath_1;
//exe���쳣�����弰����
output o_exeDriveToExcp_1;
output [35:0] o_exeToExcpData_36;
//exe�����ɵ���·
output [95:0] o_exeToLaunchData_96;
output o_exeByPathDriveToLaunch_1;
output o_executeFreeToLaunch_1;
output o_lsuFreeFromExecute_1;
output o_executeDriveToLsu_1;
output o_executeFreeToGrf_1;
output o_executeDriveToGrf_1;
output [7:0] o_executeToGrfData_8;
output [162:0] o_executeDataToLsu_163;
//11/6 zwm -> ȡgrf��־λ
output o_grfFlag_1;
output [1:0] o_wen_2;
output o_executeInUseFlag_1;

input i_launchDrive_1;

assign o_wen_2 = i_wen_2;

//8/7�������ݰ�
//����д���������ݰ�
 (* dont_touch="true" *)wire w_msr_1,w_bfi_1,w_bfc_1,w_sbfx_1,w_ubfx_1;
 (* dont_touch="true" *)wire [4:0] w_msbit_5,w_lsbit_5;
//���ô���������ݰ�????????
 (* dont_touch="true" *)wire w_isMultiLS_1;
 (* dont_touch="true" *)wire [3:0] w_n_4;
 (* dont_touch="true" *)wire [15:0] w_registerList_16;
//�Է����������ݽ��в��????????
 (* dont_touch="true" *)wire w_c_1, w_load_1, w_loadSign_1, w_isLS_1, w_writeRd_1, w_P_1, w_W_1, w_U_1, w_S_1, w_grfFlag_1, w_opNot_1, w_isXt_1, w_shiftC_1, w_shiftS_1, w_satqS_1, w_mulDivS_1;
 (* dont_touch="true" *)wire [2:0] w_addtype1_3, w_shift_3;
 (* dont_touch="true" *)wire [31:0] w_pc_32, w_op3_32, w_op2_32, w_op1_32;
 (* dont_touch="true" *)wire [1:0] w_loadStoreWidth_2, w_revType_2;
 (* dont_touch="true" *)wire [3:0] w_dHi_4, w_dLo_4;
 (* dont_touch="true" *)wire [7:0] w_insPath_8;
 (* dont_touch="true" *)wire w_shiftNum_1;

assign {w_c_1,w_addtype1_3,w_msr_1,w_bfi_1,w_bfc_1,w_sbfx_1,w_ubfx_1,w_msbit_5,w_lsbit_5, w_isMultiLS_1,w_n_4,w_registerList_16,
        w_pc_32, w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, 
        w_shift_3, w_P_1, w_W_1, w_U_1, w_S_1, w_grfFlag_1, w_opNot_1, w_isXt_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1,
        w_revType_2, w_satqS_1, w_mulDivS_1, w_insPath_8, w_op3_32, w_op2_32, w_op1_32} = i_launchDataToExe_207;
//11/6 zwm->ȡgrf��־λ���????????
assign o_grfFlag_1 = w_grfFlag_1;
//8/7����
//������дר�ñ�־λ
wire [14:0] w_writeBackIdentifyData_15;
//�����ô�ר�ñ�־λ
 (* dont_touch="true" *)wire [22:0] w_memoryIdentifyData_23;
 (* dont_touch="true" *)wire[31:0] w_currentPc_32;
 (* dont_touch="true" *)wire [31:0] w_oprand1_32;
 (* dont_touch="true" *)wire [31:0] w_oprand2_32;
 (* dont_touch="true" *)wire [31:0] w_oprnad3_32;
 (* dont_touch="true" *)wire [2:0] w_shiftType_3;
 (* dont_touch="true" *)wire w_notFlag_1;
 (* dont_touch="true" *)wire w_XTFlag_1;
 (* dont_touch="true" *)wire[1:0] w_addandShiftCarryIn_2;
 (* dont_touch="true" *)wire[8:0] w_operationTypeCode_9;
 (* dont_touch="true" *)wire [7:0] w_pathCode_8;
assign w_writeBackIdentifyData_15= {w_msr_1,w_bfi_1,w_bfc_1,w_sbfx_1,w_ubfx_1,w_msbit_5,w_lsbit_5};
assign w_memoryIdentifyData_23 = {w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1, w_writeRd_1,w_isMultiLS_1,w_registerList_16};
assign w_currentPc_32=w_pc_32;
assign w_oprand1_32 = w_op1_32;
assign w_oprand2_32 = w_op2_32;
assign w_oprnad3_32 = w_op3_32; 
assign w_shiftType_3 = w_shift_3;
assign w_notFlag_1 = w_opNot_1;
assign w_XTFlag_1 = w_isXt_1;
assign w_addandShiftCarryIn_2 = {w_addtype1_3[2],w_c_1};
assign w_operationTypeCode_9 = {w_addtype1_3[1:0],w_shiftNum_1,w_shiftS_1,w_shiftC_1,w_revType_2,w_satqS_1,w_mulDivS_1};
assign w_pathCode_8 = w_insPath_8;
// assign {w_msr_1,w_bfi_1,w_bfc_1,w_sbfx_1,w_ubfx_1,w_c_1,w_msbit_5,w_lsbit_5, w_isMultiLS_1,w_n_4,w_registerList_16,
//         w_addtype1_3, w_pc_32, w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1, w_writeRd_1, w_dHi_4, w_dLo_4, 
//         w_shift_3, w_P_1, w_W_1, w_U_1, w_S_1, w_grfFlag_1, w_opNot_1, w_isXt_1, w_shiftC_1, w_shiftS_1, w_shiftNum_1,
//         w_revType_2, w_satqS_1, w_mulDivS_1, w_insPath_8, w_op3_32, w_op2_32, w_op1_32} = i_launchDataToExe_207;


//�Է����������ݰ����н������????????
wire w_executeSplitterToOp3Selector_1;
wire w_op3SelectorToExecuteSpliter_1;
wire w_executeSplitterToExeSelector_1;
wire w_exeSelectorToExecuteSplitter_1;
wire w_executeSplitterToResWaitMerge_1;
// wire w_finalWaitMergeToExecuteSplitter_1;
wire w_exeFifoToExecuteSpliter_1;
wire w_resWaitMergeToExecuteSpliter_1, w_rescSplitterToFinalWaitMerge1_1;
wire [3:0] cSplitter3_169_41_4_132b_exeData1_4;
wire [40:0] cSplitter3_169_41_4_132b_exeData2_41;
wire [131:0] cSplitter3_169_41_4_132b_exeData3_132;
 (* dont_touch="true" *)cSplitter3_169_41_4_132b_exe executeSplitter(
.i_drive(i_launchDriveToExecute_1), .i_data_169(169'b0), .o_free(o_executeFreeToLaunch_1),
.o_driveNext0(w_executeSplitterToOp3Selector_1), .i_freeNext0(w_op3SelectorToExecuteSpliter_1), .o_data0_4(cSplitter3_169_41_4_132b_exeData1_4),
.o_driveNext1(w_executeSplitterToExeSelector_1), .o_data1_41(cSplitter3_169_41_4_132b_exeData2_41), .i_freeNext1(w_exeSelectorToExecuteSplitter_1),
.o_driveNext2(w_executeSplitterToResWaitMerge_1), .o_data2_132(cSplitter3_169_41_4_132b_exeData3_132), .i_freeNext2(w_exeFifoToExecuteSpliter_1),//1/23 zwm change w_exeFifoToExecuteSpliter_1 to w_resWaitMergeToExecuteSpliter_1 
.rst(rst));


//��һ������
//11/21 zwm exchange position w_oprand2_32 and w_oprand1_32
wire[67:0] w_executeDataToExeSelctor_68;
assign w_executeDataToExeSelctor_68 = {w_oprand1_32,w_oprand2_32,w_pathCode_8[3:0]};

wire w_exeSelectorToAddMutexMerge_1;
wire w_exeSelectorToDiv_1;
wire w_exeSelectorToRev_1;
wire w_exeSelectorToAndMutexMerge_1;
wire w_exeSelectorToEorMutexMerge_1;
wire w_exeSelectorToOrMutexMerge_1;
wire w_exeSelectorToShift_1;
wire w_exeSelectorToHsb_1;
wire w_exeSelectorToAlign_1;
wire w_exeSelectorToMul_1;
wire w_exeSelectorToResMutexMerge_1;

wire w_addMutexMergeToExeSelector_1;
wire w_divToExeSelector_1;
wire w_revToExeSelector_1;
wire w_andMutexMergeToExeSelector_1;
wire w_eorMutexMergeToExeSelector_1;
wire w_orMutexMergeToExeSelector_1;
wire w_shiftToExeSelector_1;
wire w_hsbToExeSelector_1;
wire w_alignToExeSelector_1;
wire w_mulToExeSelector_1;
wire w_resMutexMergeToExeSelector_1;

wire [63:0] w_exeSelectorToAddData_64;
wire [63:0] w_exeSelectorToDivData_64;
wire [63:0] w_exeSelectorToRevData_64;
wire [63:0] w_exeSelectorToAndData_64;
wire [63:0] w_exeSelectorToEorData_64;
wire [63:0] w_exeSelectorToOrData_64;
wire [63:0] w_exeSelectorToShiftData_64;
wire [63:0] w_exeSelectorToHsbData_64;
wire [63:0] w_exeSelectorToAlignData_64;
wire [63:0] w_exeSelectorToMulData_64;
wire [63:0] w_exeSelectorToResMutexMergeData_64;

//64bits data Structure: Adjust according to the new width requirements
 (* dont_touch="true" *)cSelector11_68b_exe exeSelector(
.i_drive(w_executeSplitterToExeSelector_1), .i_data_68(w_executeDataToExeSelctor_68), .o_free(w_exeSelectorToExecuteSplitter_1),
.o_driveNext0(w_exeSelectorToAddMutexMerge_1), .i_freeNext0(w_addMutexMergeToExeSelector_1), .o_data0_64(w_exeSelectorToAddData_64),
.o_driveNext1(w_exeSelectorToDiv_1), .o_data1_64(w_exeSelectorToDivData_64), .i_freeNext1(w_divToExeSelector_1),
.o_driveNext2(w_exeSelectorToRev_1), .i_freeNext2(w_revToExeSelector_1), .o_data2_64(w_exeSelectorToRevData_64),
.o_driveNext3(w_exeSelectorToAndMutexMerge_1), .o_data3_64(w_exeSelectorToAndData_64), .i_freeNext3(w_andMutexMergeToExeSelector_1),
.o_driveNext4(w_exeSelectorToEorMutexMerge_1), .o_data4_64(w_exeSelectorToEorData_64), .i_freeNext4(w_eorMutexMergeToExeSelector_1),
.o_driveNext5(w_exeSelectorToOrMutexMerge_1), .o_data5_64(w_exeSelectorToOrData_64), .i_freeNext5(w_orMutexMergeToExeSelector_1),
.o_driveNext6(w_exeSelectorToShift_1), .o_data6_64(w_exeSelectorToShiftData_64), .i_freeNext6(w_shiftToExeSelector_1),
.o_driveNext7(w_exeSelectorToHsb_1), .o_data7_64(w_exeSelectorToHsbData_64), .i_freeNext7(w_hsbToExeSelector_1),
.o_driveNext8(w_exeSelectorToAlign_1), .o_data8_64(w_exeSelectorToAlignData_64), .i_freeNext8(w_alignToExeSelector_1),
.o_driveNext9(w_exeSelectorToMul_1), .o_data9_64(w_exeSelectorToMulData_64), .i_freeNext9(w_mulToExeSelector_1),
.o_driveNext10(w_exeSelectorToResMutexMerge_1), .o_data10_64({w_exeSelectorToResMutexMergeData_64[31:0],w_exeSelectorToResMutexMergeData_64[63:32]}), .i_freeNext10(w_resMutexMergeToExeSelector_1),
.rst(rst));
//11/29 zwm add 16u
//12/24 zwm add 8U
wire w_exeSelectorToResMutexMergeDelay_1,w_exeSelectorToResMutexMergeDelay1_1,
w_exeSelectorToResMutexMergeDelay2_1,w_exeSelectorToResMutexMergeDelay3_1,w_exeSelectorToResMutexMergeDelay4_1;
(* dont_touch="true" *)delay32U delayDriveToRes(
.inR(w_exeSelectorToResMutexMerge_1),
.outR(w_exeSelectorToResMutexMergeDelay1_1),
.rst(rst)
);

(* dont_touch="true" *)delay32U delayDriveToRes1(
.inR(w_exeSelectorToResMutexMergeDelay1_1),
.outR(w_exeSelectorToResMutexMergeDelay2_1),
.rst(rst)
);

//12/11 zwm change 16U to 64U
(* dont_touch="true" *)delay32U delayDriveToRes2(
.inR(w_exeSelectorToResMutexMergeDelay2_1),
.outR(w_exeSelectorToResMutexMergeDelay3_1),
.rst(rst)
);

(* dont_touch="true" *)delay64U delayDriveToRes3(
    .inR(w_exeSelectorToResMutexMergeDelay3_1),
    .outR(w_exeSelectorToResMutexMergeDelay4_1),
    .rst(rst)
    );
    
(* dont_touch="true" *)delay32U delayDriveToRes4(
    .inR(w_exeSelectorToResMutexMergeDelay4_1),
    .outR(w_exeSelectorToResMutexMergeDelay_1),
    .rst(rst)
    );
//op3ѡ�񲿷�
wire w_op3Flag_1;
assign w_op3Flag_1 = w_pathCode_8[7:4] == 4'b1111 ? 1'b0 : 
((w_pathCode_8[3:0]==4'b1010 || w_pathCode_8[3:0]==4'b1000) ? 1'b0 : 1'b1);
wire w_op3SelectorToOp3NormalSelector_1;
wire w_op3NormalSelectorToOp3Selector_1;
wire w_Op3SelectorSank_1;
wire [7:0] w_op3SelectorToGrfSpliterData_8;
wire w_op3SelectorToGrfSpliter_1;
wire w_grfSpliterToOp3Selector_1;
wire [31:0] w_op3SelectorToOp3NormalSelectorData_32;
wire [31:0] w_op3SeletorSankData_32;


 (* dont_touch="true" *)cSelector3_42b_exe op3Selector(
.i_drive(w_executeSplitterToOp3Selector_1), .i_data_42({w_op3Flag_1,w_grfFlag_1,w_oprnad3_32,w_dHi_4,w_dLo_4}), .o_free(w_op3SelectorToExecuteSpliter_1),
.o_driveNext0(w_op3SelectorToGrfSpliter_1), .i_freeNext0(w_grfSpliterToOp3Selector_1), .o_data0_8(w_op3SelectorToGrfSpliterData_8),
.o_driveNext1(w_op3SelectorToOp3NormalSelector_1), .o_data1_32(w_op3SelectorToOp3NormalSelectorData_32), .i_freeNext1(w_op3NormalSelectorToOp3Selector_1),
.o_driveNext2(w_Op3SelectorSank_1), .o_data2_32(w_op3SeletorSankData_32), .i_freeNext2(w_Op3SelectorSank_1),
.rst(rst));

wire w_op3SpliterToAddWaitMerge_1;
wire [35:0] w_op3SelectorToOp3NormalSelectorData_36;
assign w_op3SelectorToOp3NormalSelectorData_36 = {w_op3SelectorToOp3NormalSelectorData_32,w_pathCode_8[7:4]};
wire w_addWaitMergeToOp3Spliter_1;
wire [31:0] w_op3SpliterToAddWaitMergeData_32;
wire w_op3SpliterToAndWaitMerge_1;
wire w_andWaitMergeToOp3Spliter_1;
wire [31:0] w_op3SpliterToAndWaitMergeData_32;
wire w_op3SpliterToEorWaitMerge_1;
wire w_eorWaitMergeToOp3Spliter_1;
wire [31:0] w_op3SpliterToEorWaitMergeData_32;
wire w_op3SpliterToOrWaitMerge_1;
wire w_orWaitMergeToOp3Spliter_1;
wire [31:0] w_op3SpliterToOrWaitMergeData_32;
wire w_op3SpliterToSatQWaitMerge_1;
wire w_satQWaitMergeToOp3Spliter_1;
wire [31:0] w_op3SpliterToSatQWaitMergeData_32;

(* dont_touch="true" *)cSelector5_36b_exe op3NormalSelector(
    .i_drive(w_op3SelectorToOp3NormalSelector_1),
    .i_data_36(w_op3SelectorToOp3NormalSelectorData_36),
    .o_free(w_op3NormalSelectorToOp3Selector_1),
    .o_driveNext0(w_op3SpliterToAddWaitMerge_1),
    .i_freeNext0(w_addWaitMergeToOp3Spliter_1),
    .o_data0_32(w_op3SpliterToAddWaitMergeData_32),
    .o_driveNext1(w_op3SpliterToAndWaitMerge_1),
    .o_data1_32(w_op3SpliterToAndWaitMergeData_32),
    .i_freeNext1(w_andWaitMergeToOp3Spliter_1),
    .o_driveNext2(w_op3SpliterToEorWaitMerge_1),
    .o_data2_32(w_op3SpliterToEorWaitMergeData_32),
    .i_freeNext2(w_eorWaitMergeToOp3Spliter_1),
    .o_driveNext3(w_op3SpliterToOrWaitMerge_1),
    .o_data3_32(w_op3SpliterToOrWaitMergeData_32),
    .i_freeNext3(w_orWaitMergeToOp3Spliter_1),
    .o_driveNext4(w_op3SpliterToSatQWaitMerge_1),
    .o_data4_32(w_op3SpliterToSatQWaitMergeData_32),
    .i_freeNext4(w_satQWaitMergeToOp3Spliter_1),
    .rst(rst)
);

//��������
wire [31:0] w_divOprand1_32;
wire [31:0] w_divOprand2_32;
wire w_divSymbolFlag_1;
wire [31:0] w_divResult_32;
assign w_divOprand1_32 = w_exeSelectorToDivData_64[63:32];
assign w_divOprand2_32 = w_exeSelectorToDivData_64[31:0];
assign w_divSymbolFlag_1 =w_operationTypeCode_9[0] ;

 (* dont_touch="true" *)div divider(
.oprand1(w_divOprand1_32),
.oprand2(w_divOprand2_32),
.symbolFlag(w_divSymbolFlag_1),
.result(w_divResult_32),
.rst(rst)
);

wire w_exeSelectorToDivFifo1_1;
wire w_exeSelectorToDivFifo2_1;
wire w_exeSelectorToDivFifo3_1;
wire w_exeSelectorToDivFifo4_1;
wire w_exeSelectorToDivFifo5_1;
wire w_exeSelectorToDivFifo6_1;
wire w_exeSelectorToDivFifo7_1;
wire w_exeSelectorToDivFifo8_1;
wire w_exeSelectorToDivFifo_1;
wire [31:0] w_divToResMutexMergeData_32;
wire w_divFifoToResMutexMerge_1;
wire w_resMutexMergeToDivFifo_1;

 (* dont_touch="true" *)delay64U delayDriveToDivFifo1(
    .inR(w_exeSelectorToDiv_1),
    .outR(w_exeSelectorToDivFifo1_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay64U delayDriveToDivFifo2(
    .inR(w_exeSelectorToDivFifo1_1),
    .outR(w_exeSelectorToDivFifo2_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay64U delayDriveToDivFifo3(
    .inR(w_exeSelectorToDivFifo2_1),
    .outR(w_exeSelectorToDivFifo3_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay64U delayDriveToDivFifo4(
    .inR(w_exeSelectorToDivFifo3_1),
    .outR(w_exeSelectorToDivFifo4_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay32U delayDriveToDivFifo5(
    .inR(w_exeSelectorToDivFifo4_1),
    .outR(w_exeSelectorToDivFifo5_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay32U delayDriveToDivFifo6(
    .inR(w_exeSelectorToDivFifo5_1),
    .outR(w_exeSelectorToDivFifo6_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay32U delayDriveToDivFifo7(
    .inR(w_exeSelectorToDivFifo6_1),
    .outR(w_exeSelectorToDivFifo7_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay32U delayDriveToDivFifo8(
    .inR(w_exeSelectorToDivFifo7_1),
    .outR(w_exeSelectorToDivFifo8_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay32U delayDriveToDivFifo9(
    .inR(w_exeSelectorToDivFifo8_1),
    .outR(w_exeSelectorToDivFifo_1),
    .rst(rst)
);


//???��Ҫȷ�Ϻ���ģ����Ҫ�����ݰ�
 (* dont_touch="true" *)cFifo1_32b_exe divFifo(
.i_drive(w_exeSelectorToDivFifo_1), .i_data_32(w_divResult_32), .o_free(w_divToExeSelector_1),.rst(rst),
.o_driveNext(w_divFifoToResMutexMerge_1), .o_data_32(w_divToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToDivFifo_1)
);


//�ӷ�����
wire w_hsbFifoToAddMutexMerge_1;
wire w_alignFifoToAddMutexMerge_1;
wire w_mulWaitMergeToAddMutexMerge_1;
wire w_shiftWaitMergeToAddMutexMerge_1;
wire w_addMutexMergeToShiftWaitMerge_1;
wire w_addMutexMergeToHsbFifo_1;
wire w_addMutexMergeToAlignFifo_1;
wire w_addMutexMergeToMulWaitMerge_1;
wire [63:0] w_shiftWaitMergeToAddMutexMergeData_64;
wire [31:0] w_hsbToAddMutexMergeData_32;
wire [31:0] w_alignToAddMutexMergeData_32;
wire [127:0] w_mulWaitMergeToAddMutexMergeData_128;
wire [127:0] w_addMutexMergeToAddData_128;
wire w_addMutexMergeToAdd_1;
wire w_addToAddMutexMerge_1;
//��Ҫȷ�Ϻ���ģ����Ҫ�����ݰ�
//188bits data structure:{w_currentPc_32,w_oprand1_64,w_oprand2_64,w_dHi_4,w_dLo_4,w_shiftType_3,w_P_1,w_U_1,w_W_1,w_S_1,w_notFlag_1,w_XTFlag_1,w_adderType_2,w_operationTypeCode_9}(not shifted)
//188bits data structure:{w_currentPc_32,w_oprand1_64,w_oprand2_64,w_dHi_4,w_dLo_4,w_shiftType_3,w_P_1,w_U_1,w_W_1,w_S_1,w_notFlag_1,w_shiftCarryOut_1,w_adderType_2,w_operationTypeCode_9}(shifted)
//124bits data Structure:{w_currentPc_32,w_oprand1_32,w_oprand2_32,w_dHi_4,w_dLo_4,w_shiftType_3,w_P_1,w_U_1,w_W_1,w_S_1,w_notFlag_1,w_XTFlag_1,w_adderType_2,w_operationTypeCode_9}(not shifted)
//124bits data Structure:{w_currentPc_32,w_oprand1_32,w_oprand2_32,w_dHi_4,w_dLo_4,w_shiftType_3,w_P_1,w_U_1,w_W_1,w_S_1,w_notFlag_1,w_shiftCarryOut_1,w_adderType_2,w_operationTypeCode_9}(shifted)
 (* dont_touch="true" *)cMutexMerge5_128b_exe addMutexMerge(
.i_drive0(w_exeSelectorToAddMutexMerge_1), .i_data0_64(w_exeSelectorToAddData_64), .o_free0(w_addMutexMergeToExeSelector_1),
.i_drive1(w_shiftWaitMergeToAddMutexMerge_1), .i_data1_64(w_shiftWaitMergeToAddMutexMergeData_64), .o_free1(w_addMutexMergeToShiftWaitMerge_1),
.i_drive2(w_hsbFifoToAddMutexMerge_1), .i_data2_64({w_hsbToAddMutexMergeData_32,w_oprand2_32}), .o_free2(w_addMutexMergeToHsbFifo_1),
.i_drive3(w_alignFifoToAddMutexMerge_1), .i_data3_64({w_alignToAddMutexMergeData_32,w_oprand2_32}), .o_free3(w_addMutexMergeToAlignFifo_1),
.i_drive4(w_mulWaitMergeToAddMutexMerge_1), .i_data4_128(w_mulWaitMergeToAddMutexMergeData_128), .o_free4(w_addMutexMergeToMulWaitMerge_1),
.i_freeNext(w_addToAddMutexMerge_1), .o_driveNext(w_addMutexMergeToAdd_1), .o_data_128(w_addMutexMergeToAddData_128),
.rst(rst)
);


// wire w_addMutexMergeToAddFifoDelay_1;
// reg [63:0] r_oprand1_64;
// reg [63:0] r_oprand2_64;
// reg [1:0] r_adderType_2;
// reg r_carryInType_1;
// reg r_addSymbolFlag_1;

//  (* dont_touch="true" *)delay2U delayDriveToAdder(
//     .inR(w_addMutexMergeToAdd_1),
//     .outR(w_addMutexMergeToAddFifoDelay_1),
//     .rst(rst)
// );

// always@(posedge w_addMutexMergeToAddFifoDelay_1 or negedge rst)begin
// if(!rst)begin
//     r_oprand1_64 = 64'b0;
//     r_oprand2_64 = 64'b0;
//     r_adderType_2 = 2'b0;
//     r_carryInType_1 = 1'b0;
//     r_addSymbolFlag_1 = 1'b0;
// end else begin
//     r_oprand1_64 = w_addMutexMergeToAddData_128[127:64];
//     r_oprand2_64 = w_addMutexMergeToAddData_128[63:0];
//     r_adderType_2 = w_operationTypeCode_9[8:7];
//     r_carryInType_1 = w_addandShiftCarryIn_2[1];
//     r_addSymbolFlag_1 = w_operationTypeCode_9[0];
// end
// end
wire[63:0] w_addResult_64;
wire w_adderCarryout_1;
wire w_adderOverFlow_1;

 (* dont_touch="true" *)adder adder(
    .i_oprand1_64(w_addMutexMergeToAddData_128[127:64]),.i_oprand2_64( w_addMutexMergeToAddData_128[63:0]),.i_adderType_2( w_operationTypeCode_9[8:7]),
    .i_carryInType_1(w_addandShiftCarryIn_2[1]),.i_addSymbolFlag_1(w_operationTypeCode_9[0]),.o_adderResult_64(w_addResult_64),.o_adderCarryOut_1(w_adderCarryout_1),.o_adderOverFlow_1(w_adderOverFlow_1),.rst(rst)
);

//12/17 zwm add delay6U
wire w_addMutexMergeToAddFifo_1;
wire w_addMutexMergeToAddFifo1_1;
wire w_addMutexMergeToAddFifoDelay1_1;
// wire w_addMutexMergeToAddFifoDelay2_1;
// wire w_addMutexMergeToAddFifoDelay3_1;
 (* dont_touch="true" *)delay6U delayDriveToAddFifo0(
    .inR(w_addMutexMergeToAdd_1),
    .outR(w_addMutexMergeToAddFifoDelay1_1),
    .rst(rst)
);



 (* dont_touch="true" *)delay16U delayDriveToAddFifo1(
    .inR(w_addMutexMergeToAddFifoDelay1_1),
    .outR(w_addMutexMergeToAddFifo1_1),
    .rst(rst)
);

 (* dont_touch="true" *)delay8U delayDriveToAddFifo2(
    .inR(w_addMutexMergeToAddFifo1_1),
    .outR(w_addMutexMergeToAddFifo_1),
    .rst(rst)
);


//  (* dont_touch="true" *)delay64U delayDriveToAddFifo5(
//     .inR(w_addMutexMergeToAddFifoDelay3_1),
//     .outR(w_addMutexMergeToAddFifo_1),
//     .rst(rst)
// );

wire[63:0] w_addFifoToResMutexMergeData_64;
wire w_addFifoToResMutexMerge_1;
wire w_resMutexMergeToAddFifo_1;
//12/1 zwm carryout and overflow also need to keep 
wire w_keepAdderCarryOut_1,w_keepAdderOverFlow_1;
 (* dont_touch="true" *)cFifo1_66b_exe addFifo(
.i_drive(w_addMutexMergeToAddFifo_1), .i_data_66({w_addResult_64,w_adderCarryout_1,w_adderOverFlow_1}), .o_free(w_addToAddMutexMerge_1),.rst(rst),
.o_driveNext(w_addFifoToResMutexMerge_1), .o_data_66({w_addFifoToResMutexMergeData_64,w_keepAdderCarryOut_1,w_keepAdderOverFlow_1}), .i_freeNext(w_resMutexMergeToAddFifo_1)
);

//��ת����
//???��ȷ������ģ����Ҫ������
wire [31:0] w_revResult_32;


 (* dont_touch="true" *)reverse reverse(
    .oprand(w_exeSelectorToRevData_64[63:32]),.reverseType(w_operationTypeCode_9[3:2]),.result(w_revResult_32),.rst(rst)
);
wire w_exeSelectorToRevFifo_1;

 (* dont_touch="true" *)delay6U delayDriveToRevFifo(
    .inR(w_exeSelectorToRev_1),
    .outR(w_exeSelectorToRevFifo_1),
    .rst(rst)
);

wire [31:0] w_revFifoToResMutexMergeData_32;
// wire [119:0] w_revToRevFifoData_120;
wire w_revFifoToResMutexMerge_1;
wire w_resMutexMergeToRevFifo_1;
// assign w_revToRevFifoData_120 = {w_exeSelectorToDivData_80[123:92],32'b0,w_revResult_32,w_exeSelectorToDivData_80[27:20],1'b0,1'b0,1'b0,w_exeSelectorToDivData_80[19:16],w_exeSelectorToDivData_80[8:0]};
 (* dont_touch="true" *)cFifo1_32b_exe revFifo(
.i_drive(w_exeSelectorToRevFifo_1), .i_data_32(w_revResult_32), .o_free(w_revToExeSelector_1),.rst(rst),
.o_driveNext(w_revFifoToResMutexMerge_1), .o_data_32(w_revFifoToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToRevFifo_1)
);

//������
wire w_shiftWaitMergeToAndMutexMerge_1; 
wire w_andMutexMergeToShiftWaitMerge_1;
wire [63:0] w_shiftWaitMergeToAndMutexMergeData_64;
wire w_andMutexMergeToAnd_1;
wire w_andToAndMutexMerge_1;
wire [63:0] w_andMutexMergeToAndData_64;


 (* dont_touch="true" *)cMutexMerge2_64b_exe andMutexMerge(
    .i_drive0(w_exeSelectorToAndMutexMerge_1), .i_data0_64(w_exeSelectorToAndData_64), .o_free0(w_andMutexMergeToExeSelector_1),
    .i_drive1(w_shiftWaitMergeToAndMutexMerge_1), .i_data1_64(w_shiftWaitMergeToAndMutexMergeData_64), .o_free1(w_andMutexMergeToShiftWaitMerge_1),
    .i_freeNext(w_andToAndMutexMerge_1), .o_driveNext(w_andMutexMergeToAnd_1), .o_data_64(w_andMutexMergeToAndData_64),
    .rst(rst)
);

wire [31:0] w_andOprand1_32;
wire [31:0] w_andOprand2_32;
wire [31:0] w_andResult_32;
assign w_andOprand1_32 = w_andMutexMergeToAndData_64[63:32];
assign w_andOprand2_32 = w_andMutexMergeToAndData_64[31:0];

 (* dont_touch="true" *)ander ander(
    .oprand1(w_andOprand1_32),.oprand2(w_andOprand2_32),.result(w_andResult_32),.rst(rst)
);
wire w_andMutexMergeToAndFifo_1;

 (* dont_touch="true" *)delay6U delayDriveToAndFifo(
    .inR(w_andMutexMergeToAnd_1),
    .outR(w_andMutexMergeToAndFifo_1),
    .rst(rst)
);
//???��ȷ������ģ����Ҫ������
// wire [119:0] w_andToAndFifoData_120;
wire [31:0] w_andFifoToResMutexMergeData_32;
wire w_andFifoToResMutexMerge_1;
wire w_resMutexMergeToAndFifo_1;
// assign w_andToAndFifoData_120 = {w_exeSelectorToDivData_80[123:92],32'b0,w_andResult_32,w_exeSelectorToDivData_80[27:20],1'b0,1'b0,w_exeSelectorToDivData_80[11],w_exeSelectorToDivData_80[19:16],w_exeSelectorToDivData_80[8:0]};
 (* dont_touch="true" *)cFifo1_32b_exe andFifo(
.i_drive(w_andMutexMergeToAndFifo_1), .i_data_32(w_andResult_32), .o_free(w_andToAndMutexMerge_1),.rst(rst),
.o_driveNext(w_andFifoToResMutexMerge_1), .o_data_32(w_andFifoToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToAndFifo_1)
);


//�������????????
wire w_shiftWaitMergeToEorMutexMerge_1; 
wire w_eorMutexMergeToShiftWaitMerge_1;
wire [63:0] w_shiftWaitMergeToEorMutexMergeData_64;
wire w_eorMutexMergeToEor_1;
wire w_eorToEorMutexMerge_1;
wire [63:0] w_eorMutexMergeToEorData_64;


 (* dont_touch="true" *)cMutexMerge2_64b_exe eorMutexMerge(
    .i_drive0(w_exeSelectorToEorMutexMerge_1), .i_data0_64(w_exeSelectorToEorData_64), .o_free0(w_eorMutexMergeToExeSelector_1),
    .i_drive1(w_shiftWaitMergeToEorMutexMerge_1), .i_data1_64(w_shiftWaitMergeToEorMutexMergeData_64), .o_free1(w_eorMutexMergeToShiftWaitMerge_1),
    .i_freeNext(w_eorToEorMutexMerge_1), .o_driveNext(w_eorMutexMergeToEor_1), .o_data_64(w_eorMutexMergeToEorData_64),
    .rst(rst)
);

wire [31:0] w_eorOprand1_32;
wire [31:0] w_eorOprand2_32;
wire [31:0] w_eorResult_32;
assign w_eorOprand1_32 = w_eorMutexMergeToEorData_64[63:32];
assign w_eorOprand2_32 = w_eorMutexMergeToEorData_64[31:0];
eor eor(
    .oprand1(w_eorOprand1_32),.oprand2(w_eorOprand2_32),.result(w_eorResult_32),.rst(rst)
);
wire w_eorMutexMergeToEorFifo_1;

 (* dont_touch="true" *)delay6U delayDriveToEorFifo(
    .inR(w_eorMutexMergeToEor_1),
    .outR(w_eorMutexMergeToEorFifo_1),
    .rst(rst)
);
//???��ȷ������ģ����Ҫ������
wire [31:0] w_eorFifoToResMutexMergeData_32;
wire w_eorFifoToResMutexMerge_1;
wire w_resMutexMergeToEorFifo_1;
// assign w_eorToEorFifoData_120 = {w_exeSelectorToDivData_80[123:92],32'b0,w_eorResult_32,w_exeSelectorToDivData_80[27:20],1'b0,1'b0,w_exeSelectorToDivData_80[11],w_exeSelectorToDivData_80[19:16],w_exeSelectorToDivData_80[8:0]};

 (* dont_touch="true" *)cFifo1_32b_exe eorFifo(
.i_drive(w_eorMutexMergeToEorFifo_1), .i_data_32(w_eorResult_32), .o_free(w_eorToEorMutexMerge_1),.rst(rst),
.o_driveNext(w_eorFifoToResMutexMerge_1), .o_data_32(w_eorFifoToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToEorFifo_1)
);

//������
wire w_shiftWaitMergeToOrMutexMerge_1; 
wire w_orMutexMergeToShiftWaitMerge_1;
wire [63:0] w_shiftWaitMergeToOrMutexMergeData_64;
wire w_orMutexMergeToOr_1;
wire w_orToOrMutexMerge_1;
wire [63:0] w_orMutexMergeToOrData_64;


 (* dont_touch="true" *)cMutexMerge2_64b_exe orMutexMerge(
    .i_drive0(w_exeSelectorToOrMutexMerge_1), .i_data0_64(w_exeSelectorToOrData_64), .o_free0(w_orMutexMergeToExeSelector_1),
    .i_drive1(w_shiftWaitMergeToOrMutexMerge_1), .i_data1_64(w_shiftWaitMergeToOrMutexMergeData_64), .o_free1(w_orMutexMergeToShiftWaitMerge_1),
    .i_freeNext(w_orToOrMutexMerge_1), .o_driveNext(w_orMutexMergeToOr_1), .o_data_64(w_orMutexMergeToOrData_64),
    .rst(rst)
);

wire [31:0] w_orOprand1_32;
wire [31:0] w_orOprand2_32;
wire [31:0] w_orResult_32;
assign w_orOprand1_32 = w_orMutexMergeToOrData_64[63:32];
assign w_orOprand2_32 = w_orMutexMergeToOrData_64[31:0];

 (* dont_touch="true" *)orrer orrer(
    .oprand1(w_orOprand1_32),.oprand2(w_orOprand2_32),.result(w_orResult_32),.rst(rst)
);
wire w_orMutexMergeToOrFifo_1;

 (* dont_touch="true" *)delay6U delayDriveToOrFifo(
    .inR(w_orMutexMergeToOr_1),
    .outR(w_orMutexMergeToOrFifo_1),
    .rst(rst)
);
//???��ȷ������ģ����Ҫ������
wire [31:0] w_orFifoToResMutexMergeData_32;
wire w_orFifoToResMutexMerge_1;
wire w_resMutexMergeToOrFifo_1;
// assign w_orToOrFifoData_120 = {w_exeSelectorToDivData_80[123:92],32'b0,w_orResult_32,w_exeSelectorToDivData_80[27:20],1'b0,1'b0,w_exeSelectorToDivData_80[11],w_exeSelectorToDivData_80[19:16],w_exeSelectorToDivData_80[8:0]};

 (* dont_touch="true" *)cFifo1_32b_exe orFifo(
.i_drive(w_orMutexMergeToOrFifo_1), .i_data_32(w_orResult_32), .o_free(w_orToOrMutexMerge_1),.rst(rst),
.o_driveNext(w_orFifoToResMutexMerge_1), .o_data_32(w_orFifoToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToOrFifo_1)
);

//��λ����
wire w_exeSelectorToShiftFifo_1;
wire w_exeSelectorToShiftFifo1_1;
wire w_exeSelectorToShiftFifo2_1;

 (* dont_touch="true" *)delay8U delayDriveToShiftFifo1(
    .inR(w_exeSelectorToShift_1),
    .outR(w_exeSelectorToShiftFifo1_1),
    .rst(rst)
);
 (* dont_touch="true" *)delay8U delayDriveToShiftFifo2(
    .inR(w_exeSelectorToShiftFifo1_1),
    .outR(w_exeSelectorToShiftFifo2_1),
    .rst(rst)
);

 (* dont_touch="true" *)delay8U delayDriveToShiftFifo3(
    .inR(w_exeSelectorToShiftFifo2_1),
    .outR(w_exeSelectorToShiftFifo_1),
    .rst(rst)
);

//???��ȷ������ģ����Ҫ������
//119bits data structure:{w_currentPc_32,w_result_32,w_oprand2_32,w_dHi_4,w_dLo_4,w_P_1,w_U_1,w_W_1,w_S_1,w_carryOut_1,w_XTFlag_1,w_shiftOpcode_9}
wire [31:0] w_shiftResult_32;
wire w_shiftCarryOut_1;

 (* dont_touch="true" *)shifter shifter(
.oprand(w_exeSelectorToShiftData_64[63:32]),.i_shiftNumber_8(w_exeSelectorToShiftData_64[7:0]),.i_shiftType_3(w_shiftType_3),.i_carryIn_1(w_addandShiftCarryIn_2[0]),
.i_xtFlag_1(w_XTFlag_1),.i_notFlag_1(w_notFlag_1),.i_shiftOpcode_3(w_operationTypeCode_9[6:4]),.result(w_shiftResult_32),.o_carryOut_1(w_shiftCarryOut_1),.rst(rst)
);

wire [31:0] w_shiftFifoToSecondExeSelectorData_32;
wire w_shiftFifoToSecondExeSelector_1;
wire w_secondExeSelectorToShiftFifo_1;
//12/1 zwm need keep shiftcarryout
wire w_keepShiftCarryOut_1;
 (* dont_touch="true" *)cFifo1_33b_exe shiftFifo(
.i_drive(w_exeSelectorToShiftFifo_1), .i_data_33({w_shiftResult_32,w_shiftCarryOut_1}), .o_free(w_shiftToExeSelector_1),.rst(rst),
.o_driveNext(w_shiftFifoToSecondExeSelector_1), .o_data_33({w_shiftFifoToSecondExeSelectorData_32,w_keepShiftCarryOut_1}), .i_freeNext(w_secondExeSelectorToShiftFifo_1)
);


//�ڶ�������
wire [35:0] w_shiftFifoToSecondExeSelectorBundleData_36;
assign w_shiftFifoToSecondExeSelectorBundleData_36 = {w_shiftFifoToSecondExeSelectorData_32,w_pathCode_8[7:4]};
wire w_secondExeSelectorToResMutexMerge_1;
wire [31:0] w_secondExeSelectorToResMutexMergeData_32;
wire w_resMutexMergeToSecondExeSelector_1;

wire w_secondExeSelectorToSatQWaitMerge_1;
wire [31:0] w_secondExeSelectorToSatQWaitMergeData_32;
wire w_satQWaitMergeToSecondExeSelector_1;

wire w_secondExeSelectorToOrWaitMerge_1;
wire [31:0] w_secondExeSelectorToOrWaitMergeData_32;
wire w_orWaitMergeToSecondExeSelector_1;

wire w_secondExeSelectorToEorWaitMerge_1;
wire [31:0] w_secondExeSelectorToEorWaitMergeData_32;
wire w_eorWaitMergeToSecondExeSelector_1;

wire w_secondExeSelectorToAndWaitMerge_1;
wire [31:0] w_secondExeSelectorToAndWaitMergeData_32;
wire w_andWaitMergeToSecondExeSelector_1;

wire w_secondExeSelectorToAddWaitMerge_1;
wire [31:0] w_secondExeSelectorToAddWaitMergeData_32;
wire w_addWaitMergeToSecondExeSelector_1;


 (* dont_touch="true" *)cSelector6_36b_exe secondExeSelector(
    .i_drive(w_shiftFifoToSecondExeSelector_1),
    .i_data_36(w_shiftFifoToSecondExeSelectorBundleData_36),
    .o_free(w_secondExeSelectorToShiftFifo_1),
    .o_driveNext0(w_secondExeSelectorToResMutexMerge_1),
    .i_freeNext0(w_resMutexMergeToSecondExeSelector_1),
    .o_data0_32(w_secondExeSelectorToResMutexMergeData_32),
    .o_driveNext1(w_secondExeSelectorToSatQWaitMerge_1),
    .o_data1_32(w_secondExeSelectorToSatQWaitMergeData_32),
    .i_freeNext1(w_satQWaitMergeToSecondExeSelector_1),
    .o_driveNext2(w_secondExeSelectorToOrWaitMerge_1),
    .o_data2_32(w_secondExeSelectorToOrWaitMergeData_32),
    .i_freeNext2(w_orWaitMergeToSecondExeSelector_1),
    .o_driveNext3(w_secondExeSelectorToEorWaitMerge_1),
    .o_data3_32(w_secondExeSelectorToEorWaitMergeData_32),
    .i_freeNext3(w_eorWaitMergeToSecondExeSelector_1),
    .o_driveNext4(w_secondExeSelectorToAndWaitMerge_1),
    .o_data4_32(w_secondExeSelectorToAndWaitMergeData_32),
    .i_freeNext4(w_andWaitMergeToSecondExeSelector_1),
    .o_driveNext5(w_secondExeSelectorToAddWaitMerge_1),
    .o_data5_32(w_secondExeSelectorToAddWaitMergeData_32),
    .i_freeNext5(w_addWaitMergeToSecondExeSelector_1),
    .rst(rst)
);


wire w_satQWaitMergeToSatQFifo_1;
wire w_satQFifoToSatQWaitMerge_1;
wire [63:0] w_satQWaitMergeToSatQData_64;
wire w_satQWaitMergeToSatQ_1;

 (* dont_touch="true" *)cWaitMerge2_64b_exe SatQWaitMerge(
.i_drive0(w_secondExeSelectorToSatQWaitMerge_1),.i_data0_32(w_secondExeSelectorToSatQWaitMergeData_32),.o_free0(w_satQWaitMergeToSecondExeSelector_1),
.i_drive1(w_op3SpliterToSatQWaitMerge_1),.i_data1_32(w_op3SpliterToSatQWaitMergeData_32),.o_free1(w_satQWaitMergeToOp3Spliter_1),.rst(rst),
.o_driveNext(w_satQWaitMergeToSatQ_1),.o_data_64(w_satQWaitMergeToSatQData_64),.i_freeNext(w_satQFifoToSatQWaitMerge_1)
);
//��������

 (* dont_touch="true" *)delay16U delayDriveToSatQFifo(
    .inR(w_satQWaitMergeToSatQ_1),
    .outR(w_satQWaitMergeToSatQFifo_1),
    .rst(rst)
);
wire [31:0] w_satQFifoToResMutexMergeData_32;
wire [31:0] w_satQResult_32;
wire w_sat_1;

 (* dont_touch="true" *)satQ satQ(
    .i_oprand1_32(w_satQWaitMergeToSatQData_64[63:32]),.i_oprand2_32(w_satQWaitMergeToSatQData_64[31:0]),.i_satQSymbolFlag_1(w_operationTypeCode_9[1]),.o_saQResult_32(w_satQResult_32),.sat(w_sat_1),.rst(rst)
);
wire w_satQFifoToResMutexMerge_1;
wire w_resMutexMergeToSatQFifo_1;

 (* dont_touch="true" *)cFifo1_32b_exe satQFifo(
.i_drive(w_satQWaitMergeToSatQFifo_1), .i_data_32(w_satQResult_32), .o_free(w_satQFifoToSatQWaitMerge_1),.rst(rst),
.o_driveNext(w_satQFifoToResMutexMerge_1), .o_data_32(w_satQFifoToResMutexMergeData_32), .i_freeNext(w_resMutexMergeToSatQFifo_1)
);



 (* dont_touch="true" *)cWaitMerge2_64b_exe OrWaitMerge(
.i_drive0(w_secondExeSelectorToOrWaitMerge_1),.i_data0_32(w_secondExeSelectorToOrWaitMergeData_32),.o_free0(w_orWaitMergeToSecondExeSelector_1),
.i_drive1(w_op3SpliterToOrWaitMerge_1),.i_data1_32(w_op3SpliterToOrWaitMergeData_32),.o_free1(w_orWaitMergeToOp3Spliter_1),.rst(rst),
.o_driveNext(w_shiftWaitMergeToOrMutexMerge_1),.o_data_64(w_shiftWaitMergeToOrMutexMergeData_64),.i_freeNext (w_orMutexMergeToShiftWaitMerge_1)  
);



 (* dont_touch="true" *)cWaitMerge2_64b_exe EorWaitMerge(
.i_drive0(w_secondExeSelectorToEorWaitMerge_1),.i_data0_32(w_secondExeSelectorToEorWaitMergeData_32),.o_free0(w_eorWaitMergeToSecondExeSelector_1),
.i_drive1(w_op3SpliterToEorWaitMerge_1),.i_data1_32(w_op3SpliterToEorWaitMergeData_32),.o_free1(w_eorWaitMergeToOp3Spliter_1),.rst(rst),
.o_driveNext(w_shiftWaitMergeToEorMutexMerge_1),.o_data_64(w_shiftWaitMergeToEorMutexMergeData_64),.i_freeNext(w_eorMutexMergeToShiftWaitMerge_1)    
);



 (* dont_touch="true" *)cWaitMerge2_64b_exe AndWaitMerge(
.i_drive0(w_secondExeSelectorToAndWaitMerge_1),.i_data0_32(w_secondExeSelectorToAndWaitMergeData_32),.o_free0(w_andWaitMergeToSecondExeSelector_1),
.i_drive1(w_op3SpliterToAndWaitMerge_1),.i_data1_32(w_op3SpliterToAndWaitMergeData_32),.o_free1(w_andWaitMergeToOp3Spliter_1),.rst(rst),
.o_driveNext(w_shiftWaitMergeToAndMutexMerge_1),.o_data_64(w_shiftWaitMergeToAndMutexMergeData_64),.i_freeNext(w_andMutexMergeToShiftWaitMerge_1)    
);

 (* dont_touch="true" *)cWaitMerge2_64b_exe AddWaitMerge(
.i_drive0(w_secondExeSelectorToAddWaitMerge_1),.i_data0_32(w_secondExeSelectorToAddWaitMergeData_32),.o_free0(w_addWaitMergeToSecondExeSelector_1),
.i_drive1(w_op3SpliterToAddWaitMerge_1),.i_data1_32(w_op3SpliterToAddWaitMergeData_32),.o_free1(w_addWaitMergeToOp3Spliter_1),.rst(rst),
.o_driveNext(w_shiftWaitMergeToAddMutexMerge_1),.o_data_64(w_shiftWaitMergeToAddMutexMergeData_64),.i_freeNext(w_addMutexMergeToShiftWaitMerge_1)    
);
//HSB����
wire w_exeSelectorToHsbFifo_1;

 (* dont_touch="true" *)delay8U delayDriveToHsbFifo(
    .inR(w_exeSelectorToHsb_1),
    .outR(w_exeSelectorToHsbFifo_1),
    .rst(rst)
);
wire [31:0] w_hsbOprand_32;
assign w_hsbOprand_32 = w_exeSelectorToHsbData_64[63:32];
wire w_hsbNotFlag_1;
assign w_hsbNotFlag_1 = w_notFlag_1;
wire [31:0] w_hsbResult_32;

 (* dont_touch="true" *)hsb hsb(
    .oprand(w_hsbOprand_32),.result(w_hsbResult_32),.notFlag(w_hsbNotFlag_1),.rst(rst)
);
// assign w_hsbToHsbFifoData_124 = {w_exeSelectorToHsbData_124[123:92],w_hsbResult_32,w_exeSelectorToHsbData_124[59:0]};

 (* dont_touch="true" *)cFifo1_32b_exe hsbFifo(
.i_drive(w_exeSelectorToHsbFifo_1), .i_data_32(w_hsbResult_32), .o_free(w_hsbToExeSelector_1),.rst(rst),
.o_driveNext(w_hsbFifoToAddMutexMerge_1), .o_data_32(w_hsbToAddMutexMergeData_32), .i_freeNext(w_addMutexMergeToHsbFifo_1)
);

//ALIGN����
wire w_exeSelectorToAlignFifo_1;
delay1U delayDriveToAlignFifo(
    .inR(w_exeSelectorToAlign_1),
    .outR(w_exeSelectorToAlignFifo_1),
    .rst(rst)
);
wire [31:0] w_alignOprand_32;
assign w_alignOprand_32 = w_exeSelectorToAlignData_64[63:32];
wire [31:0] w_alignResult_32;
wire [123:0] w_alignToAlignFifoData_124;

 (* dont_touch="true" *)align align(
    .oprand(w_alignOprand_32),.result(w_alignResult_32),.rst(rst)
);
// assign w_alignToAlignFifoData_124 = {w_exeSelectorToAlignData_124[123:92],w_alignResult_32,w_exeSelectorToAlignData_124[59:0]};

 (* dont_touch="true" *)cFifo1_32b_exe alignFifo(
.i_drive(w_exeSelectorToAlignFifo_1), .i_data_32(w_alignResult_32), .o_free(w_alignToExeSelector_1),.rst(rst),
.o_driveNext(w_alignFifoToAddMutexMerge_1), .o_data_32(w_alignToAddMutexMergeData_32), .i_freeNext(w_addMutexMergeToAlignFifo_1)
);


// �˷�����
wire w_exeSelectorToMulFifo_1;
wire w_exeSelectorToMulFifo1_1;
delay32U delayDriveToMulFifo1(
    .inR(w_exeSelectorToMul_1),
    .outR(w_exeSelectorToMulFifo1_1),
    .rst(rst)
);

delay64U delayDriveToMulFifo2(
    .inR(w_exeSelectorToMulFifo1_1),
    .outR(w_exeSelectorToMulFifo_1),
    .rst(rst)
);
wire[123:0] w_mulToMulFifoData_124; 
wire [63:0] w_mulResult_64 ;

 (* dont_touch="true" *)muller muller(
   .i_oprand1_32(w_exeSelectorToMulData_64[63:32]),.i_oprand2_32(w_exeSelectorToMulData_64[31:0]),.i_notFlag_1(w_notFlag_1),.i_mulSymbolFlag_1(w_operationTypeCode_9[0]),.o_result_64(w_mulResult_64),.rst(rst)
);
wire w_mulFifoToMulSelector_1;
wire w_mulSelectorToMulFifo_1;
wire [63:0] w_mulFifoToMulSelectorData_64;

 (* dont_touch="true" *)cFifo1_64b_exe mulFifo(
.i_drive(w_exeSelectorToMulFifo_1), .i_data_64(w_mulResult_64), .o_free(w_mulToExeSelector_1),.rst(rst),
.o_driveNext(w_mulFifoToMulSelector_1), .o_data_64(w_mulFifoToMulSelectorData_64), .i_freeNext(w_mulSelectorToMulFifo_1)
);
wire [64:0] w_mulFifoToMulSelectorData_65;
assign w_mulFifoToMulSelectorData_65 = w_pathCode_8[7:4]== 4'b0000 ? {w_mulFifoToMulSelectorData_64,1'b1} : {w_mulFifoToMulSelectorData_64,1'b0};

wire w_mulSelectorToResMutexMerge_1;
wire w_resMutexMergeToMulSelector_1;
wire w_mulSelectorToMulWaitMerge_1;
wire w_mulWaitMergeToMulSelector_1;
wire [63:0] w_mulSelectorToResMutexMergeData_64;
wire [63:0] w_mulSelectorToMulWaitMergeData_64;

 (* dont_touch="true" *)cSelector2_65b_exe mulSelector(
.i_drive(w_mulFifoToMulSelector_1), .i_data_65(w_mulFifoToMulSelectorData_65), .o_free(w_mulSelectorToMulFifo_1),
.o_driveNext0(w_mulSelectorToResMutexMerge_1), .i_freeNext0(w_resMutexMergeToMulSelector_1), .o_data0_64(w_mulSelectorToResMutexMergeData_64),
.o_driveNext1(w_mulSelectorToMulWaitMerge_1), .o_data1_64(w_mulSelectorToMulWaitMergeData_64), .i_freeNext1(w_mulWaitMergeToMulSelector_1),
.rst(rst)
);
//��GRF����
// ����Լ���߼�
//12/4 zwm start to change relative model
//12/10 zwm change to w_dLo_4 and w_dHi_4

 (* dont_touch="true" *)wire [3:0] w_rs1Addr_4;
 (* dont_touch="true" *)wire [3:0] w_rs2Addr_4;
 assign w_rs1Addr_4 = w_dLo_4;
 assign w_rs2Addr_4 = w_dHi_4;

 //ִ��ֻ��lsu��������·
 (* dont_touch="true" *) wire [3:0] w_rele_4;
 (* dont_touch="true" *) wire [3:0] w_rele1_4;
 (* dont_touch="true" *) wire [3:0] w_preRdHiAddr_4;
 (* dont_touch="true" *) wire [3:0] w_preRdLoAddr_4;

// (* dont_touch="true" *) reg [3:0] r_rele_4;
(* dont_touch="true" *)wire w_op3SelectorToGrfSpliterDelay_1;
 (* dont_touch="true" *) delay6U op3SelectorToGrfSpliterDelay(
    .inR(w_op3SelectorToGrfSpliter_1),
    .outR(w_op3SelectorToGrfSpliterDelay_1),
    .rst(rst)
);
// always @(posedge w_op3SelectorToGrfSpliterDelay_1 or negedge rst) begin
//     if(!rst)begin
//         r_rele_4 = 4'b0;
//     end else begin
//         r_rele_4[0] = (w_rs1Addr_4 == w_preRdHiAddr_4 || w_rs1Addr_4 == w_preRdLoAddr_4) ? 1'b1 : 1'b0;
//         r_rele_4[1] = (!r_rele_4[0]);
//         r_rele_4[2] = (w_rs2Addr_4 == w_preRdHiAddr_4 || w_rs2Addr_4 == w_preRdLoAddr_4) ? 1'b1 : 1'b0;
//         r_rele_4[3] = (!r_rele_4[2]);
//     end
// end
// assign w_rele_4 = r_rele_4;

assign  w_rele_4[0] = (w_rs1Addr_4 == w_preRdHiAddr_4 || w_rs1Addr_4 == w_preRdLoAddr_4) ? 1'b1 : 1'b0;
assign  w_rele_4[1] = (!w_rele_4[0]);
assign  w_rele_4[2] = (w_rs2Addr_4 == w_preRdHiAddr_4 || w_rs2Addr_4 == w_preRdLoAddr_4) ? 1'b1 : 1'b0;
assign  w_rele_4[3] = (!w_rele_4[2]);



//ѡ�������߼�
wire [31:0] w_lsuR1Data_32;
wire [31:0] w_lsuR2Data_32;
assign w_lsuR1Data_32 = w_rs1Addr_4 == w_preRdHiAddr_4 ? i_lsuToExeData_64[63:32] : i_lsuToExeData_64[31:0];
assign w_lsuR2Data_32 = w_rs2Addr_4 == w_preRdHiAddr_4 ? i_lsuToExeData_64[63:32] : i_lsuToExeData_64[31:0];

wire w_grfSpliterToRele4Spliter_1;
wire rele4SpliterToGrfSpliter_1;
wire w_rele4SplitterDriveToRelo0Merge_1,w_rele4SplitterDriveToRelo1Merge_1,w_rele4SplitterDriveToRelo2Merge_1,w_rele4SplitterDriveToRelo3Merge_1;
wire w_rele0MergeFreeToRele4Splitter_1;
wire w_rele1MergeFreeToRele4Splitter_1;
wire w_rele2MergeFreeToRele4Splitter_1;
wire w_rele3MergeFreeToRele4Splitter_1;
wire w_rs1Lsu_1;
wire w_rs1Grf_1;
wire w_rs2Lsu_1;
wire w_rs2Grf_1;
wire w_grfResSplitterDriveToRelo1Merge_1;
wire w_grfResSplitterDriveToRelo3Merge_1;
wire w_rele1MergeFreeToGrfResSplitter_1;
wire w_rele3MergeFreeToGrfResSplitter_1;


 (* dont_touch="true" *) cSplitter2_12_4_8b_exe grfSplitter(.i_drive(w_op3SelectorToGrfSpliterDelay_1), .i_data_12({w_op3SelectorToGrfSpliterData_8, w_rele_4}), .o_free(w_grfSpliterToOp3Selector_1),
      .o_driveNext0(w_grfSpliterToRele4Spliter_1), .i_freeNext0(rele4SpliterToGrfSpliter_1), .o_data0_4(w_rele1_4),
      .o_driveNext1(o_executeDriveToGrf_1), .i_freeNext1(i_executeFreeFromGrf_1), .o_data1_8(o_executeToGrfData_8),
      .rst(rst));


wire w_grfSpliterToRele4SpliterDelay_1;
 (* dont_touch="true" *) delay2U grfSpliterToRele4SpliterDelay(
    .inR(w_grfSpliterToRele4Spliter_1),
    .outR(w_grfSpliterToRele4SpliterDelay_1),
    .rst(rst)
);
wire [63:0] w_rs1Grf_64;
wire [63:0] w_rs2Grf_64;
  (* dont_touch="true" *) cSplitter4_4b_exe rele4Splitter(.i_drive(w_grfSpliterToRele4SpliterDelay_1), .i_data_4(w_rele_4), .o_free(rele4SpliterToGrfSpliter_1),
      .o_driveNext0(w_rele4SplitterDriveToRelo0Merge_1), .i_freeNext0(w_rele0MergeFreeToRele4Splitter_1), .o_data0_1(w_rs1Lsu_1),
      .o_driveNext1(w_rele4SplitterDriveToRelo1Merge_1), .i_freeNext1(w_rele1MergeFreeToRele4Splitter_1), .o_data1_1(w_rs1Grf_1),
      .o_driveNext2(w_rele4SplitterDriveToRelo2Merge_1), .i_freeNext2(w_rele2MergeFreeToRele4Splitter_1), .o_data2_1(w_rs2Lsu_1),
      .o_driveNext3(w_rele4SplitterDriveToRelo3Merge_1), .i_freeNext3(w_rele3MergeFreeToRele4Splitter_1), .o_data3_1(w_rs2Grf_1),
      .rst(rst));

  (* dont_touch="true" *) cSplitter2_64b_exe grfResSplitter(.i_drive(i_grfDriveToExecute_1), .i_data_64(i_grfToExecuteData_64), .o_free(o_executeFreeToGrf_1),
      .o_driveNext0(w_grfResSplitterDriveToRelo1Merge_1), .i_freeNext0(w_rele1MergeFreeToGrfResSplitter_1), .o_data0_64(w_rs1Grf_64),
      .o_driveNext1(w_grfResSplitterDriveToRelo3Merge_1), .i_freeNext1(w_rele3MergeFreeToGrfResSplitter_1), .o_data1_64(w_rs2Grf_64),
      .rst(rst));


wire w_driveToLsuMer,w_lsuMerFree;
wire w_rele1driveToMe_1,w_rele1driveToMe1_1;
reg r_isLsuOne_1;
wire w_isLsuOne_1;

//12/10 zwm change i_launchToExe_1 to w_op3SelectorToGrfSpliter_1
  (* dont_touch="true" *) cSelector2_1b lsuSele1(.i_drive(w_op3SelectorToGrfSpliter_1), .i_data_1(!w_isLsuOne_1), .o_free(),
  .o_driveNext0(w_driveToLsuMer), .i_freeNext0(w_lsuMerFree), .o_data0_1(),
  .o_driveNext1(w_rele1driveToMe_1), .i_freeNext1(w_rele1driveToMe1_1), .o_data1_1(),
  .rst(rst));
delay4U isOneSeleDelay1(.inR(w_rele1driveToMe_1), .outR(w_rele1driveToMe1_1), .rst(rst));  


wire i_LsuDriveToExe1_1;
wire w_lsuFreeFromExecute_1;
wire w_LsuDriveToExe_1;
delay4U lsuDelay0(.inR(i_LsuDriveToExe_1), .outR(i_LsuDriveToExe1_1), .rst(rst)); 
(* dont_touch="true" *) cMutexMerge2_1b lsuMerge(.i_drive0(i_LsuDriveToExe1_1), .i_data0_1(1'b0), .o_free0(o_lsuFreeFromExecute_1),
    .i_drive1(w_driveToLsuMer), .i_data1_1(1'b0), .o_free1(w_lsuMerFree),
    .i_freeNext(w_lsuFreeFromExecute_1), .o_driveNext(w_LsuDriveToExe_1), .o_data_1(),
    .rst(rst));

wire w_rele0MergeFreeToLsu_1,w_rele2MergeFreeToLsu_1;

wire w_rele0MergeDriveToRele0Selector_1,w_rele0SelectorFreeToRele0Merge_1,w_rele1MergeDriveToRele1Selector_1,w_rele1SelectorFreeToRele1Merge_1,
w_rele2MergeDriveToRele2Selector_1,w_rele2SelectorFreeToRele2Merge_1,w_rele3MergeDriveToRele3Selector_1,w_rele3SelectorFreeToRele3Merge_1;
wire [32:0] w_rele0Data_33,w_rele1Data_33,w_rele2Data_33,w_rele3Data_33;
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_exe rele0Merge(.i_drive0(w_LsuDriveToExe_1), .i_data0_32(w_lsuR1Data_32), .o_free0(w_rele0MergeFreeToLsu_1),
      .i_drive1(w_rele4SplitterDriveToRelo0Merge_1), .i_data1_1(w_rs1Lsu_1), .o_free1(w_rele0MergeFreeToRele4Splitter_1),
      .o_driveNext(w_rele0MergeDriveToRele0Selector_1), .o_data_33(w_rele0Data_33), .i_freeNext(w_rele0SelectorFreeToRele0Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_exe rele1Merge(.i_drive0(w_grfResSplitterDriveToRelo1Merge_1), .i_data0_32(w_rs1Grf_64[31:0]), .o_free0(w_rele1MergeFreeToGrfResSplitter_1),
      .i_drive1(w_rele4SplitterDriveToRelo1Merge_1), .i_data1_1(w_rs1Grf_1), .o_free1(w_rele1MergeFreeToRele4Splitter_1),
      .o_driveNext(w_rele1MergeDriveToRele1Selector_1), .o_data_33(w_rele1Data_33), .i_freeNext(w_rele1SelectorFreeToRele1Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_exe rele2Merge(.i_drive0(w_LsuDriveToExe_1), .i_data0_32(w_lsuR2Data_32), .o_free0(w_rele2MergeFreeToLsu_1),
      .i_drive1(w_rele4SplitterDriveToRelo2Merge_1), .i_data1_1(w_rs2Lsu_1), .o_free1(w_rele2MergeFreeToRele4Splitter_1),
      .o_driveNext(w_rele2MergeDriveToRele2Selector_1), .o_data_33(w_rele2Data_33), .i_freeNext(w_rele2SelectorFreeToRele2Merge_1),
      .rst(rst));
  (* dont_touch="true" *) cWaitMerge2_32_1_33b_exe rele3Merge(.i_drive0(w_grfResSplitterDriveToRelo3Merge_1), .i_data0_32(w_rs2Grf_64[63:32]), .o_free0(w_rele3MergeFreeToGrfResSplitter_1),
      .i_drive1(w_rele4SplitterDriveToRelo3Merge_1), .i_data1_1(w_rs2Grf_1), .o_free1(w_rele3MergeFreeToRele4Splitter_1),
      .o_driveNext(w_rele3MergeDriveToRele3Selector_1), .o_data_33(w_rele3Data_33), .i_freeNext(w_rele3SelectorFreeToRele3Merge_1),
      .rst(rst));
 assign w_lsuFreeFromExecute_1 = w_rele0MergeFreeToLsu_1;

wire w_rele0SelectorDriveToRs1Merge_1,w_rs1MergeFreeToRele0Selector_1,w_rele0SelectorDriveToMe_1;
wire w_rele1SelectorDriveToRs1Merge_1,w_rele1SelectorDriveToMe_1,w_rs1MergeFreeToRele1Selector_1;
wire w_rele2SelectorDriveToRs2Merge_1,w_rele2SelectorDriveToMe_1,w_rs2MergeFreeToRele2Selector_1;
wire w_rele3SelectorDriveToRs2Merge_1,w_rele3SelectorDriveToMe_1,w_rs2MergeFreeToRele3Selector_1;
wire [31:0] w_lsuRs1Data_32;
wire [31:0] w_grfRs1Data_32;
wire [31:0] w_lsuRs2Data_32;
wire [31:0] w_grfRs2Data_32;

  (* dont_touch="true" *) cSelector2_33b_exe rele0Selector(.i_drive(w_rele0MergeDriveToRele0Selector_1), .i_data_33(w_rele0Data_33), .o_free(w_rele0SelectorFreeToRele0Merge_1),
        .o_driveNext0(w_rele0SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele0Selector_1), .o_data0_32(w_lsuRs1Data_32),
        .o_driveNext1(w_rele0SelectorDriveToMe_1), .i_freeNext1(w_rele0SelectorDriveToMe_1), .o_data1_32(),
        .rst(rst));

  (* dont_touch="true" *) cSelector2_33b_exe rele1Selector(.i_drive(w_rele1MergeDriveToRele1Selector_1), .i_data_33(w_rele1Data_33), .o_free(w_rele1SelectorFreeToRele1Merge_1),
        .o_driveNext0(w_rele1SelectorDriveToRs1Merge_1), .i_freeNext0(w_rs1MergeFreeToRele1Selector_1), .o_data0_32(w_grfRs1Data_32),
        .o_driveNext1(w_rele1SelectorDriveToMe_1), .i_freeNext1(w_rele1SelectorDriveToMe_1), .o_data1_32(),
        .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_exe rele2Selector(.i_drive(w_rele2MergeDriveToRele2Selector_1), .i_data_33(w_rele2Data_33), .o_free(w_rele2SelectorFreeToRele2Merge_1),
    .o_driveNext0(w_rele2SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele2Selector_1), .o_data0_32(w_lsuRs2Data_32),
    .o_driveNext1(w_rele2SelectorDriveToMe_1), .i_freeNext1(w_rele2SelectorDriveToMe_1), .o_data1_32(),
    .rst(rst));
  (* dont_touch="true" *) cSelector2_33b_exe rele3Selector(.i_drive(w_rele3MergeDriveToRele3Selector_1), .i_data_33(w_rele3Data_33), .o_free(w_rele3SelectorFreeToRele3Merge_1),
        .o_driveNext0(w_rele3SelectorDriveToRs2Merge_1), .i_freeNext0(w_rs2MergeFreeToRele3Selector_1), .o_data0_32(w_grfRs2Data_32),
        .o_driveNext1(w_rele3SelectorDriveToMe_1), .i_freeNext1(w_rele3SelectorDriveToMe_1), .o_data1_32(),
        .rst(rst));

wire w_regMergeFreeToRs1Merge_1,w_rs1MergeDriveToRegMerge_1,w_regMergeFreeToRs2Merge_1,w_rs2MergeDriveToRegMerge_1;
wire [31:0] w_lastRs1Data_32,w_lastRs2Data_32;


wire w_mulWaitMergeToRegMerge_1,w_regSelectorFreeToRegMerge_1;
wire [63:0] w_Rs1AndRs2Data_64;
  (* dont_touch="true" *) cMutexMerge2_32b_exe rs1Merge(.i_drive0(w_rele0SelectorDriveToRs1Merge_1), .i_data0_32(w_lsuRs1Data_32), .o_free0(w_rs1MergeFreeToRele0Selector_1),
      .i_drive1(w_rele1SelectorDriveToRs1Merge_1), .i_data1_32(w_grfRs1Data_32), .o_free1(w_rs1MergeFreeToRele1Selector_1),
      .i_freeNext(w_regMergeFreeToRs1Merge_1), .o_driveNext(w_rs1MergeDriveToRegMerge_1), .o_data_32(w_lastRs1Data_32),
      .rst(rst));

  (* dont_touch="true" *) cMutexMerge2_32b_exe rs2Merge(.i_drive0(w_rele3SelectorDriveToRs2Merge_1), .i_data0_32(w_grfRs2Data_32), .o_free0(w_rs2MergeFreeToRele3Selector_1),
                            .i_drive1(w_rele2SelectorDriveToRs2Merge_1), .i_data1_32(w_lsuRs2Data_32), .o_free1(w_rs2MergeFreeToRele2Selector_1),
                            .i_freeNext(w_regMergeFreeToRs2Merge_1), .o_driveNext(w_rs2MergeDriveToRegMerge_1), .o_data_32(w_lastRs2Data_32),
                            .rst(rst));

  (* dont_touch="true" *) cWaitMerge2_64b_exe regMerge(.i_drive0(w_rs2MergeDriveToRegMerge_1), .i_data0_32(w_lastRs2Data_32), .o_free0(w_regMergeFreeToRs2Merge_1),
      .i_drive1(w_rs1MergeDriveToRegMerge_1), .i_data1_32(w_lastRs1Data_32), .o_free1(w_regMergeFreeToRs1Merge_1),
      .i_freeNext(w_mulWaitMergeToRegMerge_1), .o_driveNext(w_regSelectorFreeToRegMerge_1), .o_data_64(w_Rs1AndRs2Data_64),
      .rst(rst));

    reg [3:0] r_preRdHiAddr_4,r_preRdLoAddr_4;
    //12/4 zwm change the fire from w_regSelectorFreeToRegMerge_1 to o_executeDriveToLsu_1
  always@(posedge o_executeDriveToLsu_1 or negedge rst)
  begin
      if(!rst) begin
      r_preRdHiAddr_4 = 4'hf;
      r_preRdLoAddr_4 = 4'hf;
      end
    else begin
        if(w_addtype1_3[1:0] == 2'b10)begin
            r_preRdHiAddr_4 = w_rs2Addr_4;
            r_preRdLoAddr_4 = w_rs1Addr_4;
        end else if(w_isLS_1) begin
            r_preRdHiAddr_4 =  4'hf;
            r_preRdLoAddr_4 =  4'hf;
        end
         else begin
            r_preRdHiAddr_4 = 4'hf;
            r_preRdLoAddr_4 = w_rs2Addr_4;
        end

      end
  end

  assign w_preRdHiAddr_4 = r_preRdHiAddr_4;
  assign w_preRdLoAddr_4 = r_preRdLoAddr_4;
//����Լ�ⲿ�ֽ���
  always @(posedge o_executeDriveToLsu_1 or negedge rst) begin
    if (!rst) begin
      r_isLsuOne_1 <= 1'b0;
    end else begin
      if(w_isMultiLS_1 | w_load_1 & w_isLS_1) begin
        r_isLsuOne_1 <= 1'b0;
      end else begin
          r_isLsuOne_1 <= 1'b1;
      end
    end
  end
assign w_isLsuOne_1 = r_isLsuOne_1;


wire [63:0] w_Rs1AndRs2Data1_64;
assign w_Rs1AndRs2Data1_64 = w_addtype1_3[1:0] == 2'b10 ? w_Rs1AndRs2Data_64 : {32'b0,w_Rs1AndRs2Data_64[31:0]};
wire w_regSelectorFreeToRegMerge1_1;
delay4U regMergeDelay1(.inR(w_regSelectorFreeToRegMerge_1), .outR(w_regSelectorFreeToRegMerge1_1), .rst(rst)); 
//12/4 zwm relative detect end



 (* dont_touch="true" *)cWaitMerge2_128b_exe mulWaitMerge(
.i_drive0(w_mulSelectorToMulWaitMerge_1),.i_data0_64(w_mulSelectorToMulWaitMergeData_64),.o_free0(w_mulWaitMergeToMulSelector_1),
.i_drive1(w_regSelectorFreeToRegMerge1_1),.i_data1_64(w_Rs1AndRs2Data1_64),.o_free1(w_mulWaitMergeToRegMerge_1),.rst(rst),
.o_driveNext(w_mulWaitMergeToAddMutexMerge_1),.o_data_128(w_mulWaitMergeToAddMutexMergeData_128),.i_freeNext(w_addMutexMergeToMulWaitMerge_1)
);

wire w_resMutexMergeToRescSplitter_1;
wire w_rescSplitterToResMutexMerge_1;
wire [63:0] w_resMutexMergeToFinalWaitMergeData_64;
//���ڼӷ�����������?����64λ��������Ҫ����64λ�Ķ����漰���ô���������Կ��Խ�R[n]��ֵ���ڸ�32λ������Ҫ�������ݵ�ѡ����
wire [63:0] w_addFifoToResMutexMergeDataTmp_64;
//12/1 zwm need a flag to select result use 64 bit or 32 bit to process w_z_1
//12/17 zwm w_rn_32 come from w_op3_32,so change all w_op1_32 to w_op3_32
//12/26 zwm only the bit operation w_rn_32 = w_op3_32
wire [31:0] w_rn_32;
wire w_all64Flag_1;
assign w_rn_32 = (|w_writeBackIdentifyData_15[13:10]) ? w_op3_32 : w_op1_32;
assign w_all64Flag_1 =  (w_pathCode_8 == 8'b0000_0010 | w_pathCode_8 == 8'b1111_0010) ? 1'b1 : 1'b0;
assign w_addFifoToResMutexMergeDataTmp_64 = w_pathCode_8 == 8'b0000_0010 ? w_addFifoToResMutexMergeData_64 : {w_rn_32,w_addFifoToResMutexMergeData_64[31:0]};
//������

 (* dont_touch="true" *)cMutexMerge10_64b_exe resMutexMerge(
    .i_drive0(w_exeSelectorToResMutexMergeDelay_1), 
    .i_data0_64(w_exeSelectorToResMutexMergeData_64), 
    .o_free0(w_resMutexMergeToExeSelector_1),

    .i_drive1(w_secondExeSelectorToResMutexMerge_1), 
    .i_data1_64({w_rn_32,w_secondExeSelectorToResMutexMergeData_32}), 
    .o_free1(w_resMutexMergeToSecondExeSelector_1),

    .i_drive2(w_satQFifoToResMutexMerge_1), 
    .i_data2_64({w_rn_32, w_satQFifoToResMutexMergeData_32}), 
    .o_free2(w_resMutexMergeToSatQFifo_1),

    .i_drive3(w_orFifoToResMutexMerge_1), 
    .i_data3_64({w_rn_32, w_orFifoToResMutexMergeData_32}), 
    .o_free3(w_resMutexMergeToOrFifo_1),

    .i_drive4(w_eorFifoToResMutexMerge_1), 
    .i_data4_64({w_rn_32, w_eorFifoToResMutexMergeData_32}), 
    .o_free4(w_resMutexMergeToEorFifo_1),

    .i_drive5(w_andFifoToResMutexMerge_1), 
    .i_data5_64({w_rn_32, w_andFifoToResMutexMergeData_32}), 
    .o_free5(w_resMutexMergeToAndFifo_1),

    .i_drive6(w_mulSelectorToResMutexMerge_1),  
    .i_data6_64(w_mulSelectorToResMutexMergeData_64),
    .o_free6(w_resMutexMergeToMulSelector_1),

    .i_drive7(w_addFifoToResMutexMerge_1), 
    .i_data7_64(w_addFifoToResMutexMergeDataTmp_64), 
    .o_free7(w_resMutexMergeToAddFifo_1),

    .i_drive8(w_revFifoToResMutexMerge_1), 
    .i_data8_64({w_rn_32, w_revFifoToResMutexMergeData_32}), 
    .o_free8(w_resMutexMergeToRevFifo_1),

    .i_drive9(w_divFifoToResMutexMerge_1), 
    .i_data9_64({w_rn_32, w_divToResMutexMergeData_32}), 
    .o_free9(w_resMutexMergeToDivFifo_1),

    .i_freeNext(w_rescSplitterToResMutexMerge_1), 
    .o_driveNext(w_resMutexMergeToRescSplitter_1), 
    .o_data_64(w_resMutexMergeToFinalWaitMergeData_64),

    .rst(rst)
);
wire w_rescSplitterToFinalWaitMerge_1;
wire finalWaitMergeToRescSplitter_1;
wire exeFifo1ToRescSplitter_1;
wire [63:0] a;
wire [63:0] b;
//�����ɵ���·
 (* dont_touch="true" *)cSplitter2_64b_exe rescSplitter(
.i_drive(w_resMutexMergeToRescSplitter_1), .i_data_64(w_resMutexMergeToFinalWaitMergeData_64), .o_free(w_rescSplitterToResMutexMerge_1),
.o_driveNext0(o_exeByPathDriveToLaunch_1), .i_freeNext0(i_executeFreeFromLaunchByPath_1), .o_data0_64(a),
.o_driveNext1(w_rescSplitterToFinalWaitMerge_1), .o_data1_64(b), .i_freeNext1(exeFifo1ToRescSplitter_1),
.rst(rst));


//�����ٴ���nzcv������
//w_sat_1,w_adderCarryout_1,w_adderOverFlow_1,w_shiftCarryOut_1
//update:10/19 
//???�����и�ASPR.Q��Ҫͨ��w_sat_1����
//12/1 zwm need a flag to select result use 64 bit or 32 bit to process w_z_1
wire [3:0] w_nzcv_4;
wire w_n_1,w_z_1,w_C_1,w_v_1;
assign w_n_1 = w_resMutexMergeToFinalWaitMergeData_64[31];
assign w_z_1 = w_all64Flag_1 == 1'b1 ? (w_resMutexMergeToFinalWaitMergeData_64 == 64'b0) :(w_resMutexMergeToFinalWaitMergeData_64[31:0] == 32'b0);
assign w_C_1 = w_keepAdderCarryOut_1 | w_keepShiftCarryOut_1;  
assign w_v_1 = w_keepAdderOverFlow_1;
assign w_nzcv_4 = {w_n_1,w_z_1,w_C_1,w_v_1};
assign o_exeToLaunchData_96= {w_nzcv_4,{28{1'b0}},w_resMutexMergeToFinalWaitMergeData_64};
//163 bits data:{w_writeBackIdentifyData_15,w_memoryIdentifyData_23,w_sat_1,w_currentPc_32,w_addCarryOut_1,w_addOverFlow_1,w_shiftCarryOut_1,w_dHi_4,w_dLo_4,w_n_4,w_P_1,w_U_1,w_W_1,w_S_1,w_operationCode_9,w_result_64}
wire w_executeSplitterToResWaitMerge1_1;
(* dont_touch="true" *)delay4U finalDelay(
.inR(w_executeSplitterToResWaitMerge_1),
.outR(w_executeSplitterToResWaitMerge1_1),
.rst(rst)
);

//11/15 zwm add exeFifo
wire w_exeFifoToResWaitMerge_1;
cFifo1 exeFifo0(.i_drive(w_executeSplitterToResWaitMerge1_1), .i_freeNext(w_resWaitMergeToExecuteSpliter_1), .rst(rst),
               .o_free(w_exeFifoToExecuteSpliter_1), .o_driveNext(w_exeFifoToResWaitMerge_1), .o_fire_1());

cFifo1 exeFifo1(.i_drive(w_rescSplitterToFinalWaitMerge_1), .i_freeNext(finalWaitMergeToRescSplitter_1), .rst(rst),
               .o_free(exeFifo1ToRescSplitter_1), .o_driveNext(w_rescSplitterToFinalWaitMerge1_1), .o_fire_1());

wire [94:0] w_exeToLsuData_95;               
reg [94:0] r_exeToLsuData_95;
always @(posedge i_launchDriveToExecute_1 or negedge rst) begin
    if(!rst)begin
        r_exeToLsuData_95 <= 95'b0;
    end else begin
        r_exeToLsuData_95 <= {w_writeBackIdentifyData_15,w_memoryIdentifyData_23,w_currentPc_32,w_dHi_4,w_dLo_4,w_n_4,w_P_1,w_W_1,w_U_1,w_S_1,w_operationTypeCode_9};
    end
end
assign w_exeToLsuData_95 = r_exeToLsuData_95;
wire w_executeDriveToLsu_1,w_executeFreeFromLsu_1;
 (* dont_touch="true" *)cWaitMerge2_163b_exe finalWaitMerge(
.i_drive0(w_rescSplitterToFinalWaitMerge1_1),.i_data0_68({w_nzcv_4,w_resMutexMergeToFinalWaitMergeData_64}),.o_free0(finalWaitMergeToRescSplitter_1),
.i_drive1(w_exeFifoToResWaitMerge_1),.i_data1_95(w_exeToLsuData_95),.o_free1(w_resWaitMergeToExecuteSpliter_1),.rst(rst),
.o_driveNext(w_executeDriveToLsu_1),.o_data_163(o_executeDataToLsu_163),.i_freeNext(w_executeFreeFromLsu_1)
);


 (* dont_touch="true" *)cSplitter2_64b_exe ExcSplitter(
.i_drive(w_executeDriveToLsu_1), .i_data_64(64'b0), .o_free(w_executeFreeFromLsu_1),
.o_driveNext0(o_executeDriveToLsu_1), .i_freeNext0(i_executeFreeFromLsu_1), .o_data0_64(),
.o_driveNext1(o_exeDriveToExcp_1), .o_data1_64(), .i_freeNext1(i_executeFreeFromExcp_1),
.rst(rst));


//�쳣����
//������
//1/3 zwm add excNum_4
wire [3:0] w_excNum_4;
wire [31:0] w_address_32;
assign w_address_32 =  w_P_1 == 1'b1 ? o_executeDataToLsu_163[31:0] : o_executeDataToLsu_163[63:32];
//1/4 zwm 
// assign w_excNum_4 = (w_isLS_1 & w_address_32 > 32'h43200) ? 4'b0110 : 4'b1111;
assign w_excNum_4 = 4'b1111;
assign o_exeToExcpData_36 = {w_pc_32,w_excNum_4};


//1/4 zwm
//need a contap 
// contTap executeTap(
//     .trig(i_launchDrive_1 | o_executeDriveToLsu_1),
//     .req(o_executeInUseFlag_1),
//     .rst(rst)
//     );
// contTap executeTap(
//     .trig(i_launchDrive_1 | i_executeFreeFromExcp_1),
//     .req(o_executeInUseFlag_1),
//     .rst(rst)
//     );
contTap executeTap(
    .trig(i_launchDriveToExecute_1 | i_executeFreeFromExcp_1),
    .req(o_executeInUseFlag_1),
    .rst(rst)
    );

endmodule