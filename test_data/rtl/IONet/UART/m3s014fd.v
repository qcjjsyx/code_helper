// Error FIFO Element Cell
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the error FIFO elements for the M16550s UART.

// Revision history:
//
// $Log: m3s014fd.v,v $
// Revision 1.3  2004/12/10
// ECN02360 rtl update
//
// Revision 1.2  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s014fd (
  CLOCK, RESETN, IP_D, IpSel, OpSel, NVWR, OP_D
  );

input       CLOCK;
input       RESETN;
input [2:0] IP_D;
input       IpSel, OpSel, NVWR;

output [2:0] OP_D;

reg [2:0] Data, OP_D;

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    Data <= 3'b000;
  else if (IpSel & ~NVWR)
    Data <= IP_D;

always @(OpSel or Data)
  if (OpSel)
    OP_D = Data;
  else
    OP_D = 3'b000;

endmodule

