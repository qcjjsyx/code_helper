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
// State Machine
// Copyright Mentor Graphics Corporation and Licensors 2001.

// Revision history
// $Log: m3s004fb.v,v $
// Revision 1.4  2002/02/20
// tidied comments up
//
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//

//
// States
//
// The states are used for both slave and master modes of operation
//


module m3s004fb (CLOCK, CLK_EN, RESETN, IRST, WrData, WDATA, ENAB, GCENAB, STA, STP, IFLG, AAK,
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
                 StartDet, StopDet, SCL_PE, SCL_NE, IDLE, RxDa,
                 SLAA, XSLA, START, RSTART, STOP, MASTER,
                 SetIFLG, Status, Data, TxDa, LTXD, ENDRV, CKISO, DAISO, DAGND, SFSDA);

  input         CLOCK, CLK_EN, RESETN, IRST;
  input         ENAB, GCENAB, STA, STP, IFLG, AAK;
  input         WrData;
  input [7:0]   WDATA;
  input         StartDet, StopDet, SCL_PE, SCL_NE, IDLE;
  input         RxDa;
  input [6:0]   SLAA;
  input [7:0]   XSLA;
  input         SFSDA;

  output        START, RSTART, STOP;
  output        MASTER;
  output        SetIFLG;
  output [4:0]  Status;
  output [7:0]  Data;
  output        TxDa;
  output        LTXD;
  output        ENDRV;
  output        CKISO, DAISO, DAGND;

  reg        S_Idle, S_Start, S_Addr, S_Ad10, S_Data, S_RStart, S_Stop;

  reg        Stop_Done, Start_Done, Addr7_OK, Addr7_NG, Addr10_OK, Addr10_NG;
  reg        MALData;

  reg        MASTER, RSTDEL;

  reg [2:0]  DCnt;
  reg        DAck;
  reg        SSTP;

  reg [7:0]  Data;  //I2C Data
  reg        RNW;   //I2C Read/Write control
  reg        ACK;   //I2C ACK

  reg        SL7VAL, SL10VAL, SL10A, SL10P1, GCAVAL;
  reg        SLXVAL;        


  reg        WrDa7, WrDa6, WrDa5, WrDa4;
  reg        WrDa3, WrDa2, WrDa1, WrDa0;
  reg        WrAck;
  reg        WrAdd, WrEAdd;

  reg        ARBERR, ARBESET;
  reg        MASARB;

  reg        TxDa;
  reg        LTXD;

  reg        START, RSTART, STOP, ABORT, BUSERR;
  reg        ARMBE, MBERR;

  reg        SetIFLG;
  reg [7:0]  PStatus;
  reg [4:0]  Status;
  reg        CMST, CMRST, CMAWA, CMAWN, CMDTA, CMDTN, CMARL;
  reg        CMARA, CMARN, CMDRA, CMDRN;
  reg        CSAWA, CSLWA, CSGCA, CSLCA, CSDRA, CSDRN;
  reg        CSDRGA, CSDRGN, CSSTP, CSARA, CSLRN, CSDTA, CSDTN;
  reg        CSUTA, CSUTN, CM10A, CM10N;

  reg [2:0]  STISO;
  reg        ISOSTP;
  reg        DAISO, DAGND, CKISO;

  reg        ENDRV;

