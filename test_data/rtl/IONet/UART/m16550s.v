// M16550s UART
// Copyright Mentor Graphics Corporation and Licensors 2001

// This is the top level module. It instantiates and connects
// up the lower levels.
// 
// Revision history:
//
// $Log: m16550s.v,v $
// Revision 1.3  2004/12/10
// ECN02360 rtl update
//
// Revision 1.2  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
// 

module m16550s (
  CLOCK, RESETN,
  ADDRESS, WDATA, RD, VAL,
  RCLK, RCLK_BAUD, BRGE,
  NDCD, NRI, NDSR, NCTS, SIN,
  RDATA, IRQ, ACK, NDVL,
  NOUT2, NOUT1, NRTS, NDTR, SOUT, BAUD,
  TXRDY, RXRDY
  );

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       CLOCK, RCLK, RESETN;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [2:0] ADDRESS;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [7:0] WDATA;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       RD, VAL, NDCD, NRI, NDSR, NCTS, SIN, RCLK_BAUD, BRGE;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [7:0] RDATA;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       IRQ, ACK, NDVL, NOUT2, NOUT1, NRTS, NDTR, SOUT, BAUD;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       TXRDY, RXRDY;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [7:0] RDATA;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        IRQ, ACK, NDVL, NOUT2, NOUT1, NRTS, NDTR, SOUT, BAUD;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        TXRDY, RXRDY;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        TXD, THRe, PEN, WLS0, WLS1, STB, EPS, SP, SB;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [7:0] RxData, TxFIFO, RxFIFO, RxBuff, DataIn;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        DR, FE, OE, PE, BI, ADD0, ADD5;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        ADD1, ADD2, ADD4, ADD6, ADD0B, ADD1B;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        WrCyc, RdCyc;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [3:0] IER, IIR;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [15:0] DIV;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        TxClkEnab, RxClkEnab;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        LOOP1, RTS, DTR, TSRE, DDCD, TERI, DDSR, DCTS, BRKTD;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [3:0] TIP_A, TOP_A;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [3:0] RIP_A, ROP_A;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire  [2:0] OP_ED;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        TEmpt, TFull, FIFOE;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        FRE, PTE, FBRK, ERF, RTO, FOE, FERF;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        RFull, REmpt, RRST, DMA, RTL, RTM;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        LoadTxBuff, CharEn;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        RHold1, RxAboveTrig;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        NTRD, NTWR, NRWR, NRRD;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        Delta_TRST;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        RI;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        OUT2;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        OUT1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        DSR;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        DCD;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire        CTS;


// Instantiate the modules and connect them up - no logic at this top
// level of the design

// Transmit block
m3s001fd U1(
  CLOCK, RESETN, TxClkEnab, WrCyc, ADD0, TxFIFO, DataIn, 
  PEN, WLS0, WLS1, STB, EPS, SP, FIFOE, TEmpt,
  TXD, THRe, TSRE, LoadTxBuff
  );


// Receive block
m3s002fd U2(
  CLOCK, RESETN, RxClkEnab, RdCyc, ADD0, ADD5,
  RDATA[4], RDATA[3], RDATA[2], RDATA[1],
  PEN, WLS0, WLS1, STB, EPS, SP,
  SIN, LOOP1, BRKTD, RxFIFO,
  FOE, OP_ED[2], OP_ED[1], OP_ED[0], FERF, FIFOE, REmpt, RRST,
  RxData, RxBuff, CharEn, DR, FE, OE, PE, BI,
  ERF, RTO, FRE, PTE, FBRK
  );


// Address decode block 
m3s003fd U3(
  CLOCK, RESETN, RD, VAL,
  ADDRESS, WDATA, IIR, IER, DIV, RxData,
  LOOP1, OUT1, OUT2, RTS, DTR, TSRE, THRe,
  BI, FE, PE, OE, DR, ERF, DCD, RI,
  DSR, CTS, DDCD, TERI, DDSR, DCTS,
  PEN, WLS0, WLS1, STB, EPS, SP, SB, ACK, NDVL,
  RDATA, WrCyc, RdCyc, DataIn,
  ADD0, ADD1, ADD2, ADD4, ADD5, ADD6, ADD0B, ADD1B,
  FIFOE, DMA, RTL, RTM
  );


// Interrupt Priority encoder 
m3s004fd U4 (
  CLOCK, RESETN, WrCyc, RdCyc, ADD0, ADD1, ADD2,
  DataIn[3:0], DR, BI, FE, PE, OE, RTO,
  DDCD, TERI, DDSR, DCTS, THRe,
  LoadTxBuff, FIFOE,
  DMA, TFull, RHold1, RxAboveTrig,
  TSRE, TEmpt, Delta_TRST, RRST,
  IRQ, IIR, IER, TXRDY, RXRDY
  );


// Baud Rate generation block
m3s005fd U5 (
  CLOCK, RESETN, RCLK, RCLK_BAUD, BRGE, WrCyc, ADD0B, ADD1B, DataIn,
  DIV, BAUD, TxClkEnab, RxClkEnab
  );


// Modem interface block
m3s006fd U6 (
  CLOCK, RESETN, WrCyc, RdCyc, ADD4, ADD6, DataIn[4:0],
  NDCD, TXD, SB, NRI, NDSR, NCTS,
  NOUT1, NOUT2, NRTS, NDTR, BRKTD, SOUT, LOOP1,
  OUT1, OUT2, DCD, RI, DSR, CTS, RTS, DTR,
  DDCD, DCTS, DDSR, TERI
  );


// Tx FIFO controller
m3s007fd U7 (
  CLOCK, RESETN, WrCyc, ADD0, ADD2, LoadTxBuff,
  DataIn[2], DataIn[0], FIFOE,
  TOP_A, TIP_A, TEmpt, TFull, NTWR, NTRD, Delta_TRST
  );


// Rx FIFO controller
m3s008fd U8 (
  CLOCK, RESETN, WrCyc, RdCyc,
  ADD0, ADD2, ADD5,
  CharEn, DataIn[1], DataIn[0], FIFOE, RTM, RTL,
  ROP_A, RIP_A, REmpt, RFull, RxAboveTrig,
  RHold1, RRST, FOE, NRWR, NRRD
  );


// Tx FIFO
m3s009fd U9 (
  CLOCK, RESETN, DataIn, TIP_A, TOP_A, NTWR, NTRD, TxFIFO
  );


// Rx FIFO
m3s010fd U10 (
  CLOCK, RESETN, RxBuff, RIP_A, ROP_A, NRWR, NRRD, RxFIFO
  );


// Error fifo
m3s011fd U11 (
  CLOCK, RESETN, RdCyc, ADD0, ADD5, RIP_A, ROP_A,
  PTE, FRE, FBRK, CharEn, RRST, REmpt, RFull,
  OP_ED, FERF
  );

endmodule

