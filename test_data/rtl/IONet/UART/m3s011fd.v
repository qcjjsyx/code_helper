// Error Bit FIFO Storage
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the error FIFO top level for the M16x50 UART.
// This module forms the 3-bit storage to hold the error flags 
// for each received character of data. 

// Revision history:
//
// $Log: m3s011fd.v,v $
// Revision 1.4  2004/12/10
// ECN02360 rtl update
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s011fd (
  CLOCK, RESETN, RdCyc, ADD0, ADD5, IP_A, OP_A,
  PTE, FRE, BRI, CharEn, RRST, REmpt, RFull,
  OP_D, FERF
  );

input       CLOCK, RESETN, RdCyc, ADD0, ADD5;
input [3:0] IP_A, OP_A;
input       PTE, FRE, BRI, CharEn, RRST, REmpt, RFull;

output [2:0] OP_D;
output       FERF;


reg [2:0] IpData, OP_D;
reg [4:0] CountWr, CountRd;
reg       NVWR, FERF;
reg       ErrRead, OpRead, OpEnab;
wire [2:0] OpData;


// Generate input data from error flags
always @(PTE or FRE or BRI)
  IpData = {PTE,FRE,BRI};

// Generate write enable
always @(CharEn or RFull)
begin
  NVWR = ~(CharEn & ~RFull);
end

// FIFO RAM block
m3s013fd U1 (CLOCK, RESETN, IpData, IP_A, OP_A, NVWR, OpData);

// Generate signal indicating the the current output error bits have been read
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    ErrRead <= 1'b0;
  else if (RdCyc & ADD5 & ~REmpt)
    ErrRead <= 1'b1;
  else if (RdCyc & ADD0)
    ErrRead <= 1'b0;

// Enable error output bits when FIFO not empty and
// LSR not read for current output character
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    OpRead <= 1'b0;
  else if (RdCyc & ADD5)
    OpRead <= 1'b0;
  else if ((RdCyc & ADD0) | (NVWR & REmpt))
    OpRead <= 1'b1;

always @(OpRead or REmpt)
  OpEnab = OpRead & ~REmpt;

always @(OpEnab or OpData)
  OP_D = {3{OpEnab}} & OpData;

// Count errors written to FIFO
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    CountWr <= 5'b00000;
  else if (RRST | (REmpt & NVWR))
    CountWr <= CountRd;
  else if (~NVWR & (IpData[0] | IpData[1] | IpData[2]))
    CountWr <= CountWr + 5'b00001;

// Count errors read from FIFO
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    CountRd <= 5'b00000;
  else if (RdCyc & (ADD0 | ADD5) & ~ErrRead & ~REmpt & (OpData[0] | OpData[1] | OpData[2]))
    CountRd <= CountRd + 5'b00001;

// Determine whether there are any valid error in the FIFO
always @(CountWr or CountRd)
  if (CountWr == CountRd)
    FERF = 1'b0;
  else
    FERF = 1'b1;

endmodule