//
// Determines various I2C phases for both master and slave mode operation.
// One hot encoded
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) begin
    S_Idle   <= 1'b1;
    S_Start  <= 1'b0;
    S_Addr   <= 1'b0;
    S_Ad10   <= 1'b0;
    S_Data   <= 1'b0;
    S_RStart <= 1'b0;
    S_Stop   <= 1'b0;
  end
  else if (IRST | BUSERR | ABORT) begin
    S_Idle   <= 1'b1;
    S_Start  <= 1'b0;
    S_Addr   <= 1'b0;
    S_Ad10   <= 1'b0;
    S_Data   <= 1'b0;
    S_RStart <= 1'b0;
    S_Stop   <= 1'b0;
  end
  else begin
    S_Idle   <= (S_Stop & Stop_Done) | (S_Addr & Addr7_NG) | (S_Ad10 & Addr10_NG) | (S_Data & MALData) | (S_Idle & !StartDet);
    S_Start  <= (S_Idle &  StartDet) | (S_Start & !Start_Done);
    S_Addr   <= (S_Start &  Start_Done) | (S_RStart & Start_Done) | (S_Addr & !Addr7_OK & !Addr7_NG & !StartDet & !StopDet);
    S_Ad10   <= (S_Addr & Addr7_OK &  SL10P1) | (S_Ad10 & !Addr10_OK & !Addr10_NG & !StartDet & !StopDet);
    S_Data   <= (S_Addr & Addr7_OK & !SL10P1) | (S_Ad10 & Addr10_OK) | (S_Data & !StartDet & !StopDet & !MALData);
    S_RStart <= (!S_Idle & StartDet) | (S_RStart & !Start_Done);
    S_Stop   <= (!S_Idle & StopDet)  | (S_Stop & !Stop_Done);                  
  end
end

//
// Control State machines
//
always @(MASTER or SL7VAL or SL10VAL or GCAVAL
      or SCL_NE or SSTP or ARBERR)
begin
  Start_Done = ( MASTER & SCL_NE)
             | (!MASTER & SCL_NE);        

  Addr7_OK   = (!MASTER &  SL7VAL & SSTP & SCL_NE)
             | (!MASTER &  GCAVAL & SSTP & SCL_NE)
             | ( MASTER & SSTP & SCL_NE);

  Addr7_NG   = (!MASTER & !SL7VAL & !GCAVAL & SSTP & SCL_NE);

  Addr10_OK  = (!MASTER &  SL10VAL & SSTP & SCL_NE)
             | ( MASTER & SSTP & SCL_NE);

  Addr10_NG  = (!MASTER & !SL10VAL & SSTP & SCL_NE);

  Stop_Done  = 1'b1;  

  // Master Arbitration Lost in Data
  MALData    = ( ARBERR & SSTP & SCL_NE);
end

//
// Misc Status
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) begin
    MASTER <= 0;
    RSTDEL <= 0;
    ARMBE <= 0;
    MBERR <= 0;
    ENDRV <= 0;
  end

  else
  begin
  // Master or Slave
    if (IRST) MASTER <= 0;
    else    MASTER <= (START & CLK_EN) | (MASTER & !S_Stop & !ARBESET & !MBERR);
    
  // Restart delay
    if (IRST) RSTDEL <= 0;
    else RSTDEL <= STOP | START | (RSTDEL & (STA | STP));
    
  // ARm Master Buss Error
    if (IRST) ARMBE <= 0;
    else ARMBE <= (MASTER & SCL_NE) | (ARMBE & !START & !RSTART & !STOP & !ARBESET & !MBERR);
    
  // Master Buss ERRor
    if (IRST) MBERR <= 0;
    else MBERR <= BUSERR;
    
  // Enable active pull-up for SCL during high speed data transfer
  // Only changes when SCL "0".
    if (IRST) ENDRV <= 0;
    else ENDRV <= (MASTER & CKISO & WrDa6 & SCL_NE) | (ENDRV & !(SSTP & SCL_NE));
  end
end

//
// Decode Start (STA) Stop (STP) conditions
//
always @(MASTER or IDLE or STP or STA or IFLG or 
         S_Idle or RSTDEL or
         StartDet or StopDet or ARMBE)
begin
  START  = !MASTER & STA & !STP & !IFLG & IDLE & S_Idle;
  RSTART =  MASTER & STA & !STP & !IFLG & !RSTDEL;
  STOP   =  MASTER &        STP & !IFLG;
  ABORT  = !MASTER &        STP & !IFLG;
  BUSERR =  ARMBE & (StartDet | StopDet);
