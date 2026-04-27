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
// Test bench for MI2CV2
// Copyright Mentor Graphics Corporation & Licensors 2002.
//

// Revision history
// $Log: mi2cv2_tb.v,v $
// Revision 1.7  2002/02/25
// renamed include file
//
// Revision 1.6  2002/02/22
// made list files match VHDL. Change sample edge
//
// Revision 1.5  2002/02/21
// Tie FSEN/HSEN to zero when not used. Changed test clock
//
// Revision 1.4  2002/02/19
// tidy-up comments and lis header
//
// Revision 1.3  2002/02/07
// removed unused task. Updated WriteHeader.
//
// Revision 1.2  2002/02/07
// ready for review
//
// V1.000 - 23 March 2000  Initial release for RTL design

`timescale 1 ns/ 10ps

`include "mi2cv2_cfg.v"

`define QCYC  7.5             // 33.33MHz (makes simpler numbers)
`define HCYC  (`QCYC*2)
`define CYC   (`HCYC*2)
`define STROBE (`HCYC - 1)

//`define VERBOSE

// Register addresses
`define ADDR  3'b000
`define DATA  3'b001
`define CNTL  3'b010
`define CCRFS 3'b011
`define STATE 3'b011 // This is also the F/S clock control reg in write mode
`define XADDR 3'b100
`define CCRH  3'b101 // High-speed clock control register
`define Add6  3'b110
`define SRST  3'b111

module mi2cv2_tb ();
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

reg        CLOCK, RESETN;
reg  [2:0] ADDRESS;
reg  [7:0] WDATA;
reg        RD, VAL;
reg        ISCL, ISDA, IFSDA;

wire [7:0] RDATA;
wire       INTR;
wire       OSCL, OSDA;
wire       ENDRV, CKISO, DAISO, DAGND;

reg        TbSCL, TbSDA;

reg        SCLd1, SCLd2, SDAd1, SDAd2;
reg        BusIdle, StartCond, StopCond;
reg        StartDet, StopDet, StartClr, StopClr;
reg        SCLPosedge;
reg  [7:0] ShiftReg, TxData;
reg        ACK;
reg [91:0] SCLSR, CLSR;
reg [91:0] SDASR, DASR;
reg        LDSR;
reg        RSCL, RSDA;

reg  [1:0] ENCNT;
reg        HSEN, FSEN;
reg        CLKEN;
reg        HS_Mode, HS_Mode_reg;

integer OpFile, Vector, Errors, n;
reg [1000:0] test_name;

// Macro
  mi2cv2_wrap U1 (
                     `ifdef divider_en
                        .FSEN(1'b0), 
                        .HSEN(1'b0), 
                     `else
                        .FSEN(FSEN), 
                        .HSEN(HSEN), 
                     `endif

                     .CLOCK(CLOCK), 
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


// I2C Bus
always @(OSCL or TbSCL or OSDA or TbSDA)
begin
  ISCL <= OSCL & TbSCL;
  ISDA <= OSDA & TbSDA;
end

//
// Emulate Full/Standard speed data through a slow bridge
//
always @(negedge CLOCK)
begin
  IFSDA <= (ISDA | DAISO) & !DAGND;
end 

// Detect bus idle
always @(ISCL or ISDA)
begin
  BusIdle = ISCL & ISDA;
end


// Sample Bus
always @(negedge CLOCK or negedge RESETN)
  if (~RESETN) begin
    SCLd1 <= 1;
    SDAd1 <= 1;
    SCLd2 <= 1;
    SDAd2 <= 1;
    end
  else begin
    SCLd1 <= ISCL;
    SDAd1 <= ISDA;
    SCLd2 <= SCLd1;
    SDAd2 <= SDAd1;
    end

// Detect start/stop conditions
always @(SCLd1 or SDAd1 or SCLd2 or SDAd2)
begin
  StartCond = ~SDAd1 & SDAd2 & SCLd1 & SCLd2;
  StopCond  = SDAd1 & ~SDAd2 & SCLd1 & SCLd2;
  SCLPosedge = SCLd1 & ~SCLd2;
end

// Set start/stop condition flags
always @(posedge CLOCK or negedge RESETN)
  if (~RESETN) begin
    StartDet <= 0;
    StopDet <= 0;
    end
  else begin
    if (StartClr) StartDet <= 0;
    else StartDet <= StartCond | StartDet;
    if (StopClr) StopDet <= 0;
    else StopDet  <= StopCond | StopDet;
  end

//
// Bus signal generator
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN) begin
    RSCL  <= 1;
    RSDA  <= 1;
    SCLSR[91:0] <= 92'hFFFFFFFFFFFFFFFFFFFFFFF;
    SDASR[91:0] <= 92'hFFFFFFFFFFFFFFFFFFFFFFF;
    end
  else begin
    if (CLKEN) begin
      {SCLSR[90:0],RSCL} <= SCLSR[91:0];
      {SDASR[91:0],RSDA} <= {1'b1,SDASR[91:0]};
      end
    if (LDSR) begin
      SCLSR[91:0] <= CLSR[91:0];
      SDASR[91:0] <= DASR[91:0];
      end
    end
end

always @(negedge CLOCK)
begin
  TbSCL <= RSCL;
  TbSDA <= RSDA;
end

//
// Bus receiver shift register
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN) {ShiftReg[7:0],ACK} <= 9'h000;
  else if (SCLPosedge) {ShiftReg[7:0],ACK} <= {ShiftReg[6:0],ACK,SDAd1};
end

//
// Clock generator
//
initial
begin
  forever #`HCYC CLOCK = ~CLOCK;
end

`ifdef divider_en
integer HS_div, FS_div;
integer Counter;

always @(posedge CLOCK or negedge RESETN)
begin
  if (~RESETN)
  begin
    Counter = 0; // FS_div is an integer set by the tests
    FS_div = 1;  // Never set to zero!
    HS_div = 1;  // Never set to zero!
    HS_Mode_reg <= 0;
  end
  else
  begin
    // Reset counter if changes from Fast to HS or vice-versa
    if (HS_Mode_reg !== HS_Mode)
    begin
      Counter = 0;
    end
    
    HS_Mode_reg <= HS_Mode; // Sample 

    if (Counter == 0)
    begin
      CLKEN <= 1;
      if (HS_Mode)
        Counter = HS_div - 1;
      else
        Counter = FS_div - 1;
    end
    else
    begin
      CLKEN <= 0;
      Counter = Counter - 1;
    end
  end
end


`else
// Without clock divider, the HSEN and FSEN are generated here
// Determine speed
always @(HSEN or FSEN or HS_Mode)
begin
  CLKEN = (HSEN & HS_Mode) | (FSEN & !HS_Mode);
end

//
// Enable generator
//
always @(negedge CLOCK or negedge RESETN)
begin
  if (~RESETN) ENCNT <= 2'b11;
  else ENCNT[1:0] <= ENCNT[1:0] + 2'b01;
end
//
// If CLOCK were 66MHz, HSEN = div by 2, FSEN = div by 17/16
// If CLOCK were 33MHZ, HSEN = div by 1, FSEN = div by 9/8
// but to make vectors fast we use :-
always @(ENCNT)
begin
  HSEN = ENCNT[0];             //CLOCK divided by 2
  FSEN = ENCNT[1] & ENCNT[0];  //CLOCK divided by 4 
end

`endif

//
// Vector count
//
initial
begin
  Vector = 0;
  forever #`HCYC Vector = Vector+1;
end


// Write data to register
task WriteReg;
input [2:0] add;
input [7:0] wrd;
begin
  @(negedge CLOCK)
  ADDRESS = add;
  WDATA = wrd;
  VAL = 1;
  RD = 0;
  #`CYC;
  VAL = 0;
  RD = 1;
  WDATA = 0;
end
endtask

// Write data to register No VAL
task WriteVAL;
input [2:0] add;
input [7:0] wrd;
begin
  @(negedge CLOCK)
//  #`QCYC;
  ADDRESS = add;
  WDATA = wrd;
  VAL = 0;
  RD = 0;
  #`CYC;
  VAL = 0;
  RD = 1;
  WDATA = 0;
end
endtask

// Read register and check it contains expected value
task CheckReg;
input [2:0] add;
input [7:0] exp;
reg [7:0] ret;
integer   n;
begin
  @(negedge CLOCK)
//  #`QCYC;
  ADDRESS = add;
  VAL = 1;
  RD = 1;
  @(posedge CLOCK)
  ret = RDATA;
  @(negedge CLOCK)
  VAL = 0;
  RD = 1;
  if (ret !== exp) begin
    $display ("%10.0f",Vector,,"  **ERROR: %X read from reg %X, (expected %X)", ret, add, exp);
    Errors = Errors + 1;
    end
end
endtask



// Check the interrupt line is low
task CheckNoIntr;
begin
  if (INTR === 1) begin
    $display ("%10.0f",Vector,,"  **ERROR: Unexpected interrupt");
    Errors = Errors + 1;
    end
  else if (INTR !== 0) begin
    $display ("%10.0f",Vector,,"  **ERROR: INTR in unknown state");
    Errors = Errors + 1;
    end
end
endtask

// Check the interrupt line is high
task CheckIntr;
begin
  if (INTR === 0) begin
    $display ("%10.0f",Vector,,"  **ERROR: No interrupt");
    Errors = Errors + 1;
    end
  else if (INTR !== 1) begin
    $display ("%10.0f",Vector,,"  **ERROR: INTR in unknown state");
    Errors = Errors + 1;
    end
end
endtask

// Check the bus is idle
task CheckBusIdle;
begin
  if (!BusIdle) begin
    $display ("%10.0f",Vector,,"  **ERROR: Bus is not idle");
    Errors = Errors + 1;
    end
end
endtask

// Check the received data in the shift register
task CheckRxData;
input [7:0] exp;
input       aak; // 1=NAck 0=Ack
reg [7:0] ret;
reg       rak;
begin
  ret = ShiftReg;
  rak = ACK;
  if (ret !== exp) begin
    $display ("%10.0f",Vector,,"  **ERROR: Data %X received, (expected %X)", ShiftReg, exp);
    Errors = Errors + 1;
  end

  if (rak !== aak) begin
    $display ("%10.0f",Vector,,"  **ERROR: ACK %b received, (expected %b)", rak, aak);
    Errors = Errors + 1;
  end
end
endtask

// Check a START condition has occurred
task CheckStart;
begin
  if (!StartDet) begin
    $display ("%10.0f",Vector,,"  **ERROR: START not detected");
    Errors = Errors + 1;
    end
  else StartClr = 1;
  #`CYC;
  StartClr = 0;
end
endtask

// Check a STOP condition has occurred
task CheckStop;
begin
  if (!StopDet) begin
    $display ("%10.0f",Vector,,"  **ERROR: STOP not detected");
    Errors = Errors + 1;
    end
  else StopClr = 1;
  #`CYC;
  StopClr = 0;
end
endtask
//
// Wait Time
//
task WaitT;
input n;
integer n;
begin
  repeat (n) #`CYC;
end
endtask

//
// Wait for interrupt
//
task WaitInt;
begin
  while (INTR === 0) #`CYC;
  #`CYC;
end
endtask
//
// Wait for STOP
//
task WaitStop;
begin
  while (StopDet === 0) #`CYC;
  #`CYC;
end
endtask

//
// Wait for IDLE
//
task WaitIdle;
begin
  while (&SDASR[91:0] !== 1 ) #`CYC;
end
endtask
 
// Send START on bus
task SendStart;
begin
  @(negedge CLOCK)
  CLSR[9:0] <= 10'b0111111111;
  DASR[9:0] <= 10'b0000001111;
  for (n=10 ; n<92 ; n=n+1) begin 
    CLSR[n] <= 0;
    DASR[n] <= 0;
    end
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  while (StartDet !== 1) #`CYC;
  while (ISDA !== 0) #`CYC;
  while (ISCL !== 0) #`CYC;
  StartClr = 1;
  #`CYC;
  StartClr = 0;
  #`HCYC;
end
endtask

// Send RE-START on bus
task SendReStart;
begin
  @(negedge CLOCK)
  CLSR[9:0] <= 10'b1111111000;
  DASR[9:0] <= 10'b0001111111;
  for (n=10 ; n<92 ; n=n+1) begin 
    CLSR[n] <= 0;
    DASR[n] <= 0;
    end
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  while (StartDet !== 1) #`CYC;
  while (ISDA !== 0) #`CYC;
  while (ISCL !== 0) #`CYC;
  StartClr = 1;
  #`CYC;
  StartClr = 0;
  #`HCYC;
end
endtask


// Send STOP on bus
task SendStop;
begin
  @(negedge CLOCK)
  CLSR[9:0] <= 10'b1111111000;
  DASR[9:0] <= 10'b1000000000;
  for (n=10 ; n<92 ; n=n+1) begin
    CLSR[n] <= 1;
    DASR[n] <= 1;
    end
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  while (StopDet !== 1) #`CYC;
  while (ISDA !== 1) #`CYC;
  while (ISCL !== 1) #`CYC;
  StopClr = 1;
  #`CYC;
  StopClr = 0;
  #`HCYC;
end
endtask

// Stretch SCL
task Stretch;
begin
  while (ISCL !== 0) #`CYC;
  @(negedge CLOCK)
  CLSR[9:0] <= 10'b0000000000;
  DASR[9:0] <= 10'b1111111111;
  for (n=10 ; n<92 ; n=n+1) begin
    CLSR[n] <= 1;
    DASR[n] <= 1;
    end
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  while (ISCL !== 1) #`CYC;
  #`HCYC;
end
endtask

// Master sends data (to slave MI2Cv2)
task MaTxData;
input [7:0] dat;
input       ack;
reg     A,B,C,D,E,F,G,H,S;
begin
  @(negedge CLOCK)
  {A,B,C,D,E,F,G,H,S} = {dat[7:0],ack};

  CLSR[9:0]   <= 10'b0011110000; //Delay Start
  CLSR[19:10] <= 10'b0011110000;
  CLSR[29:20] <= 10'b0011110000;
  CLSR[39:30] <= 10'b0011110000;
  CLSR[49:40] <= 10'b0011110000;
  CLSR[59:50] <= 10'b0011110000;
  CLSR[69:60] <= 10'b0011110000;
  CLSR[79:70] <= 10'b0011110000;
  CLSR[89:80] <= 10'b0011110000;
  CLSR[91:90] <= 2'b00;
  DASR[9:0]   <= {A,A,A,A,A,A,A,A,A,A};
  DASR[19:10] <= {B,B,B,B,B,B,B,B,B,B};
  DASR[29:20] <= {C,C,C,C,C,C,C,C,C,C};
  DASR[39:30] <= {D,D,D,D,D,D,D,D,D,D};
  DASR[49:40] <= {E,E,E,E,E,E,E,E,E,E};
  DASR[59:50] <= {F,F,F,F,F,F,F,F,F,F};
  DASR[69:60] <= {G,G,G,G,G,G,G,G,G,G};
  DASR[79:70] <= {H,H,H,H,H,H,H,H,H,H};
  DASR[89:80] <= {S,S,S,S,S,S,S,S,S,S};
  DASR[91:90] <= 2'b10;
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  #`HCYC;
end
endtask

// Create Bus Error
task BusErr;
input [7:0] dat;
input       ack;
reg     A,B,C,D,E,F,G,H,S;
reg     Z;
begin
  @(negedge CLOCK)
  {A,B,C,D,E,F,G,H,S} = {dat[7:0],ack};
  Z = 1'b0;
  CLSR[9:0]   <= 10'b0011110000; //Delay Start
  CLSR[19:10] <= 10'b0011110000;
  CLSR[29:20] <= 10'b0011110000;
  CLSR[39:30] <= 10'b0011110000;
  CLSR[49:40] <= 10'b0011110000;
  CLSR[59:50] <= 10'b0011110000;
  CLSR[69:60] <= 10'b0011110000;
  CLSR[79:70] <= 10'b0011110000;
  CLSR[89:80] <= 10'b0011110000;
  CLSR[91:90] <= 2'b00;
  DASR[9:0] <= {B,B,B,B,A,A,A,A,A,A};
  DASR[19:10] <= {C,C,C,C,B,B,B,B,B,B};
  DASR[29:20] <= {D,D,D,D,C,C,C,C,C,C};
  DASR[39:30] <= {E,E,E,E,D,D,D,D,D,D};
  DASR[49:40] <= {F,F,F,F,E,E,E,E,E,E};
  DASR[59:50] <= {G,G,G,G,F,F,F,F,F,F};
  DASR[69:60] <= {H,H,H,H,G,G,G,G,G,G};
  DASR[79:70] <= {S,S,S,S,H,H,H,H,H,H};
  DASR[89:80] <= {Z,Z,Z,Z,S,S,S,S,S,S};
  DASR[91:90] <= 2'b10;
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  #`HCYC;
end
endtask


// Slave sends data at F/S speed (to master MI2Cv2)
task SlTxData;
input [7:0] dat;
input       ack;
reg     A,B,C,D,E,F,G,H,S;
begin
  @(negedge CLOCK)
  {A,B,C,D,E,F,G,H,S} = {dat[7:0],ack};

  CLSR[9:0]   <= 10'b1111110000; //Delay Start
  CLSR[19:10] <= 10'b1111111111;
  CLSR[29:20] <= 10'b1111111111;
  CLSR[39:30] <= 10'b1111111111;
  CLSR[49:40] <= 10'b1111111111;
  CLSR[59:50] <= 10'b1111111111;
  CLSR[69:60] <= 10'b1111111111;
  CLSR[79:70] <= 10'b1111111111;
  CLSR[89:80] <= 10'b1111111111;
  CLSR[91:90] <= 2'b11;
  DASR[9:0] <= {A,A,A,A,A,A,A,A,A,A};
  DASR[19:10] <= {B,B,B,B,B,B,B,B,B,B};
  DASR[29:20] <= {C,C,C,C,C,C,C,C,C,C};
  DASR[39:30] <= {D,D,D,D,D,D,D,D,D,D};
  DASR[49:40] <= {E,E,E,E,E,E,E,E,E,E};
  DASR[59:50] <= {F,F,F,F,F,F,F,F,F,F};
  DASR[69:60] <= {G,G,G,G,G,G,G,G,G,G};
  DASR[79:70] <= {H,H,H,H,H,H,H,H,H,H};
  DASR[89:80] <= {S,S,S,S,S,S,S,S,S,S};
  DASR[91:90] <= 2'b11;
  LDSR <= 1;
  #`CYC;
  LDSR <= 0;
  #`QCYC;
  #`HCYC;
end
endtask


task WriteHeader;
begin
  $fdisplay (OpFile,"                  A                         ");
  $fdisplay (OpFile,"                R D                         ");
  $fdisplay (OpFile,"            C   E D    W  R        CDD E I  ");
  $fdisplay (OpFile,"            LFH S R    D  D  II OO KAA N F I");
  $fdisplay (OpFile,"            OSS E E V  A  A  SS SS IIG D S N");
  $fdisplay (OpFile,"            CEE T S AR T  T  CD CD SSN R D T");
  $fdisplay (OpFile,"    VECTOR  KNN N S LD A  A  LA LA OOD V A R");
  $fdisplay (OpFile, "");
end
endtask

// Write output line
initial
begin
  #`STROBE forever begin
  $fdisplay (OpFile,"%10.0f",Vector,,,
        "%b",CLOCK,
        "%b",FSEN,
        "%b",HSEN,,
        "%b",RESETN,,
        "%o",ADDRESS,,
        "%b",VAL,
        "%b",RD,,
        "%h",WDATA,,
        "%h",RDATA,,
        "%b",ISCL,
        "%b",ISDA,,
        "%b",OSCL,
        "%b",OSDA,,
        "%b",CKISO,
        "%b",DAISO,
        "%b",DAGND,,
        "%b",ENDRV,,
        "%b",IFSDA,,
        "%b",INTR
    );
  #`HCYC;
  end
end

`ifdef SDF
// Back-annotate sdf
initial
begin
  $sdf_annotate("../gates/synop/mi2cv2.sdf",U1.U1,,"sdf.log","TYPICAL","1.0:1.0:1.0","FROM_MTM");
end
`endif

// Main
initial
begin
  OpFile = $fopen("mi2cv2.lis");
  WriteHeader;

  CLOCK = 1'b0;
  RESETN = 1'b1;
  WaitT (2);

  RESETN = 1'b0;
  ADDRESS  = 3'h0;
  WDATA = 8'h00;
  VAL = 1'b0;
  RD = 1'b1;

  TbSCL = 1'b1;
  TbSDA = 1'b1;
  ENCNT[1:0] = 2'b11;

  StartClr =0;
  StopClr = 0;
  Errors = 0;
  n = 0;
  HS_Mode = 0;
  LDSR = 0;

  WaitT (2);
  $display("    Vector Test No -- Comment --");
  $display("%10.0f",Vector,"         Test starting: mi2cv2_tb");

  // Reset
  WaitT (10);
  RESETN = 1'b1;
  WaitT (2);

  // Test 1 Reset status
  $display("%10.0f",Vector," Test  1 Reset status");
  test_name = "1";

  CheckNoIntr;
  CheckReg (`ADDR, 8'h00);
  CheckReg (`DATA, 8'h00);
  CheckReg (`CNTL, 8'h00);
  CheckReg (`STATE, 8'hF8);
  CheckReg (`XADDR, 8'h00);
  CheckReg (`CCRH, 8'h00);
  CheckReg (`Add6, 8'h00);
  CheckReg (`SRST, 8'h00);
 
  CheckBusIdle;


  // Test 2 Intr condition 08, START transmitted
  $display("%10.0f",Vector," Test  2 Intr condition 08, START transmitted");
  test_name = "2";

`ifdef divider_en
  FS_div = 1;
  WriteReg (`CCRFS, 8'h00);   //Set FS divisor 
`endif

  WriteReg (`CNTL, 8'hE0);
  WriteReg (`CNTL, 8'hC0);    //Test Start bit not cleared
  CheckReg (`CNTL, 8'hE0);
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  CheckReg (`CNTL, 8'hC8);
  WriteReg (`CNTL, 8'hC8);     //Test Interrupt not cleared
  CheckReg (`CNTL, 8'hC8);

  // Test 3 Intr condition 20, Address+W sent, no ACK
  $display("%10.0f",Vector," Test  3 Intr condition 20, Address+W sent, no ACK");
  test_name = "3";

  WriteReg (`DATA, 8'hAE);
  WriteReg (`CNTL, 8'hC0);
  SlTxData (8'hFF, 1'b1);       // Slave transmit with nack
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'hAE,1);

  // Test 4 Intr condition 30, Data sent, no ACK
  $display("%10.0f",Vector," Test  4 Intr condition 30, Data sent, no ACK");
  test_name = "4";

  WriteReg (`DATA, 8'h49);
  WriteReg (`CNTL, 8'hC0);
  SlTxData (8'hFF, 1'b1);       // Slave transmit with nack
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h30);
  CheckRxData (8'h49,1);

  // Test 5 Send STOP
  $display("%10.0f",Vector," Test  5 Send STOP");
  test_name = "5";

  WriteReg (`CNTL, 8'hD0);
  
  CheckStop;
  
  WriteReg (`CNTL, 8'hC0);     // Test Stop bit not cleared
  CheckReg (`CNTL, 8'hD0);
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  WaitStop;
  CheckStop;

  // Test 6 Intr condition 10, Repeated START
  $display("%10.0f",Vector," Test  6 Intr condition 10, Repeated START");
  test_name = "6";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h80);
  WriteReg (`CNTL, 8'hC0);      // Send address+W
  CheckNoIntr;
  SlTxData (8'hFF, 1'b1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h80,1);
  WriteReg (`CNTL, 8'hE0);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);

  // Test 7 Intr condition 18, Address+W sent, ACK received
  $display("%10.0f",Vector," Test  7 Intr condition 18, Address+W sent, ACK received");
  test_name = "7";

  WriteReg (`DATA, 8'hAE);
  WriteReg (`CNTL, 8'hC0);      // Send address+W
  SlTxData (8'hFF,0);           // Slave transmit with ack
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'hAE,0);

  // Test 8 Intr condition 28, Data sent in master mode, ACK received
  $display("%10.0f",Vector," Test  8 Intr condition 28, Data sent in master mode, ACK received");
  test_name = "8";

  WriteReg (`DATA, 8'h80);
  WriteReg (`CNTL, 8'hC0);      // Send data
  SlTxData (8'hFF,0);           // Slave transmit with ack
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h80,0);

  // Test 9 Send STOP after acknowledged data
  $display("%10.0f",Vector," Test  9 Send STOP after acknowledged data");
  test_name = "9";

  WriteReg (`CNTL, 8'hD0);
  CheckNoIntr;
  #(`CYC * 2) 
  CheckReg (`STATE, 8'hF8);
  WaitStop;
  CheckStop;

  // Test 10 Intr condition 48, Address+R sent, no ACK
  $display("%10.0f",Vector," Test 10 Intr condition 48, Address+R sent, no ACK");
  test_name = "10";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h55);
  WriteReg (`CNTL, 8'hC0);      // Send address+R
  SlTxData (8'hFF,1);           // Slave transmit with nack
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h48);
  CheckRxData (8'h55,1);

  // Test 11 Intr condition 58, Data received, no ACK sent
  $display("%10.0f",Vector," Test 11 Intr condition 58, Data received, no ACK sent");
  test_name = "11";

  WriteReg (`CNTL, 8'hC0);      // Receive data
  CheckNoIntr;
  SlTxData (8'h55,1);           // Tx data, no ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h58);
  CheckReg (`DATA, 8'h55);

  // Test 12 Intr condition 50, Data received, ACK sent
  $display("%10.0f",Vector," Test 12 Intr condition 50, Data received, ACK sent");
  test_name = "12";

  WriteReg (`CNTL, 8'hC4);      // Receive data
  CheckNoIntr;
  SlTxData (8'hAA,1);           // Tx data, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h50);
  CheckReg (`DATA, 8'hAA);

  // Test 13 Intr condition 40, Address+R sent, ACK received
  $display("%10.0f",Vector," Test 13 Intr condition 40, Address+R sent, ACK received");
  test_name = "13";

  WriteReg (`CNTL, 8'hE0);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'h11);
  WriteReg (`CNTL, 8'hC0);      // Send address+R
  CheckNoIntr;
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  CheckRxData (8'h11,0);

  // Test 14 Intr condition 38, Arbitration lost in address
  $display("%10.0f",Vector," Test 14 Intr condition 38, Arbitration lost in address");
  test_name = "14";

  WriteReg (`CNTL, 8'hE0);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC0);      // Send address+R
  CheckNoIntr;
  MaTxData (8'hF0,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 15 Intr condition 38, Arbitration lost in data
  $display("%10.0f",Vector," Test 15 Intr condition 38, Arbitration lost in data");
  test_name = "15";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);
  WriteReg (`CNTL, 8'hC0);      // Send address+W
  CheckNoIntr;
  MaTxData (8'h54,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'h54,0);
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC0);      // Send data
  CheckNoIntr;
  MaTxData (8'hF0,1);
  WaitInt;
  CheckReg (`DATA, 8'hF0);
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);
  MaTxData (8'hE8,1);           //This data should cause no Interrupt
  WaitIdle;
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  SendStop;

  // Test 16 Intr condition 78, Arbitration lost and general call received
  $display("%10.0f",Vector," Test 16 Intr condition 78, Arbitration lost and general call received");
  test_name = "16";

  WriteReg (`ADDR, 8'hFF);      // Set address = 7F, GC enabled
  WriteReg (`CNTL, 8'hE4);      // Send START, AAK
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h07);
  WriteReg (`CNTL, 8'hC4);      // Send address+R
  CheckNoIntr;
  MaTxData (8'h00,1);           // GCA
  WaitInt;
  CheckIntr;
  CheckRxData (8'h00,0);
  CheckReg (`DATA, 8'h00);  
  CheckReg (`STATE, 8'h78);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 17 Intr condition 68, Arbitration lost and own address+W received
  $display("%10.0f",Vector," Test 17 Intr condition 68, Arbitration lost and own address+W received");
  test_name = "17";

  WriteReg (`ADDR, 8'h04);      // Set address = 02, GC not enabled
  WriteReg (`CNTL, 8'hE4);      // Send START, AAK
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h07);
  WriteReg (`CNTL, 8'hC4);      // Send address+R
  MaTxData (8'h04,1);           // Address+W
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h68);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt


  // Test 18 Intr condition B0, Arbitration lost and own address+R received
  $display("%10.0f",Vector," Test 18 Intr condition BO, Arbitration lost and own address+R received");
  test_name = "18";

  WriteReg (`ADDR, 8'h04);      // Set address = 02, GC not enabled
  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h07);
  WriteReg (`CNTL, 8'hC4);      // Send address+R
  MaTxData (8'h05, 1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hB0);
  WriteReg (`DATA, 8'h78);      // Data to transmit
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  #(`CYC * 2) CheckReg (`STATE, 8'hF8);
  MaTxData (8'hFF,1);  
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hC0);
  CheckRxData (8'h78,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 19 Intr condition 70, General call received, ACK transmitted
  $display("%10.0f",Vector," Test 19 Intr condition 70, General call received, ACK transmitted");
  test_name = "19";

  WriteReg (`ADDR, 8'h0F);      // Set address = 07, GC enabled
  SendReStart;
  WaitInt;
  CheckIntr;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h00,1);           // Send general call, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h70);
  CheckRxData (8'h00,0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 20 Intr condition 90, Data received after general call, ACK transmitted
  $display("%10.0f",Vector," Test 20 Intr condition 90, Data received after general call, ACK transmitted");
  test_name = "20";

  MaTxData (8'hA5,1);           // Send data, expect ACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h90);
  CheckReg (`DATA, 8'hA5);
  CheckRxData (8'hA5, 0);

  // Test 21 Intr condition 98, Data received after general call, ACK not transmitted
  $display("%10.0f",Vector," Test 21 Intr condition 98, Data received after general call, ACK not transmitted");
  test_name = "21";

  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, and clear AAK
  MaTxData (8'h73,1);           // Send data, no ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h98);
  CheckReg (`DATA, 8'h73);
  CheckRxData (8'h73,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 22 Intr condition A0, Repeated START in slave mode
  $display("%10.0f",Vector," Test 22 Intr condition A0, Repeated START in slave mode");
  test_name = "22";

  SendReStart;                  // GC is still enables
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h00,1);           // Send GCA, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h70);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h46,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h90);
  CheckReg (`DATA, 8'h46);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendReStart;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 23 Intr condition A0, STOP in slave mode
  $display("%10.0f",Vector," Test 23 Intr condition A0, STOP in slave mode");
  test_name = "23";

  MaTxData (8'h00,1);           // Send general call, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h70);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h39,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h90);
  CheckReg (`DATA, 8'h39);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 24 Intr condition A8, Own address+R received
  $display("%10.0f",Vector," Test 24 Intr condition A8, Own address+R received");
  test_name = "24";

  WriteReg (`ADDR, 8'h80);      // Set address to 40, GC disabled
  SendStart;
  MaTxData (8'h81,1);           // Send slave address+R, expect ACK
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  CheckRxData (8'h81,0);
  WriteReg (`DATA, 8'h59);      // Load data
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hFF,1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);
  CheckRxData (8'h59,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 25 Intr condition 60, Own address+W received
  $display("%10.0f",Vector," Test 25 Intr condition 60, Own address+W received");
  test_name = "25";

  SendReStart;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h80,1);           // Send slave address+W, NACK
  WaitInt;
  CheckReg (`STATE, 8'h60);
  CheckRxData (8'h80,0);

  // Test 26 Intr condition 80, Data received in slave mode, ACK transmitted
  $display("%10.0f",Vector," Test 26 Intr condition 80, Data received in slave mode, ACK transmitted");
  test_name = "26";

  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h32,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckRxData (8'h32,0);

  // Test 27 Intr condition 88, Data received in slave mode, ACK not transmitted
  $display("%10.0f",Vector," Test 27 Intr condition 88, Data received in slave mode, ACK not transmitted");
  test_name = "27";

  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  MaTxData (8'h42,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h88);
  CheckRxData (8'h42,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt, AAK=1
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 28 Intr condition C0, Data transmitted in slave mode, ACK not received
  $display("%10.0f",Vector," Test 28 Intr condition C0, Data transmitted in slave mode, ACK not received");
  test_name = "28";

  SendStart;
  MaTxData (8'h81,1);           // Send slave address+R, expect ACK
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'hB8);      // Load data
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hC0);
  CheckRxData (8'hB8,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 29 Intr condition C8, Last byte transmitted in slave mode, ACK received
  $display("%10.0f",Vector," Test 29 Intr condition C8, Last byte transmitted in slave mode, ACK received");
  test_name = "29";

  SendStart;
  MaTxData (8'h81,1);           // Send slave address+R, expect ACK
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'hD5);      // Load data
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt, AAK=1
  MaTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hB8);
  CheckRxData (8'hD5,0);
  WriteReg (`DATA, 8'hE6);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  MaTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hC8);
  CheckRxData (8'hE6,0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 29A Intr condition D0, Last byte transmitted in slave mode, NACK received
  $display("%10.0f",Vector," Test 29A Intr condition D0, Last byte transmitted in slave mode, NACK received");
  test_name = "29";

  SendStart;
  MaTxData (8'h81,1);           // Send slave address+R, expect ACK
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'hD5);      // Load data
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt, AAK=1
  MaTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hB8);
  CheckRxData (8'hD5,0);
  WriteReg (`DATA, 8'hEE);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  MaTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hD0);
  CheckRxData (8'hEE,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt


  // Test 30 Generate bus error after intr condition 08
  $display("%10.0f",Vector," Test 30 Generate bus error after intr condition 08");
  test_name = "30";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFF);      // Load address+R
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hF0,0);             // Generate buss error during fourth bit
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 31 Generate bus error after intr condition 20
  $display("%10.0f",Vector," Test 31 Generate bus error after intr condition 20");
  test_name = "31";

  WriteReg (`CNTL, 8'hF4);      // Send START, AAK=1
  WaitInt;                      // Start + Stop are set, Stop is cleared as Idle
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFE);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`DATA, 8'h7F);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hF0,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 32 Generate bus error after intr condition 30
  $display("%10.0f",Vector," Test 32 Generate bus error after intr condition 30");
  test_name = "32";

  WriteReg (`CNTL, 8'hE0);      // Send START, AAK=0
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFE);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`DATA, 8'hCF);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h30);
  WriteReg (`DATA, 8'hCF);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFE,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 33 Generate bus error after intr condition 10
  $display("%10.0f",Vector," Test 33 Generate bus error after intr condition 10");
  test_name = "33";

  WriteReg (`CNTL, 8'hE0);      // Send START, AAK=0
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFE);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`CNTL, 8'hE0);      // Send repeated START, AAK=0
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  BusErr (8'hFC,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 34 Generate bus error after intr condition 18
  $display("%10.0f",Vector," Test 34 Generate bus error after intr condition 18");
  test_name = "34";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFE);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h6F);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFC,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 35 Generate bus error after intr condition 28
  $display("%10.0f",Vector," Test 35 Generate bus error after intr condition 28");
  test_name = "35";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hFE);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h6F);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFC,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 36 Generate bus error after intr condition 48
  $display("%10.0f",Vector," Test 36 Generate bus error after intr condition 48");
  test_name = "36";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hEF);      // Load address+R
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h48);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 37 Generate bus error after intr condition 58
  $display("%10.0f",Vector," Test 37 Generate bus error after intr condition 58");
  test_name = "37";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h55);      // Load address+R
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF, 0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK = 0
  CheckNoIntr;
  SlTxData (8'hE6,1);           // Tx data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h58);
  CheckReg (`DATA, 8'hE6);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  BusErr (8'h80,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 38 Generate bus error after intr condition 50
  $display("%10.0f",Vector," Test 38 Generate bus error after intr condition 50");
  test_name = "38";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h55);      // Load address+R
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF, 0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt, AAK = 1
  CheckNoIntr;
  SlTxData (8'hE6,1);           // Tx data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h50);
  CheckReg (`DATA, 8'hE6);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  BusErr (8'hC0,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle; 
  SendStop;

  // Test 39 Generate bus error after intr condition 40
  $display("%10.0f",Vector," Test 39 Generate bus error after intr condition 40");
  test_name = "39";

  WriteReg (`CNTL, 8'hE4);      // Send START, AAK=1
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h55);      // Load address+R
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hE0,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle;
  SendStop;

  // Test 40 Intr condition 60, Own 10-bit address+W received
  $display("%10.0f",Vector," Test 40 Intr condition 60, Own 10-bit address+W received");
  test_name = "40";

  WriteReg (`ADDR, 8'hF2);      // Set 10-bit addressing, GC disabled
  WriteReg (`XADDR, 8'h20);     // Set address 120
  SendStart;
  MaTxData (8'hF2,1);           // Send slave address+W, NACK
  CheckReg (`STATE, 8'hF8);
  WaitIdle;
  CheckRxData (8'hF2,0);
  CheckNoIntr;
  MaTxData (8'h20,1);           // Send 2nd byte of address, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  CheckRxData (8'h20,0);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  MaTxData (8'hA5,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h88);
  CheckReg (`DATA, 8'hA5);
  CheckRxData (8'hA5,1);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 41 Intr condition 60, Own 10-bit address+R received
  $display("%10.0f",Vector," Test 41 Intr condition 60, Own 10-bit address+R received");
  test_name = "41";

  SendStart;
  MaTxData (8'hF2,1);           // Send slave address+W, NACK
  CheckReg (`STATE, 8'hF8);
  WaitIdle;
  CheckNoIntr;
  MaTxData (8'h20,1);           // Send 2nd byte of address, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt, AAK=0
  SendReStart;
  WaitInt;
  CheckReg (`STATE, 8'hA0);     // Clear interrupt
  CheckReg (`CNTL, 8'hCC);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hF3,1);           // 10-bit address+R
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA8);
  CheckReg (`DATA, 8'hF3);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 42 Intr condition E8, 10-bit address, 2nd address byte NACK received
  $display("%10.0f",Vector," Test 42 Intr condition E8, 10-bit address, 2nd address byte NACK received");
  test_name = "42";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE8);

  // Test 43 Intr condition E0, 10-bit address, 2nd address byte ACK received
  $display("%10.0f",Vector," Test 43 Intr condition E0, 10-bit address, ACK received");
  test_name = "43";

  WriteReg (`CNTL, 8'hF4);      // Send STOP then START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF2);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h95);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE0);

  // Test 44 Intr condition 48, 10-bit address, address+R NACK received
  $display("%10.0f",Vector," Test 44 Intr condition 48, 10-bit address, address+R NACK received");
  test_name = "44";

  WriteReg (`CNTL, 8'hF4);      // Send STOP then START
  WaitInt;
  CheckIntr;
  CheckStop;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF0);      // Load address
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE0);
  WriteReg (`CNTL, 8'hE4);      // Re-Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hF3);
  WriteReg (`CNTL, 8'hC4);      // Clear Interrupt
  SlTxData (8'hFF,1);
  WaitInt;
  CheckReg (`STATE, 8'h48);     // Address+R, NACK received

  // Test 45 Intr condition 40, 10-bit address, Address+R, ACK received
  $display("%10.0f",Vector," Test 45 Intr condition 40, 10-bit address, Address+R, ACK received");
  test_name = "45";

  WriteReg (`CNTL, 8'hF4);      // Send STOP then START
  WaitInt;
  CheckIntr;
  CheckStop;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF0);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h95);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE0);
  WriteReg (`CNTL, 8'hE4);      // Re-Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hF3);
  WriteReg (`CNTL, 8'hC4);      // Clear Interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckReg (`STATE, 8'h40);     // Address+R, ACK received
  WriteReg (`CNTL, 8'hD4);      // Send STOP
  WaitStop;
  CheckStop;

  // Test 46 Intr condition 38, Arbitration lost in 2nd address byte
  $display("%10.0f",Vector," Test 46 Intr condition 38, Arbitration lost in 2nd address byte");
  test_name = "46";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hF4,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`DATA, 8'h97);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  CheckNoIntr;
  MaTxData (8'hFE,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;

  // Test 47 Generate bus error after intr condition E8
  $display("%10.0f",Vector," Test 47 Generate bus error after intr condition E8");
  test_name = "47";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hFF);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE8);
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFF,0);  
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle;
  SendStop;

  // Test 48 Generate bus error after intr condition E8
  $display("%10.0f",Vector," Test 48 Generate bus error after intr condition E8");
  test_name = "48";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF0);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE8);
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hE0,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle;
  SendStop;

  // Test 49 Generate bus error after intr condition E0
  $display("%10.0f",Vector," Test 49 Generate bus error after intr condition E0");
  test_name = "49";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;  
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hFF);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hF8,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle;
  SendStop;

  // Test 50 Generate bus error after intr condition E0
  $display("%10.0f",Vector," Test 50 Generate bus error after intr condition E0");
  test_name = "50";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF0);      // Load address+W
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);  
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE0);
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  BusErr (8'hFC,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  WaitIdle;
  SendStop;

  // Test 51 Testing for data dependant error in transmit
  $display("%10.0f",Vector," Test 51 Testing for data dependant error in transmit");
  test_name = "51";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hAE);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'hAE,0);
  WriteReg (`DATA, 8'h00);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h00,0);
  WriteReg (`DATA, 8'h01);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h01,0);
  WriteReg (`DATA, 8'h80);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h80,0);
  WriteReg (`DATA, 8'h81);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h81,0);
  WriteReg (`CNTL, 8'hD4);      // Send STOP
  WaitStop;
  CheckStop;

  // Test 52 Testing for arbitration lost in D7
  $display("%10.0f",Vector," Test 52 Testing for arbitration lost in D7");
  test_name = "52";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h80);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'h7F,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 53 Testing for arbitration lost in D6
  $display("%10.0f",Vector," Test 53 Testing for arbitration lost in D6");
  test_name = "53";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hC0);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hBF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 54 Testing for arbitration lost in D5
  $display("%10.0f",Vector," Test 54 Testing for arbitration lost in D5");
  test_name = "54";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hE0);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hDF,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 55 Testing for arbitration lost in D4
  $display("%10.0f",Vector," Test 55 Testing for arbitration lost in D4");
  test_name = "55";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hF0);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hEF,1);
  WaitInt;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 56 Testing for arbitration lost in D3
  $display("%10.0f",Vector," Test 56 Testing for arbitration lost in D3");
  test_name = "56";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hF8);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hF7,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 57 Testing for arbitration lost in D2
  $display("%10.0f",Vector," Test 57 Testing for arbitration lost in D2");
  test_name = "57";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hFC);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hFB,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 58 Testing for arbitration lost in D1
  $display("%10.0f",Vector," Test 58 Testing for arbitration lost in D1");
  test_name = "58";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hFE);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hFD,1);
  WaitInt;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 59 Testing for arbitration lost in D0
  $display("%10.0f",Vector," Test 59 Testing for arbitration lost in D0");
  test_name = "59";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h54);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'hFF);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  MaTxData (8'hFE,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 60 Testing for arbitration lost in ACK
  $display("%10.0f",Vector," Test 60 Testing for arbitration lost in ACK");
  test_name = "60";

  WriteReg (`CNTL, 8'hE0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h51);      // Load address+R
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK = 0
  MaTxData (8'hC3,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  // Test 61 Testing clock stretching
  $display("%10.0f",Vector," Test 61 Testing clock stretching");
  test_name = "61";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hAA);      // Load address+W
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  Stretch;   //D7 Setup
  Stretch;   //D6 Setup
  Stretch;   //D5
  Stretch;   //D4
  Stretch;   //D3
  Stretch;   //D2
  Stretch;   //D1
  Stretch;   //D0
  Stretch;   //Ack Setup
  CheckNoIntr;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'hAA,1);

  // Test 62 Testing repeated START stretching
  $display("%10.0f",Vector," Test 62 Testing repeated START stretching");
  test_name = "62";


  WriteReg (`CNTL, 8'hE4);      // Send repeated START
  Stretch;
  CheckNoIntr;
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hAA);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);

  // Test 63 Testing STOP stretching
  $display("%10.0f",Vector," Test 63 Testing STOP stretching");
  test_name = "63";

  WriteReg (`CNTL, 8'hD4);      // Send STOP
  Stretch;
  WaitStop;
  CheckStop;

  // Test 64 Incorrect address received
  $display("%10.0f",Vector," Test 64 10-bit address, address wrong");
  test_name = "64";

  WriteReg (`ADDR, 8'hF0);      // Set 10-bit addressing, GC disabled
  WriteReg (`XADDR, 8'h20);     // Set address 020
  SendStart;
  MaTxData (8'h20,1);           // Send invalid address, NACK expected
  WaitIdle;
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  SendStop;

  // Test 65 Testing data dependancies in address recognition, D1
  $display("%10.0f",Vector," Test 65 Testing data dependancies in address recognition, D1");
  test_name = "65";

  WriteReg (`ADDR, 8'hAA);      // Set address 55, GC disabled
  SendStart;
  MaTxData (8'hA8,1);           // Send incorrect address, NACK expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);
  SendReStart;                  // Repeated START
  MaTxData (8'hAA,1);           // Send slave address+W, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 66 Testing data dependancies in address recognition, D2
  $display("%10.0f",Vector," Test 66 Testing data dependancies in address recognition, D2");
  test_name = "66";

  SendReStart;                  // Send repeated START
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hAE,1);           // Send incorrect address, NACK expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);
  SendReStart;                  // Repeated START
  MaTxData (8'hAA,1);           // Send slave address+W, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 67 Testing data dependancies in address recognition, D3
  $display("%10.0f",Vector," Test 67 Testing data dependancies in address recognition, D3");
  test_name = "67";

  SendReStart;                  // Send repeated START
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hA2,1);           // Send incorrect address, ACK not expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);

  // Test 68 Testing data dependancies in address recognition, D4
  $display("%10.0f",Vector," Test 68 Testing data dependancies in address recognition, D4");
  test_name = "68";

  SendReStart;                  // Send repeated START
  MaTxData (8'hBA,1);           // Send incorrect address, ACK not expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);

  // Test 69 Testing data dependancies in address recognition, D5
  $display("%10.0f",Vector," Test 69 Testing data dependancies in address recognition, D5");
  test_name = "69";

  SendReStart;                  // Send repeated START
  MaTxData (8'h8A,1);           // Send incorrect address, ACK not expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);

  // Test 70 Testing data dependancies in address recognition, D6
  $display("%10.0f",Vector," Test 70 Testing data dependancies in address recognition, D6");
  test_name = "70";

  SendReStart;                  // Send repeated START
  MaTxData (8'hEA,1);           // Send incorrect address, ACK not expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);

  // Test 71 Testing data dependancies in address recognition, D7
  $display("%10.0f",Vector," Test 71 Testing data dependancies in address recognition, D7");
  test_name = "71";

  SendReStart;                  // Send repeated START
  MaTxData (8'h2A,1);           // Send incorrect address, ACK not expected
  WaitIdle;
  CheckReg (`STATE, 8'hF8);
  SendReStart;                  // Repeated START
  MaTxData (8'hAA,1);           // Send slave address+W, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 72 Test slave acting as if STOP on bus when STP set
  $display("%10.0f",Vector," Test 72 Test slave acting as if STOP on bus when STP set");
  test_name = "72";

  WriteReg (`ADDR, 8'h72);
  SendStart;
  MaTxData (8'h72,1);           // Send slave address+W, ACK expected
  WaitIdle;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h86,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h86);
  WriteReg (`CNTL, 8'hD4);      // Set STP
  CheckNoIntr;
  MaTxData (8'h87,1);           // This will not be received
  WaitIdle;
  CheckNoIntr;
  SendStop;                     // Free the bus

  // Test 73 Test slave stay in idle after intr condition C8
  $display("%10.0f",Vector," Test 73 Test slave stay in idle after intr condition C8");
  test_name = "73";

  WriteReg (`ADDR, 8'h30);
  SendStart;
  MaTxData (8'h31,1);           // Send slave address+R, ACK expected
  WaitInt; 
  CheckIntr;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'hB5);      // Load data
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hB8);
  CheckRxData (8'hB5,0);
  WriteReg (`DATA, 8'h94);      // Load data
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  MaTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hC8);
  CheckRxData (8'h94,0);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt, AAK=0
  SendReStart;
  MaTxData (8'h31,1);           // Send slave address+R, ACK not expected
  WaitIdle;
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  SendStop;

  // Test 74 Disabling the I2C bus
  $display("%10.0f",Vector," Test 74 Disabling the I2C bus");
  test_name = "74";

  WriteReg (`ADDR, 8'h34);      // Set address 19, GC disabled
  WriteReg (`CNTL, 8'h84);      // Disable bus, AAK=1
  SendStart;
  MaTxData (8'h34,1);           // Send slave address+W, NACK
  WaitIdle;
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  WriteReg (`CNTL, 8'hC4);      // Enable bus, AAK=1
  SendReStart;
  MaTxData (8'h34,0);           // Send slave address+W, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);

  // Test 75 Disabling the interrupt
  $display("%10.0f",Vector," Test 75 Disabling the interrupt");
  test_name = "75";

  WriteReg (`CNTL, 8'h44);      // Disable INTR, AAK=1
  MaTxData (8'h76,1);           // Send data, ACK expected
  WaitIdle;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h76);
  CheckNoIntr;
  WriteReg (`CNTL, 8'hC4);      // Clear IFLG
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear IFLG


  // Test 76 Arbitration lost in 2nd address byte and own address received
  $display("%10.0f",Vector," Test 76 Arbitration lost in 2nd address byte and own address received");
  test_name = "76";

  WriteReg (`ADDR, 8'hF2);      // Set 10-bit addressing, GC disabled
  WriteReg (`XADDR, 8'h4D);     // Set address 14D
  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF2);      // Load 1st address byte
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hF2,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h4F);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);
  CheckNoIntr;
  MaTxData (8'h4D,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h68);
  CheckRxData (8'h4D,0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt


  // Test 77 Bus error during 2nd address byte
  $display("%10.0f",Vector," Test 77 Bus error during 2nd address byte");
  test_name = "77";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;  
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load 1st address byte
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);
  BusErr (8'hF0,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h00);
  WriteReg (`CNTL, 8'hD4);      // Clear interrupt
  WaitIdle;
  SendStop;

   // Test 78 Repeated START after sending 10-bit address
  $display("%10.0f",Vector," Test 78 Repeated START after sending 10-bit address");
  test_name = "78";

  WriteReg (`CNTL, 8'hE4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF4);      // Load 1st address byte
  WriteReg (`CNTL, 8'hC4);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  WriteReg (`DATA, 8'h55);      // Load 2nd address byte
  WriteReg (`CNTL, 8'hC4);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hE8);
  WriteReg (`CNTL, 8'hE4);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);

  // Test 79 Repeated START after sending data
  $display("%10.0f",Vector," Test 79 Repeated START after sending data");
  test_name = "79";

  WriteReg (`DATA, 8'h16);      // Load address+W
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h37);      // Load data
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h37,0);
  WriteReg (`CNTL, 8'hE4);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'h29);      // Load address
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  CheckRxData (8'h29,0);
  WriteReg (`CNTL, 8'hD4);      // Send STOP
  WaitStop;
  CheckStop;

  // Test 80 Receive repeated START after receiving data
  $display("%10.0f",Vector," Test 80 Receive repeated START after receiving data");
  test_name = "80";

  WriteReg (`ADDR, 8'h84);      // Set address 42, GC disabled
  SendStart;
  MaTxData (8'h84,1);           // Send address+W, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h14,0);           // Send data, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h14);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendReStart;                  // Repeated START
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h84,1);           // Send address+R
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 81 Checking received data
  $display("%10.0f",Vector," Test 81 Checking received data");
  test_name = "81";

  WriteReg (`ADDR, 8'h34);      // Set address 1A, GC disabled
  SendStart;
  MaTxData (8'h34,1);           // Send address+W, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h00,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h00);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'hFF,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h01,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h01);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h02,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h02);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h04,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h04);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h08,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h08);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h10,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h10);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h20,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h20);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h40,1);           // Send data, NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h40);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  MaTxData (8'h80,1);           // Send data, ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h80);
  CheckReg (`DATA, 8'h80);
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  SendStop;
  WaitInt;
  WriteReg (`CNTL, 8'hC4);      // Clear interrupt

  // Test 82 Software reset
  $display("%10.0f",Vector," Test 82 Software reset");
  test_name = "82";

  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hE4);      //Send Start
  WaitInt;  
  CheckIntr;
  WriteVAL (`SRST, 8'hFF);      //No effect
  CheckReg (`STATE, 8'h08);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`DATA, 8'hFF);
  WriteReg (`SRST, 8'h00);
  WaitT (4);                    //Reset takes 2 CLOCK periods to do
  WriteReg (`SRST, 8'hFF);      //Edge of SCL changes data so re-reset
  WaitT (4);
  CheckReg (`STATE, 8'hF8);
  CheckReg (`CNTL, 8'h00);
  CheckReg (`DATA, 8'h00);
  CheckNoIntr;

`ifdef divider_en
  FS_div = 4;
  HS_div = 2;
  WriteReg (`CCRFS, 8'h02);   //Set FS divisor 
  WriteReg (`CCRH,  8'h01);   //Set HS divisor 
`endif

  // Test 83 Read ADDR, XADDR and CNTR registers
  $display("%10.0f",Vector," Test 83 Read ADDR, XADDR and CNTR registers");
  test_name = "83";

  WriteReg (`ADDR, 8'hFF);
  WriteVAL (`ADDR, 8'h00);
  CheckReg (`ADDR, 8'hFF);
  WriteReg (`ADDR, 8'h00);
  WriteVAL (`ADDR, 8'hFF);
  CheckReg (`ADDR, 8'h00);

  WriteReg (`DATA, 8'hFF);
  WriteVAL (`DATA, 8'h00);
  CheckReg (`DATA, 8'hFF);
  WriteReg (`DATA, 8'h00);
  WriteVAL (`DATA, 8'hFF);
  CheckReg (`DATA, 8'h00);

  WriteReg (`XADDR, 8'hFF);
  WriteVAL (`XADDR, 8'h00);
  CheckReg (`XADDR, 8'hFF);
  WriteReg (`XADDR, 8'h00);
  WriteVAL (`XADDR, 8'hFF);
  CheckReg (`XADDR, 8'h00);

  WriteReg (`CNTL, 8'h00);
  WriteVAL (`CNTL, 8'hFF);
  CheckReg (`CNTL, 8'h00);
  WriteReg (`CNTL, 8'hC4);
  WriteVAL (`CNTL, 8'h00);
  CheckReg (`CNTL, 8'hC4);

// Test 84 Slave entry into High speed mode write
  $display("%10.0f",Vector," Test 84 Slave Entry into High speed mode write");
  test_name = "84";

  WriteReg (`ADDR, 8'h84);   //GCE not enabled
  WriteReg (`XADDR, 8'h85);
  WriteReg (`CNTL, 8'hC4);   //Enable

  SendStart;
  MaTxData (8'h08,1);        //Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08,1);
  SendReStart;                 //Re-Start
  HS_Mode = 1;
  MaTxData (8'h84,1);        //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'h84);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hDC,1);        //Data
  WaitInt;
  CheckReg (`DATA, 8'hDC);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h80);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hED,1);        //Data
  WaitInt;
  CheckReg (`DATA, 8'hED);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h80);
  WriteReg (`CNTL, 8'hC4);
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);

  // Test 85 Slave entry into High speed mode read 
  $display("%10.0f",Vector," Test 85 Slave Entry into High speed mode read");
  test_name = "85";


  WriteReg (`ADDR, 8'h85);   //GCE enabled
  WriteReg (`XADDR, 8'h86);
  WriteReg (`CNTL, 8'hC4);   //Enable
  SendStart;
  MaTxData (8'h09,1);        //Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h09,1);
  SendReStart;                 //Re-Start
  HS_Mode = 1;
  MaTxData (8'h85,1);        //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'h85);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'hED);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckReg (`DATA, 8'hED);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hB8);
  WriteReg (`DATA, 8'hFE);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckReg (`DATA, 8'hFE);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hB8);
  WriteReg (`CNTL, 8'hC4);
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);

  // Test 86 Master entry into High speed mode write
  $display("%10.0f",Vector," Test 86 Master entry into High speed mode write");
  test_name = "86";

  WriteReg (`ADDR, 8'h86);   //GCE not enabled
  WriteReg (`XADDR, 8'h87);
  WriteReg (`CNTL, 8'hE4);   //Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h0A);   //High speed select
  WriteReg (`CNTL, 8'hC4);   //Enable
  WaitInt;
  WriteReg (`CNTL, 8'hE4);   //Re-Start
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'h8E);   //Address+W
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h8E,0);
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h71);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h71,0);
  CheckReg (`STATE, 8'h28);
  WriteReg (`DATA, 8'h82);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h82,0);
  CheckReg (`STATE, 8'h28);
  WriteReg (`CNTL, 8'hD4);   //Send Stop
  WaitStop;
  CheckStop;
  HS_Mode = 0;

  // Test 87 Master entry into High speed mode read
  $display("%10.0f",Vector," Test 87 Master entry into High speed mode read");
  test_name = "87";

  WriteReg (`ADDR, 8'h86);   //GCE not enabled
  WriteReg (`XADDR, 8'h88);
  WriteReg (`CNTL, 8'hE4);   //Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h0B);   //High speed select
  WriteReg (`CNTL, 8'hC4);   //Enable
  WaitInt;
  WriteReg (`CNTL, 8'hE4);   //Re-Start
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'h87);   //Address+R
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h87,0);
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'h9A,1);        //Data
  WaitInt;
  CheckRxData (8'h9A,0);
  CheckReg (`STATE, 8'h50);
  WriteReg (`CNTL, 8'hC0);
  SlTxData (8'hAB,1);        //Data
  WaitInt;
  CheckRxData (8'hAB,1);
  CheckReg (`STATE, 8'h58);
  WriteReg (`CNTL, 8'hD4);   //Send Stop
  WaitStop;
  CheckStop;
  HS_Mode = 0;

  // Test 88 Slave entry into High speed mode 10-bit address write
  $display("%10.0f",Vector," Test 88 Slave entry into High speed mode 10-bit address write");
  test_name = "88";

  WriteReg (`ADDR, 8'hF6);   //GCE not enabled
  WriteReg (`XADDR, 8'h89);
  WriteReg (`CNTL, 8'hC4);   //Enable
  SendStart;
  MaTxData (8'h0E,1);        //Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h0E,1);
  SendReStart;                 //Re-Start
  HS_Mode = 1;
  MaTxData (8'hF6,1);        //Slave Address
  WaitIdle;
  MaTxData (8'h89,1);        //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'h89);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'h12,1);        //Data
  WaitInt;
  CheckReg (`DATA, 8'h12);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h80);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'h34,1);        //Data
  WaitInt;
  CheckReg (`DATA, 8'h34);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h80);
  WriteReg (`CNTL, 8'hC4);
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);

  // Test 89 Slave entry into High speed mode 10-bit address read
  $display("%10.0f",Vector," Test 89 Slave entry into High speed mode 10-bit address read");
  test_name = "89";

  WriteReg (`ADDR, 8'hF6);   //GCE not enabled
  WriteReg (`XADDR, 8'h8A);
  WriteReg (`CNTL, 8'hC4);   //Enable
  SendStart;
  MaTxData (8'h09,1);        //Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h09,1);
  SendReStart;                 //Re-Start
  HS_Mode = 1;
  MaTxData (8'hF6,1);        //Slave Address
  WaitIdle;
  MaTxData (8'h8A,1);        //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'h8A);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h60);
  WriteReg (`CNTL, 8'hC4);
  SendReStart;
  WaitInt;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hF7,1);       //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'hF7);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h56);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckReg (`DATA, 8'h56);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hB8);
  WriteReg (`DATA, 8'h78);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckReg (`DATA, 8'h78);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hB8);
  WriteReg (`CNTL, 8'hC4);
  SendReStart;
  WaitInt;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hF7,1);       //Slave Address
  WaitInt;
  CheckReg (`DATA, 8'hF7);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h9A);
  WriteReg (`CNTL, 8'hC4);
  MaTxData (8'hFF,1);        //ACK
  WaitInt;
  CheckReg (`DATA, 8'h9A);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'hC0);
  WriteReg (`CNTL, 8'hC4);
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);
  WriteReg (`CNTL, 8'hC4);

  // Test 90 Master entry into High speed mode 10-bit Address write
  $display("%10.0f",Vector," Test 90 Master entry into High speed mode 10-bit Address write");
  test_name = "90";

  WriteReg (`ADDR, 8'hF0);   //GCE not enabled
  WriteReg (`XADDR, 8'h90);
  WriteReg (`CNTL, 8'hE4);   //Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h0A);   //High speed select
  WriteReg (`CNTL, 8'hC4);   //Enable
  WaitInt;
  WriteReg (`CNTL, 8'hE4);   //Re-Start
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hF0);   //Address+W
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'hF0,0);
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h91);   //Address
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h91,0);
  CheckReg (`STATE, 8'hE0);
  WriteReg (`DATA, 8'h9A);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'h9A,0);
  CheckReg (`STATE, 8'h28);
  WriteReg (`DATA, 8'hBC);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'hBC,0);
  CheckReg (`STATE, 8'h28);
  WriteReg (`CNTL, 8'hD4);   //Send Stop
  WaitStop;
  CheckStop;
  HS_Mode = 0;

  // Test 91 Master entry into High speed mode 10-bit Address read
  $display("%10.0f",Vector," Test 91 Master entry into High speed mode 10-bit Address read");
  test_name = "91";

  WriteReg (`ADDR, 8'hF0);   //GCE not enabled
  WriteReg (`XADDR, 8'h91);
  WriteReg (`CNTL, 8'hE4);   //Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h0B);   //High speed select
  WriteReg (`CNTL, 8'hC4);   //Enable
  WaitInt;
  WriteReg (`CNTL, 8'hE4);   //Re-Start
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);
  WriteReg (`DATA, 8'hF0);   //Address+W
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'hF0,0);
  CheckReg (`STATE, 8'h18);
  WriteReg (`DATA, 8'h92);   //Address
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  WriteReg (`CNTL, 8'hE4);   //Re-Start
  WaitInt;
  CheckStart;
  WriteReg (`DATA, 8'hF1);   //Address+R
  WriteReg (`CNTL, 8'hC4);   //Enable
  SlTxData (8'hFF,0);        //ACK
  WaitInt;
  CheckRxData (8'hF1,0);
  CheckReg (`STATE, 8'h40);
  WriteReg (`CNTL, 8'hC4);
  SlTxData (8'hEF,1);        //Data
  WaitInt;
  CheckRxData (8'hEF,0);
  CheckReg (`STATE, 8'h50);
  WriteReg (`CNTL, 8'hC0);
  SlTxData (8'h01,1);        //Data
  WaitInt;
  CheckRxData (8'h01,1);
  CheckReg (`STATE, 8'h58);
  WriteReg (`CNTL, 8'hD4);   //Send Stop
  WaitStop;
  CheckStop;
  HS_Mode = 0;

  // Test 92 Master write, ENAB not set
  $display("%10.0f",Vector," Test 92 Master write, ENAB not set");
  test_name = "92";

  WriteReg (`CNTL, 8'hA0);
  WriteReg (`CNTL, 8'h80);      //Test Start bit not cleared
  CheckReg (`CNTL, 8'hA0);
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  CheckReg (`CNTL, 8'h88);
  WriteReg (`CNTL, 8'h88);      //Test Interrupt not cleared
  CheckReg (`CNTL, 8'h88);

  WriteReg (`DATA, 8'hCE);      //Slave address+W               
  WriteReg (`CNTL, 8'h80);
  CheckNoIntr;
  SlTxData (8'hFF, 1'b0);       // Slave transmit with ACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  CheckReg (`DATA, 8'hCE);
  CheckRxData (8'hCE,0);

  WriteReg (`DATA, 8'h31);
  WriteReg (`CNTL, 8'h80);
  CheckNoIntr;
  SlTxData (8'hFF, 1'b0);       // Slave transmit with ACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h28);
  CheckReg (`DATA, 8'h31);
  CheckRxData (8'h31,0);

  WriteReg (`CNTL, 8'h90);
  WriteReg (`CNTL, 8'h80);     // Test Stop bit not cleared
  CheckReg (`CNTL, 8'h90);
  CheckNoIntr;
  CheckReg (`STATE, 8'hF8);
  WaitStop;
  CheckStop;

  // Test 93 Master Repeated START, ENAB not set
  $display("%10.0f",Vector," Test 93 Master Repeated START, ENAB not set");
  test_name = "93";

  WriteReg (`CNTL, 8'hA0);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h80);
  WriteReg (`CNTL, 8'h80);      // Send address+W
  CheckNoIntr;
  SlTxData (8'hFF, 1'b1);       // Slave transmit with NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckReg (`DATA, 8'h80);
  CheckRxData (8'h80,1);
  WriteReg (`CNTL, 8'hA0);      // Send repeated START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h10);

  WriteReg (`DATA, 8'h99);
  WriteReg (`CNTL, 8'h80);      // Send address+R
  CheckNoIntr;
  SlTxData (8'hFF,0);           // Slave transmit with ACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h40);
  CheckReg (`DATA, 8'h99);
  CheckRxData (8'h99,0);

  WriteReg (`DATA, 8'h80);
  WriteReg (`CNTL, 8'h80);
  CheckNoIntr;
  SlTxData (8'hA9,1);           // Slave transmit with NACK
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h58);
  CheckReg (`DATA, 8'hA9);
  CheckRxData (8'hA9,1);

  WriteReg (`CNTL, 8'h90);
  CheckNoIntr;
  #(`CYC * 2) CheckReg (`STATE, 8'hF8);
  WaitStop;
  CheckStop;

  // Test 94 Intr condition 38, Arbitration lost in address+R, ENAB not set
  $display("%10.0f",Vector," Test 94 Intr condition 38, Arbitration lost in address+R, ENAB not set");
  test_name = "94";

  WriteReg (`ADDR, 8'hFD);      // Set address = 7E, GC enabled
  WriteReg (`CNTL, 8'hA4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF8);
  WriteReg (`CNTL, 8'h84);      // Send address+W
  CheckNoIntr;
  MaTxData (8'hF1,1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  CheckReg (`DATA, 8'hF1);
  WriteReg (`CNTL, 8'h84);      // Clear interrupt
  SendStop;


  // Test 95 Intr condition 38, Arbitration lost and general call received, ENAB not set
  $display("%10.0f",Vector," Test 95 Intr condition 38, Arbitration lost and general call received, ENAB not set");
  test_name = "95";

  WriteReg (`ADDR, 8'hFD);      // Set address = 7E, GC enabled
  WriteReg (`CNTL, 8'hA4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h07);
  WriteReg (`CNTL, 8'h84);      // Send address+R
  CheckNoIntr;
  MaTxData (8'h00,1);           // GCA
  WaitInt;
  CheckIntr;
  CheckRxData (8'h00,1);
  CheckReg (`STATE, 8'h38);
  CheckReg (`DATA, 8'h00);  
  WriteReg (`CNTL, 8'h84);      // Clear interrupt
  SendStop;

  // Test 96 Intr condition 38, Arbitration lost and own address+W received, ENAB not set
  $display("%10.0f",Vector," Test 96 Intr condition 38, Arbitration lost and own address+W received, ENAB not set");
  test_name = "96";

  WriteReg (`ADDR, 8'h04);      // Set address = 02, GC not enabled
  WriteReg (`CNTL, 8'hA4);      // Send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h07);
  WriteReg (`CNTL, 8'h84);      // Send address+R
  MaTxData (8'h04,1);
  WaitInt;
  WaitT(18);
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  CheckReg (`DATA, 8'h04);  
  WriteReg (`CNTL, 8'h84);      // Clear interrupt
  SendStop;

  // Test 97 Arbitration lost in 2nd address byte and own address+W received, ENAB not set
  $display("%10.0f",Vector," Test 97 Arbitration lost in 2nd address byte and own address+W received, ENAB not set");
  test_name = "97";

  WriteReg (`ADDR, 8'hF3);      // Set 10-bit addressing, GC Enabled 
  WriteReg (`XADDR, 8'h4F);     // Set address 14F
  WriteReg (`CNTL, 8'hA4);      // Send START
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hF2);      // Load 1st address byte+W
  WriteReg (`CNTL, 8'h84);
  MaTxData (8'hFF,0);           // ACK received
  WaitInt;
  WaitT(20);                    //Slow interrupt response
  CheckIntr;
  CheckReg (`STATE, 8'h18);
  CheckReg (`DATA, 8'hF2);  
  WriteReg (`DATA, 8'h50);      // Load 2nd address byte
  WriteReg (`CNTL, 8'h84);
  CheckNoIntr;
  MaTxData (8'h4F,0);           // 2nd address byte, ACK received
  WaitInt;
  WaitT(10);                    //Slow interrupt response
  CheckIntr;
  CheckReg (`STATE, 8'h38);
  CheckReg (`DATA, 8'h4F);  
  WriteReg (`CNTL, 8'h84);      // Clear interrupt
  SendStop;

  // Test 98 General Call Address received, but GCE not enabled
  $display("%10.0f",Vector," Test 98 General Call Address received, but GCE not enabled");
  test_name = "98";

  WriteReg (`ADDR, 8'h6C);    //Set address of 36h, GCE disabled
  WriteReg (`CNTL, 8'hC4);    //ENAB, and AAK both set
  WaitT(10);
  SendStart;
  MaTxData (8'h00,1);         //General Call Address
  WaitIdle;
  CheckReg (`DATA, 8'h00);
  CheckReg (`CNTL, 8'hC4);
  CheckReg (`STATE, 8'hF8);
  CheckRxData (8'h00,1);      //Show NO ACK response
  CheckNoIntr;
  SendStop;

  WriteReg (`ADDR, 8'h6D);   //Set address oe 36h, GCE enabled
  WaitT(10);
  SendStart;
  MaTxData (8'h00,1);         //General Call Address
  WaitIdle;
  CheckReg (`DATA, 8'h00);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`STATE, 8'h70);
  CheckRxData (8'h00,0);      //Show ACK response
  CheckIntr;
  WriteReg (`CNTL, 8'hC4);
  SendStop;
  WaitInt;
  CheckReg (`STATE, 8'hA0);  //Clear Stop detection
  WriteReg (`CNTL, 8'hC4);
 
  // Test 99 Show Start is held while I2C bus is busy
  $display("%10.0f",Vector," Test 99 Show Start is held while I2C bus is busy");
  test_name = "99";

  SendStart;                //Make I2C busy
  WriteReg (`CNTL, 8'hE4);
  MaTxData (8'h7C,0);       //Address+W
  WaitIdle;
  CheckNoIntr;
  MaTxData (8'hFF,0);       //Data
  WaitIdle;
  CheckNoIntr;
  MaTxData (8'hFF,1);       //Last Data
  WaitIdle;
  CheckNoIntr;
  SendStop;

  WaitInt;                  //Wait for Start to be sent
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h7C);  //Address+W
  WriteReg (`CNTL, 8'hC4);  //Clear Interrupt
  SlTxData (8'hFF,1);       //No ACK
  WaitInt;
  CheckReg (`STATE, 8'h20);
  WriteReg (`CNTL, 8'hD4);  //Send Stop
  WaitStop; 
  CheckStop;  

  WaitT (25);


`ifdef divider_en

  ////////////////////////////////////////////////////////////////////////
  // Clock Divider Tests
  ////////////////////////////////////////////////////////////////////////

  $display("%10.0f",Vector," Software reset");

  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hE4);      //Send Start
  WaitInt;  
  CheckIntr;
  WriteVAL (`SRST, 8'hFF);      //No effect
  CheckReg (`STATE, 8'h08);
  CheckReg (`CNTL, 8'hCC);
  CheckReg (`DATA, 8'hFF);
  WriteReg (`SRST, 8'h00);
  WaitT (4);                    //Reset takes 2 CLOCK periods to do
  WriteReg (`SRST, 8'hFF);      //Edge of SCL changes data so re-reset
  WaitT (4);
  CheckReg (`STATE, 8'hF8);
  CheckReg (`CNTL, 8'h00);
  CheckReg (`DATA, 8'h00);
  CheckNoIntr;

  // Read ADDR, XADDR and CNTR registers
  $display("%10.0f",Vector," Read ADDR, XADDR and CNTR registers");

  WriteReg (`ADDR, 8'hFF);
  WriteVAL (`ADDR, 8'h00);
  CheckReg (`ADDR, 8'hFF);
  WriteReg (`ADDR, 8'h00);
  WriteVAL (`ADDR, 8'hFF);
  CheckReg (`ADDR, 8'h00);

  WriteReg (`DATA, 8'hFF);
  WriteVAL (`DATA, 8'h00);
  CheckReg (`DATA, 8'hFF);
  WriteReg (`DATA, 8'h00);
  WriteVAL (`DATA, 8'hFF);
  CheckReg (`DATA, 8'h00);

  WriteReg (`XADDR, 8'hFF);
  WriteVAL (`XADDR, 8'h00);
  CheckReg (`XADDR, 8'hFF);
  WriteReg (`XADDR, 8'h00);
  WriteVAL (`XADDR, 8'hFF);
  CheckReg (`XADDR, 8'h00);

  WriteReg (`CNTL, 8'h00);
  WriteVAL (`CNTL, 8'hFF);
  CheckReg (`CNTL, 8'h00);
  WriteReg (`CNTL, 8'hC4);
  WriteVAL (`CNTL, 8'h00);
  CheckReg (`CNTL, 8'hC4);

 
  // Test 100 Testing FS clock divider M=1, N=0
  $display("%10.0f",Vector," Test 100 Testing FS clock divider M=1, N=0");
  test_name = "test100";

  FS_div = 2;
  WriteReg (`CCRFS, 8'h08);

  WriteReg (`ADDR, 8'h5A);
  SendStart; // Test bench (master) starts transfer
  MaTxData (8'h5B,1);		// Send address+R. ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h4C);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt and set AAK
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hC0);
  CheckRxData (8'h4C,1);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WriteReg (`CNTL, 8'hE0);	// Clear interrupt and send Start
  WaitInt;
  CheckStart;
  CheckIntr;

  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h46);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 21 * 8)
  CheckNoIntr;
  #(`CYC * 24)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h46, 1);       // Check Addr+W received by testbench, no ACK.
  WriteReg (`CNTL, 8'hD4);	// Send Stop (master aborts transfer)
  #(`CYC * 50)
  CheckStop;


  test_name = "test101";
  // Test 101 Testing FS clock divider M=2
  $display("%10.0f",Vector," Test 101 Testing FS clock divider M=2");

  FS_div = 3;
  WriteReg (`CCRFS, 8'h10);

  WriteReg (`ADDR, 8'hA5);
  SendStart;
  MaTxData (8'hA5, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h9D);	// Load data
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  MaTxData (8'hFF,1);

  WaitInt;
  CheckReg (`STATE, 8'hD0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h9D,1);        // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;                     

  WriteReg (`CNTL, 8'hE0);      // Clear interrupt and send START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h68);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 32 * 8)
  CheckNoIntr;
  #(`CYC * 24)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h68, 1);       
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  #(`CYC * 50)
  CheckStop;


  test_name = "test102";
  // Test 102 Testing FS clock divider M=15
  $display("%10.0f",Vector," Test 102 Testing FS clock divider M=15");

  FS_div = 16;
  WriteReg (`CCRFS, 8'h78);

  WriteReg (`ADDR, 8'h6A);
  SendStart;
  MaTxData (8'h6B, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckIntr;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h4C);	// Load data
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  MaTxData (8'hFF,1);

  WaitInt;
  CheckReg (`STATE, 8'hD0);
  CheckRxData (8'h4C,1);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;

  WriteReg (`CNTL, 8'hE0);      // Clear interrupt and send START
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'hD4);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 178 * 8)
  CheckNoIntr;
  #(`CYC * 24)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'hD4, 1);
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  #(`CYC * 250)
  CheckStop;


  test_name = "test103";
  // Test 103 Testing FS clock divider N=1
  $display("%10.0f",Vector," Test 103 Testing FS clock divider N=1");

  FS_div = 2;
  WriteReg (`CCRFS, 8'h01);

  WriteReg (`ADDR, 8'hE4);
  // Send Start
  SendStart;

  //  Send address+R. ACK expected
  MaTxData (8'hE5, 1);
  WaitInt;

  CheckReg (`STATE, 8'hA8);
  CheckRxData (8'hE5, 0);

  WriteReg (`DATA, 8'h2B);	// Load data
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hD0);
  CheckRxData (8'h2B, 1);
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  SendStop;

  WriteReg (`CNTL, 8'hE0);	// Clear interrupt
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h34);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 21 * 8)
  CheckNoIntr;
  #(`CYC * 18)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h34, 1);
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  #(`CYC * 38)
  CheckStop;


  test_name = "test104";
  // Test 104 Testing FS clock divider N=2
  $display("%10.0f",Vector," Test 104 Testing FS clock divider N=2");
  FS_div = 4;
  WriteReg (`CCRFS, 8'h02);
  WriteReg (`CNTL, 8'hC4);	// setup for slave 
  CheckReg (`STATE, 8'hF8);
  WriteReg (`ADDR, 8'h4C);
  // Send Start
  SendStart;

  // Send address+R. ACK expected
  MaTxData (8'h4D, 1);
  WaitInt;

  CheckReg (`STATE, 8'hA8);
  CheckRxData (8'h4D, 0);

  WriteReg (`DATA, 8'h8C);	// Load data
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  MaTxData (8'hFF, 1);

  WaitInt;
  CheckReg (`STATE, 8'hD0);
  CheckRxData (8'h8C, 1);
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  SendStop;                     // Send Stop;
  WaitInt;

  WriteReg (`CNTL, 8'hE0);	// Clear interrupt
  WaitInt;
  CheckStart;
  CheckIntr;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h34);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 43 * 8)
  CheckNoIntr;
  #(`CYC * 35)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h34, 1);
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  #(`CYC * 70)
  CheckStop;

  test_name = "tes105";
  // Test 105 Testing FS clock divider N=3-7
  $display("%10.0f",Vector," Test 105 Testing FS clock divider N=3-7");
  FS_div = 128;
  WriteReg (`CCRFS, 8'h07);
  WriteReg (`ADDR, 8'h4C);
  // Send Start
  SendStart;
  // Send address+R. ACK expected
  MaTxData(8'h4D, 1);
  WaitInt;

  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h8C);	// Load data
  WriteReg (`CNTL, 8'hC0);	// Clear interrupt
  MaTxData (8'hFF, 1);

  WaitInt;
  CheckReg (`STATE, 8'hD0);
  CheckRxData (8'h8C, 1);
  WriteReg (`CNTL, 8'hE0);	// Clear interrupt
  SendStop;                     // Send Stop;

  WaitInt;
  WriteReg (`CNTL, 8'hE0);	// Clear interrupt and send Start
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);
  WriteReg (`DATA, 8'h5A);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  #(`CYC * 1280 * 1)
  FS_div = 64;
  WriteReg (`CCRFS, 8'h06);	// Set N=6
  #(`CYC * 640 * 2)
  FS_div = 32;
  WriteReg (`CCRFS, 8'h05);	// Set N=5
  #(`CYC * 320 * 2)
  FS_div = 16;
  WriteReg (`CCRFS, 8'h04);	// Set N=4
  #(`CYC * 160 * 3);
  #(`CYC * 20)
  CheckNoIntr;
  #(`CYC * 160)
  CheckIntr;
  CheckReg (`STATE, 8'h20);
  CheckRxData (8'h5A, 1);
  FS_div = 8;
  WriteReg (`CCRFS, 8'h03);	// Set N=3
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  #(`CYC * 120)
  CheckStop;



  ////////////////////////////////////////////////////////////////////////
  // High speed Clock Divider tests
  ////////////////////////////////////////////////////////////////////////

  WriteReg (`STATE, 8'hF8);	// Check status

  FS_div = 1; // Set FS divider to 1
  WriteReg (`CCRFS, 8'h00);     //Set FS divisor to div 1

  $display("%10.0f",Vector," Test 106 Testing HS clock divider M=1, N=0");
  test_name = "test106";

  HS_div = 2;
  WriteReg (`CCRH,  8'h08);     // Set HS divisor

  WriteReg (`ADDR, 8'h5A);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  HS_Mode = 1;
  SendReStart;
  MaTxData (8'h5B, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h4C);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt and set AAK
  MaTxData (8'hFF, 1);          // ACK
  WaitInt;
  CheckReg (`STATE, 8'hC0);
  CheckRxData (8'h4C, 1);
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt

  CheckReg (`STATE, 8'hC0);
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START transmitted
  WriteReg (`DATA, 8'h46);      // Send this address+W
  WriteReg (`CNTL, 8'hC0);	// Send address+W and enable ACK

  SlTxData (8'hFF, 0);          // ACK
  #(`CYC * 22 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);     // Check ACK received by mi2cv2 after data sent
  CheckRxData (8'h46, 0);       // Check Addr+W received by testbench, ACK.

  WriteReg (`DATA, 8'hB9);      // Now send a data byte
  WriteReg (`CNTL, 8'hC0);
  SlTxData (8'hFF, 0);          // ACK
  WaitInt;
  CheckRxData (8'hB9, 0);
  CheckReg (`STATE, 8'h28);
  WriteReg (`CNTL, 8'hD4);	// Send Stop (master aborts transfer)
  WaitStop;
  CheckStop;
  HS_Mode = 0;


  test_name = "test107";
  // Test 107 Testing HS clock divider M=2, N=0
  $display("%10.0f",Vector," Test 107 Testing HS clock divider M=2, N=0");

  HS_div = 3;
  WriteReg (`CCRH, 8'h10);

  WriteReg (`ADDR, 8'hA5);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  SendReStart;
  HS_Mode = 1;
  MaTxData (8'hA5, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h9D);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h9D, 1);       // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // Clear interrupt and send ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START
  WriteReg (`DATA, 8'h68);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  SlTxData (8'hFF, 0);          // ACK expected
  #(`CYC * 32 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'h68, 0);       // Check ACK returned
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  WaitStop;
  CheckStop;


  test_name = "test108";
  // Test 108 Testing HS clock divider M=15, N=0
  $display("%10.0f",Vector," Test 108 Testing HS clock divider M=15, N=0");

  FS_div = 16;
  WriteReg (`CCRFS, 8'h78);


  WriteReg (`ADDR, 8'h6A);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  SendReStart;
  HS_Mode = 1;
  MaTxData (8'h6B, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h4C);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h4C, 1);       // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // Clear interrupt and send ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START
  WriteReg (`DATA, 8'hD4);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  SlTxData (8'hFF, 0);          // ACK expected from slave testbench
  #(`CYC * 24 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'hD4, 0);       
  WriteReg (`CNTL, 8'hD4);	// Send Stop
  WaitStop;
  CheckStop;


  test_name = "test109";
  // Test 109 Testing HS clock divider N=1, M=0
  $display("%10.0f",Vector," Test 109 Testing HS clock divider N=1, M=0");

  HS_div = 2;
  WriteReg (`CCRH, 8'h01);

  WriteReg (`ADDR, 8'hE4);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  SendReStart;
  HS_Mode = 1;
  MaTxData (8'hE5, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h2B);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h2B, 1);       // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // Clear interrupt and send ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START
  WriteReg (`DATA, 8'h34);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  SlTxData (8'hFF, 0);          // ACK required/expected
  #(`CYC * 21 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'h34, 0);       

  WriteReg (`DATA, 8'hF0);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'hF0, 0);       

  WriteReg (`DATA, 8'h0F);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 1);          // Slave responds with not ACK
  WaitInt;
  CheckReg (`STATE, 8'h30);
  CheckRxData (8'h0F, 1);

  WriteReg (`CNTL, 8'hD4);	// Send Stop
  WaitStop;
  CheckStop;


  test_name = "test110";
  // Test 110 Testing HS clock divider N=2, M=0
  $display("%10.0f",Vector," Test 110 Testing HS clock divider N=2, M=0");
  HS_div = 4;
  WriteReg (`CCRH, 8'h02);

  WriteReg (`ADDR, 8'h4C);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  SendReStart;
  HS_Mode = 1;
  MaTxData (8'h4D, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h8C);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h8C, 1);       // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // Clear interrupt and send ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START
  WriteReg (`DATA, 8'h34);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  SlTxData (8'hFF, 0);          // ACK required/expected
  #(`CYC * 32 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'h34, 0);       

  WriteReg (`DATA, 8'hCC);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'hCC, 0);       

  WriteReg (`DATA, 8'h33);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 1);          // Slave responds with not ACK
  WaitInt;
  CheckReg (`STATE, 8'h30);
  CheckRxData (8'h33, 1);

  WriteReg (`CNTL, 8'hD4);	// Send Stop
  WaitStop;
  CheckStop;


  test_name = "tes111";
  // Test 111 Testing HS clock divider N=3-7, M=0
  $display("%10.0f",Vector," Test 111 Testing HS clock divider N=7, M=0");
  HS_div = 128;
  WriteReg (`CCRH, 8'h07);

  WriteReg (`ADDR, 8'h4C);
  SendStart;                    // Test bench (master) starts transfer
  MaTxData (8'h08, 1);          // Special reserved address 08-0F
  WaitIdle;
  CheckRxData (8'h08, 1);

  SendReStart;
  HS_Mode = 1;
  MaTxData (8'h4D, 1);		// Send address+R. ACK expected
  WaitInt;
  CheckReg (`STATE, 8'hA8);
  WriteReg (`DATA, 8'h8C);	// Load data
  WriteReg (`CNTL, 8'hC4);	// Clear interrupt
  MaTxData (8'hFF, 1);
  WaitInt;
  CheckReg (`STATE, 8'hC0);     // Last byte tx'd and not ACK returned
  CheckRxData (8'h8C, 1);       // Respond with not ACK (i.e. ready for STOP)
  WriteReg (`CNTL, 8'hC0);      // Clear interrupt
  SendStop;
  WaitInt;
  HS_Mode = 0;
  CheckReg (`STATE, 8'hA0);     // STOP received

  // Do a Master Write to the slave testbench

  WriteReg (`CNTL, 8'hE4);      // mi2cv2 sends START
  WaitInt;
  CheckStart;
  CheckReg (`STATE, 8'h08);     // START transmitted
  
  WriteReg (`DATA, 8'h0A);      // Reserved 8-bit master address
  WriteReg (`CNTL, 8'hC4);	// Send address+W and enable ACK
  WaitInt;

  WriteReg (`CNTL, 8'hE4);      // Clear interrupt and send ReSTART
  WaitInt;
  CheckStart;
  HS_Mode = 1;
  CheckReg (`STATE, 8'h10);     // Repeated START
  WriteReg (`DATA, 8'hB2);
  WriteReg (`CNTL, 8'hC4);	// Send address+W
  SlTxData (8'hFF, 0);          // ACK required/expected
  #(`CYC * 21 * 8)
  CheckNoIntr;
  WaitInt;
  CheckReg (`STATE, 8'h18);
  CheckRxData (8'hB2, 0);       

  WriteReg (`DATA, 8'h12);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h12, 0);       

  $display("%10.0f",Vector,"          Testing HS clock divider N=6");
  HS_div = 64;
  WriteReg (`CCRH, 8'h06);	// Set N=6
  WriteReg (`DATA, 8'h88);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h88, 0);       

  $display("%10.0f",Vector,"          Testing HS clock divider N=5");
  HS_div = 32;
  WriteReg (`CCRH, 8'h05);	// Set N=5
  WriteReg (`DATA, 8'hFF);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'hFF, 0);       

  $display("%10.0f",Vector,"          Testing HS clock divider N=4");
  HS_div = 16;
  WriteReg (`CCRH, 8'h04);	// Set N=4
  WriteReg (`DATA, 8'h69);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 0);          // Slave responds with ACK
  WaitInt;
  CheckReg (`STATE, 8'h28);
  CheckRxData (8'h69, 0);       

  $display("%10.0f",Vector,"          Testing HS clock divider N=3");
  HS_div = 8;
  WriteReg (`CCRH, 8'h03);	// Set N=3
  WriteReg (`DATA, 8'h96);
  WriteReg (`CNTL, 8'hC4);	// Send data
  SlTxData (8'hFF, 1);          // Slave responds with not ACK
  WaitInt;
  CheckReg (`STATE, 8'h30);
  CheckRxData (8'h96, 1);

  WriteReg (`CNTL, 8'hD4);	// Send Stop
  WaitStop;
  CheckStop;


`endif


  // end of test bench
  #`CYC;
  $display("%10.0f",Vector,"");
  if (Errors == 1)
    $display("%10.0f",Vector," Test completed with 1 error");
  else if (Errors)
    $display("%10.0f",Vector," Test completed with %d errors", Errors);
  else  
    $display("%10.0f",Vector," Test completed without errors");
  $display("");

  $fclose(OpFile);
  $finish;
end

endmodule

