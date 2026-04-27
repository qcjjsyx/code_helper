`timescale 1ns / 1ps


module lsu(
rst,
i_exeDriveToLsu_1,i_exeToLsuData_163,o_lsuFreeToExe_1,

i_dataRoutDriveToLsu_1,i_memData_64,o_lsuFreeToDataRout_1,
o_lsuDriveToDataRout_1,o_lsuToDataRoutData_104,i_lsuFreeFromDataRout_1,

o_lsuDriveToRGrf_1,o_lsuToRGrfData_8,i_lsuFreeFromRGrf_1,
i_grfDriveToLsu_1,i_grfToLsuData_64,o_grfFreeFromLsu_1,

o_lsuDriveToExcp_1,o_exception_36,i_lsuFreeFromExcp_1,

o_lsuDriveToWriteBack_1,o_lsuToWriteBackData_103,i_lsuFreeFromWriteBack_1,
o_lsuDriveToLaunch_1,o_lsuToLaunchData_64,i_lsuFreeFromLaunch_1,

o_lsuDriveToWGrf_1,o_wGrfData_74,i_lsuFreeFromWGrf_1,
//11/4 zwm->���ַô������־�?
o_endFlag_1,
//11/6 zwm ->����һ���ô��ʹ���?
i_wen_2,
//11/8 zwm
o_multiLoadOrStoreOver,
//11/19 zwm add load over flag
o_loadEndDrive,
o_loadEndFlag,
o_lsuInUseFlag_1,
//12/24 zwm add a path to icache
o_lsuDriveToIcache_1,
i_lsuFreeFromIcache_1,
o_lsuToIcacheData_104,


i_icacheDriveToLsu_1,
i_icacheData_64,
o_lsuFreeToIcache_1
);
input rst;
//��ִ�������¼�
input i_exeDriveToLsu_1;
input [162:0] i_exeToLsuData_163;
//��datarout��������
input i_dataRoutDriveToLsu_1;
//datarout���ĸ�λ
input i_lsuFreeFromDataRout_1;
//��д���ĸ�λ
input i_lsuFreeFromWriteBack_1;
//���ɸ��ĸ�λ
input i_lsuFreeFromLaunch_1;
//���쳣���ĸ�λ
input i_lsuFreeFromExcp_1;
//��datarout��������
input [63:0] i_memData_64;
//��grf��readGrfSelector�����弰����
input i_grfDriveToLsu_1;
input [63:0] i_grfToLsuData_64;
//grf��readGrfMutexMerge�ĸ�λ
input i_lsuFreeFromRGrf_1;
//дgrf��lsu�ĸ�λ
input i_lsuFreeFromWGrf_1;
//11/6 zwm
input [1:0] i_wen_2;
//12/24 zwm 
input i_lsuFreeFromIcache_1;
input i_icacheDriveToLsu_1;
input [63:0] i_icacheData_64;

//lsu��ִ�еĸ�λ
output o_lsuFreeToExe_1;
//lsu���쳣�����弰�쳣�����PC
output o_lsuDriveToExcp_1;
output [35:0] o_exception_36;
//lsu��datarout�����弰����
output o_lsuDriveToDataRout_1;
output [103:0] o_lsuToDataRoutData_104;
//lsu����д�����弰����
output o_lsuDriveToWriteBack_1;
output [102:0] o_lsuToWriteBackData_103;
//lsu�����ɵ���·
output o_lsuDriveToLaunch_1;
output [63:0] o_lsuToLaunchData_64;
//readGrfSelector��grf�ĸ�λ
output o_grfFreeFromLsu_1;
//readGrfMutexMerge��grf�����弰����
output o_lsuDriveToRGrf_1;
output [7:0] o_lsuToRGrfData_8;
//lsu��дgrf������
output o_lsuDriveToWGrf_1;
output [73:0] o_wGrfData_74;
//lsu��datatrout��λ
output o_lsuFreeToDataRout_1;
//���ַô������־�?
output o_endFlag_1;
//11/8 zwm
output  o_multiLoadOrStoreOver;
//11/19 zwm add load end over flag
output o_loadEndDrive;
output o_loadEndFlag;
//12/24 zwm add a path to icache
output o_lsuDriveToIcache_1;
output [103:0] o_lsuToIcacheData_104;
output o_lsuFreeToIcache_1;
output o_lsuInUseFlag_1;

wire [162:0] w_exeLsuBus_163;
wire w_wbackSplitterToLsuFifo_1;//11/8 zwm make nouse
wire w_lsuOver_1;
wire w_lsuFifoToExcSplitter_1;
wire w_lsuFifoToWbackSplitter_1;
wire w_excSplitterFree_1;
// lsuFifo
lsu_cFifo1_lsu lsuFifo(
    .i_drive(i_exeDriveToLsu_1),
    .i_freeNext(w_excSplitterFree_1),
    .rst(rst),
    .i_data_163(i_exeToLsuData_163),
    .o_data_163(w_exeLsuBus_163),
    .o_free(w_lsuOver_1),
    .o_driveNext(w_lsuFifoToExcSplitter_1)
);


//1/3 zwm add a path to exc
wire w_b_1;
  (* dont_touch="true" *)  cSplitter2_1b excSplitter (
    .i_drive     (w_lsuFifoToExcSplitter_1), .i_data_1(1'b0), .o_free(w_excSplitterFree_1    ),
    .o_driveNext0(w_lsuFifoToWbackSplitter_1), .i_freeNext0(w_wbackSplitterToLsuFifo_1), .o_data0_1(),
    .o_driveNext1(o_lsuDriveToExcp_1), .i_freeNext1(w_b_1), .o_data1_1(      ),
    .rst         (rst                                                              )
  );
  (* dont_touch="true" *)delay8U excSplitterDelay(
  .inR(o_lsuDriveToExcp_1),
  .outR(w_b_1),
  .rst(rst)
  );
// wire w_sat_1;
// wire w_adderCarryOut_1;
// wire w_adderOverFlow_1;
// wire w_shiftCarryOut_1;
wire [3:0] w_nzcv_4;
wire [63:0] w_data_64;
wire [14:0] w_writeBackIdentifyData_15;
(* dont_touch="true" *)wire w_load_1;
wire [1:0] w_loadStoreWidth_2;
wire w_loadSign_1;
wire w_isLS_1;
wire w_writeRd_1;
wire w_isMultiLS_1;
wire [31:0] w_currentPc_32;
wire [15:0] w_registerList_16;
// wire [31:0] w_Rn_32;
wire [3:0] w_dHi_4;
wire [3:0] w_dLo_4;
wire [3:0] w_n_4;
wire w_P_1,w_W_1,w_U_1,w_S_1;
wire [8:0] w_operationTypeCode_9;                                     

// ���ݴ���
assign {
        w_writeBackIdentifyData_15,
        w_load_1,
        w_loadStoreWidth_2,
        w_loadSign_1,
        w_isLS_1,
        w_writeRd_1,
        w_isMultiLS_1,
        w_registerList_16,
        w_currentPc_32,
        // w_Rn_32,
        w_dHi_4,
        w_dLo_4,
        w_n_4,
        w_P_1,w_W_1,w_U_1,w_S_1,
        w_operationTypeCode_9,
        w_nzcv_4,
        w_data_64
        } = w_exeLsuBus_163;

(* dont_touch="true" *)wire [31:0] w_address_32;
(* dont_touch="true" *)wire w_store_1;
(* dont_touch="true" *)wire [1:0] w_lsuType_2;
//???������쳣��־��β���
wire w_error_1;
assign w_error_1 = 0;
assign w_address_32 =  w_P_1 == 1'b1 ? w_data_64[31:0] : w_data_64[63:32];
assign w_store_1 = w_isLS_1 == 1'b1 ? (w_load_1 == 1'b1 ? 1'b0 : 1'b1) : 1'b0;
assign w_lsuType_2 = w_loadStoreWidth_2 == 2'b00 ? 2'b00 :
                    (w_loadStoreWidth_2 == 2'b01 ? 2'b01 :
                    (w_loadStoreWidth_2 == 2'b10 ? 2'b10 :
                    (w_loadStoreWidth_2 == 2'b11 ? 2'b11 : 2'b00)));

//wbackSplitter
wire w_wbackSplitterToStateSelector_1;
wire w_stateSelectorToWbackSplitter_1;
wire w_wbackSplitterToWbackSelector_1;
wire w_wbackSelectorToWbackSplitter_1;
wire [73:0] w_wbackSplitterOverData1_74;
wire [32:0] w_wbackSplitterOverData2_33;
(* dont_touch="true" *)cSplitter2_107_74_33b_lsu wbackSplitter(
    .i_drive(w_lsuFifoToWbackSplitter_1),
    .i_data_107(w_exeLsuBus_163[106:0]), 
    .o_free(w_wbackSplitterToLsuFifo_1),
    .o_driveNext0(w_wbackSplitterToStateSelector_1), 
    .i_freeNext0(w_stateSelectorToWbackSplitter_1), 
    .o_data0_74(w_wbackSplitterOverData1_74),
    .o_driveNext1(w_wbackSplitterToWbackSelector_1), 
    .o_data1_33(w_wbackSplitterOverData2_33), 
    .i_freeNext1(w_wbackSelectorToWbackSplitter_1),
    .rst(rst)
);

//wbackSelector
wire w_backSelectorOver_1;
wire [73:0] w_backSelectorOverData_74;
wire [74:0] w_backSelectorData_75;
assign w_backSelectorData_75 = {{4{1'b0}},w_n_4,{32{1'b0}},w_data_64[31:0],{1{2'b01}},w_W_1};
(* dont_touch="true" *)cSelector2_75b_lsu wbackSelector(
.i_drive(w_wbackSplitterToWbackSelector_1), .i_data_75(w_backSelectorData_75), .o_free(w_wbackSelectorToWbackSplitter_1),
.o_driveNext0(o_lsuDriveToWGrf_1), .i_freeNext0(i_lsuFreeFromWGrf_1), .o_data0_74(o_wGrfData_74),
.o_driveNext1(w_backSelectorOver_1), .o_data1_74(w_backSelectorOverData_74), .i_freeNext1(w_backSelectorOver_1),
.rst(rst)
);


// stateSelector
wire w_stateSelectorToExcpFifo_1;
wire w_excpFifoToStateSelector_1;
wire w_stateSelectorToReadGrfSelector_1;
wire w_readGrfSelectorToStateSelector_1;
wire w_stateSelectorToNoLsSplitter_1;
wire w_noLsSplitterToStateSelector_1;
wire w_stateSelectorToMultiLoadMutexMerge_1;
wire w_multiLoadMutexMergeToStateSelector_1;
wire w_stateSelectorToMultiStoreMutexMerge_1;
wire w_multiStoreMutexMergeToStateSelector_1;
wire [4:0] w_over1_5;
wire [4:0] w_over2_5;
wire [4:0] w_over3_5;
wire [4:0] w_over4_5;
wire [4:0] w_over5_5;
(* dont_touch="true" *)cSelector5_5b_lsu stateSelector(
.i_drive(w_wbackSplitterToStateSelector_1), .i_data_5({w_load_1,w_store_1,w_isLS_1,w_isMultiLS_1,w_error_1}), .o_free(w_stateSelectorToWbackSplitter_1),
.o_driveNext0(w_stateSelectorToExcpFifo_1), .i_freeNext0(w_excpFifoToStateSelector_1), .o_data0_5(w_over1_5),
.o_driveNext1(w_stateSelectorToReadGrfSelector_1), .o_data1_5(w_over2_5), .i_freeNext1(w_readGrfSelectorToStateSelector_1),
.o_driveNext2(w_stateSelectorToNoLsSplitter_1), .i_freeNext2(w_noLsSplitterToStateSelector_1), .o_data2_5(w_over3_5),
.o_driveNext3(w_stateSelectorToMultiLoadMutexMerge_1), .o_data3_5(w_over4_5), .i_freeNext3(w_multiLoadMutexMergeToStateSelector_1),
.o_driveNext4(w_stateSelectorToMultiStoreMutexMerge_1), .o_data4_5(w_over5_5), .i_freeNext4(w_multiStoreMutexMergeToStateSelector_1),
.rst(rst)
);

wire w_stateSelectorToNoLsSplitterDelay_1;
wire w_stateSelectorToNoLsSplitterDelay1_1;
wire w_stateSelectorToNoLsSplitterDelay2_1;
wire w_stateSelectorToNoLsSplitterDelay3_1;
wire w_stateSelectorToNoLsSplitterDelay4_1;
wire w_stateSelectorToNoLsSplitterDelay5_1;
wire w_stateSelectorToNoLsSplitterDelay6_1;
//11/29 zwm add 16u
//12/24 zwm add 8u
(* dont_touch="true" *)delay32U delayDriveToNoLs(
.inR(w_stateSelectorToNoLsSplitter_1),
.outR(w_stateSelectorToNoLsSplitterDelay1_1),
.rst(rst)
);

(* dont_touch="true" *)delay64U delayDriveToNoLs1(
.inR(w_stateSelectorToNoLsSplitterDelay1_1),
.outR(w_stateSelectorToNoLsSplitterDelay2_1),
.rst(rst)
);

(* dont_touch="true" *)delay64U delayDriveToNoLs2(//1/23 zwm change 32u to 64u
    .inR(w_stateSelectorToNoLsSplitterDelay2_1),
    .outR(w_stateSelectorToNoLsSplitterDelay3_1),
    .rst(rst)
    );

//12/11 zwm change 16U to 64U
(* dont_touch="true" *)delay64U delayDriveToNoLs3(
.inR(w_stateSelectorToNoLsSplitterDelay3_1),
.outR(w_stateSelectorToNoLsSplitterDelay4_1),
.rst(rst)
);


//1/9 zwm add a 8u
//1/15 zwm change 8u to 16u
(* dont_touch="true" *)delay16U delayDriveToNoLs4(
    .inR(w_stateSelectorToNoLsSplitterDelay4_1),
    .outR(w_stateSelectorToNoLsSplitterDelay5_1),
    .rst(rst)
    );


(* dont_touch="true" *)delay8U delayDriveToNoLs5(
    .inR(w_stateSelectorToNoLsSplitterDelay5_1),
    .outR(w_stateSelectorToNoLsSplitterDelay6_1),
    .rst(rst)
    );

cFifo1 lsuDelayFifo(.i_drive(w_stateSelectorToNoLsSplitterDelay6_1), .i_freeNext(w_noLsSplitterToStateSelector_1), .rst(rst),
               .o_free(), .o_driveNext(), .o_fire_1(w_stateSelectorToNoLsSplitterDelay_1));

//multiStoreMutexMerge
//����store����
wire w_multiStoreSelectorToMultiStoreMutexMerge_1;
wire w_multiStoreMutexMergeToMultiStoreSelector_1;
wire w_multiStoreMutexMergeToMultiStoreFifo_1;
wire w_multiStoreFifoToMultiStoreMutexMerge_1;
wire [31:0] w_storeAddress_32;//�õ�ַΪdatarout�Ĵ�����ַ
wire [15:0] w_storeRegisterList_16;
wire [31:0] w_nextStoreAddress_32;
wire [15:0] w_nextStoreRegisterList_16;
(* dont_touch="true" *)cMutexMerge2_48b_lsu multiStoreMutexMerge(
    .i_drive0(w_stateSelectorToMultiStoreMutexMerge_1), 
    .i_data0_48({w_address_32,w_registerList_16}), 
    .o_free0(w_multiStoreMutexMergeToStateSelector_1),
    .i_drive1(w_multiStoreSelectorToMultiStoreMutexMerge_1), 
    .i_data1_48({w_nextStoreAddress_32,w_nextStoreRegisterList_16}), 
    .o_free1(w_multiStoreMutexMergeToMultiStoreSelector_1),
    .i_freeNext(w_multiStoreFifoToMultiStoreMutexMerge_1), 
    .o_driveNext(w_multiStoreMutexMergeToMultiStoreFifo_1), 
    .o_data_48({w_storeAddress_32,w_storeRegisterList_16}),
    .rst(rst)    
);

//11/15 zwm delay not need,not to multistoreUpdate but to dataRoutMutexMerge
wire w_multiStoreMutexMergeToMultiStoreFifoDelay1_1;
wire w_multiStoreMutexMergeToMultiStoreFifoDelay2_1;
wire w_multiStoreMutexMergeToMultiStoreFifoDelay3_1;
(* dont_touch="true" *)delay16U outdelay0(.inR(w_multiStoreMutexMergeToMultiStoreFifo_1),.outR(w_multiStoreMutexMergeToMultiStoreFifoDelay1_1),.rst(rst));
(* dont_touch="true" *)delay8U outdelay1(.inR(w_multiStoreMutexMergeToMultiStoreFifoDelay1_1),.outR(w_multiStoreMutexMergeToMultiStoreFifoDelay2_1),.rst(rst));
// (* dont_touch="true" *)delay8U outdelay1(.inR(w_multiStoreMutexMergeToMultiStoreFifoDelay2_1),.outR(w_multiStoreMutexMergeToMultiStoreFifoDelay1_1),.rst(rst));

//����Store���ݸ���
wire [3:0] w_multiStoreDataUpateToWbackDHi_4;
wire [3:0] w_multiStoreDataUpateToWbackDLo_4;
wire [1:0] w_multiStoreDataUpateToWabckWen_2;
wire [7:0] w_multiStoreDataUpateToDataRoutWen_8;
wire w_endStoreFlag_1;
(* dont_touch="true" *)multiStoreDataUpate multiStoreDataUpate(
    .rst(rst),
    .i_fromMutexMerge_1(w_multiStoreMutexMergeToMultiStoreFifoDelay1_1),
    .i_address_32(w_storeAddress_32),
    .i_registerList_16(w_storeRegisterList_16),
    .o_dHi_4(w_multiStoreDataUpateToWbackDHi_4),
    .o_dLo_4(w_multiStoreDataUpateToWbackDLo_4),
    .o_wbackWen_2(w_multiStoreDataUpateToWabckWen_2),
    .o_dataRoutWen_8(w_multiStoreDataUpateToDataRoutWen_8),
    .o_endFlag_1(w_endStoreFlag_1),
    .o_nextAddress_32(w_nextStoreAddress_32),
    .o_nextRegisterList_16(w_nextStoreRegisterList_16)
);

//multiStoreFifo
wire w_multiStoreFifoToReadGrfMutexMerge_1;
wire w_readGrfMutexMergeToMultiStoreFifo_1;
wire [42:0] w_multiStoreDataUpdateData_43;

//11/15 zwm change 3U to 6U
// (* dont_touch="true" *)delay6U outdelay2(.inR(w_multiStoreMutexMergeToMultiStoreFifoDelay1_1),.outR(w_multiStoreMutexMergeToMultiStoreFifoDelay3_1),.rst(rst));
//!!! 12/8 zwm w_multiStoreDataUpateToWbackDHi_4 and w_multiStoreDataUpateToWbackDLo_4 should change the position,because we should first read the dHi then the dLo
//12/12 zwm change back.
(* dont_touch="true" *)cFifo1_43b_lsu multiStoreFifo(
    .i_drive(w_multiStoreMutexMergeToMultiStoreFifoDelay2_1), 
    .i_data_43({w_nextStoreAddress_32,w_endStoreFlag_1,w_multiStoreDataUpateToWbackDHi_4,w_multiStoreDataUpateToWbackDLo_4,w_multiStoreDataUpateToWabckWen_2}), 
    .o_free(w_multiStoreFifoToMultiStoreMutexMerge_1),
    .rst(rst),
    .o_driveNext(w_multiStoreFifoToReadGrfMutexMerge_1), 
    .o_data_43(w_multiStoreDataUpdateData_43), 
    .i_freeNext(w_readGrfMutexMergeToMultiStoreFifo_1)
);

//multiStoreSelector
//ͨ��endStoreFlag�ж�store�Ƿ������ÿ�ξ���multiStoreDataUpate�������һ��endStoreFlag
wire w_multiStoreSelectorOver_1;
wire w_multiStoreSelectorToDataRout_1;
wire w_dataRoutToMultiStoreSelector_1;
wire w_multiStoreSelectorOverData1_1;
wire w_multiStoreSelectorOverData2_1;
wire w_multiStoreSelectorOver1_1;
(* dont_touch="true" *)cSelector2_1b_lsu multiStoreSelector(
    .i_drive(w_dataRoutToMultiStoreSelector_1), 
    .i_data_1({w_endStoreFlag_1}), 
    .o_free(w_multiStoreSelectorToDataRout_1),
    .o_driveNext0(w_multiStoreSelectorOver_1), 
    .i_freeNext0(w_multiStoreSelectorOver1_1), 
    .o_data0_1(w_multiStoreSelectorOverData1_1),
    .o_driveNext1(w_multiStoreSelectorToMultiStoreMutexMerge_1), 
    .o_data1_1(w_multiStoreSelectorOverData2_1), 
    .i_freeNext1(w_multiStoreMutexMergeToMultiStoreSelector_1),
    .rst(rst)  
);
(* dont_touch="true" *)delay2U multiStoreDelay(.inR(w_multiStoreSelectorOver_1),.outR(w_multiStoreSelectorOver1_1),.rst(rst));

//multiLoadMutexMerge
//����load����
wire w_multiLoadSplitterToMultiLoadMutexMerge_1;
wire w_multiLoadMutexMergeToMultiLoadSplitter_1;
wire w_multiLoadMutexMergeToMultiLoadSelector_1;
wire w_multiLoadSelectorToMultiLoadMutexMerge_1;
wire [48:0] w_multiLoadMutexMergeToMultiLoadSelectorData_49;
wire [31:0] w_nextLoadAddress_32;
wire [15:0] w_nextLoadRegisterList_16;
wire w_endLoadFlag_1;
(* dont_touch="true" *)cMutexMerge2_49b_lsu multiLoadMutexMerge(
    .i_drive0(w_stateSelectorToMultiLoadMutexMerge_1), 
    .i_data0_49({w_address_32,w_registerList_16,1'b0}), 
    .o_free0(w_multiLoadMutexMergeToStateSelector_1),
    .i_drive1(w_multiLoadSplitterToMultiLoadMutexMerge_1), 
    .i_data1_49({w_nextLoadAddress_32,w_nextLoadRegisterList_16,w_endLoadFlag_1}), 
    .o_free1(w_multiLoadMutexMergeToMultiLoadSplitter_1),
    .i_freeNext(w_multiLoadSelectorToMultiLoadMutexMerge_1), 
    .o_driveNext(w_multiLoadMutexMergeToMultiLoadSelector_1), 
    .o_data_49(w_multiLoadMutexMergeToMultiLoadSelectorData_49),
    .rst(rst)    
);

//multiLoadSelector
wire w_multiLoadSelectorOver_1;
wire w_multiLoadSelectorToDataRout_1;
wire w_dataRoutToMultiLoadSelector_1;
wire [47:0] w_multiLoadSelectorOverData_48;
wire [31:0] w_loadAddress_32;
wire [15:0] w_loadRegisterList_16;


//��һ����ʱ
wire w_multiLoadMutexMergeToMultiLoadSelectorDelay_1;
(* dont_touch="true" *)delay3U outdelay3(.inR(w_multiLoadMutexMergeToMultiLoadSelector_1), .outR(w_multiLoadMutexMergeToMultiLoadSelectorDelay_1),.rst(rst));
(* dont_touch="true" *)cSelector2_49b_lsu multiLoadSelector(
    .i_drive(w_multiLoadMutexMergeToMultiLoadSelectorDelay_1), 
    .i_data_49(w_multiLoadMutexMergeToMultiLoadSelectorData_49), 
    .o_free(w_multiLoadSelectorToMultiLoadMutexMerge_1),
    .o_driveNext0(w_multiLoadSelectorOver_1), 
    .i_freeNext0(w_multiLoadSelectorOver_1), 
    .o_data0_48(w_multiLoadSelectorOverData_48),
    .o_driveNext1(w_multiLoadSelectorToDataRout_1), 
    .o_data1_48({w_loadAddress_32,w_loadRegisterList_16}), 
    .i_freeNext1(w_dataRoutToMultiLoadSelector_1),
    .rst(rst)  
);

//����load���ݸ���
wire [63:0] w_dataRoutToMultiLoadDataUpdataData_64;
wire w_dataRoutToMultiLoadDataUpdate_1;
wire [3:0] w_multiLoadDataUpateToWbackDHi_4;
wire [3:0] w_multiLoadDataUpateToWbackDLo_4;
wire [63:0] w_multiLoadDataUpateToWabckData_64;
wire [1:0] w_multiLoadDataUpateToWabckWen_2;
(* dont_touch="true" *)multiLoadDataUpate multiLoadDataUpate(
    .rst(rst),
    .i_fromDataRout_1(w_dataRoutToMultiLoadDataUpdate_1),
    .i_fromDataRoutData_64(w_dataRoutToMultiLoadDataUpdataData_64),
    .i_address_32(w_loadAddress_32),
    .i_registerList_16(w_loadRegisterList_16),
    .o_dHi_4(w_multiLoadDataUpateToWbackDHi_4),
    .o_dLo_4(w_multiLoadDataUpateToWbackDLo_4),
    .o_wbackData_64(w_multiLoadDataUpateToWabckData_64),
    .o_wbackWen_2(w_multiLoadDataUpateToWabckWen_2),
    .o_endFlag_1(w_endLoadFlag_1),
    .o_nextAddress_32(w_nextLoadAddress_32),
    .o_nextRegisterList_16(w_nextLoadRegisterList_16)
);

//multiLoadFifo
wire w_multiLoadDataUpdateToDataRout_1;
wire w_multiLoadDataUpdateFifoToMultiLoadSplitter_1;
wire w_multiLoadSplitterToMultiLoadDataUpdateFifo_1;
wire [106:0] w_multiLoadDataUpdateData_107;
wire w_dataRoutToMultiLoadDataUpdateDelay_1;

//�üӸ���ʱ
(* dont_touch="true" *)delay8U outdelay4 (.inR(w_dataRoutToMultiLoadDataUpdate_1),.outR(w_dataRoutToMultiLoadDataUpdateDelay_1), .rst(rst));
(* dont_touch="true" *)cFifo1_107b_lsu multiLoadFifo(
    .i_drive(w_dataRoutToMultiLoadDataUpdateDelay_1), 
    .i_data_107({w_nextLoadAddress_32,w_endLoadFlag_1,w_multiLoadDataUpateToWbackDHi_4,w_multiLoadDataUpateToWbackDLo_4,w_multiLoadDataUpateToWabckData_64,w_multiLoadDataUpateToWabckWen_2}), 
    .o_free(w_multiLoadDataUpdateToDataRout_1),
    .rst(rst),
    .o_driveNext(w_multiLoadDataUpdateFifoToMultiLoadSplitter_1), 
    .o_data_107(w_multiLoadDataUpdateData_107), 
    .i_freeNext(w_multiLoadSplitterToMultiLoadDataUpdateFifo_1)
);

//multiLoadSplitter
wire w_multiLoadSplitterToWback_1;
wire w_wbackToMultiLoadSplitter_1;
wire [73:0] w_multiLoadToWbackData_74;
wire [32:0] w_multiLoadSplitterData_33;
(* dont_touch="true" *)cSplitter2_107_74_33b_lsu multiLoadSplitter(
.i_drive(w_multiLoadDataUpdateFifoToMultiLoadSplitter_1), .i_data_107(w_multiLoadDataUpdateData_107), .o_free(w_multiLoadSplitterToMultiLoadDataUpdateFifo_1),
.o_driveNext0(w_multiLoadSplitterToWback_1), .i_freeNext0(w_wbackToMultiLoadSplitter_1), .o_data0_74(w_multiLoadToWbackData_74),
.o_driveNext1(w_multiLoadSplitterToMultiLoadMutexMerge_1), .o_data1_33(w_multiLoadSplitterData_33), .i_freeNext1(w_multiLoadMutexMergeToMultiLoadSplitter_1),
.rst(rst)
);

//noLsSplitter
// wire w_noLsSplitterToLaunchMutexMerge_1;
wire w_noLsSplitterToBitOpSelector_1;
// wire w_launchMutexMergeToNoLsSplitter_1;
wire w_bitOpSelectorToNoLsSplitter_1;
wire w_noLsSplitterToWriteBackMutexMerge_1;
wire w_writeBackMuetxMergeToNoLsSplitter_1;
wire [63:0] w_noLsSplitterData1_64;
wire [63:0] w_noLsSplitterData2_64;
(* dont_touch="true" *)cSplitter2_64b_lsu noLsSplitter(
.i_drive(w_stateSelectorToNoLsSplitterDelay_1), .i_data_64(64'b0), .o_free(w_noLsSplitterToStateSelector_1),
.o_driveNext0(w_noLsSplitterToBitOpSelector_1), .i_freeNext0(w_bitOpSelectorToNoLsSplitter_1), .o_data0_64(w_noLsSplitterData1_64),
.o_driveNext1(w_noLsSplitterToWriteBackMutexMerge_1), .o_data1_64(w_noLsSplitterData2_64), .i_freeNext1(w_writeBackMuetxMergeToNoLsSplitter_1),
.rst(rst)
);


wire w_bitOpFlag_1;
wire w_bitOpSelectorDrv2LaunchMutexMerge_1;
wire w_bitOpSelctorFreeFLaunchMutexMerge_1;
wire w_bitOpSelectorOver_1;
wire w_bitOpSelectorOver1_1;
delay4U outdelay12(.inR(w_bitOpSelectorOver_1), .outR(w_bitOpSelectorOver1_1),.rst(rst));
assign w_bitOpFlag_1 = (w_writeBackIdentifyData_15[13:10] == 4'b0);
(* dont_touch="true" *)cSelector2_1b_lsu bitOpSelector(
    .i_drive(w_noLsSplitterToBitOpSelector_1), 
    .i_data_1({w_bitOpFlag_1}), 
    .o_free(w_bitOpSelectorToNoLsSplitter_1),
    .o_driveNext0(w_bitOpSelectorDrv2LaunchMutexMerge_1), 
    .i_freeNext0(w_bitOpSelctorFreeFLaunchMutexMerge_1), 
    .o_data0_1(),
    .o_driveNext1(w_bitOpSelectorOver_1), 
    .o_data1_1(), 
    .i_freeNext1(w_bitOpSelectorOver1_1),
    .rst(rst)  
);


//�Ƿ���ҪȡGRF(load����Ҫ��store��Ҫ)
//readGrfSelector
wire w_readGrfSelectorToLASMutexMerge_1;
wire w_LASMutexMergeToReadGrfSelector_1;
wire w_readGrfSelectorToReadGrfMutexMerge_1;
wire w_readGrfMutexMergeToReadGrfSelector_1;
wire [1:0] w_readGrfSelectorData1_2;
wire [1:0] w_readGrfSelectorData2_2;
(* dont_touch="true" *)cSelector2_2b_lsu readGrfSelector(
    .i_drive(w_stateSelectorToReadGrfSelector_1), 
    .i_data_2({w_store_1,w_load_1}), 
    .o_free(w_readGrfSelectorToStateSelector_1),
    .o_driveNext0(w_readGrfSelectorToLASMutexMerge_1), 
    .i_freeNext0(w_LASMutexMergeToReadGrfSelector_1), 
    .o_data0_2(w_readGrfSelectorData1_2),
    .o_driveNext1(w_readGrfSelectorToReadGrfMutexMerge_1), 
    .o_data1_2(w_readGrfSelectorData2_2), 
    .i_freeNext1(w_readGrfMutexMergeToReadGrfSelector_1),
    .rst(rst)  
);

//readGrfMutexMerge
wire [1:0] w_readGrfWen_2;
assign w_readGrfWen_2 = w_lsuType_2 == 2'b10 ? 2'b11 : 2'b01;
(* dont_touch="true" *)cMutexMerge2_8b_lsu readGrfMutexMerge(
    .i_drive0(w_readGrfSelectorToReadGrfMutexMerge_1), 
    .i_data0_8({w_dHi_4,w_dLo_4}), 
    .o_free0(w_readGrfMutexMergeToReadGrfSelector_1),
    .i_drive1(w_multiStoreFifoToReadGrfMutexMerge_1), 
    .i_data1_8(w_multiStoreDataUpdateData_43[9:2]), 
    .o_free1(w_readGrfMutexMergeToMultiStoreFifo_1),
    .i_freeNext(i_lsuFreeFromRGrf_1), 
    .o_driveNext(o_lsuDriveToRGrf_1), 
    .o_data_8(o_lsuToRGrfData_8),
    .rst(rst)    
);

//ȷ����grf�������ݵ�����
wire w_grfSelectorToLASMutexMerge_1;
wire w_LASMutexMergeToGrfSelector_1;
wire w_grfSelectorToMultiStoreDataUpdateDataRout_1;
wire w_multiStoreDataUdpateDataRoutToGrfSelector_1;
wire [63:0] w_grfSelectorToLASMutexMerge_64;
//!!!����grf���ڵ�λ���ݶ����ڵ�32λ������Է�������store������Ҫ���д���
wire [63:0] w_grfSelectorToMultiStoreDataUpdateDataTmp_64;
wire [63:0] w_grfSelectorToMultiStoreDataUpdateData_64;
//12/3 zwm first high then low,change w_grfSelectorToMultiStoreDataUpdateDataTmp_64[31:0] to w_grfSelectorToMultiStoreDataUpdateDataTmp_64[63:32]
//12/12 zwm change back.because if dh and dl is all vaild,we shouldn't change the position
wire [63:0] w_grfToLsuData_64;
assign w_grfToLsuData_64 = (w_isMultiLS_1 | i_wen_2 == 2'b11) ? i_grfToLsuData_64 : {i_grfToLsuData_64[31:0],i_grfToLsuData_64[63:32]};
assign w_grfSelectorToMultiStoreDataUpdateData_64 = w_multiStoreDataUpateToDataRoutWen_8 == 8'b1111_0000 ? {w_grfSelectorToMultiStoreDataUpdateDataTmp_64[31:0],32'b0} : w_grfSelectorToMultiStoreDataUpdateDataTmp_64;
 (* dont_touch="true" *)cSelector2_65b_lsu grfSelector(
    .i_drive(i_grfDriveToLsu_1), 
    .i_data_65({w_grfToLsuData_64,w_isMultiLS_1}),
    .o_free(o_grfFreeFromLsu_1),
    .o_driveNext0(w_grfSelectorToLASMutexMerge_1), 
    .i_freeNext0(w_LASMutexMergeToGrfSelector_1), 
    .o_data0_64(w_grfSelectorToLASMutexMerge_64),
    .o_driveNext1(w_grfSelectorToMultiStoreDataUpdateDataRout_1), 
    .o_data1_64(w_grfSelectorToMultiStoreDataUpdateDataTmp_64), 
    .i_freeNext1(w_multiStoreDataUdpateDataRoutToGrfSelector_1),
    .rst(rst)  
);
//LASMutexMerge
wire w_LASMutexMergeToLsuMutexMerge_1;
wire w_lsuMutexMergeToLASMutexMerge_1;
//����store���ܻ��漰������datarout����������ǰ�����δ����ֻ��Ҫ��grfȡһ�ξ��У����Ա��뽫��һ��ȡ���������ݴ�
wire [63:0] w_LASMutexMergeToLsuMutexMerge_64;
(* dont_touch="true" *)reg [63:0] r_LASMutexMergeToLsuMutexMerge_64;
(* dont_touch="true" *)wire [63:0] w_LASMutexMergeToLsuMutexMergeTmp_64;
(* dont_touch="true" *)cMutexMerge2_64b_lsu LASMutexMerge(
    .i_drive0(w_readGrfSelectorToLASMutexMerge_1), 
    .i_data0_64(64'b0), 
    .o_free0(w_LASMutexMergeToReadGrfSelector_1),
    .i_drive1(w_grfSelectorToLASMutexMerge_1), 
    .i_data1_64(w_grfSelectorToLASMutexMerge_64), 
    .o_free1(w_LASMutexMergeToGrfSelector_1),
    .i_freeNext(w_lsuMutexMergeToLASMutexMerge_1), 
    .o_driveNext(w_LASMutexMergeToLsuMutexMerge_1), 
    .o_data_64(w_LASMutexMergeToLsuMutexMerge_64),
    .rst(rst) 
);
//12/19 zwm add a new delay4U
(* dont_touch="true" *)wire w_LASMutexMergeToLsuMutexMergeDelay_1,w_LASMutexMergeToLsuMutexMergeDelay1_1,w_LASMutexMergeToLsuMutexMergeDelay2_1;
delay6U outdelay5(.inR(w_LASMutexMergeToLsuMutexMerge_1), .outR(w_LASMutexMergeToLsuMutexMergeDelay_1),.rst(rst));
delay6U outdelay6(.inR(w_LASMutexMergeToLsuMutexMergeDelay_1), .outR(w_LASMutexMergeToLsuMutexMergeDelay1_1),.rst(rst));
delay6U outdelay11(.inR(w_LASMutexMergeToLsuMutexMergeDelay1_1), .outR(w_LASMutexMergeToLsuMutexMergeDelay2_1),.rst(rst));
always @(posedge w_LASMutexMergeToLsuMutexMergeDelay2_1 or negedge rst) begin
    if(!rst)begin
        r_LASMutexMergeToLsuMutexMerge_64 = 64'b0;
    end else begin
        r_LASMutexMergeToLsuMutexMerge_64 = w_LASMutexMergeToLsuMutexMerge_64;
    end
end
assign w_LASMutexMergeToLsuMutexMergeTmp_64 = r_LASMutexMergeToLsuMutexMerge_64;
//lsuMutexMerge
wire w_updateFinalSelectorToLsuMutexMerge_1;
wire w_lsuMutexMergeToUpdateFinalSelector_1;
wire w_lsuMutexMergeToUpdateSplitter_1;
wire w_updateSplitterToLsuMutexMerge_1;
wire [75:0] w_updateFinalSelectorToLsuMutexMergeData_76;
wire [75:0] w_lsuMutexMergeToUpdateSplitterData_76;
wire [11:0] w_firstStateValid_12;
assign w_firstStateValid_12 = w_load_1 == 1 ? 12'b1000_0000_0000 :
                             (w_store_1 == 1 ? 12'b0000_0000_1000 : 12'b0000_0000_0000);
(* dont_touch="true" *)cMutexMerge2_76b_lsu lsuMutexMerge(
.i_drive0(w_updateFinalSelectorToLsuMutexMerge_1), .i_data0_76(w_updateFinalSelectorToLsuMutexMergeData_76), .o_free0(w_lsuMutexMergeToUpdateFinalSelector_1),
.i_drive1(w_LASMutexMergeToLsuMutexMergeDelay2_1), .i_data1_76({w_LASMutexMergeToLsuMutexMergeTmp_64,w_firstStateValid_12}), .o_free1(w_lsuMutexMergeToLASMutexMerge_1),
.i_freeNext(w_updateSplitterToLsuMutexMerge_1), .o_driveNext(w_lsuMutexMergeToUpdateSplitter_1), .o_data_76(w_lsuMutexMergeToUpdateSplitterData_76),
.rst(rst)   
);

//updateSplitter
wire w_udpateSplitterToStateUpdate_1;
wire w_stateUpdateToUpdateSplitter_1;
wire w_dataUpdateToUpdateSplitter_1;
wire w_updateSplitterToDataUpdate_1;
wire [63:0] w_updateSplitterData1_64;
wire [63:0] w_updateSplitterData2_64;
(* dont_touch="true" *)cSplitter2_64b_lsu updateSplitter(
.i_drive(w_lsuMutexMergeToUpdateSplitter_1), .i_data_64(64'b0), .o_free(w_updateSplitterToLsuMutexMerge_1),
.o_driveNext0(w_udpateSplitterToStateUpdate_1), .i_freeNext0(w_stateUpdateToUpdateSplitter_1), .o_data0_64(w_updateSplitterData1_64),
.o_driveNext1(w_updateSplitterToDataUpdate_1), .o_data1_64(w_updateSplitterData2_64), .i_freeNext1(w_dataUpdateToUpdateSplitter_1),
.rst(rst)
);
// ״̬����
wire w_stateUpdateToStateUpdateSelector_1;
wire w_stateUpdateSelectorToStateUpdate_1;
wire [11:0] w_stateValid_12;
wire w_misaligned_1;
//12/16 zwm due to peripheral not need judge the address whether misaligned ,so we should first distinct the addr from peripheral or from normal addr
wire [2:0] w_memAddrLtb_3;
wire w_addrFromPeripheralFlag_1;
assign w_addrFromPeripheralFlag_1 = (w_address_32 >= 32'h01000 && w_address_32 <= 32'h0109f) ? 1'b1 : 1'b0;
assign w_memAddrLtb_3 = (w_address_32 >= 32'h01000 && w_address_32 <= 32'h0109f) ? 3'b000 : w_address_32[2:0];
(* dont_touch="true" *)stateUpdate stateUpdate(
    .rst(rst),
    .i_driveFromUpdateSplitter_1(w_udpateSplitterToStateUpdate_1), 
    .i_fromUpdateSplitterData_7({w_load_1,w_store_1,w_lsuType_2,w_memAddrLtb_3}),
    .i_freeFromStateUpdateSelector_1(w_stateUpdateSelectorToStateUpdate_1), 
    .o_freeToUpdateSplitter_1(w_stateUpdateToUpdateSplitter_1),
    .o_driveToStateUpdateSelector_1(w_stateUpdateToStateUpdateSelector_1), 
    .o_stateValid_12(w_stateValid_12), .o_misaligned_1(w_misaligned_1)
);


// ���ݸ���
wire w_dataUpdateToWriteBackSplitter_1;
wire [73:0] w_dataUpdateToWriteBackSplitter_74;
wire w_writeBackSplitterToDataUpdate_1;
wire w_dataUpdateToDataRout_1;
wire [31:0] w_dataUpdateToDataRoutAddr_32;
wire [63:0] w_dataUpdateToDataRoutData_64;
wire [7:0] w_dataUpdateToDataRoutWen_8;
wire w_dataRoutToDataUpdate_1;
//12/16 zwm due to peripheral not need judge the address whether misaligned ,so we should first distinct the addr from peripheral or from normal addr,add a flag to know the addr come from what
(* dont_touch="true" *)dataUpdate dataUpdate(
.rst(rst),
.i_addrFromPeripheralFlag_1(w_addrFromPeripheralFlag_1),
.i_lsuToDataUpdate_1(w_updateSplitterToDataUpdate_1),
.i_store_1(w_store_1),
.i_load_1(w_load_1),
.i_loadSign_1(w_loadSign_1),
.i_memAddr_32(w_address_32),
//��dataroutȡ��������
.i_memData_64(w_lsuMutexMergeToUpdateSplitterData_76[75:12]),
.i_dHi_4(w_dHi_4),
.i_dLo_4(w_dLo_4),
.i_storeData_64(w_LASMutexMergeToLsuMutexMergeTmp_64),
.i_lsuType_2(w_lsuType_2),
.i_stateValid_12(w_lsuMutexMergeToUpdateSplitterData_76[11:0]),
.i_misaligned_1(w_misaligned_1),
.i_writebackFreeToDataUpate_1(w_writeBackSplitterToDataUpdate_1),
.i_dataRoutFreeToDataUpate_1(w_dataRoutToDataUpdate_1),
.o_dataUpdateToLsu_1(w_dataUpdateToUpdateSplitter_1),
.o_dataUpdateDriveToWriteback_1(w_dataUpdateToWriteBackSplitter_1),
.o_dataUpdateToWritebackData_74(w_dataUpdateToWriteBackSplitter_74),
.o_dataUpdateDriveToMem_1(w_dataUpdateToDataRout_1),
.o_memAddr_32(w_dataUpdateToDataRoutAddr_32),
.o_memData_64(w_dataUpdateToDataRoutData_64),
.o_memWen_8(w_dataUpdateToDataRoutWen_8)
);
//writebackSplitter
//11/19 zwm only load need go to wback,but load now don't need go to launch
// wire w_writebackSplitterToLaunchMutexMerge_1;
// wire w_launchMutexMergeToWriteBackSplitter_1;
// wire w_writeBackSplitterToWriteBackMutexMerge_1;
// wire w_writeBackMutexMergeToWriteBackSplitter_1;
// wire [63:0] w_writebackSplitterToLaunchMutexMergeData_64;
// wire [73:0] w_writeBackSplitterToWriteBackMutexMergeData_74;
// (* dont_touch="true" *)cSplitter2_74_64_74b_lsu writebackSplitter(
// .i_drive(w_dataUpdateToWriteBackSplitter_1), .i_data_74(w_dataUpdateToWriteBackSplitter_74), .o_free(w_writeBackSplitterToDataUpdate_1),
// .o_driveNext0(w_writebackSplitterToLaunchMutexMerge_1), .i_freeNext0(w_launchMutexMergeToWriteBackSplitter_1), .o_data0_64(w_writebackSplitterToLaunchMutexMergeData_64),
// .o_driveNext1(w_writeBackSplitterToWriteBackMutexMerge_1), .o_data1_74(w_writeBackSplitterToWriteBackMutexMergeData_74), .i_freeNext1(w_writeBackMutexMergeToWriteBackSplitter_1),
// .rst(rst)
// );

//������·
//11/8 zwm->store also need give bypath to launch
//11/19 zwm only load need go to wback,but load now don't need go to launch,so launchMutexMerge only has two path
wire w_updateFinalSelectorToLaunchMutexMerge_1;
wire w_launchMutexMergeToUpdateFinalSelector_1;
wire [75:0] w_updateFinalSelectorData_76;
(* dont_touch="true" *)cMutexMerge2_64b_lsu launchMutexMerge(
.i_drive0(w_bitOpSelectorDrv2LaunchMutexMerge_1), .i_data0_64(w_data_64), .o_free0(w_bitOpSelctorFreeFLaunchMutexMerge_1),
.i_drive1(w_updateFinalSelectorToLaunchMutexMerge_1), .i_data1_64(w_updateFinalSelectorData_76[63:0]), .o_free1(w_launchMutexMergeToUpdateFinalSelector_1),
// .i_drive2(w_updateFinalSelectorToLaunchMutexMerge_1), .i_data2_64(w_updateFinalSelectorData_76[63:0]), .o_free2(w_launchMutexMergeToUpdateFinalSelector_1),
.i_freeNext(i_lsuFreeFromLaunch_1), .o_driveNext(o_lsuDriveToLaunch_1), .o_data_64(o_lsuToLaunchData_64),
.rst(rst)   
);

// //��д��
// wire w_writeBackMutexMergeToWriteBack_1;
// wire w_writebackToWriteBackMutexMerge_1;
// wire [73:0] w_writeBackMutexMergeToWriteBackData_74;
// (* dont_touch="true" *)cMutexMerge2_74b_lsu writeBackMutexMerge(
// .i_drive0(w_noLsSplitterToWriteBackMutexMerge_1), .i_data0_74({w_dHi_4,w_dLo_4,w_data_64[31:0],w_data_64[63:32],i_wen_2}), .o_free0(w_writeBackMuetxMergeToNoLsSplitter_1),
// .i_drive1(w_writeBackSplitterToWriteBackMutexMerge_1), .i_data1_74(w_writeBackSplitterToWriteBackMutexMergeData_74), .o_free1(w_writeBackMutexMergeToWriteBackSplitter_1),
// .i_freeNext(w_writebackToWriteBackMutexMerge_1), .o_driveNext(w_writeBackMutexMergeToWriteBack_1), .o_data_74(w_writeBackMutexMergeToWriteBackData_74),
// .rst(rst)   
// );

//stateUpdateSelector(��ʱ�ж�load�Ƿ���Խ���?????????)
//ͨ��load�Ƿ�ص�idle״̬�ж�
wire w_stateUpdateSelectorOver_1;
wire [11:0] w_stateUpdateSelectorDataOver_12,w_stateUpdateSelectorData_12;
wire w_stateUpdateSelectorToUpdateWaitMerge_1;
wire w_updateWaitMergeToStateUpdateSelector_1;
wire w_stateUpdateSelectorOver1_1;
//11/15 zwm need delay
(* dont_touch="true" *)wire w_stateUpdateToStateUpdateSelectorDelay_1;
delay8U outdelay7(.inR(w_stateUpdateToStateUpdateSelector_1), .outR(w_stateUpdateToStateUpdateSelectorDelay_1),.rst(rst));
(* dont_touch="true" *)cSelector2_12b_lsu stateUpdateSelector(
    .i_drive(w_stateUpdateToStateUpdateSelectorDelay_1), 
    .i_data_12(w_stateValid_12), 
    .o_free(w_stateUpdateSelectorToStateUpdate_1),
    .o_driveNext0(w_stateUpdateSelectorOver_1), 
    .i_freeNext0(w_stateUpdateSelectorOver1_1), 
    .o_data0_12(w_stateUpdateSelectorDataOver_12),
    .o_driveNext1(w_stateUpdateSelectorToUpdateWaitMerge_1), 
    .o_data1_12(w_stateUpdateSelectorData_12), 
    .i_freeNext1(w_updateWaitMergeToStateUpdateSelector_1),
    .rst(rst)
);
delay4U outdelay8(.inR(w_stateUpdateSelectorOver_1), .outR(w_stateUpdateSelectorOver1_1),.rst(rst));
//updateWaitMerge
wire w_dataRoutToUpdateWaitMerge_1;
wire w_updateWaitMergeToDataRout_1;
wire [63:0] w_dataRoutToUpdateWaitMergeData_64;
wire w_updateWaitMergeToUpdateFinalSelector_1;
wire w_updateFinalSelectorToUpdateWaitMerge_1;
wire [75:0] w_updateWaitMergeToUpdateFinalSelectorData_76;
(* dont_touch="true" *)cWaitMerge2_76b_lsu updateWaitMerge(
    .i_drive0(w_stateUpdateSelectorToUpdateWaitMerge_1),
    .i_data0_12(w_stateUpdateSelectorData_12),
    .o_free0(w_updateWaitMergeToStateUpdateSelector_1),
    .i_drive1(w_dataRoutToUpdateWaitMerge_1),
    .i_data1_64(w_dataRoutToUpdateWaitMergeData_64),
    .o_free1(w_updateWaitMergeToDataRout_1),
    .rst(rst),
    .o_driveNext(w_updateWaitMergeToUpdateFinalSelector_1),
    .o_data_76(w_updateWaitMergeToUpdateFinalSelectorData_76),
    .i_freeNext(w_updateFinalSelectorToUpdateWaitMerge_1)   
);

//updateFinalSelector
//11/8 zwm->store also need give bypath to launch
(* dont_touch="true" *)cSelector2_76b_lsu updateFinalSelector(
    .i_drive(w_updateWaitMergeToUpdateFinalSelector_1), 
    .i_data_76(w_updateWaitMergeToUpdateFinalSelectorData_76), 
    .o_free(w_updateFinalSelectorToUpdateWaitMerge_1),
    .o_driveNext0(w_updateFinalSelectorToLaunchMutexMerge_1), 
    .i_freeNext0(w_launchMutexMergeToUpdateFinalSelector_1), 
    .o_data0_76(w_updateFinalSelectorData_76),
    .o_driveNext1(w_updateFinalSelectorToLsuMutexMerge_1), 
    .o_data1_76(w_updateFinalSelectorToLsuMutexMergeData_76), 
    .i_freeNext1(w_lsuMutexMergeToUpdateFinalSelector_1),
    .rst(rst)
);


//��������дȥ�Ĳ��ִ���
//wbackMutexMerge
//12/12 zwm need to deal the data to wb

wire [73:0] w_lsuToWriteBackData_74;
wire [63:0] w_dataTmp_64;
wire w_lsuDriveToWriteBack_1;
assign w_dataTmp_64 = i_wen_2 == 2'b11 ? w_data_64 : {w_data_64[31:0],w_data_64[63:32]};
(* dont_touch="true" *)cMutexMerge3_74b_lsu wbackMutexMerge(
.i_drive0(w_noLsSplitterToWriteBackMutexMerge_1), .i_data0_74({w_dHi_4,w_dLo_4,w_dataTmp_64,i_wen_2}), .o_free0(w_writeBackMuetxMergeToNoLsSplitter_1),
.i_drive1(w_multiLoadSplitterToWback_1), .i_data1_74(w_multiLoadToWbackData_74), .o_free1(w_wbackToMultiLoadSplitter_1),
.i_drive2(w_dataUpdateToWriteBackSplitter_1), .i_data2_74(w_dataUpdateToWriteBackSplitter_74), .o_free2(w_writeBackSplitterToDataUpdate_1),
.i_freeNext(i_lsuFreeFromWriteBack_1), .o_driveNext(w_lsuDriveToWriteBack_1), .o_data_74(w_lsuToWriteBackData_74),
.rst(rst)   
);

//3/11 zwm

reg [73:0] r_lsuToWriteBackData_74;
delay8U outdelay17(.inR(w_lsuDriveToWriteBack_1), .outR(o_lsuDriveToWriteBack_1),.rst(rst));
always @(posedge o_lsuDriveToWriteBack_1 or negedge rst) begin
    if(!rst)begin
        r_lsuToWriteBackData_74 <= 74'b0;
    end else begin
        r_lsuToWriteBackData_74 <= w_lsuToWriteBackData_74;
    end
end
assign o_lsuToWriteBackData_103 = {w_dHi_4,w_dLo_4,r_lsuToWriteBackData_74,w_S_1,w_writeBackIdentifyData_15,w_nzcv_4,w_writeRd_1};
//������dataRoutȥ�Ĳ��ִ���
//dataRoutMutexMerge
reg [31:0] r_storeAddress_32;
wire [31:0] w_storeAddressCurrent_32;
wire w_dataRoutMutexMergeDriveToIcacheSelector_1,w_dataRoutMutexMergeFreeFromIcacheSelector_1;
wire [103:0] w_lsuToDataRoutData_104;
always @(posedge w_multiStoreMutexMergeToMultiStoreFifoDelay1_1 or negedge rst) begin
    if(!rst)begin
        r_storeAddress_32 <= 32'b0;
    end else begin
        r_storeAddress_32 <= w_storeAddress_32;
    end
end
assign w_storeAddressCurrent_32 = r_storeAddress_32;
(* dont_touch="true" *)cMutexMerge3_104b_lsu dataRoutMutexMerge(
.i_drive0(w_dataUpdateToDataRout_1), .i_data0_104({w_dataUpdateToDataRoutAddr_32,w_dataUpdateToDataRoutData_64,w_dataUpdateToDataRoutWen_8}), .o_free0(w_dataRoutToDataUpdate_1),
.i_drive1(w_multiLoadSelectorToDataRout_1), .i_data1_104({w_loadAddress_32,{64{1'b0}},{8{1'b0}}}), .o_free1(w_dataRoutToMultiLoadSelector_1),
.i_drive2(w_grfSelectorToMultiStoreDataUpdateDataRout_1), .i_data2_104({w_storeAddressCurrent_32,w_grfSelectorToMultiStoreDataUpdateData_64,w_multiStoreDataUpateToDataRoutWen_8}), .o_free2(w_multiStoreDataUdpateDataRoutToGrfSelector_1),
.i_freeNext(w_dataRoutMutexMergeFreeFromIcacheSelector_1), .o_driveNext(w_dataRoutMutexMergeDriveToIcacheSelector_1), .o_data_104(w_lsuToDataRoutData_104),
.rst(rst)   
);
//-----------------------------------------------big change--------------------------------------//
//12/24 zwm
//need a selector to distinct read address to icache or to dcache
wire w_icacheFlag_1;
assign w_icacheFlag_1 = (w_lsuToDataRoutData_104[103:72]>=32'h01200 && w_lsuToDataRoutData_104[103:72]<=32'h211ff) ? 1'b1 : 1'b0;
wire w_dataRoutMutexMergeDriveToIcacheSelector1_1;
delay8U outdelay9(.inR(w_dataRoutMutexMergeDriveToIcacheSelector_1), .outR(w_dataRoutMutexMergeDriveToIcacheSelector1_1),.rst(rst));
cSelector2_105b_lsu IcacheSelector(
    .i_drive(w_dataRoutMutexMergeDriveToIcacheSelector1_1), 
    .i_data_105({w_lsuToDataRoutData_104,w_icacheFlag_1}), 
    .o_free(w_dataRoutMutexMergeFreeFromIcacheSelector_1),
    .o_driveNext0(o_lsuDriveToDataRout_1), 
    .i_freeNext0(i_lsuFreeFromDataRout_1), 
    .o_data0_104(o_lsuToDataRoutData_104),
    .o_driveNext1(o_lsuDriveToIcache_1), 
    .o_data1_104(o_lsuToIcacheData_104), 
    .i_freeNext1(i_lsuFreeFromIcache_1),
    .rst(rst)
);
wire w_icacheOrDataRoutMutexMergeDriveToLsu_1,w_lsuFreeToIcacheOrDataRoutMutexMerge_1;
wire [63:0] w_memData_64;
cMutexMerge2_64b_lsu icacheOrDataRoutMutexMerge(
    .i_drive0(i_dataRoutDriveToLsu_1), .i_data0_64(i_memData_64), .o_free0(o_lsuFreeToDataRout_1),
    .i_drive1(i_icacheDriveToLsu_1), .i_data1_64(i_icacheData_64), .o_free1(o_lsuFreeToIcache_1),
    // .i_drive2(w_updateFinalSelectorToLaunchMutexMerge_1), .i_data2_64(w_updateFinalSelectorData_76[63:0]), .o_free2(w_launchMutexMergeToUpdateFinalSelector_1),
    .i_freeNext(w_lsuFreeToIcacheOrDataRoutMutexMerge_1), .o_driveNext(w_icacheOrDataRoutMutexMergeDriveToLsu_1), .o_data_64(w_memData_64),
    .rst(rst)  
);
wire w_icacheOrDataRoutMutexMergeDriveToLsu1_1;
delay8U outdelay10(.inR(w_icacheOrDataRoutMutexMergeDriveToLsu_1), .outR(w_icacheOrDataRoutMutexMergeDriveToLsu1_1),.rst(rst));
//-----------------------------------------change end-------------------------------------------//


//dataRoutSelector
wire [63:0] w_dataRoutSelectorData_64;
(* dont_touch="true" *)cSelector3_66b_lsu dataRoutSelector(
    .i_drive(w_icacheOrDataRoutMutexMergeDriveToLsu1_1), 
    .i_data_66({w_memData_64,w_store_1,w_isMultiLS_1}), 
    .o_free(w_lsuFreeToIcacheOrDataRoutMutexMerge_1),
    .o_driveNext0(w_dataRoutToMultiLoadDataUpdate_1), 
    .i_freeNext0(w_multiLoadDataUpdateToDataRout_1), 
    .o_data0_64(w_dataRoutToMultiLoadDataUpdataData_64),
    .o_driveNext1(w_dataRoutToUpdateWaitMerge_1), 
    .o_data1_64(w_dataRoutToUpdateWaitMergeData_64), 
    .i_freeNext1(w_updateWaitMergeToDataRout_1),
    .o_driveNext2(w_dataRoutToMultiStoreSelector_1), 
    .o_data2_64(w_dataRoutSelectorData_64), 
    .i_freeNext2(w_multiStoreSelectorToDataRout_1),
    .rst(rst)
);

//�쳣����
//������
assign o_exception_36 = {w_currentPc_32,4'b1111};


//11/4 zwm->���ַô������־�?
//11/30 zwm should let load drive delay
wire w_multiLoadSelectorOver1_1;
(* dont_touch="true" *)delay8U multiLoadDelay0(.inR(w_multiLoadSelectorOver_1),.outR(w_multiLoadSelectorOver1_1),.rst(rst));
assign o_endFlag_1 = w_endLoadFlag_1 | w_endStoreFlag_1;
assign o_multiLoadOrStoreOver = w_multiLoadSelectorOver1_1 | w_multiStoreSelectorOver_1;

//11/8 zwm->lsu must over can give exe free
//3/4 zwm->change i_lsuFreeFromLaunch_1 to i_lsuFreeFromLaunch_1
assign o_lsuFreeToExe_1 = i_lsuFreeFromLaunch_1 | o_multiLoadOrStoreOver | w_stateUpdateSelectorOver_1 | w_bitOpSelectorOver_1;

//11/19 zwm add load end over flag
assign o_loadEndFlag = w_stateValid_12[11];
//11/30 zwm should let load drive delay
wire w_loadOver_1;
(* dont_touch="true" *)delay8U loadDelay0(.inR(w_stateUpdateSelectorOver_1),.outR(w_loadOver_1),.rst(rst));
assign o_loadEndDrive = w_loadOver_1;




//1/4 zwm
//need a contap 
contTap executeTap(
    .trig(i_exeDriveToLsu_1 | i_lsuFreeFromExcp_1),
    .req(o_lsuInUseFlag_1),
    .rst(rst)
    );


endmodule
