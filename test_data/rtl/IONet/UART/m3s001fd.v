// Transmit Engine
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the transmit mechanism
// for the M16550s UART.


// Revision history:
//
// $Log: m3s001fd.v,v $
// Revision 1.5  2004/12/10
// ECN02360 rtl update
//
// Revision 1.4  2001/03/21
// *** empty log message ***
//
// Revision 1.3  2001/03/21
// $Revision and $ Date tags have been removed, as they are redundant
//
//


// Transmit state machine
// 14 states are required:
`define C_TX_IDLE 4'h0
`define C_TX_START 4'h1
`define C_TX_DATA1 4'h2
`define C_TX_DATA2 4'h3
`define C_TX_DATA3 4'h4
`define C_TX_DATA4 4'h5
`define C_TX_DATA5 4'h6
`define C_TX_DATA6 4'h7
`define C_TX_DATA7 4'h8
`define C_TX_DATA8 4'h9
`define C_TX_PARITY 4'ha
`define C_TX_STOP1 4'hb
`define C_TX_STOP2 4'hc


module m3s001fd(
  CLOCK, RESETN, TxClkEnab, WrCyc, ADD0, TxFIFO, DataIn, 
  PEN, WLS0, WLS1, STB, EPS, SP, FIFOE, TEmpt,
  TXD, THRe, TSRE, LoadTxBuff
  );

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       CLOCK, RESETN, TxClkEnab, WrCyc, ADD0;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [7:0] DataIn, TxFIFO;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       PEN, WLS0, WLS1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       STB, EPS, SP, FIFOE, TEmpt;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output      TXD, THRe, TSRE, LoadTxBuff;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [7:0] TD, DO;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [3:0] StepC, TxState;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       TXMD, TXD, DP, PTY;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       THRe2, THRe3, THRe;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       Start, ITHRe, TSRE;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       Step, HStep, NeStep;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg       TxEnab;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire      LoadTxBuff;


// Transmit Hold Register
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TD <= 8'h00;
  else if (WrCyc & ADD0)
    TD <= DataIn;

// THRe - Transmit status flag
// Three stage pipeline
// After reset THRe is set - TX Holding register empty
//
// THRe2 is shifted into THRe3 at the start of the next TX character
// At the next write to the TX shift register THRe1 is toggled because
// it feeds back the inverse of THRe3, and the process repeats
//
// ITHRe is the EXNOR of THRe2 and THRe3
// TEmpt is for the Tx fifo
// THRe is a multiplexed version of these two signals

// Start indicates that the Tx shift register is being loaded
always @(TxClkEnab or Step or TxState)
begin
  Start = (TxClkEnab & Step & (TxState == `C_TX_START));
end

assign LoadTxBuff = Start;

// Now the THRe handshake
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    THRe2 <= 1'b0;
  else if (WrCyc & ADD0)
    THRe2 <= ~THRe3;

always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    THRe3 <= 1'b0;
  else if (TxClkEnab & Step & (TxState == `C_TX_START))
    THRe3 <= THRe2;

always @(THRe2 or THRe3)
  ITHRe = ~(THRe2 ^ THRe3);

// THRe mux
always @(FIFOE or TEmpt or ITHRe)
  if (FIFOE)
    THRe = TEmpt;
  else
    THRe = ITHRe;

// Enable transmission when data is available
// and the transmitter is not disabled by flow control
always @(THRe)
  TxEnab = ~THRe;

// Transmit Shift Register empty is THRe AND TX Idle
always @(THRe or TxState)
  TSRE = (THRe & (TxState == `C_TX_IDLE));

// Transmit data latch
// This latches in the data to be transmitted
// At the start bit of the character (ST00)
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DO <= 8'h00;
  else if (Start & ~FIFOE)
    DO <= TD;
  else if (Start & FIFOE)    //  THR &  Tx Fifo data mux
    DO <= TxFIFO;

// Transmit Step timer - divides the baud rate by 16 to generate
// the 'Step' or move onto next bit enable signal
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    StepC[3:0] <= 4'b0000;
  else if (TxClkEnab & TxState == `C_TX_IDLE)
    StepC[3:0] <= 4'b0000;
  else if (TxClkEnab)
    StepC[3:0] <= (StepC[3:0] + 4'b0001);

// Step   - Count of 15
// NeStep - Count of 14
// HStep  - Count of 6      - When data is output
always @(StepC)
begin
  Step = (StepC == 4'hF);
  NeStep = (StepC == 4'hE);
  HStep = (StepC == 4'h6);
end

// Transmit state machine
// This controls the whole transmit operation
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
    TxState <= `C_TX_IDLE;
  else if (TxClkEnab)
  begin
    case (TxState)
      `C_TX_IDLE:   if (TxEnab) TxState <= `C_TX_START;
      `C_TX_START:  if (Step) TxState <= `C_TX_DATA1;
      `C_TX_DATA1:  if (Step) TxState <= `C_TX_DATA2;
      `C_TX_DATA2:  if (Step) TxState <= `C_TX_DATA3;
      `C_TX_DATA3:  if (Step) TxState <= `C_TX_DATA4;
      `C_TX_DATA4:  if (Step) TxState <= `C_TX_DATA5;
      `C_TX_DATA5:  if (Step) TxState <= `C_TX_DATA6;
      `C_TX_DATA6:  if ((~(WLS1 | WLS0)) | Step) TxState <= `C_TX_DATA7;
      `C_TX_DATA7:  if ((~WLS1) | Step) TxState <= `C_TX_DATA8;
      `C_TX_DATA8:  if ((~(WLS1 & WLS0)) | Step) TxState <= `C_TX_PARITY;
      `C_TX_PARITY: if (~PEN | Step) TxState <= `C_TX_STOP1;
      `C_TX_STOP1:  if (~STB | Step) TxState <= `C_TX_STOP2;
      `C_TX_STOP2:  if (NeStep | (~WLS1 & ~WLS0 & STB & HStep)) TxState <= `C_TX_IDLE;
      default:   TxState <= `C_TX_IDLE;
    endcase
  end
end

// Output data multiplexing
always @(TxState or DO or PTY)
begin
  case (TxState)
    `C_TX_IDLE:  TXMD = 1'b1; // Idle TX value is '1'
    `C_TX_START: TXMD = 1'b0; // Start bit value is '0'
    `C_TX_DATA1: TXMD = DO[0];
    `C_TX_DATA2: TXMD = DO[1];
    `C_TX_DATA3: TXMD = DO[2];
    `C_TX_DATA4: TXMD = DO[3];
    `C_TX_DATA5: TXMD = DO[4];
    `C_TX_DATA6: TXMD = DO[5];
    `C_TX_DATA7: TXMD = DO[6];
    `C_TX_DATA8: TXMD = DO[7];
    `C_TX_PARITY:TXMD = PTY;
    default:  TXMD = 1'b1; // Default and stop bit state is '1'
  endcase
end

// Synchronise the output data stream and remove glitches
// Normal output or IR modulated output selected
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TXD <= 1'b1;
  else if (HStep)
    TXD <= TXMD;

// Generate parity serially, clearing down after every character TX
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DP <= 1'b0;
  else if ((TxState == `C_TX_START) & TxClkEnab)
    DP <= 1'b0;
  else if (HStep & TxClkEnab)
    DP <= (TXMD ^ DP);  // EXOR DP and current data bit

// Generate parity, if required of the right polarity
always @(EPS or SP or DP)
  PTY = ~(EPS ^ (~(SP | ~DP)));


endmodule 

