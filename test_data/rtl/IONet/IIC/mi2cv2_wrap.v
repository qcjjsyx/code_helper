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
// Wrapper MI2CV2
// Copyright Mentor Graphics Corporation & Licensors 2001.
//

// Revision history
// $Log: mi2cv2_wrap.v,v $
// Revision 1.3  2002/02/21
// wrapper now has all I/O's. i.e. FSEN/HSEN permanent
//
// Revision 1.2  2002/02/07
// ready for review
//
// V1.000 - 23 March 2000  Initial release for RTL design


module mi2cv2_wrap (CLOCK, RESETN, VAL, ADDRESS, RD, WDATA, ISCL, ISDA, IFSDA,
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
                    RDATA, INTR, OSCL, OSDA, ENDRV, CKISO, DAISO, DAGND,FSEN ,HSEN 
                   );

input       CLOCK;
input       RESETN;
input       VAL;
input [2:0] ADDRESS;
input       RD;
input [7:0] WDATA;
input       ISCL, ISDA, IFSDA;
input       FSEN, HSEN;

output [7:0] RDATA;
output       INTR;
output       OSCL, OSDA;
output       ENDRV;
output       CKISO, DAISO, DAGND;

wire [7:0] RDATA;
wire       INTR;
wire       OSCL, OSDA;
wire       ENDRV, CKISO, DAISO, DAGND;

    mi2cv2 U1 (
      .CLOCK(CLOCK), 
      .FSEN(FSEN), 
      .HSEN(HSEN), 
      .RESETN(RESETN),
      .VAL(VAL), 
      .ADDRESS(ADDRESS), 
      .RD(RD), 
      .WDATA(WDATA), 
      .ISCL(ISCL), 
      .ISDA(ISDA), 
      .IFSDA(IFSDA),
      .RDATA(RDATA), 
      .INTR(INTR), 
      .OSCL(OSCL), 
      .OSDA(OSDA), 
      .ENDRV(ENDRV), 
      .CKISO(CKISO), 
      .DAISO(DAISO), 
      .DAGND(DAGND)
    );

endmodule
