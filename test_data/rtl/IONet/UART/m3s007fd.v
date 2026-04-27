// Transmit FIFO Controller
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the transmit FIFO control
// for the M16550s UART.

// Revision history:
//
// $Log: m3s007fd.v,v $
// Revision 1.4  2004/12/10
// ECN02360 rtl update
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s007fd (
  CLOCK, RESETN, WrCyc, ADD0, ADD2, LoadTxBuff,
  DI2, DI0, FIFOE,
  TOP_A, TIP_A, TEmpt, TFull, NVWR, NVRD, Delta_TRST
  );

input CLOCK, RESETN, WrCyc, ADD0, ADD2, LoadTxBuff;
input DI2, DI0, FIFOE;

output [3:0] TOP_A, TIP_A;
output       TEmpt, TFull;
output       NVWR, NVRD;
output       Delta_TRST;  // Delta version of TX FIFO reset

reg [3:0] TOP_A, TIP_A;
reg [4:0] OP_A, IP_A, TOffset;
reg       TRST, TEmpt, TFull;
reg       NVRD, NVWR, Delta_TRST;


// Generate reset for Tx FIFO counter using bit 2 in FCR
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    Delta_TRST <= 1'b0;
  else
    Delta_TRST <= WrCyc & ADD2 & DI2 & DI0;

// Holds FIFOs in reset when disabled
always @(Delta_TRST or FIFOE)
  TRST = Delta_TRST | ~FIFOE;

// Prevent writing if FIFO is full
always @(WrCyc or ADD0 or TOffset or FIFOE)
  NVWR = ~(WrCyc & ADD0 & ~TOffset[4] & FIFOE);

// Prevent reading if FIFO is empty
always @(TEmpt or LoadTxBuff)
  NVRD = (TEmpt | ~LoadTxBuff);

// Counter is held in reset when FIFOs are disabled
//
// Tx FIFO input counter
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    IP_A <= 5'b00000;
  else if (~NVWR)      // Only write to FIFO when not full
    IP_A <= IP_A + 5'b00001;

// Tx FIFO output counter
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    OP_A <= 5'b00000;
  else if (TRST)
    OP_A <= IP_A;        // Synchronous reset
  else if (~NVRD)        // Only read from FIFO when it contains something
    OP_A <= OP_A + 5'b00001;

// Works out difference between input and output pointers.
always @(IP_A or OP_A)
  TOffset = (IP_A - OP_A);

// Decide if FIFO is below trigger level or holding 1 character
always @(TOffset)
begin
  TEmpt = (TOffset == 0);
end

// IP_A & OP_A reduced by 1 bit for exporting to upper level
always @(IP_A or OP_A)
begin
  TIP_A = IP_A[3:0];
  TOP_A = OP_A[3:0];
end

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TFull <= 1'b0;
  else
    TFull <= ((TFull | TOffset[4]) & ~TEmpt);

endmodule

