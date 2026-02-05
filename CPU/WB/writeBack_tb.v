`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         writeBack_tb
// version:        1st version (2025-11-11)
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/11/25
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    出局模块
//===============================================================================

module writeBack_tb;

    reg          rst;
    reg [245:0]  i_dataLSUToWb_246;
    reg          i_driveLSUToWb;
    wire         o_freeWbToLSU;

    wire [68:0]  o_dataWbToGrf_69;
    wire         o_driveWbToGrf;
    reg          i_freeGrfToWb;

    wire [75:0]  o_dataWbToCsrf_76;
    wire         o_driveWbToCsrf;
    reg          i_freeCsrfToWb;

    wire [63:0]  o_dataWbToFetch_64;
    wire         o_driveWbToFetch;
    reg          i_freeFetchToWb;

    

writeBack uut(
.i_dataLSUToWb_246(i_dataLSUToWb_246),
.i_driveLSUToWb(i_driveLSUToWb),
.o_freeWbToLSU(o_freeWbToLSU),
.o_dataWbToGrf_69(o_dataWbToGrf_69),
.o_driveWbToGrf(o_driveWbToGrf),
.i_freeGrfToWb(i_freeGrfToWb),
.o_dataWbToCsrf_76(o_dataWbToCsrf_76),
.o_driveWbToCsrf(o_driveWbToCsrf),
.i_freeCsrfToWb(i_freeCsrfToWb),
.o_dataWbToFetch_64(o_dataWbToFetch_64),
.o_driveWbToFetch(o_driveWbToFetch),
.i_freeFetchToWb(i_freeFetchToWb),
.rst(rst)
);

initial begin
rst = 1;
i_dataLSUToWb_246 = 0;
i_driveLSUToWb = 0;
i_freeGrfToWb = 0;
i_freeCsrfToWb = 0;
i_freeFetchToWb = 0;

#50;
   rst = 0;
   #150;
   rst = 1;
   #100;

   
   #10;
   i_dataLSUToWb_246 = {64'h3, 1'b0, 32'h11111111, 4'b0010, 5'b10001, 12'b101110010110, 64'h2, 64'h8};
   #10;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #2;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #100;
   i_freeFetchToWb = ~i_freeFetchToWb;
   #2;
   i_freeFetchToWb = ~i_freeFetchToWb;


   #10;
   i_dataLSUToWb_246 = {64'h4, 1'b0, 32'h22222222, 4'b0110, 5'b10001, 12'b101110010110, 64'h4, 64'h6};
   #10;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #2;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #100;
   i_freeFetchToWb = ~i_freeFetchToWb;
   i_freeGrfToWb = ~i_freeGrfToWb;
   #2;
   i_freeFetchToWb = ~i_freeFetchToWb;
   i_freeGrfToWb = ~i_freeGrfToWb;

   #10;
   i_dataLSUToWb_246 = {64'h5, 1'b0, 32'h33333333, 4'b0001, 5'b10001, 12'b101110010110, 64'h4, 64'h6};
   #10;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #2;
   i_driveLSUToWb = ~i_driveLSUToWb;
   #100;
   i_freeFetchToWb = ~i_freeFetchToWb;
   i_freeGrfToWb = ~i_freeGrfToWb;
   i_freeCsrfToWb = ~i_freeCsrfToWb;
   #2;
   i_freeFetchToWb = ~i_freeFetchToWb;
   i_freeGrfToWb = ~i_freeGrfToWb;
   i_freeCsrfToWb = ~i_freeCsrfToWb;


   #200;
   $finish;
end


endmodule