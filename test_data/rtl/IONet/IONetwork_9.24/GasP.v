// type:  
`timescale 1ns/10ps
`celldefine

module GasP (fire, pred, succ, rst);

inout pred, succ;
input rst;
output fire;
wire w_fire, fire_1, fire_2, fire_3, fire_4;

GasP_enhanceSW_v231031  gasp (.fire(w_fire), .pred(pred), .succ(succ));

CKAN2M2HM and1 (.A(rst), .B(w_fire), .Z(fire_1));
BUFM2HM buf1 (.A(fire_1), .Z(fire_2));
BUFM2HM buf2 (.A(fire_2), .Z(fire_3));
BUFM2HM buf3 (.A(fire_3), .Z(fire_4));
BUFM2HM buf4 (.A(fire_4), .Z(fire));

endmodule
