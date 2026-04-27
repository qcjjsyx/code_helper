`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/24 18:00:13
// Design Name: 
// Module Name: eventSource
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


module eventSource(rst, switch, fire);

input rst, switch;
output fire;

wire fire1_1, fire1_2, fire1_3, fire1_4, fire1_5, fire1_6, req, reqNeg, nswitch;


INVM0HM inv0 ( .A(switch), .Z(nswitch) );
//contTap
INVM0HM inv6 ( .A(req), .Z(reqNeg) );
DFQRM2HM ffState ( .D(reqNeg), .CK(nswitch), .RB(rst), .Q(req) );
//
INVM4HM inv1 ( .A(req), .Z(fire1_1) );

DEL4M1HM delay0 ( .A(fire1_1), .Z(fire1_2) );
DEL4M1HM delay1 ( .A(fire1_2), .Z(fire1_3) );
DEL4M1HM delay2 ( .A(fire1_3), .Z(fire1_4) );
DEL4M1HM delay3 ( .A(fire1_4), .Z(fire1_5) );

AN2M0HM and0 ( .A(fire1_5), .B(nswitch), .Z(fire) );

endmodule