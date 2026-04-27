`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/07 14:01:40
// Design Name: 
// Module Name: IONetwork_Top
// author: lu.yihua
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

`define GPIO_NUM 16
module IONet_slot(
    //----------------CPU interface---------------//
    input rst,
    input rst_finish,
    input clk,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFCPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2CPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [50:0] i_dataFCPU_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2CPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  i_freeFCPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [50:0] o_data2CPU_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output WD_RST,

    //-------------UART serial interface------------//
    // UART0 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART0,NOUT2_UART0,NOUT1_UART0,NRTS_UART0,NDTR_UART0,SOUT_UART0,BAUD_UART0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART0,NDCD_UART0,NRI_UART0,NDSR_UART0,NCTS_UART0,SIN_UART0,RCLK_BAUD_UART0,BREG_UART0,

    // UART1 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART1, NOUT2_UART1, NOUT1_UART1, NRTS_UART1, NDTR_UART1, SOUT_UART1, BAUD_UART1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART1, NDCD_UART1, NRI_UART1, NDSR_UART1, NCTS_UART1, SIN_UART1, RCLK_BAUD_UART1, BREG_UART1,
   
    //-------------IIC serial interface------------//
    // IIC0 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output INTR_IIC0,OSCL_IIC0,OSDA_IIC0,ENDRV_IIC0,CKISO_IIC0,DAISO_IIC0,DAGND_IIC0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input HSEN_IIC0,FSEN_IIC0,ISCL_IIC0,ISDA_IIC0,IFSDA_IIC0,

    //-------------SPI serial interface------------//
    // SPI0 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input miso_SPI0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output sclk_SPI0,cs_n_SPI0,mosi_SPI0,startRead_SPI0,busy_SPI0,

    // SPI1 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  sclk_in_SPI1,mosi_in_SPI1,miso_in_SPI1,nss_in_SPI1,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output  IRQ_SPI1,sclk_out_SPI1,mosi_out_SPI1,miso_out_SPI1,nss_out_SPI1,io_ctl_sclk_SPI1,io_ctl_mosi_SPI1,io_ctl_miso_SPI1,io_ctl_nss_SPI1,

    //------------Watch Dog serial interface------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output Int_WD,

    //---------------TIMER serial interface------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [ 4:0] INT_TIMER, 

    //---------------PWM serial interface------------//
    // PWM0 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output PWM0_OUT,

    // PWM1 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output PWM1_OUT,

    //---------------GPIO serial interface------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_GPIO,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [`GPIO_NUM-1:0] io_pin,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] gpio_ctrl_o,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] gpio_data_o
    );
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvFNoCChannel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_free2NocChannel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataFNoCChannel0_51;
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvFNoCChannel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_free2NocChannel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataFNoCChannel1_51;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2NoCChanel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_freeFNoCChanel0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_data2NoCChanel0_51;

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2NoCChanel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_freeFNoCChanel1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_data2NoCChanel1_51;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire RST_WD;
    
    //-------------------CPU interface----------------//
    CPU2NoC cpu2noc_instance (
        .rst(rst),
        .i_drvFCPU(i_drvFCPU),
        .o_free2CPU(o_free2CPU),
        .i_dataFCPU_51(i_dataFCPU_51),

        .o_drv2CPU(o_drv2CPU),
        .i_freeFCPU(i_freeFCPU),
        .o_data2CPU_51(o_data2CPU_51),

        .i_drvFNoCChannel0(w_drvFNoCChannel0),
        .o_free2NocChannel0(w_free2NocChannel0),
        .i_dataFNoCChannel0_51(w_dataFNoCChannel0_51),

        .i_drvFNoCChannel1(w_drvFNoCChannel1),
        .o_free2NocChannel1(w_free2NocChannel1),
        .i_dataFNoCChannel1_51(w_dataFNoCChannel1_51),

        .o_drv2NoCChanel0(w_drv2NoCChanel0),
        .i_freeFNoCChanel0(w_freeFNoCChanel0),
        .o_data2NoCChanel0_51(w_data2NoCChanel0_51),

        .o_drv2NoCChanel1(w_drv2NoCChanel1),
        .i_freeFNoCChanel1(w_freeFNoCChanel1),
        .o_data2NoCChanel1_51(w_data2NoCChanel1_51)
    );

    //---------------------UART interface---------------------//
    // UART0:(0,0)West
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART0FNoc,w_freeUART02Noc,w_drvNocFUART0,w_freeNoc2UART0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART02Noc,w_dataNoc2UART0;
    NoCUART0 UART0 (
        .CLOCK(clk),
        .rst(rst),
        .rst_finish(rst_finish),
        .i_drvFNoc(w_drvUART0FNoc),
        .o_free2Noc(w_freeUART02Noc),
        .i_dataFNoc_51(w_dataNoc2UART0),
        .o_drv2Noc(w_drvNocFUART0),
        .i_freeFNoc(w_freeNoc2UART0),
        .o_data2Noc_51(w_dataUART02Noc),
        
        .IRQ(IRQ_UART0),
        .RCLK(RCLK_UART0),
        .NDCD(NDCD_UART0),
        .NRI(NRI_UART0),
        .NDSR(NDSR_UART0),
        .NCTS(NCTS_UART0),
        .SIN(SIN_UART0),
        .RCLK_BAUD(RCLK_BAUD_UART0),
        .BRGE(BREG_UART0),
        .NOUT2(NOUT2_UART0),
        .NOUT1(NOUT1_UART0),
        .NRTS(NRTS_UART0),
        .NDTR(NDTR_UART0),
        .SOUT(SOUT_UART0),
        .BAUD(BAUD_UART0)
    );
    // UART1: (0,1) North
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART1FNoc, w_freeUART12Noc, w_drvNocFUART1, w_freeNoc2UART1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART12Noc, w_dataNoc2UART1;
    NoCUART1 UART1 (
        .CLOCK(clk),
        .rst(rst),
        .rst_finish(rst_finish),
        .i_drvFNoc(w_drvUART1FNoc),
        .o_free2Noc(w_freeUART12Noc),
        .i_dataFNoc_51(w_dataNoc2UART1),
        .o_drv2Noc(w_drvNocFUART1),
        .i_freeFNoc(w_freeNoc2UART1),
        .o_data2Noc_51(w_dataUART12Noc),
        
        .IRQ(IRQ_UART1),
        .RCLK(RCLK_UART1),
        .NDCD(NDCD_UART1),
        .NRI(NRI_UART1),
        .NDSR(NDSR_UART1),
        .NCTS(NCTS_UART1),
        .SIN(SIN_UART1),
        .RCLK_BAUD(RCLK_BAUD_UART1),
        .BRGE(BREG_UART1),
        .NOUT2(NOUT2_UART1),
        .NOUT1(NOUT1_UART1),
        .NRTS(NRTS_UART1),
        .NDTR(NDTR_UART1),
        .SOUT(SOUT_UART1),
        .BAUD(BAUD_UART1)
    );

    //---------------------PWM interface---------------------//
    // PWM0 (1,1): North
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvPWM0FNoc, w_freePWM02Noc, w_drvNocFPWM0, w_freeNoc2PWM0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataPWM02Noc, w_dataNoc2PWM0;
    pwm0_top PWM0 (
    .clk(clk),
    .rst(rst),
    .rst_finish(rst_finish),
    .i_drive(w_drvPWM0FNoc),
	.o_free(w_freePWM02Noc),
	.i_msg(w_dataNoc2PWM0),
    .o_drive(w_drvNocFPWM0),
	.i_free(w_freeNoc2PWM0),
	.o_msg(w_dataPWM02Noc),
    .pwm_out(PWM0_OUT)
    );

    // PWM1 (1,0): South
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvPWM1FNoc, w_freePWM12Noc, w_drvNocFPWM1, w_freeNoc2PWM1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataPWM12Noc, w_dataNoc2PWM1;
    pwm1_top PWM1 (
    .clk(clk),
    .rst(rst),
    .rst_finish(rst_finish),
    .i_drive(w_drvPWM1FNoc),
	.o_free(w_freePWM12Noc),
	.i_msg(w_dataNoc2PWM1),
    .o_drive(w_drvNocFPWM1),
	.i_free(w_freeNoc2PWM1),
	.o_msg(w_dataPWM12Noc),
    .pwm_out(PWM1_OUT)
    );


    //-----------------IIC------------//
    //IIC0:(0,1) West
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvIIC0FNoc,w_freeIIC02Noc,w_drvNocFIIC0,w_freeNoc2IIC0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataIIC02Noc,w_dataNoc2IIC0;

    // Instantiate IIC2NoC
    I2C2NoC  IIC (
    .rst(rst),
    .CLOCK(clk),
    .rst_finish(rst_finish),
    .i_drvFNoc(w_drvIIC0FNoc),
    .o_free2Noc(w_freeIIC02Noc),
    .i_dataFNoc_51(w_dataNoc2IIC0),

    .o_drv2Noc(w_drvNocFIIC0),
    .i_freeFNoc(w_freeNoc2IIC0),
    .o_data2Noc_51(w_dataIIC02Noc),

    .INTR(INTR_IIC0),
    .FSEN(FSEN_IIC0),
    .HSEN(HSEN_IIC0),
    .ISCL(ISCL_IIC0),
    .ISDA(ISDA_IIC0),
    .IFSDA(IFSDA_IIC0),

    .OSCL(OSCL_IIC0),
    .OSDA(OSDA_IIC0),
    .ENDRV(ENDRV_IIC0),
    .CKISO(CKISO_IIC0),
    .DAISO(DAISO_IIC0),
    .DAGND(DAGND_IIC0)
    );


    //---------------SPI-------------------//
    // SPI0:(0,0)South
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSPI0FNoc, w_freeSPI02Noc, w_drvNocFSPI0, w_freeNoc2SPI0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataSPI02Noc, w_dataNoc2SPI0;

    SPI02NoC spi0 (
        .clk(clk),
        .rst(rst),
        .rst_finish(rst_finish),
        
        .i_driveFrmMesh(w_drvSPI0FNoc),
        .o_freeToMesh(w_freeSPI02Noc),
        .i_dataFrmNoc(w_dataNoc2SPI0),

        .o_driveNextToMesh(w_drvNocFSPI0),
        .i_freeNextFrmMesh(w_freeNoc2SPI0),
        .o_data2Noc(w_dataSPI02Noc),
        
        // Interact with SPI slave
        .miso(miso_SPI0),
        .sclk(sclk_SPI0),
        .cs_n(cs_n_SPI0),
        .mosi(mosi_SPI0),
	.busy(busy_SPI0),
        .startRead(startRead_SPI0)
    );

    // SPI1:(1,1):local
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSPI1FNoc, w_freeSPI12Noc, w_drvNocFSPI1, w_freeNoc2SPI1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataSPI12Noc, w_dataNoc2SPI1;

    SPI2NoC spi1 (
        .clk(clk),
        .rst(rst),
        .rst_finish(rst_finish),
        
        .i_drvFNoc(w_drvSPI1FNoc),
        .o_free2Noc(w_freeSPI12Noc),
        .i_dataFNoc_51(w_dataNoc2SPI1),

        .o_drv2Noc(w_drvNocFSPI1),
        .i_freeFNoc(w_freeNoc2SPI1),
        .o_data2Noc_51(w_dataSPI12Noc),
        
        // Interact with SPI slave
        .SPI_IRQ(IRQ_SPI1),
        .sclk_in(sclk_in_SPI1),
        .miso_in(miso_in_SPI1),
        .mosi_in(mosi_in_SPI1),
        .nss_in (nss_in_SPI1 ),

        .sclk_out(sclk_out_SPI1),
        .miso_out(miso_out_SPI1),
        .mosi_out(mosi_out_SPI1),
        .nss_out (nss_out_SPI1 ),

        .io_ctl_sclk(io_ctl_sclk_SPI1),
        .io_ctl_miso(io_ctl_miso_SPI1),
        .io_ctl_mosi(io_ctl_mosi_SPI1),
        .io_ctl_nss (io_ctl_nss_SPI1 )
    );
    //--------------Watch Dog-------------//
    // (1,0) East
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvWDFNoc, w_freeWD2Noc, w_drvNocFWD, w_freeNoc2WD;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataWD2Noc, w_dataNoc2WD; 
    
    // Instantiate the wd2noc module
    wd2noc WatchDog(
    .Noc_RES(rst),
    .rst_finish(rst_finish),
    .wd_clk(clk),
    .i_drive(w_drvWDFNoc),
    .o_free(w_freeWD2Noc),
    .i_msg(w_dataNoc2WD),

    .o_drive(w_drvNocFWD),
    .i_free(w_freeNoc2WD),
    .o_msg(w_dataWD2Noc),
    .o_RES(WD_RST),
    .o_INT(Int_WD)
    );
    
    //------------------GPIO interface--------------//
    //(0.1) West
    wire w_drvNoC2GPIO,w_freeGPIO2NoC,w_drvGPIO2NoC,w_freeNoC2GPIO;
    wire [50:0] w_dataGPIO2NoC;
    wire [50:0] w_dataNoC2GPIO;
    gpio_slot gpio_slot (     
    
        .clk                  (clk                 ),
        .rst_finish           (rst_finish          ),
        .rst                  (rst                 ),           
        .io_pin_i             (io_pin              ),
        .gpio_ctrl_o          (gpio_ctrl_o         ),
        .gpio_data_o          (gpio_data_o         ),

        .i_driveFrmMesh       (w_drvNoC2GPIO       ),
        .o_freeToMesh         (w_freeGPIO2NoC      ),
        .o_driveNextToMesh    (w_drvGPIO2NoC       ),
        .i_freeNextFrmMesh    (w_freeNoC2GPIO      ),
        .data_to              (w_dataGPIO2NoC      ),
        .data_from            (w_dataNoC2GPIO      ),
        .irq                  (IRQ_GPIO            )
    );                

    //------------------TIMER interface-------------//
    //(0,1) North
    wire w_drvNoC2Timer,w_freeTimer2NoC,w_drvTimer2NoC,w_freeNoC2Timer;
    wire [50:0] w_dataTimer2NoC;
    wire [50:0] w_dataNoC2Timer;
    
    timer_slot TIMER (
        .clk                (clk),
        .rst                (rst),
        .rst_finish         (rst_finish),
        .int_sig_o          (INT_TIMER),
        .i_driveFrmMesh     (w_drvNoC2Timer),
        .o_freeToMesh       (w_freeTimer2NoC),
        .data_from          (w_dataNoC2Timer),
        .o_driveNextToMesh  (w_drvTimer2NoC),
        .i_freeNextFrmMesh  (w_freeNoC2Timer),
        .data_to            (w_dataTimer2NoC)
    );

    //---------------------IONetWork----------------//
    // Instantiate the IONetwork
    wire w_drv2NoCChanel0_delay;
    delay8U delayUart0 (.inR(w_drv2NoCChanel0), .outR(w_drv2NoCChanel0_delay),.rst(rst));
    IONetwork uut (
        .rst(rst),

        //(0,0)
        .i_driveLocal_00(w_drv2NoCChanel0_delay), .o_freeLocal_00(w_freeFNoCChanel0),.i_localInMsg_51_00(w_data2NoCChanel0_51),
        .o_driveLocal_00(w_drvFNoCChannel0), .i_freeLocal_00(w_free2NocChannel0),  .o_localMsg_51_00(w_dataFNoCChannel0_51),
        .i_driveWest_00(w_drvNocFUART0), .o_freeWest_00(w_freeNoc2UART0), .i_westInMsg_51_00(w_dataUART02Noc),
        .o_driveWest_00(w_drvUART0FNoc), .i_freeWest_00(w_freeUART02Noc), .o_westMsg_51_00(w_dataNoc2UART0),
        .i_driveSouth_00(w_drvNocFSPI0), .o_freeSouth_00(w_freeNoc2SPI0), .i_southInMsg_51_00(w_dataSPI02Noc),
        .o_driveSouth_00(w_drvSPI0FNoc), .i_freeSouth_00(w_freeSPI02Noc), .o_southMsg_51_00(w_dataNoc2SPI0),
        
        //(1,0) 
        .i_driveLocal_10(w_drvNocFUART1), .o_freeLocal_10(w_freeNoc2UART1), .i_localInMsg_51_10(w_dataUART12Noc),
        .o_driveLocal_10(w_drvUART1FNoc), .i_freeLocal_10(w_freeUART12Noc), .o_localMsg_51_10(w_dataNoc2UART1),
        .i_driveSouth_10(w_drvNocFPWM1), .o_freeSouth_10(w_freeNoc2PWM1), .i_southInMsg_51_10(w_dataPWM12Noc),
        .o_driveSouth_10(w_drvPWM1FNoc), .i_freeSouth_10(w_freePWM12Noc), .o_southMsg_51_10(w_dataNoc2PWM1),
        .i_driveEast_10(w_drvNocFWD),  .o_freeEast_10(w_freeNoc2WD), .i_eastInMsg_51_10(w_dataWD2Noc),
        .o_driveEast_10(w_drvWDFNoc), .i_freeEast_10(w_freeWD2Noc), .o_eastMsg_51_10(w_dataNoc2WD),

        //(1,1)
        .i_driveLocal_11(w_drvNocFSPI1), .o_freeLocal_11(w_freeNoc2SPI1), .i_localInMsg_51_11(w_dataSPI12Noc),
        .o_driveLocal_11(w_drvSPI1FNoc), .i_freeLocal_11(w_freeSPI12Noc), .o_localMsg_51_11(w_dataNoc2SPI1),
        .i_driveNorth_11(w_drvNocFPWM0), .o_freeNorth_11(w_freeNoc2PWM0), .i_northInMsg_51_11(w_dataPWM02Noc),
        .o_driveNorth_11(w_drvPWM0FNoc), .i_freeNorth_11(w_freePWM02Noc), .o_northMsg_51_11(w_dataNoc2PWM0),
        .i_driveEast_11(w_drvNocFIIC0),  .o_freeEast_11(w_freeNoc2IIC0), .i_eastInMsg_51_11(w_dataIIC02Noc),
        .o_driveEast_11(w_drvIIC0FNoc), .i_freeEast_11(w_freeIIC02Noc), .o_eastMsg_51_11(w_dataNoc2IIC0),

        //(0,1)
        .i_driveLocal_01(w_drv2NoCChanel1), .i_freeLocal_01(w_free2NocChannel1), .i_localInMsg_51_01(w_data2NoCChanel1_51),
        .o_driveLocal_01(w_drvFNoCChannel1), .o_freeLocal_01(w_freeFNoCChanel1), .o_localMsg_51_01(w_dataFNoCChannel1_51),
        .i_driveWest_01(w_drvGPIO2NoC), .o_freeWest_01(w_freeNoC2GPIO),  .i_westInMsg_51_01(w_dataGPIO2NoC),
        .o_driveWest_01(w_drvNoC2GPIO), .i_freeWest_01(w_freeGPIO2NoC),.o_westMsg_51_01(w_dataNoC2GPIO),
        .i_driveNorth_01(w_drvTimer2NoC), .o_freeNorth_01(w_freeNoC2Timer),  .i_northInMsg_51_01(w_dataTimer2NoC),
        .o_driveNorth_01(w_drvNoC2Timer), .i_freeNorth_01(w_freeTimer2NoC),.o_northMsg_51_01(w_dataNoC2Timer)
    );
endmodule
