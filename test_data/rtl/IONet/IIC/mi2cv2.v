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
// MI2Cv2 Bus Controller
// Copyright Mentor Graphics Corporation and Licensors 2001.

// Revision history
// $Log: mi2cv2.v,v $
// Revision 1.6  2002/02/25
// renamed divider_en.v to mi2cv2_cfg.v
//
// Revision 1.5  2002/02/21
// added wire declaration for IRST
//
// Revision 1.4  2002/02/20
// leave FSEN/HSEN at top level but state in UG and PSpec that need to tie to logic zero when not req'd
//
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//

// The top level instantiates five blocks:
//   m3s001fb - Clock enable select/Optional Clock divider logic
//   m3s002fb - I2C syncronisation and decode
//   m3s003fb - CPU I/F and register control
//   m3s004fb - Main state machine
//   m3s005fb - Clock and data Control
//

`include "mi2cv2_cfg.v"


module mi2cv2 (CLOCK, RESETN, VAL, ADDRESS, RD, WDATA, ISCL, ISDA, IFSDA,
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
               RDATA, INTR, OSCL, OSDA, ENDRV, CKISO, DAISO, DAGND, FSEN, HSEN
              );

   input        CLOCK;         //MI2CV2 Clock
   input        FSEN;        //Full/(standard) Speed Enable, Set to 10x full/standard speed I2C bit rate
   input        HSEN;        //High Speed Enable, Set to 10x high speed I2C bit rate
   input        RESETN, VAL, RD, ISCL, ISDA, IFSDA;
   input  [2:0] ADDRESS;
   input  [7:0] WDATA;

   output [7:0] RDATA;
   output       INTR, OSCL, OSDA;
   output       ENDRV;
   output       CKISO, DAISO, DAGND;

// 001
   wire       CLK_EN;

// 002
   wire       StartDet, StopDet, SCL_PE, SCL_NE, RxDa, IDLE;
   wire       SSCL, SFSDA;

// 003
(* dont_touch="true" *)wire [6:0] SLAA;
(* dont_touch="true" *)wire [7:0] XSLA;
(* dont_touch="true" *)wire       WrData, ENAB, GCENAB, STA, STP, IFLG, AAK;
(* dont_touch="true" *)wire [7:0] RDATA;
(* dont_touch="true" *)wire       INTR, RESETN, IRST;
`ifdef divider_en
   wire   [6:0] CCRFS, CCRH;
`endif

// 004
   wire [7:0] Data;
   wire [4:0] Status;
   wire       START, RSTART, STOP;
   wire       MASTER, SetIFLG, TxDa, LTXD;
   wire       ENDRV;
   wire       CKISO, DAISO, DAGND;

// 005
   wire       ClrSTA;
   wire       OSCL, OSDA;

//
// Enable select
//
m3s001fb U1(
            `ifdef divider_en    // Internal clock divider enabled
              .CLOCK(CLOCK),
              .RESETN(RESETN),
              .CCRFS(CCRFS),
              .CCRH(CCRH),
              .MASTER(MASTER),
            `else               // Use ext divider to control clock enables
              .HSEN(HSEN),
              .FSEN(FSEN),
            `endif
            .CKISO(CKISO),
            .CLK_EN(CLK_EN));               

//
// I2C syncronisation and decode
//
m3s002fb U2(.CLOCK(CLOCK),
            .CLK_EN(CLK_EN),
            .IRST(IRST),
            .RESETN(RESETN),
            .ISCL(ISCL),
            .ISDA(ISDA),
            .IFSDA(IFSDA),
            .StartDet(StartDet),
            .StopDet(StopDet),
            .SCL_PE(SCL_PE),
            .SCL_NE(SCL_NE),
            .SSCL(SSCL),
            .SFSDA(SFSDA),
            .RxDa(RxDa),
            .IDLE(IDLE));
//
// Processor Interface
//
m3s003fb U3(.CLOCK(CLOCK),
            .IRST(IRST),
            .RESETN(RESETN),
            `ifdef divider_en    // Internal clock divider enabled
              .CCRFS(CCRFS),
              .CCRH(CCRH),
            `endif
            .VAL(VAL),
            .ADDRESS(ADDRESS),
            .RD(RD),
            .WDATA(WDATA),
            .Data(Data),
            .Status(Status),
            .SetIFLG(SetIFLG),
            .ClrSTA(ClrSTA),
            .MASTER(MASTER),
            .SLAA(SLAA),
            .XSLA(XSLA),
            .WrData(WrData),
            .ENAB(ENAB),
            .GCENAB(GCENAB),
            .STA(STA),
            .STP(STP),
            .IFLG(IFLG),
            .AAK(AAK),
            .RDATA(RDATA),
            .INTR(INTR));
//
// State machines
//
m3s004fb U4(.CLOCK(CLOCK),
            // Internal clock divider enabled
            .CLK_EN(CLK_EN),
            .RESETN(RESETN),
            .IRST(IRST),
            .WrData(WrData),
            .WDATA(WDATA),
            .ENAB(ENAB),
            .GCENAB(GCENAB),
            .STA(STA),
            .STP(STP),
            .IFLG(IFLG),
            .AAK(AAK),
            .StartDet(StartDet),
            .StopDet(StopDet),
            .SCL_PE(SCL_PE),
            .SCL_NE(SCL_NE),
            .IDLE(IDLE),
            .RxDa(RxDa),
            .SLAA(SLAA),
            .XSLA(XSLA),
            .START(START),
            .RSTART(RSTART),
            .STOP(STOP),
            .MASTER(MASTER),
            .SetIFLG(SetIFLG),
            .Status(Status),
            .Data(Data),
            .TxDa(TxDa),
            .LTXD(LTXD),
            .ENDRV(ENDRV),
            .CKISO(CKISO),
            .DAISO(DAISO),
            .DAGND(DAGND),
            .SFSDA(SFSDA));
//
// I2C Clock Data Control
//
m3s005fb U5(.CLOCK(CLOCK),
            .IRST(IRST),
            .RESETN(RESETN),
            .CLK_EN(CLK_EN),
            .SSCL(SSCL),
            .WrData(WrData),
            .IFLG(IFLG),
            .MASTER(MASTER),
            .START(START),
            .RSTART(RSTART),
            .STOP(STOP),
            .ClrSTA(ClrSTA),
            .TxDa(TxDa),
            .LTXD(LTXD),
            .OSCL(OSCL),
            .OSDA(OSDA));


endmodule

