`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  CPUwithCache
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/12/19
// Description: 
//======================================================
module CPUwithCache(
(* dont_touch="true" *)input         rst,
(* dont_touch="true" *)input         switch,

(* dont_touch="true" *)input         i_driveFromTPUtoCPU, //TPU读写接口的输入
(* dont_touch="true" *)input [79:0]  i_dataTPUtoCPU_80,
(* dont_touch="true" *)output        o_freeFromCPUtoTPU,

(* dont_touch="true" *)output        o_driveFromCPUtoTPU, //输出给TPU读写接口
(* dont_touch="true" *)input         i_freeFromTPUtoCPU,

(* dont_touch="true" *)output        o_driveFromCPUtoTS, //任务调度单元的交互   TASK SCHEDULING
(* dont_touch="true" *)output[127:0] o_dataCPUtoTS_128,
(* dont_touch="true" *)input         i_freeFromTStoCPU,

(* dont_touch="true" *)input         i_driveFromTStoCPU,
(* dont_touch="true" *)output        o_freeFromCPUtoTS,


    // tpuSlot <--> icache
    (* dont_touch="true" *)input           i_icache_drvFTPUSlot    , 
    (* dont_touch="true" *)output          o_icache_free2TPUSlot   ,
    (* dont_touch="true" *)input [55 :0]   i_icache_tpuSlotPA_56   ,
    (* dont_touch="true" *)input [127:0]   i_icache_instData_128   ,
    (* dont_touch="true" *)output          o_icache_drv2TPUSlot    , 
    (* dont_touch="true" *)input           i_icache_freeFTPUSlot   ,

    // tmu <--> dcache
    (* dont_touch="true" *)input           i_dcache_drvFTMU        ,    
    (* dont_touch="true" *)output          o_dcache_free2TMU       ,   
    (* dont_touch="true" *)input           i_dcache_tmuWen         ,        
    (* dont_touch="true" *)input  [55 :0]  i_dcache_tmuPA_56       ,   
    (* dont_touch="true" *)input  [63 :0]  i_dcache_tmuData_64     , 
    (* dont_touch="true" *)output          o_dcache_drv2tmuR       ,   
    (* dont_touch="true" *)input           i_dcache_freeFtmuR      ,  
    (* dont_touch="true" *)output [63 :0]  o_dcache_tmuRData_64    ,
    (* dont_touch="true" *)output          o_dcache_drv2tmuW       ,     
    (* dont_touch="true" *)input           i_dcache_freeFtmuW      ,  

    // l2cache <--> ddr
    (* dont_touch="true" *)input           i_drvFDDRRefill         ,    
    (* dont_touch="true" *)output          o_free2DDRRefill        ,   
    (* dont_touch="true" *)input  [255:0]  i_ddrRefillLine_256     ,
    (* dont_touch="true" *)input           i_drvFDDRWriteOver      , 
    (* dont_touch="true" *)output          o_free2DDRWriteOver     ,
    (* dont_touch="true" *)output          o_drv2DDRRead           ,      
    (* dont_touch="true" *)input           i_freeFDDRRead          ,     
    (* dont_touch="true" *)output [55 :0]  o_readPA_56             ,        
    (* dont_touch="true" *)output          o_drv2DDRWrite          ,     
    (* dont_touch="true" *)input           i_freeFDDRWrite         ,    
    (* dont_touch="true" *)output [55 :0]  o_writePA_56            ,       
    (* dont_touch="true" *)output [255:0]  o_writeLine_256    
);

(* dont_touch="true" *)wire w_driveFromMemtoIcache;
(* dont_touch="true" *)wire [135:0] w_dataMemtoIcache_136;
(* dont_touch="true" *)wire w_freeFromIcachetoMem;
(* dont_touch="true" *)wire w_driveFromIcachetoMem;
(* dont_touch="true" *)wire [255:0] w_dataIcachetoMem_256;
(* dont_touch="true" *)wire w_freeFromMemtoIcache;

(* dont_touch="true" *)wire w_driveFromMemtoDcache;
(* dont_touch="true" *)wire [135:0] w_dataMemtoDcache_136;
(* dont_touch="true" *)wire w_freeFromDcachetoMem;
(* dont_touch="true" *)wire w_driveFromDcachetoMem;
(* dont_touch="true" *)wire [255:0] w_dataDcachetoMem_256;
(* dont_touch="true" *)wire w_freeFromMemtoDcache;

(* dont_touch="true" *)cpu_top cpu_top(
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

.o_driveFromMemtoIcache(w_driveFromMemtoIcache), //输出到Icache
.o_dataMemtoIcache_136(w_dataMemtoIcache_136),
.i_freeFromIcachetoMem(w_freeFromIcachetoMem),
.i_driveFromIcachetoMem(w_driveFromIcachetoMem), //Icache的输入
.i_dataIcachetoMem_256(w_dataIcachetoMem_256),
.o_freeFromMemtoIcache(w_freeFromMemtoIcache),
.o_driveFromMemtoDcache(w_driveFromMemtoDcache), //输出到Dcache
.o_dataMemtoDcache_136(w_dataMemtoDcache_136),
.i_freeFromDcachetoMem(w_freeFromDcachetoMem),
.i_driveFromDcachetoMem(w_driveFromDcachetoMem), //Dcache的输入
.i_dataDcachetoMem_256(w_dataDcachetoMem_256),
.o_freeFromMemtoDcache(w_freeFromMemtoDcache)
);

(* dont_touch="true" *)cpuCache_top cpuCache_top(
.rst(rst),
.i_icache_drvFLdSt(w_driveFromMemtoIcache),    
.o_icache_free2LdSt(w_freeFromIcachetoMem),   
.i_icache_stWen_8(w_dataMemtoIcache_136[135:128]),     
.i_icache_cpuPA_56(w_dataMemtoIcache_136[119:64]),    
.i_icache_stData_64(w_dataMemtoIcache_136[63:0]),   
.o_icache_drv2LdSt(w_driveFromIcachetoMem),    
.i_icache_freeFLdSt(w_freeFromMemtoIcache),   
.o_icache_loadData_256(w_dataIcachetoMem_256),

.i_icache_drvFTPUSlot(i_icache_drvFTPUSlot), 
.o_icache_free2TPUSlot(o_icache_free2TPUSlot), 
.i_icache_tpuSlotPA_56(i_icache_tpuSlotPA_56), 
.i_icache_instData_128(i_icache_instData_128), 
.o_icache_drv2TPUSlot(o_icache_drv2TPUSlot), 
.i_icache_freeFTPUSlot(i_icache_freeFTPUSlot), 

.i_dcache_drvFLdSt(w_driveFromMemtoDcache),     
.o_dcache_free2LdSt(w_freeFromDcachetoMem),    
.i_dcache_stWen_8(w_dataMemtoDcache_136[135:128]),     
.i_dcache_cpuPA_56(w_dataMemtoDcache_136[119:64]),     
.i_dcache_stData_64(w_dataMemtoDcache_136[63:0]),   
.o_dcache_drv2LdSt(w_driveFromDcachetoMem),    
.i_dcache_freeFLdSt(w_freeFromMemtoDcache),  
.o_dcache_loadData_256(w_dataDcachetoMem_256), 

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

.i_drvFDDRRefill(i_drvFDDRRefill),    
.o_free2DDRRefill(o_free2DDRRefill),    
.i_ddrRefillLine_256(i_ddrRefillLine_256), 
.i_drvFDDRWriteOver(i_drvFDDRWriteOver), 
.o_free2DDRWriteOver(o_free2DDRWriteOver), 
.o_drv2DDRRead(o_drv2DDRRead),      
.i_freeFDDRRead(i_freeFDDRRead),     
.o_readPA_56(o_readPA_56),        
.o_drv2DDRWrite(o_drv2DDRWrite),     
.i_freeFDDRWrite(i_freeFDDRWrite),     
.o_writePA_56(o_writePA_56),        
.o_writeLine_256(o_writeLine_256)
);

endmodule