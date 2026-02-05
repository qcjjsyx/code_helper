`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  mem_slot
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/18
// Description: 
//======================================================


module mem_slot(
//reset
(* dont_touch="true" *)input           rst,

(* dont_touch="true" *)input         i_driveFromFetchtoMem, //取指的输入
(* dont_touch="true" *)input[135:0]  i_dataFetchtoMem_136,
(* dont_touch="true" *)output        o_freeFromMemtoFetch,

(* dont_touch="true" *)output        o_driveFromMemtoFetch, //输出到取指
(* dont_touch="true" *)output[255:0] o_dataMemtoFetch_256,
(* dont_touch="true" *)input         i_freeFromFetchtoMem,

(* dont_touch="true" *)input         i_driveFromLSUtoMem, //访存的输入
(* dont_touch="true" *)input[135:0]  i_dataLSUtoMem_136,
(* dont_touch="true" *)output        o_freeFromMemtoLSU,

(* dont_touch="true" *)output        o_driveFromMemtoLSU, //输出到访存
(* dont_touch="true" *)output[255:0] o_dataMemtoLSU_256,
(* dont_touch="true" *)input         i_freeFromLSUtoMem,

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

(* dont_touch="true" *)wire          w_driveFifoToArb;
(* dont_touch="true" *)wire          w_freeArbToFifo;
(* dont_touch="true" *)wire          w_fire_Fetch;
(* dont_touch="true" *)reg  [135:0]  r_dataFromFetch_136;
(* dont_touch="true" *)wire          w_driveFifoToSel;
(* dont_touch="true" *)wire          w_freeSelToFifo;
(* dont_touch="true" *)wire          w_fire_LSU;
(* dont_touch="true" *)reg  [135:0]  r_dataFromLSU_136;

(* dont_touch="true" *)wire          w_valid1_1;
(* dont_touch="true" *)wire          w_valid0_1;
(* dont_touch="true" *)wire          w_freeArbtoSel;
(* dont_touch="true" *)wire          w_driveSeltoArb;
(* dont_touch="true" *)wire  [1:0]   w_dataFromArb_2;

(* dont_touch="true" *)wire          w_driveFromArbtofifo;
(* dont_touch="true" *)wire          w_freeFromfifotoArb;
(* dont_touch="true" *)wire          w_fire_flag;
(* dont_touch="true" *)reg   [1:0]   r_dataFromArb_2;

(* dont_touch="true" *)wire          w_fire_Icache;
(* dont_touch="true" *)wire          w_driveFromfifotoSel;
(* dont_touch="true" *)wire          w_freeFromSeltofifo;
reg   [255:0] r_dataFromIcache_256;
(* dont_touch="true" *)wire          w_driveFromfifotoMutex;
(* dont_touch="true" *)wire          w_freeFromMutextofifo;
(* dont_touch="true" *)wire          w_fire_Dcache;
(* dont_touch="true" *)reg   [255:0] r_dataFromDcache_256;

(* dont_touch="true" *)wire          w_valid0_2;
(* dont_touch="true" *)wire          w_valid1_2;
(* dont_touch="true" *)wire          w_driveFromSeltoMutex;
(* dont_touch="true" *)wire          w_freeFromMutextoSel;

(* dont_touch="true" *)wire w_driveFromfifotoSel_dealy1;
(* dont_touch="true" *)wire w_driveFromfifotoSel_dealy2;
(* dont_touch="true" *)wire w_driveFifoToSel_dealy;


(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_1(
.i_drive(i_driveFromFetchtoMem),
.o_free(o_freeFromMemtoFetch),
.o_driveNext(w_driveFifoToArb),
.i_freeNext(w_freeArbToFifo),
.o_fire(w_fire_Fetch),
.rst(rst)
);
always @(posedge w_fire_Fetch or negedge rst) begin
if(!rst) begin
        r_dataFromFetch_136  <= 136'b0;
    end
    else begin
        r_dataFromFetch_136  <= i_dataFetchtoMem_136;
    end
end

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_2(
.i_drive(i_driveFromLSUtoMem),
.o_free(o_freeFromMemtoLSU),
.o_driveNext(w_driveFifoToSel),
.i_freeNext(w_freeSelToFifo),
.o_fire(w_fire_LSU),
.rst(rst)
);
always @(posedge w_fire_LSU or negedge rst) begin
if(!rst) begin
        r_dataFromLSU_136  <= 136'b0;
    end
    else begin
        r_dataFromLSU_136  <= i_dataLSUtoMem_136;
    end
end

localparam [63:0] ICACHE_BASE = 64'h0_0000_0000;
localparam [63:0] DCACHE_BASE = 64'h2_0000;
(* dont_touch="true" *)assign w_valid1_1 = (r_dataFromLSU_136[127:64] >= DCACHE_BASE) ? 1'b1 : 1'b0;
(* dont_touch="true" *)assign w_valid0_1 = ~w_valid1_1;
(* dont_touch="true" *)delay_free_cpu #(90)  delay_free_cpu_sel1(
     .inR(w_driveFifoToSel), 
     .outR(w_driveFifoToSel_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch_1(
.i_drive(w_driveFifoToSel_dealy),
.i_freeNext0(w_freeArbtoSel),
.i_freeNext1(i_freeFromDcachetoMem),
.valid0(w_valid0_1),
.valid1(w_valid1_1),  //DCACHE
.o_free(w_freeSelToFifo),
.o_driveNext0(w_driveSeltoArb),
.o_driveNext1(o_driveFromMemtoDcache),
.rst(rst)
);
(* dont_touch="true" *)assign o_dataMemtoDcache_136 = r_dataFromLSU_136;

(* dont_touch="true" *)cArbMerge_2_memslot cArbMerge_2_memslot(
.i_drive0(w_driveFifoToArb),   
.i_drive1(w_driveSeltoArb),
.i_data0(2'b10), //fetch
.i_data1(2'b01), //lsu
.o_free0(w_freeArbToFifo), 
.o_free1(w_freeArbtoSel),
.o_drive(w_driveFromArbtofifo),
.o_data(w_dataFromArb_2),
.i_free(w_freeFromfifotoArb),
.rst(rst)
);
(* dont_touch="true" *)assign o_dataMemtoIcache_136 = r_dataFromFetch_136;

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_3(
.i_drive(w_driveFromArbtofifo),
.o_free(w_freeFromfifotoArb),
.o_driveNext(o_driveFromMemtoIcache),
.i_freeNext(i_freeFromIcachetoMem),
.o_fire(w_fire_flag),
.rst(rst)
);
always @(posedge w_fire_flag or negedge rst) begin
if(!rst) begin
        r_dataFromArb_2  <= 2'b0;
    end
    else begin
        r_dataFromArb_2  <= w_dataFromArb_2;
    end
end

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_4(
.i_drive(i_driveFromIcachetoMem),
.o_free(o_freeFromMemtoIcache),
.o_driveNext(w_driveFromfifotoSel),
.i_freeNext(w_freeFromSeltofifo),
.o_fire(w_fire_Icache),
.rst(rst)
);
always @(posedge w_fire_Icache or negedge rst) begin
if(!rst) begin
        r_dataFromIcache_256  <= 256'b0;
    end
    else begin
        r_dataFromIcache_256  <= i_dataIcachetoMem_256;
    end
end

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_5(
.i_drive(i_driveFromDcachetoMem),
.o_free(o_freeFromMemtoDcache),
.o_driveNext(w_driveFromfifotoMutex),
.i_freeNext(w_freeFromMutextofifo),
.o_fire(w_fire_Dcache),
.rst(rst)
);
always @(posedge w_fire_Dcache or negedge rst) begin
if(!rst) begin
        r_dataFromDcache_256  <= 256'b0;
    end
    else begin
        r_dataFromDcache_256  <= i_dataDcachetoMem_256;
    end
end

(* dont_touch="true" *)assign w_valid0_2 = r_dataFromArb_2[1] & (~r_dataFromArb_2[0]);  //2'b10
(* dont_touch="true" *)assign w_valid1_2 = ~r_dataFromArb_2[1] & r_dataFromArb_2[0];  //2'b01
(* dont_touch="true" *)delay_free_cpu #(110)  delay_free_cpu_sel2(
     .inR(w_driveFromfifotoSel), 
     .outR(w_driveFromfifotoSel_dealy1), 
     .rst(rst)
);
(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch_2(
.i_drive(w_driveFromfifotoSel_dealy1),
.i_freeNext0(i_freeFromFetchtoMem),
.i_freeNext1(w_freeFromMutextoSel),
.valid0(w_valid0_2),
.valid1(w_valid1_2),  
.o_free(w_freeFromSeltofifo),
.o_driveNext0(o_driveFromMemtoFetch),
.o_driveNext1(w_driveFromSeltoMutex),
.rst(rst)
);
(* dont_touch="true" *)assign o_dataMemtoFetch_256 = r_dataFromIcache_256;

(* dont_touch="true" *)cMutexMerge_2_df_memslot cMutexMerge_2_df_memslot(
.i_drive0(w_driveFromSeltoMutex),
.i_drive1(w_driveFromfifotoMutex),
.i_data0(r_dataFromIcache_256),
.i_data1(r_dataFromDcache_256),
.i_freeNext(i_freeFromLSUtoMem),
.o_free0(w_freeFromMutextoSel),
.o_free1(w_freeFromMutextofifo),
.o_driveNext(o_driveFromMemtoLSU),
.o_data(o_dataMemtoLSU_256),
.rst(rst)
);

endmodule
