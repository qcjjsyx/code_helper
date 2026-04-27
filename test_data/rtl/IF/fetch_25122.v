`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/14 09:37:36
// Design Name: 
// Module Name: fetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ROM_ADDR_START      32'h00000000
`define ROM_ADDR_END        32'h00000FFF
`define ICache_ADDR_START   32'h00001200
`define ICache_ADDR_END     32'h00021200
`define FetchErrCode        4'b0100
`define FetchErrCode_2      4'b0010
`define InterruptCode       5'b01010
module fetch(
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst,
    // from dispatch/event source for first fetch
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFdispatch,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2dispatch,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [31:0] i_pcFdispatch_32, 

    // from jump/mem/error
    // merged in the top
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFTop,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2Top,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [31:0] i_pcFTop_32, 
    
    // from Icache
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFICache,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2ICache,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [63:0] i_inst_64,

    // to Icache
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2ICache,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFICache,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_fetchAddr_32,
    
    // to Decode
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Dec,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFDec,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [65:0] o_instAndPC_66,

    // to exception
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Excp,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  i_freeFExcp,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [3:0] o_exceptionF_2_4,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Excp_2,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFExcp_2,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [3:0] o_exceptionF_4,

    //to Interrupt
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [5:0]i_interrupt,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Int,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFInt,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [5:0] o_InterruptF_6,

    input i_isInInt
    ); 


    //-------------- from dispatch --------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvDisp2cfifo0,w_freeDispFcfifo0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvDisp2Err,w_freeDispFErr;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_PC2Inst,w_PC2Err;
    // 判断是否存在异常：如果PC太大或者太�???
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_PCErr; 
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_unlockMode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo10;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fireUnlockMode = w_firefifo10[0] | w_firefifo10[2]; 
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_cfifo5Fire_1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0]w_instCount;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_inst0PC_32,w_inst1PC_32,w_inst2PC_32,w_inst3PC_32;
       
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_freeFcfifo1,w_drv2cfifo1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_basePC_32;
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [63:0] w_inst_64;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [32:0] w_inst0_33,w_inst1_33,w_inst2_33,w_inst3_33;
    
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_intExcpBranchValid;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2selc0,w_freeFselc0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_cfifo6Fire_3;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2merge1,w_freeFmerge1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_cfifo7Fire_3;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_dispatchMode,r_errJumpMode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_split1drv2Excp,w_split1freeFExcp;
    
    //Fifo9 is to set the condition for fetch for 2second time in case the first fetch get nothing
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvCfifo92merge1,w_freeCfifo9Fmerge1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0]w_fireSecondFetch;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_SecondFetchMode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fireSecondFetchModeSet = w_fireSecondFetch[0] | w_fireSecondFetch[2];
    
    (*dont_touch = "yes"*)wire w_fireJudegeMode = w_cfifo6Fire_3[1] | w_cfifo7Fire_3[1] | w_fireSecondFetch[1]; 

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_jumpErrMode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_jumpErrFire = w_cfifo7Fire_3[1] | w_cfifo5Fire_1;
    
    (*dont_touch = "yes"*)wire w_drvfifo32merge1,w_freecfifo3Fmerge1;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [2:0] r_curNum;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0]w_fireCfifo0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select1,w_freeFselect1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2split0,w_freeFsplit0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2merge0,w_freeFmerge0;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [64:0] w_data2split0;  
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvselect42cfifo9,w_freeselect4Fcfifo9;
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_PCreFetch_32;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_normNextPc_32;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvMerge12cfifo8,w_freeMerge1Fcfifo8;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvCfifo82Split1,w_freeCfifo8FSplit1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_firePCErrCFifo8;
    //-------------- from dispatch --------------//
    // give interrupt handel module
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSpliter22Select0,w_freeSpliter2FSelect0;
    
    wire w_drv2spliter3,w_freeFspliter3;
    wire [64:0] w_data2spliter3_65;
    wire w_drvSpliter32Excp,w_freeSpliter3FExcp;
    wire w_drv2Spliter4,w_freeFSpliter4;
    wire w_drvSpliter42Excp,w_freeSpliter4FExcp;
    wire w_spliter2Drv2MergeInt,w_spliter2FreeFMergeInt;

    assign o_exceptionF_4 = (r_PCErr) ? `FetchErrCode : 4'b1111;
    wire w_bx = (o_instAndPC_66[15:10]==6'b010001) &  (o_instAndPC_66[9:8]==2'b11) &  (o_instAndPC_66[7]==1'b0);
    assign o_exceptionF_2_4 = (i_isInInt & o_instAndPC_66[32]==1'b0 & w_bx) ? `FetchErrCode_2 : 4'b1111;
    //----------------取指去异常的第二�??-----------------//
    wire w_drv2Dec,w_freeFDec;
    cSplitter2_1b_fetch spliter_err_2 (
    .i_drive(w_drv2Dec),
    .i_data_1(1'b0),
    .o_free(w_freeFDec),
    .o_driveNext0(o_drv2Dec),
    .i_freeNext0(i_freeFDec),
    .o_data0_1(),
    .o_driveNext1(o_drv2Excp_2),
    .o_data1_1(),
    .i_freeNext1(i_freeFExcp_2),
    .rst(rst)
    );

    cSplitter2_1b_fetch spliter2 (
    .i_drive(w_drv2selc0),
    .i_data_1(1'b0),
    .o_free(w_freeFselc0),
    .o_driveNext0(w_drvSpliter22Select0),
    .i_freeNext0(w_freeSpliter2FSelect0),
    .o_data0_1(),
    .o_driveNext1(w_spliter2Drv2MergeInt),
    .o_data1_1(),
    .i_freeNext1(w_spliter2FreeFMergeInt),
    .rst(rst)
    );

    //1/13 zwm 
    reg [5:0] r_InterruptF_6;
    wire w_intFire_1;
    wire w_drv2MergeInt,w_freeFMergeInt;
    assign w_intFire_1 = w_drv2MergeInt | w_spliter2Drv2MergeInt;
    always @(posedge w_intFire_1 or negedge rst) begin
        if(!rst)begin
            r_InterruptF_6 <= 6'b0;
        end else begin
            r_InterruptF_6 <= i_interrupt;
        end
        
    end
    assign o_InterruptF_6 = r_InterruptF_6;

    // (re)start the pipeline
    // 实例�??? cSelector2_33b 模块

    // 如果没有异常就去读取指令缓存，否则去异常模块
    cSelector2_33b_fetch select0 (
        .i_drive(w_drvSpliter22Select0),
        .i_data_33({~r_PCErr,i_pcFdispatch_32}),
        .o_free(w_freeSpliter2FSelect0),

        .o_driveNext0(w_drvDisp2cfifo0),
        .i_freeNext0(w_freeDispFcfifo0),
        .o_data0_32(w_PC2Inst),

        .o_driveNext1(w_drvDisp2Err),
        .o_data1_32(w_PC2Err),
        .i_freeNext1(w_freeDispFErr),

        .rst(rst)
    );
    
    /*
    * 本部分用于区分，这次取指是由谁触发：①中�???/异常/跳转 ②分派和第一次取�???
    * 如果是①则再指令拆分的时候不需要考虑之前的状态，否则需要�?
    * 注：参考架构图:cfifo7三个fire，中间的fire[1]两个作用，一方面是和cfifo6一起用于给指令分割模块确定本轮指令是否为异常跳转，一方面给读指令（curCount的修改）确定是否需要再往后面给一条指�???
    */
    //!!!!!!!!!!这里的逻辑后续改一下！！！！！！！！！�??//
    //不要用延迟去卡了，如果触发取指的话就限制新一轮的i_drive进来就行
    //↑上面的问题已修改！�??

    //去访问Icache时锁上，访问回来解锁
    reg visit_Icache_Lock;
    wire w_drvFdispatch,w_free2dispatch;
    cPmtFifo1 pmtLock (
        .rst(rst),
        .i_drive(i_drvFdispatch),
        .o_free(o_free2dispatch),
        .pmt(visit_Icache_Lock),
        .o_driveNext(w_drvFdispatch),
        .i_freeNext(w_free2dispatch)
    );

    cFifo3_fetch cfifo6(
    .i_drive(w_drvFdispatch),
    .o_free(w_free2dispatch),
    .i_freeNext(w_freeFselc0),
    .o_driveNext(w_drv2selc0),
    .o_fire_3(w_cfifo6Fire_3),
    .rst(rst)
    );

    wire w_cFifo7Drv2Spliter5,w_cFifo7FreeFSpliter5;
    cFifo3_fetch cfifo7(
    .i_drive(i_drvFTop),
    .o_free(o_free2Top),
    .i_freeNext(w_cFifo7FreeFSpliter5),
    .o_driveNext(w_cFifo7Drv2Spliter5),
    .o_fire_3(w_cfifo7Fire_3),
    .rst(rst)
    );

//1/5 zwm 
//this add spliter5

    cSplitter2_65b_fetch spliter5 (
        .i_drive        (w_cFifo7Drv2Spliter5),
        .i_data_65      (65'b0),
        .o_free         (w_cFifo7FreeFSpliter5),
        .o_driveNext0   (w_drvfifo32merge1),
        .i_freeNext0    (w_freecfifo3Fmerge1),
        .o_data0_65     (),
        .o_driveNext1   (w_drv2MergeInt),
        .o_data1_65     (),
        .i_freeNext1    (w_freeFMergeInt),
        .rst            (rst)
        );


    reg[31:0] r_pcFTop_32;
    always @(negedge w_cfifo7Fire_3[1] or negedge rst ) begin
        if(!rst)begin
            r_pcFTop_32 <=0;
        end
        else begin
            r_pcFTop_32 <= i_pcFTop_32;
        end
    end

    always@(posedge w_jumpErrFire or negedge rst )begin
        if(!rst)begin
            r_jumpErrMode <= 0;
        end
        else begin
            r_jumpErrMode <= ~r_jumpErrMode;
        end
    end

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_dispatchMode = w_cfifo6Fire_3[0] | w_cfifo6Fire_3[2];
    always@(posedge  w_dispatchMode or negedge rst)begin
        if(!rst)begin
            r_dispatchMode <= 0;
        end
        else begin
            r_dispatchMode <= ~r_dispatchMode;
        end
    end
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_errJumpFire = w_cfifo7Fire_3[0]|w_cfifo7Fire_3[2];
    always@(posedge w_errJumpFire or negedge rst)begin
        if(!rst)begin
            r_errJumpMode <= 0;
        end
        else begin
            r_errJumpMode <= ~r_errJumpMode;
        end
    end

    always@(posedge w_fireJudegeMode or negedge rst)begin
        if(!rst)begin
            r_intExcpBranchValid <= 0;
        end
        else if(r_dispatchMode) begin
            r_intExcpBranchValid <= 0;
        end
        else if(r_SecondFetchMode)begin
            r_intExcpBranchValid <= 0;
        end
        else begin
            r_intExcpBranchValid <= 1;
        end
    end

    //-------------- read from instCache(add curNum)读指令缓�???-------------//
    /*
    * 读指令缓存通过累加curNum实现，curNum从[0,instCount],含义是：当前需要出去的是第几条指令�???0是初状态无意义，大�???4后也无意�???
    * 如果一开始instCount=0，则select1走下面的路；否则走上�???
    * 对spliter0：上下路会同时走
    * 对selct2�???
    * 如果curNum<instCount则取出对应的指令，走通路�???
    * 如果curNum=instCount取出指令并向后传递驱动下一次取指，走通路�???
    */
    
    cFifo3_fetch cfifo0(
    .i_drive(w_drvDisp2cfifo0),
    .o_free(w_freeDispFcfifo0),
    .i_freeNext(w_freeFselect1),
    .o_driveNext(w_drv2select1),
    .o_fire_3(w_fireCfifo0),
    .rst(rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_readInstPC,r_writeInstPC;

    

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_readInstFire = w_fireCfifo0[0] | w_fireCfifo0[2];
    always@(posedge  w_readInstFire  or negedge rst)begin
        if(!rst)begin
            r_readInstPC <= 0;
        end
        else begin
            r_readInstPC <= ~r_readInstPC;
        end
    end


    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [64:0] w_PCInst = (r_curNum==1) ? {w_inst0PC_32,w_inst0_33} : 
                            (r_curNum==2) ? {w_inst1PC_32,w_inst1_33} :
                            (r_curNum==3) ? {w_inst2PC_32,w_inst2_33} :
                            (r_curNum==4) ? {w_inst3PC_32,w_inst3_33} :
                            65'b0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_select1Mode = (w_instCount==0 || r_curNum>w_instCount) ? 1'b1:1'b0;

    cSelector2_66b_fetch select1 (
        .i_drive(w_drv2select1),
        .i_data_66({~w_select1Mode,w_PCInst}),
        .o_free(w_freeFselect1),

        .o_driveNext0(w_drv2split0),
        .i_freeNext0(w_freeFsplit0),
        .o_data0_65(w_data2split0),

        .o_driveNext1(w_drv2merge0),
        .o_data1_65(),
        .i_freeNext1(w_freeFmerge0),

        .rst(rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2merge2,w_freeFmerge2;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select2,w_freeFselect2;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [64:0] w_data2merge2;

    cSplitter2_65b_fetch spliter0 (
    .i_drive(w_drv2split0),
    .i_data_65(w_data2split0),
    .o_free(w_freeFsplit0),
    .o_driveNext0(w_drv2merge2),
    .i_freeNext0(w_freeFmerge2),
    .o_data0_65(w_data2merge2),
    .o_driveNext1(w_drv2select2),
    .o_data1_65(),
    .i_freeNext1(w_freeFselect2),
    .rst(rst)
    );
    
    // cSplitter2_65b_fetch spliter3 (
    // .i_drive        (w_drv2spliter3),
    // .i_data_65      (w_data2spliter3_65),
    // .o_free         (w_freeFspliter3),
    // .o_driveNext0   (w_drvSpliter32Excp),
    // .i_freeNext0    (w_freeSpliter3FExcp),
    // .o_data0_65     (),
    // .o_driveNext1   (w_drv2merge2),
    // .o_data1_65     (w_data2merge2),
    // .i_freeNext1    (w_freeFmerge2),
    // .rst            (rst)
    // );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_over;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSplit02Merge0,w_freeSplit0FMerge0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvselect22cfifo2,w_freeselect2Fcfifo2;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire select2Mode = (r_curNum<w_instCount) ? 1'b0 : 1'b1;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_over_delay;
    delay8U delay(.inR(w_over), .outR(w_over_delay), .rst(rst));
    cSelector2_1b select2 (
        .i_drive(w_drv2select2),
        .i_data_1(~select2Mode),
        .o_free(w_freeFselect2),

        .o_driveNext0(w_drv2Spliter4),
        .i_freeNext0(w_freeFSpliter4),
        .o_data0_1(),

        .o_driveNext1(w_drvselect22cfifo2),
        .o_data1_1(),
        .i_freeNext1(w_freeselect2Fcfifo2),

        .rst(rst)
    );

    cSplitter2_1b_fetch spliter4 (
    .i_drive        (w_drv2Spliter4),
    .i_data_1       (),
    .o_free         (w_freeFSpliter4),
    .o_driveNext0   (w_over),
    .i_freeNext0    (w_over_delay),
    .o_data0_1      (),
    .o_driveNext1   (w_drvSpliter42Excp),
    .o_data1_1      (),
    .i_freeNext1    (w_freeSpliter4FExcp),
    .rst            (rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fireCfifo4;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fireCfifo2;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_lastOne;
    cFifo1 cfifo2(
    .i_drive(w_drvselect22cfifo2),
    .o_free(w_freeselect2Fcfifo2),
    .i_freeNext(w_freeSplit0FMerge0),
    .o_driveNext(w_drvSplit02Merge0),
    .o_fire_1(w_fireCfifo2),
    .rst(rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_lastOneFire =  w_fireCfifo2 |w_fireCfifo4;
    always@(posedge w_lastOneFire or negedge rst)begin
        if(!rst)begin
            r_lastOne <= 0;
        end
        else begin
            r_lastOne <= ~r_lastOne; 
        end
    end

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvMerge02Merge1,w_freeMerge0FMerge1;


    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_datamerge02merge1;

    // if this is the first time to fetch, we should use the pc from outside
    cMutexMerge2_32b_launch merge0 (
        .i_drive0(w_drvSplit02Merge0),
        .i_data0_32(w_normNextPc_32),
        .o_free0(w_freeSplit0FMerge0),
        .i_drive1(w_drv2merge0),
        .i_data1_32(i_pcFdispatch_32),
        .o_free1(w_freeFmerge0),
        .i_freeNext(w_freeMerge0FMerge1),
        .o_driveNext(w_drvMerge02Merge1),
        .o_data_32(w_datamerge02merge1),
        .rst(rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_dataMerge1;
    cMutexMerge3_32b_launch merge1 (
        .i_drive0(w_drvMerge02Merge1),
        .i_data0_32(w_datamerge02merge1),
        .o_free0(w_freeMerge0FMerge1),
        .i_drive1(w_drvfifo32merge1),
        .i_data1_32(r_pcFTop_32),
        .o_free1(w_freecfifo3Fmerge1),

        .i_drive2(w_drvCfifo92merge1),
        .i_data2_32(w_normNextPc_32),
        .o_free2(w_freeCfifo9Fmerge1),

        .i_freeNext(w_freeMerge1Fcfifo8),
        .o_driveNext(w_drvMerge12cfifo8),
        .o_data_32(w_dataMerge1),
        .rst(rst)
    );
    // the drv of cfifo8_saveMergeData is too early than data
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvMerge12cfifo8_delay,w_drvMerge12cfifo8_delay_2;
    delay4U delayfifo8(.inR(w_drvMerge12cfifo8), .outR(w_drvMerge12cfifo8_delay), .rst(rst));
    delay6U delayfifo8_2(.inR(w_drvMerge12cfifo8_delay), .outR(w_drvMerge12cfifo8_delay_2), .rst(rst));

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSplit12select5,w_freeSplit1Fselect5;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvFifo8save,w_freeFifo8save;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] w_dataMerge1Save;
    // this fifo is to save the data 
    cFifo1_32b_fetch cfifo8_saveMerge1Data(
    .i_drive(w_drvMerge12cfifo8_delay_2),
    .o_free(w_freeMerge1Fcfifo8),
    .i_data_32(w_dataMerge1),
    .i_freeNext(w_freeFifo8save),
    .o_driveNext(w_drvFifo8save),
    .o_data_32(w_dataMerge1Save),
    .rst(rst)    
    );
    // this fifo is a part to raise fetch exception

    wire w_drvCfifo82Select5,w_freeCfifo8FSelect5;
    cFifo1 cfifo8(
    .i_drive(w_drvFifo8save),
    .o_free(w_freeFifo8save),
    .i_freeNext(w_freeCfifo8FSelect5),
    .o_driveNext(w_drvCfifo82Select5),
    .o_fire_1(w_firePCErrCFifo8),
    .rst(rst)
    );
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_fetchAddr;
    always@(posedge w_firePCErrCFifo8 or negedge rst)begin
        if(!rst)begin
            r_fetchAddr <= w_normNextPc_32;
        end
        else begin 
            r_fetchAddr <= w_dataMerge1Save;
        end
    end
    assign o_fetchAddr_32 = r_fetchAddr;


    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSelect52Merge3,w_freeSelect5FMerge3;
    wire w_drv2ICache,w_freeFICache;
    cSelector2_1b select5 (
        .i_drive(w_drvCfifo82Select5),
        .i_data_1(1'b1),
        .o_free(w_freeCfifo8FSelect5),
        
        .o_driveNext0(w_drv2ICache),
        .i_freeNext0(w_freeFICache),
        .o_data0_1(),

        .o_driveNext1(w_drvSelect52Merge3),
        .o_data1_1(),
        .i_freeNext1(w_freeSelect5FMerge3),

        .rst(rst)
    );

    //使用fifo3去锁�??,在出来的fifo1内解�??
    wire w_firefifo_lock;
    cFifo1 cfifo_lock(
    .i_drive(w_drv2ICache),
    .o_free(w_freeFICache),
    .i_freeNext(i_freeFICache),
    .o_driveNext(o_drv2ICache),
    .o_fire_1(w_firefifo_lock),
    .rst(rst)
    );

    //-------------- from dispatch --------------//
    // Instantiate the instSplit module
   

    instSplit instSplit_inst (
        .rst(rst),
        .i_drvFICache(i_drvFICache),
        .o_free2ICache(o_free2ICache),
        .i_freeFMerge(w_freeFcfifo1),
        .o_drv2Merge(w_drv2cfifo1),
        .w_intExcpBranchValid(r_intExcpBranchValid),
        .i_basePC_32(o_fetchAddr_32),
        .i_inst_64(i_inst_64),
        .o_inst0_33(w_inst0_33),
        .o_inst1_33(w_inst1_33),
        .o_inst2_33(w_inst2_33),
        .o_inst3_33(w_inst3_33),
        .o_inst0PC_32(w_inst0PC_32),
        .o_inst1PC_32(w_inst1PC_32),
        .o_inst2PC_32(w_inst2PC_32),
        .o_inst3PC_32(w_inst3PC_32),
        .o_instCount(w_instCount),
        .o_normNextPc_32(w_normNextPc_32)
    );

    //-------------write Instcache(写指令缓�???)----//

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select4,w_freeFselect4;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_fireCfifo1_3;

    cFifo3_fetch cfifo1(
    .i_drive(w_drv2cfifo1),
    .o_free(w_freeFcfifo1),
    .i_freeNext(w_freeFselect4),
    .o_driveNext(w_drv2select4),
    .o_fire_3(w_fireCfifo1_3),
    .rst(rst)
    );

    //-------------取指上锁和解锁逻辑---------//
    wire w_lockFire = w_firefifo10[1] | w_firefifo_lock;
    always @(posedge w_lockFire or negedge rst) begin
        if(!rst)begin
            //最开始处于解锁状�??
            visit_Icache_Lock <= 1;
        end else begin
            if(r_unlockMode)begin
                //读完回来，解�??
                visit_Icache_Lock <= 1;
            end //出去取指令时上锁
            else begin
                visit_Icache_Lock <= 0;
            end
        end
    end

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_writeInstFire = w_fireCfifo1_3[0] | w_fireCfifo1_3[2];
    always@(posedge  w_writeInstFire or negedge rst)begin
        if(!rst)begin
            r_writeInstPC <= 0;
        end
        else begin
            r_writeInstPC <= ~r_writeInstPC;
        end
    end

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_curNumFire = w_fireCfifo0[1] | w_fireCfifo1_3[1];
    always@(posedge w_curNumFire or negedge rst)begin
        if(!rst)begin
            r_curNum <= 0;
        end else if(r_readInstPC)begin
            r_curNum <= r_curNum + 1;
        end
        // if the inst is the last in it,we refetch and dont give it out(r_curNum=0)
        // if there are no inst in it, we should give it out (r_curNum=1)
        else if(r_writeInstPC && r_lastOne)begin
            r_curNum <= 0;
        end
        else if(r_writeInstPC && ~r_lastOne)begin
            r_curNum <= 1;
        end
        else if(r_jumpErrMode)begin
            r_curNum <= 1;
        end 
        else if(r_lastOne)begin
             r_curNum <= 0;
        end
        else begin
            r_curNum <= 0;
        end
    end
    
    //如果取出的指令数量位0，需要重新取�???
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select3,w_freeFselect3;
    wire w_drv2spliter1,w_freeFspliter1;
    cSelector2_1b select4 (
    .i_drive(w_drv2select4),
    .i_data_1(~w_select1Mode),
    .o_free(w_freeFselect4),

    .o_driveNext0(w_drv2spliter1),
    .i_freeNext0(w_freeFspliter1),
    .o_data0_1(),

    .o_driveNext1(w_drvselect42cfifo9),
    .o_data1_1(),
    .i_freeNext1(w_freeselect4Fcfifo9),

    .rst(rst)
    );
    wire w_drv2fifo10,w_freeFfifo10;
    cSplitter2_1b_fetch spliter1 (
    .i_drive(w_drv2spliter1),
    .i_data_1(1'b0),
    .o_free(w_freeFspliter1),
    .o_driveNext0(w_split1drv2Excp),
    .i_freeNext0(w_split1freeFExcp),
    .o_data0_1(),
    .o_driveNext1(w_drv2fifo10),
    .o_data1_1(),
    .i_freeNext1(w_freeFfifo10),
    .rst(rst)
    );
    
    cFifo3_fetch cfifo10(
        .i_drive    (w_drv2fifo10),
        .o_free     (w_freeFfifo10),
        .i_freeNext (w_freeFselect3),
        .o_driveNext(w_drv2select3),
        .o_fire_3   (w_firefifo10),
        .rst        (rst)
        );
    
    always @(posedge w_fireUnlockMode or negedge rst) begin
        if(!rst)begin
            r_unlockMode <=0;
        end
        else begin
            r_unlockMode <= ~r_unlockMode;
        end
    end
    always@(posedge w_fireSecondFetchModeSet or negedge rst)begin
        if(!rst)begin
            r_SecondFetchMode<=0;
        end
        else begin
            r_SecondFetchMode<=~r_SecondFetchMode;
        end
    end

    cFifo3_fetch cfifo9(
    .i_drive(w_drvselect42cfifo9),
    .o_free(w_freeselect4Fcfifo9),
    .i_freeNext(w_freeCfifo9Fmerge1),
    .o_driveNext(w_drvCfifo92merge1),
    .o_fire_3(w_fireSecondFetch),
    .rst(rst)
    );


    (*dont_touch = "yes"*)wire w_cfifo4Over;
    (*dont_touch = "yes"*)wire w_drvselect32mcfifo5,w_freeselect3Fcfifo5;
    (*dont_touch = "yes"*)wire w_drvcfifo52merge2,w_freecfifo5Fmerge2;
    
    (*dont_touch = "yes"*)wire w_drvselect32cfifo4,w_freeselect3Fcfifo4;

    //如果r_lastOne�???1，则本次不需要给出指令，目前指令还是有一个在后面第二级流水运行的
    cSelector2_1b select3 (
    .i_drive(w_drv2select3),
    .i_data_1(~r_lastOne),
    .o_free(w_freeFselect3),

    .o_driveNext0(w_drvselect32mcfifo5),
    .i_freeNext0(w_freeselect3Fcfifo5),
    .o_data0_1(),

    .o_driveNext1(w_drvselect32cfifo4),
    .o_data1_1(),
    .i_freeNext1(w_freeselect3Fcfifo4),

    .rst(rst)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_cfifo4Over_delay;
    delay4U delayfifo4(.inR(w_cfifo4Over), .outR(w_cfifo4Over_delay), .rst(rst));

    cFifo1 cfifo4(
    .i_drive(w_drvselect32cfifo4),
    .o_free(w_freeselect3Fcfifo4),
    .i_freeNext(w_cfifo4Over_delay),
    .o_driveNext(w_cfifo4Over),
    .o_fire_1(w_fireCfifo4),
    .rst(rst)
    );

    cFifo1 cfifo5(
    .i_drive(w_drvselect32mcfifo5),
    .o_free(w_freeselect3Fcfifo5),
    .i_freeNext(w_freecfifo5Fmerge2),
    .o_driveNext(w_drvcfifo52merge2),
    .o_fire_1(w_cfifo5Fire_1),
    .rst(rst)
    );
//------------------------------------------------------------------------------------------------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvMerge22Merge3,w_freeMerge2FMerge3;
    wire [65:0] w_datamerge2;
    wire [65:0] w_instAndPC_66;
    cMutexMerge2_66b_fetch merge2 (
        .i_drive0(w_drv2merge2),
        .i_data0_66({r_PCErr,w_data2merge2}),
        .o_free0(w_freeFmerge2),
        .i_drive1(w_drvcfifo52merge2),
        .i_data1_66(w_instAndPC_66),
        .o_free1(w_freecfifo5Fmerge2),
        .i_freeNext(w_freeMerge2FMerge3),
        .o_driveNext(w_drvMerge22Merge3),
        .o_data_66(w_datamerge2),
        .rst(rst)
    );
// //1/14 zwm
//     wire w_drvMerge22Merge3Delay;
(* dont_touch="true" *)delay4U delay1(
    .inR(w_drvSelect52Merge3),
    .outR(w_freeSelect5FMerge3),
    .rst(rst)
    );
wire w_fire_1;
reg [65:0] r_instAndPC_66;
always @(posedge w_fire_1 or negedge rst) begin
    if(!rst)begin
        r_instAndPC_66 <= 66'b0;
    end else begin
        r_instAndPC_66 <= w_datamerge2;
    end
end
    assign o_instAndPC_66 = r_instAndPC_66;
    cFifo1 merge2ToSpliterErr2Fifo(
        .i_drive(w_drvMerge22Merge3), .i_freeNext(w_freeFDec), .rst(rst),
        .o_free(w_freeMerge2FMerge3), .o_driveNext(w_drv2Dec), .o_fire_1(w_fire_1));
//--------------------------------------------------------------------------------------------------------//
    // this is the mutex to Err,which can be from select0 or split1
    cMutexMerge3_32b_fetch mergeErr (
    .i_drive0(w_drvDisp2Err),
    .i_data0_32(32'b0),
    .o_free0(w_freeDispFErr),
    .i_drive1(w_split1drv2Excp),
    .i_data1_32(32'b0),
    .o_free1(w_split1freeFExcp),

    // .i_drive2(w_drvSpliter32Excp),
    // .i_data2_32(32'b0),
    // .o_free2(w_freeSpliter3FExcp),
    .i_drive2(w_drvSpliter42Excp),
    .i_data2_32(32'b0),
    .o_free2(w_freeSpliter4FExcp),
    .i_freeNext(i_freeFExcp),
    .o_driveNext(o_drv2Excp),
    .o_data_32(),
    .rst(rst)
    );

    //1/5 zwm 
    // this is the mutex to Int,which can be from select0 or split1
    cArbMerge2_105b_cpu mergeInt (
        .i_drive_2({w_drv2MergeInt,w_spliter2Drv2MergeInt}),
        .i_data0(105'b0),
        .o_free_2({w_freeFMergeInt,w_spliter2FreeFMergeInt}),
        .i_data1(105'b0),
        .i_freeNext(i_freeFInt),
        .o_driveNext(o_drv2Int),
        .o_data(),
        .rst(rst)
    );

    assign w_instAndPC_66 = (r_curNum==1) ? {r_PCErr,w_inst0PC_32,w_inst0_33} :
                            (r_curNum==2) ? {r_PCErr,w_inst1PC_32,w_inst1_33} :
                            (r_curNum==3) ? {r_PCErr,w_inst2PC_32,w_inst2_33} :
                            (r_curNum==4) ? {r_PCErr,w_inst3PC_32,w_inst3_33} :
                            65'b0;

    // this part is to define when a PC to fetch hasn err
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_firePCErr = w_cfifo6Fire_3[1] | w_firePCErrCFifo8;
    // always@(posedge w_firePCErr or negedge rst)begin
    //     if(!rst)begin
    //         r_PCErr <= 0; 
    //     end
    //     else if(r_dispatchMode && 
    //         ((i_pcFdispatch_32>`ROM_ADDR_END && i_pcFdispatch_32 < `ICache_ADDR_START)
    //             || i_pcFdispatch_32>`ICache_ADDR_END))begin
    //         r_PCErr <= 1; 
    //     end
    //     else if(!r_dispatchMode && 
    //         ((o_fetchAddr_32>`ROM_ADDR_END && o_fetchAddr_32 < `ICache_ADDR_START)
    //             || o_fetchAddr_32>`ICache_ADDR_END))begin
    //         r_PCErr <= 1; 
    //     end
    //     else begin
    //         r_PCErr <= 0; 
    //     end
    // end 
        always@(posedge w_firePCErr or negedge rst)begin
            if(!rst)begin
                r_PCErr <= 0; 
            end
            else if(r_dispatchMode && 
                ((i_pcFdispatch_32>`ROM_ADDR_END && i_pcFdispatch_32 < `ICache_ADDR_START)
                    || i_pcFdispatch_32>`ICache_ADDR_END))begin
                r_PCErr <= 1; 
            end
            else if(!r_dispatchMode && 
                ((i_pcFTop_32>`ROM_ADDR_END && i_pcFTop_32 < `ICache_ADDR_START)
                    || i_pcFTop_32>`ICache_ADDR_END))begin
                r_PCErr <= 1; 
            end
            else begin
                r_PCErr <= 0; 
            end
        end 

endmodule
