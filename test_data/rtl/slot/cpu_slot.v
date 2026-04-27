//-----------------------------------------------
//    module name: slot_data
//    author: Lu.yihua
//  
//    version: 1st version (2024-10-15)
//    description: 
//                 
//
//
//-----------------------------------------------
`timescale 1ns / 1ps
module cpu_slot (
    input  wire         initMode,  //initMode:0 means init from inner uart 

    input  wire         soc_start,  //start: 0 â†? 1

    output wire         init_sig,
    input  wire        init_rx,
    output wire        init_tx,

    input  wire         clk,
    input  wire         rst,

    input  wire	        i_driveFromMesh,
    output              o_free2Mesh,
	output wire	        o_driveToMesh,
    input               i_freeFMesh,

    output wire [50:0]  o_data2Mesh,
    input  wire [50:0]  i_dataFMesh,

    input [5:0]         i_IntSig
);

    reg UART_INIT_SEL;

    reg [31:0] r_startPC_32;

    wire w_drv2MemUARTRoad;
    wire w_driveFromStart_1,w_freeToStart_1;

    wire w_drv2initMode;
    wire w_drv2initMode_delay;
    wire w_drv2InnerInit,w_drv2IONetInit,w_freeFInnerInit,w_freeFIONetInit;
    wire w_cfifo0_end,w_cfifo0_end_delay,w_fireInit;
    wire w_initSel;
    
    delay16U delayInit(.inR(w_drv2initMode), .outR(w_drv2initMode_delay),.rst(rst));
    delay8U delayInnerInit(.inR(w_drv2InnerInit), .outR(w_freeFInnerInit),.rst(rst));
    delay4U delay0 (.inR(w_cfifo0_end), .outR(w_cfifo0_end_delay),.rst(rst));

    
    wire w_drvCpu2Icache,w_freeCPUFIcache,w_drvIcache2CPU,w_freeIcacheFCPU;
    wire [64:0] w_inst_65;

    wire w_lsuDriveToDataRout_1,w_lsuFreeFromDataRout_1,w_dataRoutDriveToLsu_1,w_lsuFreeToDataRout_1;
    wire [104:0] w_lsuToDataRoutData_105;
    wire [64:0] w_memdata_65;

    wire w_drvCPUErr2Icache,w_freeCPUErrFIcache,w_drvIcache2CPUErr,w_freeIcacheFCPUErr;
    wire [103:0] w_CPUErrData_104;
    wire [63:0] w_CPUErrInst_64;

    wire w_driveMux2Dcache,w_freeMuxFDcache,w_driveDcache2Mux,w_freeDcacheFMux;
    wire [63:0] w_dcacheData_64;
    wire [7:0] w_dcache_we_8;
    wire [31:0] w_dcache_addr_32;
    wire [63:0] w_dcache_data_64;

    /********************** clk buffer **************************/

    

    /****************start and choose the start PC*****************/

    // start from event source
    // choose the way init: initMode:1 means init from inner data_init,
    // initMode 0 means init from IONet
    // start event source

    eventSource SoCStart (
        .rst	(rst), 
        .switch	(~soc_start), 
        .fire	(w_drv2initMode)
    );

    cSelector2_1b select2 (
        .i_drive(w_drv2initMode_delay),
        .i_data_1(initMode),
        .o_free(),

        .o_driveNext0(w_drv2InnerInit),
        .i_freeNext0(w_freeFInnerInit),
        .o_data0_1(),

        .o_driveNext1(w_drv2IONetInit),
        .o_data1_1(),
        .i_freeNext1(w_freeFIONetInit),

        .rst(rst)
    ); 

    // if start from IONet (form ROM): PC <---- 32'h00000000
    // if start from form memory uart: PC <---- 32'h00001200

    cFifo1 cfifo0(
    .i_drive(w_drv2InnerInit),
    .o_free(w_freeFInnerInit),
    .i_freeNext(w_cfifo0_end_delay),
    .o_driveNext(w_cfifo0_end),
    .o_fire_1(w_fireInit),
    .rst(rst)
    );

    always @(posedge  w_fireInit or negedge rst) begin
        if(!rst)begin
            UART_INIT_SEL <= 0;
            r_startPC_32 <= 0;
        end
        else begin
            UART_INIT_SEL <= 1;
            r_startPC_32 <= 32'h00001200;
        end
    end

    // if it is init by Inner UART, we need to use this ES
    // or we should stop its clk and the event will go another way to IONet init
    eventSource UARTInitStart (
        .rst	(rst), 
        .switch	(init_sig), 
        .fire	(w_drv2MemUARTRoad)
    ); 

    cMutexMerge2_1b event2CPU(
    .i_drive0(w_drv2MemUARTRoad&UART_INIT_SEL),
    .i_drive1(w_drv2IONetInit),
    .i_data0_1(1'b0),
    .i_data1_1(1'b0),
    .i_freeNext(w_freeToStart_1),
    .rst(rst),
    .o_free0(),
    .o_free1(w_freeFIONetInit),
    .o_driveNext(w_driveFromStart_1),
    .o_data_1()
);

    /********************** CPU core **************************/
	wire [104:0] w_cpuToIcache_105;
	wire [32:0] w_fetchAddr_33;
	wire [7:0] w_fetchWen_8;
	wire [63:0] w_fetchData_64;
	assign w_cpuToIcache_105 = {w_fetchAddr_33,w_fetchData_64,w_fetchWen_8};
    // CPU core
    cpu_top_all u_cpu_core (
        .i_driveFromStart_1     (w_driveFromStart_1     ),
        .i_startPc_32           (r_startPC_32           ),
        .o_freeToStart_1        (w_freeToStart_1),

        // fetch
        .o_drv2ICache           (w_drvCpu2Icache        ),
		//33addr +64 data+8 wen
        .o_cpuToIcache_105      (w_cpuToIcache_105      ),
        .i_freeFICache          (w_freeCPUFIcache       ), 

        .i_drvFICache           (w_drvIcache2CPU        ),
        .i_inst_65              (w_inst_65              ),
        .o_free2ICache          (w_freeIcacheFCPU       ),

        // LSU
        .o_lsuDriveToDataRout_1 (w_lsuDriveToDataRout_1 ),
        .o_lsuToDataRoutData_105(w_lsuToDataRoutData_105),
        .i_lsuFreeFromDataRout_1(w_lsuFreeFromDataRout_1),

        .i_dataRoutDriveToLsu_1 (w_dataRoutDriveToLsu_1 ),
        .i_memData_65           (w_memdata_65           ),
        .o_lsuFreeToDataRout_1  (w_lsuFreeToDataRout_1  ),
        .i_IntSig               (i_IntSig               ),
        .rst                    (rst                    )
    );

    /********************** choose to route to go **************************/

    data_slot data_mux (
        .rst                    (rst                        ),

        // from CPU LSU
        .i_drvCpu2Mux           (w_lsuDriveToDataRout_1     ),
        .o_freeCPUFMux          (w_lsuFreeFromDataRout_1    ),
        .i_dataCPU2Mux_105      (w_lsuToDataRoutData_105    ),

        // to CPU LSU
        .o_driveToCpu           (w_dataRoutDriveToLsu_1     ),
        .i_freeFromCpu          (w_lsuFreeToDataRout_1      ),
        .o_memData_65           (w_memdata_65               ),

        // to Dcache
        .o_driveToDcache        (w_driveMux2Dcache          ),
        .i_freeFromDcache       (w_freeMuxFDcache           ),
        .o_dcache_we            (w_dcache_we_8              ),            
        .o_dcache_addr          (w_dcache_addr_32           ),              
        .o_dcache_data          (w_dcache_data_64           ),  

        // from Dcache
        .i_driveFromDcache      (w_driveDcache2Mux          ),
        .o_freeToDcache         (w_freeDcacheFMux           ),
        .i_dcache_data          (w_dcacheData_64            ),     

        // to IO Network
        .o_driveToMesh          (o_driveToMesh              ),
        .i_freeFromMesh         (i_freeFMesh                ),
        .o_data2Mesh            (o_data2Mesh                ),

        // from IO Network
        .i_driveFromMesh        (i_driveFromMesh            ),
        .o_freeToMesh           (o_free2Mesh                ),
        .i_dataFMesh            (i_dataFMesh                )
    );

    /********************** memory and inner init **************************/

    memory_slot  u_memory_slot (
        .rst                     ( rst                      ),
        .clk                     ( clk                      ),
        .init_rx                 ( init_rx                  ),
        .init_tx                 ( init_tx                  ),

        // LSU 
        .i_driveFrmLsu           ( w_driveMux2Dcache        ),
        .o_freeToLsu             ( w_freeMuxFDcache         ),
        .i_dbus_we               ( w_dcache_we_8            ),
        .i_dbus_addr             ( w_dcache_addr_32         ),
        .i_dbus_data             ( w_dcache_data_64         ),

        .o_driveNextToLsu        ( w_driveDcache2Mux        ),
        .i_freeNextFrmLsu        ( w_freeDcacheFMux         ),
        .o_dbus_data             ( w_dcacheData_64          ),
   
        // when UART_INIT_SEL=0 init_sig will be 0
        .UART_INIT_SEL           ( UART_INIT_SEL            ),
        .init_sig                ( init_sig                 ),
    
        // fetch
        .i_driveFrmIf            ( w_drvCpu2Icache          ),
        .o_freeToIf              ( w_freeCPUFIcache         ),
        .i_ibus_we               ( w_fetchWen_8             ),
        .i_ibus_addr             ( w_fetchAddr_33           ),
        .i_ibus_data             ( w_fetchData_64           ),
        
        .o_driveNextToIf         ( w_drvIcache2CPU          ),
        .i_freeNextFrmIf         ( w_freeIcacheFCPU         ),
        .o_ibus_data             ( w_inst_65                )
    );

endmodule

