// Address Decode and Output Data Mux
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the address decoding, register file and output data muxing
// for the M16550s UART.

// Revision history:
//
// $Log: m3s003fd.v,v $
// Revision 1.5  2004/12/10
// ECN02360 rtl update
//
// Revision 1.4  2001/03/26
// fixed problem writing to FIFO Control Register bits 3,6,7 - ECN 01473
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s003fd (
  CLOCK, RESETN, RD, VAL, 
  ADDRESS, WDATA, IIR, IER, DIV, RxData,
  LOOP1, OUT1, OUT2, RTS, DTR, TSRE, THRE,
  BI, FE, PE, OE, DR, ERF, DCD, RI,
  DSR, CTS, DDCD, TERI, DDSR, DCTS,
  PEN, WLS0, WLS1, STB, EPS, SP, SB, ACK, NDVL,
  RDATA, WrCyc, RdCyc, DataIn,
  ADD0, ADD1, ADD2, ADD4, ADD5, ADD6, ADD0B, ADD1B,
  FIFOE, DMA, RTL, RTM
  );
 

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input        CLOCK, RESETN, RD, VAL;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  [2:0] ADDRESS;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  [7:0] WDATA;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  [3:0] IIR, IER;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [15:0] DIV;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input  [7:0] RxData;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input        LOOP1, OUT1, OUT2, RTS, DTR, TSRE, THRE;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input        BI, FE, PE, OE, DR, ERF, DCD, RI;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input        DSR, CTS, DDCD, TERI, DDSR, DCTS;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       PEN, WLS0, WLS1, STB, EPS, SP, SB, ACK, NDVL;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [7:0] RDATA, DataIn; 
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       WrCyc, RdCyc;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       ADD0, ADD1, ADD2, ADD4, ADD5, ADD6, ADD0B, ADD1B;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output       FIFOE, DMA, RTL, RTM;

reg       ACK, WrCyc, RdCyc;
reg [2:0] Addr;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [7:0] DataIn;
reg       ADD0, ADD1, ADD2, ADD3, ADD4, ADD5, ADD6, ADD7;
reg [7:0] LCR, SCR, RDATA;
reg       WLS0, WLS1, STB, PEN, EPS, SP, SB;
reg       DMA, RTL, RTM;
reg       FIFOE, NDVL;
reg       ADD0B, ADD1B;


// Latch address and input data bus
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
   begin
    Addr <= 3'b000;
    DataIn <= 8'h00;
   end
  else
   begin
    if (VAL) Addr <= ADDRESS;
    if (VAL & ~RD) DataIn <= WDATA;
   end

// Generate read and write cycles
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
   begin
    RdCyc <= 1'b0;
    WrCyc <= 1'b0;
   end
  else
   begin
    RdCyc <= VAL & RD & ~RdCyc;  // defines the read cycle 
    WrCyc <= VAL & ~RD & ~WrCyc; // defines the write cycle 
   end

// Acknowledge
always @(RdCyc or WrCyc)
  ACK = RdCyc | WrCyc;

// Decode address
always @(Addr or LCR)
begin
  ADD0 = ~Addr[2] & ~Addr[1] & ~Addr[0] & ~LCR[7];
  ADD1 = ~Addr[2] & ~Addr[1] &  Addr[0] & ~LCR[7];
  ADD2 = ~Addr[2] &  Addr[1] & ~Addr[0];
  ADD3 = ~Addr[2] &  Addr[1] &  Addr[0];
  ADD4 =  Addr[2] & ~Addr[1] & ~Addr[0];
  ADD5 =  Addr[2] & ~Addr[1] &  Addr[0];
  ADD6 =  Addr[2] &  Addr[1] & ~Addr[0];
  ADD7 =  Addr[2] &  Addr[1] &  Addr[0];
  ADD0B = ~Addr[2] & ~Addr[1] & ~Addr[0] & LCR[7];
  ADD1B = ~Addr[2] & ~Addr[1] &  Addr[0] & LCR[7];
end

// Line Control Register
// Controls the format of the RX and TX words
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
    LCR <= 8'h00;
  else if (ADD3 & WrCyc)
    LCR <= DataIn;
end

// Assign LCR bits
always @(LCR)
begin
  WLS0 = LCR[0];
  WLS1 = LCR[1];
  STB = LCR[2];
  PEN = LCR[3];
  EPS = LCR[4];
  SP = LCR[5];
  SB = LCR[6];
end


// FIFO Control Register (write only)
//
// Reset signals not stored as self clearing.
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
  begin
    FIFOE <= 1'b0;
    DMA   <= 1'b0;
    RTL   <= 1'b0;
    RTM   <= 1'b0;
  end 
  else if (ADD2 & WrCyc)
  begin
    FIFOE <= DataIn[0];
    if (DataIn[0])
    begin
      DMA <= DataIn[3];
      RTL <= DataIn[6];
      RTM <= DataIn[7];
    end
    else
    begin
      DMA <= 1'b0;
      RTL <= 1'b0;
      RTM <= 1'b0;
    end 
  end
end


// Scratch Register
// Note that it is not reset
always @(posedge CLOCK)
  if (WrCyc & ADD7)
    SCR <= DataIn;

// Output data multiplexer
always @(ADD0 or ADD1 or ADD2 or ADD3 or ADD4 or ADD5 or ADD6 or ADD7 or
  ADD0B or ADD1B or
  RxData or IER or FIFOE or IIR or LCR or
  LOOP1 or OUT2 or OUT1 or RTS or DTR or ERF or TSRE or THRE or BI or FE or PE or OE or DR or
  DCD or RI or DSR or CTS or DDCD or TERI or DDSR or DCTS or SCR or DIV)
begin
  RDATA = ({8{ADD0}} & RxData) |
       ({4'h0, ({4{ADD1}} & IER)}) |
       ({(ADD2 & FIFOE), (ADD2 & FIFOE), 2'b00, ({4{ADD2}} & IIR)}) |
       ({8{ADD3}} & LCR) |
       ({3'b000, (ADD4 & LOOP1), (ADD4 & OUT2), (ADD4 & OUT1), (ADD4 & RTS),
	 (ADD4 & DTR)}) |
       ({(ADD5 & ERF), (ADD5 & TSRE), (ADD5 & THRE), (ADD5 & BI),
	 (ADD5 & FE), (ADD5 & PE), (ADD5 & OE), (ADD5 & DR)}) |
       ({(ADD6 & DCD), (ADD6 & RI), (ADD6 & DSR), (ADD6 & CTS),
	 (ADD6 & DDCD), (ADD6 & TERI), (ADD6 & DDSR), (ADD6 & DCTS)}) |
       ({8{ADD7}} & SCR) |
       ({8{ADD0B}} & DIV[7:0]) | ({8{ADD1B}} & DIV[15:8]);
end

// Generate NDVL - Output TRI-State buffer enable
always @(RdCyc)
  NDVL = ~RdCyc;


endmodule
	
