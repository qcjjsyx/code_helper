`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/26 10:48:25
// Design Name: 
// Module Name: IONetwork
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


module IONetwork(
    input wire rst,

        // External connections for each node
    //(0,0)
    input i_driveLocal_00, i_freeLocal_00, 
    input [50:0] i_localInMsg_51_00,
    output o_driveLocal_00, o_freeLocal_00,
    output  [50:0] o_localMsg_51_00,
    input i_driveWest_00, i_freeWest_00, 
    input [50:0] i_westInMsg_51_00,
    output o_driveWest_00, o_freeWest_00, 
    output [50:0] o_westMsg_51_00,
    input i_driveSouth_00, i_freeSouth_00, 
    input [50:0] i_southInMsg_51_00,
    output o_driveSouth_00, o_freeSouth_00, 
	output [50:0] o_southMsg_51_00,

    //(1,0)
    input i_driveLocal_10, i_freeLocal_10, 
	input [50:0] i_localInMsg_51_10,
    output o_driveLocal_10, o_freeLocal_10, 
	output [50:0] o_localMsg_51_10,
    input i_driveSouth_10, i_freeSouth_10, 
	input [50:0] i_southInMsg_51_10,
    output o_driveSouth_10, o_freeSouth_10, 
	output [50:0] o_southMsg_51_10,
    input i_driveEast_10, i_freeEast_10, 
	input [50:0] i_eastInMsg_51_10,
    output o_driveEast_10, o_freeEast_10, 
	output [50:0] o_eastMsg_51_10,

    //(1,1)
    input i_driveLocal_11, i_freeLocal_11, 
	input [50:0] i_localInMsg_51_11,
    output o_driveLocal_11, o_freeLocal_11, 
	output [50:0] o_localMsg_51_11,
    input i_driveNorth_11, i_freeNorth_11, 
	input [50:0] i_northInMsg_51_11,
    output o_driveNorth_11, o_freeNorth_11, 
	output [50:0] o_northMsg_51_11,
    input i_driveEast_11, i_freeEast_11, 
	input [50:0] i_eastInMsg_51_11,
    output o_driveEast_11, o_freeEast_11, 
	output [50:0] o_eastMsg_51_11,
    
    //(0,1)
    input i_driveLocal_01, i_freeLocal_01, 
	input [50:0] i_localInMsg_51_01,
    output o_driveLocal_01, o_freeLocal_01, 
	output [50:0] o_localMsg_51_01,
    input i_driveWest_01, i_freeWest_01,
	input [50:0] i_westInMsg_51_01,
    output o_driveWest_01, o_freeWest_01,
	output [50:0] o_westMsg_51_01,
    input i_driveNorth_01, i_freeNorth_01,
	input [50:0] i_northInMsg_51_01,
    output o_driveNorth_01, o_freeNorth_01, 
	output	[50:0] o_northMsg_51_01
);
    // Define wires for inter-node connections
    wire w_drive00201, w_free00201;
    wire [50:0] w_00201Msg_51;  // (0,0) to (0,1)
    wire w_drive01200, w_free01200;
    wire [50:0] w_01200Msg_51;  // (0,1) to (0,0)
    wire w_drive00210, w_free00210;
    wire [50:0] w_00210Msg_51;  // (0,0) to (1,0)
    wire w_drive10200, w_free10200;
    wire [50:0] w_10200Msg_51;  // (1,0) to (0,0)
    
    wire w_drive10211, w_free10211;
    wire [50:0] w_10211Msg_51;  // (1,0) to (1,1)
    wire w_drive11210, w_free11210;
    wire [50:0] w_11210Msg_51;  // (1,1) to (1,0)
    wire w_drive01211, w_free01211;
    wire [50:0] w_01211Msg_51;  // (0,1) to (1,1)
    wire w_drive11201, w_free11201;
    wire [50:0] w_11201Msg_51;  // (1,1) to (0,1)
    
   nodeTop node_11 (
    .rst(rst),
    .i_driveLocal(i_driveLocal_11), .o_freeLocal(o_freeLocal_11), .i_localInMsg_51(i_localInMsg_51_11),
    .o_driveLocal(o_driveLocal_11), .i_freeLocal(i_freeLocal_11), .o_localMsg_51(o_localMsg_51_11),
    .i_driveWest(w_drive01211), .o_freeWest(w_free01211), .i_westInMsg_51(w_01211Msg_51),
    .o_driveWest(w_drive11201), .i_freeWest(w_free11201), .o_westMsg_51(w_11201Msg_51),
    .i_driveEast(i_driveEast_11), .o_freeEast(o_freeEast_11), .i_eastInMsg_51(i_eastInMsg_51_11),
    .o_driveEast(o_driveEast_11), .i_freeEast(i_freeEast_11), .o_eastMsg_51(o_eastMsg_51_11),
    .i_driveNorth(i_driveNorth_11), .o_freeNorth(o_freeNorth_11), .i_northInMsg_51(i_northInMsg_51_11),
    .o_driveNorth(o_driveNorth_11), .i_freeNorth(i_freeNorth_11), .o_northMsg_51(o_northMsg_51_11),
    .i_driveSouth(w_drive10211), .o_freeSouth(w_free10211), .i_southInMsg_51(w_10211Msg_51),
    .o_driveSouth(w_drive11210), .i_freeSouth(w_free11210), .o_southMsg_51(w_11210Msg_51)
    );
    
    nodeTop node_10 (
        .rst(rst),
        .i_driveLocal(i_driveLocal_10), .o_freeLocal(o_freeLocal_10), .i_localInMsg_51(i_localInMsg_51_10),
        .o_driveLocal(o_driveLocal_10), .i_freeLocal(i_freeLocal_10), .o_localMsg_51(o_localMsg_51_10),
        .i_driveWest(w_drive00210), .o_freeWest(w_free00210), .i_westInMsg_51(w_00210Msg_51),
        .o_driveWest(w_drive10200), .i_freeWest(w_free10200), .o_westMsg_51(w_10200Msg_51),
        .i_driveEast(i_driveEast_10), .o_freeEast(o_freeEast_10), .i_eastInMsg_51(i_eastInMsg_51_10),
        .o_driveEast(o_driveEast_10), .i_freeEast(i_freeEast_10), .o_eastMsg_51(o_eastMsg_51_10),
        .i_driveNorth(w_drive11210), .o_freeNorth(w_free11210), .i_northInMsg_51(w_11210Msg_51),
        .o_driveNorth(w_drive10211), .i_freeNorth(w_free10211), .o_northMsg_51(w_10211Msg_51),
        .i_driveSouth(i_driveSouth_10), .o_freeSouth(o_freeSouth_10), .i_southInMsg_51(i_southInMsg_51_10),
        .o_driveSouth(o_driveSouth_10), .i_freeSouth(i_freeSouth_10), .o_southMsg_51(o_southMsg_51_10)
    );
    
    nodeTop node_01 (
        .rst(rst),
        .i_driveLocal(i_driveLocal_01), .o_freeLocal(o_freeLocal_01), .i_localInMsg_51(i_localInMsg_51_01),
        .o_driveLocal(o_driveLocal_01), .i_freeLocal(i_freeLocal_01), .o_localMsg_51(o_localMsg_51_01),
        .i_driveWest(i_driveWest_01), .o_freeWest(o_freeWest_01), .i_westInMsg_51(i_westInMsg_51_01),
        .o_driveWest(o_driveWest_01), .i_freeWest(i_freeWest_01), .o_westMsg_51(o_westMsg_51_01),
        .i_driveEast(w_drive11201), .o_freeEast(w_free11201), .i_eastInMsg_51(w_11201Msg_51),
        .o_driveEast(w_drive01211), .i_freeEast(w_free01211), .o_eastMsg_51(w_01211Msg_51),
        .i_driveNorth(i_driveNorth_01), .o_freeNorth(o_freeNorth_01), .i_northInMsg_51(i_northInMsg_51_01),
        .o_driveNorth(o_driveNorth_01), .i_freeNorth(i_freeNorth_01), .o_northMsg_51(o_northMsg_51_01),
        .i_driveSouth(w_drive00201), .o_freeSouth(w_free00201), .i_southInMsg_51(w_00201Msg_51),
        .o_driveSouth(w_drive01200), .i_freeSouth(w_free01200), .o_southMsg_51(w_01200Msg_51)
    );   

    // Instantiate nodes
    nodeTop node_00 (
        .rst(rst),
        .i_driveLocal(i_driveLocal_00), .o_freeLocal(o_freeLocal_00), .i_localInMsg_51(i_localInMsg_51_00),
        .o_driveLocal(o_driveLocal_00), .i_freeLocal(i_freeLocal_00), .o_localMsg_51(o_localMsg_51_00),
        .i_driveWest(i_driveWest_00), .o_freeWest(o_freeWest_00), .i_westInMsg_51(i_westInMsg_51_00),
        .o_driveWest(o_driveWest_00), .i_freeWest(i_freeWest_00), .o_westMsg_51(o_westMsg_51_00),
        //(0,0) and (1,0)
        .i_driveEast(w_drive10200), .o_freeEast(w_free10200), .i_eastInMsg_51(w_10200Msg_51),
        .o_driveEast(w_drive00210), .i_freeEast(w_free00210), .o_eastMsg_51(w_00210Msg_51),
        //(0,0) and (0,1)
        .i_driveNorth(w_drive01200), .o_freeNorth(w_free01200), .i_northInMsg_51(w_01200Msg_51),
        .o_driveNorth(w_drive00201), .i_freeNorth(w_free00201), .o_northMsg_51(w_00201Msg_51),
        .i_driveSouth(i_driveSouth_00), .o_freeSouth(o_freeSouth_00), .i_southInMsg_51(i_southInMsg_51_00),
        .o_driveSouth(o_driveSouth_00), .i_freeSouth(i_freeSouth_00), .o_southMsg_51(o_southMsg_51_00)
    );

endmodule
