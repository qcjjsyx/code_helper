`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         Fetch_top
// version:        1st version (2025-11-11)
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/11/11
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    取指模块
//===============================================================================


(* dont_touch="true" *)module Fetch_top (

(* dont_touch="true" *)input         rst,
(* dont_touch="true" *)input         switch,

(* dont_touch="true" *)input         i_driveFromTPUtoCPU, //TPU读写接口的输入
(* dont_touch="true" *)input [79:0]  i_dataTPUtoCPU_80,
(* dont_touch="true" *)output        o_freeFromCPUtoTPU,

(* dont_touch="true" *)output        o_driveFromCPUtoTPU, //输出给TPU读写接口
(* dont_touch="true" *)input         i_freeFromTPUtoCPU,

(* dont_touch="true" *)input         i_driveFromEXCPtoCPU, //中断异常的交互
(* dont_touch="true" *)input [63:0]  i_dataFromEXCPtoCPU_64,
(* dont_touch="true" *)output        o_freeFromCPUtoEXCP,

(* dont_touch="true" *)input         i_driveFromWBtoCPU, //出局模块的交互
(* dont_touch="true" *)input [63:0]  i_dataFromWBtoCPU_64,
(* dont_touch="true" *)output        o_freeFromCPUtoWB,

(* dont_touch="true" *)output        o_driveFromCPUtoIcache, //Icache的交互
(* dont_touch="true" *)output[135:0] o_dataCPUtoIcache_136,
(* dont_touch="true" *)input         i_freeFromIcachetoCPU,

(* dont_touch="true" *)input         i_driveFromIcachetoCPU,
(* dont_touch="true" *)input [255:0] i_dataIcachetoCPU_256,
(* dont_touch="true" *)output        o_freeFromCPUtoIcache,

(* dont_touch="true" *)output        o_driveFromCPUtoTS, //任务调度单元的交互   TASK SCHEDULING
(* dont_touch="true" *)output[127:0] o_dataCPUtoTS_128,
(* dont_touch="true" *)input         i_freeFromTStoCPU,

(* dont_touch="true" *)input         i_driveFromTStoCPU,
(* dont_touch="true" *)output        o_freeFromCPUtoTS,

(* dont_touch="true" *)output        o_driveFromFetchtoDecoder, //与译码模块交互
(* dont_touch="true" *)output[96:0]  o_dataFetchtoDecoder_97, //指令地址加指令内容
(* dont_touch="true" *)input         i_freeFromDecodertoFetch
);

(* dont_touch="true" *)wire w_fire_reg;
(* dont_touch="true" *) reg [79:0] r_dataFromTPU_80;
(* dont_touch="true" *)wire w_nofree;

(* dont_touch="true" *)wire w_driveSwitchToMutex;
(* dont_touch="true" *)wire w_driveFifoToMutex;

(* dont_touch="true" *)wire w_freeMutexToSwitch; 
(* dont_touch="true" *)wire w_freeMutexToFifo;
(* dont_touch="true" *)wire w_freeMutexToTS;

(* dont_touch="true" *)wire w_freeLogicToMutex;
(* dont_touch="true" *)wire w_driveMutexToLogic;
(* dont_touch="true" *)wire [80:0]w_dataMutexToLogic_81;

(* dont_touch="true" *)wire w_drivetoReg;
(* dont_touch="true" *)wire [79:0]w_datatoReg_80;
(* dont_touch="true" *)wire w_freefromReg;
(* dont_touch="true" *)wire w_driveLogicToSel;
(* dont_touch="true" *)wire [209:0]w_dataLogicToSel_210;
(* dont_touch="true" *)wire w_freeSelToLogic;

(* dont_touch="true" *)wire w_driveFromFifoToSink;
(* dont_touch="true" *)wire w_freeFromSinkToFifo;
(* dont_touch="true" *)wire w_fire_updatereg;
(* dont_touch="true" *)reg  [79:0] r_dataFromLogic_80;

(* dont_touch="true" *)wire [79:0] w_finalreg_80;
(* dont_touch="true" *)wire [79:0] w_reg_80;

(* dont_touch="true" *)wire [63:0] w_dataFromWBtoCPU_64;

(* dont_touch="true" *)wire w_valid0_TS;
(* dont_touch="true" *)wire w_valid1_Decoder;

(* dont_touch="true" *)wire w_freeFromSinkToSel;

(* dont_touch="true" *)wire w_fire_reg_dealy;
(* dont_touch="true" *)wire w_fire_updatereg_dealy;
(* dont_touch="true" *)wire w_driveLogicToSel_dealy;

(* dont_touch="true" *)wire w_driveFromFifo2ToFifo3;
(* dont_touch="true" *)wire w_freeFromFifo3ToFifo2;
(* dont_touch="true" *)wire w_fire_finalreg;
(* dont_touch="true" *)reg [79:0]r_datafinal_80;

(* dont_touch="true" *)wire w_driveFromLogictoMutex;
(* dont_touch="true" *)wire w_freeFromMutextoLogic;


/*(* dont_touch="true" *)eventSource_cpu eventSource(
.switch(switch),
.fire(w_driveSwitchToMutex),
.rst(rst)
);*/

(* dont_touch="true" *)cMutexMerge_2_WB cMutexMerge_2_WB(
.i_drive0(switch),
.o_free0(w_nofree), 
.i_drive1(w_driveFromLogictoMutex),
.o_free1(w_freeFromMutextoLogic),
.o_driveNext(o_driveFromCPUtoTPU),
.i_freeNext(i_freeFromTPUtoCPU),
.rst(rst)
);

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_1(
.i_drive(i_driveFromTPUtoCPU),
.o_free(o_freeFromCPUtoTPU),
.o_driveNext(w_driveFifoToMutex),
.i_freeNext(w_freeMutexToFifo),
.o_fire(w_fire_reg),
.rst(rst)
);

always @(posedge w_fire_reg or negedge rst) begin
if(!rst) begin
        r_dataFromTPU_80  <= 80'b0;
    end
    else begin
        r_dataFromTPU_80  <= i_dataTPUtoCPU_80;
    end
end

/*(* dont_touch="true" *)cMutexMerge_5_df_fetch cMutexMerge_5_df_fetch(
.i_drive0(w_driveSwitchToMutex), 
.i_drive1(i_driveFromEXCPtoCPU), 
.i_drive2(w_driveFifoToMutex),
.i_drive3(i_driveFromWBtoCPU),
.i_drive4(i_driveFromTStoCPU),
.i_data0(81'b0),  
.i_data1({1'b1,16'b0,i_dataFromEXCPtoCPU_64}),//用于标识中断异常，后续选择PC来源 
.i_data2({1'b0,r_dataFromTPU_80}),
.i_data3({1'b0,w_finalreg_80[79:64],w_dataFromWBtoCPU_64}),//出局带来的PC
.i_data4({1'b0,w_finalreg_80}),
.i_freeNext(w_freeLogicToMutex),
.o_free0(w_freeMutexToSwitch), 
.o_free1(o_freeFromCPUtoEXCP), 
.o_free2(w_freeMutexToFifo),
.o_free3(o_freeFromCPUtoWB),
.o_free4(o_freeFromCPUtoTS),
.o_driveNext(w_driveMutexToLogic),
.o_data(w_dataMutexToLogic_81),
.rst(rst)
);*/
(* dont_touch="true" *)cMutexMerge_4_d_fetch cMutexMerge_4_d_fetch(
.i_drive0(i_driveFromEXCPtoCPU), 
.i_drive1(w_driveFifoToMutex),
.i_drive2(i_driveFromWBtoCPU),
.i_drive3(i_driveFromTStoCPU), 
.i_data0({1'b1,16'b0,i_dataFromEXCPtoCPU_64}),//用于标识中断异常，后续选择PC来源 
.i_data1({1'b0,r_dataFromTPU_80}),
.i_data2({1'b0,w_finalreg_80[79:64],w_dataFromWBtoCPU_64}),//出局带来的PC
.i_data3({1'b0,w_finalreg_80}),
.i_freeNext(w_freeLogicToMutex),
.o_free0(o_freeFromCPUtoEXCP), 
.o_free1(w_freeMutexToFifo),
.o_free2(o_freeFromCPUtoWB),
.o_free3(o_freeFromCPUtoTS),
.o_driveNext(w_driveMutexToLogic),
.o_data(w_dataMutexToLogic_81),
.rst(rst)
);

(* dont_touch="true" *)Fetch_Logic Fetch_Logic(
.i_driveMutexToLogic(w_driveMutexToLogic),
.i_dataMutexToLogic_81(w_dataMutexToLogic_81),
.o_freeLogicToMutex(w_freeLogicToMutex),

.o_driveFromCPUtoIcache(o_driveFromCPUtoIcache),
.o_dataCPUtoIcache_136(o_dataCPUtoIcache_136),
.i_freeFromIcachetoCPU(i_freeFromIcachetoCPU),

.i_driveFromIcachetoCPU(i_driveFromIcachetoCPU),
.i_dataIcachetoCPU_256(i_dataIcachetoCPU_256),
.o_freeFromCPUtoIcache(o_freeFromCPUtoIcache),

.o_driveFromLogictoMutex(w_driveFromLogictoMutex),
.i_freeFromMutextoLogic(w_freeFromMutextoLogic),

.o_drivetoReg(w_drivetoReg),
.o_datatoReg_80(w_datatoReg_80),
.i_freefromReg(w_freefromReg),

.o_driveLogicToSel(w_driveLogicTofifo3),
.o_dataLogicToSel_210(w_dataLogicToSel_210),  //2+80+128
.i_freeSelToLogic(w_freefifo3ToLogic),
.rst(rst)
);

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_2(
.i_drive(w_drivetoReg),
.o_free(w_freefromReg),
.o_driveNext(w_driveFromFifoToSink),
.i_freeNext(w_freeFromSinkToFifo),
.o_fire(w_fire_updatereg),
.rst(rst)
);
always @(posedge w_fire_updatereg or negedge rst) begin
if(!rst) begin
        r_dataFromLogic_80  <= 80'b0;
    end
    else begin
        r_dataFromLogic_80  <= w_datatoReg_80;
    end
end

(* dont_touch="true" *)eventSink_cpu eventSink_cpu_1(
.i_drive(w_driveFromFifoToSink),
.o_free(w_freeFromSinkToFifo),
.rst(rst)
);

(* dont_touch="true" *)wire w_driveLogicTofifo3;
(* dont_touch="true" *)wire w_freefifo3ToLogic;
(* dont_touch="true" *)wire w_fire_dataLogic;
reg [209:0]r_dataLogic_210;
/*(* dont_touch="true" *)delay6U  delay_free_cpu_reg(
     .inR(w_fire_reg), 
     .outR(w_fire_reg_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)delay6U  delay_free_cpu_updatereg(
     .inR(w_fire_updatereg), 
     .outR(w_fire_updatereg_dealy), 
     .rst(rst)
);*/

//(* dont_touch="true" *)assign w_reg_80 = (r_dataFromTPU_80 & {80{w_fire_reg_dealy}})|(r_dataFromLogic_80 & {80{w_fire_updatereg_dealy}});
(* dont_touch="true" *)assign w_finalreg_80 =(r_dataFromLogic_80[63:0] > {{30{1'b0}}, 34'h1_ffff_ffff}) ? {r_dataFromLogic_80[79:64], 64'b0} : r_dataFromLogic_80; //判断到达Dcache基址之后跳回0地址
(* dont_touch="true" *)assign w_dataFromWBtoCPU_64 = (i_dataFromWBtoCPU_64 > {{30{1'b0}}, 34'h1_ffff_ffff}) ?  64'b0 : i_dataFromWBtoCPU_64;
////////////////////////////////////////////////////
(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_3(
.i_drive(w_driveLogicTofifo3),
.o_free(w_freefifo3ToLogic),
.o_driveNext(w_driveLogicToSel),
.i_freeNext(w_freeSelToLogic),
.o_fire(w_fire_dataLogic),
.rst(rst)
);
always @(posedge w_fire_dataLogic or negedge rst) begin
if(!rst) begin
        r_dataLogic_210  <= 210'b0;
    end
    else begin
        r_dataLogic_210  <= w_dataLogicToSel_210;
    end
end
////////////////////////////////////////////////////


(* dont_touch="true" *)delay_free_cpu #(6)  delay_free_cpu_sel(
     .inR(w_driveLogicToSel), 
     .outR(w_driveLogicToSel_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)assign w_valid0_TS = r_dataLogic_210[209];
(* dont_touch="true" *)assign w_valid1_Decoder = ~w_valid0_TS;
(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch(
.i_drive(w_driveLogicToSel_dealy),
.i_freeNext0(i_freeFromTStoCPU),
.i_freeNext1(i_freeFromDecodertoFetch),
.valid0(w_valid0_TS),
.valid1(w_valid1_Decoder),
.o_free(w_freeSelToLogic),
.o_driveNext0(o_driveFromCPUtoTS),
.o_driveNext1(o_driveFromFetchtoDecoder),
.rst(rst)
);

(* dont_touch="true" *)assign o_dataCPUtoTS_128 = r_dataLogic_210[127:0];
//是否压缩指令、指令地址及指令内容 1+64+32=97
(* dont_touch="true" *)assign o_dataFetchtoDecoder_97 = {r_dataLogic_210[209], r_dataLogic_210[191:128], r_dataLogic_210[31:0]};

endmodule