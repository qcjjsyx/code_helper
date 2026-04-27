`timescale 1ns / 1ps

/*
lsu的数据更新
*/
module dataUpdate(
//复位
input rst,
//addrFromPeripheralFlag
input i_addrFromPeripheralFlag_1,
//从lsu来的脉冲
input i_lsuToDataUpdate_1,
//load/store标志位
input i_store_1,
input i_load_1,
//load有关信号
input i_loadSign_1,
input [31:0] i_memAddr_32,
input [63:0] i_memData_64,
input [3:0] i_dHi_4,
input [3:0] i_dLo_4,
//store有关信号
input [63:0] i_storeData_64,
//公用信号
input [1:0]  i_lsuType_2,
input [11:0] i_stateValid_12,
input i_misaligned_1,
//free信号
input i_writebackFreeToDataUpate_1,
input i_dataRoutFreeToDataUpate_1,
//给lsu的复位
output o_dataUpdateToLsu_1,
//去grf的信号
output o_dataUpdateDriveToWriteback_1,
output [73:0] o_dataUpdateToWritebackData_74,
//去mem的信号
output o_dataUpdateDriveToMem_1,
output [31:0] o_memAddr_32,
output [63:0] o_memData_64,
output [7:0] o_memWen_8
);
wire w_freeFlIdle;
wire w_freeFlb;
wire w_freeFlhw;
wire w_freeFldw;
wire w_freeFlw;
wire w_freeFlhwm;
wire w_freeFlwm;
wire w_freeFldwm;

wire w_lIdleDrive;
wire w_lbDrive;
wire w_lhwDrive;
wire w_ldwDrive;
wire w_lwDrive;
wire w_lhwmDrive;
wire w_lwmDrive;
wire w_ldwmDrive;

(* dont_touch="true" *)reg [31:0] r_memAddr_32;   
reg r_addrFromPeripheralFlag_1;
(* dont_touch="true" *)reg r_misaligned_1;

(* dont_touch="true" *)wire [31:0] w_memAddr_32;
wire w_addrFromPeripheralFlag_1;
(* dont_touch="true" *)wire [63:0] w_storeData_64;
(* dont_touch="true" *)reg [63:0] r_storeData_64;

wire w_freeFsIdle;
wire w_freeFsw;
wire w_freeFshw;
wire w_freeFsdw;
wire w_sIdleDrive;
wire w_swDrive;
wire w_shwDrive;
wire w_sdwDrive;

wire w_free2lIdle;
wire w_driveFlIdle;
wire w_free2lb;
wire w_driveFlb;
wire w_free2lhw;
wire w_driveFlhw;
wire w_free2ldw;
wire w_driveFldw;
wire w_free2lw;
wire w_driveFlw;
wire w_free2lhwm;
wire w_driveFlhwm;
wire w_free2ldwm;
wire w_driveFldwm;
wire w_free2lwm;
wire w_driveFlwm;
  
(* dont_touch="true" *)wire [63:0] w_memData_64;  
(* dont_touch="true" *)wire w_misaligned_1;
(* dont_touch="true" *)wire [11:0] w_stateValid_12;
wire w_free2sidle;
wire w_driveFsidle;

wire w_free2sw;
wire w_driveFsw;

wire w_free2shw;
wire w_driveFshw;

wire w_free2sdw;
wire w_driveFsdw;

// 在idle状态下计算时的中间寄存器
// (* dont_touch="true" *)reg [63:0] r_sIdleMemDataTemp_64;
// (* dont_touch="true" *)reg [7:0] r_sIdleMemWenTemp_8;

(* dont_touch="true" *)reg [63:0] r_sIdleMemDataTemp_64;
(* dont_touch="true" *)reg [7:0] r_sIdleMemWenTemp_8;

(* dont_touch="true" *)wire [31:0] r_sIdleMemAddr_32;
(* dont_touch="true" *)wire [63:0] r_sIdleMemData_64;
(* dont_touch="true" *)wire [7:0] r_sIdleMemWen_8;
(* dont_touch="true" *)wire [31:0] w_sIdleMemAddr_32;
(* dont_touch="true" *)wire [63:0] w_sIdleMemData_64;
(* dont_touch="true" *)wire [7:0] w_sIdleMemWen_8;

(* dont_touch="true" *)wire [31:0] r_swMemAddr_32;
(* dont_touch="true" *)wire [31:0] w_swMemAddr_32;
(* dont_touch="true" *)wire [63:0] r_swMemData_64;
(* dont_touch="true" *)wire [7:0] r_swMemWen_8;
(* dont_touch="true" *)wire [63:0] w_swMemData_64;
(* dont_touch="true" *)wire [7:0] w_swMemWen_8;

(* dont_touch="true" *)wire [31:0] r_shwMemAddr_32;	
(* dont_touch="true" *)wire [7:0] r_shwMemWen_8;
(* dont_touch="true" *)wire [63:0] r_shwMemData_64;
(* dont_touch="true" *)wire [31:0] w_shwMemAddr_32;
(* dont_touch="true" *)wire [63:0] w_shwMemData_64;

(* dont_touch="true" *)wire [31:0] r_sdwMemAddr_32;	
(* dont_touch="true" *)wire [7:0] r_sdwMemWen_8;
(* dont_touch="true" *)wire [63:0] r_sdwMemData_64;
(* dont_touch="true" *)wire [31:0] w_sdwMemAddr_32;
(* dont_touch="true" *)wire [63:0] w_sdwMemData_64;

(* dont_touch="true" *)wire [31:0] w_lbGrfData_32;
(* dont_touch="true" *)wire [31:0] w_lhwGrfData_32;
(* dont_touch="true" *)wire [63:0] w_ldwGrfData_64;
(* dont_touch="true" *)wire [31:0] w_lwGrfData_32;

(* dont_touch="true" *)reg [1:0] r_lsuType_2;
(* dont_touch="true" *)wire [1:0] w_lsuType_2;

//dataUpdateSelector
(* dont_touch="true" *)wire w_driveToLoadSelector_1;
(* dont_touch="true" *)wire w_loadSelectorToDataUpdateSelector_1;
(* dont_touch="true" *)wire w_driveToStoreSelector_1;
(* dont_touch="true" *)wire w_storeSelectorToDataUpdateSelector_1;
(* dont_touch="true" *)cSelector2_2b_lsu dataUpdateSelector(
    .i_drive(i_lsuToDataUpdate_1),
    .i_data_2({i_store_1,i_load_1}), 
    .o_free(o_dataUpdateToLsu_1),
    .o_driveNext0(w_driveToLoadSelector_1), 
    .i_freeNext0(w_loadSelectorToDataUpdateSelector_1), 
    .o_data0_2(),
    .o_driveNext1(w_driveToStoreSelector_1), 
    .o_data1_2(), 
    .i_freeNext1(w_storeSelectorToDataUpdateSelector_1),
    .rst(rst)
);

// //暂存公共数据
// wire w_fire0Andfire1;
// assign w_fire0Andfire1 = w_driveToLoadSelector_1 | w_driveToStoreSelector_1;

// always@(posedge w_fire0Andfire1 or negedge rst)
// begin
// if(!rst)
//     begin
//         r_misaligned_1    <= 1'b0;
// 	end
// 	else   
//     begin

//         r_misaligned_1    <= i_misaligned_1;
// 	end
// end
// assign w_misaligned_1 = r_misaligned_1;

// loadSelector8
wire [7:0] w_loadValid_8;
assign w_loadValid_8 = i_stateValid_12[11:4];
wire [31:0] w_lIdleAddr_32;
wire [63:0] w_lIdleData_64;
wire [31:0] w_lbAddr_32;
wire [63:0] w_lbData_64;
wire [31:0] w_lhwAddr_32;
wire [63:0] w_lhwData_64;
wire [31:0] w_ldwAddr_32;
wire [63:0] w_ldwData_64;
wire [31:0] w_lwAddr_32;
wire [63:0] w_lwData_64;
wire [31:0] w_lhwmAddr_32;
wire [63:0] w_lhwmData_64;
wire [31:0] w_ldwmAddr_32;
wire [63:0] w_ldwmData_64;
wire [31:0] w_lwmAddr_32;
wire [63:0] w_lwmData_64;
wire w_lIdleMisaligned_1;
wire w_lIdleLoadSign_1;
wire w_lbMisaligned_1;
wire w_lbLoadSign_1;
wire w_lhwMisaligned_1;
wire w_lhwLoadSign_1;
wire w_ldwMisaligned_1;
wire w_ldwLoadSign_1;
wire w_lwMisaligned_1;
wire w_lwLoadSign_1;
wire w_lhwmMisaligned_1;
wire w_lhwmLoadSign_1;
wire w_ldwmMisaligned_1;
wire w_ldwmLoadSign_1;
wire w_lwmMisaligned_1;
wire w_lwmLoadSign_1;
(* dont_touch="true" *)cSelector8_106b_lsu loadSelector(
.i_drive(w_driveToLoadSelector_1),.i_data_106({i_misaligned_1,i_loadSign_1,i_memAddr_32,i_memData_64,w_loadValid_8}), .o_free(w_loadSelectorToDataUpdateSelector_1),
.o_driveNext0(w_lIdleDrive), .i_freeNext0(w_freeFlIdle),.o_data0_98({w_lIdleMisaligned_1,w_lIdleLoadSign_1,w_lIdleAddr_32,w_lIdleData_64}),
.o_driveNext1(w_lbDrive), .o_data1_98({w_lbMisaligned_1,w_lbLoadSign_1,w_lbAddr_32,w_lbData_64}), .i_freeNext1(w_freeFlb),
.o_driveNext2(w_lhwDrive), .i_freeNext2(w_freeFlhw),.o_data2_98({w_lhwMisaligned_1,w_lhwLoadSign_1,w_lhwAddr_32,w_lhwData_64}),
.o_driveNext3(w_ldwDrive), .o_data3_98({w_ldwMisaligned_1,w_ldwLoadSign_1,w_ldwAddr_32,w_ldwData_64}), .i_freeNext3(w_freeFldw),
.o_driveNext4(w_lwDrive), .o_data4_98({w_lwMisaligned_1,w_lwLoadSign_1,w_lwAddr_32,w_lwData_64}), .i_freeNext4(w_freeFlw),
.o_driveNext5(w_lhwmDrive), .o_data5_98({w_lhwmMisaligned_1,w_lhwmLoadSign_1,w_lhwmAddr_32,w_lhwmData_64}), .i_freeNext5(w_freeFlhwm),
.o_driveNext6(w_ldwmDrive), .o_data6_98({w_ldwmMisaligned_1,w_ldwmLoadSign_1,w_ldwmAddr_32,w_ldwmData_64}), .i_freeNext6(w_freeFldwm),
.o_driveNext7(w_lwmDrive), .o_data7_98({w_lwmMisaligned_1,w_lwmLoadSign_1,w_lwmAddr_32,w_lwmData_64}), .i_freeNext7(w_freeFlwm),
.rst(rst)
);

//所有的drive都须要延时后接入
wire w_lIdleDriveDelay_1;
wire w_lbDriveDelay_1;
wire w_lhwDriveDelay_1;
wire w_ldwDriveDelay_1;
wire w_lwDriveDelay_1;
wire w_lwDriveDelay1_1;
wire w_lhwmDriveDelay_1;
wire w_ldwmDriveDelay_1;
wire w_lwmDriveDelay_1;
(* dont_touch="true" *)delay6U outdelay1 (.inR(w_lIdleDrive), .outR(w_lIdleDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay6U outdelay2 (.inR(w_lbDrive), .outR(w_lbDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay8U outdelay3 (.inR(w_lhwDrive), .outR(w_lhwDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay6U outdelay4 (.inR(w_ldwDrive), .outR(w_ldwDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay8U outdelay51 (.inR(w_lwDrive), .outR(w_lwDriveDelay1_1), .rst(rst));
(* dont_touch="true" *)delay2U outdelay52 (.inR(w_lwDriveDelay1_1), .outR(w_lwDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay6U outdelay6 (.inR(w_lhwmDrive), .outR(w_lhwmDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay6U outdelay7 (.inR(w_ldwmDrive), .outR(w_ldwmDriveDelay_1), .rst(rst));
(* dont_touch="true" *)delay6U outdelay8 (.inR(w_lwmDrive), .outR(w_lwmDriveDelay_1), .rst(rst));
// load的fifo
// lIdleFifo 
wire [31:0] w_lIdleFifoToAddrMerge_32;
(* dont_touch="true" *)lIdleFifo_lsu lIdleFifo(
.i_drive(w_lIdleDriveDelay_1), .i_data_32(w_lIdleAddr_32), .o_free(w_freeFlIdle),.rst(rst),
.o_driveNext(w_driveFlIdle), .o_data_32(w_lIdleFifoToAddrMerge_32), .i_freeNext(w_free2lIdle)
);

// lbFifo
wire [33:0] w_lbFifoToDataMerge_34;
(* dont_touch="true" *)lbFifo_lsu lbFifo(
.i_drive(w_lbDriveDelay_1), .i_data_32(w_lbGrfData_32), .o_free(w_freeFlb),.rst(rst),
.o_driveNext(w_driveFlb), .o_data_34(w_lbFifoToDataMerge_34), .i_freeNext(w_free2lb)
);

// lhwFifo
wire [33:0] w_lhwFifoToDataMerge_34;
(* dont_touch="true" *)lhwFifo_lsu lhwFifo(
.i_drive(w_lhwDriveDelay_1), .i_data_32(w_lhwGrfData_32), .o_free(w_freeFlhw),.rst(rst),
.o_driveNext(w_driveFlhw), .o_data_34(w_lhwFifoToDataMerge_34), .i_freeNext(w_free2lhw)
);

// ldwFifo
wire [65:0] w_ldwFifoToDataMerge_66;
(* dont_touch="true" *)ldwFifo_lsu ldwFifo(
.i_drive(w_ldwDriveDelay_1), .i_data_64(w_ldwGrfData_64), .o_free(w_freeFldw),.rst(rst),
.o_driveNext(w_driveFldw), .o_data_66(w_ldwFifoToDataMerge_66), .i_freeNext(w_free2ldw)
);

// lwFifo
wire [33:0] w_lwFifoToDataMerge_34;
(* dont_touch="true" *)lwFifo_lsu lwFifo(
    .i_drive(w_lwDriveDelay1_1),
    .i_freeNext(w_free2lw),
    .rst(rst),
    .o_free(w_freeFlw),
    .o_driveNext(w_driveFlw),
    .i_data_32(w_lwGrfData_32),
    .o_data_34(w_lwFifoToDataMerge_34)
);

// lhwmFifo
wire [31:0] w_lhwmMemAddr_32;
wire [63:0] w_lhwmTemp_64;
(* dont_touch="true" *)lhwmFifo_lsu lhwmFifo(
    .i_drive(w_lhwmDriveDelay_1),
    .i_freeNext(w_free2lhwm),
    .rst(rst),
    .o_free(w_freeFlhwm),
    .o_driveNext(w_driveFlhwm),
    .i_data_96({w_lhwmAddr_32,w_lhwmData_64}),
    .o_data_96({w_lhwmMemAddr_32,w_lhwmTemp_64})
);

// ldwmFifo
wire [31:0] w_ldwmMemAddr_32;
wire [63:0] w_ldwmTemp_64;
(* dont_touch="true" *)ldwmFifo_lsu ldwmFifo(
    .i_drive(w_ldwmDriveDelay_1),
    .i_freeNext(w_free2ldwm),
    .rst(rst),
    .o_free(w_freeFldwm),
    .o_driveNext(w_driveFldwm),
    .i_data_96({w_ldwmAddr_32,w_ldwmData_64}),
    .o_data_96({w_ldwmMemAddr_32,w_ldwmTemp_64})
);

// lwmFifo
wire [31:0] w_lwmMemAddr_32;
wire [63:0] w_lwmTemp_64;
(* dont_touch="true" *)lwmFifo_lsu lwmFifo(
    .i_drive(w_lwmDriveDelay_1),
    .i_freeNext(w_free2lwm),
    .rst(rst),
    .o_free(w_freeFlwm),
    .o_driveNext(w_driveFlwm),
    .i_data_96({w_lwmAddr_32,w_lwmData_64}),
    .o_data_96({w_lwmMemAddr_32,w_lwmTemp_64})
);

// lb的写数据
//-------------------------------------big change---------------------------------------------------------//
//12/16 zwm add more condition
assign w_lbGrfData_32 = i_addrFromPeripheralFlag_1 ? {24'b0,w_lbData_64[7:0]} :
                        (w_lbAddr_32[2:0] == 3'b000 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[7]}},w_lbData_64[7:0]}: 
                         {24'b0,w_lbData_64[7:0]}:
                         w_lbAddr_32[2:0] == 3'b001 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[15]}},w_lbData_64[15:8]}:
                         {24'b0,w_lbData_64[15: 8]}:
                         w_lbAddr_32[2:0] == 3'b010 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[23]}},w_lbData_64[23:16]}: 
                         {24'b0,w_lbData_64[23:16]}:
                         w_lbAddr_32[2:0] == 3'b011 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[31]}},w_lbData_64[31:24]}: 
                         {24'b0,w_lbData_64[31:24]}:
                         w_lbAddr_32[2:0] == 3'b100 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[39]}},w_lbData_64[39:32]}: 
                         {24'b0,w_lbData_64[39:32]}:
                         w_lbAddr_32[2:0] == 3'b101 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[47]}},w_lbData_64[47:40]}: 
                         {24'b0,w_lbData_64[47:40]}:
                         w_lbAddr_32[2:0] == 3'b110 ? 
                         w_lbLoadSign_1 ? {{24{w_lbData_64[55]}},w_lbData_64[55:48]}: 
                         {24'b0,w_lbData_64[55:48]}:
                         w_lbLoadSign_1 ? {{24{w_lbData_64[63]}},w_lbData_64[63:56]}: 
                         {24'b0,w_lbData_64[63:56]});
//-----------------------------------change end-------------------------------------------------------//
// lhw的写数据
assign	w_lhwGrfData_32	= w_lhwMisaligned_1 ? 
                          (w_lhwAddr_32[2:0] == 3'b111 ? 
                          (w_lhwmLoadSign_1 ? {{16{w_lhwData_64[7]}},w_lhwData_64[7:0],w_lhwmTemp_64[63:56]} : 
                          {{16{1'b0}},w_lhwData_64[7:0],w_lhwmTemp_64[63:56]}) : 
                          32'b0):
                          (
                            w_lhwAddr_32[2:0] == 3'b000 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[15]}},w_lhwData_64[15: 0]}: {{16{1'b0}},w_lhwData_64[15: 0]}:
                            w_lhwAddr_32[2:0] == 3'b001 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[23]}},w_lhwData_64[23: 8]}: {{16{1'b0}},w_lhwData_64[23: 8]}:
                            w_lhwAddr_32[2:0] == 3'b010 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[31]}},w_lhwData_64[31:16]}: {{16{1'b0}},w_lhwData_64[31:16]}:
                            w_lhwAddr_32[2:0] == 3'b011 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[39]}},w_lhwData_64[39:24]}: {{16{1'b0}},w_lhwData_64[39:24]}:
                            w_lhwAddr_32[2:0] == 3'b100 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[47]}},w_lhwData_64[47:32]}: {{16{1'b0}},w_lhwData_64[47:32]}:
                            w_lhwAddr_32[2:0] == 3'b101 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[55]}},w_lhwData_64[55:40]}: {{16{1'b0}},w_lhwData_64[55:40]}:
                            w_lhwAddr_32[2:0] == 3'b110 ? w_lhwLoadSign_1 ? {{16{w_lhwData_64[63]}},w_lhwData_64[63:48]}: {{16{1'b0}},w_lhwData_64[63:48]}:
                            32'b0
                          );
// ldw的写数据
assign	w_ldwGrfData_64	= w_ldwMisaligned_1 ? 
                          (w_ldwAddr_32[2:0] == 3'b100 ? 
                           {w_ldwData_64[31:0],w_ldwmTemp_64[63:32]} : 64'b0
                           ):
                          (
                            w_ldwAddr_32[2:0] == 3'b000 ? w_ldwData_64 : 64'b0
                          );
//lw的数据 
//-------------------------------------big change---------------------------------------------------------//
//12/16 zwm add more condition
assign  w_lwGrfData_32  = i_addrFromPeripheralFlag_1 ? w_lwData_64[31:0] : 
                          (w_lwMisaligned_1 ? 
                          (w_lwAddr_32[2:0] == 3'b101 ? {w_lwData_64[7:0],w_lwmTemp_64[63:40]}:
                           w_lwAddr_32[2:0] == 3'b110 ? {w_lwData_64[15:0],w_lwmTemp_64[63:48]}:
                           w_lwAddr_32[2:0] == 3'b111 ? {w_lwData_64[23:0],w_lwmTemp_64[63:56]}: 
                           32'b0):
                           (
                           w_lwAddr_32[2:0] == 3'b100 ? w_lwData_64[63:32]:
                           w_lwAddr_32[2:0] == 3'b011 ? w_lwData_64[55:24]:
                           w_lwAddr_32[2:0] == 3'b010 ? w_lwData_64[47:16]:
                           w_lwAddr_32[2:0] == 3'b001 ? w_lwData_64[39:8]:
                           w_lwAddr_32[2:0] == 3'b000 ? w_lwData_64[31:0]: 
                           32'b0
                           ));
//-----------------------------------change end-------------------------------------------------------//

// lidle lhwm ldwm lwm的merge
wire w_f2lidleMerge;
wire w_drvFlidleMerge;
wire [31:0] w_loadAddr_32;

(* dont_touch="true" *)cMutexMerge4_32b_lsu lidleMerge(
    .i_drive0(w_driveFlIdle),
    .i_drive1(w_driveFlhwm),
    .i_drive2(w_driveFlwm),
    .i_drive3(w_driveFldwm),
    .i_data0_32(w_lIdleFifoToAddrMerge_32),
    .i_data1_32(w_lhwmMemAddr_32),
    .i_data2_32(w_lwmMemAddr_32),
    .i_data3_32(w_ldwmMemAddr_32),
    .i_freeNext(w_f2lidleMerge),
    .rst(rst),
    .o_free0(w_free2lIdle),
    .o_free1(w_free2lhwm),
    .o_free2(w_free2lwm),
    .o_free3(w_free2ldwm),
    .o_driveNext(w_drvFlidleMerge),
    .o_data_32(w_loadAddr_32)
);


// lb lhw ldw lw的merge
//first load i_dHi_4,then i_dLo_4
//12/12 zwm ldw is not need to change the position between dh and dl
(* dont_touch="true" *)cMutexMerge4_74b_lsu lbMerge(
    .i_drive0(w_driveFlb),
    .i_drive1(w_driveFlhw),
    .i_drive2(w_driveFlw),
    .i_drive3(w_driveFldw),
    .i_data0_74({i_dHi_4,i_dLo_4,w_lbFifoToDataMerge_34[33:2],{32{1'b0}},w_lbFifoToDataMerge_34[1:0]}),
    .i_data1_74({i_dHi_4,i_dLo_4,w_lhwFifoToDataMerge_34[33:2],{32{1'b0}},w_lhwFifoToDataMerge_34[1:0]}),
    .i_data2_74({i_dHi_4,i_dLo_4,w_lwFifoToDataMerge_34[33:2],{32{1'b0}},w_lwFifoToDataMerge_34[1:0]}),
    .i_data3_74({i_dHi_4,i_dLo_4,w_ldwFifoToDataMerge_66}),
    .i_freeNext(i_writebackFreeToDataUpate_1),
    .rst(rst),
    .o_free0(w_free2lb),
    .o_free1(w_free2lhw),
    .o_free2(w_free2lw),
    .o_free3(w_free2ldw),
    .o_driveNext(o_dataUpdateDriveToWriteback_1),
    .o_data_74(o_dataUpdateToWritebackData_74)
);


//暂存store公共信号
//加个延时
wire w_driveToStoreSelectorDelay_1;
(* dont_touch="true" *)delay4U outdelay0(.inR(w_driveToStoreSelector_1), .outR(w_driveToStoreSelectorDelay_1),.rst(rst));
always@(posedge w_driveToStoreSelectorDelay_1 or negedge rst)
begin
	if(!rst)
    begin
        r_memAddr_32  <= 32'h0000_0000;
        r_storeData_64<=64'b0;
	    r_lsuType_2 <= 2'b00;
        r_misaligned_1    <= 1'b0;
        r_addrFromPeripheralFlag_1 <= 1'b0;
	end
	else   
    begin
        r_memAddr_32    <= i_memAddr_32;
	    r_lsuType_2    <= i_lsuType_2;
        r_storeData_64 <= i_storeData_64;
        r_misaligned_1    <= i_misaligned_1;
        r_addrFromPeripheralFlag_1 <= i_addrFromPeripheralFlag_1;
	end
end
assign w_memAddr_32    = r_memAddr_32;
assign w_lsuType_2    = r_lsuType_2;   
assign w_storeData_64 = r_storeData_64; 
assign w_misaligned_1 = r_misaligned_1;
assign w_addrFromPeripheralFlag_1 = r_addrFromPeripheralFlag_1;

wire [3:0] w_storeValid_4;
assign w_storeValid_4 = i_stateValid_12[3:0];
wire [63:0] w_storeData1_64;
wire [63:0] w_storeData2_64;
wire [63:0] w_storeData3_64;
wire [63:0] w_storeData4_64; 
wire w_driveToStoreSelectorDelay1_1,w_driveToStoreSelectorDelay2_1;
//11/26 zwm change 4U to 8U
(* dont_touch="true" *)delay8U storeOutdelay0(.inR(w_driveToStoreSelectorDelay_1), .outR(w_driveToStoreSelectorDelay1_1),.rst(rst));
// (* dont_touch="true" *)delay4U storeOutdelay1(.inR(w_driveToStoreSelectorDelay1_1), .outR(w_driveToStoreSelectorDelay2_1),.rst(rst));
(* dont_touch="true" *)cSelector4_68b_lsu storeSelector(
.i_drive(w_driveToStoreSelectorDelay1_1),.i_data_68({i_storeData_64,w_storeValid_4}), .o_free(w_storeSelectorToDataUpdateSelector_1),
.o_driveNext0(w_sIdleDrive), .i_freeNext0(w_freeFsIdle),.o_data0_64(w_storeData1_64),
.o_driveNext1(w_swDrive), .o_data1_64(w_storeData2_64), .i_freeNext1(w_freeFsw),
.o_driveNext2(w_shwDrive), .i_freeNext2(w_freeFshw),.o_data2_64(w_storeData3_64),
.o_driveNext3(w_sdwDrive), .o_data3_64(w_storeData4_64), .i_freeNext3(w_freeFsdw),
.rst(rst)
);

// store的fifo
// sidleFifo
(* dont_touch="true" *)sidleFifo_lsu sidleFifo(
    .i_drive(w_sIdleDrive),
    .i_freeNext(w_free2sidle),
    .rst(rst),
    .o_free(w_freeFsIdle),
    .o_driveNext(w_driveFsidle),
    .i_data_104({w_sIdleMemAddr_32,w_sIdleMemData_64,w_sIdleMemWen_8}),
    .o_data_104({r_sIdleMemAddr_32,r_sIdleMemData_64,r_sIdleMemWen_8})
);
// swFifo
(* dont_touch="true" *)swFifo_lsu swFifo(
    .i_drive(w_swDrive),
    .i_freeNext(w_free2sw),
    .rst(rst),
    .o_free(w_freeFsw),
    .o_driveNext(w_driveFsw),
    .i_data_104({w_swMemAddr_32,w_swMemData_64,w_swMemWen_8}),
    .o_data_104({r_swMemAddr_32,r_swMemData_64,r_swMemWen_8})
);
// shwFifo
(* dont_touch="true" *)shwFifo_lsu shwFifo(
    .i_drive(w_shwDrive),
    .i_freeNext(w_free2shw),
    .rst(rst),
    .o_free(w_freeFshw),
    .o_driveNext(w_driveFshw),
    .i_data_104({w_shwMemAddr_32,w_shwMemData_64,8'b0000_0001}),
    .o_data_104({r_shwMemAddr_32,r_shwMemData_64,r_shwMemWen_8})
);
// sdwFifo
(* dont_touch="true" *)sdwFifo_lsu sdwFifo(
    .i_drive(w_sdwDrive),
    .i_freeNext(w_free2sdw),
    .rst(rst),
    .o_free(w_freeFsdw),
    .o_driveNext(w_driveFsdw),
    .i_data_104({w_sdwMemAddr_32,w_sdwMemData_64,8'b0000_1111}),
    .o_data_104({r_sdwMemAddr_32,r_sdwMemData_64,r_sdwMemWen_8})
);
// store的一些线
// store的三个状态下是否需要写mem
assign  w_sIdleMemWen_8 = r_sIdleMemWenTemp_8;
assign	w_swMemWen_8    = w_swMemAddr_32[2:0] == 3'b100 ? 8'b0000_0000 :
				          w_swMemAddr_32[2:0] == 3'b101 ? 8'b0000_0001 :
				          w_swMemAddr_32[2:0] == 3'b110 ? 8'b0000_0011 :
				          w_swMemAddr_32[2:0] == 3'b111 ? 8'b0000_0111 : 8'b0000_0000;

// store三个状态下需要写入mem的数据
assign  w_sIdleMemData_64 =	r_sIdleMemDataTemp_64;
assign  w_shwMemData_64   =	{56'b0,w_storeData_64[15:8]};
assign  w_sdwMemData_64   =	{32'b0,w_storeData_64[63:32]};
assign	w_swMemData_64    = w_swMemAddr_32[2:0] == 3'b100 ? 64'b0:
				            w_swMemAddr_32[2:0] == 3'b101 ? {56'b0,w_storeData_64[31:24]}:
				            w_swMemAddr_32[2:0] == 3'b110 ? {48'b0,w_storeData_64[31:16]}:
				            w_swMemAddr_32[2:0] == 3'b111 ? {40'b0,w_storeData_64[31:8]}:
                            64'b0;

assign w_sIdleMemAddr_32 = w_memAddr_32;
assign w_swMemAddr_32  = w_memAddr_32 + 32'h8;
assign w_shwMemAddr_32 = w_memAddr_32 + 32'h8;
assign w_sdwMemAddr_32 = w_memAddr_32 + 32'h8;

//store的数据更新
//------------------------------------------big change---------------------------------//
//12/16 zwm add new condition
always@(*)begin
if(!rst)begin
    r_sIdleMemDataTemp_64 = 64'b0;
	r_sIdleMemWenTemp_8   = 8'b0;
end else
begin
	if(!w_misaligned_1) 
    begin
        if(w_addrFromPeripheralFlag_1)begin
            case (w_lsuType_2)
                2'b11:
                begin
                    r_sIdleMemDataTemp_64 = {32'b0,w_storeData_64[31:0]};
                    r_sIdleMemWenTemp_8   = 8'b0000_1111;
                end 
                2'b00: 
                begin  
                    r_sIdleMemDataTemp_64 = {{56{1'b0}},w_storeData_64[7:0]};
                    r_sIdleMemWenTemp_8   = 8'b0000_0001;
                end
            endcase
        end else begin
            case (w_lsuType_2)
            2'b11:	
            begin
                case (w_memAddr_32[2:0])
                3'b100:
                begin
                    r_sIdleMemDataTemp_64 = {w_storeData_64[31:0],32'b0};
                    r_sIdleMemWenTemp_8   = 8'b1111_0000;
                end
                3'b011:
                begin
                    r_sIdleMemDataTemp_64 = {8'b0,w_storeData_64[31:0],24'b0};
                    r_sIdleMemWenTemp_8   = 8'b0111_1000;
                end
                3'b010:
                begin
                    r_sIdleMemDataTemp_64 = {16'b0,w_storeData_64[31:0],16'b0};
                    r_sIdleMemWenTemp_8   = 8'b0011_1100;
                end
                3'b001:
                begin
                    r_sIdleMemDataTemp_64 = {24'b0,w_storeData_64[31:0],8'b0};
                    r_sIdleMemWenTemp_8   = 8'b0001_1110;
                end
                3'b000:
                begin
                    r_sIdleMemDataTemp_64 = {32'b0,w_storeData_64[31:0]};
                    r_sIdleMemWenTemp_8   = 8'b0000_1111;
                end
                default:
                begin 
                    r_sIdleMemDataTemp_64 = 64'b0;  
                    r_sIdleMemWenTemp_8   = 8'b0000_0000; 
                end
                endcase 	        
            end
            2'b01:	
            begin 
                case (w_memAddr_32[2:0])
                3'b110:	
                begin  
                    r_sIdleMemDataTemp_64 = {w_storeData_64[15:0],48'b0};
                    r_sIdleMemWenTemp_8   = 8'b1100_0000;
                end
                3'b101:
                begin  
                    r_sIdleMemDataTemp_64 = {8'b0,w_storeData_64[15:0],40'b0};
                    r_sIdleMemWenTemp_8   = 8'b0110_0000;
                end
                3'b100:	
                begin  
                    r_sIdleMemDataTemp_64 = {16'b0,w_storeData_64[15:0],32'b0};
                    r_sIdleMemWenTemp_8   = 8'b0011_0000;
                end
                3'b011:	
                begin  
                    r_sIdleMemDataTemp_64 = {24'b0,w_storeData_64[15:0],24'b0};
                    r_sIdleMemWenTemp_8   = 8'b0001_1000;
                end
                3'b010:
                begin  
                    r_sIdleMemDataTemp_64 = {32'b0,w_storeData_64[15:0],16'b0};
                    r_sIdleMemWenTemp_8   = 8'b0000_1100;
                end
                3'b001:	
                begin  
                    r_sIdleMemDataTemp_64 = {40'b0,w_storeData_64[15:0],8'b0};
                    r_sIdleMemWenTemp_8   = 8'b0000_0110;
                end
                3'b000:	
                begin  
                    r_sIdleMemDataTemp_64 = {48'b0,w_storeData_64[15:0]};
                    r_sIdleMemWenTemp_8   = 8'b0000_0011;
                end
                default:
                begin 
                    r_sIdleMemDataTemp_64 = 64'b0;  
                    r_sIdleMemWenTemp_8   = 8'b0000_0000; 
                end
                endcase                                                                            
            end
            2'b10:	
            begin 
                case (w_memAddr_32[2:0])
                3'b000:	
                begin  
                    r_sIdleMemDataTemp_64 = w_storeData_64;
                    r_sIdleMemWenTemp_8   = 8'b1111_1111;
                end
                default:
                begin 
                    r_sIdleMemDataTemp_64 = 64'b0;  
                    r_sIdleMemWenTemp_8   = 8'b0000_0000; 
                end
                endcase                                                                            
            end
            2'b00:  
            begin 
                case (w_memAddr_32[2:0])
                3'b111:	
                begin  
                    r_sIdleMemDataTemp_64 = {w_storeData_64[7:0],{56{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b1000_0000;
                end
                3'b110:	
                begin  
                    r_sIdleMemDataTemp_64 = {{8{1'b0}},w_storeData_64[7:0],{48{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0100_0000;
                end
                3'b101:	
                begin  
                    r_sIdleMemDataTemp_64 = {{16{1'b0}},w_storeData_64[7:0],{40{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0010_0000;
                end
                3'b100:	
                begin  
                    r_sIdleMemDataTemp_64 = {{24{1'b0}},w_storeData_64[7:0],{32{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0001_0000;
                end
                3'b011:	
                begin  
                    r_sIdleMemDataTemp_64 = {{32{1'b0}},w_storeData_64[7:0],{24{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0000_1000;
                end
                3'b010:	
                begin  
                    r_sIdleMemDataTemp_64 = {{40{1'b0}},w_storeData_64[7:0],{16{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0000_0100;
                end
                3'b001:	
                begin  
                    r_sIdleMemDataTemp_64 = {{48{1'b0}},w_storeData_64[7:0],{8{1'b0}}};
                    r_sIdleMemWenTemp_8   = 8'b0000_0010;
                end
                3'b000:	
                begin  
                    r_sIdleMemDataTemp_64 = {{56{1'b0}},w_storeData_64[7:0]};
                    r_sIdleMemWenTemp_8   = 8'b0000_0001;
                end
                endcase
            end
            endcase
        end
	end
	else 
    begin
	    case (w_lsuType_2)
        2'b11:	
        begin 
			case (w_memAddr_32[2:0])
            3'b111: 
            begin  
                r_sIdleMemDataTemp_64 = {w_storeData_64[7:0],{56{1'b0}}};
                r_sIdleMemWenTemp_8   = 8'b1000_0000;
            end
            3'b110: 
            begin  
                r_sIdleMemDataTemp_64 = {w_storeData_64[15:0],{48{1'b0}}};
                r_sIdleMemWenTemp_8   = 8'b1100_0000;
			end
            3'b101: 
            begin  
                r_sIdleMemDataTemp_64 = {w_storeData_64[23:0],{40{1'b0}}};
                r_sIdleMemWenTemp_8   = 8'b1110_0000;
            end
            3'b000: 
            begin  
                r_sIdleMemDataTemp_64 = 64'b0;
                r_sIdleMemWenTemp_8   = 8'b0000_0000;
            end
            endcase
            end
        2'b01:	
        begin 
		    r_sIdleMemDataTemp_64 = {w_storeData_64[7:0],{56{1'b0}}};
            r_sIdleMemWenTemp_8   = 8'b1000_0000;
        end
        2'b10:	
        begin 
		    r_sIdleMemDataTemp_64 = {w_storeData_64[31:0],{32{1'b0}}};
            r_sIdleMemWenTemp_8   = 8'b1111_0000;
        end
        default: 		
        begin  
		    r_sIdleMemDataTemp_64 = 64'b0;
            r_sIdleMemWenTemp_8   = 8'b0000_0000;
        end
        endcase
	end
end
end
//-----------------------------change end------------------------------------//
// sidle的merge
// sidle shw sdw sw的merge

wire w_f2sidleMerge;
wire w_drvFsidleMerge;
wire [103:0] w_storeDataAddr_104;
(* dont_touch="true" *)cMutexMerge4_104b_lsu sidleMerge(
    .i_drive0(w_driveFsidle),
    .i_drive1(w_driveFsw),
    .i_drive2(w_driveFshw),
    .i_drive3(w_driveFsdw),
    .i_data0_104({r_sIdleMemData_64, r_sIdleMemAddr_32, r_sIdleMemWen_8}),
    .i_data1_104({r_swMemData_64, r_swMemAddr_32, r_swMemWen_8}),
    .i_data2_104({r_shwMemData_64, r_shwMemAddr_32, r_shwMemWen_8 }),
    .i_data3_104({r_sdwMemData_64, r_sdwMemAddr_32, r_sdwMemWen_8 }),
    .i_freeNext(w_f2sidleMerge),
    .rst(rst),
    .o_free0(w_free2sidle),
    .o_free1(w_free2sw),
    .o_free2(w_free2shw),
    .o_free3(w_free2sdw),
    .o_driveNext(w_drvFsidleMerge),
    .o_data_104(w_storeDataAddr_104)
);

// 最后的merge

(* dont_touch="true" *)cMutexMerge2_104b_lsu outMerge(
    .i_drive0(w_drvFlidleMerge),
    .i_drive1(w_drvFsidleMerge),
    .i_data0_104({{64{1'b0}}, w_loadAddr_32,{8{1'b0}}}),
    .i_data1_104(w_storeDataAddr_104),
    .i_freeNext(i_dataRoutFreeToDataUpate_1),
    .rst(rst),
    .o_free0(w_f2lidleMerge),
    .o_free1(w_f2sidleMerge),
    .o_driveNext(o_dataUpdateDriveToMem_1),
    .o_data_104({o_memData_64, o_memAddr_32, o_memWen_8})
);

endmodule
