`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         exe_top_tb
// version:        1st version (2025-11-11)
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/11/25
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    执行测试模块
//===============================================================================

module exe_top_tb;

    reg           rst;
    reg           i_driveToExe;
    wire          o_freeFrmExe;
    reg [342:0]   i_decoderExeBus_343;

    wire          o_driveNextToLsu;
    reg           i_freeNextFrmLsu;
    wire [245:0]  o_exeLSUBus_246;

    

exe_top uut(
.i_driveToExe(i_driveToExe),
.o_freeFrmExe(o_freeFrmExe),
.i_decoderExeBus_343(i_decoderExeBus_343), 
.o_driveNextToLsu(o_driveNextToLsu),
.i_freeNextFrmLsu(i_freeNextFrmLsu),
.o_exeLSUBus_246(o_exeLSUBus_246),
.rst(rst)
);

initial begin
rst = 1;
i_driveToExe = 0;
i_decoderExeBus_343 = 0;
i_freeNextFrmLsu = 0;

#50;
   rst = 0;
   #150;
   rst = 1;
   #100;

   #10;
   i_decoderExeBus_343 = {1'b1, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 9'b0, 4'b0100, 12'b000000000000, 32'h5A18C132, 64'h2000000, 64'h1, 64'h2222222222222222, 64'h8888888888888888}; //divw 求商   4
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b0, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 9'b0, 4'b0100, 12'b000000000000, 32'h5A18C132, 64'h2000000, 64'h1, 64'h0000000000000002, 64'h0000000000000008}; //div 求商   4
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b0, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 9'b0, 4'b1100, 12'b000000000000, 32'h5A18C132, 64'h2000000, 64'h1, 64'h0000000000000003, 64'h0000000000000005}; //div 取余   2
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b1, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 11'b0, 2'b11, 12'b000000000000, 32'h5A18C132, 64'h2000000, 64'h1, 64'h2222222222222222, 64'h3333333333333333}; //mulw 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b0, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 11'b0, 2'b11, 12'b000000000000, 32'h5A18C132, 64'h2000000, 64'h1, 64'h0000000000000002, 64'h0000000000000003}; //mul 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b0, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 13'b0, 12'b000000000010, 32'h5A18C132, 64'h2000000, 64'h1, 64'h3, 64'h2}; //add 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b0, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 13'b0, 12'b000000000010, 32'h5A18C132, 64'h2000000, 64'h1, 64'h4, 64'h4}; //add 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b1, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 13'b0, 12'b000000000010, 32'h5A18C132, 64'h2000000, 64'h1, 64'h1111111111111111, 64'h1111111111111111}; //addw 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #10;
   i_decoderExeBus_343 = {1'b1, 1'b0, 12'b0, 5'b01010, 9'b0, 2'b0, 13'b0, 12'b000000000010, 32'h5A18C132, 64'h2000000, 64'h1, 64'h2222222222222222, 64'h2222222222222222}; //addw 
   #10;
   i_driveToExe = ~i_driveToExe;
   #2;
   i_driveToExe = ~i_driveToExe;
   #100;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;
   #2;
   i_freeNextFrmLsu = ~i_freeNextFrmLsu;

   #200;
   $finish;
end


endmodule