end

always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) begin
    DAck <= 1'b0;
    SSTP <= 1'b0;
    DCnt[2:0] <= 3'h0;
  end

  else begin
  // Count incoming Address/Data bits
  //
    if ((!S_Addr & !S_Ad10 & !S_Data) | DAck) DCnt[2:0] <= 3'h0;
    else DCnt[2:0] <= DCnt[2:0] + {2'b00,SCL_PE};

  // Detect incoming ACK
  //
    if (IRST) DAck <= 1'b0;
    else DAck <= ((DCnt[2:0] == 3'h7) & SCL_PE) | (DAck & !SCL_PE);

  // Update status
  //
    if (IRST) SSTP <= 1'b0;
    else SSTP <= (DAck & SCL_PE) | (SSTP & !SCL_PE);
  end
end

//
// Data register
// Loaded by either TX or RX on the I2C bus and by I/F write
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) begin
    Data[7:0] <= 8'h00;
    RNW <= 1'b0;
    ACK <= 1'b0;
  end
  else if (IRST) begin
    Data[7:0] <= 8'h00;
    RNW <= 1'b0;
    ACK <= 1'b0;
  end
  else begin
    if (WrData) Data[7:0] <= WDATA[7:0];  //Write via I/F
    else begin
      if (SCL_PE) begin
        if (WrDa7) Data[7] <= RxDa;
        else Data[7] <= Data[7];

        if (WrDa6) Data[6] <= RxDa;
        else Data[6] <= Data[6];

        if (WrDa5) Data[5] <= RxDa;
        else Data[5] <= Data[5];

        if (WrDa4) Data[4] <= RxDa;
        else Data[4] <= Data[4];

        if (WrDa3) Data[3] <= RxDa;
        else Data[3] <= Data[3];

        if (WrDa2) Data[2] <= RxDa;
        else Data[2] <= Data[2];

        if (WrDa1) Data[1] <= RxDa;
        else Data[1] <= Data[1];

        if (WrDa0) Data[0] <= RxDa;
        else Data[0] <= Data[0];
      end
      else Data[7:0] <= Data[7:0];
    end

    if (SCL_PE & WrAck) ACK <= !RxDa;
    else ACK <= ACK;

    if (WrAdd) RNW <= Data[0];  //Copy Read Not Write for use later
    else RNW <= RNW;
  end
end

//
// Write decodes for Address or Data
//
always @(DCnt or DAck)
begin
  WrDa7 = (DCnt[2:0] == 3'h0) & !DAck;
  WrDa6 = (DCnt[2:0] == 3'h1);
  WrDa5 = (DCnt[2:0] == 3'h2);
  WrDa4 = (DCnt[2:0] == 3'h3);
  WrDa3 = (DCnt[2:0] == 3'h4);
  WrDa2 = (DCnt[2:0] == 3'h5);
  WrDa1 = (DCnt[2:0] == 3'h6);
  WrDa0 = (DCnt[2:0] == 3'h7);
  WrAck =                        DAck;
end

//
// Transmit Mux
//
always @(WrDa7 or WrDa6 or WrDa5 or WrDa4 or WrDa3 or 
         WrDa2 or WrDa1 or WrDa0 or WrAck or Data or
         AAK or RNW or S_Addr or S_Ad10 or S_Data or
         SL7VAL or SL10VAL or GCAVAL or MASTER or LTXD)
begin
 TxDa = (WrDa7 & Data[7])
      | (WrDa6 & Data[6])
      | (WrDa5 & Data[5])
      | (WrDa4 & Data[4])
      | (WrDa3 & Data[3])
      | (WrDa2 & Data[2])
      | (WrDa1 & Data[1])
      | (WrDa0 & Data[0])
      | (WrAck & !AAK)
      | (LTXD)                                  // Disable if last data sent
      | !(( MASTER & S_Addr & !WrAck)           // Enable functions
        | ( MASTER & S_Ad10 & !WrAck)
        | (!MASTER & S_Addr &  WrAck & SL7VAL)
        | (!MASTER & S_Addr &  WrAck & GCAVAL)
        | (!MASTER & S_Ad10 &  WrAck & SL10VAL)
        | ( MASTER & S_Data & !WrAck & !RNW)
        | ( MASTER & S_Data &  WrAck &  RNW)
        | (!MASTER & S_Data & !WrAck &  RNW)
        | (!MASTER & S_Data &  WrAck & !RNW));
end

//
// Detect Last data sent and hold TxDa OFF
// This enables Master to perform Stop/start if slave has not cleared AAK
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) LTXD <= 1'b0;
  else if (IRST) LTXD <= 1'b0;
  else LTXD <= (!MASTER & RNW & S_Data & SSTP & SCL_NE) | (LTXD & S_Data & !WrData);
end 

//
// Detect Conflict / Arbitration loss
//
always @(MASTER or SCL_PE or S_Addr or S_Ad10 or S_Data or DAck or TxDa or RxDa or STA or STP or RNW)
begin
  ARBESET = (MASTER & SCL_PE & S_Addr & !DAck &        TxDa & !RxDa & !STA & !STP)
          | (MASTER & SCL_PE & S_Ad10 & !DAck &        TxDa & !RxDa & !STA & !STP)
          | (MASTER & SCL_PE & S_Data & !DAck & !RNW & TxDa & !RxDa & !STA & !STP)
          | (MASTER & SCL_PE & S_Data &  DAck &  RNW & TxDa & !RxDa & !STA & !STP);
end

always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) ARBERR <= 1'b0;                // Test for dominant during address
  else if (IRST) ARBERR <= 1'b0;              // Test for dominant during address
  else ARBERR <= ARBESET | (ARBERR & !IFLG);  // Hold until interrupt set
end

//
// Test Address both 7 and 10-bit
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) begin
    SL7VAL  <= 1'b0;
    SL10VAL <= 1'b0;
    GCAVAL  <= 1'b0;
  end
  else if (IRST | S_Idle) begin
    SL7VAL  <= 1'b0;
    SL10VAL <= 1'b0;
    GCAVAL  <= 1'b0;
  end
  else begin
  // Set if SLAA = Incoming address + extra check on Data[0] if first part if 10-bit address
  // if restart ignore Data[0] as it could be "Read" so only first part of 10-bit address presented
  //
    SL7VAL  <= ((Data[7:1] == SLAA[6:0]) & WrAdd & (!SL10A | !Data[0] | SL10VAL) & ENAB & AAK)
               | (SL7VAL & !WrAdd & !WrEAdd);           //Hold if not address updates

  // Set if part 2 of 10-bit address is good
  // Clear of 2 part 10-bit address presented but hold if "Read" 10-bit address presented
  //
    SL10VAL <= ((Data[7:0] == XSLA[7:0]) & WrEAdd & ENAB & AAK)
               | (SL10VAL & !(WrAdd & SL10P1) & !WrEAdd);

    GCAVAL  <= ((Data[7:0] == 8'h00) & WrAdd & ENAB & AAK & GCENAB)
               | (GCAVAL & !WrAdd);  //General Call Address
  end
end

//
// Address sampling control
//
always @(DAck or S_Addr or S_Ad10 or S_Idle or SCL_NE or Data)
begin
  WrAdd =  SCL_NE & DAck & S_Addr;
  WrEAdd = SCL_NE & DAck & S_Ad10;

  SL10A  =  (Data[7:3] == 5'b11110);
  SL10P1 = ((Data[7:3] == 5'b11110) & (Data[0] == 1'b0));   //Part 1 of 10-bit address
end

//
// Control isolation of Full speed / Standard speed I2C bus
//
// Johnson counter
//
always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) STISO <= 3'b000;
  else if (IRST) STISO <= 3'b000;
  else begin
    if (ISOSTP) STISO[2:0] <= {STISO[1:0],!STISO[2]};
    else STISO[2:0] <= STISO[2:0];
  end
end

always @(STISO or S_Addr or Data or SSTP or SCL_NE or SCL_PE or StopDet or CLK_EN or SFSDA)
begin
  ISOSTP = ((STISO[2:0] == 3'b000) & (Data[7:3] == 5'b00001) & S_Addr & SSTP & SCL_NE) //Start
         | ((STISO[2:0] == 3'b001) & CLK_EN)              // Allow one period
         | ((STISO[2:0] == 3'b011) & CLK_EN)              // before driving SDA low
         | ((STISO[2:0] == 3'b111) & SCL_PE)
         | ((STISO[2:0] == 3'b110) & StopDet)
         | ((STISO[2:0] == 3'b100) & SFSDA);              // Wait for Slow bus data to rise
//
// These are All clean Johnson count decodes 
//
  DAISO = STISO[2] |  STISO[0];         
  DAGND = STISO[2] &  STISO[1];
  CKISO = STISO[1] & !STISO[0];
end

//
// Set IFLG control
//
always @(SCL_NE or MASTER or ARBERR or MBERR or SL7VAL or SL10VAL or GCAVAL or SL10P1 or
         S_Start or S_Addr or S_Ad10 or S_Data or S_Stop or S_RStart or SSTP)
begin
  SetIFLG = (MASTER & SCL_NE & S_Start)
          | (MASTER & SCL_NE & S_RStart)
          | (MASTER & SCL_NE & S_Addr & SSTP)
          | (MASTER & SCL_NE & S_Ad10 & SSTP)
          | (MASTER & SCL_NE & S_Data & SSTP)
          | (ARBERR & SCL_NE & S_Addr & SSTP)
          | (ARBERR & SCL_NE & S_Ad10 & SSTP)
          | (ARBERR & SCL_NE & S_Data & SSTP)
          | (MBERR)
          | (!MASTER & SCL_NE & S_Addr & SSTP & SL7VAL & !SL10P1)
          | (!MASTER & SCL_NE & S_Addr & SSTP & GCAVAL)
          | (!MASTER & SCL_NE & S_Ad10 & SSTP & SL10VAL) 
          | (!MASTER & SCL_NE & S_Data & SSTP)
          | (!MASTER & SCL_NE & S_RStart)
          | (!MASTER & S_Stop);

end

//
// Combine Signals
//
always @(SL7VAL or SL10VAL or MASTER or ARBERR)
begin
  SLXVAL = (SL7VAL | SL10VAL);
  MASARB = (MASTER | ARBERR);
end

//
//Generate Status
//Note. Only one state must be decoded, so that Status is correctly encoded
//
always @(MASTER or S_Start or S_RStart or S_Addr or S_Ad10 or S_Data or S_Stop or
         RNW or ACK or AAK or SL7VAL or SL10VAL or SLXVAL or GCAVAL or ARBERR or MASARB)
begin
  CMST  = ( MASTER & S_Start);
  CMRST = ( MASTER & S_RStart);
  CMAWA = ( MASTER & S_Addr & !RNW &  ACK);
  CMAWN = ( MASTER & S_Addr & !RNW & !ACK);
  CMDTA = ( MASTER & S_Data & !RNW &  ACK);
  CMDTN = ( MASTER & S_Data & !RNW & !ACK);
  CMARL = ( ARBERR & S_Addr & !GCAVAL & !SL7VAL)
        | ( ARBERR & S_Ad10 & !SL10VAL)
        | ( ARBERR & S_Data);
  CMARA = ( MASTER & S_Addr &  RNW &  ACK);
  CMARN = ( MASTER & S_Addr &  RNW & !ACK);
  CMDRA = ( MASTER & S_Data &  RNW &  ACK); 
  CMDRN = ( MASTER & S_Data &  RNW & !ACK);
  CSAWA = (!MASARB & S_Addr &  SL7VAL & !RNW &  ACK)
        | (!MASARB & S_Ad10 & SL10VAL & !RNW &  ACK);
  CSLWA = ( ARBERR & S_Addr &  SL7VAL & !RNW &  ACK)
        | ( ARBERR & S_Ad10 & SL10VAL & !RNW &  ACK);
  CSGCA = (!MASARB & S_Addr &  GCAVAL &  ACK);
  CSLCA = ( ARBERR & S_Addr &  GCAVAL &  ACK);
  CSDRA = (!MASARB & S_Data &  SLXVAL & !RNW &  ACK);
  CSDRN = (!MASARB & S_Data &  SLXVAL & !RNW & !ACK);
  CSDRGA =(!MASARB & S_Data &  GCAVAL &  ACK);
  CSDRGN =(!MASARB & S_Data &  GCAVAL & !ACK);
  CSSTP = (!MASTER & (S_Stop | S_RStart));
  CSARA = (!MASARB & S_Addr &  SL7VAL &  RNW &  ACK)
        | (!MASARB & S_Ad10 & SL10VAL &  RNW &  ACK);
  CSLRN = ( ARBERR & S_Addr &  SL7VAL &  RNW &  ACK)
        | ( ARBERR & S_Ad10 & SL10VAL &  RNW &  ACK);
  CSDTA = (!MASARB & S_Data &  SLXVAL &  RNW &  ACK &  AAK);
  CSDTN = (!MASARB & S_Data &  SLXVAL &  RNW & !ACK &  AAK);
  CSUTA = (!MASARB & S_Data &  SLXVAL &  RNW &  ACK & !AAK);
  CSUTN = (!MASARB & S_Data &  SLXVAL &  RNW & !ACK & !AAK);

  CM10A = ( MASTER & S_Ad10 &  ACK);
  CM10N = ( MASTER & S_Ad10 & !ACK); 
end

always @(posedge CLOCK or negedge RESETN)
begin
  if (!RESETN) PStatus[7:0] <= 8'hF8; 
  else
    if (SetIFLG) begin
    PStatus[7:0] <= (8'h08 & {8{CMST}})
                | (8'h10 & {8{CMRST}})
                | (8'h18 & {8{CMAWA}})
                | (8'h20 & {8{CMAWN}})
                | (8'h28 & {8{CMDTA}})
                | (8'h30 & {8{CMDTN}})
                | (8'h38 & {8{CMARL}})
                | (8'h40 & {8{CMARA}})
                | (8'h48 & {8{CMARN}})
                | (8'h50 & {8{CMDRA}})
                | (8'h58 & {8{CMDRN}})
                | (8'h60 & {8{CSAWA}})
                | (8'h68 & {8{CSLWA}})
                | (8'h70 & {8{CSGCA}})
                | (8'h78 & {8{CSLCA}})
                | (8'h80 & {8{CSDRA}})
                | (8'h88 & {8{CSDRN}})
                | (8'h90 & {8{CSDRGA}})
                | (8'h98 & {8{CSDRGN}})
                | (8'hA0 & {8{CSSTP}})
                | (8'hA8 & {8{CSARA}})
                | (8'hB0 & {8{CSLRN}})
                | (8'hB8 & {8{CSDTA}})
                | (8'hC0 & {8{CSDTN}})
                | (8'hC8 & {8{CSUTA}})
                | (8'hD0 & {8{CSUTN}})
                | (8'hD8 & {8{1'b0}})    //Not used
                | (8'hE0 & {8{CM10A}})
                | (8'hE8 & {8{CM10N}})
                | (8'hF0 & {8{1'b0}});   //Not used

    end
    else PStatus[7:0] <= PStatus[7:0] | {{5{!IFLG}},3'b000};
end

//
// Disregard PStatus[2:0] as always zero
//
always @(PStatus)
begin
  Status[4:0] = PStatus[7:3];
end

endmodule
