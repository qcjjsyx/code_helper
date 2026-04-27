//-----------------------------------------------
//	module name: arbMsg
//	author: Anping HE (heap@lzu.edu.cn)
//  modifier: Fu Tong , Baoxia Wan , Mingshu Chen ,Kang Li Zhao
//	version: 4st version (2021-11-20)
//	description: 
//		arbitration the message and then send out
//		e.g., priority= {west, east, north, south, local}
//-----------------------------------------------

`timescale 1ns / 1ps

module arbMsg(
	rst,
	i_driveWest,	o_freeWest,		i_westMsg_51,
	i_driveEast,	o_freeEast,		i_eastMsg_51,
	i_driveNorth,	o_freeNorth,	i_northMsg_51,
	i_driveSouth,	o_freeSouth,	i_southMsg_51,
	i_driveLocal,	o_freeLocal,	i_localMsg_51,
	o_driveNext,	i_freeNext,		o_msg_51

);

input 			rst;
input			i_driveWest;
input			i_driveEast;
input			i_driveNorth;
input			i_driveSouth;
input			i_driveLocal;
input			i_freeNext;
(*dont_touch = "yes"*)input	[50:0] 	i_westMsg_51;
(*dont_touch = "yes"*)input	[50:0] 	i_eastMsg_51;
(*dont_touch = "yes"*)input	[50:0] 	i_northMsg_51;
(*dont_touch = "yes"*)input	[50:0] 	i_southMsg_51;
(*dont_touch = "yes"*)input	[50:0] 	i_localMsg_51;

output			o_freeWest;
output			o_freeEast;
output			o_freeNorth;
output			o_freeSouth;
output			o_freeLocal;
output			o_driveNext;
(*dont_touch = "yes"*)output	[50:0]	o_msg_51;	


cArbMerge5_51b arbMerge (
	.i_drive_5		({i_driveLocal,i_driveSouth,i_driveNorth,i_driveEast,i_driveWest}),
	.i_data0		(i_westMsg_51		),
	.i_data1		(i_eastMsg_51		),
	.i_data2		(i_northMsg_51		),
	.i_data3		(i_southMsg_51		),
	.i_data4		(i_localMsg_51		),
	.i_freeNext		(i_freeNext			),
	.rst			(rst				),
	.o_free_5		({o_freeLocal,o_freeSouth,o_freeNorth,o_freeEast,o_freeWest}),
	.o_driveNext	(o_driveNext		),
	.o_data		(o_msg_51			)
);

endmodule
