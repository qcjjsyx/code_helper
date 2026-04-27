/*=============================================================
Project:ARMCPU
Module:inStack
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:
==============================================================*/


`timescale 1ns/1ps


module inStack (
    input i_inOutDriToDataSpli_1,
    input rst,
    input i_freeFromRGRF_1,
    input i_freeFromRPSR_1,
    input i_driveFromRGRF_1,
    input i_driveFromRPSR_1,
    //input i_freeFormDR_1,
    input[191:0] i_grfData_192,
    input[31:0] i_psrData_32,
    input i_DRSeleDriToinStackSele_1,
    //input i_driveFromDR_1,
    input i_freeFromDR_1,
    input [31:0]i_SP_32,
    input i_freeFromSPDec,
    input [31:0] i_pc_32,

    output o_freeFrominStackSele_1,
    output o_w_inStackDriToDR_1,
    output[31:0] o_SP_32,
    output o_driveFromSPDec,
output[95:0] o_data_96,
    // output[63:0] o_data0_64,
    // output[63:0] o_data1_64,
    // output[63:0] o_data2_64,
    // output[63:0] o_data3_64,



    output o_freeFromInStack,
    output o_freeToRGRF_1,
    output o_freeToRPSR_1,
    output o_driveToRGRF_1,
    output o_driveToRPSR_1
    
);
    

(* dont_touch="true" *)    cSplitter2_1b_Nodata dataSpli(.i_drive(i_inOutDriToDataSpli_1), /*.i_data_1(),*/ .o_free(o_freeFromInStack),
    .o_driveNext0(o_driveToRGRF_1),.i_freeNext0(i_freeFromRGRF_1),/*.o_data0_1(),*/
    .o_driveNext1(o_driveToRPSR_1),.i_freeNext1(i_freeFromRPSR_1),/*.o_data1_1(),*/
    .rst(rst));


    //等待RGF和RPSR准备好数�?



    wire w_dataMerDriveToInMer_1, w_freeFromInMer_1;
    wire[223:0] w_stackData_224;
(* dont_touch="true" *)    cWaitMerge2_224b_int dataMerge(.i_drive0(i_driveFromRGRF_1), .i_data0_192(i_grfData_192),.o_free0(o_freeToRGRF_1),
                        .i_drive1(i_driveFromRPSR_1), .i_data1_32(i_psrData_32), .o_free1(o_freeToRPSR_1),
                        .o_driveNext(w_dataMerDriveToInMer_1), .o_data_224(w_stackData_224), .i_freeNext(w_freeFromInMer_1),
                        .rst(rst));


wire [63:0] w_inData0_64, w_inData1_64, w_inData2_64, w_inData3_64;
wire [31:0] w_inData0Addr_32, w_inData1Addr_32, w_inData2Addr_32, w_inData3Addr_32;



assign w_inData0_64 = {i_pc_32, w_stackData_224[223:192]};//w_pc_32 固定�? 32'h0000abcd
assign w_inData1_64 = w_stackData_224[191:128];
assign w_inData2_64 = w_stackData_224[127:64];
assign w_inData3_64 = w_stackData_224[63:0];

assign w_inData0Addr_32 = i_SP_32 - 8;// i_SP_32 固定�?32'h0000ab30
assign w_inData1Addr_32 = i_SP_32 - 16;
assign w_inData2Addr_32 = i_SP_32 - 24;
assign w_inData3Addr_32 = i_SP_32 - 32;


wire  w_freeFormDR_1,w_inStackDri_1, w_inStackFree_1,w_inStackDriToDR_1;

(* dont_touch="true" *) cMutexMerge2_1b inStackMerge(.i_drive0(w_dataMerDriveToInMer_1), .i_data0_1(), .o_free0(w_freeFromInMer_1),
                        .i_drive1(w_inStackDri_1), .i_data1_1(), .o_free1(w_inStackFree_1),
                        .i_freeNext(i_freeFromDR_1), .o_driveNext(w_inStackDriToDR_1), .o_data_1(),
                        .rst(rst));

//3/24 zwm add delay8U
delay8U Delay1(.inR(w_inStackDriToDR_1), .outR(o_w_inStackDriToDR_1), .rst(rst)); //延时打拍

wire w_inNumPose_1,w_inStackSeleToMe_1;
assign w_inNumPose_1 = w_inStackDri_1 | w_inStackSeleToMe_1;

reg [1:0] r_inNum_2;
wire [1:0] w_inNum_2; 

always @(posedge w_inNumPose_1 or negedge rst) begin
    if(!rst) begin
        r_inNum_2 <= 2'b0; 
    end else begin
        r_inNum_2 <= r_inNum_2+1;
    end
end

assign w_inNum_2 = r_inNum_2;
assign o_data_96 = (w_inNum_2==2'b00)?({w_inData0_64,w_inData0Addr_32}):
                   (w_inNum_2==2'b01)?({w_inData1_64,w_inData1Addr_32}):
                   (w_inNum_2==2'b10)?({w_inData2_64,w_inData2Addr_32}):
                   (w_inNum_2==2'b11)?({w_inData3_64,w_inData3Addr_32}): 96'b0;
wire w_freeFrominStackSele_1, w_DRSeleDriToinStackSele_1; 
(* dont_touch="true" *) cSelector2_1b inStackSele(.i_drive(i_DRSeleDriToinStackSele_1), .i_data_1(w_inNum_2 == 2'b11), .o_free(o_freeFrominStackSele_1),
                        .o_driveNext0(w_inStackSeleToMe_1), .i_freeNext0(i_freeFromSPDec), .o_data0_1(),
                        .o_driveNext1(w_inStackDri_1), .i_freeNext1(w_inStackFree_1), .o_data1_1(),
                        .rst(rst));


//wire[31:0] i_SP_32;
reg[31:0] r_SP_32;

always@(posedge w_inStackSeleToMe_1 or negedge rst)
    begin
        if(!rst) begin 
            r_SP_32 <= 32'hFFFFFFFF;//w_NAddr_32;
        end
        else begin
        r_SP_32 <= w_inData3Addr_32;
        end
    end

    //assign i_SP_32 = r_SP_32;
    assign o_SP_32 = r_SP_32;
delay4U Delay0(.inR(w_inStackSeleToMe_1), .outR(o_driveFromSPDec), .rst(rst)); //延时打拍
    //assign o_driveFromSPDec=  w_inStackSeleToMe_1;
    
//cSelector3_66b_int DRSelector (.i_drive(i_driveFromDR_1), .i_data_66({2'b10, 64'b0}), .o_free(),
//                        .o_driveNext0(), .i_freeNext0(), .o_data0_64(),
//                        .o_driveNext1(w_DRSeleDriToinStackSele_1), .i_freeNext1(1'b0), .o_data1_64(), //入栈不需要返回数�?
//                        .o_driveNext2(), .i_freeNext2(), .o_data2_64(),
//                        .rst(rst)); 
//cFifo1 fifo0(.i_drive(i_driveFromDR_1),.rst(rst),.i_freeNext(w_freeFrominStackSele_1),.o_free(w_freeFormDR_1),.o_driveNext(w_DRSeleDriToinStackSele_1),.o_fire_1());


endmodule
