`timescale 1ns / 1ps
//===============================================================================
// Project:        
// Module:         Fetch_Logic
// version:        1st version (2025-11-11)
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/11/11
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    取指逻辑模块
//===============================================================================


(* dont_touch="true" *)module Fetch_Logic (
input         rst,
input         i_driveMutexToLogic,
input [80:0]  i_dataMutexToLogic_81,
output        o_freeLogicToMutex,

output        o_driveFromCPUtoIcache,
output[135:0] o_dataCPUtoIcache_136,
input         i_freeFromIcachetoCPU,

input         i_driveFromIcachetoCPU,
input [255:0] i_dataIcachetoCPU_256,
output        o_freeFromCPUtoIcache,

output        o_driveFromLogictoMutex, //告诉TPU接口可以发新的一批指令
inout         i_freeFromMutextoLogic,

output        o_drivetoReg,
output[79:0]  o_datatoReg_80,
input         i_freefromReg,

output        o_driveLogicToSel,
output[209:0] o_dataLogicToSel_210,
input         i_freeSelToLogic
);

(* dont_touch="true" *)wire w_fire_reg;
(* dont_touch="true" *)wire w_driveFifoToSel;
(* dont_touch="true" *)wire w_freeSelToFifo;
(* dont_touch="true" *)wire w_valid1;
(* dont_touch="true" *)wire w_valid0;
(* dont_touch="true" *)wire w_driveSelToNat;
(* dont_touch="true" *)wire w_driveSelToTPU;
(* dont_touch="true" *)wire w_freeNatToSel;
(* dont_touch="true" *)wire w_freeSelToSel_delay;

(* dont_touch="true" *)reg [80:0] r_dataFromTPU_81;

(* dont_touch="true" *)wire w_freeFromWaitToNat;
(* dont_touch="true" *)wire w_driveFromNatToWait;
(* dont_touch="true" *)wire [79:0]w_dataNatToWait_80;

(* dont_touch="true" *)wire w_driveFromWaitToSel;
(* dont_touch="true" *)wire w_freeFromSelToWait;

(* dont_touch="true" *)wire w_type_1;  //1'b1表示矩阵扩展指令；1'b0表示处理器指令
(* dont_touch="true" *)wire w_yasuo_1; //1'b1表示是压缩指令；1'b0表示是非压缩指令
(* dont_touch="true" *)wire w_valid_0;
(* dont_touch="true" *)wire w_valid_1;
(* dont_touch="true" *)wire w_valid_2 ;

(* dont_touch="true" *)wire w_freeFromMutexToSel0;
(* dont_touch="true" *)wire w_freeFromMutexToSel1;
(* dont_touch="true" *)wire w_freeFromMutexToSel2;
(* dont_touch="true" *)wire w_driveFromSelToMutex0;
(* dont_touch="true" *)wire w_driveFromSelToMutex1;
(* dont_touch="true" *)wire w_driveFromSelToMutex2;

(* dont_touch="true" *)wire [15:0]w_amount_16;
(* dont_touch="true" *)wire [63:0]w_originPC0_64;
(* dont_touch="true" *)wire [63:0]w_originPC1_64;
(* dont_touch="true" *)wire [63:0]w_originPC2_64;
(* dont_touch="true" *)wire [127:0]w_TPUInstruction_128;
(* dont_touch="true" *)wire [31:0]w_RVInstruction_32;
(* dont_touch="true" *)wire [209:0]w_datavalid0_210;
(* dont_touch="true" *)wire [209:0]w_datavalid1_210;
(* dont_touch="true" *)wire [209:0]w_datavalid2_210;

(* dont_touch="true" *)wire w_freeFromNatToMutex;
(* dont_touch="true" *)wire w_driveFromMutexToNat;
(* dont_touch="true" *)wire [209:0]w_dataMutexToNat_210;

(* dont_touch="true" *)wire [335:0]w_dataFromWait_336;

(* dont_touch="true" *)wire w_driveFifoToSel_dealy;
(* dont_touch="true" *)wire w_driveFromWaitToSel_dealy;

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu(
.i_drive(i_driveMutexToLogic),
.o_free(o_freeLogicToMutex),
.o_driveNext(w_driveFifoToSel),
.i_freeNext(w_freeSelToFifo),
.o_fire(w_fire_reg),
.rst(rst)
);

always @(posedge w_fire_reg or negedge rst) begin
if(!rst) begin
        r_dataFromTPU_81  <= 81'b0;
    end
    else begin
        r_dataFromTPU_81  <= i_dataMutexToLogic_81;
    end
end

(* dont_touch="true" *)assign w_valid0 = (r_dataFromTPU_81[79:64] == 16'b0) ? 1'b0 : 1'b1;  //指令不是0条，则第0路判断条件为1，走第0路
(* dont_touch="true" *)assign w_valid1 = ~w_valid0;
(* dont_touch="true" *)delay_free_cpu #(30)  delay_free_cpu_sel1(
     .inR(w_driveFifoToSel), 
     .outR(w_driveFifoToSel_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch_1(
.i_drive(w_driveFifoToSel_dealy),
.i_freeNext0(w_freeNatToSel),
.i_freeNext1(i_freeFromMutextoLogic),
.valid0(w_valid0),
.valid1(w_valid1),
.o_free(w_freeSelToFifo),
.o_driveNext0(w_driveSelToNat),
.o_driveNext1(o_driveFromLogictoMutex),
.rst(rst)
);

(* dont_touch="true" *)cNatSplit_2_fetch cNatSplit_2_fetch(
.i_drive(w_driveSelToNat),
.i_freeNext0(i_freeFromIcachetoCPU),
.i_freeNext1(w_freeFromWaitToNat),
.o_free(w_freeNatToSel),
.o_driveNext0(o_driveFromCPUtoIcache),
.o_driveNext1(w_driveFromNatToWait),
.rst(rst)
);

(* dont_touch="true" *)assign o_dataCPUtoIcache_136 = {8'b0, r_dataFromTPU_81[63:0], 64'b0};
(* dont_touch="true" *)assign w_dataNatToWait_80 = r_dataFromTPU_81[79:0];

(* dont_touch="true" *)cWaitMerge_2_d_fetch cWaitMerge_2_d_fetch(
.i_drive0(i_driveFromIcachetoCPU),
.o_free0(o_freeFromCPUtoIcache),
.i_data0(i_dataIcachetoCPU_256),  //256bit
.i_drive1(w_driveFromNatToWait),
.o_free1(w_freeFromWaitToNat),
.i_data1(w_dataNatToWait_80),  //80bit
.o_driveNext(w_driveFromWaitToSel),
.i_freeNext(w_freeFromSelToWait),
.o_data(w_dataFromWait_336),  //{i_data1,i_data0}  80,256  [335:320] [319:256] [255:0]
.rst(rst)
);

(* dont_touch="true" *)assign w_type_1 = (w_TPUInstruction_128[7:0] == 8'b00001000);

(* dont_touch="true" *)assign w_yasuo_1 = (w_TPUInstruction_128[1:0] != 2'b11) | (w_RVInstruction_32[1:0] != 2'b11);

(* dont_touch="true" *)assign w_valid_0 = w_type_1;
(* dont_touch="true" *)assign w_valid_1 = (~w_type_1) & (~w_yasuo_1);
(* dont_touch="true" *)assign w_valid_2 = (~w_type_1) & w_yasuo_1;

(* dont_touch="true" *)delay6U  delay_free_cpu_sel2(
     .inR(w_driveFromWaitToSel), 
     .outR(w_driveFromWaitToSel_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)cSelSplit_3_fetch cSelSplit_3_fetch(
.i_drive(w_driveFromWaitToSel_dealy),
.i_freeNext0(w_freeFromMutexToSel0),
.i_freeNext1(w_freeFromMutexToSel1),
.i_freeNext2(w_freeFromMutexToSel2),
.valid0(w_valid_0),
.valid1(w_valid_1),
.valid2(w_valid_2),
.o_free(w_freeFromSelToWait),
.o_driveNext0(w_driveFromSelToMutex0),
.o_driveNext1(w_driveFromSelToMutex1),
.o_driveNext2(w_driveFromSelToMutex2),
.rst(rst)
);

(* dont_touch="true" *)assign w_amount_16 = 16'b0 ? 16'b0 : w_dataFromWait_336[335:320] - 16'b1;
(* dont_touch="true" *)assign w_originPC0_64 = w_dataFromWait_336[319:256] + 16;
//(* dont_touch="true" *)assign w_originPC1_64 = w_dataFromWait_336[319:256] + 4;
//(* dont_touch="true" *)assign w_originPC2_64 = w_dataFromWait_336[319:256] + 2;
(* dont_touch="true" *)assign w_originPC1_64 = w_dataFromWait_336[319:256] ;
(* dont_touch="true" *)assign w_originPC2_64 = w_dataFromWait_336[319:256] ;
//(* dont_touch="true" *)assign w_TPUInstruction_128 = w_dataFromWait_336[(w_dataFromWait_336[260:256]+16)*8-1:(w_dataFromWait_336[260:256])*8];
(* dont_touch="true" *)assign w_TPUInstruction_128 = w_dataFromWait_336[w_dataFromWait_336[260:256] * 8 +: 128];
//(* dont_touch="true" *)assign w_RVInstruction_32 = w_dataFromWait_336[(w_dataFromWait_336[260:256]+4)*8-1:(w_dataFromWait_336[260:256])*8];
(* dont_touch="true" *)assign w_RVInstruction_32 = w_dataFromWait_336[w_dataFromWait_336[260:256] * 8 +: 32];
(* dont_touch="true" *)assign w_datavalid0_210 = {w_type_1,w_yasuo_1,w_amount_16,w_originPC0_64,w_TPUInstruction_128} ;   //2+80+128;更新之后的条数和pc;对于处理器指令来说，32bit指令放在w_datavalid0_208[31:0]
(* dont_touch="true" *)assign w_datavalid1_210 = {w_type_1,w_yasuo_1,w_amount_16,w_originPC1_64,96'b0,w_RVInstruction_32} ;
(* dont_touch="true" *)assign w_datavalid2_210 = {w_type_1,w_yasuo_1,w_amount_16,w_originPC2_64,96'b0,w_RVInstruction_32} ;

(* dont_touch="true" *)cMutexMerge_3_df_fetch cMutexMerge_3_df_fetch(
.i_drive0(w_driveFromSelToMutex0), 
.i_drive1(w_driveFromSelToMutex1), 
.i_drive2(w_driveFromSelToMutex2),
.i_data0(w_datavalid0_210),  
.i_data1(w_datavalid1_210),  
.i_data2(w_datavalid2_210),
.i_freeNext(w_freeFromNatToMutex),
.o_free0(w_freeFromMutexToSel0), 
.o_free1(w_freeFromMutexToSel1), 
.o_free2(w_freeFromMutexToSel2),
.o_driveNext(w_driveFromMutexToNat),
.o_data(w_dataMutexToNat_210),
.rst(rst)
);

(* dont_touch="true" *)cNatSplit_2_fetch cNatSplit_2_fetch_2(
.i_drive(w_driveFromMutexToNat),
.i_freeNext0(i_freefromReg), 
.i_freeNext1(i_freeSelToLogic), 
.o_free(w_freeFromNatToMutex),
.o_driveNext0(o_drivetoReg), 
.o_driveNext1(o_driveLogicToSel), 
.rst(rst)
);
(* dont_touch="true" *)assign o_datatoReg_80 = w_dataMutexToNat_210[207:128];
(* dont_touch="true" *)assign o_dataLogicToSel_210 = w_dataMutexToNat_210;


endmodule