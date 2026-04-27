`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/21 18:00:55
// Design Name: 
// Module Name: click
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: click used in merge
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module relay4merge(inR, inA, outR, outA, fire, rst); 

input inR, outA, rst;

output inA, outR, fire;

wire inAR, outAR, notR;
//, rstNeg;
//wire Rtemp0, Rtemp1, Rtemp2, Rtemp3, Rtemp4;

XOR2M8HM neqIn ( .A(inR), .B(inA), .Z(inAR) );
XNR2M4HM eqOut ( .A(outA), .B(inA), .Z(outAR) );
AN2M16HM andFire ( .A(inAR), .B(outAR), .Z(fire) );
INVM48HM invTmp ( .A(inA), .Z(notR) );
DFQRM8HM ffState ( .D(notR), .CK(fire), .RB(rst), .Q(inA) );

//DEL1M4HM delay7 ( .A(Rtemp0), .Z(inA) );
BUFM48HM U1 ( .A(inA), .Z(outR) );

endmodule

