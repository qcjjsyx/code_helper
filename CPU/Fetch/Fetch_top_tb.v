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

module Fetch_top_tb;

reg         rst;
reg         switch;

reg         i_driveFromTPUtoCPU; //TPU读写接口的输入
reg [79:0]  i_dataTPUtoCPU_80;
wire        o_freeFromCPUtoTPU;

wire        o_driveFromCPUtoTPU; //输出给TPU读写接口
reg         i_freeFromTPUtoCPU;

reg         i_driveFromEXCPtoCPU; //中断异常的交互
reg [63:0]  i_dataFromEXCPtoCPU_64;
wire        o_freeFromCPUtoEXCP;

reg         i_driveFromWBtoCPU; //出局模块的交互
reg [63:0]  i_dataFromWBtoCPU_64;
wire        o_freeFromCPUtoWB;

wire        o_driveFromCPUtoIcache; //Icache的交互
wire[135:0] o_dataCPUtoIcache_136;
reg         i_freeFromIcachetoCPU;

reg         i_driveFromIcachetoCPU;
reg [255:0] i_dataIcachetoCPU_256;
wire        o_freeFromCPUtoIcache;

wire        o_driveFromCPUtoTS; //任务调度单元的交互   TASK SCHEDULING
wire[127:0] o_dataCPUtoTS_128;
reg         i_freeFromTStoCPU;

reg         i_driveFromTStoCPU;
wire        o_freeFromCPUtoTS;

wire        o_driveFromFetchtoDecoder;//与译码模块交互
wire[96:0]  o_dataFetchtoDecoder_97; //指令地址加指令内容
reg         i_freeFromDecodertoFetch;

Fetch_top dut(
.rst(rst),
.switch(switch),

.i_driveFromTPUtoCPU(i_driveFromTPUtoCPU),
.i_dataTPUtoCPU_80(i_dataTPUtoCPU_80),
.o_freeFromCPUtoTPU(o_freeFromCPUtoTPU),

.o_driveFromCPUtoTPU(o_driveFromCPUtoTPU), 
.i_freeFromTPUtoCPU(i_freeFromTPUtoCPU),

.i_driveFromEXCPtoCPU(i_driveFromEXCPtoCPU),
.i_dataFromEXCPtoCPU_64(i_dataFromEXCPtoCPU_64),
.o_freeFromCPUtoEXCP(o_freeFromCPUtoEXCP),

.i_driveFromWBtoCPU(i_driveFromWBtoCPU),
.i_dataFromWBtoCPU_64(i_dataFromWBtoCPU_64),
.o_freeFromCPUtoWB(o_freeFromCPUtoWB),

.o_driveFromCPUtoIcache(o_driveFromCPUtoIcache),
.o_dataCPUtoIcache_136(o_dataCPUtoIcache_136),
.i_freeFromIcachetoCPU(i_freeFromIcachetoCPU),

.i_driveFromIcachetoCPU(i_driveFromIcachetoCPU),
.i_dataIcachetoCPU_256(i_dataIcachetoCPU_256),
.o_freeFromCPUtoIcache(o_freeFromCPUtoIcache),

.o_driveFromCPUtoTS(o_driveFromCPUtoTS),
.o_dataCPUtoTS_128(o_dataCPUtoTS_128),
.i_freeFromTStoCPU(i_freeFromTStoCPU),

.i_driveFromTStoCPU(i_driveFromTStoCPU),
.o_freeFromCPUtoTS(o_freeFromCPUtoTS),

.o_driveFromFetchtoDecoder(o_driveFromFetchtoDecoder),
.o_dataFetchtoDecoder_97(o_dataFetchtoDecoder_97),
.i_freeFromDecodertoFetch(i_freeFromDecodertoFetch)
);

initial begin
rst = 1;
switch = 0;
i_driveFromTPUtoCPU = 0;
i_dataTPUtoCPU_80 = 0;
i_freeFromTPUtoCPU = 0;
i_driveFromEXCPtoCPU = 0;
i_dataFromEXCPtoCPU_64 = 0;
i_driveFromWBtoCPU = 0;
i_dataFromWBtoCPU_64 = 0;
i_freeFromIcachetoCPU = 0;
i_driveFromIcachetoCPU = 0;
i_dataIcachetoCPU_256 = 0;
i_freeFromTStoCPU = 0;
i_driveFromTStoCPU = 0;
i_freeFromDecodertoFetch = 0;

#50;
   rst = 0;
   #150;
   rst = 1;
   #100;

   #10;
   switch = ~switch;
   #2;
   switch = ~switch;
   #20;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   
   #10;
   i_dataTPUtoCPU_80 = {16'h03,64'h0};
   i_dataIcachetoCPU_256 = {256'h2222222222222222222222222222220811111111111111111111111111110008};
   #10;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;


   #10;
   i_dataIcachetoCPU_256 = {256'h4444444444444444444444444444400833333333333333333333333333330008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_dataIcachetoCPU_256 = {256'h6666666666666666666666666666000855555555555555555555555555550008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;

#10;
   i_dataTPUtoCPU_80 = {16'h03,64'h1_ffff_fff0};
   i_dataIcachetoCPU_256 = {256'h0321057210050708032528910005100803210572100507080321057210050008};
   #10;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;


   #10;
   i_dataIcachetoCPU_256 = {256'h0321057210050708032528910005100803210572100507080321057210050008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_dataIcachetoCPU_256 = {256'h0321057210050708032105721005000803210572100507080325289100050008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoCPU = ~i_driveFromIcachetoCPU;
   #100;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromIcachetoCPU = ~i_freeFromIcachetoCPU;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;

   #500;
   $finish;
end


endmodule