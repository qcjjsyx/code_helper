// Modem Output and Status Registers
// Copyright Mentor Graphics Corporation and Licensors 2001

// This module provides the modem output control and status registers
// for the M16550s UART.

// Revision history:
//
// $Log: m3s006fd.v,v $
// Revision 1.4  2004/12/10
// ECN02360 rtl update
//
// Revision 1.3  2001/03/21
// Added CVS log tag
// Removed old Change history associated with version 8.8 ofthe m16550a core
//

module m3s006fd (
  CLOCK, RESETN, WrCyc, RdCyc, ADD4, ADD6, DataIn,
  NDCD, TXD, SB, NRI, NDSR, NCTS,
  NOUT1, NOUT2, NRTS, NDTR, BRKTD, SOUT, LOOP1,
  OUT1, OUT2, DCD, RI, DSR, CTS, RTS, DTR,
  DDCD, DCTS, DDSR, TERI
  );

input       CLOCK, RESETN, WrCyc, RdCyc, ADD4, ADD6;
input [4:0] DataIn;
input       NDCD, TXD, SB, NRI, NDSR, NCTS;
 
output NOUT1, NOUT2, NRTS, NDTR, BRKTD, SOUT, LOOP1;
output OUT1, OUT2, DCD, RI, DSR, CTS, RTS, DTR;
output DDCD, DCTS, DDSR, TERI;

reg       LOOP1, OUT2, OUT1, RTS, DTR;
reg       DCDS, DCD, DDCD, DDCDSet;
reg       CTSS, CTS, DCTS, DCTSSet;
reg       DSRS, DSR, DDSR, DDSRSet;
reg       RIS, RI, TERI, DRISet;
reg       NOUT2, NOUT1, NRTS, NDTR, SOUT;
reg       IDCD, ICTS, IRI, IDSR;
reg       LOCAL_RST_SAMP, LOCAL_RST;
reg       BRKTD;


// Modem Control Register
// Works in CPU timing domain
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
  begin
    LOOP1 <= 1'b0;
    OUT2 <= 1'b0;
    OUT1 <= 1'b0;
    RTS <= 1'b0;
    DTR  <= 1'b0;
  end
  else if (WrCyc & ADD4)
  begin
    LOOP1 <= DataIn[4];
    OUT2 <= DataIn[3];
    OUT1 <= DataIn[2];
    RTS <= DataIn[1];
    DTR  <= DataIn[0];
  end

// Ensure that setting break makes the TX Data output go to 0
always @(TXD or SB)
  BRKTD = ~(TXD & ~SB);

// If loop mode is enabled, all of the modem output lines are
// negated
always @(LOOP1 or OUT2 or OUT1 or RTS or DTR or BRKTD)
begin
  NOUT2 = (~(~LOOP1 & OUT2));
  NOUT1 = (~(~LOOP1 & OUT1));
  NRTS  = (~(~LOOP1 & RTS));
  NDTR  = (~(~LOOP1 & DTR));
  SOUT  = (~(~LOOP1 & BRKTD));
end


// Sample of the modem input lines, with CLK to synchronise

// Read back takes into account loop-backed signals
always @(LOOP1 or OUT2 or DTR or RTS or OUT1 or NDCD or NCTS or NDSR or NRI)
begin
  if (LOOP1)
  begin
    IDCD = OUT2;
    ICTS = RTS;
    IDSR = DTR;
    IRI = OUT1;
  end
  else
  begin
    IDCD = ~NDCD;
    ICTS = ~NCTS;
    IDSR = ~NDSR;
    IRI = ~NRI;
  end
end


// Generation of Modem Status Delta bits

// Generate Local reset for Delta bits
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
      LOCAL_RST_SAMP <= 1'b0;
      LOCAL_RST      <= 1'b0;
   end
  else
   begin
      LOCAL_RST_SAMP <= 1'b1;
      LOCAL_RST      <= LOCAL_RST_SAMP;
   end 
end

// End of common register and delta code
	
// Start with NDCD
// Note Reset has to be active for at least two clocks
// for this circuit to initialise properly
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
    DCDS <= 1'b0;
    DCD  <= 1'b0;
   end
  else
   begin
    DCDS <= IDCD;
    DCD  <= DCDS;
   end
end

// Sample delta bit
always @(DCD or DCDS or LOCAL_RST)
  DDCDSet = ((DCDS ^ DCD) &  LOCAL_RST);

// Generate delta bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DDCD <= 1'b0;
  else if (DDCDSet | (WrCyc & ADD6 & DataIn[3]))
    DDCD <= 1'b1;
  else if ((RdCyc & ADD6) | (WrCyc & ADD6 & ~DataIn[3]))
    DDCD <= 1'b0;


// Now for CTS
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
    CTSS <= 1'b0;
    CTS  <= 1'b0;
   end
  else
   begin
    CTSS <= ICTS;
    CTS  <= CTSS;
   end
end

always @(CTS or CTSS or LOCAL_RST)
  DCTSSet = ((CTSS ^ CTS) &  LOCAL_RST);

// Generate delta bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DCTS <= 1'b0;
  else if (DCTSSet | (WrCyc & ADD6 & DataIn[0]))
    DCTS <= 1'b1;
  else if ((RdCyc & ADD6) | (WrCyc & ADD6 & ~DataIn[0]))
    DCTS <= 1'b0;


// Now for DSR
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
    DSRS <= 1'b0;
    DSR  <= 1'b0;
   end
  else
   begin
    DSRS <= IDSR;
    DSR  <= DSRS;
   end
end

// Sample delta bit
always @(DSRS or DSR or LOCAL_RST)
  DDSRSet = ((DSRS ^ DSR) & LOCAL_RST);

// Generate delta bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    DDSR <= 1'b0;
  else if (DDSRSet | (WrCyc & ADD6 & DataIn[1]))
    DDSR <= 1'b1;
  else if ((RdCyc & ADD6) | (WrCyc & ADD6 & ~DataIn[1]))
    DDSR <= 1'b0;


// Now for RI
// Note that the Delta bit is only generated on the rising
// edge of the RI input
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
   begin
    RIS <= 1'b0;
    RI  <= 1'b0;
   end
  else
   begin
    RIS <= IRI;
    RI  <= RIS;
   end
end

// Sample delta bit
always @(RIS or RI or LOCAL_RST)
  DRISet = ((~RIS & RI) & LOCAL_RST);

// Generate delta bit
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN)
    TERI <= 1'b0;
  else if (DRISet | (WrCyc & ADD6 & DataIn[2]))
    TERI <= 1'b1;
  else if ((RdCyc & ADD6) | (WrCyc & ADD6 & ~DataIn[2]))
    TERI <= 1'b0;


endmodule
	
