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

module tb_top_I2C;

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
  #`CYC;
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
  else 
  begin
    $display ("%10.0f",Vector,"right"  );
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




  // Main
initial
begin
  OpFile = $fopen("mi2cv2.lis");


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
  // CheckReg (`ADDR, 8'h00);
  // CheckReg (`DATA, 8'h00);
  // CheckReg (`CNTL, 8'h00);
  // CheckReg (`STATE, 8'hF8); 
  // CheckReg (`XADDR, 8'h00);
  // CheckReg (`CCRH, 8'h00);
  // CheckReg (`Add6, 8'h00);
  // CheckReg (`SRST, 8'h00);
 
  CheckBusIdle;



 // Test 83 Read ADDR, XADDR and CNTR registers
  $display("%10.0f",Vector," Test 83 Read ADDR, XADDR and CNTR registers");
  test_name = "83";

//   WriteReg (`ADDR, 8'h01);
  // WriteVAL (`ADDR, 8'h00);
  // CheckReg (`ADDR, 8'hFF);
  // WriteReg (`ADDR, 8'h00);
  // WriteVAL (`ADDR, 8'hFF);
  // CheckReg (`ADDR, 8'h00);

  WriteReg (`DATA, 8'hFF);
  CheckReg (`DATA, 8'hFF);
 WriteReg (`DATA, 8'h01);
 CheckReg (`DATA, 8'h01);
 WriteReg (`DATA, 8'h02);
 CheckReg (`DATA, 8'h02);

  // WriteReg (`XADDR, 8'hFF);
  // WriteVAL (`XADDR, 8'h00);
  // CheckReg (`XADDR, 8'hFF);
  // WriteReg (`XADDR, 8'h00);
  // WriteVAL (`XADDR, 8'hFF);
  // CheckReg (`XADDR, 8'h00);

  // WriteReg (`CNTL, 8'h00);
  // WriteVAL (`CNTL, 8'hFF);
  // CheckReg (`CNTL, 8'h00);
  // WriteReg (`CNTL, 8'hC4);
  // WriteVAL (`CNTL, 8'h00);
  // CheckReg (`CNTL, 8'hC4);


//   // Test 2 Intr condition 08, START transmitted
//   $display("%10.0f",Vector," Test  2 Intr condition 08, START transmitted");
//   test_name = "2";

// `ifdef divider_en
//   FS_div = 1;
//   WriteReg (`CCRFS, 8'h00);   //Set FS divisor 
// `endif

//   WriteReg (`CNTL, 8'hE0);
//   WriteReg (`CNTL, 8'hC0);    //Test Start bit not cleared
//   CheckReg (`CNTL, 8'hE0);
//   WaitInt;
//   CheckStart;
//   CheckIntr;
//   CheckReg (`STATE, 8'h08);
//   CheckReg (`CNTL, 8'hC8);
//   WriteReg (`CNTL, 8'hC8);     //Test Interrupt not cleared
//   CheckReg (`CNTL, 8'hC8);

//   // Test 5 Send STOP
//   $display("%10.0f",Vector," Test  5 Send STOP");
//   test_name = "5";

//   WriteReg (`CNTL, 8'hD0);
//   WriteReg (`CNTL, 8'hC0);     // Test Stop bit not cleared
//   CheckReg (`CNTL, 8'hD0);
//   CheckNoIntr;
//   CheckReg (`STATE, 8'hF8);
//   WaitStop;
//   CheckStop;



//     // Test 64 Incorrect address received
//   $display("%10.0f",Vector," Test 64 10-bit address, address wrong");
//   test_name = "64";

//   WriteReg (`ADDR, 8'hF0);      // Set 10-bit addressing, GC disabled
//   WriteReg (`XADDR, 8'h20);     // Set address 020
//   SendStart;
//   MaTxData (8'h20,1);           // Send invalid address, NACK expected
//   WaitIdle;
//   CheckNoIntr;
//   CheckReg (`STATE, 8'hF8);
//   SendStop;






  //   // Test 81 Checking received data
  // $display("%10.0f",Vector," Test 81 Checking received data");
  // test_name = "81";

  // WriteReg (`ADDR, 8'h34);      // Set address 1A, GC disabled
  // SendStart;
  // MaTxData (8'h34,1);           // Send address+W, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h60);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h00,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h00);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'hFF,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'hFF);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h01,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h01);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h02,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h02);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h04,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h04);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h08,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h08);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h10,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h10);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h20,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h20);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h40,1);           // Send data, NACK
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h40);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // MaTxData (8'h80,1);           // Send data, ACK expected
  // WaitInt;
  // CheckIntr;
  // CheckReg (`STATE, 8'h80);
  // CheckReg (`DATA, 8'h80);
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt
  // SendStop;
  // WaitInt;
  // WriteReg (`CNTL, 8'hC4);      // Clear interrupt





end

endmodule