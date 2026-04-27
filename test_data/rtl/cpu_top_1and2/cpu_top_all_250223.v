
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

//瀹氫箟锛歩_IntSig={iic,wd,spi1,uart1,timer}
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
/*鍦ㄥ彇鎸囧墠澧炲姞涓や釜鎷╄矾锛屽垽鏂槸鍚﹂渶瑕佷粠鍒嗘淳杩囨潵鐨凱C锛宖etchSele0涓哄垽鏂槸鍚﹂渶瑕佹甯窹C+2鎴朠C+4鐨凱C,鑻ヨ瘧鐮佸彂鐢熷紓甯稿垯闇€鑸嶅純锛�
w_decExcFlag_1鏄瘧鐮佹槸鍚﹀彂鐢熷紓甯哥殑鏍囧織锛�
fetchSele1涓哄垽鏂槸鍚﹂渶瑕佸垎娲炬潵鐨勮烦杞琍C鎴栬€呬腑鏂紓甯哥粰鐨凱C锛寃_ExcToIfFlag_1鏍囧織鐫€璇C浠庝腑鏂紓甯告ā鍧楁潵鐨勶紝鐢变簬涓柇寮傚父妯″潡鏉ョ殑PC蹇呯劧
浼氳繘鍒板彇鎸囷紝鍥犱负涓€鏃︿骇鐢熶腑鏂垨寮傚父鍙栨寚杩涙潵鐨勬寚浠ょ浉褰撲簬绗竴鏉℃寚浠わ紝鎵€浠_exeExcFlag0_1浼樺厛绾ф渶楂橈紝濡傛灉鎵ц鎴栬€呰瘧鐮佷骇鐢熷紓甯革紝閭ｄ箞
w_ExcToIfFlag_1蹇呯劧浼氭潵锛屼絾鏅氫簬w_decExcFlag_1鍜寃_exeExcFlag0_1锛屾墍浠ュ彧瑕佷簩鑰呬腑鏈変竴涓紓甯搁兘闇€瑕佸悶鎺夋潵鍙栨寚鐨凱C
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
/*鍙栨寚杩欓噷寰€涓柇寮傚父妯″潡鐨勪簨浠舵€诲叡鏈変笁涓紝鍒嗗埆鏄彇鎸囧紓甯搞€佸彇鎸囦腑鏂拰璇戠爜寮傚父锛岃瘧鐮佸紓甯哥洰鍓嶅彧鏀寔寮傚父杩斿洖锛屽彇鎸囪繖閲屽府璇戠爜鍙戦€佸幓涓柇
寮傚父妯″潡鐨勪簨浠秓_drv2Excp_2鍜屽紓甯哥爜o_exceptionF_2_4,涓轰簡淇濋櫓璧疯锛屽湪姣忎釜鍘讳腑鏂紓甯告ā鍧楃殑浜嬩欢鍚庨兘鍔犱簡涓€涓猚Fifo
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
    .o_drv2Excp(w_iFExcdriToIntTmp), .i_freeFExcp(w_ifExcFreeFromIntTmp), .o_exceptionF_4(w_intExcNum_4),.i_isInInt(w_isInInt),
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
/*鍙栨寚鍜岃瘧鐮佷箣闂寸殑绾ч棿瀵勫瓨鍣ㄣ€傝繖閲岀敤鎷╄矾鏉ュ疄鐜帮紝杩欓噷鐨勬嫨璺湁涓夌鎯呭喌锛氱涓€绉嶏紝濡傛灉鍙栨寚杩欓噷鏈変腑鏂垨鑰呭紓甯稿苟涓旇瘧鐮佸拰鎵ц閮芥病鏈夊紓甯革紝
閭ｄ箞灏辫蛋寮傚父鐨勬梺璺紱绗簩绉嶏紝濡傛灉璇戠爜鎴栨墽琛屾湁寮傚父锛岄偅涔堝氨璧伴槺锛涚涓夌锛屼笂闈袱绉嶉兘涓嶇鍚堬紝灏辫蛋姝ｅ父鐨勮繘鍏ヨ瘧鐮佺殑閭ｆ潯璺€傜壒鍒渶瑕佹敞鎰忕殑鏄紝
鍒ゆ柇璇戠爜鍜屾墽琛屾湁娌℃湁寮傚父鏄牴鎹紓甯哥爜鍒ゆ柇鐨勶紝杩欓噷鏄痺_decTrueNum_4,w_exeTrueNum_4锛屽墠闈㈡彁鍒拌瘧鐮佺殑寮傚父浜嬩欢鐢卞彇鎸囩粰鍑猴紝浣嗘槸杩欓噷鐨勫紓甯哥爜
骞朵笉鏄彇鎸囧府蹇欎骇鐢熺殑閭ｄ釜锛岃€屾槸璇戠爜妯″潡鑷繁浜х敓鐨勶紝鍥犱负璇戠爜杩欓噷鐨勫紓甯哥洰鍓嶆敮鎸佺殑鏄紓甯歌繑鍥烇紝鑰屽紓甯歌繑鍥炵殑涓嬩竴鏉℃寚浠ゅ繀鐒舵槸鏂扮▼搴忕殑绗竴鏉℃寚浠わ紝
鎵€浠ュ湪鏂版寚浠よ繘鏉ヤ箣鍓嶏紝娴佹按绾夸腑鐨勬墍鏈変俊鎭兘蹇呴』琚浣嶏紝鍏朵腑灏卞寘鎷垎娲炬梺璺娴嬬殑璁℃暟鍣紝鎵€浠ュ繀椤昏寮傚父杩斿洖鐨勮繖鏉℃寚浠よ繘鍏ュ埌鍒嗘淳鏇存柊璁℃暟鍣ㄤ箣鍚�
鎵嶈蛋绾ч棿瀵勫瓨鍣ㄧ殑寮傚父鏃佽矾
1/12 鏇存柊
鐢变簬鍒嗘淳鏃佽矾妫€娴嬬殑璁℃暟鍣ㄧ殑澶嶄綅閫昏緫鏇存敼鎴愪簡鍙涓柇寮傚父妯″潡寰€鍙栨寚鍙戜簨浠讹紝鎰忓懗鐫€瑕佽繘鏂扮殑绋嬪簭鐨勶紝杩欎釜绋嬪簭涓嶇鏄腑鏂紓甯告湇鍔＄▼搴忥紝杩樻槸寮傚父杩斿洖鍚庣殑
姝ｅ父绋嬪簭锛岄兘鐩稿綋浜庣涓€鏉℃寚浠わ紝鎵€浠_decTrueNum_4閲囩敤鍙栨寚甯繖浜х敓鐨勫紓甯哥爜涔熸棤濡�
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
//     .req(w_intCodeFlag_1),//1/13 zwm ------------->鐢ㄦ潵閫夋嫨鐢ㄧ殑涓柇鐮佹潵鑷摢閲�
//     .rst(rst)
//     );
// assign w_intCurrentNum_5 = w_intCodeFlag_1 ? w_intNum_6 : w_intNewType_5;
// assign w_iFExcOrIntFlag_1 = (w_intExcNum_4 != 4'b1111 || w_intNewType_6 != 6'b000000) && ({w_decTrueNum_4,w_exeTrueNum_4}==8'hff); 
assign w_iFExcOrIntFlag_1 = (w_exceptionF_2_4 != 4'b1111 || w_intExcNum_4 != 4'b1111 || w_intNewType_6 != 6'b000000) && (w_exeTrueNum_4==4'hf); 
// assign w_ifDriveToMeFlag_1 =  (w_decTrueNum_4!=4'b1111 || w_exeTrueNum_4 != 4'b1111);
assign w_ifDriveToMeFlag_1 = w_exeTrueNum_4 != 4'b1111;

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
/*excfifo鍗＄殑鏄綋鍙栨寚寰€璇戠爜璧版椂鏉ュ垽鏂渶涓嶉渶瑕佸府鎵ц鍙戝幓涓柇寮傚父鐨勪簨浠躲€傜涓€锛屼箣鎵€浠ヨ甯墽琛屽彂寮傚父浜嬩欢锛屾槸鍥犱负濡傛灉绋嬪簭鐨勭涓€鏉℃寚浠ゅ湪鎵ц涔嬪墠
灏变骇鐢熶腑鏂紓甯哥殑璇濓紝鏄笉浼氳繘鍏ュ埌鎵ц妯″潡鐨勶紝杩涜€屾墽琛屼篃灏变笉浼氬彂寮傚父浜嬩欢锛岃€岀幇鍦ㄧ殑涓柇寮傚父妯″潡蹇呴』寰楃瓑鍒版墍鏈夋ā鍧楃殑涓柇寮傚父浜嬩欢鍒伴綈涔嬪悗鎵嶄細澶勭悊锛�
鎵€浠ュ繀椤诲府鎵ц鍙戝紓甯镐簨浠躲€俧ifo杩欓噷鐨刬_freeNext鐗瑰埆閲嶈锛寃_launchDriveToExe11鏄墽琛屾敹鍒板垎娲剧殑浜嬩欢骞朵笖寤惰繜涓€娈垫椂闂村悗鐨勶紝鎵€浠ユ鏃跺氨蹇呯劧
淇濊瘉浜嗘墽琛岄噷闈㈡湁鎸囦护浜嗕箣鍚庢墠鍒ゆ柇瑕佷笉瑕佸府鎵ц鍙戝紓甯镐簨浠讹紙濡傛灉鍒嗘淳鍒版墽琛岀殑绾ч棿瀵勫瓨鍣ㄥ垽鏂彲浠ユ甯歌繘鍏ユ墽琛岀殑璇濓級
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
/*杩欓噷缁欒蛋寮傚父鏃佽矾鍔犱簡寰堝ぇ寤舵椂锛屾槸瑕佷繚璇佹甯告寚浠よ蛋鍒版墽琛屽苟涓旂粰浜嗗浣嶄箣鍚庢梺璺墠鑳借蛋
*/
//---------------------------------------------------------------------------------------------------------//  
wire w_ifDriToDecMerDelay1_1,w_ifDriToDecMerDelay2_1,w_ifDriToDecMerDelay3_1;
(* dont_touch="true" *)delay8U delayDriveToByPath(
    .inR(w_ifDriToDecMer),
    .outR(w_ifDriToDecMerDelay1_1),
    .rst(rst)
    );
