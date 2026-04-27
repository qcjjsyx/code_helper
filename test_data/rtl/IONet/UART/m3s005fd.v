// Baud Rate Generator
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the baud rate generator
// for the M16550s UART.
//
// Revision history:
//
// $Log: m3s005fd.v,v $
// Revision 1.4  2004/12/10
// ECN02360 rtl update
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s005fd (
  CLOCK, RESETN, RCLK, RCLK_BAUD, BRGE, WrCyc, ADD0B, ADD1B, DataIn,
  DIV, BAUD, TxClkEnab, RxClkEnab
  );

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       CLOCK, RESETN, RCLK, RCLK_BAUD, BRGE, WrCyc, ADD0B, ADD1B;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [7:0] DataIn;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [15:0] DIV;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output        BAUD, TxClkEnab, RxClkEnab;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       BAUD, TxClkEnab, RxClkEnab;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[15:0] DIV, BRG;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       BrLoad, BRG_One, SyncRClk, DelRClk;


// Baud Rate generator registers

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DIV <= 16'h0001;
  else
  begin
    if (WrCyc & ADD0B)
      DIV <= {DIV[15:8],DataIn[7:0]};
    else if (WrCyc & ADD1B)
      DIV <= {DataIn[7:0],DIV[7:0]};
  end

// Generation of the counter load bit, counter is loaded anytime
// there is a write to either the LSB, or the MSB of the divisor
// register
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    BrLoad <= 1'b0;
  else
    BrLoad <= WrCyc & (ADD0B | ADD1B);


// Baud Rate Counter
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    BRG <= 16'h0001;
  else if (BrLoad | BRG_One)
    BRG <= DIV;
  else if (BRGE)
    BRG <= BRG - 16'h0001;

// Detect BRG = 1
always @(BRG or BRGE)
  BRG_One = (BRG == 16'h0001) & BRGE;

// Generate BAUD output
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    BAUD <= 1'b1;
  else
  begin
    if (BRG_One | BrLoad)
      BAUD <= 1'b1;
    else if (BRG[15:1] == 15'h0001)
      BAUD <= 1'b0;
  end

// Generate transmitter enable
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TxClkEnab <= 1'b1;
  else
    TxClkEnab <= BRG_One;

// Synchronise RCLK to CLK
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    SyncRClk <= 1'b0;
    DelRClk  <= 1'b0;
  end
  else
  begin
    SyncRClk <= RCLK;
    DelRClk  <= SyncRClk;
  end

// Generate receiver enable
always @(RCLK_BAUD or TxClkEnab or SyncRClk or DelRClk)
  if (RCLK_BAUD)
    RxClkEnab = TxClkEnab;
  else
    RxClkEnab = SyncRClk & ~DelRClk;

endmodule
