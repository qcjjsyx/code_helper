//-----------------------------------------------
//    module name: 
//    author: lu.yihua
//  
//    version: 1st version (2024-10-15)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps

module arm_soc_top(
    input  wire        initMode_pad,    

    input  wire        clk_pad,

    input  wire        rst_pad,
    
    input  wire        rx_pin_pad,    
    output wire        tx_pin_pad,
    
    // UART0 serial interface
    output NOUT2_UART0_pad, NOUT1_UART0_pad, NRTS_UART0_pad, NDTR_UART0_pad, SOUT_UART0_pad, BAUD_UART0_pad,
    input RCLK_UART0_pad, NDCD_UART0_pad, NRI_UART0_pad, NDSR_UART0_pad, NCTS_UART0_pad, SIN_UART0_pad, RCLK_BAUD_UART0_pad, BREG_UART0_pad,


    // UART1 serial interface
    output NOUT2_UART1_pad, NOUT1_UART1_pad, NRTS_UART1_pad, NDTR_UART1_pad, SOUT_UART1_pad, BAUD_UART1_pad,
    input RCLK_UART1_pad, NDCD_UART1_pad, NRI_UART1_pad, NDSR_UART1_pad, NCTS_UART1_pad, SIN_UART1_pad, RCLK_BAUD_UART1_pad, BREG_UART1_pad,

    // IIC0 serial interface
    output OSCL_IIC0_pad,OSDA_IIC0_pad,ENDRV_IIC0_pad,CKISO_IIC0_pad,DAISO_IIC0_pad,DAGND_IIC0_pad,
    input HSEN_IIC0_pad, FSEN_IIC0_pad, ISCL_IIC0_pad, ISDA_IIC0_pad, IFSDA_IIC0_pad,

    // SPI0 serial interface
    input miso_SPI0_pad,
    output sclk_SPI0_pad,cs_n_SPI0_pad,mosi_SPI0_pad,startRead_SPI0_pad,

    // SPI1 serial interface
    inout wire sclk_SPI1_pad,miso_SPI1_pad,mosi_SPI1_pad,nss_SPI1_pad,

    //---------------PWM serial interface------------//
    // PWM0 serial interface
    output PWM0_OUT_pad,

    // PWM1 serial interface
    output PWM1_OUT_pad,

    //---------------GPIO serial interface------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)inout [15:0] io_pin_pad
    

    );

    localparam input_DO   = 1'b0; localparam output_DI   = 1'bz;   
    localparam input_OE   = 1'b0; localparam output_OE   = 1'b1; 
    localparam input_IDDQ = 1'b0; localparam output_IDDQ = 1'b0; localparam inout_IDDQ = 1'b0;
    localparam input_PD   = 1'b1; localparam output_PD   = 1'b0; localparam inout_PD   = 1'b1;
    localparam input_PU   = 1'b1; localparam output_PU   = 1'b0; localparam inout_PU   = 1'b1;
    localparam input_SMT  = 1'b1; localparam output_SMT  = 1'b0; localparam inout_SMT  = 1'b1;
    localparam input_SR   = 1'b0; localparam output_SR   = 1'b0; localparam inout_SR   = 1'b0;
    localparam input_PIN2 = 1'b0; localparam output_PIN2 = 1'b1; localparam inout_PIN2 = 1'b1;
    localparam input_PIN1 = 1'b0; localparam output_PIN1 = 1'b1; localparam inout_PIN1 = 1'b1;

    wire init_sig;
    wire clk,rst_async,rx_pin,tx_pin,initMode;
    wire rst,rst_wd;
    wire rst_finish;
    wire WD_RST;
    wire [4:0] INT_TIMER;

    async2sync async2sync_rstInit  (.clk(clk),.rst_async_n(rst_async),.rst_sync_n(rst));
    async2sync async2sync_rstFinish(.clk(clk),.rst_async_n(~init_sig&rst),.rst_sync_n(rst_finish));
    async2sync async2sync_rstWD    (.clk(clk),.rst_async_n(WD_RST),.rst_sync_n(rst_wd));
    
    wire NOUT2_UART0, NOUT1_UART0, NRTS_UART0, NDTR_UART0, SOUT_UART0, BAUD_UART0;
    wire RCLK_UART0, NDCD_UART0, NRI_UART0, NDSR_UART0, NCTS_UART0, SIN_UART0, RCLK_BAUD_UART0, BREG_UART0;
    wire NOUT2_UART1, NOUT1_UART1, NRTS_UART1, NDTR_UART1, SOUT_UART1, BAUD_UART1,IRQ_UART1;
    wire RCLK_UART1, NDCD_UART1, NRI_UART1, NDSR_UART1, NCTS_UART1, SIN_UART1, RCLK_BAUD_UART1, BREG_UART1;
    wire OSCL_IIC0, OSDA_IIC0, ENDRV_IIC0, CKISO_IIC0, DAISO_IIC0, DAGND_IIC0,INTR_IIC0;
    wire HSEN_IIC0, FSEN_IIC0, ISCL_IIC0, ISDA_IIC0, IFSDA_IIC0;
    wire miso_SPI0;
    wire sclk_SPI0, cs_n_SPI0, mosi_SPI0, startRead_SPI0;
    wire Int_WD;
    wire PWM0_OUT;
    wire PWM1_OUT;
    wire  sclk_in_SPI1,mosi_in_SPI1,miso_in_SPI1,nss_in_SPI1;
    wire  IRQ_SPI1,sclk_out_SPI1,mosi_out_SPI1,miso_out_SPI1,nss_out_SPI1,io_ctl_sclk_SPI1,io_ctl_mosi_SPI1,io_ctl_miso_SPI1,io_ctl_nss_SPI1;
    wire IRQ_GPIO;
    wire [15:0] io_pin;
    wire [31:0] gpio_ctrl_o;
    wire [31:0] gpio_data_o;

    //---------------------------OUTPUT IO PAD---------------------------//
    IUMB output_tx_pin(
    .PAD   (tx_pin_pad), .DO   (tx_pin),
    .OE    (output_OE  ),.IDDQ (output_IDDQ),.PD    (output_PD  ),
    .PU    (output_PU  ),.SMT  (output_SMT ),//.DI    (output_DI  ),
    .SR    (output_SR  ),.PIN2 (output_PIN2),.PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
    IUMB output_nout2_uart0(
    .PAD   (NOUT2_UART0_pad), .DO   (NOUT2_UART0),
    .OE    (output_OE      ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
    .PU    (output_PU      ), .SMT  (output_SMT ), //.DI    (output_DI  ),
    .SR    (output_SR      ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_nout1_uart0(
        .PAD   (NOUT1_UART0_pad), .DO   (NOUT1_UART0),
        .OE    (output_OE      ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU      ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR      ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_nrts_uart0(
        .PAD   (NRTS_UART0_pad), .DO   (NRTS_UART0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_ndtr_uart0(
        .PAD   (NDTR_UART0_pad), .DO   (NDTR_UART0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_sout_uart0(
        .PAD   (SOUT_UART0_pad), .DO   (SOUT_UART0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_baud_uart0(
        .PAD   (BAUD_UART0_pad), .DO   (BAUD_UART0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_nout2_uart1(
        .PAD   (NOUT2_UART1_pad), .DO   (NOUT2_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_nout1_uart1(
        .PAD   (NOUT1_UART1_pad), .DO   (NOUT1_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_nrts_uart1(
        .PAD   (NRTS_UART1_pad), .DO   (NRTS_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
    
    IUMB output_ndtr_uart1(
        .PAD   (NDTR_UART1_pad), .DO   (NDTR_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_sout_uart1(
        .PAD   (SOUT_UART1_pad), .DO   (SOUT_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_baud_uart1(
        .PAD   (BAUD_UART1_pad), .DO   (BAUD_UART1),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_oscl_iic0(
        .PAD   (OSCL_IIC0_pad), .DO   (OSCL_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_osda_iic0(
        .PAD   (OSDA_IIC0_pad), .DO   (OSDA_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_endrv_iic0(
        .PAD   (ENDRV_IIC0_pad), .DO   (ENDRV_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_ckiso_iic0(
        .PAD   (CKISO_IIC0_pad), .DO   (CKISO_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_daiso_iic0(
        .PAD   (DAISO_IIC0_pad), .DO   (DAISO_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_dagnd_iic0(
        .PAD   (DAGND_IIC0_pad), .DO   (DAGND_IIC0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
        
    IUMB output_sclk_spi0(
        .PAD   (sclk_SPI0_pad), .DO   (sclk_SPI0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
            
    IUMB output_cs_n_spi0(
        .PAD   (cs_n_SPI0_pad), .DO   (cs_n_SPI0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
            
    IUMB output_mosi_spi0(
        .PAD   (mosi_SPI0_pad), .DO   (mosi_SPI0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
            
    IUMB output_startRead_spi0(
        .PAD   (startRead_SPI0_pad), .DO   (startRead_SPI0),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB output_pwm0_out(
        .PAD   (PWM0_OUT_pad), .DO   (PWM0_OUT),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
            
    IUMB output_pwm1_out(
        .PAD   (PWM1_OUT_pad), .DO   (PWM1_OUT),
        .OE    (output_OE     ), .IDDQ (output_IDDQ), .PD    (output_PD  ),
        .PU    (output_PU     ), .SMT  (output_SMT ), //.DI    (output_DI  ),
        .SR    (output_SR     ), .PIN2 (output_PIN2), .PIN1  (output_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

//----------------------------SPI inout  PAD--------------------------------//
    
    IUMB inout_sclk_SPI1(
    .PAD   (sclk_SPI1_pad),  .OE    (io_ctl_sclk_SPI1),
    .DO    (sclk_out_SPI1), .DI    (sclk_in_SPI1), 
    .PD    (inout_PD  ),.PU    (inout_PU  ),.SMT   (inout_SMT ), .IDDQ  (inout_IDDQ),
    .SR    (inout_SR  ),.PIN2  (inout_PIN2),.PIN1  (inout_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB inout_miso_SPI1(
    .PAD   (miso_SPI1_pad),  .OE    (io_ctl_miso_SPI1),
    .DO    (miso_out_SPI1), .DI    (miso_in_SPI1), 
    .PD    (inout_PD  ),.PU    (inout_PU  ),.SMT   (inout_SMT ), .IDDQ  (inout_IDDQ),
    .SR    (inout_SR  ),.PIN2  (inout_PIN2),.PIN1  (inout_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB inout_mosi_SPI1(
    .PAD   (mosi_SPI1_pad),  .OE    (io_ctl_mosi_SPI1),
    .DO    (mosi_out_SPI1), .DI    (mosi_in_SPI1), 
    .PD    (inout_PD  ),.PU    (inout_PU  ),.SMT   (inout_SMT ), .IDDQ  (inout_IDDQ),
    .SR    (inout_SR  ),.PIN2  (inout_PIN2),.PIN1  (inout_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB inout_nss_SPI1(
    .PAD   (nss_SPI1_pad),  .OE    (io_ctl_nss_SPI1),
    .DO    (nss_out_SPI1), .DI    (nss_in_SPI1), 
    .PD    (inout_PD  ),.PU    (inout_PU  ),.SMT   (inout_SMT ), .IDDQ  (inout_IDDQ),
    .SR    (inout_SR  ),.PIN2  (inout_PIN2),.PIN1  (inout_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

//----------------------------INPUT IO PAD--------------------------------//
    IUMB input_initMode(
        .PAD   (initMode_pad),.DI    (initMode),
        .OE    (input_OE  ),.IDDQ  (input_IDDQ),.PD    (input_PD  ),
        .PU    (input_PU  ),.SMT   (input_SMT ),.DO    (input_DO  ),
        .SR    (input_SR  ),.PIN2  (input_PIN2),.PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    ); 

    IUMB input_clk(
        .PAD   (clk_pad),.DI (clk),
        .OE    (input_OE  ),.IDDQ  (input_IDDQ),.PD    (input_PD  ),
        .PU    (input_PU  ),.SMT   (input_SMT ),.DO    (input_DO  ),
        .SR    (input_SR  ),.PIN2  (input_PIN2),.PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
    IUMB input_rst(
        .PAD   (rst_pad),.DI    (rst_async),
        .OE    (input_OE  ),.IDDQ  (input_IDDQ),.PD    (input_PD  ),
        .PU    (input_PU  ),.SMT   (input_SMT ),.DO    (input_DO  ),
        .SR    (input_SR  ),.PIN2  (input_PIN2),.PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_rx_pin(
        .PAD   (rx_pin_pad),.DI    (rx_pin),
        .OE    (input_OE  ),.IDDQ  (input_IDDQ),.PD    (input_PD  ),
        .PU    (input_PU  ),.SMT   (input_SMT ),.DO    (input_DO  ),
        .SR    (input_SR  ),.PIN2  (input_PIN2),.PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    ); 

    IUMB input_RCLK_UART0 (
    .PAD   (RCLK_UART0_pad), .DI    (RCLK_UART0),
    .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
    .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
    .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_NDCD_UART0 (
        .PAD   (NDCD_UART0_pad), .DI    (NDCD_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_NRI_UART0 (
        .PAD   (NRI_UART0_pad),  .DI    (NRI_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_NDSR_UART0 (
        .PAD   (NDSR_UART0_pad), .DI    (NDSR_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_NCTS_UART0 (
        .PAD   (NCTS_UART0_pad), .DI    (NCTS_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_SIN_UART0 (
        .PAD   (SIN_UART0_pad),  .DI    (SIN_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_RCLK_BAUD_UART0 (
        .PAD   (RCLK_BAUD_UART0_pad), .DI    (RCLK_BAUD_UART0),
        .OE    (input_OE),            .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),            .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),            .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_BREG_UART0 (
        .PAD   (BREG_UART0_pad), .DI    (BREG_UART0),
        .OE    (input_OE),       .IDDQ  (input_IDDQ), .PD    (input_PD),
        .PU    (input_PU),       .SMT   (input_SMT),  .DO    (input_DO),
        .SR    (input_SR),       .PIN2  (input_PIN2), .PIN1  (input_PIN1),
        .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_rclk_uart1(
    .PAD   (RCLK_UART1_pad), .DI (RCLK_UART1),
    .OE    (input_OE       ), .IDDQ (input_IDDQ), .PD (input_PD  ),
    .PU    (input_PU       ), .SMT  (input_SMT ), .DO (input_DO  ),
    .SR    (input_SR       ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
);

    IUMB input_ndcd_uart1(
        .PAD   (NDCD_UART1_pad), .DI (NDCD_UART1),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_nri_uart1(
        .PAD   (NRI_UART1_pad), .DI (NRI_UART1),
        .OE    (input_OE     ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU     ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR     ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_ndsr_uart1(
        .PAD   (NDSR_UART1_pad), .DI (NDSR_UART1),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_ncts_uart1(
        .PAD   (NCTS_UART1_pad), .DI (NCTS_UART1),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_sin_uart1(
        .PAD   (SIN_UART1_pad), .DI (SIN_UART1),
        .OE    (input_OE     ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU     ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR     ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_rclk_baud_uart1(
        .PAD   (RCLK_BAUD_UART1_pad), .DI (RCLK_BAUD_UART1),
        .OE    (input_OE           ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU           ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR           ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_breg_uart1(
        .PAD   (BREG_UART1_pad), .DI (BREG_UART1),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_hsen_iic0(
    .PAD   (HSEN_IIC0_pad), .DI (HSEN_IIC0),
    .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
    .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
    .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
);

    IUMB input_fsen_iic0(
        .PAD   (FSEN_IIC0_pad), .DI (FSEN_IIC0),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_iscl_iic0(
        .PAD   (ISCL_IIC0_pad), .DI (ISCL_IIC0),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_isda_iic0(
        .PAD   (ISDA_IIC0_pad), .DI (ISDA_IIC0),
        .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );

    IUMB input_ifsda_iic0(
        .PAD   (IFSDA_IIC0_pad), .DI (IFSDA_IIC0),
        .OE    (input_OE       ), .IDDQ (input_IDDQ), .PD (input_PD  ),
        .PU    (input_PU       ), .SMT  (input_SMT ), .DO (input_DO  ),
        .SR    (input_SR       ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
    IUMB input_miso_spi0(
    .PAD   (miso_SPI0_pad), .DI (miso_SPI0),
    .OE    (input_OE      ), .IDDQ (input_IDDQ), .PD (input_PD  ),
    .PU    (input_PU      ), .SMT  (input_SMT ), .DO (input_DO  ),
    .SR    (input_SR      ), .PIN2 (input_PIN2), .PIN1 (input_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
    );
  


    genvar i; 
    generate
       for(i=0;i<16;i=i+1)
       begin: gpio
            IUMB inout_gpio_i(
                .PAD   (io_pin_pad[i]),  .OE    (gpio_ctrl_o[i]),
                .DO    (gpio_data_o[i]), .DI    (io_pin[i]), 
                .PD    (inout_PD  ),.PU    (inout_PU  ),.SMT   (inout_SMT ), .IDDQ  (inout_IDDQ),
                .SR    (inout_SR  ),.PIN2  (inout_PIN2),.PIN1  (inout_PIN1),
    .VSS(1'b0),.VDD(1'b1),.VDDIO(1'b1)
            );
       end
    endgenerate

    wire [50:0] Local_in; 
    wire [50:0] Local_out;

    wire w_freeFrmCPU, w_freeToCPU, w_driveToCPU, w_driveFrmCPU;
    
    wire w_drvFload,w_free2load,w_drvFStore,w_free2Store;
    wire RST_WD;
    reg soc_start;
    reg rst_1,rst_2;

    /********************** clk buffer **************************/


    //local slot
    cpu_slot u_cpu   (
    
        .clk                  (clk              ),
        .rst                  (rst_2           ),
        
        .init_sig             (init_sig         ),
        .init_rx              (rx_pin           ),
        .init_tx              (tx_pin           ),
        
        .i_driveFromMesh      (w_driveToCPU      ),
        .o_free2Mesh          (w_freeFrmCPU      ),
        .i_dataFMesh          (Local_in          ),

        .o_driveToMesh        (w_driveFrmCPU     ),
        .i_freeFMesh          (w_freeToCPU       ),
        .o_data2Mesh          (Local_out         ),

        .soc_start            (soc_start         ),
        //定义：i_IntSig={iic,wd,spi1,uart1,GPIO,timer}
        .i_IntSig             ({INTR_IIC0,Int_WD,IRQ_SPI1,IRQ_UART1,IRQ_GPIO,INT_TIMER[0]}),

        .initMode             (initMode          )
    );           

    IONet_slot io_slot (
        .rst                    (rst_2              ),
        .rst_finish             (rst_2              ),
        .clk                    (clk                ),
        
        .i_drvFCPU              (w_driveFrmCPU      ),
        .o_free2CPU             (w_freeToCPU        ),
        .i_dataFCPU_51          (Local_out          ), 
    
        .o_drv2CPU              (w_driveToCPU       ),
        .i_freeFCPU             (w_freeFrmCPU       ),
        .o_data2CPU_51          (Local_in           ),
    
        // UART0
        .IRQ_UART0              (                   ),
        .NOUT2_UART0            (NOUT2_UART0        ),
        .NOUT1_UART0            (NOUT1_UART0        ),
        .NRTS_UART0             (NRTS_UART0         ),
        .NDTR_UART0             (NDTR_UART0         ),
        .SOUT_UART0             (SOUT_UART0         ),
        .BAUD_UART0             (BAUD_UART0         ),
        .RCLK_UART0             (RCLK_UART0         ),
        .NDCD_UART0             (NDCD_UART0         ),
        .NRI_UART0              (NRI_UART0          ),
        .NDSR_UART0             (NDSR_UART0         ),
        .NCTS_UART0             (NCTS_UART0         ),
        .SIN_UART0              (SIN_UART0          ),
        .RCLK_BAUD_UART0        (RCLK_BAUD_UART0    ),
        .BREG_UART0             (BREG_UART0         ),
    
        // UART1
        .IRQ_UART1              (IRQ_UART1          ),
        .NOUT2_UART1            (NOUT2_UART1        ),
        .NOUT1_UART1            (NOUT1_UART1        ),
        .NRTS_UART1             (NRTS_UART1         ),
        .NDTR_UART1             (NDTR_UART1         ),
        .SOUT_UART1             (SOUT_UART1         ),
        .BAUD_UART1             (BAUD_UART1         ),
        .RCLK_UART1             (RCLK_UART1         ),
        .NDCD_UART1             (NDCD_UART1         ),
        .NRI_UART1              (NRI_UART1          ),
        .NDSR_UART1             (NDSR_UART1         ),
        .NCTS_UART1             (NCTS_UART1         ),
        .SIN_UART1              (SIN_UART1          ),
        .RCLK_BAUD_UART1        (RCLK_BAUD_UART1    ),
        .BREG_UART1             (BREG_UART1         ),
    
        // IIC0
        .INTR_IIC0              (INTR_IIC0          ),
        .OSCL_IIC0              (OSCL_IIC0          ),
        .OSDA_IIC0              (OSDA_IIC0          ),
        .ENDRV_IIC0             (ENDRV_IIC0         ),
        .CKISO_IIC0             (CKISO_IIC0         ),
        .DAISO_IIC0             (DAISO_IIC0         ),
        .DAGND_IIC0             (DAGND_IIC0         ),
        .HSEN_IIC0              (HSEN_IIC0          ),
        .FSEN_IIC0              (FSEN_IIC0          ),
        .ISCL_IIC0              (ISCL_IIC0          ),
        .ISDA_IIC0              (ISDA_IIC0          ),
        .IFSDA_IIC0             (IFSDA_IIC0         ),
    
        // SPI0
        .sclk_SPI0              (sclk_SPI0          ),
        .cs_n_SPI0              (cs_n_SPI0          ),
        .mosi_SPI0              (mosi_SPI0          ),
        .startRead_SPI0         (startRead_SPI0     ),
        .miso_SPI0              (miso_SPI0          ),
    
        // SPI1
        .sclk_in_SPI1           (sclk_in_SPI1       ),
        .mosi_in_SPI1           (mosi_in_SPI1       ),
        .miso_in_SPI1           (miso_in_SPI1       ),      
        .nss_in_SPI1            (nss_in_SPI1        ),
        .IRQ_SPI1               (IRQ_SPI1           ),
        .sclk_out_SPI1          (sclk_out_SPI1      ),
        .mosi_out_SPI1          (mosi_out_SPI1      ),
        .miso_out_SPI1          (miso_out_SPI1      ),
        .nss_out_SPI1           (nss_out_SPI1       ),
        .io_ctl_sclk_SPI1       (io_ctl_sclk_SPI1   ),
        .io_ctl_mosi_SPI1       (io_ctl_mosi_SPI1   ),
        .io_ctl_miso_SPI1       (io_ctl_miso_SPI1   ),
        .io_ctl_nss_SPI1        (io_ctl_nss_SPI1    ),
    
        // WD
        .Int_WD                 (Int_WD             ),
        .WD_RST                 (WD_RST             ),
    
        // TIMER
        .INT_TIMER              (INT_TIMER          ),
    
        // PWM0
        .PWM0_OUT               (PWM0_OUT           ),
    
        // PWM1
        .PWM1_OUT               (PWM1_OUT           ),
    
        // GPIO
        .IRQ_GPIO               (IRQ_GPIO           ),
        .io_pin                 (io_pin             ),
        .gpio_ctrl_o            (gpio_ctrl_o        ),
        .gpio_data_o            (gpio_data_o        )
    );
    


    /************************ auto start after rst *******************/
    // rst:异步按键复位转同�?
    // rst_real：消除毛刺后的按键复�?,这里由于用的是机械按键，应该设置12500�?5ms）【暂时用10，实际用的时候改�?
    // rst_2:增加复位时长，主要针对WD产生的复位信号，实际使用这个
    //reg [17:0] counter_remove_spike;
    reg [1:0] rst_sync_stage; // 用于记录复位同步的阶�?
    //reg rst_real;//消除毛刺的复�?
    //对异步按键复位增加复位滤�?
    //always @(posedge clk) begin
    //    if(!rst)begin
    //        if(counter_remove_spike<18'hFF)begin
    //            counter_remove_spike <= counter_remove_spike + 18'h1;
    //        end
    //    end else begin
    //        counter_remove_spike <= 18'h0;
    //    end
    //end
    //always @(posedge clk) begin
    //    //按键按不�?1000个周期就不会拉低rst_real
    //    if(counter_remove_spike==18'hFF)begin
    //        rst_real <= 0;
    //    end
    //    else begin
    //        rst_real <= 1;
    //    end
    //end

    //延长复位时间以确保复位深�?
    reg [15:0] counter;
    wire rst_with_wd = WD_RST & rst;
    always @(posedge clk or negedge rst_with_wd) begin
        if (!rst_with_wd) begin
            rst_sync_stage <= 2'b00;
            soc_start <= 1'b0;
            counter <=8'b0;
            rst_1 <= 1'b0;
            rst_2 <= 1'b0;
        end else begin
            case (rst_sync_stage)
                2'b00: begin // rst从低变高后，开始第一阶段计数
                    if (counter < 16'd200) begin
                        counter <= counter + 1;
                    end else begin
                        rst_1 <= 1'b1; // 第一阶段计数完成，产生rst_1
                        counter <= 5'b0; // 重置计数�?
                        rst_sync_stage <= 2'b01; // 进入第二阶段
                    end
                end
                2'b01: begin // rst_1从低变高后，开始第二阶段计�?
                    if (counter < 16'd200) begin
                        counter <= counter + 1;
                    end else begin
                        rst_2 <= 1'b1; // 第二阶段计数完成，产生rst_2
                        counter <= 5'b0; // 重置计数�?
                        rst_sync_stage <= 2'b10; // 进入第三阶段
                    end
                end
                2'b10: begin // rst_2从低变高后，开始第三阶段计�?
                    if (counter < 16'd200) begin
                        counter <= counter + 1;
                    end else begin
                        soc_start <= 1'b1; // 第三阶段计数完成，拉高soc_start
                        counter <= 5'b0; // 重置计数�?
                        rst_sync_stage <= 2'b00; // 重置阶段
                    end
                end
                default: rst_sync_stage <= 2'b00;
            endcase
        end
    end


endmodule
