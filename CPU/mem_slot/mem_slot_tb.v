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

module mem_slot_tb;


// mem_slot Inputs
reg   rst                                  = 1 ;
reg   i_driveFromFetchtoMem                = 0 ;
reg   [135:0]  i_dataFetchtoMem_136        = 0 ;
reg   i_freeFromFetchtoMem                 = 0 ;
reg   i_driveFromLSUtoMem                  = 0 ;
reg   [135:0]  i_dataLSUtoMem_136          = 0 ;
reg   i_freeFromLSUtoMem                   = 0 ;
reg   i_freeFromIcachetoMem                = 0 ;
reg   i_driveFromIcachetoMem               = 0 ;
reg   [255:0]  i_dataIcachetoMem_256       = 0 ;
reg   i_freeFromDcachetoMem                = 0 ;
reg   i_driveFromDcachetoMem               = 0 ;
reg   [255:0]  i_dataDcachetoMem_256       = 0 ;

// mem_slot Outputs
wire  o_freeFromMemtoFetch                 ;
wire  o_driveFromMemtoFetch                ;
wire  [255:0]  o_dataMemtoFetch_256        ;
wire  o_freeFromMemtoLSU                   ;
wire  o_driveFromMemtoLSU                  ;
wire  [255:0]  o_dataMemtoLSU_256          ;
wire  o_driveFromMemtoIcache               ;
wire  [135:0]  o_dataMemtoIcache_136       ;
wire  o_freeFromMemtoIcache                ;
wire  o_driveFromMemtoDcache               ;
wire  [135:0]  o_dataMemtoDcache_136       ;
wire  o_freeFromMemtoDcache                ;


mem_slot  u_mem_slot (
    .rst                     ( rst                             ),
    .i_driveFromFetchtoMem   ( i_driveFromFetchtoMem           ),
    .i_dataFetchtoMem_136    ( i_dataFetchtoMem_136    [135:0] ),
    .i_freeFromFetchtoMem    ( i_freeFromFetchtoMem            ),
    .i_driveFromLSUtoMem     ( i_driveFromLSUtoMem             ),
    .i_dataLSUtoMem_136      ( i_dataLSUtoMem_136      [135:0] ),
    .i_freeFromLSUtoMem      ( i_freeFromLSUtoMem              ),
    .i_freeFromIcachetoMem   ( i_freeFromIcachetoMem           ),
    .i_driveFromIcachetoMem  ( i_driveFromIcachetoMem          ),
    .i_dataIcachetoMem_256   ( i_dataIcachetoMem_256   [255:0] ),
    .i_freeFromDcachetoMem   ( i_freeFromDcachetoMem           ),
    .i_driveFromDcachetoMem  ( i_driveFromDcachetoMem          ),
    .i_dataDcachetoMem_256   ( i_dataDcachetoMem_256   [255:0] ),

    .o_freeFromMemtoFetch    ( o_freeFromMemtoFetch            ),
    .o_driveFromMemtoFetch   ( o_driveFromMemtoFetch           ),
    .o_dataMemtoFetch_256    ( o_dataMemtoFetch_256    [255:0] ),
    .o_freeFromMemtoLSU      ( o_freeFromMemtoLSU              ),
    .o_driveFromMemtoLSU     ( o_driveFromMemtoLSU             ),
    .o_dataMemtoLSU_256      ( o_dataMemtoLSU_256      [255:0] ),
    .o_driveFromMemtoIcache  ( o_driveFromMemtoIcache          ),
    .o_dataMemtoIcache_136   ( o_dataMemtoIcache_136   [135:0] ),
    .o_freeFromMemtoIcache   ( o_freeFromMemtoIcache           ),
    .o_driveFromMemtoDcache  ( o_driveFromMemtoDcache          ),
    .o_dataMemtoDcache_136   ( o_dataMemtoDcache_136   [135:0] ),
    .o_freeFromMemtoDcache   ( o_freeFromMemtoDcache           )
);

initial
begin

   #50;
   rst = 0;
   #150;
   rst = 1;
   #100;
   
   #10;
   i_dataFetchtoMem_136 = {8'b0, 64'h2000, 64'h8};
   i_dataIcachetoMem_256 = {256'h4444444444444444444444444444400833333333333333333333333333330008};
   #10;
   i_driveFromFetchtoMem = ~i_driveFromFetchtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromFetchtoMem = ~i_driveFromFetchtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #100;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromFetchtoMem = ~i_freeFromFetchtoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromFetchtoMem = ~i_freeFromFetchtoMem;

   #10;
   i_dataFetchtoMem_136 = {8'b0, 64'h3201, 64'h6};
   i_dataIcachetoMem_256 = {256'h6666666666666666666666666666000855555555555555555555555555550008};
   #10;
   i_driveFromFetchtoMem = ~i_driveFromFetchtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromFetchtoMem = ~i_driveFromFetchtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #100;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromFetchtoMem = ~i_freeFromFetchtoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromFetchtoMem = ~i_freeFromFetchtoMem;

   #10;
   i_dataLSUtoMem_136 = {8'b0, 64'h3201, 64'h6};
   i_dataIcachetoMem_256 = {256'h0321057210050708032528910005100803210572100507080321057210050008};
   #10;
   i_driveFromLSUtoMem = ~i_driveFromLSUtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #2;
   i_driveFromLSUtoMem = ~i_driveFromLSUtoMem;
   i_driveFromIcachetoMem = ~i_driveFromIcachetoMem;
   #100;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromLSUtoMem = ~i_freeFromLSUtoMem;
   #2;
   i_freeFromIcachetoMem = ~i_freeFromIcachetoMem;
   i_freeFromLSUtoMem = ~i_freeFromLSUtoMem;

   #10;
   i_dataLSUtoMem_136 = {8'b0, 64'h2_0000_0001, 64'h6};
   i_dataDcachetoMem_256 = {256'h0321057210050708032105721005000803210572100507080325289100050008};
   #10;
   i_driveFromLSUtoMem = ~i_driveFromLSUtoMem;
   i_driveFromDcachetoMem = ~i_driveFromDcachetoMem;
   #2;
   i_driveFromLSUtoMem = ~i_driveFromLSUtoMem;
   i_driveFromDcachetoMem = ~i_driveFromDcachetoMem;
   #100;
   i_freeFromDcachetoMem = ~i_freeFromDcachetoMem;
   i_freeFromLSUtoMem = ~i_freeFromLSUtoMem;
   #2;
   i_freeFromDcachetoMem = ~i_freeFromDcachetoMem;
   i_freeFromLSUtoMem = ~i_freeFromLSUtoMem;

    #200;
    $finish;
end

endmodule