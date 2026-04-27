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
// Clock Data Controller
// Copyright Mentor Graphics Corporation and Licensors 2001.
//
// Revision history
// $Log: m3s005fb.v,v $
// Revision 1.4  2002/02/20
// tidied comments up
//
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//

// Controls the generation of the I2C clock in master mode.
//

module m3s005fb (CLOCK, IRST, RESETN, CLK_EN, SSCL, WrData, IFLG,
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
                 MASTER, START, RSTART, STOP, ClrSTA,
                 TxDa, LTXD, OSCL, OSDA);

   input        CLOCK, IRST, RESETN, CLK_EN;
   input        SSCL;
   input        WrData;
   input        IFLG;
   input        MASTER;
   input        START, RSTART, STOP;
   input        TxDa;
   input        LTXD;

   output       ClrSTA;
   output       OSCL, OSDA;

   reg       OSCL, OSDA;
   reg [2:0] SCLCNT;
   reg       RSTCNT;
   reg       CNTINC;

   reg       LSCL, HSCL;


//
// Mode state deffinitions
//
// 00 = Normal    // Master Tx, Master Rx or idle 
// 01 = Start
// 10 = Restart
// 11 = Stop
//
   reg [1:0] Mode;
   reg       MStep;

   reg       ClrSTA;

//
// I2C clock control
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) OSCL <= 1'b1;
  else if (IRST) OSCL <= 1'b1;
  else begin
    if (CLK_EN) begin
      case (Mode[1:0])
        2'b00 : begin
                  if (MASTER) OSCL <= (OSCL & !(SCLCNT[2:0] == 3'h2)) | (SCLCNT[2:0] == 3'h4);
                  else OSCL <= !(HSCL & !SSCL);
                end
        2'b01 : OSCL <= !(SCLCNT[2:0] == 3'h6);
        2'b10 : OSCL <=  OSCL |  (SCLCNT[2:0] == 3'h1);
        2'b11 : OSCL <=  OSCL |  (SCLCNT[2:0] == 3'h1);
        default : OSCL <= 1'bx;
      endcase
    end
    else OSCL <= OSCL;
  end

end

//
// I2C data control
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) OSDA <= 1'b1;
  else if (IRST) OSDA <= 1'b1;
  else begin
    if (CLK_EN) begin
      case (Mode[1:0])
        2'b00 : OSDA <= (((TxDa & !STOP) | START | RSTART) & !SSCL)
                      | (OSDA & SSCL);   // Update only when SSCL = 0
        2'b01 : OSDA <= 1'b0;
        2'b10 : OSDA <= 1'b1;
        2'b11 : OSDA <= (SCLCNT[2:0] == 3'h7);
        default : OSDA <= 1'bx;
      endcase
    end
    else OSDA <= OSDA;
  end

end

//
// I2C clock / data timing
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) SCLCNT[2:0] <= 3'h0;
  else if (RSTCNT) SCLCNT[2:0] <= 3'h0;
  else begin
    if (CNTINC) SCLCNT[2:0] <= SCLCNT[2:0] + 3'b001;
    else SCLCNT[2:0] <= SCLCNT[2:0];
  end
end

//
// Counter reset
//
always @(SCLCNT or SSCL or MASTER or OSCL or Mode or CLK_EN or IRST or LSCL)
begin
  case (Mode[1:0])
    2'b00 : begin
              RSTCNT = ((SCLCNT[2:0] == 3'h0)
                     & !( SSCL &  OSCL & CLK_EN)
                     & !(!SSCL & !OSCL & CLK_EN))
                     | ( OSCL & (SCLCNT[2:0] == 3'h2) & CLK_EN)
                     | (!OSCL & (SCLCNT[2:0] == 3'h4) & CLK_EN)
                     | (IRST)
                     | (!MASTER & !LSCL);
            end
    2'b01 :   RSTCNT = (SCLCNT[2:0] == 3'h6) & CLK_EN;
    2'b10 :   RSTCNT = (SCLCNT[2:0] == 3'h6) & CLK_EN;
    2'b11 :   RSTCNT = (SCLCNT[2:0] == 3'h7) & !MASTER;
    default : RSTCNT = 1'bx;
  endcase

end

//
// Count increment
//
always @(SCLCNT or OSCL or HSCL or SSCL or Mode or CLK_EN or MASTER)
begin
  case (Mode[1:0])
    2'b00 : CNTINC = !((SCLCNT == 3'h2) & !OSCL & HSCL & MASTER) & CLK_EN;
    2'b01 : CNTINC = CLK_EN;                                 // Bus must already be idle
    2'b10 : CNTINC = !((SCLCNT == 3'h3) & !SSCL) & CLK_EN;   // Hold until SCLK released
    2'b11 : CNTINC = !((SCLCNT == 3'h3) & !SSCL) & CLK_EN &  // Hold until SCLK released
                      !(SCLCNT == 3'h7);    // Hold at Max count wait for MASTER release
    default : CNTINC = 1'bx;
  endcase

end

//
// In Slave mode time release of SCL from write to SDA so that a minimum of 
// 3 CLK_EN's is timed. Thus providing a minimum safe data setup.
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) LSCL <= 1'b0;
  else if (IRST) LSCL <= 1'b0;
  else LSCL <= (LTXD & WrData) | (LSCL & !((SCLCNT == 3'h2) & CLK_EN));
end 
//
// Hold SCL
//
always @(LSCL or IFLG)
begin
  HSCL = LSCL | IFLG;
end

//
// Control when mode changes to meet minimum SCL timing's
//
// NOTE: Start is immediate as bus must be idle for this action
// other events such as Restart or Stop must comply with active
// bus timings
//
always @(START or Mode or SCLCNT or CLK_EN or RSTCNT)
begin
  MStep = ( (Mode[1:0] == 2'b00) & START)              
        | ( (Mode[1:0] == 2'b00) & (SCLCNT[2:0] == 3'h4) & CLK_EN)
        | (!(Mode[1:0] == 2'b00) & RSTCNT);
end

always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) Mode[1:0] <= 2'b00;    // Normal mode
  else if (IRST) Mode[1:0] <= 2'b00;  // Normal mode
  else begin
    case ({MStep,Mode[1:0]})
      3'b000 :   Mode[1:0] <= 2'b00;          // Normal operation
      3'b100 : begin
                 Mode[0] <= START | STOP;     // Load
                 Mode[1] <= STOP  | RSTART;
               end
      3'b001 : Mode[1:0] <= 2'b01;    // Hold   Start
      3'b101 : Mode[1:0] <= 2'b00;    // To Normal

      3'b010 : Mode[1:0] <= 2'b10;    // Hold   ReStart
      3'b110 : Mode[1:0] <= 2'b01;    // To Start

      3'b011 : Mode[1:0] <= 2'b11;    // Hold   Stop
      3'b111 : Mode[1:0] <= 2'b00;    // To Normal

      default : Mode[1:0] <= 2'bxx;
    endcase
  end
end


always @(Mode or RSTCNT or MASTER)
begin
  ClrSTA = ((Mode[1:0] == 2'b01) & RSTCNT);
end

endmodule
