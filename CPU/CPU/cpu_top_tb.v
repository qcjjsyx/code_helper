`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         cpu_top_tb
// version:        1st version (2025-11-11)
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/11/26
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    CPU测试模块
//===============================================================================

module cpu_top_tb;

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

wire        o_driveFromMemtoIcache; //输出到Icache
wire[135:0] o_dataMemtoIcache_136;
reg         i_freeFromIcachetoMem;

reg         i_driveFromIcachetoMem; //Icache的输入
reg[255:0]  i_dataIcachetoMem_256;
wire        o_freeFromMemtoIcache;

wire        o_driveFromMemtoDcache; //输出到Dcache
wire[135:0] o_dataMemtoDcache_136;
reg         i_freeFromDcachetoMem;

reg         i_driveFromDcachetoMem; //Dcache的输入
reg[255:0]  i_dataDcachetoMem_256;
wire        o_freeFromMemtoDcache;

    

cpu_top uut(
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
.o_driveFromMemtoIcache(o_driveFromMemtoIcache), //输出到Icache
.o_dataMemtoIcache_136(o_dataMemtoIcache_136),
.i_freeFromIcachetoMem(i_freeFromIcachetoMem),
.i_driveFromIcachetoMem(i_driveFromIcachetoMem), //Icache的输入
.i_dataIcachetoMem_256(i_dataIcachetoMem_256),
.o_freeFromMemtoIcache(o_freeFromMemtoIcache),
.o_driveFromMemtoDcache(o_driveFromMemtoDcache), //输出到Dcache
.o_dataMemtoDcache_136(o_dataMemtoDcache_136),
.i_freeFromDcachetoMem(i_freeFromDcachetoMem),
.i_driveFromDcachetoMem(i_driveFromDcachetoMem), //Dcache的输入
.i_dataDcachetoMem_256(i_dataDcachetoMem_256),
.o_freeFromMemtoDcache(o_freeFromMemtoDcache),
.rst(rst)
);

initial begin
rst = 1;
switch = 0;
i_driveFromTPUtoCPU = 0; //TPU读写接口的输入
i_dataTPUtoCPU_80 = 0;
i_freeFromTPUtoCPU = 0;
i_freeFromTStoCPU = 0;
i_driveFromTStoCPU = 0;
i_freeFromIcachetoMem = 0;
i_driveFromIcachetoMem = 0; //Icache的输入
i_dataIcachetoMem_256 = 0;
i_freeFromDcachetoMem = 0;
i_driveFromDcachetoMem = 0; //Dcache的输入
i_dataDcachetoMem_256 = 0;

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
   
  /* #10;
   i_dataTPUtoCPU_80 = {16'h08,64'h0};
   i_dataIcachetoMem_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};//li
   #10;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   //i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;

   #10;  
   i_dataIcachetoMem_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};//li
   //i_dataIcachetoMem_256 = {256'h00000000000000000000000000000000000000000000000000108f1300000d13};
   #10;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;

   #10;
   i_dataIcachetoMem_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};//auipc
   #10;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;

   #10;
   i_dataIcachetoMem_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};//add
   #10;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
  

   #10;
   i_dataIcachetoMem_256 = {256'h002001930ffe8e9300ff0eb70000af03df8080930000709700000d9300000d13};//lw
   i_dataDcachetoMem_256 = {};
   #10;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   i_driveFromDcachetoMem = ~i_driveFromDcachetoMem;
   #2;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   i_driveFromDcachetoMem = ~i_driveFromDcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromDcachetoMem = ~i_freeFromDcachetoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromDcachetoMem = ~i_freeFromDcachetoMem;*/



   #10;
   i_dataTPUtoCPU_80 = {16'h05,64'h0};
   i_dataIcachetoMem_256 = {256'h2222222222222222222222222222220811111111111111111111111111110008};
   #10;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_dataIcachetoMem_256 = {256'h4444444444444444444444444444400833333333333333333333333333330008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_dataIcachetoMem_256 = {256'h0321057210050708032528910005100803210572100507080321057210050008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

    #10;
   i_dataIcachetoMem_256 = {256'h6666666666666666666666666666600855555555555555555555555555550008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_dataIcachetoMem_256 = {256'h6666666666666666666666666666600855555555555555555555555555550008};
   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #1000;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromTStoCPU = ~i_freeFromTStoCPU;

   #10;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #2;
   i_driveFromTStoCPU = ~i_driveFromTStoCPU;
   #1000;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;


   #10000;
   $finish;
end


endmodule