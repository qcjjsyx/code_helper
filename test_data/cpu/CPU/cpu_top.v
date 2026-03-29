`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  cpu_top
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/25
// Description: 
//======================================================
module cpu_top(
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

(* dont_touch="true" *)output        o_driveFromMemtoIcache, //输出到Icache
(* dont_touch="true" *)output[135:0] o_dataMemtoIcache_136,
(* dont_touch="true" *)input         i_freeFromIcachetoMem,

(* dont_touch="true" *)input         i_driveFromIcachetoMem, //Icache的输入
(* dont_touch="true" *)input[255:0]  i_dataIcachetoMem_256,
(* dont_touch="true" *)output        o_freeFromMemtoIcache,

(* dont_touch="true" *)output        o_driveFromMemtoDcache, //输出到Dcache
(* dont_touch="true" *)output[135:0] o_dataMemtoDcache_136,
(* dont_touch="true" *)input         i_freeFromDcachetoMem,

(* dont_touch="true" *)input         i_driveFromDcachetoMem, //Dcache的输入
(* dont_touch="true" *)input[255:0]  i_dataDcachetoMem_256,
(* dont_touch="true" *)output        o_freeFromMemtoDcache
);

wire w_driveFromEXCPtoCPU;
wire [63:0] w_dataFromEXCPtoCPU_64;
wire w_freeFromCPUtoEXCP;
wire w_driveFromWBtoCPU;
wire [63:0] w_dataFromWBtoCPU_64;
wire w_freeFromCPUtoWB;
wire w_driveFromCPUtoIcache;
wire [135:0] w_dataCPUtoIcache_136;
wire w_freeFromIcachetoCPU;
wire w_driveFromIcachetoCPU;
wire [255:0] w_dataIcachetoCPU_256;
wire w_freeFromCPUtoIcache;
wire w_driveFromFetchtoDecoder;
wire [96:0] w_dataFetchtoDecoder_97;
wire w_freeFromDecodertoFetch;

wire w_driveToExe;
wire w_freeFromExe;
wire [342:0] w_dataToExe_343;
wire w_driveNextToLsu;
wire w_freeNextFrmLsu;
wire [245:0] w_exeLSUBus_246;

wire w_driveToMem;
wire w_freeFromMem;
wire [135:0] w_dataToMem_136;
wire w_driveFromMem;
wire w_freeToMem;
wire [255:0] w_dataFromMem_256;

wire w_driveToRetire;
wire w_freeFromRetire;
wire [245:0] w_dataToRetire_246;

wire [68:0] w_dataWbToGrf_69;
wire w_driveWbToGrf;
wire w_freeGrfToWb;
wire [75:0] w_dataWbToCsrf_76;
wire w_driveWbToCsrf;
wire w_freeCsrfToWb;

(*dont_touch = "yes"*)Fetch_top Fetch_top(
.rst(rst),
.switch(switch),

.i_driveFromTPUtoCPU(i_driveFromTPUtoCPU),
.i_dataTPUtoCPU_80(i_dataTPUtoCPU_80),
.o_freeFromCPUtoTPU(o_freeFromCPUtoTPU),

.o_driveFromCPUtoTPU(o_driveFromCPUtoTPU), 
.i_freeFromTPUtoCPU(i_freeFromTPUtoCPU),

.i_driveFromEXCPtoCPU(w_driveFromEXCPtoCPU),
.i_dataFromEXCPtoCPU_64(w_dataFromEXCPtoCPU_64),
.o_freeFromCPUtoEXCP(w_freeFromCPUtoEXCP),

.i_driveFromWBtoCPU(w_driveFromWBtoCPU),
.i_dataFromWBtoCPU_64(w_dataFromWBtoCPU_64),
.o_freeFromCPUtoWB(w_freeFromCPUtoWB),

.o_driveFromCPUtoIcache(w_driveFromCPUtoIcache),
.o_dataCPUtoIcache_136(w_dataCPUtoIcache_136),
.i_freeFromIcachetoCPU(w_freeFromIcachetoCPU),

.i_driveFromIcachetoCPU(w_driveFromIcachetoCPU),
.i_dataIcachetoCPU_256(w_dataIcachetoCPU_256),
.o_freeFromCPUtoIcache(w_freeFromCPUtoIcache),

.o_driveFromCPUtoTS(o_driveFromCPUtoTS),
.o_dataCPUtoTS_128(o_dataCPUtoTS_128),
.i_freeFromTStoCPU(i_freeFromTStoCPU),

.i_driveFromTStoCPU(i_driveFromTStoCPU),
.o_freeFromCPUtoTS(o_freeFromCPUtoTS),

.o_driveFromFetchtoDecoder(w_driveFromFetchtoDecoder),
.o_dataFetchtoDecoder_97(w_dataFetchtoDecoder_97),
.i_freeFromDecodertoFetch(w_freeFromDecodertoFetch)
);


(*dont_touch = "yes"*)idu_top idu_top(
.rst(rst),
.i_driveWriteGrf(w_driveWbToGrf),
.o_freeWriteGrf(w_freeGrfToWb),
.i_dataWriteGrf_69(w_dataWbToGrf_69),//{rd_5,data_64}
.i_driveWriteCsr(w_driveWbToCsrf),
.o_freeWriteCsr(w_freeCsrfToWb),
.i_dataWriteCsr_76(w_dataWbToCsrf_76),// {addr_12, data_64}
.i_driveFromIfu(w_driveFromFetchtoDecoder),
.i_dataFromIfu_97(w_dataFetchtoDecoder_97),//{1-c,64-pc,32-ins}
.o_freeToIfu(w_freeFromDecodertoFetch),
.o_driveToExe(w_driveToExe),
.i_freeFromExe(w_freeFromExe),
.o_dataToExe_343(w_dataToExe_343)
);


(*dont_touch = "yes"*)exe_top exe_top(
.rst(rst),
.i_driveToExe(w_driveToExe),
.o_freeFrmExe(w_freeFromExe),
.i_decoderExeBus_343(w_dataToExe_343),
.o_driveNextToLsu(w_driveNextToLsu),
.i_freeNextFrmLsu(w_freeNextFrmLsu),
.o_exeLSUBus_246(w_exeLSUBus_246)
);


(*dont_touch = "yes"*)lsu_top lsu_top(
.rst(rst),
.i_driveFromExe(w_driveNextToLsu),
.o_freeToExe(w_freeNextFrmLsu),
.i_dataFromExe_246(w_exeLSUBus_246),
.o_driveToMem(w_driveToMem),
.i_freeFromMem(w_freeFromMem),
.o_dataToMem_136(w_dataToMem_136),
.i_driveFromMem(w_driveFromMem),
.o_freeToMem(w_freeToMem),
.i_dataFromMem_256(w_dataFromMem_256),
.o_driveToRetire(w_driveToRetire),
.i_freeFromRetire(w_freeFromRetire),
.o_dataToRetire_246(w_dataToRetire_246)
);

(*dont_touch = "yes"*)mem_slot mem_slot(
.rst(rst),
.i_driveFromFetchtoMem(w_driveFromCPUtoIcache), //取指的输入
.i_dataFetchtoMem_136(w_dataCPUtoIcache_136),
.o_freeFromMemtoFetch(w_freeFromIcachetoCPU),

.o_driveFromMemtoFetch(w_driveFromIcachetoCPU), //输出到取指
.o_dataMemtoFetch_256(w_dataIcachetoCPU_256),
.i_freeFromFetchtoMem(w_freeFromCPUtoIcache),

.i_driveFromLSUtoMem(w_driveToMem), //访存的输入
.i_dataLSUtoMem_136(w_dataToMem_136),
.o_freeFromMemtoLSU(w_freeFromMem),

.o_driveFromMemtoLSU(w_driveFromMem), //输出到访存
.o_dataMemtoLSU_256(w_dataFromMem_256),
.i_freeFromLSUtoMem(w_freeToMem),

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
.o_freeFromMemtoDcache(o_freeFromMemtoDcache)
);


(*dont_touch = "yes"*)writeBack writeBack(
.rst(rst),
.i_dataLSUToWb_246(w_dataToRetire_246),
.i_driveLSUToWb(w_driveToRetire),
.o_freeWbToLSU(w_freeFromRetire),
.o_dataWbToGrf_69(w_dataWbToGrf_69),
.o_driveWbToGrf(w_driveWbToGrf),
.i_freeGrfToWb(w_freeGrfToWb),
.o_dataWbToCsrf_76(w_dataWbToCsrf_76),
.o_driveWbToCsrf(w_driveWbToCsrf),
.i_freeCsrfToWb(w_freeCsrfToWb),
.o_dataWbToFetch_64(w_dataFromWBtoCPU_64),
.o_driveWbToFetch(w_driveFromWBtoCPU),
.i_freeFetchToWb(w_freeFromCPUtoWB)
);


endmodule