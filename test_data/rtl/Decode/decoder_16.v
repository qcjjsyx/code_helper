/*=============================================================
Project:ARMCPU
Module:decoder_16
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:decoder_16 or decoder
==============================================================*/

`timescale 1ps/1ps

module decoder_16 (
    input i_drive,
    input [63:0] i_data_64,
    input i_isInInt, // 2025.1.3 zlt-->add
    output o_free,
    output o_drive1,
    output [186:0] o_data_187,
    output [3:0] o_excNum_4,
    input i_free,
        //12/27 zwm add nzcv wen
    output [3:0] o_nzcvWen_4,
    input rst
);


assign o_drive1 = i_drive;
assign o_free = i_free;


(* dont_touch="true" *) wire [15:0] w_int_16;
(* dont_touch="true" *) wire [31:0] w_pc_32;
(* dont_touch="true" *) wire [2:0] w_imm_3;
(* dont_touch="true" *) wire [4:0] w_imm_5;
(* dont_touch="true" *) wire [6:0] w_imm_7;
(* dont_touch="true" *) wire [7:0] w_imm_8;
(* dont_touch="true" *) wire [10:0] w_imm_11;
(* dont_touch="true" *) wire [31:0] w_imm_32;

(* dont_touch="true" *) wire [2:0] w_rd_3;
(* dont_touch="true" *) wire [3:0] w_rd_4, w_rdLo_4;
(* dont_touch="true" *) wire [3:0] w_rn_4;
(* dont_touch="true" *) wire [2:0] w_rdn_3;
(* dont_touch="true" *) wire [3:0] w_rm_4;


(* dont_touch="true" *) wire w_movR_1, w_lslI_1, w_lsrI_1, w_asrI_1;
(* dont_touch="true" *) wire w_addR_1, w_subR_1;
(* dont_touch="true" *) wire w_addI3_1, w_subI3_1;
(* dont_touch="true" *) wire w_movI_1, w_cmpI_1, w_addI8_1, w_subI8_1;
(* dont_touch="true" *) wire w_andR_1, w_eorR_1, w_lslR_1, w_lsrR_1, w_asrR_1, w_adcR_1, w_sbcR_1, w_rorR_1, w_tstR_1, w_rsbI_1, 
                             w_cmpR_1, w_cmnR_1, w_orrR_1, w_mul_1, w_bicR_1, w_mvnR_1;
(* dont_touch="true" *) wire w_addHR_1, w_cmpHR_1, w_movHR_1, w_bx_1, w_blx_1;
(* dont_touch="true" *) wire w_ldrPc_1;
(* dont_touch="true" *) wire w_strR_1, w_strhR_1, w_strbR_1, w_ldrsbR_1, w_ldrR_1, w_ldrhR_1, w_ldrbr_1, w_ldrshR_1;
(* dont_touch="true" *) wire w_strI5_1, w_ldrI5_1, w_strbI_1, w_ldrbI_1;
(* dont_touch="true" *) wire w_strhI_1, w_ldrhI_1;
(* dont_touch="true" *) wire w_strI8_1, w_ldrI8_1;
(* dont_touch="true" *) wire w_adr_1, w_addSpI8_1;
(* dont_touch="true" *) wire w_stmia_1, w_ldmia_1;
(* dont_touch="true" *) wire w_cB_1, w_ucB_1;
(* dont_touch="true" *) wire w_addSpI7_1, w_subSp_1;
(* dont_touch="true" *) wire w_sxth_1, w_sxtb_1, w_uxth_1, w_uxtb_1;
(* dont_touch="true" *) wire w_cbz_1, w_cbnz_1;
(* dont_touch="true" *) wire w_push_1, w_pop_1;
(* dont_touch="true" *) wire w_rev_1, w_rev16_1, w_revsh_1;
(* dont_touch="true" *) wire w_nop_1, w_yield_1, w_wfe_1, w_wfi_1, w_sev_1;
(* dont_touch="true" *) wire w_ifThen_1;

(* dont_touch="true" *) wire [2:0] w_op_3;
(* dont_touch="true" *) wire [3:0] w_op_4;
(* dont_touch="true" *) wire [4:0] w_op_5;
(* dont_touch="true" *) wire [5:0] w_op_6;
(* dont_touch="true" *) wire [7:0] w_op_8;
(* dont_touch="true" *) wire w_funct_1;
(* dont_touch="true" *) wire [1:0] w_funct_2;
(* dont_touch="true" *) wire [2:0] w_funct_3;
(* dont_touch="true" *) wire [3:0] w_funct_4;
(* dont_touch="true" *) wire w_functL_1;
(* dont_touch="true" *) wire [3:0] w_firstcond_4, w_mask_4;
(* dont_touch="true" *) wire [3:0] w_cond_4;
(* dont_touch="true" *) wire [15:0] w_zero_16;

assign {w_pc_32, w_zero_16, w_int_16} = i_data_64;

assign w_funct_1 = w_int_16[9];
assign w_funct_2 = w_int_16[12:11];
assign w_funct_3 = w_int_16[11:9];
assign w_funct_4 = w_int_16[9:6];
assign w_functL_1 = w_int_16[11];
assign w_firstcond_4 = w_int_16[7:4];
assign w_mask_4 = w_int_16[3:0];
assign w_cond_4 = w_int_16[11:8];

assign w_op_3 = w_int_16[15:13];
assign w_op_4 = w_int_16[15:12];
assign w_op_5 = w_int_16[15:11];
assign w_op_6 = w_int_16[15:10];
assign w_op_8 = w_int_16[15:8];

// shift by immm,move register
(* dont_touch="true" *) wire w_shiftIAndMobeR_1;
assign w_movR_1 = (w_op_3 == 3'b000) & (w_funct_2 == 2'b00) & (w_imm_5 == 5'b00000);
assign w_lslI_1 = (w_op_3 == 3'b000) & (w_funct_2 == 2'b00) & (w_imm_5 != 5'b00000);
assign w_lsrI_1 = (w_op_3 == 3'b000) & (w_funct_2 == 2'b01);
assign w_asrI_1 = (w_op_3 == 3'b000) & (w_funct_2 == 2'b10);
assign w_shiftIAndMobeR_1 = w_movR_1 | w_lslI_1 | w_lsrI_1 | w_asrI_1;

// add/sub reg
(* dont_touch="true" *) wire w_addSubR_1;
assign w_addR_1 = (w_op_6 == 6'b000110) & (w_funct_1 == 1'b0);
assign w_subR_1 = (w_op_6 == 6'b000110) & (w_funct_1 == 1'b1);
assign w_addSubR_1 = w_addR_1 | w_subR_1;

// add/sub imm3
(* dont_touch="true" *) wire w_addSubI3_1;
assign w_addI3_1 = (w_op_6 == 6'b000111) & (w_funct_1 == 1'b0);
assign w_subI3_1 = (w_op_6 == 6'b000111) & (w_funct_1 == 1'b1);
assign w_addSubI3_1 = w_addI3_1 | w_subI3_1;

// add/sub/com/mov imm8
(* dont_touch="true" *) wire w_addSubComMovI8_1;
(* dont_touch="true" *) wire w_addSubI8_1;
assign w_movI_1 = (w_op_3 == 3'b001) & (w_funct_2 == 2'b00);
assign w_cmpI_1 = (w_op_3 == 3'b001) & (w_funct_2 == 2'b01);
assign w_addI8_1 = (w_op_3 == 3'b001) & (w_funct_2 == 2'b10);
assign w_subI8_1 = (w_op_3 == 3'b001) & (w_funct_2 == 2'b11);
assign w_addSubComMovI8_1 = w_movI_1 | w_cmpI_1 | w_addI8_1 | w_subI8_1;
assign w_addSubI8_1 = w_addI8_1 | w_subI8_1 | w_cmpI_1;

// data-processing reg
(* dont_touch="true" *) wire w_dataProcessingR_1;
(* dont_touch="true" *) wire w_dataProcessingRNotMvn_1;
assign w_andR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0000);
assign w_eorR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0001);
assign w_lslR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0010);
assign w_lsrR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0011);
assign w_asrR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0100);
assign w_adcR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0101);
assign w_sbcR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0110);
assign w_rorR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b0111);
assign w_tstR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1000);
assign w_rsbI_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1001); // 第二个操作数为全0的立即数
assign w_cmpR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1010);
assign w_cmnR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1011);
assign w_orrR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1100);
assign w_mul_1  = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1101);
assign w_bicR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1110);
assign w_mvnR_1 = (w_op_6 == 6'b010000) & (w_funct_4 == 4'b1111);
assign w_dataProcessingR_1 = w_andR_1 | w_eorR_1 | w_lslR_1 | w_lsrR_1 | w_asrR_1 
                           | w_adcR_1| w_sbcR_1 | w_rorR_1 | w_tstR_1 | w_rsbI_1 
                           | w_cmpR_1 | w_cmnR_1 | w_orrR_1 | w_mul_1 | w_bicR_1 | w_mvnR_1;

assign w_dataProcessingRNotMvn_1 = w_andR_1 | w_eorR_1 | w_lslR_1 | w_lsrR_1 | w_asrR_1 
                                 | w_adcR_1| w_sbcR_1 | w_rorR_1 | w_tstR_1 
                                 | w_cmpR_1 | w_cmnR_1 | w_orrR_1 | w_mul_1 | w_bicR_1;

// special data processing
(* dont_touch="true" *) wire w_specialDataPro_1;
(* dont_touch="true" *) wire w_speDataAdd_1;
assign w_addHR_1 = (w_op_6 == 6'b010001) & (w_int_16[9:8] == 2'b00);
assign w_cmpHR_1 = (w_op_6 == 6'b010001) & (w_int_16[9:8] == 2'b01);
assign w_movHR_1 = (w_op_6 == 6'b010001) & (w_int_16[9:8] == 2'b10);
assign w_specialDataPro_1 = w_addHR_1 | w_cmpHR_1 | w_movHR_1;
assign w_speDataAdd_1 = w_addHR_1 | w_cmpHR_1;

// branch/exchange
(* dont_touch="true" *) wire w_bAndBlx_1;
assign w_bx_1  = (w_op_6 == 6'b010001) & (w_int_16[9:8] == 2'b11) & (w_int_16[7] == 1'b0);
assign w_blx_1 = (w_op_6 == 6'b010001) & (w_int_16[9:8] == 2'b11) & (w_int_16[7] == 1'b1);
assign w_bAndBlx_1 = w_bx_1 | w_blx_1;

// load from literal pool
assign w_ldrPc_1 = (w_op_5 == 5'b01001);

// load/store reg offset
(* dont_touch="true" *) wire w_loadStoreReg_1;
assign w_strR_1   = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b000); 
assign w_strhR_1  = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b001); 
assign w_strbR_1  = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b010); 
assign w_ldrsbR_1 = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b011); 
assign w_ldrR_1   = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b100); 
assign w_ldrhR_1  = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b101); 
assign w_ldrbr_1  = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b110); 
assign w_ldrshR_1 = (w_op_4 == 4'b0101) & (w_funct_3 == 3'b111);
assign w_loadStoreReg_1 = w_strR_1 | w_strhR_1 | w_strbR_1 | w_ldrsbR_1 
                        | w_ldrR_1 | w_ldrhR_1 | w_ldrbr_1 | w_ldrshR_1; 

// load/store word/byte imm offset
(* dont_touch="true" *) wire w_loadStoreWordByteI_1;
assign w_strI5_1 = (w_op_3 == 3'b011) & (w_funct_2 == 2'b00);
assign w_ldrI5_1 = (w_op_3 == 3'b011) & (w_funct_2 == 2'b01);
assign w_strbI_1 = (w_op_3 == 3'b011) & (w_funct_2 == 2'b10);
assign w_ldrbI_1 = (w_op_3 == 3'b011) & (w_funct_2 == 2'b11);
assign w_loadStoreWordByteI_1 = w_strI5_1 | w_ldrI5_1 | w_strbI_1 | w_ldrbI_1;

// load/store halfword imm offset
(* dont_touch="true" *) wire w_loadStoreHalfwordI_1;
assign w_strhI_1 = (w_op_4 == 4'b1000) & (w_functL_1 == 1'b0);
assign w_ldrhI_1 = (w_op_4 == 4'b1000) & (w_functL_1 == 1'b1);
assign w_loadStoreHalfwordI_1 = w_strhI_1 | w_ldrhI_1;

// load from or store to stack
(* dont_touch="true" *) wire w_loadStoreStack_1;
assign w_strI8_1 = (w_op_4 == 4'b1001) & (w_functL_1 == 1'b0);
assign w_ldrI8_1 = (w_op_4 == 4'b1001) & (w_functL_1 == 1'b1);
assign w_loadStoreStack_1 = w_strI8_1 | w_ldrI8_1;

// add to SP or PC
(* dont_touch="true" *) wire w_addToSpOrPc_1;
assign w_adr_1   = (w_op_4 == 4'b1010) & (w_functL_1 == 1'b0);
assign w_addSpI8_1 = (w_op_4 == 4'b1010) & (w_functL_1 == 1'b1);
assign w_addToSpOrPc_1 = w_adr_1 | w_addSpI8_1;

// load/store multiple
(* dont_touch="true" *) wire w_loadStoreMlutiple_1, w_isMultiLS_1, w_pushPopReg_1;;
assign w_stmia_1 = (w_op_4 == 4'b1100) & (w_functL_1 == 1'b0);
assign w_ldmia_1 = (w_op_4 == 4'b1100) & (w_functL_1 == 1'b1);
assign w_loadStoreMlutiple_1 = w_stmia_1 | w_ldmia_1;
assign w_isMultiLS_1  = w_stmia_1 | w_ldmia_1 | w_pop_1 | w_push_1;
// miscellaneous ins
(* dont_touch="true" *) wire w_miscellaneous_1;
// adjust stack pointer ins
(* dont_touch="true" *) wire w_adjustStackPointer_1;
assign w_addSpI7_1 = (w_op_8 == 8'b10110000) & (w_int_16[7] == 1'b0);
assign w_subSp_1 = (w_op_8 == 8'b10110000) & (w_int_16[7] == 1'b1);
assign w_adjustStackPointer_1 = w_addSpI7_1 | w_subSp_1;

// sign/zero extend
(* dont_touch="true" *) wire w_signZeroExtend_1;
assign w_sxth_1 = (w_op_8 == 8'b10110010) & (w_int_16[7:6] == 2'b00);
assign w_sxtb_1 = (w_op_8 == 8'b10110010) & (w_int_16[7:6] == 2'b01);
assign w_uxth_1 = (w_op_8 == 8'b10110010) & (w_int_16[7:6] == 2'b10);
assign w_uxtb_1 = (w_op_8 == 8'b10110010) & (w_int_16[7:6] == 2'b11);
assign w_signZeroExtend_1 = w_sxth_1 | w_sxtb_1 | w_uxth_1 | w_uxtb_1;

// compare and branch on (Non-)Zero
(* dont_touch="true" *) wire w_comAndBranch_1;
assign w_cbz_1  = (w_op_4 == 4'b1011) & (w_int_16[11:10] == 2'b00) & (w_int_16[8] == 1'b1);
assign w_cbnz_1 = (w_op_4 == 4'b1011) & (w_int_16[11:10] == 2'b10) & (w_int_16[8] == 1'b1);
assign w_comAndBranch_1 = w_cbz_1 | w_cbnz_1;

// push/pop reg list
//(* dont_touch="true" *) wire w_pushPopReg_1;
assign w_push_1 = (w_op_4 == 4'b1011) & (w_int_16[11:9] == 3'b010);
assign w_pop_1  = (w_op_4 == 4'b1011) & (w_int_16[11:9] == 3'b110);
assign w_pushPopReg_1 = w_isMultiLS_1;

// set endianness
// reverse bytes
(* dont_touch="true" *) wire w_reverseBytes_1;
assign w_rev_1 = (w_op_8 == 8'b10111010) & (w_int_16[7:6] == 2'b00);
assign w_rev16_1 = (w_op_8 == 8'b10111010) & (w_int_16[7:6] == 2'b01);
assign w_revsh_1 = (w_op_8 == 8'b10111010) & (w_int_16[7:6] == 2'b11);
assign w_reverseBytes_1 = w_rev_1 | w_rev16_1 | w_revsh_1;

(* dont_touch="true" *) wire [1:0] w_revType_2; 
assign w_revType_2 = {2{w_rev_1}}   & 2'b01
                   | {2{w_rev16_1}} & 2'b10
                   | {2{w_revsh_1}} & 2'b11;

// if_then
assign w_ifThen_1 = (w_op_8 == 8'b10111111) & (w_mask_4 != 4'b0000);

// conditional branch
assign w_cB_1 = (w_op_4 == 4'b1101);
// unconditional branch
assign w_ucB_1 = (w_op_5 == 5'b11100);

// NOP-compatible hint instructions
(* dont_touch="true" *) wire w_nopCompatible_1;
assign w_sev_1 = (w_op_8 == 8'b10111111) & (w_firstcond_4 == 4'b0100) & (w_mask_4 == 4'b0000);
assign w_nop_1 = (w_op_8 == 8'b10111111) & (w_firstcond_4 == 4'b0000) & (w_mask_4 == 4'b0000);
assign w_yield_1 = (w_op_8 == 8'b10111111) & (w_firstcond_4 == 4'b0001) & (w_mask_4 == 4'b0000);
assign w_wfe_1 = (w_op_8 == 8'b10111111) & (w_firstcond_4 == 4'b0010) & (w_mask_4 == 4'b0000);
assign w_wfi_1 = (w_op_8 == 8'b10111111) & (w_firstcond_4 == 4'b0011) & (w_mask_4 == 4'b0000);
assign w_nopCompatible_1 = w_sev_1 | w_nop_1 | w_yield_1 | w_wfe_1 | w_wfi_1;

assign w_miscellaneous_1 = w_signZeroExtend_1 | w_reverseBytes_1 | w_comAndBranch_1
                         | w_adjustStackPointer_1 | w_pushPopReg_1 | w_nopCompatible_1;

wire w_isSportInt;
assign w_isSportInt =  w_cB_1 | w_ucB_1 | w_reverseBytes_1 | w_pushPopReg_1 | w_comAndBranch_1 | w_signZeroExtend_1 | w_adjustStackPointer_1 |
                w_isMultiLS_1 | w_addToSpOrPc_1 | w_loadStoreStack_1 | w_loadStoreHalfwordI_1 | w_loadStoreWordByteI_1 | w_loadStoreReg_1 |
                w_ldrPc_1 | w_bAndBlx_1 | w_speDataAdd_1 | w_dataProcessingR_1 | w_addSubComMovI8_1 | w_addSubI3_1 | w_addSubR_1 |
                w_shiftIAndMobeR_1; // 2025.1.3 zlt add

//数据
(* dont_touch="true" *) wire w_rn5to3_1, w_rn2to0_1, w_rn10to8_1;
(* dont_touch="true" *) wire w_rm8to6_1, w_rm6to3_1, w_rm5to3_1;
(* dont_touch="true" *) wire w_rd2to0_1, w_rd10to8_1;
(* dont_touch="true" *) wire w_imm2_1, w_imm5_1, w_imm8_1, w_imm12_1, w_imm16_1;
(* dont_touch="true" *) wire w_imm3_1, w_imm7_1, w_imm11_1;
(* dont_touch="true" *) wire w_immAllZero_1;


assign w_imm_3 = w_int_16[8:6];
assign w_imm_5 = w_int_16[10:6];
assign w_imm_7 = {7{w_adjustStackPointer_1}} & w_int_16[6:0]
               | {7{w_comAndBranch_1}} & {w_int_16[9], w_int_16[7:3], 1'b0}; 
assign w_imm_8 = w_int_16[7:0];
assign w_imm_11 = w_int_16[10:0];
//rn
//11/16 zwm w_specialDataPro_1 is not belong to w_rn2to0_1
assign w_rn5to3_1 = w_addSubR_1 | w_addSubI3_1 | w_loadStoreReg_1 | 
                    w_loadStoreHalfwordI_1 | w_loadStoreWordByteI_1 | w_reverseBytes_1;
assign w_rn2to0_1 = w_dataProcessingR_1 | w_comAndBranch_1;
assign w_rn10to8_1 = w_addSubComMovI8_1 | w_loadStoreMlutiple_1;
//rm
assign w_rm5to3_1 = w_shiftIAndMobeR_1 | w_dataProcessingR_1 | w_signZeroExtend_1 | w_reverseBytes_1;
assign w_rm6to3_1 = w_specialDataPro_1 | w_bAndBlx_1;
assign w_rm8to6_1 = w_addSubR_1 | w_addSubI3_1 | w_loadStoreReg_1;

//11/4 zwm->新增一个条\EF\BF???
//rd
//11/16 zwm w_specialDataPro_1 is not belong to w_rd2to0_1
assign w_rd2to0_1 = w_shiftIAndMobeR_1 | w_addSubI3_1 | w_addSubR_1 | w_dataProcessingR_1 
                  | w_loadStoreReg_1 | w_loadStoreHalfwordI_1 | w_loadStoreHalfwordI_1
                  | w_signZeroExtend_1 | w_reverseBytes_1 | w_loadStoreWordByteI_1;
assign w_rd10to8_1 = w_addSubComMovI8_1 | w_ldrPc_1 | w_loadStoreStack_1 | w_addToSpOrPc_1;
//imm


(* dont_touch="true" *) wire [1:0] w_immExtType_2;
(* dont_touch="true" *) wire [7:0] w_immType_8;
(* dont_touch="true" *) wire w_isImm_1;
assign w_imm3_1 = w_addSubI3_1;
assign w_imm5_1 = w_shiftIAndMobeR_1 | w_loadStoreWordByteI_1 | w_loadStoreHalfwordI_1;
assign w_imm7_1 = w_adjustStackPointer_1 | w_comAndBranch_1;
assign w_imm8_1 = w_addSubComMovI8_1 | w_ldrPc_1 | w_loadStoreStack_1 | w_addSpI8_1 | w_cB_1;
assign w_imm11_1 = w_ucB_1;

assign w_immAllZero_1 = w_rsbI_1 | w_signZeroExtend_1;

assign w_immType_8 = {w_imm16_1, w_imm12_1, w_imm8_1, w_imm5_1, w_imm2_1, w_imm11_1, w_imm7_1, w_imm3_1};
assign w_isImm_1 = |w_immType_8;

wire w_immZero_1, w_immSign_1, w_immDecode_1, w_immThumb_1;

assign w_immZero_1 = 1;
assign w_immSign_1 = w_cB_1 | w_ucB_1;
assign w_immDecode_1 = 0;
assign w_immThumb_1 = 0;

assign w_immExtType_2 = {2{w_immZero_1}} & 2'b00
                      | {2{w_immSign_1}} & 2'b01
                      | {2{w_immDecode_1}} & 2'b10
                      | {2{w_immThumb_1}} & 2'b11;

(* dont_touch="true" *) wire [15:0] w_immToLaunch_16;

// 立即数扩展放到分派模块去做，这里只传16位的imm
//11/8 zwm ->imm5 not in the same way
//12/30 zwm w_ucB_1 is immSign
assign w_immToLaunch_16 = {{16{w_imm3_1}} & {13'b0, w_imm_3}}
                        | {{16{w_strI5_1 | w_ldrI5_1}} & {{9{1'b0}},w_imm_5,{2{1'b0}}}}
                        | {{16{w_shiftIAndMobeR_1 | w_strbI_1 | w_ldrbI_1 }} & {11'b0, w_imm_5}}
                        | {{16{w_loadStoreHalfwordI_1}} & {{10{1'b0}},w_imm_5,{1{1'b0}}}}
                        | {{16{w_comAndBranch_1}} & {9'b0, w_imm_7}}
                        | {{16{w_adjustStackPointer_1}} & {{7{1'b0}}, w_imm_7,{2{1'b0}}}}
                        | {{16{w_ldrPc_1 | w_addToSpOrPc_1 | w_loadStoreStack_1}} & {{6{1'b0}}, w_imm_8 ,{2{1'b0}}}}
                        | {{16{w_cB_1}} & {{7{1'b0}}, w_imm_8,1'b0}}
                        | {{16{w_ucB_1}} & {{4{w_imm_11[10]}}, w_imm_11,1'b0}}
                        | {{16{w_addSubComMovI8_1}} & {8'b0, w_imm_8}}
                        | {{16{w_immAllZero_1}} & {16'b0}} 
                        | {{16{w_push_1}} & {1'b0, w_int_16[8], 6'b0, w_imm_8}} // 还剩下B型指\EF\BF??????
                        | {{16{w_pop_1}} & {w_int_16[8], 7'b0, w_imm_8}}
                        | {{16{w_loadStoreMlutiple_1}} &{8'b0, w_imm_8}};  // 还剩下B型指\EF\BF??????

//数据的准\EF\BF??????
wire w_spOp1;                     
(* dont_touch="true" *) wire w_spRd_1;
(* dont_touch="true" *) wire w_writeRd_1;
//12/13 zwm if not writeRd should set default value 4'hf
assign w_rn_4 = {{4{w_rn2to0_1}} & {1'b0, w_int_16[2:0]}}
              | {{4{w_rn5to3_1}} & {1'b0, w_int_16[5:3]}}
              | {{4{w_rn10to8_1}} & {1'b0, w_int_16[10:8]}}
              | {{4{w_spOp1}} & {4'b1101}}
              | {{4{w_specialDataPro_1}} & {w_int_16[7],w_int_16[2:0]}}
              | {{4{w_rsbI_1}} & {1'b0,w_int_16[5:3]}};

assign w_rm_4 = {{4{w_rm5to3_1}} & {1'b0, w_int_16[5:3]}}
              | {{4{w_rm6to3_1}} & {w_int_16[6:3]}}
              | {{4{w_rm8to6_1}} & {1'b0, w_int_16[8:6]}};

assign w_rd_4 = {{4{w_rd2to0_1}} & {1'b0, w_int_16[2:0]}}
              | {{4{w_rd10to8_1}} & {1'b0, w_int_16[10:8]}}
              | {{4{w_specialDataPro_1}} & {w_int_16[7], w_int_16[2:0]}}
              | {{4{w_spRd_1}} & {4'b1101}}
              | {{4{~w_writeRd_1}} & {4'b1111}};

assign w_rdLo_4 = 4'hf;

(* dont_touch="true" *) wire w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3;



// CMP,MOV,RSB
// CMPI8没有目的寄存\EF\BF??????
// RSB，MVN没有立即数和RM，只对Rn取非
// MOV只有RM，w_ldrPc_1第二操作数为立即\EF\BF??????
// 对SP的操作第一个操作数为Rn
// signOrZeroExtend立即数为\EF\BF??????0

// RSB(imm)寄存值的取反分派做，立即数为\EF\BF??????0
// ADD(SPI8)第一个操作数为SP,w_adjustStackPointer_1
// push/pop没弄-->弄了

assign w_spOp1 = w_pop_1 | w_push_1 | w_addSpI7_1 | w_addSpI8_1 | w_subSp_1;
assign w_spRd_1 = w_blx_1 | w_subSp_1;
assign w_rnOp1 = w_addSubR_1 | w_addSubI3_1 | w_addSubI8_1 | w_dataProcessingRNotMvn_1 
               | w_speDataAdd_1 | w_loadStoreReg_1 | w_loadStoreWordByteI_1 | w_loadStoreHalfwordI_1
               | w_loadStoreStack_1 |w_addSpI8_1 | w_loadStoreMlutiple_1 | w_adjustStackPointer_1 | w_comAndBranch_1
               | w_reverseBytes_1 | w_comAndBranch_1 | w_spOp1;
assign w_rmOp1 = w_shiftIAndMobeR_1 | w_signZeroExtend_1 | w_mvnR_1 | w_movHR_1 | w_bAndBlx_1;
assign w_rmOp2 = w_addSubR_1 | w_dataProcessingRNotMvn_1 | w_speDataAdd_1 | w_loadStoreReg_1;
assign w_rnOp3 = 0;
assign w_immOp3 = 0;
// 11/10 zwm store type no need writeRd
(* dont_touch="true" *) wire w_store_1;
assign w_writeRd_1 = !(w_cmpI_1 | w_tstR_1 | w_cmpR_1 | w_cmpHR_1 | w_cmnR_1 | w_cB_1 | w_ucB_1 | w_bx_1);
// pop/push未考虑,没有出现的指令都是只要立即数

//操作的准\EF\BF??????

//操作
(* dont_touch="true" *) wire w_add_1, w_sub_1;
(* dont_touch="true" *) wire w_and_1, w_or_1, w_eor_1, w_not_1; // not指第一次运算结果后的取\EF\BF??????
(* dont_touch="true" *) wire w_lsl_1, w_lsr_1, w_asr_1, w_ror_1;
(* dont_touch="true" *) wire w_rmNot_1, w_rnNot_1;
(* dont_touch="true" *) wire w_immNot_1;
(* dont_touch="true" *) wire w_opNot_1;

(* dont_touch="true" *) wire w_loadAndStore_1;
assign w_loadAndStore_1 = w_loadStoreReg_1 | w_loadStoreHalfwordI_1 | w_loadStoreWordByteI_1 
                        | w_loadStoreStack_1 | w_loadStoreMlutiple_1 | w_ldrPc_1;

assign w_add_1 = w_loadAndStore_1 | w_addSubI8_1 | w_addToSpOrPc_1 | w_addSubR_1 | w_addSubI3_1 
               | w_speDataAdd_1 | w_sbcR_1 | w_rsbI_1 | w_cmpR_1 | w_cmnR_1 | w_adcR_1 
               | w_adjustStackPointer_1 | w_pushPopReg_1;

// 加法进位的分\EF\BF?????? -->因为要APSR.C的值所以只能放到分别派去做
(* dont_touch="true" *) wire w_addC0_1, w_addC1_1, w_addC_1;// 加法运算的进位信息，进位恒为0，恒1，还有进位标志位
(* dont_touch="true" *) wire w_add5_1, w_add64_1;

assign w_addC0_1 = w_loadAndStore_1 | w_addR_1 | w_addI3_1 | w_addI8_1 | w_cmnR_1 | w_addHR_1 | w_addToSpOrPc_1 | w_addSpI7_1 | w_pop_1 | w_ldmia_1 | w_stmia_1;
assign w_addC1_1 = w_subI3_1 | w_subR_1 | w_cmpI_1 | w_subI8_1 | w_rsbI_1 | w_cmpR_1 | w_cmpHR_1 | w_subSp_1 | w_push_1 ;
assign w_addC_1 = w_adcR_1 | w_sbcR_1;
assign w_add5_1 = 0;
assign w_add64_1 = 0;

assign w_sub_1 = w_subR_1 | w_subI3_1 | w_subI8_1 | w_subSp_1 | w_cmpR_1 
               | w_cmpI_1 | w_cmpHR_1 | w_sbcR_1 | w_rsbI_1;
assign w_rmNot_1 = w_subR_1 | w_sbcR_1 | w_cmpR_1 | w_cmpHR_1 | w_bicR_1 | w_mvnR_1; // 都是对Rm取反
assign w_rnNot_1 = w_rsbI_1;
assign w_immNot_1 = w_subI3_1 | w_cmpI_1 | w_subI8_1 | w_rsbI_1 | w_subSp_1 | w_push_1;
assign w_opNot_1 = 0;

// logic
// assign w_not_1 = w_sub_1 | w_bicR_1 | w_mvnR_1;
assign w_and_1 = w_tstR_1 | w_bicR_1 | w_andR_1;
assign w_or_1 = w_orrR_1;
assign w_eor_1 = w_eorR_1;

// shift
(* dont_touch="true" *) wire [1:0] w_shift_2;
(* dont_touch="true" *) wire [2:0] w_shift_3;
(* dont_touch="true" *) wire w_shiftC_1;
assign w_lsl_1 = w_lslI_1 | w_lslR_1;
assign w_lsr_1 = w_lsrI_1 | w_lsrR_1;
assign w_asr_1 = w_asrI_1 | w_asrR_1;
assign w_ror_1 = w_signZeroExtend_1 | w_rorR_1;
assign w_shift_2 = {2{w_lsl_1}} & 2'b00
                 | {2{w_lsr_1}} & 2'b01
                 | {2{w_asr_1}} & 2'b10;

assign w_shift_3 = {3{w_ror_1}} & {3'b011}
                 | {3{!w_ror_1}} & {{1'b0, w_shift_2}};
 
assign w_shiftC_1 = 1'b1;

// sxtb/sxth/uxtb/uxth
(* dont_touch="true" *) wire w_xtSize_1, w_xtSign_1, w_isXt_1;

assign w_xtSign_1 = w_sxtb_1 | w_sxth_1; // \EF\BF??????1时代表有符号扩展，为0时代表无符号扩展
assign w_xtSize_1 = w_sxtb_1 | w_uxtb_1; // \EF\BF??????1时代\EF\BF??????8位，\EF\BF??????0时代\EF\BF??????16\EF\BF??????
assign w_isXt_1 = w_uxtb_1 | w_sxtb_1 | w_uxth_1 | w_sxth_1;

// loadAndStore
(* dont_touch="true" *) wire [1:0] w_loadStoreWidth_2;
(* dont_touch="true" *) wire w_load_1;

(* dont_touch="true" *) wire w_isLS_1;
(* dont_touch="true" *) wire w_loadSign_1;
(* dont_touch="true" *) wire w_widthB_1;
(* dont_touch="true" *) wire w_widthH_1;
(* dont_touch="true" *) wire w_widthW_1;

//12/8 zwm pop is also load inst
assign w_load_1 = w_ldrshR_1 | w_ldrbI_1 | w_ldrbr_1 | w_ldrhI_1
                | w_ldrhR_1 | w_ldrR_1 | w_ldrI5_1 | w_ldrI8_1 
                | w_ldrsbR_1 | w_ldmia_1 | w_ldrPc_1 | w_pop_1;

assign w_store_1 = w_strbI_1 | w_strbR_1 | w_strhI_1 | w_strhR_1
                 | w_strI5_1 | w_strI8_1 | w_strR_1 | w_stmia_1;

assign w_isLS_1 = w_loadAndStore_1 | w_isMultiLS_1;

assign w_loadSign_1 = w_ldrsbR_1 | w_ldrshR_1;

assign w_widthB_1 = w_ldrbI_1 | w_ldrsbR_1 | w_ldrbr_1
                  | w_strbI_1 | w_strbR_1;

assign w_widthH_1 = w_ldrhI_1 | w_ldrhR_1 | w_ldrshR_1
                  | w_strhI_1 | w_strhR_1;

assign w_widthW_1 = w_ldrR_1 | w_ldrI5_1 | w_ldrI8_1
                  | w_ldrPc_1 | w_strR_1 | w_strI5_1 | w_strI8_1;

assign w_loadStoreWidth_2 = {{2{w_widthB_1}} & 2'b00}
                          | {{2{w_widthH_1}} & 2'b01}
                          | {{2{w_widthW_1}} & 2'b11};

// PC \EF\BF?????? 跳转 一次取\EF\BF??????/多字 立即数扩\EF\BF?????? 写CPSR 异常 翻转

(* dont_touch="true" *) wire w_setFlags_1;
assign w_setFlags_1 = ~ (w_load_1 | w_store_1 | w_addToSpOrPc_1 
                      | w_addHR_1 | w_movHR_1 | w_bAndBlx_1 
                      | w_miscellaneous_1 | w_cB_1 | w_ucB_1 | w_movR_1);


(* dont_touch="true" *) wire w_alignAndAdd_1;
assign w_alignAndAdd_1 = w_adr_1 | w_ldrPc_1;

(* dont_touch="true" *) wire w_shiftAdd_1;
assign w_shiftAdd_1 = 0;

(* dont_touch="true" *) wire w_mulAdd_1;
assign w_mulAdd_1 = 0;

(* dont_touch="true" *) wire w_onlyMul_1;
assign w_onlyMul_1 = w_mul_1;

(* dont_touch="true" *) wire w_onlyDiv_1;
assign w_onlyDiv_1 = 0;

(* dont_touch="true" *) wire w_onlyAnd_1;
assign w_onlyAnd_1 = w_and_1;

(* dont_touch="true" *) wire w_onlyEor_1;
assign w_onlyEor_1 = w_eor_1;

(* dont_touch="true" *) wire w_onlyOr_1;
assign w_onlyOr_1 = w_or_1;

(* dont_touch="true" *) wire w_shiftAnd_1;
assign w_shiftAnd_1 = 0;

(* dont_touch="true" *) wire w_shiftEor_1;
assign w_shiftEor_1 = 0;

(* dont_touch="true" *) wire w_shiftOr_1;
assign w_shiftOr_1 = 0;

(* dont_touch="true" *) wire w_onlyShift_1;
assign w_onlyShift_1 = w_lsl_1 | w_lsr_1 | w_asr_1 | w_ror_1;

(* dont_touch="true" *) wire w_shiftSatQ_1;
assign w_shiftSatQ_1 = 0;

(* dont_touch="true" *) wire w_hsbAdd_1;
assign w_hsbAdd_1 = 0;

(* dont_touch="true" *) wire w_onlyRev_1;
assign w_onlyRev_1 = w_reverseBytes_1;

(* dont_touch="true" *) wire [7:0] w_sRs_8, w_sRd_8;

assign w_sRs_8 = 8'b1111_1110;
assign w_sRd_8 = 8'b1111_1111;


(* dont_touch="true" *) wire [4:0] w_widthm1_5;
assign w_widthm1_5 = 0;
(* dont_touch="true" *) wire w_bitdieldAndSaturate_1;
assign w_bitdieldAndSaturate_1 = 0;


(* dont_touch="true" *) wire w_P_1, w_W_1, w_U_1;
assign w_U_1 = 1'b1;
//11.1hrq -> //11.1hrq -> add push
assign w_P_1 = w_isMultiLS_1 & w_push_1 | ~w_isMultiLS_1 & 1'b1;
//11.1hrq -> //11.1hrq -> add push,pop,stmia
assign w_W_1 = w_pop_1 | w_push_1 | w_stmia_1 | (w_ldmia_1 & (w_immToLaunch_16[w_int_16[10:8]] == 1'b0));
(* dont_touch="true" *) wire w_mrs_1, w_msr_1, w_bl_1;
assign w_mrs_1 = 0;
assign w_msr_1 = 0;
assign w_bl_1 = 0;

(* dont_touch="true" *) wire w_mulDivSign_1;
assign w_mulDivSign_1 = w_setFlags_1;

(* dont_touch="true" *) wire w_satSign_1;
assign w_satSign_1 = 0;

(* dont_touch="true" *) wire w_aluWritePC_1;
assign w_aluWritePC_1 = 0;

wire w_grfFlag_1;
assign w_grfFlag_1 = 0;

(* dont_touch="true" *) wire [15:0] w_insType_16;
assign w_insType_16 = {16{w_add_1 & ~w_ldrPc_1}}  &    16'h0001 
                    | {16{w_alignAndAdd_1}} &    16'h0002            
                    | {16{w_shiftAdd_1}}    &    16'h0003              
                    | {16{w_mulAdd_1}}      &    16'h0004              
                    | {16{w_onlyMul_1}}     &    16'h0010              
                    | {16{w_onlyDiv_1}}     &    16'h0020            
                    | {16{w_onlyAnd_1}}     &    16'h0030           
                    | {16{w_onlyEor_1}}     &    16'h0040           
                    | {16{w_onlyOr_1}}      &    16'h0100           
                    | {16{w_shiftAnd_1}}    &    16'h0200           
                    | {16{w_shiftEor_1}}    &    16'h0300           
                    | {16{w_shiftOr_1}}     &    16'h0400           
                    | {16{w_onlyShift_1}}   &    16'h1000           
                    | {16{w_shiftSatQ_1}}   &    16'h2000           
                    | {16{w_hsbAdd_1}}      &    16'h3000           
                    | {16{w_onlyRev_1}}     &    16'h4000;   

wire w_thumbExpandRor_1;
wire [1:0] w_wen_2;
assign w_wen_2 = 2'b10;



//12/27 zwm dute to not all nzcv need update,so this need 4bits wen
wire w_notUpdateV_1,w_notUpdatCandV_1;

assign w_notUpdateV_1 = w_andR_1 | w_asrI_1 | w_asrR_1 | w_bicR_1 | w_eorR_1 | w_lslI_1 | w_lslR_1 |
                        w_movI_1 | w_movR_1 | w_movHR_1 | w_mvnR_1 | w_orrR_1 | w_rorR_1 | w_tstR_1 ;
assign w_notUpdatCandV_1 = w_mul_1;
assign o_nzcvWen_4 = {4{w_notUpdateV_1}} & 4'b1110
                   | {4{w_notUpdatCandV_1}} & 4'b1100
                   | {4{~w_notUpdatCandV_1 & ~w_notUpdateV_1}} & 4'b1111;

(* dont_touch="true" *) wire [186:0] w_decoderDataToLaunch_187;
assign w_decoderDataToLaunch_187 = {w_setFlags_1,w_rm_4, // rs2
                                    w_rn_4, // rs1
                                    w_sRs_8,
                                    w_immExtType_2,
                                    w_immType_8,
                                    w_immToLaunch_16,
                                    w_widthm1_5,  // 位操作和饱和指令用到的第二个立即\EF\BF?????? 
                                    w_isImm_1, //是否包含立即\EF\BF??????
                                    w_pushPopReg_1,
                                    w_pc_32,
                                    w_cond_4,
                                    w_addC0_1, w_addC1_1, w_addC_1, w_add5_1, w_add64_1,
                                    w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bitdieldAndSaturate_1, w_thumbExpandRor_1,
                                    w_alignAndAdd_1,
                                    w_aluWritePC_1, w_cB_1, w_ucB_1, w_bl_1, w_bx_1, w_blx_1, w_cbz_1, w_cbnz_1,
                                    w_mrs_1, w_msr_1, 
                                    w_insType_16,
                                    w_shift_3,
                                    w_load_1, w_loadStoreWidth_2, w_loadSign_1, w_isLS_1,
                                    w_writeRd_1,
                                    w_rd_4, w_rdLo_4, w_sRd_8, 
                                    w_P_1, w_W_1, w_U_1,
                                    w_grfFlag_1,
                                    w_rnNot_1, w_rmNot_1, w_immNot_1, w_opNot_1,
                                    w_isXt_1,
                                    w_revType_2,
                                    w_satSign_1, // 饱和运算的符\EF\BF??????
                                    w_shiftC_1,
                                    w_xtSign_1, w_xtSize_1,
                                    w_mulDivSign_1,{14{1'b0}}, w_isMultiLS_1,w_rn_4,w_wen_2
                                    };

assign o_data_187 = w_decoderDataToLaunch_187;

// assign o_excNum_4 = i_isInInt & w_bx_1 ? 4'b0010 : w_isSportInt ? 4'b1111 : 4'b0101; // 2025.1.3 zlt add
assign o_excNum_4 = i_isInInt & w_bx_1 ? 4'b0010 : 4'b1111; // 2025.1.3 zlt add

endmodule 
