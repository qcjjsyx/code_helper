//-----------------------------------------------
//	module name: sram_8k
//	author: Lu.yihua
//  
//	version: 1st version (2022-4-12)
//	description: 
//      total 8KB
//	receive data and send data
//      Sram_8k: i_WEB_8[i] write:1, read:0. enable byte by byte.
//      whether you write|read|(write&read) o_data_64 will output the data in address.
//-----------------------------------------------

`timescale 1ns / 1ps

module sram_8k(
i_addr_10,i_data_64,i_WEB_8,i_sramTrig,o_data_64	
);

input   [9:0]      i_addr_10;
input   [63:0]     i_data_64;
input              i_sramTrig;

// the input is viewed as write:0 read:1
input   [ 7:0]     i_WEB_8;
output  [63:0]     o_data_64;

//---------------------------------------------------------

SHKB110_1024X8X8CM8 Sram_8KB_0(
    .A0   ( i_addr_10[0]  ),  .A1   ( i_addr_10[1]  ),  .A2  ( i_addr_10[2] ),  .A3  ( i_addr_10[3] ),  .A4  ( i_addr_10[4]   ),  
    .A5   ( i_addr_10[5]  ),  .A6   ( i_addr_10[6]  ),  .A7  ( i_addr_10[7] ),  .A8  ( i_addr_10[8] ),  .A9  ( i_addr_10[9]   ),                                 
    .DO0  ( o_data_64[0]  ),  .DO1  ( o_data_64[1]  ),  .DO2  ( o_data_64[2]  ),  .DO3  ( o_data_64[3]  ),  .DO4  ( o_data_64[4]  ), 
    .DO5  ( o_data_64[5]  ),  .DO6  ( o_data_64[6]  ),  .DO7  ( o_data_64[7]  ),  .DO8  ( o_data_64[8]  ),  .DO9  ( o_data_64[9]  ),  
    .DO10 ( o_data_64[10] ),  .DO11 ( o_data_64[11] ),  .DO12 ( o_data_64[12] ),  .DO13 ( o_data_64[13] ),  .DO14 ( o_data_64[14] ), 
    .DO15 ( o_data_64[15] ),  .DO16 ( o_data_64[16] ),  .DO17 ( o_data_64[17] ),  .DO18 ( o_data_64[18] ),  .DO19 ( o_data_64[19] ), 
    .DO20 ( o_data_64[20] ),  .DO21 ( o_data_64[21] ),  .DO22 ( o_data_64[22] ),  .DO23 ( o_data_64[23] ),  .DO24 ( o_data_64[24] ),  
    .DO25 ( o_data_64[25] ),  .DO26 ( o_data_64[26] ),  .DO27 ( o_data_64[27] ),  .DO28 ( o_data_64[28] ),  .DO29 ( o_data_64[29] ),  
    .DO30 ( o_data_64[30] ),  .DO31 ( o_data_64[31] ),  .DO32 ( o_data_64[32] ),  .DO33 ( o_data_64[33] ),  .DO34 ( o_data_64[34] ),
    .DO35 ( o_data_64[35] ),  .DO36 ( o_data_64[36] ),  .DO37 ( o_data_64[37] ),  .DO38 ( o_data_64[38] ),  .DO39 ( o_data_64[39] ),  
    .DO40 ( o_data_64[40] ),  .DO41 ( o_data_64[41] ),  .DO42 ( o_data_64[42] ),  .DO43 ( o_data_64[43] ),  .DO44 ( o_data_64[44] ), 
    .DO45 ( o_data_64[45] ),  .DO46 ( o_data_64[46] ),  .DO47 ( o_data_64[47] ),  .DO48 ( o_data_64[48] ),  .DO49 ( o_data_64[49] ),  
    .DO50 ( o_data_64[50] ),  .DO51 ( o_data_64[51] ),  .DO52 ( o_data_64[52] ),  .DO53 ( o_data_64[53] ),  .DO54 ( o_data_64[54] ),  
    .DO55 ( o_data_64[55] ),  .DO56 ( o_data_64[56] ),  .DO57 ( o_data_64[57] ),  .DO58 ( o_data_64[58] ),  .DO59 ( o_data_64[59] ),  
    .DO60 ( o_data_64[60] ),  .DO61 ( o_data_64[61] ),  .DO62 ( o_data_64[62] ),  .DO63 ( o_data_64[63] ),
    .DI0  ( i_data_64[0]  ),  .DI1  ( i_data_64[1]  ),  .DI2  ( i_data_64[2]  ),  .DI3  ( i_data_64[3]  ),  .DI4  ( i_data_64[4]  ), 
    .DI5  ( i_data_64[5]  ),  .DI6  ( i_data_64[6]  ),  .DI7  ( i_data_64[7]  ),  .DI8  ( i_data_64[8]  ),  .DI9  ( i_data_64[9]  ),  
    .DI10 ( i_data_64[10] ),  .DI11 ( i_data_64[11] ),  .DI12 ( i_data_64[12] ),  .DI13 ( i_data_64[13] ),  .DI14 ( i_data_64[14] ), 
    .DI15 ( i_data_64[15] ),  .DI16 ( i_data_64[16] ),  .DI17 ( i_data_64[17] ),  .DI18 ( i_data_64[18] ),  .DI19 ( i_data_64[19] ), 
    .DI20 ( i_data_64[20] ),  .DI21 ( i_data_64[21] ),  .DI22 ( i_data_64[22] ),  .DI23 ( i_data_64[23] ),  .DI24 ( i_data_64[24] ),  
    .DI25 ( i_data_64[25] ),  .DI26 ( i_data_64[26] ),  .DI27 ( i_data_64[27] ),  .DI28 ( i_data_64[28] ),  .DI29 ( i_data_64[29] ),  
    .DI30 ( i_data_64[30] ),  .DI31 ( i_data_64[31] ),  .DI32 ( i_data_64[32] ),  .DI33 ( i_data_64[33] ),  .DI34 ( i_data_64[34] ),
    .DI35 ( i_data_64[35] ),  .DI36 ( i_data_64[36] ),  .DI37 ( i_data_64[37] ),  .DI38 ( i_data_64[38] ),  .DI39 ( i_data_64[39] ),  
    .DI40 ( i_data_64[40] ),  .DI41 ( i_data_64[41] ),  .DI42 ( i_data_64[42] ),  .DI43 ( i_data_64[43] ),  .DI44 ( i_data_64[44] ), 
    .DI45 ( i_data_64[45] ),  .DI46 ( i_data_64[46] ),  .DI47 ( i_data_64[47] ),  .DI48 ( i_data_64[48] ),  .DI49 ( i_data_64[49] ),  
    .DI50 ( i_data_64[50] ),  .DI51 ( i_data_64[51] ),  .DI52 ( i_data_64[52] ),  .DI53 ( i_data_64[53] ),  .DI54 ( i_data_64[54] ),  
    .DI55 ( i_data_64[55] ),  .DI56 ( i_data_64[56] ),  .DI57 ( i_data_64[57] ),  .DI58 ( i_data_64[58] ),  .DI59 ( i_data_64[59] ),  
    .DI60 ( i_data_64[60] ),  .DI61 ( i_data_64[61] ),  .DI62 ( i_data_64[62] ),  .DI63 ( i_data_64[63] ),
    .WEB0 ( ~i_WEB_8[0]  ),   .WEB1 ( ~i_WEB_8[1]   ),  .WEB2 ( ~i_WEB_8[2]  ),   .WEB3 ( ~i_WEB_8[3]  ), 
    .WEB4 ( ~i_WEB_8[4]  ),   .WEB5 ( ~i_WEB_8[5]   ),  .WEB6 ( ~i_WEB_8[6]  ),   .WEB7 ( ~i_WEB_8[7]  ), 
    .DVSE ( 1'b0         ),   .DVS0 ( 1'b0          ),  .DVS1 ( 1'b0         ),   .DVS2 ( 1'b0         ),   .DVS3( 1'b0             ),
    .CK   ( i_sramTrig   ),
    .CSB  ( 1'b0 ),
    .OE   ( 1'b1 )
);


endmodule

