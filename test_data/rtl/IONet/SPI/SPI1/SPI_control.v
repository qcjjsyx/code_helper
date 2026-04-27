

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/09 11:04:28
// Design Name: 
// Module Name: SPI_control
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


module SPI_control(
input clk,
input rst_n,

output io_ctl_sclk,
output io_ctl_miso,
output io_ctl_mosi,
output io_ctl_nss,

input sclk_in,
input miso_in,
input mosi_in,
input nss_in,

output sclk_out,
output miso_out,
output mosi_out,
output nss_out,

output  SPI_interrupt,

input[7:0]     PADDR               ,  
input           PENABLE             ,
input           PSEL                ,
input [31:0]    PWDATA              ,
input           PWRITE              ,
output [31:0]   PRDATA              ,
output          PREADY              ,
output          PSLVERR             ,

output nss_reg

    );
//reg wire
// SPI registers
//SPI_SR
(*dont_touch = "yes"*)wire BSY;
wire OVR;
wire MODF;//实际用的MODF
reg MODF_reg;//MODF赋值
wire CRCERR;
wire RXNE;
wire TXE;
wire CRCBSY;

//SPI_DR
wire [15:0] RDR;
wire [15:0] TDR;

//SPI_CRCPR、SPI_RXCRCR、SPI_RXCRCR
wire [15:0] CRCPOLY;
wire [15:0] TXCRC;
wire [15:0] RXCRC;

//SPI_CR1
wire BIDIMODE;
wire BIDIOE;
wire CRCEN;
wire CRCNEXT;
wire DFF;
wire RXONLY;
wire SSM;
wire SSI;
wire LSBFIRST;
wire SPE_apb;
reg SPE;
wire [2:0] BR;
wire MSTR_apb;
reg MSTR;
wire CPOL;
wire CPHA;

//SPI_CR2
wire TXEIE;
wire RXNEIE;
wire ERRIE;
wire SSOE;
wire TXDMAE;
wire RXDMAE;

//寄存器读写标志
wire SR_r;
wire DR_w;
wire DR_r;
wire CR1_w;
wire CR1_r;

//inout
//wire sclk_in = sclk;
//wire miso_in = miso;
//wire mosi_in = mosi;
//wire nss_in = nss;   

//wire miso_out;
//wire mosi_out;
//(*dont_touch = "yes"*)wire nss_out; 

//sclk们
wire sclk_out_div;//分频输出
wire sclk_m_div;//分频输出
wire sclk_m = CPHA ? ~sclk_m_div : sclk_m_div;//主机时钟驱动
//wire sclk_out = CPOL ? ~sclk_out_div : sclk_out_div;//主机时钟输出
wire sclk_s = (CPOL^CPHA) ? ~sclk_in : sclk_in;//从机时钟驱动

assign sclk_out = CPOL ? ~sclk_out_div : sclk_out_div;//主机时钟输出
assign io_ctl_sclk = MSTR ? 1'b1 : 1'b0;//1 is out , 0 is in
assign io_ctl_miso = MSTR ? 1'b0 : ((BIDIMODE & !BIDIOE) ? 1'b0 : 1'b1);
assign io_ctl_mosi = MSTR ? ((BIDIMODE & !BIDIOE) ? 1'b0 : 1'b1) : 1'b0;
assign io_ctl_nss = (MSTR & SSOE) ? 1'b1 : 1'b0;

//assign sclk = MSTR ? sclk_out : 1'bz;
//assign miso = MSTR ? 1'bz : ((BIDIMODE & !BIDIOE) ? 1'bz : miso_out);
//assign mosi = MSTR ? ((BIDIMODE & !BIDIOE) ? 1'bz : mosi_out) : 1'bz;
//assign nss = (MSTR & SSOE) ? nss_out : 1'bz;

//nss
assign nss_reg = SSM ? SSI : nss_in;//内部nss信号

//always@(posedge clk or negedge rst_n) begin
//    if(!rst_n)  nss_reg <= 1'b0;
//    else if(SSM) nss_reg <= SSI;
//    else nss_reg <= nss_in;
//end

//MODF
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  MODF_reg <= 1'b0;
    else if(MSTR & !nss_reg) MODF_reg <= 1'b1;
end

always@(posedge clk) begin
    if(MODF) begin
        MSTR <= 1'b0;
        SPE <= 1'b0;
    end
    else begin
        MSTR <= MSTR_apb;
        SPE <= SPE_apb;
    end
end

//主从机使能
reg M_en;
reg S_en;

always@(posedge clk) begin
    if(SPE & nss_reg & MSTR) M_en <= 1'b1;
    else M_en <= 1'b0;
end

always@(posedge clk) begin
    if(SPE & !nss_reg & !MSTR) S_en <= 1'b1;
    else S_en <= 1'b0;
end

//模块例化
wire enable_m;
wire enable_s;
wire crc_en_m;
wire crc_en_s;
wire enable = MSTR ? enable_m : enable_s;
wire crc_en = MSTR ? crc_en_m : crc_en_s;
clk_div clk_div_u(
.clk      (clk     ),
.rst_n    (rst_n   ),
.rx_only  (RXONLY  ),
.M_en     (M_en    ),
.DFF      (DFF     ),
.enable   (enable_m | crc_en_m  ),
.BR       (BR      ),
.nss_out  (nss_out  ),
.sclk_m   (sclk_m_div  ),
.sclk_out (sclk_out_div)
);

wire rx_m = MSTR ? ((BIDIMODE & !BIDIOE) ? mosi_in : miso_in) : 1'b0;
wire rx_s = MSTR ? 1'b0 : ((BIDIMODE & !BIDIOE) ? miso_in : mosi_in);
wire tx_m;
wire tx_s;
assign mosi_out = (BIDIMODE & !BIDIOE) ? 1'b0 : tx_m;

