

`timescale 1ns / 1ps

module cSplitter2_103b_wb(
i_drive, i_data_103, o_free,
o_driveNext0, i_freeNext0, o_data0_98,
o_driveNext1, o_data1_5, i_freeNext1,
rst);

input i_drive;
input i_freeNext0,i_freeNext1;
input rst;
input [102:0] i_data_103;

output o_free;
output o_driveNext0,o_driveNext1;
output [97:0] o_data0_98;
output [4:0] o_data1_5;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire;
wire w_freeNext,w_free0Next,w_free1Next;
wire w_driveNext0;
wire w_sendFree;
wire w_sendDrive;
wire w_firstTrig, w_firstReq;
wire w_secondTrig, w_secondReq;
wire w_delayFree0Next,w_delayFree1Next;
(* dont_touch="true" *)delay4U indelay1 (.inR(i_freeNext0), .outR(w_delayFree0Next), .rst(rst));

(* dont_touch="true" *)delay4U indelay2 (.inR(i_freeNext1), .outR(w_delayFree1Next), .rst(rst));

(*KEEP="TRUE"*) wire [1:0] w_rdWen_2;
(*KEEP="TRUE"*) wire w_writeRd_1,w_bfc_1,w_bfi_1,w_s_1,w_sbfx,w_ubfx;
(*KEEP="TRUE"*) wire [3:0] w_nzcv_4;
(*KEEP="TRUE"*) wire w_msr_1;
(*KEEP="TRUE"*) wire [7:0] w_prfAddr_8;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrH_4;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrL_4;
(*KEEP="TRUE"*) wire [63:0] w_data_64,w_dataTopro_64;
(*KEEP="TRUE"*) wire [4:0] w_msbit_5,w_lsbit_5;

assign {w_prfAddr_8,w_grfAddrH_4,w_grfAddrL_4,w_data_64,
           w_rdWen_2,w_s_1,w_msr_1,w_bfi_1,w_bfc_1,w_sbfx,w_ubfx,w_msbit_5,w_lsbit_5,w_nzcv_4,w_writeRd_1} = i_data_103;

assign o_data0_98 = {w_prfAddr_8,w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2,w_msr_1,w_msbit_5,w_lsbit_5,w_bfi_1,w_bfc_1,w_sbfx,w_ubfx,w_writeRd_1};
assign o_data1_5 = {w_s_1,w_nzcv_4};


(* dont_touch="true" *)delay2U outdelay1 (.inR(w_delayFree0Next), .outR(w_free0Next), .rst(rst));

assign w_firstTrig = w_delayFree0Next | w_sendDrive;

contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

(* dont_touch="true" *)delay2U outdelay2 (.inR(w_delayFree1Next), .outR(w_free1Next), .rst(rst));

assign w_secondTrig = w_delayFree1Next | w_sendDrive;

contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_freeNext = w_free0Next | w_free1Next;
assign w_sendFree = w_freeNext & !(w_secondReq | w_firstReq);
assign w_sendDrive = i_drive;
assign o_free = w_sendFree;
assign o_driveNext0 = i_drive;
assign o_driveNext1 = i_drive;
endmodule

