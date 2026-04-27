`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/23 20:02:29
// Design Name: 
// Module Name: reg_apb
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


module reg_apb(
input           clk                 ,
input           rst_n                ,
//APB signal
input[7:0]     PADDR               ,  
input           PENABLE             ,
input           PSEL                ,
input [31:0]    PWDATA              ,
input           PWRITE              ,
output [31:0]   PRDATA              ,
output          PREADY              ,
output          PSLVERR             ,

//SPI_SR
input         BSY                ,
input         OVR                ,
input         MODF               ,
input         CRCERR             ,
input         RXNE               ,
input         TXE                ,
input         CRCBSY             ,

//SPI_DR
output  reg [15:0]  TDR                 ,
input        [15:0]  RDR                 ,

//SPI_CRCPR
output  reg [15:0]  CRCPOLY             ,

//SPI_TXCRCR
input  [15:0]  TXCRC               ,

//SPI_RXCRCR
input  [15:0]  RXCRC               ,

//SPI_CR1
output  reg         BIDIMODE            ,     
output  reg         BIDIOE              ,      
output  reg         CRCEN               ,   
output  reg         CRCNEXT             ,    
output  reg         DFF                 ,     
output  reg         RXONLY              ,   
output  reg         SSM                 ,  
output  reg         SSI                 ,   
output  reg         LSBFIRST            , 
output  reg         SPE                 , 
output  reg  [2:0]  BR                  ,     
output  reg         MSTR                ,     
  
output  reg         CPOL                ,
output  reg         CPHA                ,    

//SPI_CR2
output  reg         TXEIE               ,    
output  reg         RXNEIE              ,
output  reg         ERRIE               ,    
output  reg         SSOE                ,     
output  reg         TXDMAE              ,     
output  reg         RXDMAE              ,     





//寄存器读写标志
output              SR_r                ,
output              DR_w                ,
output              DR_r                ,
output              CR1_w               ,
output              CR1_r               
    );

//寄存器地址
parameter SPI_SR = 8'h72;
parameter SPI_DR = 8'h73;
parameter SPI_CRCPR = 8'h74;
parameter SPI_CR1 = 8'h70;
parameter SPI_CR2 = 8'h71;
parameter SPI_RXCRCR = 8'h75;
parameter SPI_TXCRCR = 8'h76;

//变量定义
//寄存器变量

//总线变量
reg [31:0]rdata;
wire read;
wire write;
wire [31:0]addr;

//assign addr = (PADDR[31:16] == 16'h4001) ? PADDR[7:0] : 8'hz;
assign addr = PADDR;
assign PSLVERR = 1'b0;
assign read = PSEL & (!PWRITE);
assign write = PENABLE & PSEL & PWRITE;
assign PREADY = 1'b1;

//寄存器读写标志信号
assign SR_r = ( read & ( addr == SPI_SR ) ) ? 1'b1 : 1'b0; 
assign DR_r = ( read && ( addr == SPI_DR ) ) ? 1'b1 : 1'b0; 
assign CR1_r = ( read && ( addr == SPI_CR1 ) ) ? 1'b1 : 1'b0;  
assign DR_w = ( write && ( addr == SPI_DR ) ) ? 1'b1 : 1'b0; 
assign CR1_w = ( write && ( addr == SPI_CR1 ) ) ? 1'b1 : 1'b0; 
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_CR1_w;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_CR1_w_buf;
always@(posedge clk) begin
    r_CR1_w_buf <= CR1_w;
    r_CR1_w <= r_CR1_w_buf; 
end

/****************  read  ***************/

assign PRDATA = (read) ? rdata : 32'bz;
always@(*) 
begin
    case(addr)
//        SPI_SR:   rdata = {22'b0, CTS, LBD, TXE, TC, RXNE, IDLE, ORE, NE, FE, PE }; //无CTS，LBD信号，因为没添加相关模块
        SPI_SR:   rdata = {24'b0, BSY, OVR, MODF, CRCERR, CRCBSY, 1'b0, TXE, RXNE }; 
        SPI_DR:   rdata = {16'b0, RDR }; 
        SPI_CR1:  rdata = {16'b0, BIDIMODE, BIDIOE, CRCEN, CRCNEXT, DFF, RXONLY, SSM, SSI, LSBFIRST, SPE, BR, MSTR, CPOL, CPHA}; 
        SPI_CR2:  rdata = {24'b0, TXEIE, RXNEIE, ERRIE, 2'b0, SSOE, TXDMAE, RXDMAE}; 
        SPI_CRCPR: rdata = {16'b0, CRCPOLY };
        SPI_TXCRCR: rdata = {16'b0, TXCRC };
        SPI_RXCRCR: rdata = {16'b0, RXCRC };
        default:    rdata = 32'b0;
    endcase
end
/****************************************************/



/*********************  write  **********************/
//SPI_DR
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        TDR<=16'b0;
    end
    else if (write && addr == SPI_DR)
    begin
        TDR<=PWDATA[15:0];
    end
end

//SPI_CRCPR
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        CRCPOLY <= 16'h0007;
    end
    else if (write && addr == SPI_CRCPR)
    begin
        CRCPOLY <= PWDATA[15:0];
    end
end

//SPI_CR1
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        BIDIMODE <= 1'b0;
        BIDIOE   <= 1'b0;
        CRCEN    <= 1'b0;
        CRCNEXT  <= 1'b0;
        DFF      <= 1'b0;
        RXONLY   <= 1'b0;
        SSM      <= 1'b0;
        SSI      <= 1'b0;
        LSBFIRST <= 1'b0;
        SPE      <= 1'b0;
        BR       <= 3'b0;
        MSTR     <= 1'b0;
        CPOL     <= 1'b0;
        CPHA     <= 1'b0;
    end
    else if (write && addr == SPI_CR1)
    begin
        BIDIMODE<= PWDATA[15];
        BIDIOE  <= PWDATA[14];
        CRCEN   <= PWDATA[13];
        CRCNEXT <= PWDATA[12];
        DFF     <= PWDATA[11];
        RXONLY  <= PWDATA[10];
        SSM     <= PWDATA[ 9];
        SSI     <= PWDATA[ 8];
        LSBFIRST<= PWDATA[ 7];
        SPE     <= PWDATA[ 6];
        BR      <= PWDATA[5:3];
        MSTR    <= PWDATA[ 2];
        CPOL    <= PWDATA[ 1];
        CPHA    <= PWDATA[ 0];
    end
end

//SPI_CR2
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        TXEIE    <= 1'b0;
        RXNEIE   <= 1'b0;
        ERRIE    <= 1'b0;
        SSOE     <= 1'b0;
        TXDMAE   <= 1'b0;
        RXDMAE   <= 1'b0;
    end
    else if (write && addr == SPI_CR2)
    begin
        TXEIE    <= PWDATA[7];
        RXNEIE   <= PWDATA[6];
        ERRIE    <= PWDATA[5];
        SSOE     <= PWDATA[2];
        TXDMAE   <= PWDATA[1];
        RXDMAE   <= PWDATA[0];
    end
end

/*************************************************************/
endmodule
