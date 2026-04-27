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


module IONetwork_Top(
    // CPU core interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input clk,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFCPU,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2CPU,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_flag,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [5:0] i_index_6,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [33:0] i_addr_34,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [31:0] i_data_32,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2CPULoad,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  i_freeFCPULoad,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [5:0] o_indexLoad,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_dataLoad,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [4:0] o_rdLoad,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2CPUStore,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  i_freeFCPUStore,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [4:0] o_indexStore,

    //-------------UART serial interface------------//
    // UART0 serial interface
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART0,NOUT2_UART0,NOUT1_UART0,NRTS_UART0,NDTR_UART0,SOUT_UART0,BAUD_UART0,ACK_UART0,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART0,NDCD_UART0,NRI_UART0,NDSR_UART0,NCTS_UART0,SIN_UART0,RCLK_BAUD_UART0,BREG_UART0

    // UART1 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART1, NOUT2_UART1, NOUT1_UART1, NRTS_UART1, NDTR_UART1, SOUT_UART1, BAUD_UART1,ACK_UART1,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART1, NDCD_UART1, NRI_UART1, NDSR_UART1, NCTS_UART1, SIN_UART1, RCLK_BAUD_UART1, BREG_UART1,

    // UART2 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART2, NOUT2_UART2, NOUT1_UART2, NRTS_UART2, NDTR_UART2, SOUT_UART2, BAUD_UART2,ACK_UART2,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART2, NDCD_UART2, NRI_UART2, NDSR_UART2, NCTS_UART2, SIN_UART2, RCLK_BAUD_UART2, BREG_UART2,

    // UART3 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_UART3, NOUT2_UART3, NOUT1_UART3, NRTS_UART3, NDTR_UART3, SOUT_UART3, BAUD_UART3,ACK_UART3,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input RCLK_UART3, NDCD_UART3, NRI_UART3, NDSR_UART3, NCTS_UART3, SIN_UART3, RCLK_BAUD_UART3, BREG_UART3,

    //-------------IIC serial interface------------//
    // IIC0 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output INTR_IIC0,OSCL_IIC0,OSDA_IIC0,ENDRV_IIC0,CKISO_IIC0,DAISO_IIC0,DAGND_IIC0,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input HSEN_IIC0,FSEN_IIC0,ISCL_IIC0,ISDA_IIC0,IFSDA_IIC0,

    // IIC1 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output INTR_IIC1, OSCL_IIC1, OSDA_IIC1, ENDRV_IIC1, CKISO_IIC1, DAISO_IIC1, DAGND_IIC1,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input HSEN_IIC1, FSEN_IIC1, ISCL_IIC1, ISDA_IIC1, IFSDA_IIC1,

    //-------------SPI serial interface------------//
    // SPI0 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input miso_SPI0,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output sclk_SPI0,cs_n_SPI0,mosi_SPI0,finish_SPI0,startRead_SPI0,

    // SPI1 serial interface
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input miso_SPI1,
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output sclk_SPI1, cs_n_SPI1, mosi_SPI1, finish_SPI1, startRead_SPI1,

    //------------Watch Dog serial interface------------//
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ_WD
    
    );
    //------------CPU????0,0??local----------//  
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
    
    //-------------------CPU----------------//
    CPU2NoC cpu2noc_instance (
        .rst(rst& ~RST_WD),
        .i_drvFCPU(i_drvFCPU),
        .o_free2CPU(o_free2CPU),

        .i_flag(i_flag),
        .i_index_6(i_index_6),
        .i_addr_34(i_addr_34),
        .i_data_32(i_data_32),

        .o_drv2CPULoad(o_drv2CPULoad),
        .i_freeFCPULoad(i_freeFCPULoad),

        .o_indexLoad(o_indexLoad),
        .o_dataLoad(o_dataLoad),
        .o_rdLoad(o_rdLoad),

        .o_drv2CPUStore(o_drv2CPUStore),
        .i_freeFCPUStore(i_freeFCPUStore),

        .o_indexStore(o_indexStore),


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

    //---------------UART-----------------//
    // UART0:(0,0)West
    //UART0??(0,0)West
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART0FNoc,w_freeUART02Noc,w_drvNocFUART0,w_freeNoc2UART0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART02Noc,w_dataNoc2UART0;
    UART2NoC UART0 (
        .CLOCK(clk),
        .rst(rst& ~RST_WD),
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
        .BAUD(BAUD_UART0),
        .ACK(ACK_UART0)
    );
    // UART1??(0,1)North
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART1FNoc, w_freeUART12Noc, w_drvNocFUART1, w_freeNoc2UART1;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART12Noc, w_dataNoc2UART1;
//    UART2NoC UART1 (
//        .CLOCK(clk),
//        .rst(rst& ~RST_WD),
//        .i_drvFNoc(w_drvUART1FNoc),
//        .o_free2Noc(w_freeUART12Noc),
//        .i_dataFNoc_51(w_dataNoc2UART1),
//        .o_drv2Noc(w_drvNocFUART1),
//        .i_freeFNoc(w_freeNoc2UART1),
//        .o_data2Noc_51(w_dataUART12Noc),
        
//        .IRQ(IRQ_UART1),
//        .RCLK(RCLK_UART1),
//        .NDCD(NDCD_UART1),
//        .NRI(NRI_UART1),
//        .NDSR(NDSR_UART1),
//        .NCTS(NCTS_UART1),
//        .SIN(SIN_UART1),
//        .RCLK_BAUD(RCLK_BAUD_UART1),
//        .BRGE(BREG_UART1),
//        .NOUT2(NOUT2_UART1),
//        .NOUT1(NOUT1_UART1),
//        .NRTS(NRTS_UART1),
//        .NDTR(NDTR_UART1),
//        .SOUT(SOUT_UART1),
//        .BAUD(BAUD_UART1),
//        .ACK(ACK_UART1)
//    );

    // UART2??(1,0)South
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART2FNoc, w_freeUART22Noc, w_drvNocFUART2, w_freeNoc2UART2;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART22Noc, w_dataNoc2UART2;
//    UART2NoC UART2 (
//        .CLOCK(clk),
//        .rst(rst& ~RST_WD),
//        .i_drvFNoc(w_drvUART2FNoc),
//        .o_free2Noc(w_freeUART22Noc),
//        .i_dataFNoc_51(w_dataNoc2UART2),
//        .o_drv2Noc(w_drvNocFUART2),
//        .i_freeFNoc(w_freeNoc2UART2),
//        .o_data2Noc_51(w_dataUART22Noc),
        
//        .IRQ(IRQ_UART2),
//        .RCLK(RCLK_UART2),
//        .NDCD(NDCD_UART2),
//        .NRI(NRI_UART2),
//        .NDSR(NDSR_UART2),
//        .NCTS(NCTS_UART2),
//        .SIN(SIN_UART2),
//        .RCLK_BAUD(RCLK_BAUD_UART2),
//        .BRGE(BREG_UART2),
//        .NOUT2(NOUT2_UART2),
//        .NOUT1(NOUT1_UART2),
//        .NRTS(NRTS_UART2),
//        .NDTR(NDTR_UART2),
//        .SOUT(SOUT_UART2),
//        .BAUD(BAUD_UART2),
//        .ACK(ACK_UART2)
//    );

    // UART3??(1,1)North
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvUART3FNoc, w_freeUART32Noc, w_drvNocFUART3, w_freeNoc2UART3;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataUART32Noc, w_dataNoc2UART3;
//    UART2NoC UART3 (
//        .CLOCK(clk),
//        .rst(rst& ~RST_WD),
//        .i_drvFNoc(w_drvUART3FNoc),
//        .o_free2Noc(w_freeUART32Noc),
//        .i_dataFNoc_51(w_dataNoc2UART3),
//        .o_drv2Noc(w_drvNocFUART3),
//        .i_freeFNoc(w_freeNoc2UART3),
//        .o_data2Noc_51(w_dataUART32Noc),
        
//        .IRQ(IRQ_UART3),
//        .RCLK(RCLK_UART3),
//        .NDCD(NDCD_UART3),
//        .NRI(NRI_UART3),
//        .NDSR(NDSR_UART3),
//        .NCTS(NCTS_UART3),
//        .SIN(SIN_UART3),
//        .RCLK_BAUD(RCLK_BAUD_UART3),
//        .BRGE(BREG_UART3),
//        .NOUT2(NOUT2_UART3),
//        .NOUT1(NOUT1_UART3),
//        .NRTS(NRTS_UART3),
//        .NDTR(NDTR_UART3),
//        .SOUT(SOUT_UART3),
//        .BAUD(BAUD_UART3),
//        .ACK(ACK_UART3)
//    );

    //-----------------IIC------------//
    //IIC0:(0,1)West
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvIIC0FNoc,w_freeIIC02Noc,w_drvNocFIIC0,w_freeNoc2IIC0;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataIIC02Noc,w_dataNoc2IIC0;

//    // Instantiate I2C2NoC
//    I2C2NoC iic0 (
//    .rst(rst& ~RST_WD),
//    .i_drvFNoc(w_drvIIC0FNoc),
//    .o_free2Noc(w_freeIIC02Noc),
//    .i_dataFNoc_51(w_dataNoc2IIC0),

//    .o_drv2Noc(w_drvNocFIIC0),
//    .i_freeFNoc(w_freeNoc2IIC0),
//    .o_data2Noc_51(w_dataIIC02Noc),

//    .INTR(INTR_IIC0),
//    .FSEN(FSEN_IIC0),
//    .HSEN(HSEN_IIC0),
//    .ISCL(ISCL_IIC0),
//    .ISDA(ISDA_IIC0),
//    .IFSDA(IFSDA_IIC0),

//    .OSCL(OSCL_IIC0),
//    .OSDA(OSDA_IIC0),
//    .ENDRV(ENDRV_IIC0),
//    .CKISO(CKISO_IIC0),
//    .DAISO(DAISO_IIC0),
//    .DAGND(DAGND_IIC0)
//    );
    //IIC1:(1,0):local
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvIIC1FNoc, w_freeIIC12Noc, w_drvNocFIIC1, w_freeNoc2IIC1;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataIIC12Noc, w_dataNoc2IIC1;

    // Instantiate I2C2NoC
//    I2C2NoC iic1 (
//        .rst(rst& ~RST_WD),
//        .i_drvFNoc(w_drvIIC1FNoc),
//        .o_free2Noc(w_freeIIC12Noc),
//        .i_dataFNoc_51(w_dataNoc2IIC1),

//        .o_drv2Noc(w_drvNocFIIC1),
//        .i_freeFNoc(w_freeNoc2IIC1),
//        .o_data2Noc_51(w_dataIIC12Noc),

//        .INTR(INTR_IIC1),
//        .FSEN(FSEN_IIC1),
//        .HSEN(HSEN_IIC1),
//        .ISCL(ISCL_IIC1),
//        .ISDA(ISDA_IIC1),
//        .IFSDA(IFSDA_IIC1),

//        .OSCL(OSCL_IIC1),
//        .OSDA(OSDA_IIC1),
//        .ENDRV(ENDRV_IIC1),
//        .CKISO(CKISO_IIC1),
//        .DAISO(DAISO_IIC1),
//        .DAGND(DAGND_IIC1)
//    );

    //---------------SPI-------------------//
    // SPI0:(0,0)South
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSPI0FNoc, w_freeSPI02Noc, w_drvNocFSPI0, w_freeNoc2SPI0;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataSPI02Noc, w_dataNoc2SPI0;

//    SPI2NoC #(
//        .CLK_FREQUENCE(50_000_000),
//        .SPI_FREQUENCE(5_000_000),
//        .DATA_WIDTH(32),
//        .CPOL(1),
//        .CPHA(1)
//    ) spi0 (
//        .clk(clk),
//        .rst(rst& ~RST_WD),
        
//        .i_drvFNoc(w_drvSPI0FNoc),
//        .o_free2Noc(w_freeSPI02Noc),
//        .i_dataFNoc_51(w_dataNoc2SPI0),

//        .o_drv2Noc(w_drvNocFSPI0),
//        .i_freeFNoc(w_freeNoc2SPI0),
//        .o_data2Noc_51(w_dataSPI02Noc),
        
//        // Interact with SPI slave
//        .miso(miso_SPI0),
//        .sclk(sclk_SPI0),
//        .cs_n(cs_n_SPI0),
//        .mosi(mosi_SPI0),
//        .finish(finish_SPI0),
//        .startRead(startRead_SPI0)
//    );

    // SPI1:(1,1):local
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvSPI1FNoc, w_freeSPI12Noc, w_drvNocFSPI1, w_freeNoc2SPI1;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataSPI12Noc, w_dataNoc2SPI1;

//    SPI2NoC # (
//        .CLK_FREQUENCE(50_000_000),
//        .SPI_FREQUENCE(5_000_000),
//        .DATA_WIDTH(32),
//        .CPOL(1),
//        .CPHA(1)
//    ) spi1 (
//        .clk(clk),
//        .rst(rst & ~RST_WD),
        
//        .i_drvFNoc(w_drvSPI1FNoc),
//        .o_free2Noc(w_freeSPI12Noc),
//        .i_dataFNoc_51(w_dataNoc2SPI1),

//        .o_drv2Noc(w_drvNocFSPI1),
//        .i_freeFNoc(w_freeNoc2SPI1),
//        .o_data2Noc_51(w_dataSPI12Noc),
        
//        // Interact with SPI slave
//        .miso(miso_SPI1),
//        .sclk(sclk_SPI1),
//        .cs_n(cs_n_SPI1),
//        .mosi(mosi_SPI1),
//        .finish(finish_SPI1),
//        .startRead(startRead_SPI1)
//    );

    //--------------Watch Dog-------------//
    // (1,0)East
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvWDFNoc, w_freeWD2Noc, w_drvNocFWD, w_freeNoc2WD;
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] w_dataWD2Noc, w_dataNoc2WD; 
    
