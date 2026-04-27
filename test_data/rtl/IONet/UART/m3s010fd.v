// Rx Fifo Storage Top Level
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module allows the substitution of a dual port RAM.
// If this is done NVWR needs to be logically ORed with a
// negated version of CLK, to form the write strobe. 
// NVRD is the read strobe. 
//
// Revision history:
//
// $Log: m3s010fd.v,v $
// Revision 1.3  2004/12/10
// ECN02360 rtl update
//
// Revision 1.2  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s010fd (
  CLOCK, RESETN, IP_D, IP_A, OP_A, NVWR, NVRD, OP_D
  );

input [7:0] IP_D;
input [3:0] IP_A, OP_A;
input       CLOCK, RESETN, NVWR, NVRD;

output [7:0] OP_D;

wire [7:0] OP_D;
reg [15:0] IpSel, OpSel;
wire [7:0] OP0, OP1, OP2, OP3, OP4, OP5, OP6, OP7;
wire [7:0] OP8, OP9, OP10, OP11, OP12, OP13, OP14, OP15;

// Input Address decode, generates IP enables
// for each of the FIFO blocks
always @(IP_A)
begin
  case (IP_A)
    4'h0:    IpSel = 16'h0001;
    4'h1:    IpSel = 16'h0002;
    4'h2:    IpSel = 16'h0004;
    4'h3:    IpSel = 16'h0008;
    4'h4:    IpSel = 16'h0010;
    4'h5:    IpSel = 16'h0020;
    4'h6:    IpSel = 16'h0040;
    4'h7:    IpSel = 16'h0080;
    4'h8:    IpSel = 16'h0100;
    4'h9:    IpSel = 16'h0200;
    4'hA:    IpSel = 16'h0400;
    4'hB:    IpSel = 16'h0800;
    4'hC:    IpSel = 16'h1000;
    4'hD:    IpSel = 16'h2000;
    4'hE:    IpSel = 16'h4000;
    default: IpSel = 16'h8000;
  endcase
end

// Output Address decode, generates OP enables
// for each of the FIFO blocks
always @(OP_A)
begin
  case (OP_A)
    4'h0:    OpSel = 16'h0001;
    4'h1:    OpSel = 16'h0002;
    4'h2:    OpSel = 16'h0004;
    4'h3:    OpSel = 16'h0008;
    4'h4:    OpSel = 16'h0010;
    4'h5:    OpSel = 16'h0020;
    4'h6:    OpSel = 16'h0040;
    4'h7:    OpSel = 16'h0080;
    4'h8:    OpSel = 16'h0100;
    4'h9:    OpSel = 16'h0200;
    4'hA:    OpSel = 16'h0400;
    4'hB:    OpSel = 16'h0800;
    4'hC:    OpSel = 16'h1000;
    4'hD:    OpSel = 16'h2000;
    4'hE:    OpSel = 16'h4000;
    default: OpSel = 16'h8000;
  endcase
end

// FIFO Elements instantiated as levels of hierarchy
m3s012fd U0  (CLOCK, RESETN, IP_D, IpSel[0],  OpSel[0],  NVWR, NVRD, OP0);
m3s012fd U1  (CLOCK, RESETN, IP_D, IpSel[1],  OpSel[1],  NVWR, NVRD, OP1);
m3s012fd U2  (CLOCK, RESETN, IP_D, IpSel[2],  OpSel[2],  NVWR, NVRD, OP2);
m3s012fd U3  (CLOCK, RESETN, IP_D, IpSel[3],  OpSel[3],  NVWR, NVRD, OP3);
m3s012fd U4  (CLOCK, RESETN, IP_D, IpSel[4],  OpSel[4],  NVWR, NVRD, OP4);
m3s012fd U5  (CLOCK, RESETN, IP_D, IpSel[5],  OpSel[5],  NVWR, NVRD, OP5);
m3s012fd U6  (CLOCK, RESETN, IP_D, IpSel[6],  OpSel[6],  NVWR, NVRD, OP6);
m3s012fd U7  (CLOCK, RESETN, IP_D, IpSel[7],  OpSel[7],  NVWR, NVRD, OP7);
m3s012fd U8  (CLOCK, RESETN, IP_D, IpSel[8],  OpSel[8],  NVWR, NVRD, OP8);
m3s012fd U9  (CLOCK, RESETN, IP_D, IpSel[9],  OpSel[9],  NVWR, NVRD, OP9);
m3s012fd U10 (CLOCK, RESETN, IP_D, IpSel[10], OpSel[10], NVWR, NVRD, OP10);
m3s012fd U11 (CLOCK, RESETN, IP_D, IpSel[11], OpSel[11], NVWR, NVRD, OP11);
m3s012fd U12 (CLOCK, RESETN, IP_D, IpSel[12], OpSel[12], NVWR, NVRD, OP12);
m3s012fd U13 (CLOCK, RESETN, IP_D, IpSel[13], OpSel[13], NVWR, NVRD, OP13);
m3s012fd U14 (CLOCK, RESETN, IP_D, IpSel[14], OpSel[14], NVWR, NVRD, OP14);
m3s012fd U15 (CLOCK, RESETN, IP_D, IpSel[15], OpSel[15], NVWR, NVRD, OP15);

// Output Selection Mux
assign OP_D = OP0 | OP1 | OP2 | OP3 | OP4 | OP5 | OP6 | OP7 |
         OP8 | OP9 | OP10 | OP11 | OP12 | OP13 | OP14 | OP15;

endmodule

