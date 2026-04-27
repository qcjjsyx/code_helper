// Receive FIFO Controller
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the receive FIFO control
// for the M16550s UART.

// Revision history:
//
// $Log: m3s008fd.v,v $
// Revision 1.5  2004/12/10
// ECN02360 rtl update
//
// Revision 1.4  2001/03/26
// The redundant logic has been eliminated - ECN 01472
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s008fd (
  CLOCK, RESETN, WrCyc, RdCyc,
  ADD0, ADD2, ADD5,
  CharEn, DI1, DI0, FIFOE, RTM, RTL,
  ROP_A, RIP_A, REmpt, RFull, RxAboveTrig,
  RHold1, RRST, FOE, NVWR, NVRD
  );

input CLOCK, RESETN, WrCyc, RdCyc;
input ADD0, ADD2, ADD5;
input CharEn, DI1, DI0, FIFOE, RTM, RTL;

output [3:0] ROP_A, RIP_A;
output       REmpt, RFull;     
output       RxAboveTrig;
output       RHold1, RRST, FOE;
output       NVRD, NVWR;


reg [3:0] ROP_A, RIP_A;
reg [4:0] OP_A, IP_A, ROffset;
reg       DRRST, RHold1;
reg       RxTrig1, RxTrig2, RxTrig3, RxTrig4;
reg       RxAboveTrig;
reg       DOE, DOER, FOE, RRST, NVWR, NVRD;
reg       REmpt, RFull;

// Generate reset for Rx FIFO counter using bit 1 in FCR & MR
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
    DRRST <= 1'b0;   
  else
    DRRST <= WrCyc & ADD2 & DI1 & DI0; //if we write the FCR's bit0, bit1 then set DRRST
end

// Holds FIFOs in reset when disabled
always @(DRRST or FIFOE)
  RRST = DRRST | ~FIFOE;

// Prevent writing if FIFO is full
always @(RFull or CharEn)
  NVWR = RFull | ~CharEn;

// Prevent reading if FIFO is empty
always @(RdCyc or ADD0 or REmpt or FIFOE)
  NVRD = ~(RdCyc & ADD0 & ~REmpt & FIFOE);

// Counter is held in reset when FIFOs are disabled
// Rx FIFO input counter
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
    IP_A <= 5'b00000;
  else if (RRST) 	     
    IP_A <= OP_A;
  else if (~NVWR) //if FIFO not full and we have a new packet
    IP_A <= IP_A + 5'b00001; // then increment the Input Counter of the FIFO
end


// Rx FIFO output counter
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
    OP_A <= 5'b00000;
  else if (~NVRD)
    OP_A <= OP_A + 5'b00001;
end	

// Works out difference between input and output pointers.
always @(IP_A or OP_A)
  ROffset = IP_A - OP_A;

// Detect when FIFO above the trigger level
always @(ROffset) 
begin
  RHold1  = (ROffset == 1);                 // Fifo holds 1 char of information
  RxTrig1 = (ROffset >= 1);    
  RxTrig2 = (ROffset >= 4);
  RxTrig3 = (ROffset >= 8);
  RxTrig4 = (ROffset >= 14);
end

always @(RTM or RTL or RxTrig1 or RxTrig2 or RxTrig3 or RxTrig4)
begin
  case ({RTM,RTL})
    2'b00   : RxAboveTrig = RxTrig1;
    2'b01   : RxAboveTrig = RxTrig2;
    2'b10   : RxAboveTrig = RxTrig3;
    default : RxAboveTrig = RxTrig4;
  endcase
end


// Decide if fifo is empty or full
always @(ROffset)
begin
  REmpt = (ROffset == 0);
  RFull = ROffset[4];
end

// Fifo mode OE indicator

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DOER <= 1'b0;
  else if (RRST)      
    DOER <= DOE;
  else if (RFull & CharEn) //if FIFO is Full and we have a new packet of data
    DOER <= ~DOE; // then set the overrun error OE

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DOE <= 1'b0;
  else if (RdCyc & ADD5 & FOE) // if we read the LSR and OE=1
    DOE <= DOER; // clear the Overrun error

always @(DOE or DOER)
  FOE = DOE ^ DOER; // this is the overrun error when the FIFO is enabled

// OP_A and IP_A reduced by 1 bit for exporting to upper level
always @(IP_A or OP_A)
begin
  RIP_A = IP_A[3:0];
  ROP_A = OP_A[3:0];
end


endmodule
