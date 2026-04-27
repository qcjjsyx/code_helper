// FIFO Element Cell
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the FIFO elements
// for the M16550s UART.
// The module uses a read strobe as well as a write strobe 
// to allow substitution of a dual port RAM for the whole FIFO. 

// Revision history:
//
// $Log: m3s012fd.v,v $
// Revision 1.3  2004/12/10
// ECN02360 rtl update
//
// Revision 1.2  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s012fd (
  CLOCK, RESETN, IP_D, IpSel, OpSel, NVWR, NVRD, OP_D
  );

input       CLOCK;
input       RESETN;
input [7:0] IP_D;
input       IpSel, OpSel, NVWR, NVRD;

output [7:0] OP_D;

reg [7:0] Data, OP_D;

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    Data <= 8'h00;
  else if (IpSel & ~NVWR)
    Data <= IP_D;

always @(OpSel or NVRD or Data)
  if (OpSel & ~NVRD)
    OP_D = Data;
  else
    OP_D = 8'h00;

endmodule