//    // Instantiate the wd2noc module
//    wd2noc wd2noc_inst (
//        .i_drvFNoc(w_drvWDFNoc),
//        .o_free2Noc(w_freeWD2Noc),
//        .i_msg(w_dataWD2Noc),

//        .o_drv2Noc(w_drvNocFWD),
//        .i_freeFNoc(w_freeNoc2WD),
//        .o_data2Noc_51(w_dataNoc2WD),
//        .Noc_RES(rst),

//        // Watchdog clock
//        .wg_clk(clk),

//        // Outputs to mesh
//        .o_RES(RST_WD),
//        .o_INT(IRQ_WD)
//    );



    //---------------IONetWork------------//
    // Instantiate the Unit Under Test (UUT)
    wire w_drv2NoCChanel0_delay;
    delay8U delayUart0 (.inR(w_drv2NoCChanel0), .outR(w_drv2NoCChanel0_delay),.rst(rst));
    IONetwork uut (
        .rst(rst& ~RST_WD),

        //(0,0)
        .i_driveLocal_00(w_drv2NoCChanel0_delay), .o_freeLocal_00(w_freeFNoCChanel0),.i_localInMsg_51_00(w_data2NoCChanel0_51),
        .o_driveLocal_00(w_drvFNoCChannel0), .i_freeLocal_00(w_free2NocChannel0),  .o_localMsg_51_00(w_dataFNoCChannel0_51),
        .i_driveWest_00(w_drvNocFUART0), .o_freeWest_00(w_freeNoc2UART0), .i_westInMsg_51_00(w_dataUART02Noc),
        .o_driveWest_00(w_drvUART0FNoc), .i_freeWest_00(w_freeUART02Noc), .o_westMsg_51_00(w_dataNoc2UART0),
        .i_driveSouth_00(), .i_freeSouth_00(), .i_southInMsg_51_00(),
        .o_driveSouth_00(), .o_freeSouth_00(), .o_southMsg_51_00(),

        //(1,0) 
        .i_driveLocal_10(), .i_freeLocal_10(), .i_localInMsg_51_10(),
        .o_driveLocal_10(), .o_freeLocal_10(), .o_localMsg_51_10(),
        .i_driveSouth_10(), .i_freeSouth_10(), .i_southInMsg_51_10(),
        .o_driveSouth_10(), .o_freeSouth_10(), .o_southMsg_51_10(),
        .i_driveEast_10(), .i_freeEast_10(), .i_eastInMsg_51_10(),
        .o_driveEast_10(), .o_freeEast_10(), .o_eastMsg_51_10(),


        //(1,1)
        .i_driveLocal_11(), .i_freeLocal_11(), .i_localInMsg_51_11(),
        .o_driveLocal_11(), .o_freeLocal_11(), .o_localMsg_51_11(),
        .i_driveNorth_11(), .i_freeNorth_11(), .i_northInMsg_51_11(),
        .o_driveNorth_11(), .o_freeNorth_11(), .o_northMsg_51_11(),
        .i_driveEast_11(), .i_freeEast_11(), .i_eastInMsg_51_11(),
        .o_driveEast_11(), .o_freeEast_11(), .o_eastMsg_51_11(),

        //(0,1)
        .i_driveLocal_01(w_drv2NoCChanel1), .i_freeLocal_01(w_free2NocChannel1), .i_localInMsg_51_01(w_data2NoCChanel1_51),
        .o_driveLocal_01(w_drvFNoCChannel1), .o_freeLocal_01(w_freeFNoCChanel1), .o_localMsg_51_01(w_dataFNoCChannel1_51),
        .i_driveWest_01(), .i_freeWest_01(), .i_westInMsg_51_01(),
        .o_driveWest_01(), .o_freeWest_01(), .o_westMsg_51_01(),
        .i_driveNorth_01(), .i_freeNorth_01(), .i_northInMsg_51_01(),
        .o_driveNorth_01(), .o_freeNorth_01(), .o_northMsg_51_01()
    );
endmodule
