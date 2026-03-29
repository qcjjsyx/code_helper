//-----------------------------------------------
//  module name: pmtClick
//  author: Fu Tong, Baoxia WAN 
//      modify author: Kang Li Zhao
//  version: 1st version (2021-11-20)
//  description: 
//      standard click with permit 
//      while permit is 1 , pmtClick is the same with click,
//      while permit is 0 , pmtClick is paused
//-----------------------------------------------
`timescale 1ns / 1ps

module pmtRelay(inR, inA, outR, outA, pmt, fire, rstn);

input inR, outA, rstn,pmt;

output inA, outR, fire;

wire inAR, outAR, notR;
wire Rtemp0, Rtemp1, Rtemp2, Rtemp3, Rtemp4,Rtemp5,Rtemp6;
wire fire0;
XOR2V2_140P9T35R neqIn ( .A1(inR), .A2(inA), .Z(inAR) );

XNOR2V2_140P9T35R eqOut ( .A1(outA), .A2(inA), .ZN(outAR) );

CLKAND2V3_140P9T35R andFire ( .A1(inAR), .A2(outAR), .Z(fire0) );
CLKAND2V3_140P9T35R fire_pmt ( .A1(fire0), .A2(pmt), .Z(fire) );
INV2_140P9T35R invTmp ( .I(inA), .ZN(notR) );

DRNQV2_140P9T35R ffState ( .D(notR), .CK(fire), .RDN(rstn), .Q(Rtemp0) );

DEL1V4_140P9T35R delay7 ( .I(Rtemp0), .Z(inA) );
BUFV2_140P9T35R U1 ( .I(inA), .Z(outR) );
endmodule