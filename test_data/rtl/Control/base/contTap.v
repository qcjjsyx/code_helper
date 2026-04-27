//-----------------------------------------------
//	module name: Sender
//	author: Anping HE (heap@lzu.edu.cn)
//	modify author: 
//		Tong FU (fut21@lzu.edu.cn)
//		Xiabao WAN (wanbx21@lzu.edu.cn)
//		Mingshu CHEN (chenmsh18@lzu.edu.cn)	
//	version: 1st version (2021-11-13)
//	Last Modified: 2021-11-16
//	description: 
//		continue tap 
//		req = !req when trig is valid
//		tech: xilinx fpga
//-----------------------------------------------



`timescale 1ns / 1ps

module contTap(trig, req, rst);

input trig, rst;
output req;

wire reqNeg;

INVM0HM inv6 ( .A(req), .Z(reqNeg) );
DFQRM2HM ffState ( .D(reqNeg), .CK(trig), .RB(rst), .Q(req) );
endmodule
