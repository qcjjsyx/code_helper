/*=============================================================
Project:ARMCPU
Module:decoder32
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:decoder32
==============================================================*/


`timescale 1ns/1ps

module decoder_32 (
    input i_drive,
    input [63:0] i_data_64,
    output o_free,
    output o_drive,
    output [186:0] o_data_187,
    output [3:0] o_excNum_4,
    input i_free,
    output [8:0] o_blImm9_9,
    //12/27 zwm add nzcv wen
    output [3:0] o_nzcvWen_4,
    input rst
);


(* dont_touch="true" *)wire [31:0] w_int_32;
(* dont_touch="true" *)wire [31:0] w_pc_32;

(* dont_touch="true" *)wire [15:0] w_int1_16;
(* dont_touch="true" *)wire [15:0] w_int2_16;

(* dont_touch="true" *)wire w_isImm_1, w_xt_1;
(* dont_touch="true" *)wire [4:0] w_op_5;
(* dont_touch="true" *)wire [6:0] w_op_7;
(* dont_touch="true" *)wire [3:0] w_rn_4;
(* dont_touch="true" *)wire [3:0] w_rm_4;
(* dont_touch="true" *)wire [3:0] w_rd_4;
(* dont_touch="true" *)wire [3:0] w_rdLo_4;
(* dont_touch="true" *)wire w_S_1;
(* dont_touch="true" *)wire [1:0] w_addType_2;
(* dont_touch="true" *)wire [7:0] w_imm_8;
(* dont_touch="true" *)wire [4:0] w_imm_5;
(* dont_touch="true" *)wire [1:0] w_imm_2;
(* dont_touch="true" *)wire [11:0] w_imm_12;
(* dont_touch="true" *)wire [11:0] w_LoadAndStoreImm_12;
(* dont_touch="true" *)wire [15:0] w_imm_16;
(* dont_touch="true" *)wire [15:0] w_immToLaunch_16;
(* dont_touch="true" *)wire [1:0] w_shift_2;
(* dont_touch="true" *)wire [2:0] w_shift_3;
(* dont_touch="true" *)wire [4:0] w_satOrLsbit_5;
(* dont_touch="true" *)wire [4:0] w_widthm1_5;
(* dont_touch="true" *)wire [31:0] w_op1_32, w_op2_32, w_op3_32;

(* dont_touch="true" *)wire [3:0] w_funct_4;

(* dont_touch="true" *)wire w_isShitf_1; // thumbexpandIMM是否要移�???????
(* dont_touch="true" *)wire w_isPC_1; //后面的计算是否要用到PC
(* dont_touch="true" *)wire w_isXt_1;
(* dont_touch="true" *)wire w_isMultiLS_1;


(* dont_touch="true" *)wire w_dataProConstantShift_1; // 可变立即数扩�???????
(* dont_touch="true" *)wire w_dataProModifImm12_1, w_LSreg_list_16; // 立即数扩展方式可�???????
(* dont_touch="true" *)wire w_regControlShift_1; 

assign {w_pc_32, w_int_32} = i_data_64;
assign {w_int1_16, w_int2_16} = w_int_32;



assign w_funct_4 = w_int1_16[8:5];
//12/1 zwm not all inst need w_S_1
assign w_S_1 = w_int1_16[4] & (w_dataProModifImm12_1 | w_dataProConstantShift_1 | w_regControlShift_1);
// data processing instructions:immediate,including bitfield and saturate
// data processing instructions with modified 12-bit immediate
(* dont_touch="true" *)wire w_adcMI12_1, w_addMI12_1, w_andMI12_1, w_bicMI12_1, w_cmnMI12_1, w_cmpMI12_1,
                            w_eorMI12_1, w_movMI12_1, w_mvnMI12_1, w_ornMI12_1, w_orrMI12_1, w_rsbMI12_1, 
                            w_sbcMI12_1, w_subMI12_1, w_teqMI12_1, w_tstMI12_1;


(* dont_touch="true" *)wire w_aluWritePC_1; 

(* dont_touch="true" *)wire w_add_1; // 只做加法的指�???????
(* dont_touch="true" *)wire w_alignAndAdd_1; //ALIGN,ADD
(* dont_touch="true" *)wire w_shiftAdd_1;// shift,add
(* dont_touch="true" *)wire w_mulAdd_1;// mul,add
(* dont_touch="true" *)wire w_onlyMul_1;// 只做乘法
(* dont_touch="true" *)wire w_onlyDiv_1;// 只做除法
(* dont_touch="true" *)wire w_onlyAnd_1;// 只做�???????
(* dont_touch="true" *)wire w_onlyEor_1;// 只做异或
(* dont_touch="true" *)wire w_onlyOr_1;// 只做�???????
(* dont_touch="true" *)wire w_shiftAnd_1;// shift,and
(* dont_touch="true" *)wire w_shiftEor_1;// shift,eor
(* dont_touch="true" *)wire w_shiftOr_1;// shift,or
(* dont_touch="true" *)wire w_onlyShift_1;// 只做移位
(* dont_touch="true" *)wire w_shiftSatQ_1;// shifr,satq
(* dont_touch="true" *)wire w_hsbAdd_1;
(* dont_touch="true" *)wire w_onlyRev_1;// 只做翻转




assign w_rn_4 = w_int1_16[3:0];
assign w_rm_4 = w_int2_16[3:0]; 
assign w_imm_12 = {w_int1_16[10], w_int2_16[14:12], w_int2_16[7:0]};
//update
assign w_imm_16 = { w_int1_16[3:0],w_int1_16[10],w_int2_16[14:12], w_int2_16[7:0]};
assign w_imm_5  = {w_int2_16[14:12], w_int2_16[7:6]}; 
assign w_imm_8  = w_int2_16[7:0];
assign w_imm_2  = w_int2_16[5:4]; 
// 如果有两个立即数的指令后面怎么处理
assign w_satOrLsbit_5       = {w_int2_16[14:12], w_int2_16[7:6]};
assign w_widthm1_5          = w_int2_16[4:0];
assign w_LoadAndStoreImm_12 = w_int2_16[11:0];
assign w_LSreg_list_16      = w_int2_16[15:0];
assign w_shift_2            = w_int2_16[5:4];
assign w_isPC_1             = w_rn_4 == 4'b1111;

assign w_op_5 = w_int1_16[15:11];
assign w_op_7 = w_int1_16[15:9];

// rn不会�???????15,rn如果�???????15则不做对应的操作，若rd�???????15则不回写
assign w_adcMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1010);
assign w_addMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1000) & (w_int2_16[11:8] != 4'b1111); // ADD with Rd == 0b1111,S == 1 To cmn
assign w_andMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0000) & (w_int2_16[11:8] != 4'b1111); // AND with Rd == 0b1111,S == 1 To tst
assign w_bicMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0001);
assign w_cmnMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1000) & (w_int2_16[11:8] == 4'b1111); // ADD 
assign w_cmpMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1101) & (w_int2_16[11:8] == 4'b1111); // SUB
assign w_eorMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0100) & (w_int2_16[11:8] != 4'b1111); // EOR with Rd == 0b1111,S == 1 To teq
assign w_movMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0010) & (w_rn_4 == 4'b1111); // ORR  不走执行
assign w_mvnMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0011) & (w_rn_4 == 4'b1111); // ORN
assign w_ornMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0011) & (w_rn_4 != 4'b1111); // ORN with Rn == 0b1111
assign w_orrMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0010) & (w_rn_4 != 4'b1111); // ORR with Rn == 0b1111
assign w_rsbMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1110);
assign w_sbcMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1011);
assign w_subMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b1101) & (w_int2_16[11:8] != 4'b1111); // SUB with Rd == 0b1111,S == 1 To cmp
assign w_teqMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0100) & (w_int2_16[11:8] == 4'b1111); // EOR
assign w_tstMI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b0) & (w_funct_4 == 4'b0000) & (w_int2_16[11:8] == 4'b1111); // AND


assign w_dataProModifImm12_1 = w_adcMI12_1 | w_addMI12_1 | w_andMI12_1 | w_bicMI12_1 | w_cmnMI12_1 | w_cmpMI12_1
                             | w_eorMI12_1 | w_movMI12_1 | w_mvnMI12_1 | w_ornMI12_1 | w_orrMI12_1 | w_rsbMI12_1
                             | w_sbcMI12_1 | w_subMI12_1 | w_teqMI12_1 | w_tstMI12_1;



// add,sub plain 12-bit immediate
//rd不会�???????15,rn�???????15时做ALIGN操作
(* dont_touch="true" *)wire w_addPI12_1, w_subPI12_1, w_adrAddPI12_1, w_adrSubP12_1;
(* dont_touch="true" *)wire w_dataProPlainImm12_1; // �???????0扩展
assign w_addPI12_1    = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0000) & (w_rn_4 != 4'b1111);
assign w_subPI12_1    = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0101) & (w_rn_4 != 4'b1111);
assign w_adrAddPI12_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0101) & (w_rn_4 == 4'b1111);
assign w_adrSubP12_1  = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0000) & (w_rn_4 == 4'b1111);
assign w_dataProPlainImm12_1 = w_addPI12_1 | w_subPI12_1 | w_adrAddPI12_1 | w_adrSubP12_1;

// move plain 16-bit imm
(* dont_touch="true" *)wire w_movtPI16_1, w_movPI16_1;

(* dont_touch="true" *)wire w_movePlainImm16_1; // �???????0扩展
// rd不会�???????15，没有rn
assign w_movtPI16_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0110); // 不走执行
assign w_movPI16_1  = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b0010); // 不走执行
assign w_movePlainImm16_1 = w_movtPI16_1 | w_movPI16_1;

// data processing instructions, bitdield and saturate
(* dont_touch="true" *)wire w_bfc_1, w_bfi_1, w_sbfx_1, w_ssatLSL_1, w_ssatASR_1, w_ubfx_1, w_usatLSL_1, w_usatASR_1;
(* dont_touch="true" *)wire w_bitdieldAndSaturate_1;
(* dont_touch="true" *)wire w_bitdield_1;
(* dont_touch="true" *)wire w_saturate_1;
//rn，rd不能�???????15
assign w_bfc_1     = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1011) & (w_rn_4 == 4'b1111); 
assign w_bfi_1     = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1011) & (w_rn_4 != 4'b1111);// Rn == 0b1111 To bfc
assign w_sbfx_1    = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1010);
assign w_ssatLSL_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1000);
assign w_ssatASR_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1001);
assign w_ubfx_1    = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1110);
assign w_usatLSL_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1100);
assign w_usatASR_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b0) & (w_int1_16[9] == 1'b1) & (w_funct_4 == 4'b1101);

assign w_bitdieldAndSaturate_1 = w_bfc_1 | w_bfi_1 | w_sbfx_1 | w_ssatLSL_1 
                               | w_ssatASR_1 | w_ubfx_1 | w_usatLSL_1 | w_usatASR_1;
assign w_bitdield_1 = w_bfc_1 | w_bfi_1 | w_sbfx_1 | w_ubfx_1; // 立即数不需要扩�???????
assign w_saturate_1 = w_ssatLSL_1 | w_ssatASR_1 | w_usatLSL_1 | w_usatASR_1; // 立即数可变扩�???????

// data processing instructions,non-immediate
// data processing :constant shift
// rn,rd类似上面可变立即数的指令，rn�???????15的时候不做操�???????
// 都是需要进位的，加减法是在做加法时进位，其他的是在做移位时进位
(* dont_touch="true" *)wire w_adcRConsShift_1, w_addRConsShift_1, w_addAluPC_1, w_andRConsShift_1, w_bicRConsShift_1, w_cmnRConsShift_1, w_cmpRConsShift_1,
     w_eorRConsShift_1, w_mvnRConsShift_1, w_ornRConsShift_1, w_orrRConsShift_1, w_rsbRConsShift_1,
     w_sbcRConsShift_1, w_subRConsShift_1, w_teqRConsShift_1, w_tstRConsShift_1;

(* dont_touch="true" *)wire w_shiftImm5_1;

assign w_addRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1000) & (w_int2_16[11:8] != 4'b1111);  
assign w_addAluPC_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1000) & (w_int2_16[11:8] == 4'b1111) & (w_S_1 != 1'b1);   // ALUWritePC();
assign w_andRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0000) & (w_int2_16[11:8] != 4'b1111);
assign w_adcRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1010);
assign w_bicRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0001);
assign w_cmnRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1000) & (w_int2_16[11:8] == 4'b1111) & (w_S_1 == 1'b1); // ADD with Rd == 0b1111, S == 1
assign w_cmpRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1101) & (w_int2_16[11:8] == 4'b1111); // SUB with Rd == 0b1111, S == 1
assign w_eorRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0100) & (w_int2_16[11:8] != 4'b1111);
// assign w_moveIShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010); // ORR with Rn == 0b1111
assign w_mvnRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0011) & (w_rn_4 == 4'b1111); // ORN with Rn == 0b1111 不走执行
assign w_ornRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0011) & (w_rn_4 != 4'b1111);
assign w_orrRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_rn_4 != 4'b1111);
assign w_rsbRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1110);
assign w_sbcRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1011);
assign w_subRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b1101) & (w_int2_16[11:8] != 4'b1111);
assign w_teqRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0100) & (w_int2_16[11:8] == 4'b1111); // EOR with Rd == 0b1111, S == 1
assign w_tstRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0000) & (w_int2_16[11:8] == 4'b1111); // AND with Rd == 0b1111, S == 1

assign w_dataProConstantShift_1 = w_addRConsShift_1 | w_andRConsShift_1 | w_adcRConsShift_1 | w_bicRConsShift_1
                                | w_cmnRConsShift_1 | w_cmpRConsShift_1 | w_eorRConsShift_1 | w_mvnRConsShift_1
                                | w_ornRConsShift_1 | w_orrRConsShift_1 | w_rsbRConsShift_1 | w_sbcRConsShift_1
                                | w_subRConsShift_1 | w_teqRConsShift_1 | w_tstRConsShift_1 | w_shiftImm5_1 | w_addAluPC_1; 
// move, and immediate shift instructions
(* dont_touch="true" *)wire [4:0] w_dataProceConsShiftImm_5;
// imm5型移�???????
(* dont_touch="true" *)wire w_movRConsShift_1, w_movAluWritePC_1, w_lslI5ConsShift_1, w_lsrI5ConsShift_1, w_asrI5ConsShift_1, w_rorI5ConsShift_1, w_rrx_1;


assign w_dataProceConsShiftImm_5 = {w_int2_16[14:12], w_int2_16[7:6]};
assign w_movRConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b00) & (w_dataProceConsShiftImm_5 == 5'b00000) & (w_rn_4 == 4'b1111) & (w_int2_16[11:8] != 4'b1111); 
assign w_movAluWritePC_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b00) & (w_dataProceConsShiftImm_5 == 5'b00000) & (w_rn_4 == 4'b1111) & (w_int2_16[11:8] == 4'b1111); //ALUWritePC()
assign w_lslI5ConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b00) & (w_dataProceConsShiftImm_5 != 5'b00000) & (w_rn_4 == 4'b1111);
assign w_lsrI5ConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b01) & (w_rn_4 == 4'b1111);
assign w_asrI5ConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b10) & (w_rn_4 == 4'b1111);
assign w_rorI5ConsShift_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 2'b11) & (w_dataProceConsShiftImm_5 != 5'b00000) & (w_rn_4 == 4'b1111);
assign w_rrx_1 = (w_op_7 == 7'b1110101) & (w_funct_4 == 4'b0010) & (w_int2_16[5:4] == 3'b11) & (w_dataProceConsShiftImm_5 == 5'b00000) & (w_rn_4 == 4'b1111);

assign w_shiftImm5_1 = w_lslI5ConsShift_1 | w_lsrI5ConsShift_1 | w_asrI5ConsShift_1 | w_rorI5ConsShift_1 | w_rrx_1 | w_movAluWritePC_1 | w_movRConsShift_1;

// register-controlled shift
//rn,rm,rd不会�???????15

(* dont_touch="true" *)wire w_lslRContShift_1, w_lsrRContShift_1, w_asrRContShift_1, w_rorRShift_1;

assign w_lslRContShift_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0000) & (w_int2_16[7] == 1'b0);
assign w_lsrRContShift_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0001) & (w_int2_16[7] == 1'b0);
assign w_asrRContShift_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0010) & (w_int2_16[7] == 1'b0);
assign w_rorRShift_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0011) & (w_int2_16[7] == 1'b0);

assign w_regControlShift_1 = w_lslRContShift_1 | w_lsrRContShift_1 | w_asrRContShift_1 | w_rorRShift_1;

// sign or zero extension,with optional addtion
//rn,rm,rd不会�???????15
(* dont_touch="true" *) wire w_sxtb_1, w_uxtb_1, w_sxth_1, w_uxth_1; // 写不写xpsr不看�???????4�???????


assign w_sxtb_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0010) & (w_int1_16[4] == 1'b0);
assign w_uxtb_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0010) & (w_int1_16[4] == 1'b1);
assign w_sxth_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0000) & (w_int1_16[4] == 1'b0);
assign w_uxth_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0010) & (w_int1_16[4] == 1'b1);
assign w_xt_1 = w_sxtb_1 | w_uxtb_1 | w_sxth_1 | w_uxth_1;
//补充 sxth、uxth

// other there register data processing
//rn,rm,rd不会�???????15
(* dont_touch="true" *) wire w_otherThereReg_1;
(* dont_touch="true" *) wire w_clz_1, w_rbit_1, w_rev_1, w_rev16_1, w_revsh_1; // 写不写xpsr不看�???????4�???????

assign w_clz_1   = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0101) & (w_int1_16[4] == 1'b1) & (w_int2_16[6:4] == 3'b000);
assign w_rbit_1  = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0100) & (w_int1_16[4] == 1'b1) & (w_int2_16[6:4] == 3'b010);
assign w_rev_1   = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0101) & (w_int1_16[4] == 1'b1) & (w_int2_16[6:4] == 3'b000);
//update:w_funct_4 == 4'b0100
assign w_rev16_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0100) & (w_int1_16[4] == 1'b1) & (w_int2_16[6:4] == 3'b001);
assign w_revsh_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b0101) & (w_int1_16[4] == 1'b1) & (w_int2_16[6:4] == 3'b011);

assign w_otherThereReg_1 = w_clz_1 | w_rbit_1 | w_rev16_1 | w_rev_1 | w_revsh_1;

// 32-bit multiplies and Sum of absolute differences,with or without accumulate
//rn,rm,rd不会�???????15
(* dont_touch="true" *) wire w_mulAndSum32_1;
(* dont_touch="true" *) wire w_mla_1, w_mls_1, w_mul_1;
//update:w_rdLo_4==4'b1111时，w_mul_1=1
assign w_mla_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1000) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000) & (w_rdLo_4 != 4'b1111);// ra != 1111
assign w_mls_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1000) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0001);
assign w_mul_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1000) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000) & (w_rdLo_4 == 4'b1111);// ra == 1111

assign w_mulAndSum32_1 = w_mla_1 | w_mls_1 | w_mul_1;

// 64-bit multiplies and multiply-accumulates Divides
//rn,rm,rd不会�???????15
(* dont_touch="true" *) wire w_mul64_1;
(* dont_touch="true" *) wire w_div64_1;
(* dont_touch="true" *) wire w_smull_1, w_sdiv_1, w_umull_1, w_udiv_1, w_smlal_1, w_umlal_1;

assign w_smull_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1100) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000);
assign w_sdiv_1  = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1100) & (w_int1_16[4] == 1'b1) & (w_int2_16[7:4] == 4'b1111);
assign w_umull_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1101) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000);
assign w_udiv_1  = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1101) & (w_int1_16[4] == 1'b1) & (w_int2_16[7:4] == 4'b1111);
assign w_smlal_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1110) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000);
assign w_umlal_1 = (w_op_7 == 7'b1111101) & (w_funct_4 == 4'b1111) & (w_int1_16[4] == 1'b0) & (w_int2_16[7:4] == 4'b0000);

assign w_mul64_1 = w_smull_1  | w_umull_1  | w_smlal_1;
assign w_div64_1 = w_sdiv_1 | w_udiv_1;
// load and store single data item, memory hints
(* dont_touch="true" *) wire w_isLS_1;
(* dont_touch="true" *) wire w_loadStoreI12_1, w_loadStoreI8_1, w_loadStoreR_1; // 立即�???????0扩展  
(* dont_touch="true" *) wire w_loadStoreI_1;
(* dont_touch="true" *) wire w_loadAndStoreSingle_1;

assign w_loadStoreI12_1         = (w_op_7 == 7'b1111100) & ((w_int1_16[7] == 1'b1) | (w_rn_4 == 4'b1111));
assign w_loadStoreI8_1          = (w_op_7 == 7'b1111100) & (w_int1_16[7] == 1'b0) & (w_rn_4 != 4'b1111) & (w_int2_16[11] == 1'b1);
assign w_loadStoreR_1           = (w_op_7 == 7'b1111100) & (w_int1_16[7] == 1'b0) & (w_rn_4 != 4'b1111) & (w_int2_16[11] == 1'b0);
assign w_loadAndStoreSingle_1   = w_loadStoreI12_1 | w_loadStoreI8_1 | w_loadStoreR_1;
assign w_loadStoreI_1           = w_loadStoreI12_1 | w_loadStoreI8_1;



(* dont_touch="true" *) wire [1:0] w_loadStoreWidth_2;
(* dont_touch="true" *) wire w_load_1;
(* dont_touch="true" *) wire w_store_1;
(* dont_touch="true" *) wire w_loadSign_1;

(* dont_touch="true" *) wire w_U_1, w_P_1, w_W_1;

(* dont_touch="true" *) wire w_SU_1, w_SP_1, w_SW_1;

(* dont_touch="true" *) wire w_RU_1, w_RP_1, w_RW_1;


(* dont_touch="true" *) wire w_ldrdStrdI8_1;
 
// U指是否是加法，P指用不用加完或减完的结果，W指回不回写，PWU不对w_loadStoreR_1起作用。p,w不对I12起作�???????
assign w_SU_1 = w_loadStoreI8_1 ? w_int2_16[9] : w_int1_16[7];
assign w_SP_1 = w_int2_16[10];
assign w_SW_1 = w_int1_16[8];

assign w_RU_1 = 1'b1;
assign w_RP_1 = 1'b1;
assign w_RW_1 = 1'b0;
// 后续：U,P,W需要整合，将几种访存指令统一起来;


assign w_load_1  =  w_int1_16[4];
assign w_store_1 = ~w_int1_16[4];
assign w_loadSign_1 = w_int1_16[8];
//12/4 zwm loadstorewidth == 11 be load/store word , == 10 be load/store double word
//!!! 12/4 zwm load/store exclusive is not correct!
assign w_loadStoreWidth_2 = w_ldrdStrdI8_1 == 1'b1 ? 2'b10 : (w_int1_16[6:5] == 2'b10 ? 2'b11 : w_int1_16[6:5]);

// load/store double and exclusive and table branch

(* dont_touch="true" *) wire w_ldrexStrexI8_1;
(* dont_touch="true" *) wire w_ldrStrExb_1, w_ldrStrExh_1; 
(* dont_touch="true" *) wire w_tbb_1, w_tbh_1;
(* dont_touch="true" *) wire w_loadStoreDouble_1;

(* dont_touch="true" *) wire w_ldrStrEx_1;

(* dont_touch="true" *) wire w_DP_1, w_DU_1, w_DW_1;
//loadAndStoreMultiple
(* dont_touch="true" *)wire w_ldmdb_1, w_stmdb_1, w_stmia_1, w_push_1, w_ldmia_1, w_pop_1;

assign w_DP_1 = w_int1_16[8];
assign w_DU_1 = w_int1_16[7];
assign w_DW_1 = w_int1_16[5];
//11.1hrq -> add MultiLS
//12/12 zwm w_loadStoreI_1 is not all use w_SP_1 
assign w_P_1 = w_loadStoreI8_1 & w_SP_1
             | w_loadStoreI12_1
             | w_DP_1 & w_ldrdStrdI8_1
             | w_RP_1 & w_loadStoreR_1
             | w_ldmdb_1 | w_push_1 | w_stmdb_1;

assign w_U_1 = w_loadStoreI8_1 & w_SU_1
             | w_loadStoreI12_1 
             | w_DU_1 & w_ldrdStrdI8_1
             | w_RU_1 & w_loadStoreR_1
             | w_DU_1 & w_isMultiLS_1;
//11.1hrq -> add MultiLS
assign w_W_1 = w_loadStoreI8_1 & w_SW_1 
             | w_DW_1 & w_ldrdStrdI8_1
             | w_RW_1 & w_loadStoreR_1
             | w_DW_1 & w_isMultiLS_1;

assign w_ldrdStrdI8_1 = (w_op_7 == 7'b1110100) & (w_int1_16[6] == 1'b1) & (w_DP_1 | w_DW_1);
assign w_ldrexStrexI8_1 = (w_op_7 == 7'b1110100) & (w_int1_16[6] == 1'b1) & ~(w_DP_1 | w_DW_1 | w_DU_1);
assign w_ldrStrExb_1 = (w_op_7 == 7'b1110100) & (w_int1_16[8:5] == 4'b0110) & (w_int2_16[7:4] == 4'b0100); 
assign w_ldrStrExh_1 = (w_op_7 == 7'b1110100) & (w_int1_16[8:5] == 4'b0110) & (w_int2_16[7:4] == 4'b0101);
assign w_tbb_1 = (w_op_7 == 7'b1110100) & (w_int1_16[8:5] == 4'b0110) & (w_int2_16[7:4] == 4'b0000);
assign w_tbh_1 = (w_op_7 == 7'b1110100) & (w_int1_16[8:5] == 4'b0110) & (w_int2_16[7:4] == 4'b0001);
assign w_loadStoreDouble_1 = w_ldrdStrdI8_1 | w_ldrexStrexI8_1;
assign w_ldrStrEx_1 = w_ldrStrExb_1 | w_ldrStrExh_1;

assign w_isLS_1 = w_loadAndStoreSingle_1 | w_loadStoreDouble_1 | w_ldrStrEx_1 | w_isMultiLS_1;


assign w_ldmdb_1     = (w_op_7 == 7'b1110100) & (w_int1_16[8:6] == 3'b100) & (w_int1_16[4] == 1'b1);
assign w_ldmia_1     = (w_op_7 == 7'b1110100) & (w_int1_16[8:6] == 3'b010) & (w_int1_16[4] == 1'b1);
assign w_pop_1       = (w_op_7 == 7'b1110100) & (w_int1_16[8:0] == 9'b010111101);
assign w_push_1      = (w_op_7 == 7'b1110100) & (w_int1_16[8:0] == 9'b100101101);
//assign w_srs_1       = (w_op_7 == 7'b1110100) & (w_int1_16[8:6] == 3'b110) & (w_int1_16[4] == 1'b0);
assign w_stmdb_1     = (w_op_7 == 7'b1110100) & (w_int1_16[8:6] == 3'b100) & (w_int1_16[4] == 1'b0);
assign w_stmia_1     = (w_op_7 == 7'b1110100) & (w_int1_16[8:6] == 3'b010) & (w_int1_16[4] == 1'b0); 
assign w_isMultiLS_1 = w_ldmdb_1 | w_ldmia_1 | w_pop_1 | w_push_1 | w_stmdb_1 | w_stmia_1;
(* dont_touch="true" *) wire w_cB_1, w_ucB_1, w_bl_1;
(* dont_touch="true" *) wire w_mrs_1, w_msr_1;
(* dont_touch="true" *) wire w_return_1;
(* dont_touch="true" *) wire w_B_1;
(* dont_touch="true" *) wire [3:0] w_cond_4;

assign w_ucB_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b0) & (w_int2_16[12] == 1'b1);
assign w_bl_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b1) & (w_int2_16[12] == 1'b1);
assign w_cB_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b0) & (w_int2_16[12] == 1'b0) & (w_int1_16[9:6] != 4'b1111);
assign w_mrs_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b0) & (w_int2_16[12] == 1'b0) & (w_int1_16[9:5] == 5'b11111); // 读特殊寄存器
assign w_msr_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b0) & (w_int2_16[12] == 1'b0) & (w_int1_16[9:5] == 5'b11100); // 写特殊寄存器
assign w_return_1 = (w_op_5 == 5'b11110) & (w_int2_16[15] == 1'b1) & (w_int2_16[14] == 1'b0) & (w_int2_16[12] == 1'b0) & (w_int1_16[9:5] == 5'b11111);

assign w_cond_4 = w_int1_16[9:6];

assign w_B_1 = w_ucB_1 | w_cB_1 | w_bl_1;


wire w_isSportInt;
assign w_isSportInt = w_B_1 | w_msr_1 | w_mrs_1 | w_isLS_1 | w_tbb_1 | w_tbh_1 | w_mul64_1 | w_div64_1 | w_umlal_1 
                    | w_mulAndSum32_1 | w_otherThereReg_1 | w_xt_1 | w_regControlShift_1 | w_dataProConstantShift_1 | w_bitdieldAndSaturate_1
                    | w_movePlainImm16_1 | w_dataProPlainImm12_1 | w_dataProModifImm12_1; // 2025.1.3 zlt add

// assign o_excNum_4 = w_isSportInt ? 4'b1111 : 4'b0101; // 2025.1.3 zlt add
assign o_excNum_4 = 4'b1111; // 2025.1.3 zlt add

wire w_I1, w_I2;

assign w_I1 = ~(w_int2_16[13] ^ w_int1_16[10]);
assign w_I2 = ~(w_int2_16[11] ^ w_int1_16[10]);

wire [8:0] w_blImm9_9;
assign w_blImm9_9 = {w_int1_16[10], w_I1, w_I2, w_int1_16[9:4]}; 
// 暂定结束所有指�???????

//立即数类型和对应的扩展类�???????

(* dont_touch="true" *) wire w_imm2_1, w_imm5_1, w_imm8_1, w_imm12_1, w_imm16_1;
(* dont_touch="true" *) wire w_imm3_1, w_imm7_1, w_imm11_1;
(* dont_touch="true" *) wire w_immZero_1, w_immSign_1, w_immDecode_1, w_immThumb_1;
(* dont_touch="true" *) wire [1:0] w_immExtType_2;
(* dont_touch="true" *) wire [7:0] w_immType_8;


//12/11 zwm w_loadStoreDouble_1 is also belong to w_imm8_1
assign w_imm12_1 = w_dataProModifImm12_1 | w_dataProPlainImm12_1 | w_loadStoreI12_1;
assign w_imm16_1 = w_movePlainImm16_1;
assign w_imm8_1 = w_loadStoreI8_1 | w_loadStoreDouble_1 | w_clz_1;
assign w_imm5_1 = w_bitdieldAndSaturate_1 | w_dataProConstantShift_1;
assign w_imm2_1 = w_loadStoreR_1;
assign w_imm3_1 = 0;
assign w_imm7_1 = 0;
assign w_imm11_1 = 0;

assign w_immType_8 = {w_imm16_1, w_imm12_1, w_imm8_1, w_imm5_1, w_imm2_1, w_imm11_1, w_imm7_1, w_imm3_1};
assign w_isImm_1 = |w_immType_8 | w_bl_1 | w_clz_1 | w_ucB_1;
assign w_immExtType_2 = {2{w_immZero_1}} & 2'b00
                      | {2{w_immSign_1}} & 2'b01
                      | {2{w_immDecode_1}} & 2'b10
                      | {2{w_immThumb_1}} & 2'b11;

assign w_immZero_1 = w_dataProPlainImm12_1 | w_movePlainImm16_1 | w_bitdield_1 | w_isXt_1 | w_isLS_1;
assign w_immSign_1 = w_B_1;
assign w_immDecode_1 = w_saturate_1 | w_dataProConstantShift_1;
assign w_immThumb_1 = w_dataProModifImm12_1;// 再考虑一下ThumbExpandImmWithC()

// 立即数扩展放到分派模块去做，这里只传16位的imm
assign w_immToLaunch_16 = {{16{w_dataProModifImm12_1 | w_dataProPlainImm12_1}} & {4'b0 ,w_imm_12}} 
                | {16{w_movePlainImm16_1}} & w_imm_16
                | {16{w_bitdieldAndSaturate_1}} & {11'b0, w_satOrLsbit_5}
                | {16{w_dataProConstantShift_1}} & {11'b0, w_imm_5} 
                | {16{w_loadStoreI12_1}} & {4'b0, w_LoadAndStoreImm_12}
                | {16{w_loadStoreI8_1}} & {8'b0, w_imm_8}
                | {16{w_loadStoreR_1}} & {14'b0, w_imm_2}
                | {16{w_isXt_1}} & {{11{1'b0}}, w_int2_16[5:4], {3{1'b0}}}
                | {16{w_loadStoreDouble_1}} & {{6{1'b0}}, w_imm_8, {2{1'b0}}} 
                | {16{(w_stmia_1 | w_stmdb_1 | w_push_1)}} & {1'b0,w_int2_16[14],1'b0, w_int2_16[12:0]}
                | {16{(w_pop_1 | w_ldmia_1 | w_ldmdb_1)}} & {w_int2_16[15:14],1'b0, w_int2_16[12:0]}
                | {16{w_bl_1 | w_ucB_1}} & {w_int1_16[3:0], w_int2_16[10:0], 1'b0}
                | {16{w_clz_1}} & {16'd31}; 


// 指令的分�???????
(* dont_touch="true" *) wire w_thumbExpandRor_1;
assign w_thumbExpandRor_1 = w_dataProModifImm12_1 & w_imm_12[11:10] != 2'b00;
// 后续立即数取反和从寄存器中的数取�???????
// 还有中间结果的取�???????
(* dont_touch="true" *) wire w_rnNot_1, w_rmNot_1, w_immNot_1;
(* dont_touch="true" *) wire w_opNot_1;
// thunmImmExend
assign w_isShitf_1 = w_imm_12[11] | w_imm_12[10];

assign  w_rnNot_1 = w_rsbRConsShift_1 | w_rsbMI12_1;
//还需要再考虑访存指令 -->�???????
//12/12 zwm w_mls_1 is belong to w_opNot_1
assign w_immNot_1 = (w_bicMI12_1 & ~ w_isShitf_1) | (w_mvnMI12_1 & ~ w_isShitf_1) | (w_ornMI12_1 & ~ w_isShitf_1)
                  | (w_cmpMI12_1 & ~ w_isShitf_1) | w_subPI12_1 | w_adrSubP12_1
                  | (w_sbcMI12_1 & ~ w_isShitf_1) | (w_subMI12_1 & ~ w_isShitf_1) | (w_loadStoreI_1 & ~w_U_1)
                  | (w_ldrdStrdI8_1 & ~w_U_1) |(w_isMultiLS_1 & (w_int1_16[8:6] == 3'b100));   

assign w_opNot_1 = w_bicRConsShift_1 | w_cmpRConsShift_1 | w_mvnRConsShift_1 | w_ornRConsShift_1 | w_sbcRConsShift_1 | w_subRConsShift_1 | w_mls_1
                 | (w_bicMI12_1 & w_isShitf_1) | (w_mvnMI12_1 & w_isShitf_1) | (w_ornMI12_1 & w_isShitf_1)
                 | (w_cmpMI12_1 & w_isShitf_1) 
                 | (w_sbcMI12_1 & w_isShitf_1) | (w_subMI12_1 & w_isShitf_1) 
                 | w_clz_1;

// op1,op2,op3 --->分派模块
//指令集中的部分内容和指令实际用到的操作数不符，这里有改动
(* dont_touch="true" *) wire w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3; 
(* dont_touch="true" *) wire w_writeRd_1;
(* dont_touch="true" *) wire [1:0] w_wen_2;

//12/3 zwm add rd logic 
wire w_rd11to8_1,w_rt15to12_1;
assign w_rd11to8_1 = w_dataProModifImm12_1 | w_dataProPlainImm12_1 | w_movePlainImm16_1 | w_bitdieldAndSaturate_1 | w_dataProConstantShift_1 |
                     w_regControlShift_1 | w_isXt_1 | w_otherThereReg_1 | w_mulAndSum32_1 | w_mul64_1 | w_div64_1 | w_loadStoreDouble_1 | w_ldrStrEx_1 | w_tbb_1 | w_tbh_1;
//12/3 zwm lazy to add each inst
assign w_rt15to12_1 = ~w_rd11to8_1;
//12/9 zwm w_movMI12_1 also don't need rn
//12/11 zwm w_loadStoreDouble_1 also belong to w_rnOp1
assign w_rnOp1 = (w_dataProModifImm12_1 & ~w_isShitf_1 & ~w_mvnMI12_1 & ~w_movMI12_1) | w_saturate_1 | w_mulAndSum32_1 | w_mul64_1 | w_div64_1 | w_regControlShift_1
               | (w_dataProPlainImm12_1 & ~w_adrAddPI12_1 & ~w_adrSubP12_1 ) | w_loadStoreI12_1 | w_loadStoreI8_1 | w_ldrStrEx_1 | w_mrs_1 | w_msr_1 | w_isMultiLS_1 | w_loadStoreDouble_1;

assign w_rmOp1 = w_loadStoreR_1 | w_shiftImm5_1 | w_dataProConstantShift_1 | w_otherThereReg_1 | w_isXt_1;

assign w_rmOp2 = w_mulAndSum32_1 | w_mul64_1 | w_div64_1 | w_regControlShift_1; // 字节等互斥访问指�???????

//update
assign w_rnOp3 = w_loadStoreR_1 | (w_bitdield_1 & ~w_bfc_1 ) | w_thumbExpandRor_1 | w_dataProConstantShift_1;

assign w_immOp3 = w_saturate_1;

assign w_writeRd_1 = ~(w_cmnRConsShift_1 | w_cmpRConsShift_1 | w_teqRConsShift_1 | w_tstRConsShift_1
                   | w_cmnMI12_1 | w_cmpMI12_1 | w_teqMI12_1 | w_tstMI12_1 | w_cB_1 | w_ucB_1);  //(?)

//12/3 zwm change  w_rd_4 logic
//12/13 zwm if not writeRd should set default value 4'hf
assign w_rd_4 =   {4{w_writeRd_1}} & w_int2_16[11:8] & {4{~w_bl_1}} & {4{w_rd11to8_1}} 
                | {4{w_writeRd_1}} & w_int2_16[15:12] &{4{~w_bl_1}} & {4{w_rt15to12_1}} 
                | {4{w_writeRd_1}} & {4{w_bl_1}} & 4'd14
                | {4{~w_writeRd_1}} & 4'hf;

//!!!这里的逻辑有问�???????
//12/9 zwm default is 4'hf
// assign w_rdLo_4 = {4{w_mul64_1 | w_mulAndSum32_1 | w_loadStoreDouble_1}} & w_int2_16[15:12]; 
assign w_rdLo_4 = (w_mul64_1 | w_mulAndSum32_1 | w_loadStoreDouble_1) ? w_int2_16[15:12] : 4'hf; 


assign w_wen_2 = {w_mul64_1 | w_loadStoreDouble_1} ? 2'b11 : 2'b10;

// 特殊寄存器的地址->用来分派模块检测相关�?

(* dont_touch="true" *) wire [7:0] w_sRs_8, w_sRd_8;

assign w_sRs_8 = w_mrs_1 ? w_int2_16[7:0] : 8'b1111_1110;
assign w_sRd_8 = w_msr_1 ? w_int2_16[7:0] : 8'b1111_1111;


// 为路径分�???????



assign w_aluWritePC_1 = w_addAluPC_1 | w_movAluWritePC_1; 

// add 需要判断thumb扩展
//12/12 zwm  w_ldrdStrdI8_1 & w_store_1 is not correct,should be w_ldrdStrdI8_1 & w_P_1 & ~w_isPC_1
assign w_add_1 = (w_adcMI12_1 & ~ w_isShitf_1) | (w_addMI12_1 & ~ w_isShitf_1) | w_addPI12_1 | (w_cmnMI12_1 & ~ w_isShitf_1) 
               | (w_cmpMI12_1 & ~ w_isShitf_1) | (w_rsbMI12_1 & ~ w_isShitf_1) | (w_sbcMI12_1 & ~ w_isShitf_1) | (w_subMI12_1 & ~ w_isShitf_1) 
               | w_subPI12_1  | w_sbfx_1 | w_ubfx_1 | ((w_loadStoreI8_1 | w_loadStoreI12_1) & w_P_1)
               | (w_ldrdStrdI8_1 & ~w_isPC_1) | w_tbb_1 | w_ldrexStrexI8_1 | w_isMultiLS_1;
// ALIGN,add
// lard判断rn是不�???????15在哪里做
//12/11 zwm w_ldrdStrdI8_1 is also need n == 15
assign w_alignAndAdd_1 = w_adrAddPI12_1 | w_adrSubP12_1 | (w_loadStoreI12_1 & w_load_1 & w_isPC_1)
                       | (w_ldrdStrdI8_1 & w_load_1 & w_isPC_1); 
// 把ALIGN放到分派做，如果是用到PC的直接在分派处理�???????,可选择的方案�?

// shift,add 需要判断thumb扩展
assign w_shiftAdd_1 = w_adcRConsShift_1 | (w_adcMI12_1 & w_isShitf_1) | (w_addMI12_1 & w_isShitf_1) | w_addRConsShift_1 
                    | (w_cmnMI12_1 & w_isShitf_1) | w_cmnRConsShift_1 | w_loadStoreR_1 | w_tbh_1 
                    | (w_cmpMI12_1 & w_isShitf_1) | w_cmpRConsShift_1 | (w_rsbMI12_1 & w_isShitf_1) | w_rsbRConsShift_1
                    | (w_sbcMI12_1 & w_isShitf_1) | w_sbcRConsShift_1 | (w_subMI12_1 & w_isShitf_1) | w_subRConsShift_1;

// mul,add
assign w_mulAdd_1 = w_mla_1 | w_smlal_1 | w_umlal_1 | w_mls_1;
// mul
assign w_onlyMul_1 = w_mul_1 | w_smull_1 | w_umull_1; 
//div
assign w_onlyDiv_1 = w_sdiv_1 | w_udiv_1;
//and
assign w_onlyAnd_1 = (w_andMI12_1 & ~ w_isShitf_1) | (w_tstMI12_1 & ~ w_isShitf_1) | (w_bicMI12_1 & ~ w_isShitf_1);
//eor
assign w_onlyEor_1 = (w_eorMI12_1 & ~ w_isShitf_1) | (w_teqMI12_1 & ~ w_isShitf_1);
//or
assign w_onlyOr_1 = (w_orrMI12_1 & ~ w_isShitf_1) | (w_ornMI12_1 & ~ w_isShitf_1);
//shift,and,还需要判断thumb扩展
assign w_shiftAnd_1 = (w_andMI12_1 & w_isShitf_1) | w_andRConsShift_1 | (w_tstMI12_1 & w_isShitf_1) 
                    | w_tstRConsShift_1 | (w_bicMI12_1 & ~ w_isShitf_1) | w_bicRConsShift_1;
//shift,eor,还需要判断thumb扩展
assign w_shiftEor_1 = (w_eorMI12_1 & w_isShitf_1) | w_eorRConsShift_1 | (w_teqMI12_1 & w_isShitf_1) | w_teqRConsShift_1;
//shift,or,还需要判断thumb扩展
assign w_shiftOr_1 = (w_ornMI12_1 & w_isShitf_1) | w_ornRConsShift_1 | (w_orrMI12_1 & w_isShitf_1) | w_orrRConsShift_1;
//shift (mov指令待商�???????)
assign w_onlyShift_1 = w_lslI5ConsShift_1 | w_lslRContShift_1 | w_lsrI5ConsShift_1 | w_lsrRContShift_1
                     | w_asrI5ConsShift_1 | w_asrRContShift_1 | w_rorI5ConsShift_1 | w_rorRShift_1
                     | w_rrx_1 | w_sxtb_1 | w_uxtb_1 | w_sxth_1 | w_uxth_1  
                     | (w_mvnMI12_1 & w_isShitf_1)
                     | (w_movMI12_1 & w_isShitf_1)
                     | w_mvnRConsShift_1; // movR删掉了，2024.10.08
//shift,SatQ
assign w_shiftSatQ_1 = w_usatASR_1 | w_usatLSL_1 | w_ssatASR_1 | w_ssatLSL_1;
//hsb,add
assign w_hsbAdd_1 = w_clz_1;
//rev
assign w_onlyRev_1 = w_rbit_1 | w_rev16_1 | w_revsh_1;


// 剩余工作
// 1. 立即数要取反的指�??????? -->上面
// 2. 移位的类�??????? -->解决
// 3. 现在的所有取非操作中，如果是立即数取非则去掉不需要传到执�??????? -->分派去对立即数取�??????? �???????
// 4. 数据�???????
// 5. 访存指令中有一位判断是否要做加法，不做的话就不进加法那条路了�?-->index-->w_p_1
// 6. 访存指令中有一位判断是否做加法还是减法，如果做减法要提前给imm取反�???????-->add-->w_u_1

// 区分5位的加法�???????32位的加法

(* dont_touch="true" *) wire w_add5_1;
(* dont_touch="true" *) wire w_add64_1;
assign w_add5_1 = w_bitdield_1; // �???????1时代�???????32位加法，�???????0代表5位加�???????
assign w_add64_1 = w_smlal_1;

// 加法进位的分�??????? -->因为要APSR.C的值所以只能放到分别派去做
(* dont_touch="true" *) wire w_addCarry_1, w_addC0_1, w_addC1_1, w_addC_1;// 加法运算的进位信息，进位恒为0，恒1，还有进位标志位--->BFC/BFI
//12/12 zwm w_mls_1 is not belong to w_addC0_1 ,belong to w_addC1_1
//12/13 zwm w_loadAndStoreSingle_1 is not all belong to w_addC0_1
//12/20 zwm w_clz_1 is belong to w_addC1_1
assign w_addC0_1 = w_addMI12_1 | w_cmnMI12_1 | w_tstMI12_1 | w_addPI12_1 | w_adrAddPI12_1 
                 | w_bitdield_1 | w_addRConsShift_1 | w_addAluPC_1 | w_loadSign_1 | w_cmnRConsShift_1
                 | (w_mulAdd_1 & ~w_mls_1) | w_loadStoreI12_1 | w_loadStoreR_1 | (w_loadStoreI8_1 & w_U_1) | w_loadStoreDouble_1 | w_ldrStrEx_1 |  w_ldmia_1 | w_stmia_1 | w_pop_1;
                 
assign w_addC1_1 = w_cmpMI12_1 | w_rsbMI12_1 | w_subMI12_1 | w_subPI12_1 | w_cmpRConsShift_1
                 | w_rsbRConsShift_1 | w_subRConsShift_1 | w_adrSubP12_1 | w_push_1 | w_ldmdb_1 | w_stmdb_1 | w_mls_1 | (w_loadStoreI8_1 & ~w_U_1) | w_clz_1;
// branch ;
                  
assign w_addC_1 = w_adcMI12_1 | w_sbcMI12_1 | w_adcRConsShift_1 | w_sbcRConsShift_1;                                 

// assign w_addCarry_1 = w_addC0_1 & 1'b0
//                     | w_addC1_1 & 1'b1
//                     | w_addC_1 &

// assign w_addType_2 = {w_add5_1, }

// 移位时是否需要进�???????,是否产生进位
(* dont_touch="true" *) wire w_shiftC_1; // thumbExpandImmWithC
assign w_shiftC_1 = w_andRConsShift_1 | w_bicRConsShift_1 | w_eorRConsShift_1 | w_shiftImm5_1 
           | w_mvnRConsShift_1 | w_ornRConsShift_1 | w_orrMI12_1 | w_teqRConsShift_1
           | w_tstRConsShift_1 | w_regControlShift_1 | w_andMI12_1 | w_bicMI12_1
           | w_eorMI12_1 | w_movMI12_1 | w_mvnMI12_1 | w_ornMI12_1 | w_teqMI12_1 | w_tstMI12_1 ;

// 哪种REV指令
(* dont_touch="true" *) wire [1:0] w_revType_2; 
assign w_revType_2 = {2{w_rbit_1}}  & 2'b00
                   | {2{w_rev_1}}   & 2'b01
                   | {2{w_rev16_1}} & 2'b10
                   | {2{w_revsh_1}} & 2'b11;
 
// 哪种饱和运算
(* dont_touch="true" *) wire w_satSign_1;
assign w_satSign_1 = w_ssatASR_1 | w_ssatLSL_1; //�???????1时代表有符号，为0代表无符�???????
// 哪种乘除�???????
(* dont_touch="true" *) wire w_mulDivSign_1, w_mulDivType_1;
//11/26 zwm w_smull_1 | w_smlal_1 | w_sdiv_1 delete
assign w_mulDivSign_1 = w_S_1;//�???????1时代表有符号运算
assign w_mulDivType_1 = w_mulAndSum32_1;//�???????1时代�???????32位乘，为0时代�???????64位乘法和64位除�???????

// sxtb、sxth、uxtb、uxth
(* dont_touch="true" *) wire w_xtSize_1, w_xtSign_1;

assign w_xtSign_1 = w_sxtb_1 | w_sxth_1; // �???????1时代表有符号扩展，为0时代表无符号扩展
assign w_xtSize_1 = w_sxtb_1 | w_uxtb_1; // �???????1时代�???????8位，�???????0时代�???????16�???????
assign w_isXt_1 = w_uxtb_1 | w_sxtb_1 | w_uxth_1 | w_sxth_1;


// 区分用到的立即数到底是几位的 -->不需�???????

// 移位的种�???????-->ror和rrx 

(* dont_touch="true" *) wire w_rorType_1, w_rrxType_1, w_ror_1;
//12/5 zwm add w_lslType_1,w_lsrType_1,w_asrType_1
wire w_lslType_1,w_lsrType_1,w_asrType_1;

assign w_rorType_1 = w_ror_1 | w_immDecode_1 & w_shift_2 == 2'b11 & w_imm_5 == 5'b0 | w_immThumb_1 & w_isShitf_1 | w_isXt_1;
assign w_rrxType_1 = w_rrx_1 | w_immDecode_1 & w_shift_2 == 2'b11 & w_imm_5 != 5'b0;
assign w_lslType_1 = w_lslRContShift_1 | w_loadStoreR_1;
assign w_lsrType_1 = w_lsrRContShift_1;
assign w_asrType_1 = w_asrRContShift_1;

assign w_ror_1 = w_rorI5ConsShift_1 | w_rorRShift_1;
assign w_shift_3 = {3{w_rorType_1}} & {3'b011}
                 | {3{w_rrxType_1}} & {3'b100}
                 | {3{w_lslType_1}} & {3'b000}
                 | {3{w_lsrType_1}} & {3'b001}
                 | {3{w_asrType_1}} & {3'b010}
                 | {3{w_saturate_1}} & {1'b0, w_int1_16[5], 1'b0}
                 | {3{!(w_rorType_1 | w_rrxType_1 | w_saturate_1 | w_lslType_1 | w_lsrType_1 | w_asrType_1)}} & {{1'b0, w_shift_2}};



//需要传给launch模块的数据包：w_bit_1, w_saturate_5, w_wat_1, w_immNot_1, w_pc_32, w_dHi_4, w_dLo_4, w_shift_3, P,W,U,S,w_not_1,w_addType_1,w_shiftC/S/Num/,revType,sats,mulS,insPath


(* dont_touch="true" *) wire [15:0] w_insType_16;
assign w_insType_16 = {16{w_add_1}}         &    16'h0001 
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

(* dont_touch="true" *) wire w_cbz_1, w_cbnz_1;
assign w_cbz_1 = 0;
assign w_cbnz_1 = 0;
(* dont_touch="true" *) wire w_bx_1, w_blx_1;
assign w_bx_1 = 0;
assign w_blx_1 = 0;
(* dont_touch="true" *) wire w_pushPopReg_1;
assign w_pushPopReg_1 = w_isMultiLS_1;

(* dont_touch="true" *) wire w_grfFlag_1;
assign w_grfFlag_1 = w_mla_1 | w_mls_1 | w_smlal_1;

(* dont_touch="true" *) wire [186:0] w_DecoderDataToLaunch_187;

assign o_blImm9_9 = w_blImm9_9;

//12/27 zwm dute to not all nzcv need update,so this need 4bits wen
wire w_notUpdateV_1,w_notUpdatCandV_1;

assign w_notUpdateV_1 = w_andMI12_1 | w_andRConsShift_1 | w_asrI5ConsShift_1 | w_asrRContShift_1 | w_bicMI12_1 |
                        w_bicRConsShift_1 | w_eorMI12_1 | w_eorRConsShift_1 |w_lslI5ConsShift_1 | w_lslRContShift_1 |
                        w_movMI12_1 |w_movRConsShift_1 | w_movPI16_1 | w_movAluWritePC_1 | w_mvnMI12_1 | w_mvnRConsShift_1 |
                        w_ornMI12_1 |w_ornRConsShift_1 | w_orrMI12_1 | w_orrRConsShift_1 | w_rorI5ConsShift_1 | w_rorRShift_1 |
                        w_rrx_1 | w_teqMI12_1 |w_teqRConsShift_1 | w_tstMI12_1 | w_tstRConsShift_1;
assign w_notUpdatCandV_1 = w_mul_1;
assign o_nzcvWen_4 = {4{w_notUpdateV_1}} & 4'b1110
                   | {4{w_notUpdatCandV_1}} & 4'b1100
                   | {4{~w_notUpdatCandV_1 & ~w_notUpdateV_1}} & 4'b1111;

assign w_DecoderDataToLaunch_187 = {w_S_1,w_rm_4,
                                    w_rn_4,
                                    w_sRs_8,
                                    w_immExtType_2,
                                    w_immType_8,
                                    w_immToLaunch_16,
                                    w_widthm1_5,  // 位操作和饱和指令用到的第二个立即�??????? 
                                    w_isImm_1, //是否包含立即�???????
                                    w_pushPopReg_1,
                                    w_pc_32,
                                    w_cond_4,
                                    w_addC0_1, w_addC1_1, w_addC_1, w_add5_1, w_add64_1,
                                    w_rnOp1, w_rmOp1, w_rmOp2, w_rnOp3, w_immOp3, w_bitdield_1,w_thumbExpandRor_1,
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
                                    w_satSign_1, // 饱和运算的符�???????
                                    w_shiftC_1,
                                    w_xtSign_1, w_xtSize_1,
                                    w_mulDivSign_1,w_bfi_1, w_bfc_1, w_sbfx_1, w_ubfx_1,w_widthm1_5,w_satOrLsbit_5,w_isMultiLS_1,w_rn_4,w_wen_2
                                    };
assign o_data_187 = w_DecoderDataToLaunch_187;


(* dont_touch="true" *)delay16U topdelay0 (.inR(i_drive), .outR(o_drive), .rst(rst));
assign o_free = i_free;

endmodule  
