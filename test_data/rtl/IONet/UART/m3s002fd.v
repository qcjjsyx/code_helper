// Receive Engine
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the receive mechanism
// for the M16550s UART.

// Revision history:
//
// $Log: m3s002fd.v,v $
// Revision 1.4  2004/12/10
// ECN02360 rtl update
//
// Revision 1.3  2001/03/21
// *** empty log message ***
//
// Revision 1.2  2001/03/21
// Added log, tag.
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

// Receive state machine
// 14 states are required:
`define C_RX_IDLE 4'h0
`define C_RX_START 4'h1
`define C_RX_DATA1 4'h2
`define C_RX_DATA2 4'h3
`define C_RX_DATA3 4'h4
`define C_RX_DATA4 4'h5
`define C_RX_DATA5 4'h6
`define C_RX_DATA6 4'h7
`define C_RX_DATA7 4'h8
`define C_RX_DATA8 4'h9
`define C_RX_PARITY 4'ha
`define C_RX_STOP1 4'hb
`define C_RX_CHARX 4'hc
`define C_RX_END_BRK 4'hd

// Seven bits
`define C_RTO 4'b0111

module m3s002fd (
  CLOCK, RESETN, RxClkEnab, RdCyc, ADD0, ADD5,
  DA4, DA3, DA2, DA1,
  PEN, WLS0, WLS1, STB, EPS, SP,
  SIN, LOOP1, BRKTD, RxFIFO,
  FOE, FPE, FFE, FBI, FERF, FIFOE, REmpt, RRST,
  RxData, RxBuff, CharEn, DR, FE, OE, PE, BI,
  ERF, RTO, FRE, PTE, FBRK
  );


input       CLOCK, RESETN, RxClkEnab, RdCyc, ADD0, ADD5;
input       DA4, DA3, DA2, DA1;
input       PEN, WLS0, WLS1, STB, EPS, SP;
input       SIN, LOOP1, BRKTD;
input [7:0] RxFIFO;
input       FOE, FPE, FFE, FBI, FERF;
input       FIFOE, REmpt, RRST;

output [7:0] RxData, RxBuff;
output       CharEn;
output       DR, FE, OE, PE, BI;
output       ERF;     // At least one error in fifo
output       RTO;     // Rx character timeout
output       FRE, PTE, FBRK;

reg [7:0] RxData, RxBuff, RxReg;
reg [3:0] StepC, RxState;
reg [2:0] RXS;
reg [5:0] TOC;
reg       DIN, PTY, FRE;
reg       DP, RTO;
reg       DR, FE, OE, PE, BI, ERF;
reg       SDIN, RdLtch, RdSync, RdPulse;
reg       DRTog, DRRdTog, OETog, OERdTog, PETog, PERdTog, FETog, FERdTog;
reg       BITog, BIRdTog;
reg       IDLE, Step;
reg       BRK, FBRK, PTE, CharEn;
reg       IDR, IFE, IOE, IPE, IBI;
reg       NoBit6, NoBit7, NoBit8;
reg       IpFilter;


// Input data is either SIN or TX data looped back
always @(LOOP1 or SIN or BRKTD)
  SDIN = (~LOOP1 & SIN) | (LOOP1 & ~BRKTD);

// Input data filter, filters incoming data using a majority
// 2 of 3 logic circuit - also resyncs data to RX Clock
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    RXS[2:0] <= 3'b111;
  else if (RxClkEnab)
  begin
    RXS[0] <= SDIN;
    RXS[1] <= RXS[0];
    RXS[2] <= RXS[1];
  end
always @(RXS)
  IpFilter = (RXS[0] & RXS[1]) | (RXS[0] & RXS[2]) | (RXS[1] & RXS[2]);

// Input data selected from input filter
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DIN <= 1;
  else if (RxClkEnab)
    DIN <= IpFilter;

// Receive Step timer - divides the baud rate by 16 to generate
// the 'Step' or move onto next bit enable signal
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
      StepC <= 4'h0;
  else begin
    if ((RxState == `C_RX_IDLE) & RxClkEnab & ~DIN)
      StepC <= 4'h0;
    else if (RxClkEnab)
      StepC <= StepC + 4'b0001;
  end

