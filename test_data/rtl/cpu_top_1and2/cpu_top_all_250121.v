
`timescale 1ns/1ps

module cpu_top_all (
input i_driveFromStart_1,
input [31:0] i_startPc_32,
output o_freeToStart_1,

output o_drv2ICache,
output [104:0] o_cpuToIcache_105,
input  i_freeFICache,

input  i_drvFICache,
input [64:0] i_inst_65,
output o_free2ICache,

output o_lsuDriveToDataRout_1,
output [104:0] o_lsuToDataRoutData_105,
input  i_lsuFreeFromDataRout_1 ,

input i_dataRoutDriveToLsu_1,
input [64:0] i_memData_65,
output o_lsuFreeToDataRout_1,

// output o_driveToDataRoute_1, 
// output [103:0] o_dataRouteData_104,
// input  i_freeFromDataRoute_1,

//���壺i_IntSig={iic,wd,spi1,uart1,gpio,timer}
input [5:0]i_IntSig, 

input rst

);


wire w_launchDriveToIf_1, w_IfFreeToLaunch_1, w_driveToDec, w_freeFromDec, w_iFExcdriToInt, w_ifExcFreeFromInt,
     w_intDriToInt, w_ifIntFreeFromInt, w_ifDriToDec, w_ifDriToDecMer, w_ifDriToMe, w_decfreeToIf, w_freeFromDecMer;
wire [31:0] w_launchPC_32;
wire [65:0] w_instAndPC_66;
wire [3:0] w_intExcNum_4;
wire [5:0] w_intNum_6;
wire w_iFExcOrIntFlag_1,w_decoderExcFlag_1,w_exeExcFlag_1;

wire w_branchDri3, w_branchFree3,w_branchDri2, w_branchFree2,w_branchDri1, w_branchFree1, w_driveToDec1, w_driveToDec2;
wire [31:0] w_branchPC3_32, w_branchPC2_32, w_branchPC1_32, w_pcFTop_32;
wire w_free2Top, w_drvFTop, w_drvFTop1;
wire w_multiLSEnd_1;
reg [31:0] r_pc_32, r_branchPc_32;
wire [31:0] w_launchPC1_32;
wire w_launchPcDriToIf_1, w_launchBranchDri;
wire w_decoderDrive_1,w_decoderDriveToLaunch_1,w_decoDrive1ToLaunch_1,w_launchFreeToDecoder_1,w_launchFree1ToDecoder_1,w_decoSpliFreeToDeco_1;
wire [3:0] w_expen_4, w_wben_4;

(* dont_touch="true" *) cMutexMerge4_32b BranchMerge(.i_drive0(w_launchBranchDri), .i_data0_32(w_branchPC1_32), .o_free0(w_branchFree1),
    .i_drive1(w_branchDri2), .i_data1_32(w_branchPC2_32), .o_free1(w_branchFree2),
    .i_drive2(w_branchDri3), .i_data2_32(w_branchPC3_32), .o_free2(w_branchFree3),
    .i_drive3(i_driveFromStart_1), .i_data3_32(i_startPc_32), .o_free3(o_freeToStart_1),
    .i_freeNext(w_free2Top), .o_driveNext(w_drvFTop), .o_data_32(w_pcFTop_32),
    .rst(rst));

(* dont_touch="true" *) delay8U branchDelay1(.inR(w_drvFTop), .outR(w_drvFTop1), .rst(rst));

wire w_iFExcdriToInt1, w_intDriToInt1;
//12/24 zwm fetch should first pass through arbMerge
wire w_fetchDriveToIcache_1,w_fetchFreeFromIcache_1;
wire [31:0] w_fetchAddr_32;
wire w_drvFICache,w_free2ICache;
wire [63:0] w_inst_64;
wire w_driveToWaitMerge_1,w_freeFromWaitMerge_1;
//------------------------------------------big change-------------------------------------------------//
//1/3 zwm
wire w_fetchSele0ToMe,w_fetchSele1ToMe;
wire w_fetchSele0DriveToFetch_1,w_fetchSele0FreeFromFetch_1;
wire w_fetchSele1DriveToFetch_1,w_fetchSele1FreeFromFetch_1;
wire w_ifDrv2IfExcMutex,w_ifFreeFIfExcMutex;
wire w_ifDrv2IfIntMutex,w_ifFreeFIfIntMutex;
wire w_drv2Excp_2,w_freeFExcp_2;
wire w_isInInt;
wire [3:0] w_exceptionF_2_4;
wire [35:0] w_ifExc_36;
wire [36:0] w_ifInt_37;
wire [35:0] w_ifHelpDecExc_36;
wire [35:0] w_ifExcTmp_36;
wire [37:0] w_ifIntTmp_38;
wire [35:0] w_ifHelpDecExcTmp_36;
wire [35:0] w_decExcPcAndNum_36;
wire w_intDriToIntTmp,w_ifIntFreeFromIntTmp;
wire w_iFExcdriToIntTmp,w_ifExcFreeFromIntTmp;
wire w_drv2Excp_2Tmp,w_freeFExcp_2Tmp;
assign w_ifExcTmp_36 = {w_instAndPC_66[64:33],w_intExcNum_4};
assign w_ifIntTmp_38 = {w_instAndPC_66[64:33],w_intNum_6};
assign w_ifHelpDecExcTmp_36 = {w_instAndPC_66[64:33],w_exceptionF_2_4};


//1/10 zwm
wire w_decExcFlag_1,w_exeExcFlag0_1;
wire [3:0] w_decTrueNum_4;
wire [3:0] w_exeTrueNum_4;
assign w_decExcFlag_1 = w_decTrueNum_4[3:0] != 4'b1111;
assign w_exeExcFlag0_1 = w_exeTrueNum_4[3:0] != 4'b1111;
// assign w_decExcFlag_1 = w_decExcPcAndNum_36[3:0] != 4'b1111;
// reg r_ExcToIfFlag_1;
wire w_ExcToIfFlag_1;
wire w_branchFree3Delay_1;
contTap fetchTap(
.trig(w_branchDri3 | w_branchFree3Delay_1),
.req(w_ExcToIfFlag_1),
.rst(rst)
); 

(* dont_touch="true" *) delay8U branchDri3Delay(.inR(w_branchFree3), .outR(w_branchFree3Delay_1), .rst(rst));
//---------------------------------------------------------------------------------------------------------//
/*��ȡָǰ����������·���ж��Ƿ���Ҫ�ӷ��ɹ�����PC��fetchSele0Ϊ�ж��Ƿ���Ҫ����PC+2��PC+4��PC,�����뷢���쳣����������
w_decExcFlag_1�������Ƿ����쳣�ı�־��
fetchSele1Ϊ�ж��Ƿ���Ҫ����������תPC�����ж��쳣����PC��w_ExcToIfFlag_1��־�Ÿ�PC���ж��쳣ģ�����ģ������ж��쳣ģ������PC��Ȼ
�����ȡָ����Ϊһ�������жϻ��쳣ȡָ������ָ���൱�ڵ�һ��ָ�����w_exeExcFlag0_1���ȼ���ߣ����ִ�л�����������쳣����ô
w_ExcToIfFlag_1��Ȼ������������w_decExcFlag_1��w_exeExcFlag0_1������ֻҪ��������һ���쳣����Ҫ�̵���ȡָ��PC
*/
//---------------------------------------------------------------------------------------------------------//
cSelector2_1b fetchSele0(
    .i_drive(w_launchPcDriToIf_1), .i_data_1(w_decExcFlag_1), .o_free(w_IfFreeToLaunch_1),
    .o_driveNext0(w_fetchSele0ToMe), .i_freeNext0(w_fetchSele0ToMe), .o_data0_1(),
    .o_driveNext1(w_fetchSele0DriveToFetch_1), .i_freeNext1(w_fetchSele0FreeFromFetch_1), .o_data1_1(),
    .rst(rst)
);

//1/11 zwm
cSelector2_1b fetchSele1(
    .i_drive(w_drvFTop1), .i_data_1((w_decExcFlag_1 | w_exeExcFlag0_1) & ~w_ExcToIfFlag_1), .o_free(w_free2Top),
    .o_driveNext0(w_fetchSele1ToMe), .i_freeNext0(w_fetchSele1ToMe), .o_data0_1(),
    .o_driveNext1(w_fetchSele1DriveToFetch_1), .i_freeNext1(w_fetchSele1FreeFromFetch_1), .o_data1_1(),
    .rst(rst)
);
// cSelector2_1b fetchSele1(
//     .i_drive(w_drvFTop1), .i_data_1(w_decExcFlag_1 & ~w_ExcToIfFlag_1), .o_free(w_free2Top),
//     .o_driveNext0(w_fetchSele1ToMe), .i_freeNext0(w_fetchSele1ToMe), .o_data0_1(),
//     .o_driveNext1(w_fetchSele1DriveToFetch_1), .i_freeNext1(w_fetchSele1FreeFromFetch_1), .o_data1_1(),
//     .rst(rst)
// );
 reg [31:0] r_pcFTop_32;
 wire [31:0] w_pcTop_32;
always @(posedge w_drvFTop1 or negedge rst) begin
    if (!rst) begin
        r_pcFTop_32 <= 32'b0;
    end else begin
        r_pcFTop_32 <= w_pcFTop_32;
    end
end
assign w_pcTop_32 = r_pcFTop_32;

//---------------------------------------------------------------------------------------------------------//
/*ȡָ�������ж��쳣ģ����¼��ܹ����������ֱ���ȡָ�쳣��ȡָ�жϺ������쳣�������쳣Ŀǰֻ֧���쳣���أ�ȡָ��������뷢��ȥ�ж�
�쳣ģ����¼�o_drv2Excp_2���쳣��o_exceptionF_2_4,Ϊ�˱����������ÿ��ȥ�ж��쳣ģ����¼��󶼼���һ��cFifo
*/
//---------------------------------------------------------------------------------------------------------//  

(* dont_touch="true" *) fetch fetch_inst (
    .rst(rst),
    .o_drv2Excp_2(w_drv2Excp_2Tmp),
    .i_freeFExcp_2(w_freeFExcp_2),
    .o_exceptionF_2_4(w_exceptionF_2_4),
    .i_drvFdispatch(w_fetchSele0DriveToFetch_1), .o_free2dispatch(w_fetchSele0FreeFromFetch_1), .i_pcFdispatch_32(w_launchPC1_32),
    .i_drvFTop(w_fetchSele1DriveToFetch_1), .o_free2Top(w_fetchSele1FreeFromFetch_1), .i_pcFTop_32(w_pcTop_32),
    .i_drvFICache(w_drvFICache), .o_free2ICache(w_free2ICache), .i_inst_64(w_inst_64),
    .o_drv2ICache(w_fetchDriveToIcache_1), .i_freeFICache(w_fetchFreeFromIcache_1), .o_fetchAddr_32(w_fetchAddr_32),
    .o_drv2Dec(w_driveToDec), .i_freeFDec(w_freeFromDec), .o_instAndPC_66(w_instAndPC_66),
    .o_drv2Excp(w_iFExcdriToIntTmp), .i_freeFExcp(w_ifExcFreeFromInt), .o_exceptionF_4(w_intExcNum_4),.i_isInInt(w_isInInt),
    .o_drv2Int(w_intDriToIntTmp), .i_freeFInt(w_ifIntFreeFromInt), .o_InterruptF_6(w_intNum_6), .i_interrupt(i_IntSig)
  );
//------------------------------------change end----------------------------------------------------------//


 
  reg [63:0] r_insAndPC_64, r_insAndPC1_64;
  reg r_is16_1, r_is161_1;
  wire [63:0] w_pcAndIns_64, w_pcAndIns1_64;
  wire w_is16_1, w_is161_1;



  always @(posedge w_driveToDec or negedge rst) begin
    if (!rst) begin
        r_insAndPC1_64 <= 64'b0; 
        r_is161_1 <= 1'b0; 
    end else begin
        r_insAndPC1_64 <= {w_instAndPC_66[64:33],w_instAndPC_66[31:0]};
        r_is161_1 <= ~w_instAndPC_66[32];
    end
end



assign w_pcAndIns1_64 = r_insAndPC1_64;
assign w_is161_1 = r_is161_1;

// (* dont_touch="true" *) delay8U intDelay0(.inR(w_iFExcdriToInt), .outR(w_iFExcdriToInt1), .rst(rst)); 
// (* dont_touch="true" *) delay8U intDelay1(.inR(w_intDriToInt), .outR(w_intDriToInt1), .rst(rst));

//1/3 zwm 
//------------------------------------------------big change-----------------------------------------------//

//---------------------------------------------------------------------------------------------------------//
/*ȡָ������֮��ļ���Ĵ�������������·��ʵ�֣��������·�������������һ�֣����ȡָ�������жϻ����쳣���������ִ�ж�û���쳣��
��ô�����쳣����·���ڶ��֣���������ִ�����쳣����ô�����壻�����֣��������ֶ������ϣ����������Ľ������������·���ر���Ҫע����ǣ�
�ж������ִ����û���쳣�Ǹ����쳣���жϵģ�������w_decTrueNum_4,w_exeTrueNum_4��ǰ���ᵽ������쳣�¼���ȡָ����������������쳣��
������ȡָ��æ�������Ǹ�����������ģ���Լ������ģ���Ϊ����������쳣Ŀǰ֧�ֵ����쳣���أ����쳣���ص���һ��ָ���Ȼ���³���ĵ�һ��ָ�
��������ָ�����֮ǰ����ˮ���е�������Ϣ�����뱻��λ�����оͰ���������·���ļ����������Ա������쳣���ص�����ָ����뵽���ɸ��¼�����֮��
���߼���Ĵ������쳣��·
1/12 ����
���ڷ�����·���ļ������ĸ�λ�߼����ĳ���ֻҪ�ж��쳣ģ����ȡָ���¼�����ζ��Ҫ���µĳ���ģ�������򲻹����ж��쳣������򣬻����쳣���غ��
�������򣬶��൱�ڵ�һ��ָ�����w_decTrueNum_4����ȡָ��æ�������쳣��Ҳ�޷�
*/
//---------------------------------------------------------------------------------------------------------//  
wire [1:0] w_ifOutStackSeleFlag_2;
wire [1:0] w_exeMutexSeleFlag_2,w_decoderOutStackSeleFlag_2;
wire [35:0] w_exeToExcpData_36;
reg [1:0] r_ifOutStackSeleFlag_2;
wire w_ifDriveToMeFlag_1;
wire [5:0] w_intNewType_6;
wire w_driveToDec3;


// wire w_intCodeFlag_1;
// wire [4:0] w_intCurrentNum_5;
// contTap seleTap(
//     .trig(w_intDriToIntTmp | w_branchDri3),
//     .req(w_intCodeFlag_1),//1/13 zwm ------------->����ѡ���õ��ж�����������
//     .rst(rst)
//     );
// assign w_intCurrentNum_5 = w_intCodeFlag_1 ? w_intNum_6 : w_intNewType_5;
assign w_iFExcOrIntFlag_1 = (w_intExcNum_4 != 4'b1111 || w_intNewType_6 != 6'b000000) && ({w_decTrueNum_4,w_exeTrueNum_4}==8'hff); 
assign w_ifDriveToMeFlag_1 =  (w_decTrueNum_4!=4'b1111 || w_exeTrueNum_4 != 4'b1111);

always @(posedge w_driveToDec3 or negedge rst) begin
    if (!rst) begin
        r_ifOutStackSeleFlag_2 <= 2'b01; 
    end else begin

        if (w_ifDriveToMeFlag_1) begin
            r_ifOutStackSeleFlag_2 <= 2'b10;
        end
        else if (w_iFExcOrIntFlag_1) begin
            r_ifOutStackSeleFlag_2 <= 2'b00;
        end 
        else begin
            r_ifOutStackSeleFlag_2 <= 2'b01; 
        end

    end
end

assign w_ifOutStackSeleFlag_2 = r_ifOutStackSeleFlag_2;

(* dont_touch="true" *) delay6U outStackSeleDelay0(.inR(w_driveToDec), .outR(w_driveToDec1), .rst(rst));

(* dont_touch="true" *) delay4U outStackSeleDelay1(.inR(w_driveToDec), .outR(w_driveToDec3), .rst(rst));


//---------------------------------------------------------------------------------------------------------//
/*excfifo�����ǵ�ȡָ��������ʱ���ж��費��Ҫ��ִ�з�ȥ�ж��쳣���¼�����һ��֮����Ҫ��ִ�з��쳣�¼�������Ϊ�������ĵ�һ��ָ����ִ��֮ǰ
�Ͳ����ж��쳣�Ļ����ǲ�����뵽ִ��ģ��ģ�����ִ��Ҳ�Ͳ��ᷢ�쳣�¼��������ڵ��ж��쳣ģ�����õȵ�����ģ����ж��쳣�¼�����֮��Żᴦ����
���Ա����ִ�з��쳣�¼���fifo�����i_freeNext�ر���Ҫ��w_launchDriveToExe11��ִ���յ����ɵ��¼������ӳ�һ��ʱ���ģ����Դ�ʱ�ͱ�Ȼ
��֤��ִ��������ָ����֮����ж�Ҫ��Ҫ��ִ�з��쳣�¼���������ɵ�ִ�еļ���Ĵ����жϿ�����������ִ�еĻ���
*/
//---------------------------------------------------------------------------------------------------------//  

wire w_IfforExc_1;
wire w_bDriToIf, w_bFreeFromIf, w_driveToExeMer;
wire w_launchDriveToExe11;
(* dont_touch="true" *) cFifo1 excfifo(.i_drive(w_driveToDec1), .o_free(), 
                                          .o_driveNext(w_IfforExc_1), .i_freeNext(w_launchDriveToExe11 | w_branchDri3), .o_fire_1(),
                                          .rst(rst));
// (* dont_touch="true" *) cFifo1 excfifo(.i_drive(w_driveToDec1), .o_free(), 
//                                           .o_driveNext(w_IfforExc_1), .i_freeNext(w_launchDriveToExe11), .o_fire_1(),
//                                           .rst(rst));


wire w_ifDriToPmt, w_ifFreeFromPmt, w_pmtDriToDec, w_decfreeToPmt;
wire w_freeFromDecMer11,w_freeFromDecMer1;
(* dont_touch="true" *) cSelector3_2b outStackSele(.i_drive(w_driveToDec1), .i_data_2(w_ifOutStackSeleFlag_2), .o_free(w_freeFromDec),
    .o_driveNext0(w_ifDriToPmt), .i_freeNext0(w_ifFreeFromPmt), .o_data0_1(),
    .o_driveNext1(w_ifDriToDecMer), .i_freeNext1(w_freeFromDecMer11), .o_data1_1(),
    .o_driveNext2(w_ifDriToMe), .i_freeNext2(w_ifDriToMe), .o_data2_1(),
    .rst(rst));
//---------------------------------------------------------------------------------------------------------//
/*��������쳣��·���˺ܴ���ʱ����Ҫ��֤����ָ���ߵ�ִ�в��Ҹ��˸�λ֮����·������
*/
//---------------------------------------------------------------------------------------------------------//  
wire w_ifDriToDecMerDelay1_1,w_ifDriToDecMerDelay2_1;
// (* dont_touch="true" *)delay4U delayDriveToByPath(
//     .inR(w_ifDriToDecMer),
//     .outR(w_ifDriToDecMerDelay1_1),
//     .rst(rst)
//     );
//     (* dont_touch="true" *)delay16U delayDriveToByPath1(
//     .inR(w_ifDriToDecMerDelay1_1),
//     .outR(w_ifDriToDecMerDelay2_1),
//     .rst(rst)
//     );
    wire w_releaseFlag_1;
    wire w_launchDriveToExe_1, w_ExeFreeToLaunch_1;
    contTap releaseTap(
        .trig(w_launchDriveToExe_1 | w_ExeFreeToLaunch_1),//1/16 -------> zwm change w_driveToExeMer to w_launchDriveToExe_1
        .req(w_releaseFlag_1),
        .rst(rst)
        );
    
    (* dont_touch="true" *) cPmtFifo1 fetchToExePmtfifo(.i_drive(w_ifDriToDecMer), .o_free(w_freeFromDecMer11), .pmt(~w_releaseFlag_1),
    .o_driveNext(w_ifDriToDecMerDelay2_1), .i_freeNext(w_freeFromDecMer), .o_fire_1(),
    .rst(rst));

//-------------------------------------change end-----------------------------------------------------------------//
wire w_decoderDrive1_1, w_decoderDrive2_1;
wire [186:0] w_decoData_187;
wire w_executeDriveToLsu_1,w_exeByPathDriveToLaunch_1,w_driveToLsu,w_exeDrive2_1;
wire [162:0] w_executeDataToLsu_163;
reg r_isGo;
wire w_multiLoadOrStoreOver_1, w_multiLoadOrStoreOver2_1, w_muquitltiLoadOrStoreOver1_1;
wire w_loadEndDrive,w_loadEndDrive1;
wire w_branchDri3Delay;
(* dont_touch="true" *) delay4U goDelay1(.inR(w_decoderDrive_1), .outR(w_decoderDrive1_1), .rst(rst)); 
(* dont_touch="true" *) delay2U goDelay2(.inR(w_decoderDrive1_1), .outR(w_decoderDrive2_1), .rst(rst)); 
(* dont_touch="true" *) delay8U goDelay3(.inR(w_multiLoadOrStoreOver_1), .outR(w_muquitltiLoadOrStoreOver1_1), .rst(rst)); 
(* dont_touch="true" *) delay8U goDelay4(.inR(w_branchDri3), .outR(w_branchDri3Delay), .rst(rst)); 
(* dont_touch="true" *) delay8U goDelay5(.inR(w_loadEndDrive), .outR(w_loadEndDrive1), .rst(rst)); 
wire w_goDrive;
wire w_lsuDriveToWriteBack_1, w_multiLoadOrStoreOverData_1;


wire w_exeDrive_1, w_exeDrive1_1,w_freeToExeMer_1, w_exeReq;

contTap secondTap(
.trig(w_multiLoadOrStoreOver_1 | w_muquitltiLoadOrStoreOver1_1),
.req(w_multiLoadOrStoreOverData_1),
.rst(rst)
);


contTap firstTap(
.trig(w_loadEndDrive | w_loadEndDrive1),
.req(w_exeReq),
.rst(rst)
);


//11/8 zwm
assign w_goDrive = w_decoderDrive2_1 | w_muquitltiLoadOrStoreOver1_1 | w_loadEndDrive1;
// assign w_goDrive = w_decoderDrive2_1 | w_muquitltiLoadOrStoreOver1_1 | w_exeDrive2_1;
// always @(posedge w_goDrive or negedge rst) begin
//     if (!rst) begin
//         r_isGo = 1'b1; 
//     end else begin
// //11/7 zwm ->storeҲ����Ҫ����???????
//         if(w_multiLSEnd_1 & w_multiLoadOrStoreOverData_1 | w_exeReq & w_executeDataToLsu_163[147] & ~w_executeDataToLsu_163[141])begin
//             r_isGo = 1'b1;
//         end
//         else if(w_decoData_187[5] | w_decoData_187[57])begin
//             r_isGo = 1'b0;
//         end
//     end
// end
//1/3 zwm add a condition,if w_iFExcOrIntFlag_1 r_isGo should be 0
wire w_lsuDribeToWbMerge;
// wire w_excOrIntOver_1;
// contTap thirdTap(
// .trig(w_lsuDribeToWbMerge | w_branchDri3),
// .req(w_excOrIntOver_1),
// .rst(rst)
// );

wire w_loadEndFlag;
wire w_intIsGo_1;
wire w_pmt;
always @(posedge w_goDrive or negedge rst) begin
    if (!rst) begin
        r_isGo = 1'b1; 
    end else begin
//11/7 zwm ->storeҲ����Ҫ����???????
//11/26 zwm due to load is just w_int1_16[4],maybe a is not load but w_int1_16[4] = 1
        if(w_multiLSEnd_1 & w_multiLoadOrStoreOverData_1 | w_exeReq & w_loadEndFlag )begin
            r_isGo = 1'b1;
        end
        else if(w_decoData_187[5] | w_decoData_187[57] & w_decoData_187[53] )begin
            r_isGo = 1'b0;
        end
    end
end
assign w_pmt = ~w_intIsGo_1 & r_isGo;//1/12 zwm ---->ȡָ������֮������������Ҫ�����ж��쳣ģ��ģ���Ϊ�ж��쳣ģ��ȥȡָ���źű�Ȼ����ջ�����죬����ȵ���ջ����������ͷ�ȡָ��ָ��
(* dont_touch="true" *) cPmtFifo1 pmtfifo(.i_drive(w_ifDriToPmt), .o_free(w_ifFreeFromPmt), .pmt(w_pmt),
                                          .o_driveNext(w_pmtDriToDec), .i_freeNext(w_decfreeToPmt), .o_fire_1(),
                                          .rst(rst));
wire w_isGo;
assign w_isGo = r_isGo;


// (* dont_touch="true" *) delay4U ifDelay0(.inR(w_pmtDriToDec), .outR(w_driveToDec1), .rst(rst)); 
// (* dont_touch="true" *) delay6U ifDelay1(.inR(w_driveToDec1), .outR(w_driveToDec2), .rst(rst)); 
always @(posedge w_pmtDriToDec or negedge rst) begin
    if (!rst) begin
        r_insAndPC_64 <= 64'b0;
        r_is16_1 <= 1'b0; 
    end else begin
        r_insAndPC_64 <= w_pcAndIns1_64;
        r_is16_1 <= w_is161_1;
    end
end
assign w_pcAndIns_64 = r_insAndPC_64;
assign w_is16_1 = r_is16_1;




wire [1:0] w_wen_2;
wire [8:0] w_blImm9_9;
wire [3:0] w_nzcvWen_4;
wire [2:0] w_intAndExc_cnt;
wire [35:0] w_decExc_36;
wire w_decExcToInt,w_decFreeFromInt;
wire w_decDriveToExcMutexMerge_1,w_decFreeFromExcMutexMerge_1,w_decFreeFromExcMutexMerge1_1;
wire w_decInUseFlag_1,w_exeInUseFlag_1,w_lsuInUseFlag_1;
assign w_isInInt = (w_intAndExc_cnt >3'b000);
//11/14 zwm w_driveToDec1 -> w_pmtDriToDec
//update:w_decoData_187最高位是w_isExc_1
(* dont_touch="true" *) decoder decoder_inst (
    .i_driveFromIF(w_pmtDriToDec),.i_pcAndIns_64(w_pcAndIns_64),.o_freeToIF(w_decfreeToPmt),.i_is16_1(w_is16_1),
    .o_driveToLaunch_1(w_decoderDrive_1),.o_decoderData_187(w_decoData_187),.i_freeFromLaunch_1(w_decoSpliFreeToDeco_1),
    .o_driveToExc_1(w_decDriveToExcMutexMerge_1),.o_decPCAndNum_36(w_decExcPcAndNum_36),.i_freeFromExc_1(w_decFreeFromExcMutexMerge1_1),.o_wen_2(w_wen_2),
    .o_blImm9_9(w_blImm9_9), .i_isInInt(w_isInInt), // 2025.1.3 zlt add.i_isInInt()
    .o_nzcvWen_4(w_nzcvWen_4),
    // .o_decInUseFlag_1(w_decInUseFlag_1),
    .rst(rst)
  );

(* dont_touch="true" *) cSplitter2_1b decoSplitter(.i_drive(w_decoderDrive_1), .i_data_1(1'b0), .o_free(w_decoSpliFreeToDeco_1),
    .o_driveNext0(w_decoderDriveToLaunch_1), .i_freeNext0(w_launchFreeToDecoder_1), .o_data0_1(),
    .o_driveNext1(w_decoDrive1ToLaunch_1), .i_freeNext1(w_launchFree1ToDecoder_1), .o_data1_1(),
    .rst(rst));


wire w_launchDriveToGrf_1, w_launchFreeFromGrf, w_grfDriveToLaunch_1, w_grfFreeFromLaunch_1;
wire [7:0] w_regAddr_8, w_SRegAddr_8;
wire [63:0] w_grfDataToLaunch_64;
wire [31:0] w_prfDataToLaunch_32, w_psrDataToLaunch_32;
wire w_launchDriveToSrf_1, w_srfFreeTolaunch_1, w_prfDriveToLaunch_1, w_prfFreeFromLaunch_1;
wire w_launchDriveToPsr_1, w_PSRFreeToLaunch_1, w_psrDriveToLaunch_1, w_psrFreeFromLaunch_1;

wire [206:0] w_launchDataToExe_207;
wire [31:0] w_pc_32, w_branchPc_32;
wire [95:0] w_ExeData_96;
wire [63:0] w_lsuData_64;
wire w_LsuDriveToLunch_1, w_ExeDriveToLunch_1, w_launchFreeToLsu_1, w_launchFreeToExe_1;
wire w_exeWayToLaunch,w_exeWayFreeFromLaunch;
//---------------------------------------------------------------------------------------------------------//
/*���ɶ�����·�����������µ����⡣ֻҪ�������ж��쳣����ô������ô�����ڵ�ǰ��ˮ�߱���ˢ֮�󣬽�����ָ���Ȼ�ǵ�һ��ָ����е�
�������ǳ�ʼ������������ÿ���ж��쳣ģ����ȡָ���¼�ʱ����ζ��Ҫ�����жϷ����������쳣���صĵ�һ��ָ���ˣ���ʱ��Ҫ�����е�������ʼ��
����i_driveFExcToIf_1��i_excToIfFlag_1�������ڰѷ��ɼ�������ʼ����
*/
//---------------------------------------------------------------------------------------------------------//  
(* dont_touch="true" *) launch launch_inst (
    .i_decoderDriveToLaunch_1(w_decoderDriveToLaunch_1),.i_decoderData_185(w_decoData_187[184:0]),.o_launchFreeToDecoder_1(w_launchFreeToDecoder_1),
    .i_decoDrive1ToLaunch_1(w_decoDrive1ToLaunch_1),.i_s_1(w_decoData_187[185]),.o_launchFree1ToDecoder_1(w_launchFree1ToDecoder_1),
    .i_LsuDriveToLunch_1(w_LsuDriveToLunch_1),.i_lsuData_64(w_lsuData_64),.o_launchFreeToLsu_1(w_launchFreeToLsu_1),
    .i_ExeDriveToLunch_1(w_exeWayToLaunch),.i_ExeData_96(w_ExeData_96),.o_launchFreeToExe_1(w_exeWayFreeFromLaunch),

    .o_launchDriveToGrf_1(w_launchDriveToGrf_1), .o_regAddr_8(w_regAddr_8), .i_grfFreeTolaunch_1(w_launchFreeFromGrf),
    .i_GrfDriveToLaunch_1(w_grfDriveToLaunch_1),.i_rsData_64(w_grfDataToLaunch_64), .o_launchFreeToGrf_1(w_grfFreeFromLaunch_1),

    .o_launchDriveToSrf_1(w_launchDriveToSrf_1), .o_SRegAddr_8(w_SRegAddr_8), .i_srfFreeTolaunch_1(w_srfFreeTolaunch_1),
    .i_SrfDriveToLaunch_1(w_prfDriveToLaunch_1), .i_sRsData_32(w_prfDataToLaunch_32), .o_launchFreeToSrf_1(w_prfFreeFromLaunch_1),

    .o_launchDriveToPsr_1(w_launchDriveToPsr_1),.i_PSRFreeToLaunch_1(w_PSRFreeToLaunch_1),
    .i_PSRDriveToLaunch_1(w_psrDriveToLaunch_1),.i_psrData_32(w_psrDataToLaunch_32),.o_launchFreeToPSR_1(w_psrFreeFromLaunch_1),

    .o_launchDriveToExe_1(w_launchDriveToExe_1), .o_launchDataToExe_207(w_launchDataToExe_207), .i_ExeFreeToLaunch_1(w_ExeFreeToLaunch_1),
    .o_launchDriveToIf_1(w_launchDriveToIf_1), .o_pc_32(w_launchPC_32), .i_IfFreeToLaunch_1(w_IfFreeToLaunch_1),
    .o_bDriToIf(w_branchDri1), .o_branchPc_32(w_branchPc_32), .i_bFreeFromIf(w_branchFree1), //跳�???????1
    .i_blImm9_9(w_blImm9_9),

    //12/10 zwm need the w_wen_2 from the top
    .i_wen_2(w_wen_2),
    .rst(rst),

    .o_b_1(),

    .i_isInInt(w_isInInt),
    // .decNum_4(w_decTrueNum_4),
    // .exeNum_4(w_exeTrueNum_4),
    .i_driveFExcToIf_1(w_branchDri3),
    .i_excToIfFlag_1(w_ExcToIfFlag_1)
  );
//？？？可以提前将下一�?pc给取�?????????????????


//1/11 zwm
//---------------------------------------------------------------------------------------------------------//
/*
1/12 ����
����Ҫ�õ������־λ�ˣ���Ϊ�޷��������ʱ�������n+1��ָ�û�����룬����n��ָ���Ѿ���ִ�в�����·�������ˣ����ʱ��ִ�е���·��
��Ҫ�ģ�ֻ������n+1��ָ�û�����������
*/
//---------------------------------------------------------------------------------------------------------//  
//   wire w_launchNoEmptyFlag_1;
//   wire w_pmtDriToDec1;
//     (* dont_touch="true" *)delay2U delayPmtDriToDec(
//         .inR(w_pmtDriToDec),
//         .outR(w_pmtDriToDec1),
//         .rst(rst)
//         );
//   contTap launchNoEmptyTap(
//     .trig(w_pmtDriToDec1 | w_launchDriveToExe_1),
//     .req(w_launchNoEmptyFlag_1),
//     .rst(rst)
//     );




reg [206:0] r_launchDataToExe_207;
reg [1:0] r_wen_2;
reg [3:0] r_nzcvWen_4;
wire w_driveToExeMer1, w_branch1Dri1, w_launchDriveToIf1_1, w_branch1Dri2;

reg r_lsuGo_1;

// 10.21 modify-->zlt
(* dont_touch="true" *) delay2U launchDelay0(.inR(w_launchDriveToExe_1), .outR(w_driveToExeMer1), .rst(rst)); 
(* dont_touch="true" *) delay4U launchDelay1(.inR(w_driveToExeMer1), .outR(w_driveToExeMer), .rst(rst)); 
always @(posedge w_driveToExeMer1 or negedge rst) begin
    if (!rst) begin
        r_launchDataToExe_207 <= 207'b0; 
        r_wen_2 <= 2'b0;
        r_nzcvWen_4 <= 4'b0;
    end else begin
        r_launchDataToExe_207 <= w_launchDataToExe_207;
        r_wen_2 <= w_wen_2;
        r_nzcvWen_4 <= w_nzcvWen_4;
    end
end 

// 10.21 newADD--->zlt
(* dont_touch="true" *) delay6U launchBranchDelay0(.inR(w_branchDri1), .outR(w_branch1Dri1), .rst(rst)); 
(* dont_touch="true" *) delay6U launchBranchDelay1(.inR(w_branch1Dri1), .outR(w_launchBranchDri), .rst(rst)); 
always @(posedge w_branch1Dri1 or negedge rst) begin
    if (!rst) begin
        r_branchPc_32 <= 32'b0; 
    end else begin
        r_branchPc_32 <= w_branchPc_32; 
    end
end

assign w_branchPC1_32 = r_branchPc_32;

// 10.21 newADD--->zlt
(* dont_touch="true" *) delay2U launchPcDelay0(.inR(w_launchDriveToIf_1), .outR(w_launchDriveToIf1_1), .rst(rst)); 
(* dont_touch="true" *) delay4U launchPcDelay1(.inR(w_launchDriveToIf1_1), .outR(w_launchPcDriToIf_1), .rst(rst)); 
always @(posedge w_launchDriveToIf1_1 or negedge rst) begin
    if (!rst) begin
        r_pc_32 <= 32'b0;  
    end else begin
        r_pc_32 <= w_launchPC_32; 
    end
end


assign w_launchPC1_32 = r_pc_32;

wire w_driveToLaunchSele, w_launchDriveToExe, w_launchDriveToExeMer, w_launchDriveToMe;
wire w_launchFreeFromExe, w_launchFreeFromExeMer,w_launchFreeFromExeMer1,w_freeToLaunchMer;
wire w_exeDriveToExcMutexMerge_1,w_exeFreeFromExcMutexMerge_1,w_exeFreeFromExcMutexMerge1_1;

// 11.20-->ifree-->zlt
//1/3 zwm add a cfifo
wire w_ifDriToDecMer1;
wire w_excOrDecFlag_1;
cFifo1 launchDelayFifo1(.i_drive(w_ifDriToDecMerDelay2_1), .i_freeNext(w_driveToLaunchSele), .rst(rst),
               .o_free(w_freeFromDecMer), .o_driveNext(w_ifDriToDecMer1), .o_fire_1());

(* dont_touch="true" *) cMutexMerge2_1b launchMerge(.i_drive0(w_driveToExeMer), .i_data0_1(1'b1), .o_free0(w_ExeFreeToLaunch_1),
    .i_drive1(w_ifDriToDecMer1), .i_data1_1(1'b0), .o_free1(w_freeFromDecMer1),
    .i_freeNext(w_executeDriveToLsu_1 | w_launchFreeFromExeMer1 | w_launchDriveToMe), .o_driveNext(w_driveToLaunchSele), .o_data_1(w_excOrDecFlag_1),
    .rst(rst));

//-----------------------------------big change----------------------------------------------------//
//1/3 zwm 
    reg [1:0] r_decoderOutStackSeleFlag_2;
    
    wire w_decoderDriveToMeFlag_1;
    wire w_decExcRstFlag_1;
    wire w_exeExcRstFlag_1;
    wire w_driveToLaunchSele1;

//---------------------------------------------------------------------------------------------------------//
/*���������w_decExcRstFlag_1��w_exeExcRstFlag_1�Ǳ�־���Ƿ�ǰ�����������µ��쳣�룬��Ϊ��������쳣�ˣ���ˢ��ˮ���ˣ�����ָ��
������ʱ����Ӧ�����е��ж��쳣�붼��λ��4��b1111
*/
//---------------------------------------------------------------------------------------------------------//  
    
    contTap decTap(
    .trig(w_driveToDec | w_ifExcFreeFromInt),
    .req(w_decExcRstFlag_1),
    .rst(rst)
    ); 
    contTap exeTap(
        .trig(w_exeDriveToExcMutexMerge_1 | w_ifExcFreeFromInt),
        .req(w_exeExcRstFlag_1),
        .rst(rst)
        ); 
    
//---------------------------------------------------------------------------------------------------------//
/*�����Ƿ��ɺ�ִ��֮��ļ���Ĵ���������������ӣ���Ϊ��·ǰ�滹��һ�����⣬����·���¼��Ǵӷ��ɹ����ģ���·�����������
��һ�֣�����������쳣����ִ�����쳣����ô�����쳣��·���ڶ��֣����ִ�����쳣�Ǿ����壻����������ֶ����Ǿ�������ִ�С�
����·���¼��Ǵ���һ������Ĵ������쳣��·���ģ���·�������������һ�֣�ִ�����쳣����ô�ͼ������쳣��·���ڶ��֣�ִ�����쳣��
��ô������
*/
//---------------------------------------------------------------------------------------------------------//  
    
    assign w_decTrueNum_4 = w_decExcRstFlag_1 ? w_decExcPcAndNum_36[3:0] : 4'b1111;
    assign w_exeTrueNum_4 = w_exeExcRstFlag_1 ?  w_exeToExcpData_36[3:0] : 4'b1111;
    assign w_decoderExcFlag_1 = w_excOrDecFlag_1 ? (w_decTrueNum_4 != 4'b1111) && (w_exeTrueNum_4==4'b1111) : w_exeTrueNum_4==4'b1111;
    // assign w_decoderExcFlag_1 = (w_decTrueNum_4 != 4'b1111 || w_ifOutStackSeleFlag_2 == 2'b00) && (w_exeTrueNum_4==4'b1111);
    // assign w_decoderDriveToMeFlag_1 =w_exeTrueNum_4!=4'b1111;
    assign w_decoderDriveToMeFlag_1 = w_exeTrueNum_4!=4'b1111;
    
    always @(posedge w_driveToLaunchSele1 or negedge rst) begin
        if (!rst) begin
            r_decoderOutStackSeleFlag_2 <= 2'b01; 
        end else begin
            if (w_decoderExcFlag_1) begin
                r_decoderOutStackSeleFlag_2 <= 2'b00;
            end 
            else if (w_decoderDriveToMeFlag_1) begin
                r_decoderOutStackSeleFlag_2 <= 2'b10;
            end
            else begin
                r_decoderOutStackSeleFlag_2 <= 2'b01; 
            end
    
        end
    end
    
    assign w_decoderOutStackSeleFlag_2 = r_decoderOutStackSeleFlag_2;

    (* dont_touch="true" *) delay6U launchSeleDelay0(.inR(w_driveToLaunchSele), .outR(w_driveToLaunchSele1), .rst(rst)); 

    
(* dont_touch="true" *) cSelector3_2b launchSele(.i_drive(w_driveToLaunchSele1), .i_data_2(w_decoderOutStackSeleFlag_2), .o_free(w_freeToLaunchMer),
    .o_driveNext0(w_launchDriveToExe), .i_freeNext0(w_executeDriveToLsu_1), .o_data0_1(), // 2024.11.13-->zlt-->exedrive is launch inFree
    .o_driveNext1(w_launchDriveToExeMer), .i_freeNext1(w_launchFreeFromExeMer), .o_data1_1(),
    .o_driveNext2(w_launchDriveToMe), .i_freeNext2(w_launchDriveToMe), .o_data2_1(),
    .rst(rst));       
//------------------------------------------change end------------------------------------------------//

//1/10 zwm 
//----------------------------------------big change----------------------------------------------//
//due to excpath is so fast,this must add delay

//---------------------------------------------------------------------------------------------------------//
/*��������쳣��·���˺ܴ���ʱ����Ҫ��֤����ָ���ߵ�ִ�в��Ҹ��˸�λ֮����·������
*/
//---------------------------------------------------------------------------------------------------------//  
    wire w_launchDriveToExeMerDelay1_1,w_launchDriveToExeMerDelay2_1,w_launchDriveToExeMerDelay3_1,
    w_launchDriveToExeMerDelay4_1,w_launchDriveToExeMerDelay5_1,w_launchDriveToExeMerDelay6_1;
// (* dont_touch="true" *)delay32U delayDriveToNoLs(
//     .inR(w_launchDriveToExeMer),
//     .outR(w_launchDriveToExeMerDelay1_1),
//     .rst(rst)
//     );
    
//     (* dont_touch="true" *)delay32U delayDriveToNoLs1(
//     .inR(w_launchDriveToExeMerDelay1_1),
//     .outR(w_launchDriveToExeMerDelay2_1),
//     .rst(rst)
//     );
    
//     (* dont_touch="true" *)delay32U delayDriveToNoLs2(
//         .inR(w_launchDriveToExeMerDelay2_1),
//         .outR(w_launchDriveToExeMerDelay3_1),
//         .rst(rst)
//         );
    
//     //12/11 zwm change 16U to 64U
//     (* dont_touch="true" *)delay64U delayDriveToNoLs3(
//     .inR(w_launchDriveToExeMerDelay3_1),
//     .outR(w_launchDriveToExeMerDelay4_1),
//     .rst(rst)
//     );
    
    
//     //1/9 zwm add a 8u
//     (* dont_touch="true" *)delay32U delayDriveToNoLs4(
//         .inR(w_launchDriveToExeMerDelay4_1),
//         .outR(w_launchDriveToExeMerDelay5_1),
//         .rst(rst)
//         );

//     (* dont_touch="true" *)delay32U delayDriveToNoLs5(
//         .inR(w_launchDriveToExeMerDelay5_1),
//         .outR(w_launchDriveToExeMerDelay6_1),
//         .rst(rst)
//         );

    wire w_releaseSecondFlag_1;
    wire w_exeDriToExeMutex, w_exeMutexFreeToExe, w_driveToMe;
    contTap releaseSecondTap(
        .trig(w_exeDriToExeMutex | w_exeMutexFreeToExe),
        .req(w_releaseSecondFlag_1),
        .rst(rst)
        );
    
    (* dont_touch="true" *) cPmtFifo1 launchToLsuPmtfifo(.i_drive(w_launchDriveToExeMer), .o_free(w_launchFreeFromExeMer1), .pmt(~w_releaseSecondFlag_1),
    .o_driveNext(w_launchDriveToExeMerDelay2_1), .i_freeNext(w_launchFreeFromExeMer), .o_fire_1(),
    .rst(rst));
//-------------------------------------------------------change end---------------------------------------------------------------------//



wire w_launchDriveToExe1;
(* dont_touch="true" *) delay4U lsuGoDelay0(.inR(w_launchDriveToExe), .outR(w_launchDriveToExe1), .rst(rst)); 
    always @(posedge w_launchDriveToExe1 or negedge rst) begin
        if (!rst) begin
            r_lsuGo_1 <= 1'b1;
        end else begin
            if(r_isGo == 1'b0 ) r_lsuGo_1 <= 1'b0; // 2024.11.13--zlt-->lsuWay
            else r_lsuGo_1 <= 1'b1;
        end
    end     
wire [206:0] w_launchDataToExecute_207;
wire [1:0] w_wen1_2;
wire [3:0] w_nzcvWen1_4;
assign w_launchDataToExecute_207 = r_launchDataToExe_207;
assign w_wen1_2 = r_wen_2;
assign w_nzcvWen1_4 = r_nzcvWen_4;

wire w_exeDriveToRGrf_1, w_exeFreeFromRGrf, w_grfDriToExe_1, w_exeFreeFromGrf;
wire [7:0] w_exeToRGrfAddr_8;
wire [63:0] w_grfDataToExe_64;

wire w_exeDriveToExcp_1, w_executeFreeFromExcp_1;
wire [35:0] w_exeExcNew_36;
wire [95:0] w_exeToLaunchData_96;
wire [63:0] w_lsuToExeData_64;
wire w_LsuDriveToExe_1, w_lsuFreeFromExecute_1, w_executeFreeFromLaunchByPath_1;
wire w_executeFreeFromLsu_1;
wire w_grfFlag_1;
wire [1:0] w_wen2_2;

// 连中�?异常模块的线先简单�?��??????????????????-->zlt,2024.10.25
(* dont_touch="true" *) execute execute_inst (
    
    .i_launchDriveToExecute_1(w_launchDriveToExe),.i_wen_2(w_wen1_2), .i_launchDataToExe_207(w_launchDataToExecute_207), .o_executeFreeToLaunch_1(w_launchFreeFromExe),
    
    .o_executeDriveToGrf_1(w_exeDriveToRGrf_1), .o_executeToGrfData_8(w_exeToRGrfAddr_8), .i_executeFreeFromGrf_1(w_exeFreeFromRGrf),  //去grf
    .i_grfDriveToExecute_1(w_grfDriToExe_1), .i_grfToExecuteData_64(w_grfDataToExe_64), .o_executeFreeToGrf_1(w_exeFreeFromGrf), //grf回�???????

    .i_LsuDriveToExe_1(w_LsuDriveToExe_1), .i_lsuToExeData_64(w_lsuToExeData_64), .o_lsuFreeFromExecute_1(w_lsuFreeFromExecute_1),
    
    .o_exeDriveToExcp_1(w_exeDriveToExcMutexMerge_1), .o_exeToExcpData_36(w_exeToExcpData_36), .i_executeFreeFromExcp_1(w_exeFreeFromExcMutexMerge1_1),//exp

    .o_exeByPathDriveToLaunch_1(w_exeByPathDriveToLaunch_1), .o_exeToLaunchData_96(w_exeToLaunchData_96), .i_executeFreeFromLaunchByPath_1(w_executeFreeFromLaunchByPath_1),// launch

    .o_executeDriveToLsu_1(w_executeDriveToLsu_1), .o_executeDataToLsu_163(w_executeDataToLsu_163),.i_executeFreeFromLsu_1(w_executeFreeFromLsu_1),
    
    .rst(rst),
    .o_executeInUseFlag_1(w_exeInUseFlag_1),
    .i_launchDrive_1(w_driveToExeMer & ~w_decoderExcFlag_1 & ~w_decoderDriveToMeFlag_1),//1/11 zwm ----> not use

    .o_grfFlag_1(w_grfFlag_1), .o_wen_2(w_wen2_2)
  );                      


  (* dont_touch="true" *) delay8U IFfreeDelay1(.inR(w_launchDriveToExe), .outR(w_launchDriveToExe11), .rst(rst)); 


//11/21 zwm drive1 is to fast and get together with i_freeNext,so add cfifo
  wire w_exeByPathDriveToLaunch1_1,w_executeFreeFromLaunchByPath1_1;
  cFifo1 exeWaitMergeDelayFifo1(.i_drive(w_exeByPathDriveToLaunch_1), .i_freeNext(w_executeFreeFromLaunchByPath1_1), .rst(rst),
  .o_free(w_executeFreeFromLaunchByPath_1), .o_driveNext(w_exeByPathDriveToLaunch1_1), .o_fire_1());

(* dont_touch="true" *) cWaitMerge2_1b exeWaitMerge(.i_drive0(w_executeDriveToLsu_1), .i_data0_1(1'b0), .o_free0(w_executeFreeFromLsu_1),
    .i_drive1(w_exeByPathDriveToLaunch1_1), .i_data1_1(1'b0), .o_free1(w_executeFreeFromLaunchByPath1_1),
    .o_driveNext(w_exeDrive_1), .o_data_1(), .i_freeNext(w_freeToExeMer_1),
    .rst(rst));

reg [95:0]  r_exeToLaunchData_96;
reg [162:0] r_executeDataToLsu_163;
reg [35:0] r_exeToExcpData_36;
reg [1:0] r_wen2_2;
reg [3:0] r_nzcvWen2_4;
wire [162:0] w_exeToLsuData_163;
wire [1:0] w_wen3_2;
wire [3:0] w_nzcvWen2_4;
wire [35:0] w_exeExc_36;

// 10.21 modify-->zlt
//11/15 zwm change 6U to 8U
(* dont_touch="true" *) delay4U exeDelay0(.inR(w_exeDrive_1), .outR(w_exeDrive1_1), .rst(rst)); 
(* dont_touch="true" *) delay4U exeDelay1(.inR(w_exeDrive1_1), .outR(w_exeDrive2_1), .rst(rst)); 
//11/21 zwm change w_exeDrive1_1 to w_exeDrive_1
//11/24 zwm change w_exeDrive_1 to w_executeDriveToLsu_1
//12/5 zwm change w_executeDriveToLsu_1 to w_executeDriveToLsu1_1,and add buffer
wire w_executeDriveToLsu1_1;
wire w_fire2_1,w_fire3_1,w_fire4_1,w_fire5_1,w_fire6_1,w_fire7_1,w_fire8_1;
BUFM2HM buf0(.A(w_executeDriveToLsu_1), .Z(w_fire2_1));
BUFM2HM buf1(.A(w_fire2_1), .Z(w_fire3_1));
BUFM2HM buf2(.A(w_fire3_1), .Z(w_fire4_1));
BUFM2HM buf3(.A(w_fire4_1), .Z(w_fire5_1));
BUFM2HM buf4(.A(w_fire5_1), .Z(w_fire6_1));
BUFM2HM buf5(.A(w_fire6_1), .Z(w_fire7_1));
BUFM2HM buf6(.A(w_fire7_1), .Z(w_fire8_1));
BUFM2HM buf7(.A(w_fire8_1), .Z(w_executeDriveToLsu1_1));

always @(posedge w_executeDriveToLsu1_1 or negedge rst) begin
    if (!rst) begin
        // r_exeToLaunchData_96 <= 96'b0; 
        r_executeDataToLsu_163 <= 163'b0; 
        r_wen2_2 <= 2'b0;
        r_nzcvWen2_4 <= 4'b0;
        r_exeToExcpData_36 <= 36'b0;
    end else begin
        // r_exeToLaunchData_96 <= w_exeToLaunchData_96; 
        r_executeDataToLsu_163 <= w_executeDataToLsu_163;
        r_wen2_2 <= w_wen2_2;
        r_nzcvWen2_4 <= w_nzcvWen1_4;
        r_exeToExcpData_36 <= w_exeToExcpData_36;
    end
end
assign w_exeExc_36 = r_exeToExcpData_36;

//1/9 zwm change w_exeByPathDriveToLaunch1_1 to w_executeDriveToLsu1_1
wire w_exeByPathDriveToLaunchDelay_1;
(* dont_touch="true" *) delay8U exeToLaunhDelay(.inR(w_exeByPathDriveToLaunch_1), .outR(w_exeByPathDriveToLaunchDelay_1), .rst(rst)); 

always @(posedge w_exeByPathDriveToLaunchDelay_1 or negedge rst) begin
    if (!rst) begin
        r_exeToLaunchData_96 <= 96'b0; 
        // r_executeDataToLsu_163 <= 163'b0; 
        // r_wen2_2 <= 2'b0;
    end else begin
        r_exeToLaunchData_96 <= w_exeToLaunchData_96; 
        // r_executeDataToLsu_163 <= w_executeDataToLsu_163;
        // r_wen2_2 <= w_wen2_2;
    end
end

assign w_ExeData_96 = r_exeToLaunchData_96;
assign w_exeToLsuData_163 = r_executeDataToLsu_163;
assign w_wen3_2 = r_wen2_2;
assign w_nzcvWen2_4 = r_nzcvWen2_4;

wire w_driveToExeSele_1, w_freeFromExeSele_1,w_freeFromLsuMer;
wire w_freeFromLsu,w_driveToLsuMer;

(* dont_touch="true" *) cSplitter2_1b exeSplitter(.i_drive(w_exeDrive2_1), .i_data_1(1'b0), .o_free(w_freeToExeMer_1),
    .o_driveNext0(w_ExeDriveToLunch_1), .i_freeNext0(w_launchFreeToExe_1), .o_data0_1(),
    .o_driveNext1(w_exeDriToExeMutex), .i_freeNext1(w_exeMutexFreeToExe), .o_data1_1(),
    .rst(rst));//后续�?能�?�换一下位�?，先�?定没异常了再给旁�?????????????????


// 当暂停流水线时执行的旁路需要舍弃掉

wire w_exeWayToMe;
wire w_driveToLsuWaitMerge_1;
//1/10 zwm add a w_exeOrExcPathFlag_1 to distant from exe or ExcPath
wire w_exeOrExcPathFlag_1;
//------------------------------big change-----------------------------------------//
//---------------------------------------------------------------------------------------------------------//
/*�����ִ�з������ɵ���·����ѡ�����ȡָ�ڼ�����·��ѡ��û������������·����ôҪô������ȡָ��ָ��������쳣��Ҫ������ִ�������������쳣��
�������������Ӧ�������ɷ���·����Ϊ���ɺ��治�������µ�ָ��
*/
//---------------------------------------------------------------------------------------------------------//  
    
//1/11 zwm 
wire  w_launchWaySeleCS_1;
// assign w_launchWaySeleCS_1 = r_lsuGo_1 && (w_ifOutStackSeleFlag_2!=2'b00);
assign w_launchWaySeleCS_1 = r_lsuGo_1 && (w_ifOutStackSeleFlag_2==2'b01);//1/12 zwm ----> use this
// assign w_launchWaySeleCS_1 = r_lsuGo_1 & w_launchNoEmptyFlag_1;
(* dont_touch="true" *) cSelector2_1b launchWaySele(.i_drive(w_ExeDriveToLunch_1), .i_data_1(w_launchWaySeleCS_1), .o_free(w_launchFreeToExe_1),
    .o_driveNext0(w_exeWayToLaunch), .i_freeNext0(w_exeWayFreeFromLaunch), .o_data0_1(),
    .o_driveNext1(w_exeWayToMe), .i_freeNext1(w_exeWayToMe), .o_data1_1(),
    .rst(rst));
//--------------------------------change end--------------------------------------//

(* dont_touch="true" *) cMutexMerge2_1b exeMutexMerge(.i_drive0(w_exeDriToExeMutex), .i_data0_1(1'b1), .o_free0(w_exeMutexFreeToExe),
    .i_drive1(w_launchDriveToExeMerDelay2_1), .i_data1_1(1'b0), .o_free1(w_launchFreeFromExeMer),
    .i_freeNext(w_freeFromLsu | w_freeFromLsuMer | w_driveToMe), .o_driveNext(w_driveToExeSele_1), .o_data_1(w_exeOrExcPathFlag_1),
    .rst(rst));


//-----------------------------------big change----------------------------------//
//---------------------------------------------------------------------------------------------------------//
/*������ִ�����ô�ļ���Ĵ�������Ϊ�ô��쳣��ǰ����ִ�����жϣ����Բ�����ڷô��쳣ִ������������������·���¼�Ҳ�����֣���һ���Ǵ�
ִ��ģ��������ôֻ��Ҫ�ж�ִ����û���쳣�Ϳ��ԣ�����о����쳣��·��û�о�����ȥ���ô棻�ڶ����Ǵ���һ��������·���쳣��·����
*/
//---------------------------------------------------------------------------------------------------------//  
//1/3 zwm 
    reg [1:0] r_exeMutexSeleFlag_2;
    wire w_driveToExeSele1_1;
    assign w_exeExcFlag_1 = w_exeOrExcPathFlag_1 ? w_exeTrueNum_4 != 4'b1111 : 1'b1;
    // assign w_exeExcFlag_1 = w_exeOrExcPathFlag_1 ? w_exeTrueNum_4 != 4'b1111 : (w_exeTrueNum_4 != 4'b1111 || w_decoderOutStackSeleFlag_2 == 2'b00);
    always @(posedge w_driveToExeSele1_1 or negedge rst) begin
        if (!rst) begin
            r_exeMutexSeleFlag_2 <= 2'b01; 
        end else begin
            if (w_exeExcFlag_1) begin
                r_exeMutexSeleFlag_2 <= 2'b00;
            end
            else begin
                r_exeMutexSeleFlag_2 <= 2'b01; 
            end
    
        end
    end
    
    assign w_exeMutexSeleFlag_2 = r_exeMutexSeleFlag_2;
    (* dont_touch="true" *) delay6U exeMutexSeleDelay0(.inR(w_driveToExeSele_1), .outR(w_driveToExeSele1_1), .rst(rst)); 
(* dont_touch="true" *) cSelector3_2b exeMutexSele(.i_drive(w_driveToExeSele1_1), .i_data_2(w_exeMutexSeleFlag_2), .o_free(w_freeFromExeSele_1),
    .o_driveNext0(w_driveToLsu), .i_freeNext0(w_freeFromLsu), .o_data0_1(),
    .o_driveNext1(w_driveToLsuMer), .i_freeNext1(w_freeFromLsuMer), .o_data1_1(),
    .o_driveNext2(w_driveToMe), .i_freeNext2(w_driveToMe), .o_data2_1(),
    .rst(rst));    

//------------------------------------change end--------------------------------//
wire w_lsuDriveToRGrf_1, w_lsuFreeFromRGrf_1,w_grfDriveToLsu_1,w_grfFreeFromLsu_1;
wire [7:0] w_lsuToRGrfData_8;
wire [63:0] w_grfToLsuData_64, w_lsuToLaunchData_64;
wire [35:0] w_lsuException_36;
wire [73:0] w_lsuWGrfData_74;
wire [102:0] w_lsuToWriteBackData_103;
wire w_lsuDriveToDataRout_1;
wire [103:0] w_lsuToDataRoutData_104;
wire w_lsuDriveToExcp_1, w_lsuFreeFromExcp_1, w_lsuDriveToWGrf_1, w_lsuFreeFromWGrf_1;
wire w_lsuFreeFromWriteBack_1, w_lsuDriveToLaunch_1, w_lsuFreeFromLaunch_1;
//12/24 zwm lsu add a path to icache
wire w_lsuDriveToIcache_1,w_lsuFreeFromIcache_1;
wire [103:0] w_lsuToIcacheData_104;
wire w_icacheDriveToLsu_1,w_lsuFreeToIcache_1;
wire [63:0] w_icacheData_64;
wire w_lsuDriveToExcMutexMerge_1,w_lsuFreeFromExcMutexMerge_1,w_lsuFreeFromExcMutexMerge1_1;
wire [35:0] w_lsuExc_36;
wire w_lsuFreeFromDR_1;
wire w_dataRoutDriveToLsu_1,w_lsuFreeToDataRout_1;
wire [63:0] w_lsuDRData_64;



//12/12 zwm change {w_grfToLsuData_64[31:0],w_grfToLsuData_64[63:32]} to w_grfToLsuData_64

(* dont_touch="true" *) lsu lsu_inst (
    
    .i_exeDriveToLsu_1(w_driveToLsu), .i_wen_2(w_wen3_2), .i_exeToLsuData_163(w_exeToLsuData_163), .o_lsuFreeToExe_1(w_freeFromLsu),
    
    .i_dataRoutDriveToLsu_1(w_dataRoutDriveToLsu_1), .i_memData_64(w_lsuDRData_64), .o_lsuFreeToDataRout_1(w_lsuFreeToDataRout_1),
    .o_lsuDriveToDataRout_1(w_lsuDriveToDataRout_1), .o_lsuToDataRoutData_104(w_lsuToDataRoutData_104), .i_lsuFreeFromDataRout_1(w_lsuFreeFromDR_1), // DR

    .o_lsuDriveToRGrf_1(w_lsuDriveToRGrf_1), .o_lsuToRGrfData_8(w_lsuToRGrfData_8), .i_lsuFreeFromRGrf_1(w_lsuFreeFromRGrf_1),
    .i_grfDriveToLsu_1(w_grfDriveToLsu_1), .i_grfToLsuData_64(w_grfToLsuData_64), .o_grfFreeFromLsu_1(w_grfFreeFromLsu_1),// 读GRF
    
    .o_lsuDriveToExcp_1(w_lsuDriveToExcMutexMerge_1), .o_exception_36(w_lsuException_36), .i_lsuFreeFromExcp_1(w_lsuFreeFromExcMutexMerge1_1),                               

    .o_lsuDriveToWriteBack_1(w_lsuDriveToWriteBack_1), .o_lsuToWriteBackData_103(w_lsuToWriteBackData_103), .i_lsuFreeFromWriteBack_1(w_lsuFreeFromWriteBack_1),

    .o_lsuDriveToLaunch_1(w_lsuDriveToLaunch_1), .o_lsuToLaunchData_64(w_lsuToLaunchData_64), .i_lsuFreeFromLaunch_1(w_lsuFreeFromLaunch_1),

    .o_lsuDriveToWGrf_1(w_lsuDriveToWGrf_1), .o_wGrfData_74(w_lsuWGrfData_74), .i_lsuFreeFromWGrf_1(w_lsuFreeFromWGrf_1), // 写GRF

    .o_endFlag_1(w_multiLSEnd_1), // 11.7-->w_endFlag_1 always is 1;
    .rst(rst), // 11/7 need endFlag drive -->zlt-->undo
    .o_multiLoadOrStoreOver(w_multiLoadOrStoreOver_1), //11/8 zwm->endFlag drive->do
    .o_loadEndDrive(w_loadEndDrive), .o_loadEndFlag(w_loadEndFlag),
    .o_lsuInUseFlag_1(w_lsuInUseFlag_1),
    //12/24 zwm add a path to icache
    .o_lsuDriveToIcache_1(w_lsuDriveToIcache_1),
    .i_lsuFreeFromIcache_1(w_lsuFreeFromIcache_1),
    .o_lsuToIcacheData_104(w_lsuToIcacheData_104),
    .i_icacheDriveToLsu_1(w_icacheDriveToLsu_1),
    .i_icacheData_64(w_icacheData_64),
    .o_lsuFreeToIcache_1(w_lsuFreeToIcache_1)
  );

//-----------------------------------------------big change-----------------------------------------------//
//12/24 zwm add a arbitMerge
  wire w_lsuDriveToIcacheDelay_1,w_fetchDriveToIcacheDelay_1;
  (* dont_touch="true" *) delay4U lsuToIcacheDelay(.inR(w_lsuDriveToIcache_1), .outR(w_lsuDriveToIcacheDelay_1), .rst(rst));
  (* dont_touch="true" *) delay4U fetchToIcacheDelay(.inR(w_fetchDriveToIcache_1), .outR(w_fetchDriveToIcacheDelay_1), .rst(rst));
  cArbMerge2_105b_cpu icachecArbMerge(
    .i_drive_2({w_fetchDriveToIcacheDelay_1,w_lsuDriveToIcacheDelay_1}),
    .i_data0({w_lsuToIcacheData_104[103:72],1'b1,w_lsuToIcacheData_104[71:0]}),
    .i_data1({w_fetchAddr_32,1'b0,{64{1'b0}},{8{1'b0}}}),
    .i_freeNext(i_freeFICache),
    .rst(rst),

    .o_free_2({w_fetchFreeFromIcache_1,w_lsuFreeFromIcache_1}),
    .o_driveNext(o_drv2ICache),
    .o_data(o_cpuToIcache_105)
  );
  cSelector2_65b_cpu icacheSelector(
    .i_drive(i_drvFICache), .i_data_65(i_inst_65), .o_free(o_free2ICache),
    .o_driveNext0(w_drvFICache), .i_freeNext0(w_free2ICache), .o_data0_64(w_inst_64),
    .o_driveNext1(w_icacheDriveToLsu_1), .o_data1_64(w_icacheData_64), .i_freeNext1(w_lsuFreeToIcache_1),
    .rst(rst)
  );
//-----------------------------------------------change end-----------------------------------------------//

//11/11 zwm lsu to datarout drive need delay,and data need lock
  wire w_lsuDriveToDataRoutDelay1_1,w_lsuDriveToDataRoutDelay2_1;
  wire w_lsuDriveToDR_1;
  reg [103:0] r_lsuToDataRoutData_104;
  wire [103:0] w_lsuToDR_104;
(* dont_touch="true" *) delay16U lsuToDataRoutDelay0(.inR(w_lsuDriveToDataRout_1), .outR(w_lsuDriveToDataRoutDelay1_1), .rst(rst)); 
always @(posedge w_lsuDriveToDataRoutDelay1_1 or negedge rst) begin
    if(!rst)begin
        r_lsuToDataRoutData_104 <= 104'b0;
    end else begin
        r_lsuToDataRoutData_104 <= w_lsuToDataRoutData_104;
    end
end
assign w_lsuToDR_104 = r_lsuToDataRoutData_104;
wire w_lsuDriveToLaunch1_1;
wire w_lsuDriveToLaunch2_1;
reg [63:0] r_lsuToLaunchData_64;
reg r_multiLSEnd_1;
wire w_lsuSplitterDriveToExeSele0_1,w_exeSele0FreeToLsuSplitter_1, w_LsuDriveToLunch1_1, w_launchFreeToLsu1_1;

//11/9 zwm lsu to launch data slower than lsu to launch drive,so need delay
(* dont_touch="true" *) delay16U lsuDelay1(.inR(w_lsuDriveToLaunch_1), .outR(w_lsuDriveToLaunch2_1), .rst(rst)); 
always @(posedge w_lsuDriveToLaunch2_1 or negedge rst) begin
    if (!rst) begin
        r_lsuToLaunchData_64 <= 64'b0; 
    end else begin
        r_lsuToLaunchData_64 <= w_lsuToLaunchData_64; 
    end
end


(* dont_touch="true" *) delay4U lsuDelay0(.inR(w_lsuDriveToLaunch2_1), .outR(w_lsuDriveToLaunch1_1), .rst(rst)); 

(* dont_touch="true" *) cSplitter2_1b lsuSplitter(.i_drive(w_lsuDriveToLaunch1_1), .i_data_1(1'b0), .o_free(w_lsuFreeFromLaunch_1),
    .o_driveNext0(w_LsuDriveToLunch1_1), .i_freeNext0(w_launchFreeToLsu1_1), .o_data0_1(),
    .o_driveNext1(w_lsuSplitterDriveToExeSele0_1), .i_freeNext1(w_exeSele0FreeToLsuSplitter_1), .o_data1_1(),
    .rst(rst));

wire w_lsuByWayToMe;


    // 2024.11.11 zlt-->
//1/11 zwm 
wire  w_lsuByWaySele0CS_1;
// assign w_lsuByWaySele0CS_1 = r_lsuGo_1 && (w_ifOutStackSeleFlag_2==2'b01);
// assign w_lsuByWaySele0CS_1 = r_lsuGo_1 & w_launchNoEmptyFlag_1;
assign w_lsuByWaySele0CS_1 = r_lsuGo_1 && w_decoderOutStackSeleFlag_2==2'b01 && w_ifOutStackSeleFlag_2==2'b01;//1/12 zwm ---->use this
      (* dont_touch="true" *) cSelector2_1b lsuByWaySele0(.i_drive(w_LsuDriveToLunch1_1), .i_data_1(w_lsuByWaySele0CS_1), .o_free(w_launchFreeToLsu1_1),
  .o_driveNext0(w_LsuDriveToLunch_1), .i_freeNext0(w_launchFreeToLsu_1), .o_data0_1(),
  .o_driveNext1(w_lsuByWayToMe), .i_freeNext1(w_lsuByWayToMe), .o_data1_1(),
  .rst(rst)); // exe 


// 11/6 zwm ->����һ����·�����ж�ִ���Ƿ���Ҫ�ô���???????

// 11/6 zlt -->add a waitMerge for wait launch --> Unresolved
// wire w_drivrToexeSele0;
// (* dont_touch="true" *) cWaitMerge2_1b lsuLunchWaitMerge(.i_drive0(w_launchDriveToExe), .i_data0_1(1'b0), .o_free0(),
//     .i_drive1(w_lsuSplitterDriveToExeSele0_1), .i_data1_1(1'b0), .o_free1(),
//     .o_driveNext(w_drivrToexeSele0), .o_data_1(), .i_freeNext(w_exeSele0FreeToLsuSplitter_1),
//     .rst(rst));

wire w_rele0driveToMe_1,w_rele0driveToMe1_1;
  (* dont_touch="true" *) cSelector2_1b exeSele0(.i_drive(w_lsuSplitterDriveToExeSele0_1), .i_data_1(w_grfFlag_1), .o_free(w_exeSele0FreeToLsuSplitter_1),
  .o_driveNext0(w_LsuDriveToExe_1), .i_freeNext0(w_lsuFreeFromExecute_1), .o_data0_1(),
  .o_driveNext1(w_rele0driveToMe_1), .i_freeNext1(w_rele0driveToMe1_1), .o_data1_1(),
  .rst(rst)); // exe     // ������һ��û��ִ�е���·
delay2U isOneSeleDelay0(.inR(w_rele0driveToMe_1), .outR(w_rele0driveToMe1_1), .rst(rst));  



assign w_lsuToExeData_64 = r_lsuToLaunchData_64;
assign w_lsuData_64 = r_lsuToLaunchData_64;

wire w_lsuDriveToSele, w_freeFromLsuSele;
wire w_lsuDriveToMe, w_lsuDriveToWb, w_freeFromWb;
wire w_freeFromWbMerge;
//update:
(* dont_touch="true" *) cMutexMerge2_1b lsuMutexMerge(.i_drive0(w_lsuDriveToWriteBack_1), .i_data0_1(1'b0), .o_free0(w_lsuFreeFromWriteBack_1),
    .i_drive1(w_driveToLsuMer), .i_data1_1(1'b0), .o_free1(w_freeFromLsuMer),
    .i_freeNext(w_freeFromLsuSele), .o_driveNext(w_lsuDriveToSele), .o_data_1(),
    .rst(rst));




//-------------------------------------------big change------------------------------------//
wire [1:0] w_lsuMutexSeleFlag_2;
// assign w_lsuMutexSeleFlag_2 = (w_exeMutexSeleFlag_2 == 2'b00) ? 2'b00 : 2'b01;
assign w_lsuMutexSeleFlag_2 = (w_exeMutexSeleFlag_2 == 2'b00) ? 2'b00 : 2'b01;
(* dont_touch="true" *) cSelector3_2b lsuMutexSele(.i_drive(w_lsuDriveToSele), .i_data_2(w_lsuMutexSeleFlag_2), .o_free(w_freeFromLsuSele),
    .o_driveNext0(w_lsuDriveToWb), .i_freeNext0(w_freeFromWb), .o_data0_1(),
    .o_driveNext1(w_lsuDribeToWbMerge), .i_freeNext1(w_freeFromWbMerge), .o_data1_1(),
    .o_driveNext2(w_lsuDriveToMe), .i_freeNext2(w_lsuDriveToMe), .o_data2_1(),
    .rst(rst));   
//------------------------------------------change end--------------------------------------//
wire w_lsuDriveToWb1, w_lsuDriveToWb2;
reg [3:0] r_nzcvWen3_4;
reg [102:0] r_lsuToWBData_103;

always @(posedge w_lsuDriveToWb2 or negedge rst) begin
    if (!rst) begin
        r_lsuToWBData_103 <= 64'b0;
        r_nzcvWen3_4 <= 4'b0; 
    end else begin
        r_lsuToWBData_103 <= w_lsuToWriteBackData_103;
        r_nzcvWen3_4 <= w_nzcvWen2_4; 
    end
end
wire [102:0] w_wbData_103;
assign w_wbData_103 = r_lsuToWBData_103;
assign w_wben_4 = r_nzcvWen3_4;

// 11/13 zwm 8U is too late,change 3U
//12/12 zwm change 3U to 6U
(* dont_touch="true" *) delay6U lsuToWbDelay0(.inR(w_lsuDriveToWb), .outR(w_lsuDriveToWb2), .rst(rst)); 
(* dont_touch="true" *) delay2U lsuToWbDelay1(.inR(w_lsuDriveToWb2), .outR(w_lsuDriveToWb1), .rst(rst)); 


wire w_wbDriToRGrf, w_wbFreeFromRGrf, w_grfDriveToWb_1, w_grfFreeFromWb_1;
wire [7:0] w_lsuRegAddr_8;
wire [3:0] w_nzcv_4;
wire [31:0] w_wbPc_32;
wire [63:0] w_grfDataToWb_64;
wire [39:0] w_prfData_40;
wire [73:0] w_grfData_74;
wire w_psrDriveFromWB_1, w_psrFreeToWB_1, w_prfDriveFromWB_1, w_prfFreeToWB_1;
wire w_wbDriToIf_1, w_wbFreeFromIf, w_grfDriveFromWB_1, w_grfFreeToWB_1;


(* dont_touch="true" *) wb wb_inst (
    .i_lsuDriveToWB(w_lsuDriveToWb1), .i_data_103(w_wbData_103), .o_free(w_freeFromWb),

    .i_driveMutexMerge2(w_grfDriveToWb_1), .i_dataFromGRF_64({w_grfDataToWb_64}), .o_WBfreeGRF(w_grfFreeFromWb_1),
    
    .o_wbDriveReadGRF(w_wbDriToRGrf), .o_WBdataToGRF_8(w_lsuRegAddr_8), .i_wbFreeFromReadGRF(w_wbFreeFromRGrf),
    
    .o_drive_prf(w_prfDriveFromWB_1), .o_prfData_40(w_prfData_40), .i_wbFreeFROMPrf(w_prfFreeToWB_1),
    .o_drive_pc(w_branchDri2), .o_pcData_32(w_branchPC2_32), .i_wbFreeFromIF(w_branchFree2), // 跳�???????2
    
    .o_drive_grf(w_grfDriveFromWB_1), .o_grfData_74(w_grfData_74), .i_wbFreeFromGRF(w_grfFreeToWB_1), // 写GRF
    
    .o_drive_xpsr(w_psrDriveFromWB_1), .o_xpsrData_4(w_nzcv_4), .i_wbFreeFromXpsr(w_psrFreeToWB_1), 

    .rst(rst)
  );// wb需要修�?????????????????

// (* dont_touch="true" *) cMutexMerge2_1b wbMutexMerge(.i_drive0(), .i_data0_1(), .o_free0(),
//     .i_drive1(), .i_data1_1(), .o_free1(),
//     .i_freeNext(), .o_driveNext(w_lsuDriveToSele), .o_data_1(),
//     .rst(rst));


wire w_freeFromRGRF_1, w_driveToRGRF_1, w_driveFromRPSR_1, w_freeToRPSR_1;
wire w_driveFromRGRF_1, w_freeToRGRF_1, w_driveToRPSR_1, w_freeFromRPSR_1;
wire [191:0] w_grfData_192;
wire [31:0] w_psrDataToExp_32, w_dataToWPSR_32;
wire [71:0] w_dataToWGRF_72;
wire w_driveToWGRF_1, w_freeFromWGRF_1, w_driveToWPSR_1, w_freeFromWPSR_1;
wire w_intDriveToDR,w_intFreeFromDR;
wire w_intDriveFromDR,w_intFreeToDR;
wire [103:0] w_intData_104;
wire [63:0] w_intDRData_64;


// 后续需要修改进�?�?异常的�??????? -->zlt 2024.10.25
(* dont_touch="true" *) intAndExc intAndExc_inst (
    .i_intDriveFromIF(w_intDriToInt),.i_intPCAndIntNum_38(w_ifIntTmp_38),.o_intFreeToIF(w_ifIntFreeFromInt),
    .i_excDriveFromIF(w_iFExcdriToInt),.i_ifPCAndNum_36(w_ifExc_36),.o_excFreeToIf(w_ifExcFreeFromInt),
    .i_excDriveFromDec(w_drv2Excp_2),.i_decPCAndNum_36(w_ifHelpDecExc_36),.o_excFreeToDec(w_freeFExcp_2),
    .i_excDriveFromExe(w_exeDriveToExcp_1),.i_exePCAndNum_36(w_exeExcNew_36),.o_excFreeToExe(w_executeFreeFromExcp_1),
    .i_excDriveFromLsu(w_lsuDriveToExcp_1),.i_lsuPCAndNum_36(w_lsuExc_36),.o_excFreeToLsu(w_lsuFreeFromExcp_1),
    .o_driveToRGRF_1(w_driveToRGRF_1),.i_freeFromRGRF_1(w_freeFromRGRF_1),
    .i_driveFromRGRF_1(w_driveFromRGRF_1),.i_grfData_192(w_grfData_192),.o_freeToRGRF_1(w_freeToRGRF_1),
    .o_driveToRPSR_1(w_driveToRPSR_1),.i_freeFromRPSR_1(w_freeFromRPSR_1),
    .i_driveFromRPSR_1(w_driveFromRPSR_1),.i_psrData_32(w_psrDataToExp_32),.o_freeToRPSR_1(w_freeToRPSR_1),
    .o_DriveToIf_1(w_branchDri3),.o_intPC_32(w_branchPC3_32),.i_freeFromIf_1(w_branchFree3), // 跳�???????3
    .i_driveFromWB(w_lsuDribeToWbMerge),.o_freeToWB(w_freeFromWbMerge),
    .o_driveToDataRoute_1(w_intDriveToDR),.o_dataRouteData_104(w_intData_104),.i_freeFromDataRoute_1(w_intFreeFromDR),
   .i_driveFromDR_1(w_intDriveFromDR),.i_DRdata_64(w_intDRData_64),.o_freeToDR_1(w_intFreeToDR),
    .o_driveToWGRF_1(w_driveToWGRF_1),.o_dataToWGRF_72(w_dataToWGRF_72),.i_freeFromWGRF_1(w_freeFromWGRF_1),
    .o_driveToWPSR_1(w_driveToWPSR_1),.o_dataToWPSR_32(w_dataToWPSR_32),.i_freeFromWPSR_1(w_freeFromWPSR_1),
    .o_intAndExc_cnt(w_intAndExc_cnt),
    .o_intIsGo_1(w_intIsGo_1),

    .o_intNewType_6(w_intNewType_6),
    .rst(rst)
  );

//----------------------------------------big change-----------------------------------------//
//1/8 zwm add a mutex because datarout drive may come from lsu or int
  cMutexMerge2_105b_cpu DRMutexMerge(
    .i_drive0(w_intDriveToDR), .i_data0_105({w_intData_104[31:0],1'b0,w_intData_104[95:32],w_intData_104[103:96]}), .o_free0(w_intFreeFromDR),
    .i_drive1(w_lsuDriveToDataRoutDelay1_1), .i_data1_105({w_lsuToDR_104[103:72],1'b1,w_lsuToDR_104[71:0]}), .o_free1(w_lsuFreeFromDR_1),
    .i_freeNext(i_lsuFreeFromDataRout_1), .o_driveNext(w_lsuDriveToDR_1), .o_data_105(o_lsuToDataRoutData_105),
    .rst(rst)
  ); 
(* dont_touch="true" *) delay8U lsuToDataRoutDelay1(.inR(w_lsuDriveToDR_1), .outR(o_lsuDriveToDataRout_1), .rst(rst));
  cSelector2_65b_cpu DRSelector(
    .i_drive(i_dataRoutDriveToLsu_1), .i_data_65(i_memData_65), .o_free(o_lsuFreeToDataRout_1),
    .o_driveNext0(w_intDriveFromDR), .i_freeNext0(w_intFreeToDR), .o_data0_64(w_intDRData_64),
    .o_driveNext1(w_dataRoutDriveToLsu_1), .o_data1_64(w_lsuDRData_64), .i_freeNext1(w_lsuFreeToDataRout_1),
    .rst(rst)
  );
  //-------------------------------------------change end-------------------------------------//

  // write GRF only need one port --> zlt  -->need arbtMerge 


  //11/11 zwm lsu to read grf drive need delay
  wire w_lsuDriveToRGrfDelay_1;
(* dont_touch="true" *) delay8U lsuToRGrfDelay0(.inR(w_lsuDriveToRGrf_1), .outR(w_lsuDriveToRGrfDelay_1), .rst(rst)); 

(* dont_touch="true" *) grf grf_inst (
    .rst(rst),
    .i_grfDriveFromLaunch_1(w_launchDriveToGrf_1), .i_rsAddr_8(w_regAddr_8), .o_grfFreeToLaunch_1(w_launchFreeFromGrf),
    .o_grfDriveToLaunch_1(w_grfDriveToLaunch_1), .o_grfDataToLaunch_64(w_grfDataToLaunch_64), .i_grfFreeFromLaunch_1(w_grfFreeFromLaunch_1), //launch 读grf
    
    .i_driveFromExe_1(w_exeDriveToRGrf_1), .i_rs2Addr_8(w_exeToRGrfAddr_8), .o_grfFreeToExe_1(w_exeFreeFromRGrf),
    .o_grfDriveToExe_1(w_grfDriToExe_1), .o_grfDataToExe_64(w_grfDataToExe_64), .i_grfFreeFromExe_1(w_exeFreeFromGrf), // exe 读grf
    
    .i_driveFromLsu_1(w_lsuDriveToRGrfDelay_1), .i_rs3Addr_8(w_lsuToRGrfData_8), .o_grfFreeToLsu_1(w_lsuFreeFromRGrf_1),
    .o_grfDriveToLsu_1(w_grfDriveToLsu_1), .o_grfDataToLsu_64(w_grfToLsuData_64), .i_grfFreeFromLsu_1(w_grfFreeFromLsu_1), // lsu 读grf

    .i_grfwDriveFromLsu_1(w_lsuDriveToWGrf_1), .i_lsuAddr_8(w_lsuWGrfData_74[73:66]), .i_lsuDataToGrf_64(w_lsuWGrfData_74[65:2]), .i_lsuWen_2(w_lsuWGrfData_74[1:0]), 
    .o_grfwFreeToLsu_1(w_lsuFreeFromWGrf_1), // LSU写GRF

    .i_driveFromWb_1(w_wbDriToRGrf), .i_rs4Addr_8(w_lsuRegAddr_8[7:0]), .o_grfFreeToWb_1(w_wbFreeFromRGrf),
    .o_grfDriveToWb_1(w_grfDriveToWb_1), .o_grfDataToWb_64(w_grfDataToWb_64), .i_grfFreeFromWb_1(w_grfFreeFromWb_1), //WB�???????????
    
    .i_grfwDriveFromWB_1(w_grfDriveFromWB_1), .i_wbAddr_8(w_grfData_74[73:66]), .i_wbDataToGrf_64(w_grfData_74[65:2]), .i_wbWen_2(w_grfData_74[1:0]),
    .o_grfwFreeToWB_1(w_grfFreeToWB_1), //WB�??????????
    
    .i_driveFromExp_1(w_driveToRGRF_1), .o_grfFreeToExp_1(w_freeFromRGRF_1),
    .o_grfDriveToExp_1(w_driveFromRGRF_1), .o_grfDataToExp_192(w_grfData_192), .i_grfFreeFromExp_1(w_freeToRGRF_1), //exp�???????????
    
    .i_grfwDriveFromExp_1(w_driveToWGRF_1), .i_expAddr_8(w_dataToWGRF_72[71:64]), .i_expDataToGrf_64(w_dataToWGRF_72[63:0]), .i_expWen_2(2'b11),
    .o_grfwFreeToExp_1(w_freeFromWGRF_1) //exp�??????????
  );

// wire PSR onlu need one port --> zlt -->need arbtMerge
(* dont_touch="true" *) prf prf_inst (
    .rst(rst),
    .i_psrDriveFromLaunch_1(w_launchDriveToPsr_1), .o_psrFreeToLaunch_1(w_PSRFreeToLaunch_1),
    .o_psrDriveToLaunch_1(w_psrDriveToLaunch_1), .o_psrDataToLaunch_32(w_psrDataToLaunch_32), .i_psrFreeFromLaunch_1(w_psrFreeFromLaunch_1), //launch读psr
    
    .i_prfDriveFromLaunch_1(w_launchDriveToSrf_1), .i_rsAddr_8(w_SRegAddr_8), .o_prfFreeToLaunch_1(w_srfFreeTolaunch_1),
    .o_prfDriveToLaunch_1(w_prfDriveToLaunch_1), .o_prfDataToLaunch_32(w_prfDataToLaunch_32), .i_prfFreeFromLaunch_1(w_prfFreeFromLaunch_1), //launch读prf
    
    .i_psrDriveFromExp_1(w_driveToRPSR_1), .o_psrFreeToExp_1(w_freeFromRPSR_1),
    .o_psrDriveToExp_1(w_driveFromRPSR_1), .o_psrDataToExp_32(w_psrDataToExp_32), .i_psrFreeFromExp_1(w_freeToRPSR_1), // exp读psr
    
    .i_prfDriveFromWB_1(w_prfDriveFromWB_1), .i_rdAddr_8(w_prfData_40[39:32]), .i_rdDataToPrf_32(w_prfData_40[31:0]), .o_prfFreeToWB_1(w_prfFreeToWB_1),//wb写prf
    .i_psrDriveFromWB_1(w_psrDriveFromWB_1), .i_wbnzcv_4(w_nzcv_4), .o_psrFreeToWB_1(w_psrFreeToWB_1), .i_wben_4(w_wben_4),//wb写psr
    
    .i_psrwDriveFromExp_1(w_driveToWPSR_1), .o_psrwFreeToExp_1(w_freeFromWPSR_1), .i_expnzcv_4(w_dataToWPSR_32[31:28]),.i_expen_4(4'b1111) // exp写psr
    
  );



// �ź�Դ�滻��by xyp���޶���2025/1/2
/**************************************/
// ����ȡֵ���¼�
  wire w_driveFromIf_xyp;
  wire w_freeToIf_xyp;
  
  wire w_dirveToDecSelector_xyp, w_dirveToExeSelector_xyp, w_dirveToLsuSelector_xyp;
  wire w_freeFromDecSelector_xyp, w_freeFromExeSelector_xyp, w_freeFromLsuSelector_xyp;
  
  wire w_decReq_xyp, w_exeReq_xyp, w_lsuReq_xyp;
  
  wire w_driveToDecMutexMerge_xyp, w_driveToExeMutexMerge_xyp, w_driveToLsuMutexMerge_xyp;
  wire w_freeFromDecMutexMerge_xyp, w_freeFromExeMutexMerge_xyp, w_freeFromLsuMutexMerge_xyp;
  
  // �Ը�???????
  wire w_driveToFreeDec0_xyp, w_driveToFreeExe0_xyp, w_driveToFreeLsu0_xyp;
  wire w_driveToFreeDec1_xyp, w_driveToFreeExe1_xyp, w_driveToFreeLsu1_xyp;
  
  wire w_driveToDecMM_xyp, w_driveToExeMM_xyp, w_driveToLsuMM_xyp;
  wire w_freeFromDecMM_xyp, w_freeFromExeMM_xyp, w_freeFromLsuMM_xyp;


  wire w_decMutexDriveToFifo_1,w_decMutexFreeFromFifo_1;
  wire w_exeMutexDriveToFifo_1,w_exeMutexFreeFromFifo_1;
  wire w_lsuMutexDriveToFifo_1,w_lsuMutexFreeFromFifo_1;
  wire [35:0] w_decTmp_36,w_exeTmp_36,w_lsuTmp_36;

  
  // ȥ���ж��쳣����???????
  // wire w_driveDecToInt_xyp, w_driveExeToInt_xyp, w_driveLsuToInt_xyp;
  // wire w_freeIntToDec_xyp, w_freeIntToExe_xyp, w_freeIntToLsu_xyp;
  // wire [35:0] w_decExcNew_36, w_exeExcNew_36, w_lsuExcNew_36;
  
reg r_exeExc_1;
wire w_exeExc_1;
  // �¼�����
  //need a contap 
// always @(r_isGo) begin
//     if(!rst) r_exeExc_1 <= 1'b0;
//     else r_exeExc_1<=~r_exeExc_1;
// end
// assign w_exeExc_1 = r_exeExc_1;
//   assign w_decReq_xyp = ~w_decInUseFlag_1;
  assign w_exeReq_xyp = ~w_exeInUseFlag_1;
  assign w_lsuReq_xyp = ~w_lsuInUseFlag_1;
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cSplitter3_NoData_xyp  u_cSplitter3_NoData_xyp (
      .i_drive                 ( w_IfforExc_1 ),
      .i_freeNext0             ( w_freeFromDecSelector_xyp    ),
      .i_freeNext1             ( w_freeFromExeSelector_xyp    ),
      .i_freeNext2             ( w_freeFromLsuSelector_xyp    ),
      .rst                     ( rst                          ),
  
      .o_free                  ( w_freeToIf_xyp               ),
      .o_driveNext0            ( w_dirveToDecSelector_xyp     ),
      .o_driveNext1            ( w_dirveToExeSelector_xyp     ),
      .o_driveNext2            ( w_dirveToLsuSelector_xyp     )
  );
  (* dont_touch="true" *)delay6U SplitterDelay (.inR(w_dirveToDecSelector_xyp), .outR(w_freeFromDecSelector_xyp), .rst(rst));
  

  //ifExcMutex
    // �¼�����
//   wire w_a_1,w_b_1;
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_36b_xyp  ifExcMutex (
//       .i_drive0                ( w_ifDrv2IfExcMutex      ),                 // ����decģ��
//       .i_drive1                ( w_multiLoadOrStoreOver_1 | w_loadEndDrive),
//       .i_data0_36              ( w_ifExcTmp_36             ),
//       .i_data1_36              ( 36'hf_ffff_ffff                 ),
//       .i_freeNext              ( w_ifExcFreeFromInt    	       ),
//       .rst                     ( rst                   		   ),
  
//       .o_free0                 ( w_ifFreeFIfExcMutex       ),
//       .o_free1                 ( w_b_1     ),
//       .o_driveNext             ( w_iFExcdriToInt   		   ),
//       .o_data_36               ( w_ifExc_36                  )
//   );

//   //ifIntMutex
//     // �¼�����
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_37b_xyp  ifIntMutex (
//       .i_drive0                ( w_ifDrv2IfIntMutex      ),                 // ����decģ��
//       .i_drive1                ( w_multiLoadOrStoreOver_1 | w_loadEndDrive),
//       .i_data0_37              ( w_ifIntTmp_38             ),
//       .i_data1_37              ( 37'h1f_ffff_ffe0                 ),
//       .i_freeNext              ( w_ifIntFreeFromInt    	       ),
//       .rst                     ( rst                   		   ),
  
//       .o_free0                 ( w_ifFreeFIfIntMutex       ),
//       .o_free1                 ( w_a_1     ),
//       .o_driveNext             ( w_intDriToInt   		   ),
//       .o_data_37               ( w_ifInt_37                  )
//   );

//   // �¼���· Dec
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cSelector2_1b_xyp  u0_cSelector2_1b_xyp (
//       .i_drive                 ( w_dirveToDecSelector_xyp        ),
//       .i_freeNext0             ( w_freeFromDecMutexMerge_xyp     ),
//       .i_freeNext1             ( w_driveToFreeDec1_xyp           ),
//       .rst                     ( rst                             ),
//       .i_data                  ( w_decReq_xyp                    ), // 1��w_driveToDecMutexMerge_xyp
  
//       .o_free                  ( w_freeFromDecSelector_xyp       ),
//       .o_driveNext0            ( w_driveToDecMutexMerge_xyp      ),
//       .o_driveNext1            ( w_driveToFreeDec0_xyp           )
//   );
//   (* dont_touch="true" *)delay1Unit outdelay0_xyp (.inR(w_driveToFreeDec0_xyp), .outR(w_driveToFreeDec1_xyp), .rst(rst));
  
//   // �¼�����
//   wire w_decDriveToExcMutexMerge1_1;
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_36b_xyp  u0_cMutexMerge2_36b_xyp (
//       .i_drive0                ( w_decDriveToExcMutexMerge1_1      ),                 // ����decģ��
//       .i_drive1                ( w_driveToDecMutexMerge_xyp      ),
//       .i_data0_36              ( w_decTmp_36             ),
//       .i_data1_36              ( 36'hf_ffff_ffff                 ),
//       .i_freeNext              ( w_decFreeFromInt    	       ),
//       .rst                     ( rst                   		   ),
  
//       .o_free0                 ( w_decFreeFromExcMutexMerge1_1       ),
//       .o_free1                 ( w_freeFromDecMutexMerge_xyp     ),
//       .o_driveNext             ( w_decExcToInt   		   ),
//       .o_data_36               ( w_decExc_36                  )
//   );
  
  // �¼���· Exe
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cSelector2_1b_xyp  u1_cSelector2_1b_xyp (
      .i_drive                 ( w_dirveToExeSelector_xyp        ),
      .i_freeNext0             ( w_freeFromExeMutexMerge_xyp     ),
      .i_freeNext1             ( w_driveToFreeExe1_xyp           ),
      .rst                     ( rst                             ),
      .i_data                  ( w_exeReq_xyp                    ), // 1��w_driveToExeMutexMerge_xyp
  
      .o_free                  ( w_freeFromExeSelector_xyp       ),
      .o_driveNext0            ( w_driveToExeMutexMerge_xyp      ),
      .o_driveNext1            ( w_driveToFreeExe0_xyp           )
  );
  (* dont_touch="true" *)delay1Unit outdelay1_xyp (.inR(w_driveToFreeExe0_xyp), .outR(w_driveToFreeExe1_xyp), .rst(rst));
  
  // �¼�����
  wire w_exeDriveToExcMutexMerge1_1;
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cMutexMerge2_36b_xyp  u1_cMutexMerge2_36b_xyp (
      .i_drive0                ( w_exeDriveToExcMutexMerge_1      ),                  // ����exeģ��        
      .i_drive1                ( w_driveToExeMutexMerge_xyp      ),
      .i_freeNext              ( w_executeFreeFromExcp_1    	       ),
      .i_data0_36              ( w_exeToExcpData_36              ),
      .i_data1_36              ( 36'hf_ffff_ffff                 ),
      .rst                     ( rst                             ),
  
      .o_free0                 ( w_exeFreeFromExcMutexMerge1_1    ),
      .o_free1                 ( w_freeFromExeMutexMerge_xyp     ),
      .o_driveNext             ( w_exeDriveToExcp_1             ),
      .o_data_36               ( w_exeExcNew_36                  )
  );
  
  // �¼���· Lsu
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cSelector2_1b_xyp  u2_cSelector2_1b_xyp (
      .i_drive                 ( w_dirveToLsuSelector_xyp        ),
      .i_freeNext0             ( w_freeFromLsuMutexMerge_xyp     ),
      .i_freeNext1             ( w_driveToFreeLsu1_xyp           ),
      .rst                     ( rst                             ),
      .i_data                  ( w_lsuReq_xyp                    ), // 1��w_driveToLsuMutexMerge_xyp
  
      .o_free                  ( w_freeFromLsuSelector_xyp       ),
      .o_driveNext0            ( w_driveToLsuMutexMerge_xyp      ),
      .o_driveNext1            ( w_driveToFreeLsu0_xyp           )
  );
  (* dont_touch="true" *)delay1Unit outdelay2_xyp (.inR(w_driveToFreeLsu0_xyp), .outR(w_driveToFreeLsu1_xyp), .rst(rst));
  
  // �¼�����
  wire w_lsuDriveToExcMutexMerge1_1;
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cMutexMerge2_36b_xyp  u2_cMutexMerge2_36b_xyp (
      .i_drive0                ( w_lsuDriveToExcMutexMerge1_1      ),                  // ����lsuģ��  
      .i_drive1                ( w_driveToLsuMutexMerge_xyp      ),
      .i_data0_36              ( w_lsuTmp_36               ),
      .i_data1_36              ( 36'hf_ffff_ffff                 ),
      .i_freeNext              ( w_lsuFreeFromExcp_1              ),
      .rst                     ( rst                             ),
  
      .o_free0                 ( w_lsuFreeFromExcMutexMerge1_1       ),
      .o_free1                 ( w_freeFromLsuMutexMerge_xyp     ),
      .o_driveNext             ( w_lsuDriveToExcp_1             ),
      .o_data_36               ( w_lsuExc_36                  )
  );
  wire w_decFire_1,w_exeFire_1,w_lsuFire_1,w_ifIntFire_1,w_ifExcFire_1;
  reg [36:0] r_ifIntTmp_37;
  reg [35:0] r_ifExcTmp_36,r_decTmp_36,r_exeTmp_36,r_lsuTmp_36;
//   wire w_decMutexDriveToFifo1_1,w_exeMutexDriveToFifo1_1,w_lsuMutexDriveToFifo1_1;
//     (* dont_touch="true" *)delay6U decoderDelay (.inR(w_decMutexDriveToFifo_1), .outR(w_decMutexDriveToFifo1_1), .rst(rst));
//     (* dont_touch="true" *)delay6U executeDelay (.inR(w_exeMutexDriveToFifo_1), .outR(w_exeMutexDriveToFifo1_1), .rst(rst));
//     (* dont_touch="true" *)delay6U lsuDelay (.inR(w_lsuMutexDriveToFifo_1), .outR(w_lsuMutexDriveToFifo1_1), .rst(rst));

  cFifo1 ifIntDelayFifo(.i_drive(w_intDriToIntTmp), .i_freeNext(w_ifIntFreeFromInt), .rst(rst),
  .o_free(w_ifIntFreeFromIntTmp), .o_driveNext(w_intDriToInt), .o_fire_1(w_ifIntFire_1));    

  cFifo1 ifExcDelayFifo(.i_drive(w_iFExcdriToIntTmp), .i_freeNext(w_ifExcFreeFromInt), .rst(rst),
  .o_free(w_ifExcFreeFromIntTmp), .o_driveNext(w_iFExcdriToInt), .o_fire_1(w_ifExcFire_1));    

  cFifo1 ifHelpDecExcDelayFifo(.i_drive(w_drv2Excp_2Tmp), .i_freeNext(w_freeFExcp_2), .rst(rst),
               .o_free(w_freeFExcp_2Tmp), .o_driveNext(w_drv2Excp_2), .o_fire_1(w_decFire_1));    
               
//   cFifo1 executeDelayFifo(.i_drive(w_exeDriveToExcMutexMerge_1), .i_freeNext(w_exeFreeFromExcMutexMerge1_1), .rst(rst),
//                .o_free(w_exeFreeFromExcMutexMerge_1), .o_driveNext(w_exeDriveToExcMutexMerge1_1), .o_fire_1(w_exeFire_1));    
               
  cFifo1 lsuDelayFifo(.i_drive(w_lsuDriveToExcMutexMerge_1), .i_freeNext(w_lsuFreeFromExcMutexMerge1_1), .rst(rst),
               .o_free(w_lsuFreeFromExcMutexMerge_1), .o_driveNext(w_lsuDriveToExcMutexMerge1_1), .o_fire_1(w_lsuFire_1));    
               
// always @(posedge w_ifIntFire_1 or negedge rst) begin
//     if(!rst)begin
//         r_ifIntTmp_37 <= 37'h1ffff_fffe0;
//     end else begin
//         r_ifIntTmp_37 <= w_ifIntTmp_38;
//     end
// end
// assign w_ifInt_37 = r_ifIntTmp_37;

always @(posedge w_ifExcFire_1 or negedge rst) begin
    if(!rst)begin
        r_ifExcTmp_36 <= 36'hffff_fffff;
    end else begin
        r_ifExcTmp_36 <= w_ifExcTmp_36;
    end
end
assign w_ifExc_36 = r_ifExcTmp_36;

always @(posedge w_decFire_1 or negedge rst) begin
    if(!rst)begin
        r_decTmp_36 <= 36'hffff_fffff;
    end else begin
        r_decTmp_36 <= w_ifHelpDecExcTmp_36;
    end
end
assign w_ifHelpDecExc_36 = r_decTmp_36;

// always @(posedge w_exeFire_1 or negedge rst) begin
//     if(!rst)begin
//         r_exeTmp_36 <= 36'hffff_fffff;
//     end else begin
//         r_exeTmp_36 <= w_exeToExcpData_36;
//     end
// end
// assign w_exeTmp_36 = r_exeTmp_36;

always @(posedge w_lsuFire_1 or negedge rst) begin
    if(!rst)begin
        r_lsuTmp_36 <= 36'hffff_fffff;
    end else begin
        r_lsuTmp_36 <= w_lsuException_36;
    end
end
assign w_lsuTmp_36 = r_lsuTmp_36;
  /**************************************/

endmodule
