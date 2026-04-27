//*******************************************************************       //
//IMPORTANT NOTICE                                                          //
//================                                                          //
//Copyright Mentor Graphics Corporation 1996 - 1999.  All rights reserved.  //
//This file and associated deliverables are the trade secrets,              //
//confidential information and copyrighted works of Mentor Graphics         //
//Corporation and its licensors and are subject to your license agreement   //
//with Mentor Graphics Corporation.                                         //
//                                                                          //
//Use of these deliverables for the purpose of making silicon from an IC    //
//design is limited to the terms and conditions of your license agreement   //
//with Mentor Graphics If you have further questions please contact Mentor  //
//Graphics Customer Support.                                                //
//                                                                          //
//This Mentor Graphics core (mi2cv2 v2002.030) was extracted on             //
//workstation hostid 80889f14 Inventra                                      //
// Processor Interface
// Copyright Mentor Graphics Corporation and Licensors 2001.

// Revision history
// $Log: m3s003fb.v,v $
// Revision 1.5  2002/02/25
// renamed divider_en.v to mi2cv2_cfg.v
//
// Revision 1.4  2002/02/21
// remove combinatorial logic from INTR output to ensure INTR is glitch free
//
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//

// Contains five registers:
//  0: Addr     7-bit address register + general call enable
//  1: Data     8-bit data register
//  2: Cntrl    6-bit control register
//  3: Status   8-bit status register (read only)
//  4: XAddr    8-bit extended address register - for 10-bit addressing
//  7: SoftReset

`include "mi2cv2_cfg.v"

//
// Fully synchronous read and write
//

module m3s003fb (CLOCK, RESETN, VAL, ADDRESS, RD, WDATA, Data, Status, SetIFLG, ClrSTA, MASTER,
//*******************************************************************       //
//IMPORTANT NOTICE                                                          //
//================                                                          //
//Copyright Mentor Graphics Corporation 1996 - 1999.  All rights reserved.  //
//This file and associated deliverables are the trade secrets,              //
//confidential information and copyrighted works of Mentor Graphics         //
//Corporation and its licensors and are subject to your license agreement   //
//with Mentor Graphics Corporation.                                         //
//                                                                          //
//Use of these deliverables for the purpose of making silicon from an IC    //
//design is limited to the terms and conditions of your license agreement   //
//with Mentor Graphics If you have further questions please contact Mentor  //
//Graphics Customer Support.                                                //
//                                                                          //
//This Mentor Graphics core (mi2cv2 v2002.030) was extracted on             //
//workstation hostid 80889f14 Inventra                                      //
                 SLAA, XSLA, WrData, ENAB, GCENAB, STA, STP, IFLG, AAK, RDATA, INTR, IRST 
                 `ifdef divider_en
                   ,CCRFS ,CCRH
                 `endif
                  );

  input        CLOCK;
  input        RESETN;
  input        VAL;
  input  [2:0] ADDRESS;
  input        RD;
  input  [7:0] WDATA;
  input  [7:0] Data;
  input  [4:0] Status;
  input        SetIFLG, ClrSTA;
  input        MASTER;

  output       ENAB, GCENAB, STA, STP, IFLG, AAK, INTR, IRST;
  output [6:0] SLAA;
  output [7:0] XSLA;
  output       WrData;
  output [7:0] RDATA;

`ifdef divider_en
  output [6:0] CCRFS;
  output [6:0] CCRH;
  reg [6:0] CCRFS;
  reg [6:0] CCRH;
