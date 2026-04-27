`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2024/08/01 10:22:28
// author: lu.yihua
// Design Name: 
// Module Name: UARTInterface
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
module CPU2NoC(
    // CPU core interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFCPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2CPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [50:0] i_dataFCPU_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2CPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  i_freeFCPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [50:0] o_data2CPU_51,
    
    // NoC interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFNoCChannel0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2NocChannel0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [50:0] i_dataFNoCChannel0_51,
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFNoCChannel1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2NocChannel1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [50:0] i_dataFNoCChannel1_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2NoCChanel0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFNoCChanel0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [50:0] o_data2NoCChanel0_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2NoCChanel1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFNoCChanel1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [50:0] o_data2NoCChanel1_51
);
    
    localparam UART0Addr = 8'h00;
    localparam UART1Addr = 8'h10;
    localparam PWM0Addr = 8'h20;
    localparam PWM1Addr = 8'h30;
    localparam I2C0Addr = 8'h40;
    localparam TIMERAddr = 8'h50;
    localparam SPI0Addr = 8'h60;
    localparam SPI1Addr = 8'h70;
    localparam WATCHDOGAddr = 8'h80;
    localparam GPIOAddr = 8'h90;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [7:0] r_IOAddr;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_data_32;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_flag;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [11:0] r_carry_12;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2Channel0,w_freeFChannel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [39:0] w_data2Channel0,w_data2Channel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2Channel1,w_freeFChannel1;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [4:0] r_X,r_Y;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_channelChoose = (r_IOAddr>=UART0Addr && r_IOAddr<UART1Addr
                            || r_IOAddr>=PWM1Addr && r_IOAddr<I2C0Addr
                            || r_IOAddr>=SPI0Addr && r_IOAddr<SPI1Addr
                            || r_IOAddr>=UART1Addr && r_IOAddr<PWM0Addr
                            || r_IOAddr>=WATCHDOGAddr && r_IOAddr<GPIOAddr)  ? 1'B0 : 1'B1;
    
    wire w_fireFifo0,w_fireFifo2;
    wire w_drvSelect0,w_freeSelect0;
    wire w_drv2fifo2,w_freeFfifo2,w_drv2fifo2_dalay;
    cFifo1 cfifo0(
    .i_drive(i_drvFCPU),
    .o_free(),
    .i_freeNext(w_freeFfifo2),
    .o_driveNext(w_drv2fifo2),
    .o_fire_1(w_fireFifo0),   //11.2jyl change from o_fire_2 to o_fire_3
    .rst(rst)
    );
	assign o_free2CPU = o_drv2CPU;

    delay4U delay7 (.inR(w_drv2fifo2), .outR(w_drv2fifo2_dalay), .rst(rst));
    cFifo1 cfifo2(
    .i_drive(w_drv2fifo2_dalay),
    .o_free(w_freeFfifo2),
    .i_freeNext(w_freeSelect0),
    .o_driveNext(w_drvSelect0),
    .o_fire_1(w_fireFifo2),   //11.2jyl change from o_fire_2 to o_fire_3
    .rst(rst)
    );

    always@(posedge w_fireFifo0 or negedge rst)begin
        if(!rst)begin
            r_IOAddr <= 8'b0;
            r_data_32 <=32'b0;
            r_flag <= 0;
        end
        else begin
            r_IOAddr <= i_dataFCPU_51[49:42];
            r_data_32 <= i_dataFCPU_51[41:10];
            r_flag <= ~i_dataFCPU_51[50];//ionet is 1 read 0 write,while cpu is 1 write 0 read
        end
    end
    
    cSelector2_41b select0 (
        .i_drive(w_drvSelect0),
        .i_data_41({~w_channelChoose,r_IOAddr,r_data_32}),
        .o_free(w_freeSelect0),

        .o_driveNext0(w_drv2Channel0),
        .i_freeNext0(w_freeFChannel0),
        .o_data0_40(w_data2Channel0),

        .o_driveNext1(w_drv2Channel1),
        .o_data1_40(w_data2Channel1),
        .i_freeNext1(w_freeFChannel1),

        .rst(rst)
    ); 

    //----------Channel0-----------//

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select2,w_freeFselect2,w_drv2NoCChanel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_data2MutexWriteChannel0;
    (* dont_touch="true" *)delay8U delay18 (.inR(w_drv2NoCChanel0), .outR(o_drv2NoCChanel0), .rst(rst));
    cSplitter2_51b splitterChannel0 (
        .i_drive(w_drv2Channel0),
        .i_freeNext0(i_freeFNoCChanel0),
        .i_freeNext1(w_freeFselect2),
        .rst(rst),
        .i_data_51({r_flag,w_data2Channel0,r_X,r_Y}),

        .o_free(w_freeFChannel0),
        .o_driveNext0(w_drv2NoCChanel0),
        .o_driveNext1(w_drv2select2),
        .o_data0_51(o_data2NoCChanel0_51),
        .o_data1_51(w_data2MutexWriteChannel0)
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2Mutex0Channel0,w_freeFMutex0Channel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_overselect2,w_overselect2_dalay;
    (* dont_touch="true" *)delay8U delay6 (.inR(w_overselect2), .outR(w_overselect2_dalay), .rst(rst));
    
    cSelector2_1b select2 (
        .i_drive(w_drv2select2),
        .i_data_1(~r_flag),
        .o_free(w_freeFselect2),

        .o_driveNext0(w_drv2Mutex0Channel0),
        .i_freeNext0(w_freeFMutex0Channel0),
        .o_data0_1(),

        .o_driveNext1(w_overselect2),
        .o_data1_1(),
        .i_freeNext1(w_overselect2_dalay),

        .rst(rst)
    ); 
    
 

    //------------Channel1---------//

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2select3,w_freeFselect3,w_drv2NoCChanel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_data2Mutex0Channel1_51;
    (* dont_touch="true" *)delay8U delay20 (.inR(w_drv2NoCChanel1), .outR(o_drv2NoCChanel1), .rst(rst));

    cSplitter2_51b splitterChannel1 (
        .i_drive(w_drv2Channel1),
        .i_freeNext0(i_freeFNoCChanel1),
        .i_freeNext1(w_freeFselect3),
        .rst(rst),
        .i_data_51({r_flag,w_data2Channel1,r_X,r_Y}),

        .o_free(w_freeFChannel1),
        .o_driveNext0(w_drv2NoCChanel1),
        .o_driveNext1(w_drv2select3),
        .o_data0_51(o_data2NoCChanel1_51),
        .o_data1_51(w_data2Mutex0Channel1_51)
    );
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_overselect3,w_overselect3_dalay;
    (* dont_touch="true" *)delay8U delay8 (.inR(w_overselect3), .outR(w_overselect3_dalay), .rst(rst));
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2Mutex0Channel1,w_freeFMutex0Channel1;
    
    cSelector2_1b select3 (
        .i_drive(w_drv2select3),
        .i_data_1(~r_flag),
        .o_free(w_freeFselect3),

        .o_driveNext0(w_drv2Mutex0Channel1),
        .i_freeNext0(w_freeFMutex0Channel1),
        .o_data0_1(),

        .o_driveNext1(w_overselect3),
        .o_data1_1(),
        .i_freeNext1(w_overselect3_dalay),

        .rst(rst)
    ); 
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_mutex0dataChannel1_51;


    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2Mutex2Channel1,w_freeFMutex2Channel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_data2Mutex2Channel1;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvMutexRead2select1,w_freeMutexReadFselect1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire[50:0] w_dataMutexRead;
    
    cMutexMerge2_51b mutexRead (
        .i_drive0(i_drvFNoCChannel0),
        .i_data0_51(i_dataFNoCChannel0_51),
        .o_free0(o_free2NocChannel0),
        .i_drive1(i_drvFNoCChannel1),
        .i_data1_51(i_dataFNoCChannel1_51),
        .o_free1(o_free2NocChannel1),
        .i_freeNext(w_freeMutexReadFselect1),
        .o_driveNext(w_drvMutexRead2select1),
        .o_data_51(w_dataMutexRead),
        .rst(rst)
    );
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[49:0] r_CPUdata;
    wire w_fireFifo1;
    wire w_drvCPULoad,w_freeCPULoad;
    cFifo1 cfifo1(
    .i_drive(w_drvMutexRead2select1),
    .o_free(w_freeMutexReadFselect1),
    .i_freeNext(w_freeCPULoad),
    .o_driveNext(w_drvCPULoad),
    .o_fire_1(w_fireFifo1),
    .rst(rst)
    );


    always@(posedge w_fireFifo1 or negedge rst)begin
        if(!rst)begin
            r_CPUdata <= 0;
        end
        else begin
            r_CPUdata <= w_dataMutexRead[49:0];
        end
    end


    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0]w_dataMutexWrite;
    wire w_drv2CPUStore_dalay1;
    wire w_drv2CPUStore,w_free2CPUStore;
    wire w_drv2fifo1,w_freeFfifo1;
   delay8U delay0 (.inR(w_drv2CPUStore_dalay1), .outR(w_free2CPUStore),.rst(rst));
    cMutexMerge2_51b mutexWrite (
        .i_drive0(w_drv2Mutex0Channel0),
        .i_data0_51(w_data2MutexWriteChannel0),
        .o_free0(w_freeFMutex0Channel0),
        .i_drive1(w_drv2Mutex0Channel1),
        .i_data1_51(w_data2Mutex0Channel1_51),
        .o_free1(w_freeFMutex0Channel1),
        .i_freeNext(w_free2CPUStore),
        .o_driveNext(w_drv2CPUStore_dalay1),
        .o_data_51(w_dataMutexWrite),
        .rst(rst)
    );
    
    wire [50:0] w_data2CPU_51= {~r_flag,r_CPUdata};
    reg [50:0] r_data2CPU_51;

    wire w_firecfifoOut;
    cFifo1 cfifoOut(
    .i_drive(w_drvCPULoad),
    .o_free(w_freeCPULoad),
    .i_freeNext(i_freeFCPU),
    .o_driveNext(o_drv2CPU),
    .o_fire_1(w_firecfifoOut),   //11.2jyl change from o_fire_2 to o_fire_3
    .rst(rst)
    );
    always@(posedge w_firecfifoOut or negedge rst)begin
        if(!rst)begin
            r_data2CPU_51 <=0;
        end
        else begin
            r_data2CPU_51 <= w_data2CPU_51;
        end
    end
    assign o_data2CPU_51 = r_data2CPU_51;
    always@(posedge w_fireFifo2 or negedge rst)begin
        //UART0
        if(!rst)begin
            r_X = 5'b00000;
            r_Y = 5'b00000;
        end 
        else if(r_IOAddr>=UART0Addr && r_IOAddr<UART1Addr)begin
            r_X = 5'b10001;
            r_Y = 5'b00000;
        end
        //UART1
        else if(r_IOAddr>=UART1Addr && r_IOAddr<PWM0Addr)begin
            r_X = 5'b00001;
            r_Y = 5'b00000;
        end
        //PWM0
        else if(r_IOAddr>=PWM0Addr && r_IOAddr<PWM1Addr)begin
            r_X = 5'b00001;
            r_Y = 5'b00001;
        end
        //PWM1
        else if(r_IOAddr>=PWM1Addr && r_IOAddr<I2C0Addr)begin
            r_X = 5'b00001;
            r_Y = 5'b10001;
        end
        //I2C0
        else if(r_IOAddr>=I2C0Addr && r_IOAddr<TIMERAddr)begin
            r_X = 5'b00010;
            r_Y = 5'b00000;
        end
        //TIMER
        else if(r_IOAddr>=TIMERAddr && r_IOAddr<SPI0Addr)begin
            r_X = 5'b00000;
            r_Y = 5'b00001;
        end
        //SPI0
        else if(r_IOAddr>=SPI0Addr && r_IOAddr<SPI1Addr)begin
            r_X = 5'b00000;
            r_Y = 5'b10001;
        end
        //SPI1
        else if(r_IOAddr>=SPI1Addr && r_IOAddr<WATCHDOGAddr)begin
            r_X = 5'b00001;
            r_Y = 5'b00000;
        end
        //WD
        else if(r_IOAddr>=WATCHDOGAddr && r_IOAddr<GPIOAddr )begin
            r_X = 5'b00010;
            r_Y = 5'b00000;
        end
        else if(r_IOAddr>=GPIOAddr )begin
            r_X = 5'b10001;
            r_Y = 5'b00000;
        end
        else begin
            r_X = 5'b00000;
            r_Y = 5'b00000;
        end
    end

    
endmodule
