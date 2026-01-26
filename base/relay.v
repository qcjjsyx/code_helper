`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/27 09:08:55
// Design Name: 
// Module Name: click
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module relay(inR, inA, outR, outA, fire, rstn); 

input inR, outA, rstn;

output inA, outR, fire;

wire inAR, outAR, notR, rstNeg;
wire Rtemp0, Rtemp1, Rtemp2, Rtemp3, Rtemp4;
wire Rtemp5;

XOR2V2_140P9T35R neqIn_donttouch ( .A1(inR), .A2(inA), .Z(inAR));
XNOR2V2_140P9T35R eqOut_donttouch ( .A1(outA), .A2(inA), .ZN(outAR));
CLKAND2V3_140P9T35R andFire_donttouch ( .A1(inAR), .A2(outAR), .Z(fire));
INV2_140P9T35R invTmp_donttouch ( .I(inA), .ZN(notR));
DRNQV2_140P9T35R ffState_donttouch ( .D(notR), .CK(fire), .RDN(rstn), .Q(Rtemp0));

DEL1V4_140P9T35R delay7_donttouch ( .I(Rtemp0), .Z(Rtemp5));
DEL1V4_140P9T35R delay8_donttouch ( .I(Rtemp5), .Z(inA));
BUFV2_140P9T35R U1_donttouch ( .I(inA), .Z(outR));

endmodule