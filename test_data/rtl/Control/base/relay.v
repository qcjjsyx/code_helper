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


module relay(inR, inA, outR, outA, fire, rst); 

input inR, outA, rst;

output inA, outR, fire;

wire inAR, outAR, notR, rstNeg;
wire Rtemp0, Rtemp1, Rtemp2, Rtemp3, Rtemp4;

XOR2M0HM neqIn ( .A(inR), .B(inA), .Z(inAR) );
XNR2M0HM eqOut ( .A(outA), .B(inA), .Z(outAR) );
AN2M0HM andFire ( .A(inAR), .B(outAR), .Z(fire) );
INVM0HM invTmp ( .A(inA), .Z(notR) );
DFQRM2HM ffState ( .D(notR), .CK(fire), .RB(rst), .Q(Rtemp0) );

DEL1M4HM delay7 ( .A(Rtemp0), .Z(inA) );
BUFM2HM U1 ( .A(inA), .Z(outR) );

endmodule
