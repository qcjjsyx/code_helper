//-----------------------------------------------
//    module name: socmem
//    author: lu.yihua
//    version: 1st version (2024-10-17)
//    description: 
//    to realise rom write Icache, 
//    when init: LSU need to write Icache and Dcache, and IF only read from ROM
//    so I add some selector logic.
//-----------------------------------------------
`timescale 1ns / 1ps

module socmem(
    input  wire        		rst,
    input  wire        		clk,
    input  wire             UART_INIT_SEL,
    
    input  wire			    i_driveFrmIf,       
    output wire			    o_freeToIf,          
    
    output wire		        o_driveNextToIf,     
    input  wire		        i_freeNextFrmIf,     
    
    // ICache: data_width 64bit
    input  wire 	[ 7:0] 	i_iwen_8,
    input  wire 	[31:0] 	i_iaddress_32,
    input  wire 	[63:0] 	i_idataW_64,
    output wire 	[63:0] 	o_idataR_64,
    
    input  wire			    i_driveFrmLsu,       
    output wire			    o_freeToLsu,        
    
    output wire		        o_driveNextToLsu,     
    input  wire		        i_freeNextFrmLsu,     
    // DCache: data_width 64bit
    input  wire 	[ 7:0] 	i_dwen_8,          
    input  wire 	[31:0] 	i_daddress_32, 
    input  wire 	[63:0] 	i_ddataW_64,  
    output wire 	[63:0] 	o_ddataR_64,

	input	wire	        init_sig
    );
    //---------------取指路由锁定----------//
    wire w_driveFrmIf,w_freeToIf;
    wire w_firelock;
    cFifo1 fifolockIF (
        .rst          (rst),
        .i_drive      (i_driveFrmIf),
        .o_free       (o_freeToIf),
        .o_driveNext  (w_driveFrmIf),
        .i_freeNext   (w_freeToIf),
        .o_fire_1     (w_firelock)
    );
    reg if_routeSelect;
    reg  [103:0] r_IFinfo_lock;
    wire [103:0] w_IFInfo_lock = r_IFinfo_lock;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            r_IFinfo_lock   <= 0;
            if_routeSelect  <= 0;
        end
        else begin
            if_routeSelect  <= (i_iaddress_32>=32'h00001200);
            r_IFinfo_lock   <= {i_iwen_8,i_iaddress_32,i_idataW_64};
        end
    end

    //----------------取指拆分------------//
    wire w_drv2Select0,w_freeFSelect0;
    wire w_drv2NextIf,w_freeFNextFrmLsu;
    wire [103:0] w_IFinfo;
    //8 bit wen+ 32bit addr+ 64bit data=104bit
    cSplitter2_104b_socmem split1 (
        .rst            (rst),
        .i_drive        (w_driveFrmIf       ),
        .o_free         (w_freeToIf         ),
        .i_data_104     (w_IFInfo_lock      ),
        .o_driveNext0   (w_drv2Select0      ),
        .o_driveNext1   (w_drv2NextIf       ),
        .i_freeNext0    (w_freeFSelect0     ),
        .i_freeNext1    (i_freeNextFrmIf    ),
        .o_data0_104    (w_IFinfo           )
    );

    wire w_drvIF2mutexIcache,w_freeIFFmutexIcache;
    wire w_drvIF2fifoROM,w_freeIFFfifoROM;
    delay2U delay_ROM (.inR(w_drvIF2fifoROM), .outR(w_freeIFFfifoROM),.rst(rst));
    wire [103:0] w_infoIF2mutexIcache,w_infoROM;
    cSelector2_104b_socmem select0 (
        .rst            (rst                ),
        .i_drive        (w_drv2Select0      ),
        .o_free         (w_freeFSelect0     ),
        .i_data_104     (w_IFinfo           ),
        .o_driveNext0   (w_drvIF2mutexIcache),
        .o_driveNext1   (w_drvIF2fifoROM    ),
        .i_freeNext0    (w_freeIFFmutexIcache),
        .i_freeNext1    (w_freeIFFfifoROM   ),
        .o_data0_104    (w_infoIF2mutexIcache),
        .o_data1_104    (w_infoROM          )
    );
 
    //----------------LSU拆分-------------//
    wire w_drv2Select1,w_freeFSelect1;
    wire w_driveNextToLsu,w_freeNextFrmLsu;
    wire [103:0] w_LSUinfo;
    //8 bit wen+ 32bit addr+ 64bit data=104bit
    cSplitter2_104b_socmem split0 (
        .rst            (rst                ),
        .i_drive        (i_driveFrmLsu      ),
        .o_free         (o_freeToLsu        ),
        .i_data_104     ({i_dwen_8,i_daddress_32,i_ddataW_64}),
        .o_driveNext0   (w_drv2Select1      ),
        .o_driveNext1   (w_driveNextToLsu   ),
        .i_freeNext0    (w_freeFSelect1     ),
        .i_freeNext1    (w_freeNextFrmLsu   ),
        .o_data0_104    (w_LSUinfo          )
    );

    wire w_drvLSU2mutexIcache,w_freeLSUFmutexIcache;
    wire w_drvLSU2fifoDcache,w_freeLSUFfifoDcache;
    wire w_drvLSU2fifoStack,w_freeLSUFfifoStack;
    wire [103:0] w_infoLSU2mutexIcache,w_infoDcache,w_infoStack;
    cSelector3_104b_socmem select1 (
        .rst            (rst                    ),
        .i_drive        (w_drv2Select1          ),
        .o_free         (w_freeFSelect1         ),
        .i_data_104     (w_LSUinfo              ),
        .o_driveNext0   (w_drvLSU2mutexIcache   ),
        .o_driveNext1   (w_drvLSU2fifoDcache    ),
        .o_driveNext2   (w_drvLSU2fifoStack     ),
        .i_freeNext0    (w_freeLSUFmutexIcache  ),
        .i_freeNext1    (w_freeLSUFfifoDcache   ),
        .i_freeNext2    (w_freeLSUFfifoStack    ),
        .o_data0_104    (w_infoLSU2mutexIcache  ),
        .o_data1_104    (w_infoDcache           ),
        .o_data2_104    (w_infoStack            )
    );

    //---------------Icache数据聚合----------//
    wire w_drive2fifoIcache,w_freeFfifoIcache;
    wire [103:0] w_info2IcacheFifo;
    cMutexMerge2_104b_socmem mutexIcache (
        .rst            (rst                    ),
        .i_drive0       (w_drvIF2mutexIcache    ),
        .i_drive1       (w_drvLSU2mutexIcache   ),
        .o_free0        (w_freeIFFmutexIcache   ),
        .o_free1        (w_freeLSUFmutexIcache  ),
        .i_data0_104    (w_infoIF2mutexIcache   ),
        .i_data1_104    (w_infoLSU2mutexIcache  ),
        .o_driveNext    (w_drive2fifoIcache     ),
        .i_freeNext     (w_freeFfifoIcache      ),
        .o_data_104     (w_info2IcacheFifo      )
    );

    wire [1:0] w_fireIf;
    wire w_cfifoIcache_end,w_cfifoIcache_end_delay;
    delay2U delay_IcacheFifo (.inR(w_cfifoIcache_end), .outR(w_cfifoIcache_end_delay),.rst(rst));
    cFifo2_socmem cFifo2_Icache(
        .i_drive        ( w_drive2fifoIcache    ),
        .o_free         ( w_freeFfifoIcache     ),
        .o_fire_2       ( w_fireIf              ),
        .rst            ( rst                   ),  
        .o_driveNext    ( w_cfifoIcache_end     ),
        .i_freeNext     ( w_cfifoIcache_end_delay)
    );

    reg [ 7:0] r_icacheEn;
    reg [31:0] r_icacheAddr;
    reg [63:0] r_icacheData;
    always @(negedge w_fireIf[0] or negedge rst ) begin
        if(!rst)begin
            r_icacheEn      <= 0;
            r_icacheAddr    <= 0;
            r_icacheData    <= 0;
        end 
        else begin
            r_icacheEn      <= w_info2IcacheFifo[103:96];
            r_icacheAddr    <= w_info2IcacheFifo[ 95:64]-32'h00001200;
            r_icacheData    <= w_info2IcacheFifo[ 63: 0];
        end
    end
    //--------------------ICache操作逻辑-----------//
    wire icache_Trig;
    CKMUX2M4HM	icachemux(.S(init_sig),.A(w_fireIf[1]),.B(clk),.Z(icache_Trig));
    wire [ 7:0] w_icacheEn  = (init_sig) ? i_iwen_8                   : r_icacheEn;
    wire [31:0] w_icacheAddr= (init_sig) ? i_iaddress_32-32'h00001200 : r_icacheAddr;
    wire [63:0] w_icacheData= (init_sig) ? i_idataW_64                : r_icacheData;

    wire [63:0] w_icacheDataOut,w_ROMDataOut;
    sram_128k  ICache (
        .i_addr_14               ( w_icacheAddr[13:0]   ),
        .i_data_64               ( w_icacheData         ),
        .i_sramTrig              ( icache_Trig          ), 
        .i_WEB_8                 ( w_icacheEn           ), 
        .o_data_64               ( w_icacheDataOut      )
    );
    ROM ROM(
        .clk                    ( w_fireIf[1]           ),
        .rst                    ( rst                   ),
        .i_addr                 ( w_icacheAddr[11:0]    ),
        .o_data                 ( w_ROMDataOut          )	
    );
    
    //----------------Dcach数据逻辑---------------//
    wire [1:0] w_fireDcache;
    wire w_drvDcache2MutexLSU,w_freeDcacheFMutexLSU;
    cFifo2_socmem cFifo2_Dcache(
        .i_drive        ( w_drvLSU2fifoDcache   ),
        .o_free         ( w_freeLSUFfifoDcache  ),
        .o_fire_2       ( w_fireDcache          ),
        .rst            ( rst                   ),  
        .o_driveNext    ( w_drvDcache2MutexLSU  ),
        .i_freeNext     ( w_freeDcacheFMutexLSU )
    );

    reg [ 7:0] r_dcacheEn;
    reg [31:0] r_dcacheAddr;
    reg [63:0] r_dcacheData;
    always @(negedge w_fireDcache[0] or negedge rst ) begin
        if(!rst)begin
            r_dcacheEn      <= 0;
            r_dcacheAddr    <= 0;
            r_dcacheData    <= 0;
        end 
        else begin
            r_dcacheEn      <= w_infoDcache[103:96];
            r_dcacheAddr    <= w_infoDcache[ 95:64]-32'h00021200;
            r_dcacheData    <= w_infoDcache[ 63: 0];
        end
    end
    //------------Dcache控制逻辑----------//
    wire dcache_Trig;
    CKMUX2M4HM	dcachemux(.S(init_sig),.A(w_fireDcache[1]),.B(clk),.Z(dcache_Trig));
    wire [ 7:0] w_dcacheEn  = (init_sig&&(i_daddress_32<=32'h00041200)) ? i_dwen_8                   : r_dcacheEn;
    wire [31:0] w_dcacheAddr= (init_sig&&(i_daddress_32<=32'h00041200)) ? i_daddress_32-32'h00021200 : r_dcacheAddr;
    wire [63:0] w_dcacheData= (init_sig&&(i_daddress_32<=32'h00041200)) ? i_ddataW_64                : r_dcacheData;
    wire [63:0] w_dcacheDataOut;
    sram_128k  DCache (
        .i_addr_14               ( w_dcacheAddr[13:0]   ),
        .i_data_64               ( w_dcacheData         ),
        .i_sramTrig              ( dcache_Trig          ), 
        .i_WEB_8                 ( w_dcacheEn           ), 
        .o_data_64               ( w_dcacheDataOut      )
    );

    //----------------Stack数据逻辑---------------//
    wire [1:0] w_fireStack;
    wire w_drvStack2MutexLSU,w_freeStackFMutexLSU;
    cFifo2_socmem cFifo2_Stack(
        .i_drive        ( w_drvLSU2fifoStack    ),
        .o_free         ( w_freeLSUFfifoStack   ),
        .o_fire_2       ( w_fireStack           ),
        .rst            ( rst                   ),  
        .o_driveNext    ( w_drvStack2MutexLSU   ),
        .i_freeNext     ( w_freeStackFMutexLSU  )
    );

    reg [ 7:0] r_StackEn;
    reg [31:0] r_StackAddr;
    reg [63:0] r_StackData;
    always @(negedge w_fireStack[0] or negedge rst ) begin
        if(!rst)begin
            r_StackEn      <= 0;
            r_StackAddr    <= 0;
            r_StackData    <= 0;
        end 
        else begin
            r_StackEn      <= w_infoStack[103:96];
            r_StackAddr    <= w_infoStack[ 95:64]-32'h00041200;
            r_StackData    <= w_infoStack[ 63: 0];
        end
    end
    //------------Stack控制逻辑----------//
    wire stack_Trig;
    CKMUX2M4HM	stackmux(.S(init_sig),.A(w_fireStack[1]),.B(clk),.Z(stack_Trig));
    wire [ 7:0] w_StackEn  = (init_sig&&(i_daddress_32>32'h00041200)) ? i_dwen_8                   : r_dcacheEn;
    wire [31:0] w_StackAddr= (init_sig&&(i_daddress_32>32'h00041200)) ? i_daddress_32-32'h00041200 : r_dcacheAddr;
    wire [63:0] w_StackData= (init_sig&&(i_daddress_32>32'h00041200)) ? i_ddataW_64                : r_dcacheData;
    wire [63:0] w_StackDataOut;
    sram_8k  stack (
        .i_addr_10               ( w_StackAddr[9:0]     ),
        .i_data_64               ( w_StackData          ),
        .i_sramTrig              ( stack_Trig           ), 
        .i_WEB_8                 ( w_StackEn            ), 
        .o_data_64               ( w_StackDataOut       )
    );
    
    //---------Dcache和Stack的mutex逻辑-----------------//
    wire [63:0] w_LSUdata;
    wire w_cfifoLSU_end,w_cfifoLSU_end_delay;
    delay2U delay_LSUFifo (.inR(w_cfifoLSU_end), .outR(w_cfifoLSU_end_delay),.rst(rst));
    cMutexMerge2_64b_socmem mutexLSU (
        .rst            (rst                    ),
        .i_drive0       (w_drvDcache2MutexLSU   ),
        .i_drive1       (w_drvStack2MutexLSU    ),
        .o_free0        (w_freeDcacheFMutexLSU  ),
        .o_free1        (w_freeStackFMutexLSU   ),
        .i_data0_64     (w_dcacheDataOut        ),
        .i_data1_64     (w_StackDataOut         ),
        .o_driveNext    (w_cfifoLSU_end         ),
        .i_freeNext     (w_cfifoLSU_end_delay   ),
        .o_data_64      (w_LSUdata              )
    );

    //---------输出选择----------//
    delay16U delay_IFDrive (.inR(w_drv2NextIf), .outR(o_driveNextToIf),.rst(rst));
    delay16U delay_LSUDrive (.inR(w_driveNextToLsu), .outR(o_driveNextToLsu),.rst(rst));

    assign o_idataR_64 = if_routeSelect ? w_icacheDataOut : w_ROMDataOut;
    assign o_ddataR_64 = w_LSUdata;
endmodule
