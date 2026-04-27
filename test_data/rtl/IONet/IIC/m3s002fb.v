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
// I2C I/P Filter
// Copyright Mentor Graphics Corporation and Licensors 2001.

// Revision history
// $Log: m3s002fb.v,v $
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//

//
// Filters and synchronises and decodes the bus input signals
//
module m3s002fb (CLOCK, CLK_EN, IRST, RESETN, ISCL, ISDA, IFSDA,
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
                 StartDet, StopDet, SCL_PE, SCL_NE, SSCL, SFSDA, RxDa, IDLE);

   input        CLOCK, CLK_EN, IRST, RESETN, ISCL, ISDA, IFSDA;
   output       StartDet, StopDet;
   output       SCL_PE, SCL_NE, SSCL;
   output       SFSDA;
   output       RxDa;
   output       IDLE;

   reg       IntSCL1, IntSCL2;
   reg       IntSDA1, IntSDA2;
   reg       StartDet, StopDet;
   reg       SCL_PE, SCL_NE;
   reg       SSCL, RxDa;
   reg       SFSDA;
   reg       InActive;
   reg       IDLE;

   reg [2:0] IDCNT;
   reg       BUSY;

//
// Sample I2C bus inputs
//
always @(posedge CLOCK or negedge RESETN)
begin
   if (!RESETN) begin
     BUSY <= 1'b0;
     IntSCL1 <= 1'b1;
     IntSDA1 <= 1'b1;
     IntSCL2 <= 1'b1;
     IntSDA2 <= 1'b1;
     IDCNT[2:0] <= 3'b000;
     SFSDA <= 1'b1;     //Synchronise Full/Standard speed data
   end
   else begin
     if (CLK_EN) begin
       IntSCL1 <= ISCL;
       IntSDA1 <= ISDA;
     end
     else begin
       IntSCL1 <= IntSCL1;
       IntSDA1 <= IntSDA1;
     end

     IntSCL2 <= IntSCL1;
     IntSDA2 <= IntSDA1;

     if (InActive) IDCNT[2:0] <= IDCNT[2:0] + (!IDLE & CLK_EN);
     else IDCNT[2:0] <= 3'b000;

  // Busy is true between start and stop on the I2C bus
  //
     if (IRST) BUSY <= 1'b0;
     else BUSY <= (StartDet) | (BUSY & !StopDet);
   
     SFSDA <= IFSDA;     //Synchronise Full/Standard speed data
                         //Used for bus isolation control
  end
end

always @(IntSCL2 or IntSCL1 or IntSDA2 or IntSDA1 or IDCNT or BUSY or IRST)
begin
  StartDet =  IntSCL2 &  IntSCL1 &  IntSDA2 & !IntSDA1;  //SCL high, SDA falling edge
  StopDet  =  IntSCL2 &  IntSCL1 & !IntSDA2 &  IntSDA1;  //SCL high, SDA rising edge 

  SCL_PE   = !IntSCL2 &  IntSCL1;  //Pos edge on SCL
  SCL_NE   =  IntSCL2 & !IntSCL1;  //Neg edge on SCL

  RxDa     =  IntSDA1;  //Data
  SSCL     =  IntSCL1;  //Clock

  InActive =  IntSCL1 & IntSCL2 & IntSDA1 & IntSDA2 & !BUSY & !IRST;
//
// IDLE is used to control IDCNT, that determines how long the I2C bus is inactive before we become idle.
//
  IDLE     = (IDCNT[2:0] == 3'b110) & IntSCL1 & IntSCL2 & IntSDA1 & IntSDA2;

end

endmodule
