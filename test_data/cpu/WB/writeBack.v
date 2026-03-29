`timescale 1ns / 1ps
//======================================================
// Project:     TPU
// Module:      writeBack
// Author:      Hongrui Miao
// Reviser:     Hongrui Miao
// Mail??       miaohr21@lzu.edu.cn
// Date:        2025/11/20
// Description: 
//======================================================

module writeBack (
    // From Mem
    input [245:0]  i_dataLSUToWb_246,
    input          i_driveLSUToWb,
    output         o_freeWbToLSU,

    // To Grf
    output [68:0]  o_dataWbToGrf_69,
    output         o_driveWbToGrf,
    input          i_freeGrfToWb,

    // To Csrf
    output [75:0]  o_dataWbToCsrf_76,
    output         o_driveWbToCsrf,
    input          i_freeCsrfToWb,

    // To Fetch
    output [63:0]  o_dataWbToFetch_64,
    output         o_driveWbToFetch,
    input          i_freeFetchToWb,

    // reset
    input rst
    );


(* dont_touch="true" *)wire w_fire_reg;
(* dont_touch="true" *)wire w_driveFifoToNat;
(* dont_touch="true" *)wire w_freeNatToFifo;
(* dont_touch="true" *)reg  [245:0]r_dataLSUToWb_246;

(* dont_touch="true" *)wire [63:0]w_PC_64;
(* dont_touch="true" *)wire w_Compress_1;
(* dont_touch="true" *)wire [31:0]w_inst_32;
(* dont_touch="true" *)wire [3:0]w_type_4;
(* dont_touch="true" *)wire [4:0]w_rd_5;
(* dont_touch="true" *)wire [11:0]w_func_12;
(* dont_touch="true" *)wire [63:0]w_funcData_64;
(* dont_touch="true" *)wire [63:0]w_data_64;

(* dont_touch="true" *)wire w_driveFromNatToSel1;
(* dont_touch="true" *)wire w_driveFromNatToSel2;
(* dont_touch="true" *)wire w_freeFromSelToNat1;
(* dont_touch="true" *)wire w_freeFromSelToNat2;

(* dont_touch="true" *)wire w_isWriteGrf;
(* dont_touch="true" *)wire w_isWriteCsrf;

(* dont_touch="true" *)wire w_driveFromSelToNat1;
(* dont_touch="true" *)wire w_driveFromSelToMutex1;
(* dont_touch="true" *)wire w_freeFromNatToSel1;
(* dont_touch="true" *)wire w_freeFromMutexToSel1;
(* dont_touch="true" *)wire w_driveFromSelToNat2;
(* dont_touch="true" *)wire w_driveFromSelToMutex2;
(* dont_touch="true" *)wire w_freeFromNatToSel2;
(* dont_touch="true" *)wire w_freeFromMutexToSel2;

(* dont_touch="true" *)wire w_driveFromNatToMutex1;
(* dont_touch="true" *)wire w_freeFromMutexToNat1;
(* dont_touch="true" *)wire w_driveFromNatToMutex2;
(* dont_touch="true" *)wire w_freeFromMutexToNat2;

(* dont_touch="true" *)wire w_driveFromMutexToWait1;
(* dont_touch="true" *)wire w_freeFromWaitToMutex1;
(* dont_touch="true" *)wire w_driveFromMutexToWait2;
(* dont_touch="true" *)wire w_freeFromWaitToMutex2;

(* dont_touch="true" *)wire w_brudata_1;

(* dont_touch="true" *)wire w_driveFromNatToSel1_dealy;
(* dont_touch="true" *)wire w_driveFromNatToSel2_dealy;

(* dont_touch="true" *)wire [63:0]w_PCnew_64;

(* dont_touch="true" *)cFifo1_cpu cFifo1_cpu(
.i_drive(i_driveLSUToWb),
.o_free(o_freeWbToLSU),
.o_driveNext(w_driveFifoToNat),
.i_freeNext(w_freeNatToFifo),
.o_fire(w_fire_reg),
.rst(rst)
);

always @(posedge w_fire_reg or negedge rst) begin
if(!rst) begin
        r_dataLSUToWb_246  <= 246'b0;
    end
    else begin
        r_dataLSUToWb_246  <= i_dataLSUToWb_246;
    end
end

// 分开
assign  {
         w_PC_64,
         w_Compress_1,
         w_inst_32,
         w_type_4,
         w_rd_5,
         w_func_12,
         w_funcData_64,
         w_data_64         
                        }   = r_dataLSUToWb_246;

(* dont_touch="true" *)cNatSplit_2_fetch cNatSplit_2_fetch_1(
.i_drive(w_driveFifoToNat),
.i_freeNext0(w_freeFromSelToNat1),
.i_freeNext1(w_freeFromSelToNat2),
.o_free(w_freeNatToFifo),
.o_driveNext0(w_driveFromNatToSel1),
.o_driveNext1(w_driveFromNatToSel2),
.rst(rst)
);

(* dont_touch="true" *)delay8U  delay_free_cpu_sel1(
     .inR(w_driveFromNatToSel1), 
     .outR(w_driveFromNatToSel1_dealy), 
     .rst(rst)
);
(* dont_touch="true" *)delay8U  delay_free_cpu_sel2(
     .inR(w_driveFromNatToSel2), 
     .outR(w_driveFromNatToSel2_dealy), 
     .rst(rst)
);

(* dont_touch="true" *)assign w_isWriteGrf  = (w_type_4 == 4'b0010 | w_type_4 == 4'b0100) ? 1'b0 : 1'b1;
(* dont_touch="true" *)assign w_isWriteCsrf = (w_type_4 == 4'b0001) ? 1'b1 : 1'b0;
(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch_1(
.i_drive(w_driveFromNatToSel1_dealy),
.i_freeNext0(w_freeFromNatToSel1),
.i_freeNext1(w_freeFromMutexToSel1),
.valid0(w_isWriteGrf),
.valid1(~w_isWriteGrf),
.o_free(w_freeFromSelToNat1),
.o_driveNext0(w_driveFromSelToNat1),
.o_driveNext1(w_driveFromSelToMutex1),
.rst(rst)
);

(* dont_touch="true" *)cSelSplit_2_fetch cSelSplit_2_fetch_2(
.i_drive(w_driveFromNatToSel2_dealy),
.i_freeNext0(w_freeFromNatToSel2),
.i_freeNext1(w_freeFromMutexToSel2),
.valid0(w_isWriteCsrf),
.valid1(~w_isWriteCsrf),
.o_free(w_freeFromSelToNat2),
.o_driveNext0(w_driveFromSelToNat2),
.o_driveNext1(w_driveFromSelToMutex2),
.rst(rst)
);

(* dont_touch="true" *)cNatSplit_2_fetch cNatSplit_2_fetch_2(
.i_drive(w_driveFromSelToNat1),
.i_freeNext0(i_freeGrfToWb),
.i_freeNext1(w_freeFromMutexToNat1),
.o_free(w_freeFromNatToSel1),
.o_driveNext0(o_driveWbToGrf),
.o_driveNext1(w_driveFromNatToMutex1),
.rst(rst)
);
(* dont_touch="true" *)assign o_dataWbToGrf_69 = {w_data_64,w_rd_5};

(* dont_touch="true" *)cNatSplit_2_fetch cNatSplit_2_fetch_3(
.i_drive(w_driveFromSelToNat2),
.i_freeNext0(w_freeFromMutexToNat2),
.i_freeNext1(i_freeCsrfToWb),
.o_free(w_freeFromNatToSel2),
.o_driveNext0(w_driveFromNatToMutex2),
.o_driveNext1(o_driveWbToCsrf),
.rst(rst)
);
(* dont_touch="true" *)assign o_dataWbToCsrf_76 = {w_funcData_64,w_func_12}; //csr地址以及数据

(* dont_touch="true" *)cMutexMerge_2_WB cMutexMerge_2_WB_1(
.i_drive0(w_driveFromNatToMutex1),
.o_free0(w_freeFromMutexToNat1), 
.i_drive1(w_driveFromSelToMutex1),
.o_free1(w_freeFromMutexToSel1),
.o_driveNext(w_driveFromMutexToWait1),
.i_freeNext(w_freeFromWaitToMutex1),
.rst(rst)
);

(* dont_touch="true" *)cMutexMerge_2_WB cMutexMerge_2_WB_2(
.i_drive0(w_driveFromSelToMutex2),
.o_free0(w_freeFromMutexToSel2), 
.i_drive1(w_driveFromNatToMutex2),
.o_free1(w_freeFromMutexToNat2),
.o_driveNext(w_driveFromMutexToWait2),
.i_freeNext(w_freeFromWaitToMutex2),
.rst(rst)
);

(* dont_touch="true" *)cWaitMerge_2_WB cWaitMerge_2_WB(
.i_drive0(w_driveFromMutexToWait1),
.o_free0(w_freeFromWaitToMutex1), 
.i_drive1(w_driveFromMutexToWait2),
.o_free1(w_freeFromWaitToMutex2),
.o_driveNext(o_driveWbToFetch),
.i_freeNext(i_freeFetchToWb),
.rst(rst)
);
(* dont_touch="true" *)assign w_brudata_1 = 
       (w_type_4 == 4'b0101) ||
       (w_type_4 == 4'b0110) ||
       (w_type_4 == 4'b0100);
(* dont_touch="true" *)assign w_PCnew_64 =  w_Compress_1? (w_PC_64 + 2) : (w_PC_64 + 4);
(* dont_touch="true" *)assign o_dataWbToFetch_64 = 
    ({64{~w_brudata_1}} & w_PCnew_64) |
    ({64{ w_brudata_1}} & w_funcData_64);



endmodule