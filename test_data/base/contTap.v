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

module contTap(trig, req, rstn);

input trig, rstn;
output req;
wire reqNeg;

INV2_140P9T35R inv6_donttouch ( .I(req), .ZN(reqNeg) );
DRNQV2_140P9T35R ffState_donttouch ( .D(reqNeg), .CK(trig), .RDN(rstn), .Q(req) );
endmodule