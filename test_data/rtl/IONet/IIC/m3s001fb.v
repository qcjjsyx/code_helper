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
// Clock Enable Mux
// Copyright Mentor Graphics Corporation and Licensors 2001.

// Revision history
// $Log: m3s001fb.v,v $
// Revision 1.6  2002/02/25
// renamed divider_en.v to mi2cv2_cfg.v
//
// Revision 1.5  2002/02/21
// tidy up some lint warnings
//
// Revision 1.4  2002/02/20
// rename MaCLK_EN to CLK_EN to make top-level tidier
//
// Revision 1.3  2002/02/07
// ready for review
//
// Revision 1.2  2001/09/05
// 23 March 2000 - Initial RTL version
//
//

`include "mi2cv2_cfg.v"

// Version of m3s001fb when divider is built-in
`ifdef divider_en
 
  module m3s001fb (CLOCK, RESETN, CCRFS, CCRH, MASTER, CKISO, CLK_EN);
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

    input       CLOCK, RESETN, MASTER, CKISO;
    input [6:0] CCRFS, CCRH;
    output      CLK_EN;

    reg         CLK_EN, CLK_EN_int, MaCLK_EN;
    reg         FSEN, HSEN, Spd_change, CKISO_reg;
    reg   [3:0] Count2;
    reg   [6:0] Count1;

    wire  [2:0] Count1_DIV;


    // Stage 1 counter
    always @(posedge CLOCK or negedge RESETN)
      if (!RESETN)
      begin
        Count1 <= 0;
        Spd_change <= 0;
        CKISO_reg <= 0;
       end
      else
      begin
        CKISO_reg <= CKISO;
        if (Spd_change)
        begin
          Count1 <= 0;
          Spd_change <= 0;
        end
        else
        begin
          Count1 <= Count1 + 1;
          Spd_change <= CKISO_reg ^ CKISO;
        end
      end
    assign Count1_DIV[2:0] = CKISO ? CCRH[2:0] : CCRFS[2:0];

    // Stage 1 output control
    always @(Count1 or Count1_DIV)
    begin
      case (Count1_DIV[2:0])
        3'o0: CLK_EN_int = 1;
        3'o1: CLK_EN_int = Count1[0];
        3'o2: CLK_EN_int = Count1[1] & Count1[0];
        3'o3: CLK_EN_int = Count1[2] & Count1[1] & Count1[0];
        3'o4: CLK_EN_int = Count1[3] & Count1[2] & Count1[1] & Count1[0];
        3'o5: CLK_EN_int = Count1[4] & Count1[3] & Count1[2] & Count1[1] &
                       Count1[0];
        3'o6: CLK_EN_int = Count1[5] & Count1[4] & Count1[3] & Count1[2] &
                       Count1[1] & Count1[0];
        3'o7: CLK_EN_int = Count1[6] & Count1[5] & Count1[4] & Count1[3] &
                       Count1[2] & Count1[1] & Count1[0];
        default : CLK_EN_int = 1'bx;
      endcase
    end

    // Stage 2 counter
    always @(posedge CLOCK or negedge RESETN)
      if (!RESETN)
        Count2 <= 4'b0000;
      else if (Spd_change)
        Count2 <= 4'b0000;
      else 
        if (CLK_EN_int)
          if (CKISO & (Count2[3:0] == CCRH[6:3]))
            Count2 <= 4'b0000;
          else if (!CKISO & (Count2[3:0] == CCRFS[6:3]))
            Count2 <= 4'b0000;
          else
            Count2 <= Count2 + 1;

    // Stage 2 output control
    always @(CLK_EN_int or Count2)
      MaCLK_EN = CLK_EN_int & ~Count2[3] & ~Count2[2] & ~Count2[1] & ~Count2[0];

    // Selects which clock enable to use dependent on MASTER/SLAVE mode
    always @(MASTER or CLK_EN_int or MaCLK_EN)
    begin
      CLK_EN = (MASTER & MaCLK_EN) | (~MASTER & CLK_EN_int); 
    end

  endmodule


// Version of m3s001fb when divider is external
`else

  module m3s001fb (HSEN, FSEN, CKISO, CLK_EN);
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

     input    FSEN, HSEN, CKISO;
     output   CLK_EN;
     reg      CLK_EN;

  always @(FSEN or HSEN or CKISO)
  begin
    CLK_EN = (CKISO & HSEN) | (!CKISO & FSEN);
  end
 
  endmodule

`endif
