`timescale 1ns / 1ps
//======================================================
// Project: TPU
// Module:  exeTop_module
// Author:  Hongrui Miao
// Mail:    miaohr21@lzu.edu.cn
// Date:    2025/11/18
// Description: The top-level module of the execution module is responsible for connecting the ALU, AGU, BRU, CSR, DIV, MUL modules, and interacting with the decoding module and the memory access module.
//======================================================


module exe_top(
//reset
(* dont_touch="true" *)input           rst,

//decoder <--> exe
(* dont_touch="true" *)input           i_driveToExe,
(* dont_touch="true" *)output          o_freeFrmExe,
(* dont_touch="true" *)input [342:0]   i_decoderExeBus_343, 

//exe <--> mem
(* dont_touch="true" *)output          o_driveNextToLsu,
(* dont_touch="true" *)input           i_freeNextFrmLsu,
(* dont_touch="true" *)output [245:0]  o_exeLSUBus_246
    );

(* dont_touch="true" *)wire          w_freefifo;

(* dont_touch="true" *)wire [245:0]   w_exeLSUBus_246;
(* dont_touch="true" *)wire           w_driveFifoToSel;
(* dont_touch="true" *)wire           w_freeSelToFifo;
(* dont_touch="true" *)wire           w_fire_reg;
(* dont_touch="true" *)reg  [342:0]   r_dataFromDecoder_343;

(* dont_touch="true" *)wire [63:0]    w_rs1Value_64;
(* dont_touch="true" *)wire [63:0]    w_rs2Value_64;
(* dont_touch="true" *)wire [63:0]    w_imm_64;
(* dont_touch="true" *)wire [63:0]    w_PC_64;
(* dont_touch="true" *)wire [31:0]    w_inst_32;
(* dont_touch="true" *)wire [11:0]    w_aluControl_12;
(* dont_touch="true" *)wire           w_mul_1;
(* dont_touch="true" *)wire           w_mulLowHigh_1;
(* dont_touch="true" *)wire           w_div_1;
(* dont_touch="true" *)wire           w_remainder_1;
(* dont_touch="true" *)wire [1:0]     w_mulDivSign_2;
(* dont_touch="true" *)wire           w_CsrType_1;
(* dont_touch="true" *)wire [2:0]     w_CsrCsw_3;
(* dont_touch="true" *)wire           w_store_1;
(* dont_touch="true" *)wire           w_load_1;
(* dont_touch="true" *)wire           w_loadSign_1;
(* dont_touch="true" *)wire [1:0]     w_loadStoreWidth_2;
(* dont_touch="true" *)wire           w_Jal_1;
(* dont_touch="true" *)wire           w_Jalr_1;
(* dont_touch="true" *)wire           w_BType_1;
(* dont_touch="true" *)wire [3:0]     w_BTypeCon_4;
(* dont_touch="true" *)wire           w_branchSign_1;
(* dont_touch="true" *)wire           w_jumpOrNot_1;
(* dont_touch="true" *)wire [4:0]     w_rd_5;
(* dont_touch="true" *)wire [11:0]    w_rs2Csr_12;
(* dont_touch="true" *)wire           w_Compress_1;
(* dont_touch="true" *)wire           w_rv64_1;

(* dont_touch="true" *)wire           w_alu_1;
(* dont_touch="true" *)wire           w_agu_1;
(* dont_touch="true" *)wire           w_bru_1;

(* dont_touch="true" *)wire          w_driveNextalu;
(* dont_touch="true" *)wire          w_driveNextalu_delay;
(* dont_touch="true" *)wire          w_driveNextalu0_delay;
(* dont_touch="true" *)wire          w_freeNextalu;
(* dont_touch="true" *)wire          w_driveNextmul;
(* dont_touch="true" *)wire          w_driveNextmul_delay;
(* dont_touch="true" *)wire          w_driveNextmul0_delay;
(* dont_touch="true" *)wire          w_freeNextmul;
(* dont_touch="true" *)wire          w_driveNextdiv;
(* dont_touch="true" *)wire          w_driveNextdiv_delay;
(* dont_touch="true" *)wire          w_driveNextdiv0_delay;
(* dont_touch="true" *)wire          w_freeNextdiv;
(* dont_touch="true" *)wire          w_driveNextagu;
(* dont_touch="true" *)wire          w_driveNextagu_delay;
(* dont_touch="true" *)wire          w_driveNextagu0_delay;
(* dont_touch="true" *)wire          w_freeNextagu;
(* dont_touch="true" *)wire          w_driveNextcsr;
(* dont_touch="true" *)wire          w_driveNextcsr_delay;
(* dont_touch="true" *)wire          w_driveNextcsr0_delay;
(* dont_touch="true" *)wire          w_freeNextcsr;
(* dont_touch="true" *)wire          w_driveNextbru;
(* dont_touch="true" *)wire          w_driveNextbru_delay;
(* dont_touch="true" *)wire          w_driveNextbru0_delay;
(* dont_touch="true" *)wire          w_freeNextbru;

(* dont_touch="true" *)wire          w_driveNextToLsu;

(* dont_touch="true" *)wire [245:0]  w_aluResult_246;
(* dont_touch="true" *)wire [245:0]  w_mulResult_246;
(* dont_touch="true" *)wire [245:0]  w_divResult_246;
(* dont_touch="true" *)wire [245:0]  w_aguResult_246;
(* dont_touch="true" *)wire [245:0]  w_csrResult_246;
(* dont_touch="true" *)wire [245:0]  w_bruResult_246;

(* dont_touch="true" *)wire [234:0]  w_muldata_235;
(* dont_touch="true" *)wire [234:0]  w_muldata_valid_235;
(* dont_touch="true" *)wire [234:0]  w_divdata_235;
(* dont_touch="true" *)wire [234:0]  w_divdata_valid_235;

(* dont_touch="true" *)wire          w_driveFifoToSel_dealy1;

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu_1(
.i_drive(i_driveToExe),
.o_free(w_freefifo),
.o_driveNext(w_driveFifoToSel),
.i_freeNext(w_freeSelToFifo),
.o_fire(w_fire_reg),
.rst(rst)
);

always @(posedge w_fire_reg or negedge rst) begin
if(!rst) begin
        r_dataFromDecoder_343  <= 343'b0;
    end
    else begin
        r_dataFromDecoder_343  <= i_decoderExeBus_343;
    end
end

// 分开
(* dont_touch="true" *)assign  {
         w_rv64_1,
         w_Compress_1,          
         w_rs2Csr_12,               
         w_rd_5,                  
         w_jumpOrNot_1,         
         w_branchSign_1,       
         w_BTypeCon_4,          
         w_BType_1,             
         w_Jalr_1,              
         w_Jal_1,               
         w_loadStoreWidth_2,    
         w_loadSign_1,          
         w_load_1,              
         w_store_1,             
         w_CsrCsw_3,            
         w_CsrType_1,           
         w_mulDivSign_2,        
         w_remainder_1,         
         w_div_1,               
         w_mulLowHigh_1,        
         w_mul_1,               
         w_aluControl_12,       
         w_inst_32,
         w_PC_64,               
         w_imm_64,              
         w_rs2Value_64,         
         w_rs1Value_64          
                        }   = r_dataFromDecoder_343;

//择路的条件
(* dont_touch="true" *)assign w_alu_1 = | w_aluControl_12;
(* dont_touch="true" *)assign w_agu_1 = w_store_1 | w_load_1;
(* dont_touch="true" *)assign w_bru_1 = w_Jal_1 | w_Jalr_1 | w_BType_1;
//w_mul_1
//w_div_1
//w_CsrType_1

(* dont_touch="true" *)delay_free_cpu #(15)  delay_free_cpu_sel(
     .inR(w_driveFifoToSel), 
     .outR(w_driveFifoToSel_dealy1), 
     .rst(rst)
);
(* dont_touch="true" *)cSelSplit_6_exe cSelSplit_6_exe(
.i_drive(w_driveFifoToSel_dealy1),
.i_freeNext0(w_driveNextalu0_delay), 
.i_freeNext1(w_driveNextmul0_delay), 
.i_freeNext2(w_driveNextdiv0_delay), 
.i_freeNext3(w_driveNextagu0_delay),
.i_freeNext4(w_driveNextcsr0_delay), 
.i_freeNext5(w_driveNextbru0_delay),
.valid0(w_alu_1), 
.valid1(w_mul_1), 
.valid2(w_div_1), 
.valid3(w_agu_1),
.valid4(w_CsrType_1), 
.valid5(w_bru_1),
.o_free(w_freeSelToFifo),
.o_driveNext0(w_driveNextalu),
.o_driveNext1(w_driveNextmul), 
.o_driveNext2(w_driveNextdiv), 
.o_driveNext3(w_driveNextagu),
.o_driveNext4(w_driveNextcsr), 
.o_driveNext5(w_driveNextbru), 
.rst(rst)
);


(* dont_touch="true" *)delay_free_cpu #(1) u_delayALU0_donttouch(
     .inR(w_driveNextalu), 
     .outR(w_driveNextalu0_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(1) u_delayMUL0_donttouch(
     .inR(w_driveNextmul), 
     .outR(w_driveNextmul0_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(1) u_delayDIV0_donttouch(
     .inR(w_driveNextdiv), 
     .outR(w_driveNextdiv0_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(1) u_delayAGU0_donttouch(
     .inR(w_driveNextagu), 
     .outR(w_driveNextagu0_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(1) u_delayCSR0_donttouch(
     .inR(w_driveNextcsr), 
     .outR(w_driveNextcsr0_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(1) u_delayBRU0_donttouch(
     .inR(w_driveNextbru), 
     .outR(w_driveNextbru0_delay), 
     .rst(rst)
);


//assign w_muldata_171 = {rdExist_1, w_inst_32, w_exceptionInfo_5, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_mul_1, w_mulLowHigh_1, w_mulDivSign_2};
(* dont_touch="true" *)assign w_muldata_235 = {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_mul_1, w_mulLowHigh_1, w_mulDivSign_2, w_rv64_1};
//assign w_divdata_111 = {rdExist_1, w_inst_32, w_exceptionInfo_5, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_div_1, w_remainder_1, w_mulDivSign_2};
(* dont_touch="true" *)assign w_divdata_235 = {w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_div_1, w_remainder_1, w_mulDivSign_2, w_rv64_1};
(* dont_touch="true" *)assign w_muldata_valid_235 = {235{w_mul_1}} & {w_muldata_235};
(* dont_touch="true" *)assign w_divdata_valid_235 = {235{w_div_1}} & {w_divdata_235};

(* dont_touch="true" *)alu_module  alu_module(
//.i_aludata_151({rdExist_1, w_inst_32, w_exceptionInfo_5, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_aluControl_12}),  
.i_aludata_307({w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64,w_imm_64, w_rv64_1, w_aluControl_12}), //[241:210],[209:205],[204:141],[140:77],[76:13],[12],[11:0]   
.o_aluResult_246(w_aluResult_246)
);

(* dont_touch="true" *)mul_module  mul_module(
.i_muldata_235(w_muldata_valid_235),
.o_mulResult_246(w_mulResult_246)
);

(* dont_touch="true" *)div_module  div_module(
.i_divdata_235(w_divdata_valid_235),
.o_divResult_246(w_divResult_246)
);

(* dont_touch="true" *)agu_module  agu_module(
.i_agudata_300({w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_imm_64, w_rv64_1, w_store_1, w_load_1, w_loadSign_1, w_loadStoreWidth_2}),
.o_aguResult_246(w_aguResult_246)
);

(* dont_touch="true" *)csr_module  csr_module(
.i_csrdata_247({w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_rv64_1, w_CsrType_1, w_CsrCsw_3, w_rs2Csr_12}),
.o_csrResult_246(w_csrResult_246)
);

(* dont_touch="true" *)bru_module  bru_module(
.i_brudata_303({w_Compress_1, w_inst_32, w_rd_5, w_rs1Value_64, w_rs2Value_64, w_PC_64, w_imm_64, w_rv64_1, w_Jal_1, w_Jalr_1, w_BType_1, w_BTypeCon_4, w_branchSign_1}),
.o_bruResult_246(w_bruResult_246)
);

(* dont_touch="true" *)delay_free_cpu #(4) u_delayalu_donttouch(
     .inR(w_driveNextalu), 
     .outR(w_driveNextalu_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(40) u_delaymul_donttouch(
     .inR(w_driveNextmul), 
     .outR(w_driveNextmul_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(120) u_delaydiv_donttouch(
     .inR(w_driveNextdiv), 
     .outR(w_driveNextdiv_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(4) u_delayagu_donttouch(
     .inR(w_driveNextagu), 
     .outR(w_driveNextagu_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(4) u_delaycsr_donttouch(
     .inR(w_driveNextcsr), 
     .outR(w_driveNextcsr_delay), 
     .rst(rst)
);

(* dont_touch="true" *)delay_free_cpu #(8) u_delaybru_donttouch(
     .inR(w_driveNextbru), 
     .outR(w_driveNextbru_delay), 
     .rst(rst)
);


(* dont_touch="true" *)cMutexMerge_6_df_exe cMutexMerge_6_df_exe(
.i_drive0(w_driveNextalu_delay), 
.i_drive1(w_driveNextmul_delay), 
.i_drive2(w_driveNextdiv_delay),
.i_drive3(w_driveNextagu_delay),
.i_drive4(w_driveNextcsr_delay),
.i_drive5(w_driveNextbru_delay),
.i_data0(w_aluResult_246),  
.i_data1(w_mulResult_246),  
.i_data2(w_divResult_246),
.i_data3(w_aguResult_246),
.i_data4(w_csrResult_246),
.i_data5(w_bruResult_246),
.i_freeNext(i_freeNextFrmLsu),
.o_free0(w_freeNextalu), 
.o_free1(w_freeNextmul), 
.o_free2(w_freeNextdiv),
.o_free3(w_freeNextagu),
.o_free4(w_freeNextcsr),
.o_free5(w_freeNextbru),
.o_driveNext(w_driveNextToLsu),
.o_data(w_exeLSUBus_246),
.rst(rst)
);

(* dont_touch="true" *)assign o_freeFrmExe = w_freeNextalu|w_freeNextmul|w_freeNextdiv|w_freeNextagu|w_freeNextcsr|w_freeNextbru;

(* dont_touch="true" *)delay_free_cpu #(5) u_delaylsu_donttouch(
     .inR(w_driveNextToLsu), 
     .outR(o_driveNextToLsu), 
     .rst(rst)
);

(* dont_touch="true" *)assign o_exeLSUBus_246 = (w_rd_5 == 5'b0 && w_exeLSUBus_246[148:145] != 4'b0100 && w_exeLSUBus_246[148:145] != 4'b0010) ? {w_exeLSUBus_246[245:64],64'b0} : w_exeLSUBus_246; 

endmodule
