//-----------------------------------------------
//	module name: delay1U
//	author: Fu Tong , Baoxia Wan , Mingshu Chen
//  modifier: 
//  	modifyer: Anping HE (heap@lzu.edu.cn)
//  		adopting FDPE explicitly
//	version: 2nd version (2021-11-17)
//	description: 
//		one unit delay
//      output ==> input (==>:one uint delay)
//-----------------------------------------------
`timescale 1ns / 1ps

module delay6U(inR, outR, rst);
input inR, rst;
output outR;

wire outR0,outR1,outR1Buf;

delay2U delay1(.inR(inR), .outR(outR0), .rst(rst));
delay2U delay2(.inR(outR0), .outR(outR1), .rst(rst));
// wire w_fire2_1,w_fire3_1,w_fire4_1,w_fire5_1;
// BUFM2HM buf0(.A(outR1), .Z(w_fire2_1));
// BUFM2HM buf1(.A(w_fire2_1), .Z(w_fire3_1));
// BUFM2HM buf2(.A(w_fire3_1), .Z(w_fire4_1));
// BUFM2HM buf3(.A(w_fire4_1), .Z(w_fire5_1));
// BUFM2HM buf4(.A(w_fire5_1), .Z(outR1Buf));
delay2U delay3(.inR(outR1), .outR(outR), .rst(rst));




//DEL4UHDV1 delay1 ( .I(inR), .Z(outR0) );
//DEL4UHDV1 delay2 ( .I(outR0), .Z(outR1) );
//DEL4UHDV1 delay3 ( .I(outR1), .Z(outR2) );
//DLYCLK8S8_X1B_A9TRULP_C40_W3 delay4 ( .A(outR2), .Y(outR3) );
//DLYCLK8S8_X1B_A9TRULP_C40_W3 delay5 ( .A(outR3), .Y(outR4) );
//DEL4UHDV1 delay6 ( .I(outR2), .Z(outR) );
// DEL1M4HM delay1 ( .A(inR), .Z(outR0) );
// DEL1M4HM delay2 ( .A(outR0), .Z(outR1) );
// DEL1M4HM delay3 ( .A(outR1), .Z(outR2) );
// DEL1M4HM delay4 ( .A(outR2), .Z(outR3) );
// DEL1M4HM delay5 ( .A(outR3), .Z(outR4) );
// DEL1M4HM delay6 ( .A(outR4), .Z(outR5) );
// DEL1M4HM delay7 ( .A(outR5), .Z(outR6) );
// DEL1M4HM delay8 ( .A(outR6), .Z(outR7) );
// DEL1M4HM delay9 ( .A(outR7), .Z(outR) );
endmodule