// Step - Count of 7
always @(RxClkEnab or StepC)
  Step = ((StepC == 4'h7) & RxClkEnab);

// Decode number of bits required for the character
always @(WLS0 or WLS1)
begin
  NoBit6 = ~WLS1 & ~WLS0;
  NoBit7 = ~WLS1;
  NoBit8 = ~WLS1 | ~WLS0;
end

// Receive state machine
// This controls the whole Receive operation
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
      RxState <= `C_RX_IDLE;
  else if (RxClkEnab)
  begin
      case (RxState)
        `C_RX_IDLE:  if (~DIN)          RxState <= `C_RX_START;  // Detect start bit
        `C_RX_START: if (Step & ~DIN)   RxState <= `C_RX_DATA1;
                     else if (Step)     RxState <= `C_RX_IDLE;   // If false start stop RX
        `C_RX_DATA1: if (Step)          RxState <= `C_RX_DATA2;
        `C_RX_DATA2: if (Step)          RxState <= `C_RX_DATA3;
        `C_RX_DATA3: if (Step)          RxState <= `C_RX_DATA4;
        `C_RX_DATA4: if (Step)          RxState <= `C_RX_DATA5;
        `C_RX_DATA5: if (Step)          RxState <= `C_RX_DATA6;
        `C_RX_DATA6: if (NoBit6 | Step) RxState <= `C_RX_DATA7;
        `C_RX_DATA7: if (NoBit7 | Step) RxState <= `C_RX_DATA8;
        `C_RX_DATA8: if (NoBit8 | Step) RxState <= `C_RX_PARITY;
        `C_RX_PARITY: if (~PEN | Step)  RxState <= `C_RX_STOP1;
        `C_RX_STOP1: if (Step)          RxState <= `C_RX_CHARX;
        `C_RX_CHARX:   RxState <= `C_RX_END_BRK;
        `C_RX_END_BRK: if (DIN)  RxState <= `C_RX_IDLE;
         	       else if (~DIN & BRK) RxState <= `C_RX_START; 
        default:  RxState <= `C_RX_IDLE;
      endcase
    end
end

// IDLE is true is BREAK or IDLE condition is met
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN) IDLE <= 1'b0;
  else if (~FIFOE) IDLE <= 1'b0;
  else IDLE <= (((RxState == `C_RX_END_BRK) & RxClkEnab) | (IDLE & DIN));

// CPU channel read pulse synchronisation
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    RdLtch <= 1'b0;
    RdSync <= 1'b0;
  end
  else
  begin
    if (RdCyc & ADD0)
      RdLtch <= ~RdSync;
    if (RxClkEnab)
      RdSync <= RdLtch;
  end
always @(RdLtch or RdSync)
  RdPulse = RdLtch ^ RdSync;

// Timeout counter
//
// NOTE. IDLE becomes active at end of received CHARACTER, and inactive
// at start of next CHAR
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TOC <= 6'b000000;
  else if ((~IDLE & ~RTO)  | RdPulse | RRST)     // Other reset conditions
    TOC <= 6'b000000;
  else if (IDLE & ~REmpt & Step & ~RTO)      // Waiting and something in fifo
    TOC <= TOC + 6'b000001;

// Timeout error flag
// indicates 4 character periods have passed
//
// Default value of 7 = Start bit, 5-data bits and 1 Stop bit
always @(TOC or WLS0 or WLS1 or PEN or STB)
  RTO = (TOC[5:0] == {(`C_RTO + ({2'b00,WLS1,WLS0}) + {3'b000,PEN} + {3'b000,STB}),2'b00});

// Receive buffer data multiplexing
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
	          RxBuff <= 8'h00;
	          PTY <= 1'b0;
	          FRE <= 1'b0;
   end
  else
    case (RxState)
      `C_RX_IDLE: begin
 	            RxBuff <= 8'h00;
	            PTY <= 1'b0;
	            FRE <= 1'b0;
	          end
     `C_RX_DATA1: if (Step) RxBuff[0] <= DIN;
     `C_RX_DATA2: if (Step) RxBuff[1] <= DIN;
     `C_RX_DATA3: if (Step) RxBuff[2] <= DIN;
     `C_RX_DATA4: if (Step) RxBuff[3] <= DIN;
     `C_RX_DATA5: if (Step) RxBuff[4] <= DIN;
     `C_RX_DATA6: if (Step) RxBuff[5] <= DIN;
     `C_RX_DATA7: if (Step) RxBuff[6] <= DIN;
     `C_RX_DATA8: if (Step) RxBuff[7] <= DIN;
     `C_RX_PARITY: if (Step) PTY <= DIN;
     `C_RX_STOP1: if (Step) FRE <= ~DIN; // Framing error if DIN not 1 at Framing bit
     default: begin
	        RxBuff <= RxBuff;
	        PTY <= PTY;
	        FRE <= FRE;
	      end
    endcase
end

// Check parity serially, clearing down after every character RX
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DP <= 1'b0;
  else if (RxState == `C_RX_START) 
    DP <= 1'b0;
  else if (Step & (RxState != `C_RX_PARITY) & (RxState != `C_RX_STOP1))
    DP <= (DIN ^ DP);

// Generate parity error, if one has occured:
always @(PEN or EPS or PTY or SP or DP)
  PTE = ~(~PEN | ((EPS ^ PTY) ^ (~(SP | ~DP))));

// Monitor for break condition
// If RX shift register detectes all 0's for a whole character
// period - by being full of 0's then we have a break character
// and generate a BI immediately
// Break detection reset on return to IDLE state
always @(RxBuff or FRE or PTY)
  BRK = (RxBuff[7] | RxBuff[6] | RxBuff[5] | RxBuff[4] |
         RxBuff[3] | RxBuff[2] | RxBuff[1] | RxBuff[0] | ~FRE | PTY);
always @(BRK)
  FBRK = ~BRK;

// Generate a signal which says that we are in Character RX state
// and BEN is active
always @(RxClkEnab or RxState)
  CharEn = ((RxState == `C_RX_CHARX) & RxClkEnab);

// Rx Data Holding register
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    RxReg <= 8'h00;
  else if (CharEn)
    RxReg <= RxBuff;


// Now for the error and status bits

// Start with the Data Ready bit - DR
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    DRTog   <= 1'b0;
    DRRdTog <= 1'b0;
  end
  else
  begin
    if (CharEn) // if we have a new packet of data
      DRTog <= ~DRRdTog; // set the Data Ready DR bit
    if (RdCyc & ADD0) // if we read the RX register
      DRRdTog <= DRTog; // clear the Data Ready DR bit
  end
always @(DRTog or DRRdTog)
  IDR = DRTog ^ DRRdTog;

// Overrun Error Bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    OETog   <= 1'b0;
    OERdTog <= 1'b0;
  end
  else
  begin
    if (CharEn & DR & (FIFOE==0)) // If we have a new character, and the RX buffer is full
                                  // and the FIFO is disabled
      OETog <= ~OERdTog; // then set the overrun error
    if (RdCyc & ADD5 & DA1) // if we have a read cycle and read the LSR and OE=1
      OERdTog <= OETog; // then clear the overrun error
  end
always @(OETog or OERdTog)
  IOE = OETog ^ OERdTog; // this is the overun error when the FIFO is disabled

// Parity Error Bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    PETog   <= 1'b0;
    PERdTog <= 1'b0;
  end
  else
  begin
    if (CharEn & PTE)
      PETog <= ~PERdTog;
    else if (CharEn & PE)
      PETog <= ~PETog;
    if (RdCyc & ADD5 & DA2)
      PERdTog <= PETog;
  end
always @(PETog or PERdTog)
  IPE = PETog ^ PERdTog;

// Framing Error Bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    FETog   <= 1'b0;
    FERdTog <= 1'b0;
  end
  else
  begin
    if (CharEn & FRE)
      FETog <= ~FERdTog;
    else if (CharEn & FE)
      FETog <= ~FETog;
    if (RdCyc & ADD5 & DA3)
      FERdTog <= FETog;
  end
always @(FETog or FERdTog)
  IFE = FETog ^ FERdTog;

//  Break Indication Bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    BITog   <= 1'b0;
    BIRdTog <= 1'b0;
  end
  else
  begin
    if (CharEn & ~BRK)
      BITog <= ~BIRdTog;
    if (RdCyc & ADD5 & DA4)
      BIRdTog <= BITog;
  end
always @(BITog or BIRdTog)
  IBI = BITog ^ BIRdTog;


// Data mux to select between RBR and Rx Fifo
// Including error flags
always @(RxFIFO or RxReg or REmpt or IDR or FOE or IOE or FPE
         or IPE or FFE or IFE or FBI or IBI or FERF or FIFOE)
  if (FIFOE)
  begin
    RxData = RxFIFO;
    DR     = ~REmpt;
    OE     = FOE;
    PE     = FPE;
    FE     = FFE;
    BI     = FBI;
    ERF    = FERF;
  end
  else
  begin
    RxData = RxReg;
    DR     = IDR;
    OE     = IOE;
    PE     = IPE;
    FE     = IFE;
    BI     = IBI;
    ERF    = 1'b0;
  end

endmodule