`endif  

  reg [6:0] SLAA;
  reg [7:0] XSLA;
  reg [7:0] XDA, RDATA;
  reg       GCENAB, INTR;
  reg       IRST;
  reg       IEN, ENAB, STA, STP, IFLG, AAK;
  reg       SLAA_WR, WrData, CNTR_WR, XSLA_WR, CCRFS_WR, CCRH_WR, SRST;


//
// Synchronise software reset to make Internal Reset
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN)
    IRST <= 1'b0;
  else
    IRST <= SRST;
end


// Decode I/F Addresses
//
always @(ADDRESS or VAL or RD)
begin
  SLAA_WR  = (ADDRESS[2:0] == 3'h0) & VAL & !RD;   //ADDR
  WrData   = (ADDRESS[2:0] == 3'h1) & VAL & !RD;   //DATA
  CNTR_WR  = (ADDRESS[2:0] == 3'h2) & VAL & !RD;   //CNTR
  XSLA_WR  = (ADDRESS[2:0] == 3'h4) & VAL & !RD;   //XADDR

  CCRFS_WR = (ADDRESS[2:0] == 3'h3) & VAL & !RD;   //Full-Stnd clock control reg 
  CCRH_WR  = (ADDRESS[2:0] == 3'h5) & VAL & !RD;   //High-Speed clock control reg 
  SRST     = (ADDRESS[2:0] == 3'h7) & VAL & !RD;
end

//
// Processor interface registers, latched on the rising edge of RD
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN)
  begin
    INTR       <= 1'b0;
    SLAA[6:0]  <= 7'h00;
    GCENAB     <= 1'b0;
    {IEN,ENAB,STA,STP,IFLG,AAK} <= 6'h00;
    XSLA[7:0]  <= 8'h00;
  `ifdef divider_en
     CCRFS[6:0]<= 7'h00;
     CCRH[6:0] <= 7'h00;
  `endif
  end
  else if (IRST)
  begin
    INTR       <= 1'b0;
    SLAA[6:0]  <= 7'h00;
    GCENAB     <= 1'b0;
    {IEN,ENAB,STA,STP,IFLG,AAK} <= 6'h00;
    XSLA[7:0]  <= 8'h00;
  `ifdef divider_en
    CCRFS[6:0] <= 7'h00;
    CCRH[6:0]  <= 7'h00;
  `endif
  end
  else begin
    if (SLAA_WR) {SLAA[6:0],GCENAB} <= WDATA[7:0];
    else         {SLAA[6:0],GCENAB} <= {SLAA[6:0],GCENAB};

    IEN  <= (WDATA[7] & CNTR_WR) | (IEN  & !CNTR_WR);
    ENAB <= (WDATA[6] & CNTR_WR) | (ENAB & !CNTR_WR);
    STA  <= (WDATA[5] & CNTR_WR) | (STA  & !ClrSTA);    // May only be set by write
    STP  <= (WDATA[4] & CNTR_WR) | (STP  &  MASTER);    // May only be set by write
    IFLG <= ((WDATA[3] | !CNTR_WR) & IFLG) | SetIFLG;   // May only be cleared by write
    AAK  <= (WDATA[2] & CNTR_WR) | (AAK  & !CNTR_WR);

    if (XSLA_WR) XSLA[7:0] <= WDATA[7:0];
    else XSLA[7:0] <= XSLA[7:0];

  `ifdef divider_en
    if (CCRFS_WR) CCRFS[6:0] <= WDATA[6:0];
    else CCRFS[6:0] <= CCRFS[6:0];

    if (CCRH_WR) CCRH[6:0] <= WDATA[6:0];
    else CCRH[6:0] <= CCRH[6:0];
  `endif

    // Interrupt
    // (i.e. logical result of IFLG & IEN)
    INTR <= (((WDATA[3] | !CNTR_WR) & IFLG) | SetIFLG) & 
             ((WDATA[7] & CNTR_WR) | (IEN  & !CNTR_WR));

  end
end


//
// Output data mux
//
always @(SLAA or GCENAB or Data or IEN or ENAB or STA or STP or IFLG or AAK or
         Status or XSLA or ADDRESS)
begin
  case (ADDRESS[2:0])
    0: XDA[7:0] <= {SLAA[6:0], GCENAB};
    1: XDA[7:0] <= Data[7:0];
    2: XDA[7:0] <= {IEN, ENAB, STA, STP, IFLG, AAK, 2'b00};
    3: XDA[7:0] <= {Status[4:0], 3'b000};
    4: XDA[7:0] <= XSLA[7:0];
    5: XDA[7:0] <= 8'h00;
    6: XDA[7:0] <= 8'h00;
    7: XDA[7:0] <= 8'h00;
    default: XDA <= 8'hxx;
  endcase
end

//
// RDATA is zero unless selected
//
always @(VAL or XDA)
begin
  RDATA[7:0] <= {8{VAL}} & XDA[7:0];
end

endmodule