(* dont_touch="true" *)delay6U delayDriveToByPath1(
    .inR(w_ifDriToDecMerDelay1_1),
    .outR(w_ifDriToDecMerDelay3_1),
    .rst(rst)
    );//2/18 zwm add
    wire w_releaseFlag_1;
    wire w_launchDriveToExe_1, w_ExeFreeToLaunch_1;
    contTap releaseTap(
        .trig(w_launchDriveToExe_1 | w_ExeFreeToLaunch_1),//1/16 zwm ------->change w_driveToExeMer to w_launchDriveToExe_1
        .req(w_releaseFlag_1),
        .rst(rst)
        );
    
    (* dont_touch="true" *) cPmtFifo1 fetchToExePmtfifo(.i_drive(w_ifDriToDecMerDelay3_1), .o_free(w_freeFromDecMer11), .pmt(~w_releaseFlag_1),
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
// //11/7 zwm ->store涔熼敓鏂ゆ嫹閿熸枻鎷疯閿熸枻鎷烽敓鏂ゆ嫹锟�??????
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
//11/7 zwm ->store涔熼敓鏂ゆ嫹閿熸枻鎷疯閿熸枻鎷烽敓鏂ゆ嫹锟�??????
//11/26 zwm due to load is just w_int1_16[4],maybe a is not load but w_int1_16[4] = 1
        if(w_multiLSEnd_1 & w_multiLoadOrStoreOverData_1 | w_exeReq & w_loadEndFlag )begin
            r_isGo = 1'b1;
        end
        else if(w_decoData_187[5] | w_decoData_187[57] & w_decoData_187[53] )begin
            r_isGo = 1'b0;
        end
    end
end
assign w_pmt = ~w_intIsGo_1 & r_isGo;//1/12 zwm ---->鍙栨寚鍜岃瘧鐮佷箣闂撮攣鐨勬潯浠惰繕瑕佸姞涓婁腑鏂紓甯告ā鍧楃殑锛屽洜涓轰腑鏂紓甯告ā鍧楀幓鍙栨寚鐨勪俊鍙峰繀鐒舵瘮鍏ユ爤缁撴潫蹇紝蹇呴』绛夊埌鍏ユ爤缁撴潫鍚庢墠鑳介噴鏀惧彇鎸囩殑鎸囦护
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
//update:w_decoData_187閺堚偓妤傛ü缍呴弰鐥篲isExc_1
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
/*鍒嗘淳瀵逛笌鏃佽矾妫€娴嬭鏁板櫒鏇存柊鐨勯棶棰樸€傚彧瑕佸彂鐢熶簡涓柇寮傚父锛岄偅涔堜笉绠℃€庝箞鏍凤紝鍦ㄥ綋鍓嶆祦姘寸嚎琚啿鍒蜂箣鍚庯紝杩涙潵鐨勬寚浠ゅ繀鐒舵槸绗竴鏉℃寚浠わ紝鎵€鏈夌殑
鏉′欢閮芥槸鍒濆鐨勬潯浠讹紝鎵€浠ユ瘡褰撲腑鏂紓甯告ā鍧楀線鍙栨寚鍙戜簨浠舵椂锛屾剰鍛崇潃瑕佽繘鏉ヤ腑鏂湇鍔＄▼搴忔垨鑰呭紓甯歌繑鍥炵殑绗竴鏉℃寚浠や簡锛屾鏃堕兘瑕佹妸鎵€鏈夌殑鏉′欢鍒濆鍖�
杩欓噷i_driveFExcToIf_1鍜宨_excToIfFlag_1灏辨槸鐢ㄤ簬鎶婂垎娲捐鏁板櫒鍒濆鍖栫殑
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
    .o_bDriToIf(w_branchDri1), .o_branchPc_32(w_branchPc_32), .i_bFreeFromIf(w_branchFree1), //鐠哄疇锟�??????1
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
//閿涚噦绱甸敍鐔峰讲娴犮儲褰侀崜宥呯殺娑撳绔撮弶顡禼缂佹瑥褰囬敓锟�????????????????


//1/11 zwm
//---------------------------------------------------------------------------------------------------------//
/*
1/12 鏇存柊
涓嶉渶瑕佺敤鍒拌繖涓爣蹇椾綅浜嗭紝鍥犱负鏃犳硶鎶婃彙杩欎釜鏃舵満锛屽鏋渘+1鏉℃寚浠よ繕娌¤繘璇戠爜锛屼絾鏄痭鏉℃寚浠ゅ凡缁忚繘鎵ц骞朵笖鏃佽矾鍙戝嚭鏉ヤ簡锛岃繖涓椂鍊欐墽琛岀殑鏃佽矾鏄�
闇€瑕佺殑锛屽彧涓嶈繃鏄痭+1鏉℃寚浠よ繕娌¤繘鍒拌瘧鐮佸垎娲�
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
/*杩欓噷鐨勪袱涓獁_decExcRstFlag_1锛寃_exeExcRstFlag_1鏄爣蹇楃潃鏄惁褰撳墠浜х敓鐨勬槸鏈€鏂扮殑寮傚父鐮侊紝鍥犱负濡傛灉浜х敓寮傚父浜嗭紝鍐插埛娴佹按绾夸簡锛屽綋鏂版寚浠�
杩涙潵鐨勬椂鍊欑悊搴斿皢鎵€鏈夌殑涓柇寮傚父鐮侀兘澶嶄綅鎴�4鈥榖1111
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
/*杩欓噷鏄垎娲惧拰鎵ц涔嬮棿鐨勭骇闂村瘎瀛樺櫒銆傝繖閲岀殑鎯呭喌鏈€澶嶆潅锛屽洜涓烘嫨璺墠闈㈣繕鏈変竴涓簰鏂ワ紝褰撴嫨璺殑浜嬩欢鏄粠鍒嗘淳杩囨潵鐨勶紝鎷╄矾鏈変笁绉嶆儏鍐碉細
绗竴绉嶏細濡傛灉璇戠爜鏈夊紓甯稿苟涓旀墽琛屾棤寮傚父锛岄偅涔堝氨璧板紓甯告梺璺紱绗簩绉嶏紝濡傛灉鎵ц鏈夊紓甯搁偅灏辫蛋闃憋紱濡傛灉涓婇潰涓ょ閮戒笉鏄氨姝ｅ父杩涙墽琛屻€�
褰撴嫨璺殑浜嬩欢鏄粠涓婁竴涓骇闂村瘎瀛樺櫒鐨勫紓甯告梺璺潵鐨勶紝鎷╄矾鏈変袱绉嶆儏鍐碉細绗竴绉嶏細鎵ц鏃犲紓甯革紝閭ｄ箞灏辩户缁蛋寮傚父鏃佽矾锛涚浜岀锛屾墽琛屾湁寮傚父锛�
閭ｄ箞灏辫蛋闃�
*/
//---------------------------------------------------------------------------------------------------------//  
    
    assign w_decTrueNum_4 = w_decExcRstFlag_1 ? w_decExcPcAndNum_36[3:0] : 4'b1111;
    assign w_exeTrueNum_4 = w_exeExcRstFlag_1 ?  w_exeToExcpData_36[3:0] : 4'b1111;
    assign w_decoderExcFlag_1 = w_excOrDecFlag_1 ? (w_decTrueNum_4 != 4'b1111) && (w_exeTrueNum_4==4'b1111) : w_exeTrueNum_4 == 4'b1111;
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

    (* dont_touch="true" *) delay8U launchSeleDelay0(.inR(w_driveToLaunchSele), .outR(w_driveToLaunchSele1), .rst(rst)); 

    
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
/*杩欓噷缁欒蛋寮傚父鏃佽矾鍔犱簡寰堝ぇ寤舵椂锛屾槸瑕佷繚璇佹甯告寚浠よ蛋鍒版墽琛屽苟涓旂粰浜嗗浣嶄箣鍚庢梺璺墠鑳借蛋
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
// (* dont_touch="true" *) delay4U lsuGoDelay0(.inR(w_launchDriveToExe), .outR(w_launchDriveToExe1), .rst(rst)); //2/9 zwm not need
    always @(posedge w_launchDriveToExe or negedge rst) begin
        if (!rst) begin
            r_lsuGo_1 <= 1'b1;
        end else begin
//2/19 zwm add two condition
//----------------------------------------------------------------------------//
            if(r_isGo == 1'b0 && (r_launchDataToExe_207[187] | r_launchDataToExe_207[134] & r_launchDataToExe_207[130])) r_lsuGo_1 <= 1'b0; // 2024.11.13--zlt-->lsuWay
//----------------------------------------------------------------------------//
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

// 鏉╃偘鑵戦弬顓炵磽鐢憡膩閸ф娈戠痪鍨帥缁犫偓閸楁洖顦╅敓锟�????????????????-->zlt,2024.10.25
(* dont_touch="true" *) execute execute_inst (
    
    .i_launchDriveToExecute_1(w_launchDriveToExe),.i_wen_2(w_wen1_2), .i_launchDataToExe_207(w_launchDataToExecute_207), .o_executeFreeToLaunch_1(w_launchFreeFromExe),
    
    .o_executeDriveToGrf_1(w_exeDriveToRGrf_1), .o_executeToGrfData_8(w_exeToRGrfAddr_8), .i_executeFreeFromGrf_1(w_exeFreeFromRGrf),  //閸樼鲍rf
    .i_grfDriveToExecute_1(w_grfDriToExe_1), .i_grfToExecuteData_64(w_grfDataToExe_64), .o_executeFreeToGrf_1(w_exeFreeFromGrf), //grf閸ョ偞锟�??????

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
    .rst(rst));//閸氬海鐢婚崣顖濆厴鐟曚焦宕叉稉鈧稉瀣╃秴缂冾噯绱濋崗鍫⑩€樼€规碍鐥呭鍌氱埗娴滃棗鍟€缂佹瑦姊洪敓锟�????????????????



//------------------------------big change-----------------------------------------//
//---------------------------------------------------------------------------------------------------------//
/*杩欓噷瀵规墽琛屽彂寰€鍒嗘淳鐨勬梺璺繘琛岄€夋嫨銆傚鏋滃彇鎸囧湪绾ч棿鎷╄矾鐨勯€夋嫨娌¤蛋姝ｅ父鐨勯偅鏉¤矾锛岄偅涔堣涔堝氨鏄湪鍙栨寚鐨勬寚浠や骇鐢熶簡寮傚父锛岃涓嶅氨鏄墽琛岃嚜韬骇鐢熶簡寮傚父锛�
杩欎袱绉嶆儏鍐甸兘涓嶅簲璇ュ線鍒嗘淳鍙戞梺璺紝鍥犱负鍒嗘淳鍚庨潰涓嶄細鍐嶆湁鏂扮殑鎸囦护
*/
//---------------------------------------------------------------------------------------------------------//  
//1/11 zwm 
wire w_exeWayToMe;
wire w_launchWaySele0Drv2ExeByPathPmtfifo_1;
wire w_launchWaySele0FreeFExeByPathPmtfifo_1;
(* dont_touch="true" *) cSelector2_1b launchWaySele0(.i_drive(w_ExeDriveToLunch_1),//1/27 zwm ------------->change w_ExeDriveToLunch_1 to w_ExeDriveToLunchDelay_1
     .i_data_1(r_lsuGo_1), .o_free(w_launchFreeToExe_1),
    .o_driveNext0(w_launchWaySele0Drv2ExeByPathPmtfifo_1), .i_freeNext0(w_launchWaySele0FreeFExeByPathPmtfifo_1), .o_data0_1(),
    .o_driveNext1(w_exeWayToMe), .i_freeNext1(w_exeWayToMe), .o_data1_1(),
    .rst(rst));
//--------------------------------change end--------------------------------------//



//------------------------------big change-----------------------------------------//
//---------------------------------------------------------------------------------//
/*1/27 zwm
鐢变簬鎵ц鍘诲垎娲剧殑鏃佽矾鏈夊彲鑳戒細蹇簬涓嬩竴鏉℃寚浠ゅ埌璇戠爜锛屽鏋滀笅涓€鏉℃寚浠ゅ垰濂芥湁涓柇寮傚父锛屾鏃舵墽琛岀殑鏃佽矾
鏃╁凡鍙戝嚭鏉ワ紝鏃犳硶琚秷闄わ紝鎵€浠ュ繀椤讳繚璇佷笅涓€鏉℃寚浠ゅ彂鍒拌瘧鐮佷箣鍚庢墠鎶婃墽琛屾梺璺彂鍑烘潵
*/
//----------------------------------------------------------------------------------//  
wire w_releaseExeByPathFlag_1;
reg r_releaseExeByPathFlag_1;
wire w_ExeDriveToLunchDelay_1,w_launchFreeToExe1_1;
// wire w_exeByPathFire_1;
wire w_launchToFetch_1;
reg r_count_1;
// assign w_launchToFetch_1 = w_launchDriveToIf_1 | w_branchDri1 | w_driveToDec;
assign w_launchToFetch_1 = w_exeByPathDriveToLaunch_1 | w_driveToDec | w_branchDri3;
// assign w_launchToFetch_1 = w_intDriToIntTmp | w_driveToDec;//2/21 zwm change
wire w_ExeDriveToLunchReq_1,w_driveToDecReq_1,w_launchToFetch5_1,w_ExeDriveToLunch5_1,w_driveToDec5,w_ExeDriveToLunch6_1,w_driveToDec6;
(* dont_touch="true" *) delay6U launchToFetchDelay(.inR(w_launchToFetch_1), .outR(w_launchToFetch5_1), .rst(rst));
(* dont_touch="true" *) delay6U launchToFetchDelay1(.inR(w_driveToDec), .outR(w_driveToDec6), .rst(rst));
(* dont_touch="true" *) delay6U launchToFetchDelay2(.inR(w_ExeDriveToLunch_1), .outR(w_ExeDriveToLunch6_1), .rst(rst));
contTap exeTap1(
.trig(w_ExeDriveToLunch_1 | w_ExeDriveToLunch5_1),
.req(w_ExeDriveToLunchReq_1),
.rst(rst)
); 

(* dont_touch="true" *) delay6U ExeDriveToLunchDelay(.inR(w_ExeDriveToLunch_1), .outR(w_ExeDriveToLunch5_1), .rst(rst));
contTap exeTap2(
.trig(w_driveToDec | w_driveToDec5),
.req(w_driveToDecReq_1),
.rst(rst)
); 
(* dont_touch="true" *) delay6U ldriveToDecDelay(.inR(w_driveToDec), .outR(w_driveToDec5), .rst(rst));

wire w_rstDrive;
assign w_rstDrive = w_launchToFetch5_1 | rst;

// always @(negedge w_rstDrive) begin
//     if(!rst)begin
//         r_releaseExeByPathFlag_1 = 1'b1;
//         r_count_1 = 1'b1;
//     end else begin
//         if(w_driveToDec6 & w_ExeDriveToLunch6_1 | w_ExeDriveToLunchReq_1 & w_driveToDecReq_1) begin
//             r_releaseExeByPathFlag_1 = 1'b1;
//         end else if(w_driveToDecReq_1) begin
//             r_releaseExeByPathFlag_1 = 1'b1;
//             r_count_1 = r_count_1 + 1'b1;
//         end else if(w_ExeDriveToLunchReq_1) begin
//             r_releaseExeByPathFlag_1 = r_count_1;
//             r_count_1 = r_count_1 + 1'b1;
//         end else begin
//             r_releaseExeByPathFlag_1 = 1'b1;
//             r_count_1 = 1'b1;
//         end
//     end
// end


always @(posedge w_launchToFetch_1 or negedge rst) begin
    if(!rst)begin
        r_releaseExeByPathFlag_1 = 1'b1;
        r_count_1 = 1'b1;
    end else begin
        if(w_driveToDec) begin
            r_releaseExeByPathFlag_1 = 1'b1;
            r_count_1 = r_count_1 + 1'b1;
        end else if(w_exeByPathDriveToLaunch_1) begin
            r_releaseExeByPathFlag_1 = r_count_1;
            r_count_1 = r_count_1 + 1'b1;
        end else begin
            r_releaseExeByPathFlag_1 = 1'b1;
            r_count_1 = 1'b1;
        end
    end
end
assign w_releaseExeByPathFlag_1 = r_releaseExeByPathFlag_1;
wire w_launchWaySele0Drv2ExeByPathPmtfifoDelay_1;
// (* dont_touch="true" *) delay6U exeByPathDelay(.inR(w_launchWaySele0Drv2ExeByPathPmtfifo_1), .outR(w_launchWaySele0Drv2ExeByPathPmtfifoDelay_1), .rst(rst)); 
(* dont_touch="true" *) cPmtFifo1 exeByPathPmtfifo(.i_drive(w_launchWaySele0Drv2ExeByPathPmtfifo_1), .o_free(w_launchWaySele0FreeFExeByPathPmtfifo_1), .pmt(w_releaseExeByPathFlag_1),
.o_driveNext(w_ExeDriveToLunchDelay_1), .i_freeNext(w_launchFreeToExe1_1), .o_fire_1(),
.rst(rst));


wire w_exeWayToMe1;
wire  w_launchWaySeleCS_1;
// assign w_launchWaySeleCS_1 = r_lsuGo_1 && (w_ifOutStackSeleFlag_2!=2'b00);
assign w_launchWaySeleCS_1 = w_ifOutStackSeleFlag_2==2'b01;//1/12 zwm ----> use this
// assign w_launchWaySeleCS_1 = r_lsuGo_1 & w_launchNoEmptyFlag_1;
(* dont_touch="true" *) cSelector2_1b launchWaySele1(.i_drive(w_ExeDriveToLunchDelay_1),//1/27 zwm ------------->change w_ExeDriveToLunch_1 to w_ExeDriveToLunchDelay_1
.i_data_1(w_launchWaySeleCS_1), .o_free(w_launchFreeToExe1_1),
.o_driveNext0(w_exeWayToLaunch), .i_freeNext0(w_exeWayFreeFromLaunch), .o_data0_1(),
.o_driveNext1(w_exeWayToMe1), .i_freeNext1(w_exeWayToMe1), .o_data1_1(),
.rst(rst));


//-------------------------------change end-------------------------------------------------------------//

//1/10 zwm add a w_exeOrExcPathFlag_1 to distant from exe or ExcPath
wire w_exeOrExcPathFlag_1;
(* dont_touch="true" *) cMutexMerge2_1b exeMutexMerge(.i_drive0(w_exeDriToExeMutex), .i_data0_1(1'b1), .o_free0(w_exeMutexFreeToExe),
    .i_drive1(w_launchDriveToExeMerDelay2_1), .i_data1_1(1'b0), .o_free1(w_launchFreeFromExeMer),
    .i_freeNext(w_freeFromLsu | w_freeFromLsuMer | w_driveToMe), .o_driveNext(w_driveToExeSele_1), .o_data_1(w_exeOrExcPathFlag_1),
    .rst(rst));


//-----------------------------------big change----------------------------------//
//---------------------------------------------------------------------------------------------------------//
/*杩欓噷鏄墽琛屽線璁垮瓨鐨勭骇闂村瘎瀛樺櫒銆傚洜涓鸿瀛樺紓甯告彁鍓嶅埌浜嗘墽琛屾潵鍒ゆ柇锛屾墍浠ヤ笉浼氬瓨鍦ㄨ瀛樺紓甯告墽琛岃蛋闃辩殑鎯呭喌銆傝繖閲屾嫨璺殑浜嬩欢涔熸湁涓ょ锛岀涓€绉嶆槸浠�
鎵ц妯″潡鏉ワ紝閭ｄ箞鍙渶瑕佸垽鏂墽琛屾湁娌℃湁寮傚父灏卞彲浠ワ紝濡傛灉鏈夊氨璧板紓甯告梺璺紝娌℃湁灏辨甯稿幓寰€璁垮瓨锛涚浜岀鏄粠涓婁竴涓骇闂存嫨璺殑寮傚父鏃佽矾鏉ワ紝
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
    .i_grfDriveToLsu_1(w_grfDriveToLsu_1), .i_grfToLsuData_64(w_grfToLsuData_64), .o_grfFreeFromLsu_1(w_grfFreeFromLsu_1),// 鐠囩眾RF
    
    .o_lsuDriveToExcp_1(w_lsuDriveToExcMutexMerge_1), .o_exception_36(w_lsuException_36), .i_lsuFreeFromExcp_1(w_lsuFreeFromExcMutexMerge1_1),                               

    .o_lsuDriveToWriteBack_1(w_lsuDriveToWriteBack_1), .o_lsuToWriteBackData_103(w_lsuToWriteBackData_103), .i_lsuFreeFromWriteBack_1(w_lsuFreeFromWriteBack_1),

    .o_lsuDriveToLaunch_1(w_lsuDriveToLaunch_1), .o_lsuToLaunchData_64(w_lsuToLaunchData_64), .i_lsuFreeFromLaunch_1(w_lsuFreeFromLaunch_1),

    .o_lsuDriveToWGrf_1(w_lsuDriveToWGrf_1), .o_wGrfData_74(w_lsuWGrfData_74), .i_lsuFreeFromWGrf_1(w_lsuFreeFromWGrf_1), // 閸愭─RF

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
//2/11 zwm add delay6U
  wire w_drvFICacheDelay,w_drvFICacheDelay1;
  (* dont_touch="true" *) delay6U icacheSelectorDelay(.inR(i_drvFICache), .outR(w_drvFICacheDelay), .rst(rst));   
  (* dont_touch="true" *) delay8U icacheSelectorDelay1(.inR(w_drvFICacheDelay), .outR(w_drvFICacheDelay1), .rst(rst)); //2/11 zwm add  
  cSelector2_65b_cpu icacheSelector(
    .i_drive(w_drvFICacheDelay1), .i_data_65(i_inst_65), .o_free(o_free2ICache),
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
wire w_lsuSplitterDriveToExeSele0_1,w_exeSele0FreeToLsuSplitter_1, w_LsuDriveToLunch1_1, w_launchFreeToLsu1_1,w_launchFreeToLsu2_1;

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




//------------------------------big change-----------------------------------------//
//---------------------------------------------------------------------------------//
/*2/21 zwm
鐢变簬鎵ц鍘诲垎娲剧殑鏃佽矾鏈夊彲鑳戒細蹇簬涓嬩竴鏉℃寚浠ゅ埌璇戠爜锛屽鏋滀笅涓€鏉℃寚浠ゅ垰濂芥湁涓柇寮傚父锛屾鏃舵墽琛岀殑鏃佽矾
鏃╁凡鍙戝嚭鏉ワ紝鏃犳硶琚秷闄わ紝鎵€浠ュ繀椤讳繚璇佷笅涓€鏉℃寚浠ゅ彂鍒拌瘧鐮佷箣鍚庢墠鎶婃墽琛屾梺璺彂鍑烘潵
*/
//----------------------------------------------------------------------------------//  
wire w_releaseLsuByPathFlag_1;
reg r_releaseLsuByPathFlag_1;
wire w_LsuDriveToLunchDelay_1,w_LsuDriveToLunchDelay2_1;
// wire w_launchToFetch_1;
// assign w_launchToFetch_1 = w_launchDriveToIf_1 | w_branchDri1 | w_driveToDec;
// assign w_launchToFetch_1 = w_exeByPathFire_1 | w_driveToDec;
// assign w_launchToFetch_1 = w_intDriToIntTmp | w_driveToDec;//2/21 zwm change
// always @(posedge w_launchToFetch_1 or negedge rst) begin
//     if(!rst)begin
//         r_releaseExeByPathFlag_1 = 1'b1;
//     end else begin
//         if(w_intDriToIntTmp) begin
//             r_releaseExeByPathFlag_1 = w_intNewType_6 != 6'b000000 ? 1'b0 : 1'b1;
//         end else begin
//             r_releaseExeByPathFlag_1 = 1'b1;
//         end
//     end
// end
assign w_releaseLsuByPathFlag_1 = r_releaseLsuByPathFlag_1;
// (* dont_touch="true" *) delay6U exeByPathDelay(.inR(w_ExeDriveToLunch_1), .outR(w_ExeDriveToLunchDelay_1), .rst(rst)); 
(* dont_touch="true" *) cPmtFifo1 lsuByPathPmtfifo(.i_drive(w_LsuDriveToLunch1_1), .o_free(w_launchFreeToLsu2_1), .pmt(w_releaseExeByPathFlag_1),
.o_driveNext(w_LsuDriveToLunchDelay_1), .i_freeNext(w_launchFreeToLsu1_1), .o_fire_1(),
.rst(rst));

//-------------------------------change end-------------------------------------------------------------//






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


// 11/6 zwm ->閿熸枻鎷烽敓鏂ゆ嫹涓€閿熸枻鎷烽敓鏂ゆ嫹璺敓鏂ゆ嫹閿熸枻鎷烽敓鍙鎷锋墽閿熸枻鎷烽敓瑙掑嚖鎷烽敓鏂ゆ嫹瑕侀敓鐭揪鎷烽敓鏂ゆ嫹锟�??????

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
  .rst(rst)); // exe     // 閿熸枻鎷烽敓鏂ゆ嫹閿熸枻鎷蜂竴閿熸枻鎷锋病閿熸枻鎷锋墽閿熷彨纰夋嫹閿熸枻鎷疯矾
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
    .o_drive_pc(w_branchDri2), .o_pcData_32(w_branchPC2_32), .i_wbFreeFromIF(w_branchFree2), // 鐠哄疇锟�??????2
    
    .o_drive_grf(w_grfDriveFromWB_1), .o_grfData_74(w_grfData_74), .i_wbFreeFromGRF(w_grfFreeToWB_1), // 閸愭─RF
    
    .o_drive_xpsr(w_psrDriveFromWB_1), .o_xpsrData_4(w_nzcv_4), .i_wbFreeFromXpsr(w_psrFreeToWB_1), 

    .rst(rst)
  );// wb闂団偓鐟曚椒鎱ㄩ敓锟�????????????????

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


// 閸氬海鐢婚棁鈧憰浣锋叏閺€纭呯箻娑擃厽鏌囧鍌氱埗閻ㄥ嫮锟�?????? -->zlt 2024.10.25
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
    .o_DriveToIf_1(w_branchDri3),.o_intPC_32(w_branchPC3_32),.i_freeFromIf_1(w_branchFree3), // 鐠哄疇锟�??????3
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
    .o_grfDriveToLaunch_1(w_grfDriveToLaunch_1), .o_grfDataToLaunch_64(w_grfDataToLaunch_64), .i_grfFreeFromLaunch_1(w_grfFreeFromLaunch_1), //launch 鐠囩鲍rf
    
    .i_driveFromExe_1(w_exeDriveToRGrf_1), .i_rs2Addr_8(w_exeToRGrfAddr_8), .o_grfFreeToExe_1(w_exeFreeFromRGrf),
    .o_grfDriveToExe_1(w_grfDriToExe_1), .o_grfDataToExe_64(w_grfDataToExe_64), .i_grfFreeFromExe_1(w_exeFreeFromGrf), // exe 鐠囩鲍rf
    
    .i_driveFromLsu_1(w_lsuDriveToRGrfDelay_1), .i_rs3Addr_8(w_lsuToRGrfData_8), .o_grfFreeToLsu_1(w_lsuFreeFromRGrf_1),
    .o_grfDriveToLsu_1(w_grfDriveToLsu_1), .o_grfDataToLsu_64(w_grfToLsuData_64), .i_grfFreeFromLsu_1(w_grfFreeFromLsu_1), // lsu 鐠囩鲍rf

    .i_grfwDriveFromLsu_1(w_lsuDriveToWGrf_1), .i_lsuAddr_8(w_lsuWGrfData_74[73:66]), .i_lsuDataToGrf_64(w_lsuWGrfData_74[65:2]), .i_lsuWen_2(w_lsuWGrfData_74[1:0]), 
    .o_grfwFreeToLsu_1(w_lsuFreeFromWGrf_1), // LSU閸愭─RF

    .i_driveFromWb_1(w_wbDriToRGrf), .i_rs4Addr_8(w_lsuRegAddr_8[7:0]), .o_grfFreeToWb_1(w_wbFreeFromRGrf),
    .o_grfDriveToWb_1(w_grfDriveToWb_1), .o_grfDataToWb_64(w_grfDataToWb_64), .i_grfFreeFromWb_1(w_grfFreeFromWb_1), //WB閿燂拷??????????
    
    .i_grfwDriveFromWB_1(w_grfDriveFromWB_1), .i_wbAddr_8(w_grfData_74[73:66]), .i_wbDataToGrf_64(w_grfData_74[65:2]), .i_wbWen_2(w_grfData_74[1:0]),
    .o_grfwFreeToWB_1(w_grfFreeToWB_1), //WB閿燂拷?????????
    
    .i_driveFromExp_1(w_driveToRGRF_1), .o_grfFreeToExp_1(w_freeFromRGRF_1),
    .o_grfDriveToExp_1(w_driveFromRGRF_1), .o_grfDataToExp_192(w_grfData_192), .i_grfFreeFromExp_1(w_freeToRGRF_1), //exp閿燂拷??????????
    
    .i_grfwDriveFromExp_1(w_driveToWGRF_1), .i_expAddr_8(w_dataToWGRF_72[71:64]), .i_expDataToGrf_64(w_dataToWGRF_72[63:0]), .i_expWen_2(2'b11),
    .o_grfwFreeToExp_1(w_freeFromWGRF_1) //exp閿燂拷?????????
  );

// wire PSR onlu need one port --> zlt -->need arbtMerge
(* dont_touch="true" *) prf prf_inst (
    .rst(rst),
    .i_psrDriveFromLaunch_1(w_launchDriveToPsr_1), .o_psrFreeToLaunch_1(w_PSRFreeToLaunch_1),
    .o_psrDriveToLaunch_1(w_psrDriveToLaunch_1), .o_psrDataToLaunch_32(w_psrDataToLaunch_32), .i_psrFreeFromLaunch_1(w_psrFreeFromLaunch_1), //launch鐠囩倍sr
    
    .i_prfDriveFromLaunch_1(w_launchDriveToSrf_1), .i_rsAddr_8(w_SRegAddr_8), .o_prfFreeToLaunch_1(w_srfFreeTolaunch_1),
    .o_prfDriveToLaunch_1(w_prfDriveToLaunch_1), .o_prfDataToLaunch_32(w_prfDataToLaunch_32), .i_prfFreeFromLaunch_1(w_prfFreeFromLaunch_1), //launch鐠囩倍rf
    
    .i_psrDriveFromExp_1(w_driveToRPSR_1), .o_psrFreeToExp_1(w_freeFromRPSR_1),
    .o_psrDriveToExp_1(w_driveFromRPSR_1), .o_psrDataToExp_32(w_psrDataToExp_32), .i_psrFreeFromExp_1(w_freeToRPSR_1), // exp鐠囩倍sr
    
    .i_prfDriveFromWB_1(w_prfDriveFromWB_1), .i_rdAddr_8(w_prfData_40[39:32]), .i_rdDataToPrf_32(w_prfData_40[31:0]), .o_prfFreeToWB_1(w_prfFreeToWB_1),//wb閸愭獤rf
    .i_psrDriveFromWB_1(w_psrDriveFromWB_1), .i_wbnzcv_4(w_nzcv_4), .o_psrFreeToWB_1(w_psrFreeToWB_1), .i_wben_4(w_wben_4),//wb閸愭獤sr
    
    // .i_psrwDriveFromExp_1(w_driveToWPSR_1), .o_psrwFreeToExp_1(w_freeFromWPSR_1), .i_expnzcv_4(w_dataToWPSR_32[31:28]),.i_expen_4(w_expen_4) // exp閸愭獤sr
    .i_psrwDriveFromExp_1(w_driveToWPSR_1), .o_psrwFreeToExp_1(w_freeFromWPSR_1), .i_expnzcv_4(w_dataToWPSR_32[31:28]),.i_expen_4(4'b1111) // exp閸愭獤sr
    
  );



// 淇″彿婧愭浛鎹紝by xyp锛屼慨璁簬2025/1/2
/**************************************/
// 鏉ヨ嚜鍙栧€肩殑浜嬩欢
  wire w_driveFromIf_xyp;
  wire w_freeToIf_xyp;
  
  wire w_dirveToDecSelector_xyp, w_dirveToExeSelector_xyp, w_dirveToLsuSelector_xyp;
  wire w_freeFromDecSelector_xyp, w_freeFromExeSelector_xyp, w_freeFromLsuSelector_xyp;
  
  wire w_decReq_xyp, w_exeReq_xyp, w_lsuReq_xyp;
  
  wire w_driveToDecMutexMerge_xyp, w_driveToExeMutexMerge_xyp, w_driveToLsuMutexMerge_xyp;
  wire w_freeFromDecMutexMerge_xyp, w_freeFromExeMutexMerge_xyp, w_freeFromLsuMutexMerge_xyp;
  
  // 鑷锟�??????
  wire w_driveToFreeDec0_xyp, w_driveToFreeExe0_xyp, w_driveToFreeLsu0_xyp;
  wire w_driveToFreeDec1_xyp, w_driveToFreeExe1_xyp, w_driveToFreeLsu1_xyp;
  
  wire w_driveToDecMM_xyp, w_driveToExeMM_xyp, w_driveToLsuMM_xyp;
  wire w_freeFromDecMM_xyp, w_freeFromExeMM_xyp, w_freeFromLsuMM_xyp;


  wire w_decMutexDriveToFifo_1,w_decMutexFreeFromFifo_1;
  wire w_exeMutexDriveToFifo_1,w_exeMutexFreeFromFifo_1;
  wire w_lsuMutexDriveToFifo_1,w_lsuMutexFreeFromFifo_1;
  wire [35:0] w_decTmp_36,w_exeTmp_36,w_lsuTmp_36;

  
  // 鍘诲線涓柇寮傚父鐨勪簨锟�??????
  // wire w_driveDecToInt_xyp, w_driveExeToInt_xyp, w_driveLsuToInt_xyp;
  // wire w_freeIntToDec_xyp, w_freeIntToExe_xyp, w_freeIntToLsu_xyp;
  // wire [35:0] w_decExcNew_36, w_exeExcNew_36, w_lsuExcNew_36;
  
reg r_exeExc_1;
wire w_exeExc_1;
  // 浜嬩欢鍒嗘祦
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
    // 浜嬩欢浜掓枼
//   wire w_a_1,w_b_1;
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_36b_xyp  ifExcMutex (
//       .i_drive0                ( w_ifDrv2IfExcMutex      ),                 // 鏉ヨ嚜dec妯″潡
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
//     // 浜嬩欢浜掓枼
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_37b_xyp  ifIntMutex (
//       .i_drive0                ( w_ifDrv2IfIntMutex      ),                 // 鏉ヨ嚜dec妯″潡
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

//   // 浜嬩欢鎷╄矾 Dec
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cSelector2_1b_xyp  u0_cSelector2_1b_xyp (
//       .i_drive                 ( w_dirveToDecSelector_xyp        ),
//       .i_freeNext0             ( w_freeFromDecMutexMerge_xyp     ),
//       .i_freeNext1             ( w_driveToFreeDec1_xyp           ),
//       .rst                     ( rst                             ),
//       .i_data                  ( w_decReq_xyp                    ), // 1璧皐_driveToDecMutexMerge_xyp
  
//       .o_free                  ( w_freeFromDecSelector_xyp       ),
//       .o_driveNext0            ( w_driveToDecMutexMerge_xyp      ),
//       .o_driveNext1            ( w_driveToFreeDec0_xyp           )
//   );
//   (* dont_touch="true" *)delay1Unit outdelay0_xyp (.inR(w_driveToFreeDec0_xyp), .outR(w_driveToFreeDec1_xyp), .rst(rst));
  
//   // 浜嬩欢浜掓枼
//   wire w_decDriveToExcMutexMerge1_1;
//   (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
//   cMutexMerge2_36b_xyp  u0_cMutexMerge2_36b_xyp (
//       .i_drive0                ( w_decDriveToExcMutexMerge1_1      ),                 // 鏉ヨ嚜dec妯″潡
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
  
  // 浜嬩欢鎷╄矾 Exe
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cSelector2_1b_xyp  u1_cSelector2_1b_xyp (
      .i_drive                 ( w_dirveToExeSelector_xyp        ),
      .i_freeNext0             ( w_freeFromExeMutexMerge_xyp     ),
      .i_freeNext1             ( w_driveToFreeExe1_xyp           ),
      .rst                     ( rst                             ),
      .i_data                  ( w_exeReq_xyp                    ), // 1璧皐_driveToExeMutexMerge_xyp
  
      .o_free                  ( w_freeFromExeSelector_xyp       ),
      .o_driveNext0            ( w_driveToExeMutexMerge_xyp      ),
      .o_driveNext1            ( w_driveToFreeExe0_xyp           )
  );
  (* dont_touch="true" *)delay1Unit outdelay1_xyp (.inR(w_driveToFreeExe0_xyp), .outR(w_driveToFreeExe1_xyp), .rst(rst));
  
  // 浜嬩欢浜掓枼
  wire w_exeDriveToExcMutexMerge1_1;
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cMutexMerge2_36b_xyp  u1_cMutexMerge2_36b_xyp (
      .i_drive0                ( w_exeDriveToExcMutexMerge_1      ),                  // 鏉ヨ嚜exe妯″潡        
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
  
  // 浜嬩欢鎷╄矾 Lsu
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cSelector2_1b_xyp  u2_cSelector2_1b_xyp (
      .i_drive                 ( w_dirveToLsuSelector_xyp        ),
      .i_freeNext0             ( w_freeFromLsuMutexMerge_xyp     ),
      .i_freeNext1             ( w_driveToFreeLsu1_xyp           ),
      .rst                     ( rst                             ),
      .i_data                  ( w_lsuReq_xyp                    ), // 1璧皐_driveToLsuMutexMerge_xyp
  
      .o_free                  ( w_freeFromLsuSelector_xyp       ),
      .o_driveNext0            ( w_driveToLsuMutexMerge_xyp      ),
      .o_driveNext1            ( w_driveToFreeLsu0_xyp           )
  );
  (* dont_touch="true" *)delay1Unit outdelay2_xyp (.inR(w_driveToFreeLsu0_xyp), .outR(w_driveToFreeLsu1_xyp), .rst(rst));
  
  // 浜嬩欢浜掓枼
  wire w_lsuDriveToExcMutexMerge1_1;
  (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
  cMutexMerge2_36b_xyp  u2_cMutexMerge2_36b_xyp (
      .i_drive0                ( w_lsuDriveToExcMutexMerge1_1      ),                  // 鏉ヨ嚜lsu妯″潡  
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
