`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         CPUwithCache_tb
// version:        
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/12/19
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    CPU测试模块
//===============================================================================

module CPUwithCache_tb;
reg         rst;
reg         switch;

reg         i_driveFromTPUtoCPU; //TPU读写接口的输入
reg [79:0]  i_dataTPUtoCPU_80;
wire        o_freeFromCPUtoTPU;

wire        o_driveFromCPUtoTPU; //输出给TPU读写接口
reg         i_freeFromTPUtoCPU;

wire        o_driveFromCPUtoTS; //任务调度单元的交互   TASK SCHEDULING
wire[127:0] o_dataCPUtoTS_128;
reg         i_freeFromTStoCPU;

reg         i_driveFromTStoCPU;
wire        o_freeFromCPUtoTS;

// tpuSlot <--> icache
reg           i_icache_drvFTPUSlot; 
wire          o_icache_free2TPUSlot;
reg [55 :0]   i_icache_tpuSlotPA_56;
reg [127:0]   i_icache_instData_128;
wire          o_icache_drv2TPUSlot; 
reg           i_icache_freeFTPUSlot;

// tmu <--> dcache
reg           i_dcache_drvFTMU;   
wire          o_dcache_free2TMU;  
reg           i_dcache_tmuWen;       
reg  [55 :0]  i_dcache_tmuPA_56;   
reg  [63 :0]  i_dcache_tmuData_64;
wire          o_dcache_drv2tmuR;  
reg           i_dcache_freeFtmuR; 
wire [63 :0]  o_dcache_tmuRData_64;
wire          o_dcache_drv2tmuW;    
reg           i_dcache_freeFtmuW;

// l2cache <--> ddr
reg           i_drvFDDRRefill;  
wire          o_free2DDRRefill; 
reg  [255:0]  i_ddrRefillLine_256;
reg           i_drvFDDRWriteOver;
wire          o_free2DDRWriteOver;
wire          o_drv2DDRRead;    
reg           i_freeFDDRRead;    
wire [55 :0]  o_readPA_56;      
wire          o_drv2DDRWrite;   
reg           i_freeFDDRWrite;   
wire [55 :0]  o_writePA_56;     
wire [255:0]  o_writeLine_256;


CPUwithCache uut(
.rst(rst),
.switch(switch),

.i_driveFromTPUtoCPU(i_driveFromTPUtoCPU), //TPU读写接口的输入
.i_dataTPUtoCPU_80(i_dataTPUtoCPU_80),
.o_freeFromCPUtoTPU(o_freeFromCPUtoTPU),

.o_driveFromCPUtoTPU(o_driveFromCPUtoTPU), //输出给TPU读写接口
.i_freeFromTPUtoCPU(i_freeFromTPUtoCPU),

.o_driveFromCPUtoTS(o_driveFromCPUtoTS), //任务调度单元的交互   TASK SCHEDULING
.o_dataCPUtoTS_128(o_dataCPUtoTS_128),
.i_freeFromTStoCPU(i_freeFromTStoCPU),

.i_driveFromTStoCPU(i_driveFromTStoCPU),
.o_freeFromCPUtoTS(o_freeFromCPUtoTS),

// tpuSlot <--> icache
.i_icache_drvFTPUSlot(i_icache_drvFTPUSlot), 
.o_icache_free2TPUSlot(o_icache_free2TPUSlot),
.i_icache_tpuSlotPA_56(i_icache_tpuSlotPA_56),
.i_icache_instData_128(i_icache_instData_128),
.o_icache_drv2TPUSlot(o_icache_drv2TPUSlot), 
.i_icache_freeFTPUSlot(i_icache_freeFTPUSlot),

// tmu <--> dcache
.i_dcache_drvFTMU(i_dcache_drvFTMU),   
.o_dcache_free2TMU(o_dcache_free2TMU),  
.i_dcache_tmuWen(i_dcache_tmuWen),       
.i_dcache_tmuPA_56(i_dcache_tmuPA_56),   
.i_dcache_tmuData_64(i_dcache_tmuData_64),
.o_dcache_drv2tmuR(o_dcache_drv2tmuR),  
.i_dcache_freeFtmuR(i_dcache_freeFtmuR), 
.o_dcache_tmuRData_64(o_dcache_tmuRData_64),
.o_dcache_drv2tmuW(o_dcache_drv2tmuW),    
.i_dcache_freeFtmuW(i_dcache_freeFtmuW),

// l2cache <--> ddr
// cache -> ddr
.o_drv2DDRRead(o_drv2DDRRead),    // read ddr
.i_freeFDDRRead(i_freeFDDRRead),    
.o_readPA_56(o_readPA_56),      // read pa

.o_drv2DDRWrite(o_drv2DDRWrite),   // write ddr
.i_freeFDDRWrite(i_freeFDDRWrite),   
.o_writePA_56(o_writePA_56),     // write pa
.o_writeLine_256(o_writeLine_256), // write data

// ddr -> cache
.i_drvFDDRRefill(i_drvFDDRRefill),  // read over
.o_free2DDRRefill(o_free2DDRRefill), 
.i_ddrRefillLine_256(i_ddrRefillLine_256), // read data

.i_drvFDDRWriteOver(i_drvFDDRWriteOver), // write over
.o_free2DDRWriteOver(o_free2DDRWriteOver)
);

initial begin

rst = 1;
switch = 0;
i_driveFromTPUtoCPU = 0; //TPU读写接口的输入
i_dataTPUtoCPU_80 = 0;
i_freeFromTPUtoCPU = 0;
i_freeFromTStoCPU = 0;
i_driveFromTStoCPU = 0;
i_icache_drvFTPUSlot = 0; 
i_icache_tpuSlotPA_56 = 0;
i_icache_instData_128 = 0;
i_icache_freeFTPUSlot = 0;
i_dcache_drvFTMU = 0;   
i_dcache_tmuWen = 0;       
i_dcache_tmuPA_56 = 0;   
i_dcache_tmuData_64 = 0;
i_dcache_freeFtmuR = 0;   
i_dcache_freeFtmuW = 0;
i_drvFDDRRefill = 0;  
i_ddrRefillLine_256 = 0;
i_drvFDDRWriteOver = 0;  
i_freeFDDRRead = 0;      
i_freeFDDRWrite = 0;   

#50;
   rst = 0;
   #150;
   rst = 1;
   #100;

   #10;
   switch = ~switch;
   #2;
   switch = ~switch;
   @(posedge o_driveFromCPUtoTPU);
   #10;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;



   #10;
   i_dataTPUtoCPU_80 = {16'h05,64'h0};
   #5;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;


   @(posedge o_drv2DDRRead);
   #10;
   i_freeFDDRRead = ~i_freeFDDRRead;
   #2;
   i_freeFDDRRead = ~i_freeFDDRRead;

   #5;
   i_ddrRefillLine_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};
   #10;
   i_drvFDDRRefill = ~i_drvFDDRRefill;
   #2;
   i_drvFDDRRefill = ~i_drvFDDRRefill;

   /*#5;
   i_ddrRefillLine_256 = {256'h2222222222222222222222222222220811111111111111111111111111110008};
   #10;
   i_drvFDDRRefill = ~i_drvFDDRRefill;
   #2;
   i_drvFDDRRefill = ~i_drvFDDRRefill;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
 
  ///////////////////////////////////////////////////////////////////////////////////////////
   @(posedge o_drv2DDRRead);
   #10;
   i_freeFDDRRead = ~i_freeFDDRRead;
   #2;
   i_freeFDDRRead = ~i_freeFDDRRead;

    #5;
   i_ddrRefillLine_256 = {256'h4444444444444444444444444444400833333333333333333333333333330008};
   #10;
   i_drvFDDRRefill = ~i_drvFDDRRefill;
   #2;
   i_drvFDDRRefill = ~i_drvFDDRRefill;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

    #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;

    ///////////////////////////////////////////////////////////////////////////////////////////
   @(posedge o_drv2DDRRead);
   #10;
   i_freeFDDRRead = ~i_freeFDDRRead;
   #2;
   i_freeFDDRRead = ~i_freeFDDRRead;

    #5;
   i_ddrRefillLine_256 = {256'h0321057210050708032528910005100803210572100507080321057210050008};
   #10;
   i_drvFDDRRefill = ~i_drvFDDRRefill;
   #2;
   i_drvFDDRRefill = ~i_drvFDDRRefill;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

    #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;

   @(posedge o_driveFromCPUtoTS);
   #10;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;*/

   #1000;
   

#10000;
     $finish;
end

endmodule