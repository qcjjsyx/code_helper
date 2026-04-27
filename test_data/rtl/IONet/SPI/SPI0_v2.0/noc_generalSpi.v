`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/01 16:22:47
// Design Name: 
// Module Name: noc_generalSpi

// Revision 0.01 - File Created
// Additional Comments:

//////////////////////////////////////////////////////////////////////////////////
module noc_generalSpi

(
    input clk,
    input rst,
    
    //interact with spi slave
    input miso,
    output sclk,
    output cs_n,
    output mosi,
    
    output startRead,
    output busy,

    // External connections for each node
    //(0,0)
    input i_driveLocal_00, i_freeLocal_00, [50:0] i_localInMsg_51_00,
    output o_driveLocal_00, o_freeLocal_00, [50:0] o_localMsg_51_00,
    input i_driveWest_00, i_freeWest_00, [50:0] i_westInMsg_51_00,
    output o_driveWest_00, o_freeWest_00, [50:0] o_westMsg_51_00,
//    input i_driveSouth_00, i_freeSouth_00, [50:0] i_southInMsg_51_00,
//    output o_driveSouth_00, o_freeSouth_00, [50:0] o_southMsg_51_00,

    //(1,0)
    input i_driveLocal_10, i_freeLocal_10, [50:0] i_localInMsg_51_10,
    output o_driveLocal_10, o_freeLocal_10, [50:0] o_localMsg_51_10,
    input i_driveSouth_10, i_freeSouth_10, [50:0] i_southInMsg_51_10,
    output o_driveSouth_10, o_freeSouth_10, [50:0] o_southMsg_51_10,
    input i_driveEast_10, i_freeEast_10, [50:0] i_eastInMsg_51_10,
    output o_driveEast_10, o_freeEast_10, [50:0] o_eastMsg_51_10,

    //(1,1)
    input i_driveLocal_11, i_freeLocal_11, [50:0] i_localInMsg_51_11,
    output o_driveLocal_11, o_freeLocal_11, [50:0] o_localMsg_51_11,
    input i_driveNorth_11, i_freeNorth_11, [50:0] i_northInMsg_51_11,
    output o_driveNorth_11, o_freeNorth_11, [50:0] o_northMsg_51_11,
    input i_driveEast_11, i_freeEast_11, [50:0] i_eastInMsg_51_11,
    output o_driveEast_11, o_freeEast_11, [50:0] o_eastMsg_51_11,
    
    //(0,1)
    input i_driveLocal_01, i_freeLocal_01, [50:0] i_localInMsg_51_01,
    output o_driveLocal_01, o_freeLocal_01, [50:0] o_localMsg_51_01,
    input i_driveWest_01, i_freeWest_01, [50:0] i_westInMsg_51_01,
    output o_driveWest_01, o_freeWest_01, [50:0] o_westMsg_51_01,
    input i_driveNorth_01, i_freeNorth_01, [50:0] i_northInMsg_51_01,
    output o_driveNorth_01, o_freeNorth_01, [50:0] o_northMsg_51_01
    );

    wire r_en;
//    wire startRead;
//    wire [31:0] spi2nocD;
//    wire [31:0] noc2spiD;
    
    wire [50:0] w_o_southMsg_51_00;
    wire w_i_freeSouth_00;
    wire w_o_driveSouth_00;
    
    wire w_i_driveSouth_00;
    wire w_o_freeSouth_00;
    wire [50:0] w_i_southInMsg_51_00;
    
//    wire [7:0] address;
//    wire       finish;
//    wire       dataReady;
    
    IONetwork mesh (
        .rst(rst),
        //(0,0)
        .i_driveLocal_00(i_driveLocal_00), .i_freeLocal_00(i_freeLocal_00), .i_localInMsg_51_00(i_localInMsg_51_00),
        .o_driveLocal_00(o_driveLocal_00), .o_freeLocal_00(o_freeLocal_00), .o_localMsg_51_00(o_localMsg_51_00),
        .i_driveWest_00(i_driveWest_00), .i_freeWest_00(i_freeWest_00), .i_westInMsg_51_00(i_westInMsg_51_00),
        .o_driveWest_00(o_driveWest_00), .o_freeWest_00(o_freeWest_00), .o_westMsg_51_00(o_westMsg_51_00),
        .i_driveSouth_00(w_i_driveSouth_00), .i_freeSouth_00(w_i_freeSouth_00), .i_southInMsg_51_00(w_i_southInMsg_51_00),
        .o_driveSouth_00(w_o_driveSouth_00), .o_freeSouth_00(w_o_freeSouth_00), .o_southMsg_51_00(w_o_southMsg_51_00),
       
        //(1,0)
        .i_driveLocal_10(i_driveLocal_10), .i_freeLocal_10(i_freeLocal_10), .i_localInMsg_51_10(i_localInMsg_51_10),
        .o_driveLocal_10(o_driveLocal_10), .o_freeLocal_10(o_freeLocal_10), .o_localMsg_51_10(o_localMsg_51_10),
        .i_driveSouth_10(i_driveSouth_10), .i_freeSouth_10(i_freeSouth_10), .i_southInMsg_51_10(i_southInMsg_51_10),
        .o_driveSouth_10(o_driveSouth_10), .o_freeSouth_10(o_freeSouth_10), .o_southMsg_51_10(o_southMsg_51_10),
        .i_driveEast_10(i_driveEast_10), .i_freeEast_10(i_freeEast_10), .i_eastInMsg_51_10(i_eastInMsg_51_10),
        .o_driveEast_10(o_driveEast_10), .o_freeEast_10(o_freeEast_10), .o_eastMsg_51_10(o_eastMsg_51_10),
        
        //(1,1)
        .i_driveLocal_11(i_driveLocal_11), .i_freeLocal_11(i_freeLocal_11), .i_localInMsg_51_11(i_localInMsg_51_11),
        .o_driveLocal_11(o_driveLocal_11), .o_freeLocal_11(o_freeLocal_11), .o_localMsg_51_11(o_localMsg_51_11),
        .i_driveNorth_11(i_driveNorth_11), .i_freeNorth_11(i_freeNorth_11), .i_northInMsg_51_11(i_northInMsg_51_11),
        .o_driveNorth_11(o_driveNorth_11), .o_freeNorth_11(o_freeNorth_11), .o_northMsg_51_11(o_northMsg_51_11),
        .i_driveEast_11(i_driveEast_11), .i_freeEast_11(i_freeEast_11), .i_eastInMsg_51_11(i_eastInMsg_51_11),
        .o_driveEast_11(o_driveEast_11), .o_freeEast_11(o_freeEast_11), .o_eastMsg_51_11(o_eastMsg_51_11),
        
        //(0,1)
        .i_driveLocal_01(i_driveLocal_01), .i_freeLocal_01(i_freeLocal_01), .i_localInMsg_51_01(i_localInMsg_51_01),
        .o_driveLocal_01(o_driveLocal_01), .o_freeLocal_01(o_freeLocal_01), .o_localMsg_51_01(o_localMsg_51_01),
        .i_driveWest_01(i_driveWest_01), .i_freeWest_01(i_freeWest_01), .i_westInMsg_51_01(i_westInMsg_51_01),
        .o_driveWest_01(o_driveWest_01), .o_freeWest_01(o_freeWest_01), .o_westMsg_51_01(o_westMsg_51_01),
        .i_driveNorth_01(i_driveNorth_01), .i_freeNorth_01(i_freeNorth_01), .i_northInMsg_51_01(i_northInMsg_51_01),
        .o_driveNorth_01(o_driveNorth_01), .o_freeNorth_01(o_freeNorth_01), .o_northMsg_51_01(o_northMsg_51_01)
    ); 
    
    noc_generalSpi_slot slot(
        .clk(clk),
        .rst(rst),
        
        .i_driveFrmMesh(w_o_driveSouth_00),
        .o_freeToMesh(w_i_freeSouth_00),
        .i_dataFrmNoc(w_o_southMsg_51_00),                     //51位
        
        .o_driveNextToMesh(w_i_driveSouth_00),
        .i_freeNextFrmMesh(w_o_freeSouth_00),
        .o_data2Noc(w_i_southInMsg_51_00),                   //51位
        
        //interact with spi slave
        .miso(miso),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        
        .busy(busy),
        .startRead(startRead)                    //开启一次新的读数
        
    );
        
    /*spi_master  u_spi_master(
        .clk(clk),
        .rst_n(rst),
        
        .rx(miso),
        .sclk_out(sclk),
        .nss_out(cs_n),
        .tx(mosi),
        
        .data_in(noc2spiD),
        .data_out(spi2nocD),
        .RXNE(dataReady),
        
        .DR_w(startRead),
        .ADDR(address),
        .DR_r(readFlag),
        .r_enT(r_enT)
      );*/
endmodule