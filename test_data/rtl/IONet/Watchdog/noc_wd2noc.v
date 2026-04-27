`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jiang Yilong
// 
// Create Date: 2024/09/04 09:51:01
// Design Name: 
// Module Name: noc_wd2noc
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


module noc_wd2noc(
//clock and reset
input wdclk,
input rst,

//connect to 1,0 east
//(1,0)
output o_driveEast_10, o_freeEast_10, [50:0] o_eastMsg_51_10,
//00 node
input i_driveLocal_00, i_freeLocal_00, [50:0] i_localInMsg_51_00,
//send out wd rst and int
output wd_rst,
output wd_int
);
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire i_driveEast_10; 
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire i_freeEast_10;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [50:0] i_eastInMsg_51_10;
    
IONetwork mesh (
        .rst(rst),
        //(0,0)
        .i_driveLocal_00(i_driveLocal_00), .i_freeLocal_00(i_freeLocal_00), .i_localInMsg_51_00(i_localInMsg_51_00),
        .o_driveLocal_00(), .o_freeLocal_00(), .o_localMsg_51_00(),
        .i_driveWest_00(), .i_freeWest_00(), .i_westInMsg_51_00(),
        .o_driveWest_00(), .o_freeWest_00(), .o_westMsg_51_00(),
        .i_driveSouth_00(), .i_freeSouth_00(), .i_southInMsg_51_00(),
        .o_driveSouth_00(), .o_freeSouth_00(), .o_southMsg_51_00(),
       
        //(1,0)
        .i_driveLocal_10(), .i_freeLocal_10(), .i_localInMsg_51_10(),
        .o_driveLocal_10(), .o_freeLocal_10(), .o_localMsg_51_10(),
        .i_driveSouth_10(), .i_freeSouth_10(), .i_southInMsg_51_10(),
        .o_driveSouth_10(), .o_freeSouth_10(), .o_southMsg_51_10(),
        .i_driveEast_10(i_driveEast_10), .i_freeEast_10(i_freeEast_10), .i_eastInMsg_51_10(i_eastInMsg_51_10),
        .o_driveEast_10(o_driveEast_10), .o_freeEast_10(o_freeEast_10), .o_eastMsg_51_10(o_eastMsg_51_10),
        
        //(1,1)
        .i_driveLocal_11(), .i_freeLocal_11(), .i_localInMsg_51_11(),
        .o_driveLocal_11(), .o_freeLocal_11(), .o_localMsg_51_11(),
        .i_driveNorth_11(), .i_freeNorth_11(), .i_northInMsg_51_11(),
        .o_driveNorth_11(), .o_freeNorth_11(), .o_northMsg_51_11(),
        .i_driveEast_11(), .i_freeEast_11(), .i_eastInMsg_51_11(),
        .o_driveEast_11(), .o_freeEast_11(), .o_eastMsg_51_11(),
        
        //(0,1)
        .i_driveLocal_01(), .i_freeLocal_01(), .i_localInMsg_51_01(),
        .o_driveLocal_01(), .o_freeLocal_01(), .o_localMsg_51_01(),
        .i_driveWest_01(), .i_freeWest_01(), .i_westInMsg_51_01(),
        .o_driveWest_01(), .o_freeWest_01(), .o_westMsg_51_01(),
        .i_driveNorth_01(), .i_freeNorth_01(), .i_northInMsg_51_01(),
        .o_driveNorth_01(), .o_freeNorth_01(), .o_northMsg_51_01()
    );
    

wd2noc wd (
//inputs from mesh
.i_drive(o_driveEast_10),
.i_msg(o_eastMsg_51_10),
//[49:42] 8bits address to control wd mode, see defines
//[50:49] 1bit write enable have to be set as true
//[41:10] 32bit data
//[10:0] route data
.Noc_RES(rst),
.i_free(o_freeEast_10),

//watchdog clock
.wd_clk(wdclk),

//outputs 2 mesh
.o_free(i_freeEast_10),
.o_drive(i_driveEast_10),
.o_msg(i_eastInMsg_51_10),
.o_RES(wd_rst),
.o_INT(wd_int)
);
endmodule