wire [15:0] RDR_m;
wire [15:0] RDR_s;
assign RDR = MSTR ? RDR_m : RDR_s;

(*dont_touch = "yes"*)wire busy_m;
(*dont_touch = "yes"*)wire busy_s;
assign BSY = RXONLY ? 1'b1 : (MSTR ? busy_m : busy_s);

wire RXNE_m;
wire RXNE_s;
assign RXNE = MSTR ? RXNE_m : RXNE_s;

wire TXE_m;
wire TXE_s;
assign TXE = MSTR ? TXE_m : TXE_s;

wire OVR_m;
wire OVR_s;
wire OVR_in = MSTR ? OVR_m : OVR_s;

wire rxonly = BIDIMODE ? (~BIDIOE) : RXONLY;

  spi_m spi_m_u(
.sclk    (sclk_m),
.clk     (clk     ),
.rst_n   (rst_n   ),
.DFF     (DFF     ),
.M_en    (M_en    ),
.DR_w    (DR_w    ),
.data_in (TDR ),
.LSBFIRST(LSBFIRST),
.rx      (rx_m    ),
.DR_r    (DR_r    ),
.rxonly  (RXONLY  ),
.data_out(RDR_m),
.OVR     (OVR_m     ),
.CRC_next(CRCNEXT),
.TXCRC   (TXCRC   ),
.CPHA    (CPHA    ),
.RXNE    (RXNE_m    ),
.TXE     (TXE_m     ),
.enable  (enable_m  ),
.crc_en  (crc_en_m  ),
.busy    (busy_m    ),
.tx      (tx_m )
  );

spi_s spi_s_u(
.sclk    (sclk_s  ),
.clk     (clk     ),
.rst_n   (rst_n   ),
.S_en    (S_en    ),
.DR_w    (DR_w    ),
.DFF     (DFF     ),
.data_in (TDR ),
.LSBFIRST(LSBFIRST),
.rx      (rx_s      ),
.DR_r    (DR_r    ),
.rxonly  (rxonly  ),
.data_out(RDR_s),
.OVR     (OVR_s     ),
.CRC_next(CRCNEXT),
.TXCRC   (TXCRC   ),
.CPHA    (CPHA    ),
.RXNE    (RXNE_s    ),
.TXE     (TXE_s     ),
.enable  (enable_s  ),
.crc_en  (crc_en_s  ),
.busy    (busy_s  ),
.tx      (miso_out )
  );
  
wire CRC_busy_rx;
wire CRC_busy_tx;
assign CRCBSY = CRC_busy_rx | CRC_busy_tx;

CRC_rx CRC_rx_u(
.clk     (clk     ),
.rst_n   (rst_n   ),
.CRC_en  (CRCEN  ),
.RXNE    (RXNE    ),
.DFF     (DFF     ),
.CRC_next(CRCNEXT),
.datain  (RDR  ),
.CRCERR  (CRCERR),
.poly    (CRCPOLY    ),
.CRC_out (RXCRC ),
.CRC_busy(CRC_busy_rx)
);

CRC_tx CRC_tx_u(
.clk     (clk     ),
.rst_n   (rst_n   ),
.CRC_en  (CRCEN  ),
//.TXE     (TXE     ),
.DFF     (DFF     ),
//.CRC_next(CRCNEXT),
.datain  (TDR  ),
.poly    (CRCPOLY    ),
.enable  (enable),
.crc_en  (crc_en),
.CRC_out (TXCRC ),
.CRC_busy(CRC_busy_tx)
);

state0 OVR_u(
.clk        (clk),
.rst_n      (rst_n),
.S1         (DR_r),
.S2         (SR_r),
.S3         (OVR_in),
.stateout   (OVR)
);

state0 MODF_u(
.clk        (clk),
.rst_n      (rst_n),
.S1         (SR_r),
.S2         (CR1_w),
.S3         (MODF_reg),
.stateout   (MODF)
);

reg_apb reg_apb_u (
    .clk(clk),
    .rst_n(rst_n),
    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PSEL(PSEL),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .BSY(BSY),
    .OVR(OVR),
    .MODF(MODF),
    .CRCERR(CRCERR),
    .RXNE(RXNE),
    .TXE(TXE),
    .CRCBSY(CRCBSY),
    .TDR(TDR),
    .RDR(RDR),
    .CRCPOLY(CRCPOLY),
    .TXCRC(TXCRC),
    .RXCRC(RXCRC),
    .BIDIMODE(BIDIMODE),
    .BIDIOE(BIDIOE),
    .CRCEN(CRCEN),
    .CRCNEXT(CRCNEXT),
    .DFF(DFF),
    .RXONLY(RXONLY),
    .SSM(SSM),
    .SSI(SSI),
    .LSBFIRST(LSBFIRST),
    .SPE(SPE_apb),
    .BR(BR),
    .MSTR(MSTR_apb),
    .CPOL(CPOL),
    .CPHA(CPHA),
    .TXEIE(TXEIE),
    .RXNEIE(RXNEIE),
    .ERRIE(ERRIE),
    .SSOE(SSOE),
    .TXDMAE(TXDMAE),
    .RXDMAE(RXDMAE),
    .SR_r(SR_r),
    .DR_w(DR_w),
    .DR_r(DR_r),
    .CR1_w(CR1_w),
    .CR1_r(CR1_r)
  );
  

/*********************中断检测*************************/
assign SPI_interrupt = (RXNE & RXNEIE) | ((MODF | OVR | CRCERR) & ERRIE) | (TXE & TXEIE) | 1'b0;
/*************************************************/
endmodule
