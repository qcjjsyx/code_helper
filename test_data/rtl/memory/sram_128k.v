//-----------------------------------------------
//	module name: SramTop
//	author: Wenqi Diao
//  
//	version: 1st version (2022-4-12)
//	description: 
//      total 128KB, use 4 * sram_32k
//		Sram_32KB(4096*8*8) receive data and send data
//      Sram_32k: i_WEB_8[i] write:1, read:0. enable byte by byte.
//      whether you write|read|(write&read) o_data_64 will output the data in address.
//-----------------------------------------------

`timescale 1ns / 1ps

module sram_128k(
i_addr_14,i_data_64,i_WEB_8,i_sramTrig,o_data_64	
    );

input   [13:0]      i_addr_14;
input   [63:0]      i_data_64;
input               i_sramTrig;

// the input is viewed as write:0 read:1
input   [ 7:0]      i_WEB_8;
output  [63:0]      o_data_64;

wire csb_0;
assign csb_0 = (i_addr_14[13:12] == 2'b00);
wire csb_1;
assign csb_1 = (i_addr_14[13:12] == 2'b01);
wire csb_2;
assign csb_2 = (i_addr_14[13:12] == 2'b10);
wire csb_3;
assign csb_3 = (i_addr_14[13:12] == 2'b11);

wire [63:0] w_data_64_s0;
wire [63:0] w_data_64_s1;
wire [63:0] w_data_64_s2;
wire [63:0] w_data_64_s3;

assign o_data_64 = (i_addr_14[13:12] == 2'b00) ? w_data_64_s0 :
                    (i_addr_14[13:12] == 2'b01) ? w_data_64_s1 :
                    (i_addr_14[13:12] == 2'b10) ? w_data_64_s2 : w_data_64_s3;
//---------------------------------------------------------

SHKB110_4096X8X8CM8 Sram_32KB_0(
    .A0   ( i_addr_14[0]  ),  .A1   ( i_addr_14[1]  ),  .A2  ( i_addr_14[2] ),  .A3  ( i_addr_14[3] ),  .A4  ( i_addr_14[4]   ),  
    .A5   ( i_addr_14[5]  ),  .A6   ( i_addr_14[6]  ),  .A7  ( i_addr_14[7] ),  .A8  ( i_addr_14[8] ),  .A9  ( i_addr_14[9]   ),  
    .A10  ( i_addr_14[10] ),  .A11  ( i_addr_14[11] ),                                   
    .DO0  ( w_data_64_s0[0]  ),  .DO1  ( w_data_64_s0[1]  ),  .DO2  ( w_data_64_s0[2]  ),  .DO3  ( w_data_64_s0[3]  ),  .DO4  ( w_data_64_s0[4]  ), 
    .DO5  ( w_data_64_s0[5]  ),  .DO6  ( w_data_64_s0[6]  ),  .DO7  ( w_data_64_s0[7]  ),  .DO8  ( w_data_64_s0[8]  ),  .DO9  ( w_data_64_s0[9]  ),  
    .DO10 ( w_data_64_s0[10] ),  .DO11 ( w_data_64_s0[11] ),  .DO12 ( w_data_64_s0[12] ),  .DO13 ( w_data_64_s0[13] ),  .DO14 ( w_data_64_s0[14] ), 
    .DO15 ( w_data_64_s0[15] ),  .DO16 ( w_data_64_s0[16] ),  .DO17 ( w_data_64_s0[17] ),  .DO18 ( w_data_64_s0[18] ),  .DO19 ( w_data_64_s0[19] ), 
    .DO20 ( w_data_64_s0[20] ),  .DO21 ( w_data_64_s0[21] ),  .DO22 ( w_data_64_s0[22] ),  .DO23 ( w_data_64_s0[23] ),  .DO24 ( w_data_64_s0[24] ),  
    .DO25 ( w_data_64_s0[25] ),  .DO26 ( w_data_64_s0[26] ),  .DO27 ( w_data_64_s0[27] ),  .DO28 ( w_data_64_s0[28] ),  .DO29 ( w_data_64_s0[29] ),  
    .DO30 ( w_data_64_s0[30] ),  .DO31 ( w_data_64_s0[31] ),  .DO32 ( w_data_64_s0[32] ),  .DO33 ( w_data_64_s0[33] ),  .DO34 ( w_data_64_s0[34] ),
    .DO35 ( w_data_64_s0[35] ),  .DO36 ( w_data_64_s0[36] ),  .DO37 ( w_data_64_s0[37] ),  .DO38 ( w_data_64_s0[38] ),  .DO39 ( w_data_64_s0[39] ),  
    .DO40 ( w_data_64_s0[40] ),  .DO41 ( w_data_64_s0[41] ),  .DO42 ( w_data_64_s0[42] ),  .DO43 ( w_data_64_s0[43] ),  .DO44 ( w_data_64_s0[44] ), 
    .DO45 ( w_data_64_s0[45] ),  .DO46 ( w_data_64_s0[46] ),  .DO47 ( w_data_64_s0[47] ),  .DO48 ( w_data_64_s0[48] ),  .DO49 ( w_data_64_s0[49] ),  
    .DO50 ( w_data_64_s0[50] ),  .DO51 ( w_data_64_s0[51] ),  .DO52 ( w_data_64_s0[52] ),  .DO53 ( w_data_64_s0[53] ),  .DO54 ( w_data_64_s0[54] ),  
    .DO55 ( w_data_64_s0[55] ),  .DO56 ( w_data_64_s0[56] ),  .DO57 ( w_data_64_s0[57] ),  .DO58 ( w_data_64_s0[58] ),  .DO59 ( w_data_64_s0[59] ),  
    .DO60 ( w_data_64_s0[60] ),  .DO61 ( w_data_64_s0[61] ),  .DO62 ( w_data_64_s0[62] ),  .DO63 ( w_data_64_s0[63] ),
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
    .WEB0 ( ~i_WEB_8[0]  ), .WEB1 ( ~i_WEB_8[1]  ), .WEB2 ( ~i_WEB_8[2]  ), .WEB3 ( ~i_WEB_8[3]  ), 
    .WEB4 ( ~i_WEB_8[4]  ), .WEB5 ( ~i_WEB_8[5]  ), .WEB6 ( ~i_WEB_8[6]  ), .WEB7 ( ~i_WEB_8[7]  ), 
    .CK ( i_sramTrig ),
    .CSB  ( ~csb_0 ),
    .OE   ( 1'b1 )
);

SHKB110_4096X8X8CM8 Sram_32KB_1(
    .A0   ( i_addr_14[0]  ),  .A1   ( i_addr_14[1]  ),  .A2  ( i_addr_14[2] ),  .A3  ( i_addr_14[3] ),  .A4  ( i_addr_14[4]   ),  
    .A5   ( i_addr_14[5]  ),  .A6   ( i_addr_14[6]  ),  .A7  ( i_addr_14[7] ),  .A8  ( i_addr_14[8] ),  .A9  ( i_addr_14[9]   ),  
    .A10  ( i_addr_14[10] ),  .A11  ( i_addr_14[11] ),                                   
    .DO0  ( w_data_64_s1[0]  ),  .DO1  ( w_data_64_s1[1]  ),  .DO2  ( w_data_64_s1[2]  ),  .DO3  ( w_data_64_s1[3]  ),  .DO4  ( w_data_64_s1[4]  ), 
    .DO5  ( w_data_64_s1[5]  ),  .DO6  ( w_data_64_s1[6]  ),  .DO7  ( w_data_64_s1[7]  ),  .DO8  ( w_data_64_s1[8]  ),  .DO9  ( w_data_64_s1[9]  ),  
    .DO10 ( w_data_64_s1[10] ),  .DO11 ( w_data_64_s1[11] ),  .DO12 ( w_data_64_s1[12] ),  .DO13 ( w_data_64_s1[13] ),  .DO14 ( w_data_64_s1[14] ), 
    .DO15 ( w_data_64_s1[15] ),  .DO16 ( w_data_64_s1[16] ),  .DO17 ( w_data_64_s1[17] ),  .DO18 ( w_data_64_s1[18] ),  .DO19 ( w_data_64_s1[19] ), 
    .DO20 ( w_data_64_s1[20] ),  .DO21 ( w_data_64_s1[21] ),  .DO22 ( w_data_64_s1[22] ),  .DO23 ( w_data_64_s1[23] ),  .DO24 ( w_data_64_s1[24] ),  
    .DO25 ( w_data_64_s1[25] ),  .DO26 ( w_data_64_s1[26] ),  .DO27 ( w_data_64_s1[27] ),  .DO28 ( w_data_64_s1[28] ),  .DO29 ( w_data_64_s1[29] ),  
    .DO30 ( w_data_64_s1[30] ),  .DO31 ( w_data_64_s1[31] ),  .DO32 ( w_data_64_s1[32] ),  .DO33 ( w_data_64_s1[33] ),  .DO34 ( w_data_64_s1[34] ),
    .DO35 ( w_data_64_s1[35] ),  .DO36 ( w_data_64_s1[36] ),  .DO37 ( w_data_64_s1[37] ),  .DO38 ( w_data_64_s1[38] ),  .DO39 ( w_data_64_s1[39] ),  
    .DO40 ( w_data_64_s1[40] ),  .DO41 ( w_data_64_s1[41] ),  .DO42 ( w_data_64_s1[42] ),  .DO43 ( w_data_64_s1[43] ),  .DO44 ( w_data_64_s1[44] ), 
    .DO45 ( w_data_64_s1[45] ),  .DO46 ( w_data_64_s1[46] ),  .DO47 ( w_data_64_s1[47] ),  .DO48 ( w_data_64_s1[48] ),  .DO49 ( w_data_64_s1[49] ),  
    .DO50 ( w_data_64_s1[50] ),  .DO51 ( w_data_64_s1[51] ),  .DO52 ( w_data_64_s1[52] ),  .DO53 ( w_data_64_s1[53] ),  .DO54 ( w_data_64_s1[54] ),  
    .DO55 ( w_data_64_s1[55] ),  .DO56 ( w_data_64_s1[56] ),  .DO57 ( w_data_64_s1[57] ),  .DO58 ( w_data_64_s1[58] ),  .DO59 ( w_data_64_s1[59] ),  
    .DO60 ( w_data_64_s1[60] ),  .DO61 ( w_data_64_s1[61] ),  .DO62 ( w_data_64_s1[62] ),  .DO63 ( w_data_64_s1[63] ),
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
    .WEB0 ( ~i_WEB_8[0]  ), .WEB1 ( ~i_WEB_8[1]  ), .WEB2 ( ~i_WEB_8[2]  ), .WEB3 ( ~i_WEB_8[3]  ), 
    .WEB4 ( ~i_WEB_8[4]  ), .WEB5 ( ~i_WEB_8[5]  ), .WEB6 ( ~i_WEB_8[6]  ), .WEB7 ( ~i_WEB_8[7]  ), 
    .CK ( i_sramTrig ),
    .CSB  ( ~csb_1 ),
    .OE   ( 1'b1 )
);

SHKB110_4096X8X8CM8 Sram_32KB_2(
    .A0   ( i_addr_14[0]  ),  .A1   ( i_addr_14[1]  ),  .A2  ( i_addr_14[2] ),  .A3  ( i_addr_14[3] ),  .A4  ( i_addr_14[4]   ),  
    .A5   ( i_addr_14[5]  ),  .A6   ( i_addr_14[6]  ),  .A7  ( i_addr_14[7] ),  .A8  ( i_addr_14[8] ),  .A9  ( i_addr_14[9]   ),  
    .A10  ( i_addr_14[10] ),  .A11  ( i_addr_14[11] ),                                   
    .DO0  ( w_data_64_s2[0]  ),  .DO1  ( w_data_64_s2[1]  ),  .DO2  ( w_data_64_s2[2]  ),  .DO3  ( w_data_64_s2[3]  ),  .DO4  ( w_data_64_s2[4]  ), 
    .DO5  ( w_data_64_s2[5]  ),  .DO6  ( w_data_64_s2[6]  ),  .DO7  ( w_data_64_s2[7]  ),  .DO8  ( w_data_64_s2[8]  ),  .DO9  ( w_data_64_s2[9]  ),  
    .DO10 ( w_data_64_s2[10] ),  .DO11 ( w_data_64_s2[11] ),  .DO12 ( w_data_64_s2[12] ),  .DO13 ( w_data_64_s2[13] ),  .DO14 ( w_data_64_s2[14] ), 
    .DO15 ( w_data_64_s2[15] ),  .DO16 ( w_data_64_s2[16] ),  .DO17 ( w_data_64_s2[17] ),  .DO18 ( w_data_64_s2[18] ),  .DO19 ( w_data_64_s2[19] ), 
    .DO20 ( w_data_64_s2[20] ),  .DO21 ( w_data_64_s2[21] ),  .DO22 ( w_data_64_s2[22] ),  .DO23 ( w_data_64_s2[23] ),  .DO24 ( w_data_64_s2[24] ),  
    .DO25 ( w_data_64_s2[25] ),  .DO26 ( w_data_64_s2[26] ),  .DO27 ( w_data_64_s2[27] ),  .DO28 ( w_data_64_s2[28] ),  .DO29 ( w_data_64_s2[29] ),  
    .DO30 ( w_data_64_s2[30] ),  .DO31 ( w_data_64_s2[31] ),  .DO32 ( w_data_64_s2[32] ),  .DO33 ( w_data_64_s2[33] ),  .DO34 ( w_data_64_s2[34] ),
    .DO35 ( w_data_64_s2[35] ),  .DO36 ( w_data_64_s2[36] ),  .DO37 ( w_data_64_s2[37] ),  .DO38 ( w_data_64_s2[38] ),  .DO39 ( w_data_64_s2[39] ),  
    .DO40 ( w_data_64_s2[40] ),  .DO41 ( w_data_64_s2[41] ),  .DO42 ( w_data_64_s2[42] ),  .DO43 ( w_data_64_s2[43] ),  .DO44 ( w_data_64_s2[44] ), 
    .DO45 ( w_data_64_s2[45] ),  .DO46 ( w_data_64_s2[46] ),  .DO47 ( w_data_64_s2[47] ),  .DO48 ( w_data_64_s2[48] ),  .DO49 ( w_data_64_s2[49] ),  
    .DO50 ( w_data_64_s2[50] ),  .DO51 ( w_data_64_s2[51] ),  .DO52 ( w_data_64_s2[52] ),  .DO53 ( w_data_64_s2[53] ),  .DO54 ( w_data_64_s2[54] ),  
    .DO55 ( w_data_64_s2[55] ),  .DO56 ( w_data_64_s2[56] ),  .DO57 ( w_data_64_s2[57] ),  .DO58 ( w_data_64_s2[58] ),  .DO59 ( w_data_64_s2[59] ),  
    .DO60 ( w_data_64_s2[60] ),  .DO61 ( w_data_64_s2[61] ),  .DO62 ( w_data_64_s2[62] ),  .DO63 ( w_data_64_s2[63] ),
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
    .WEB0 ( ~i_WEB_8[0]  ), .WEB1 ( ~i_WEB_8[1]  ), .WEB2 ( ~i_WEB_8[2]  ), .WEB3 ( ~i_WEB_8[3]  ), 
    .WEB4 ( ~i_WEB_8[4]  ), .WEB5 ( ~i_WEB_8[5]  ), .WEB6 ( ~i_WEB_8[6]  ), .WEB7 ( ~i_WEB_8[7]  ), 
    .CK ( i_sramTrig ),
    .CSB  ( ~csb_2 ),
    .OE   ( 1'b1 )
);

SHKB110_4096X8X8CM8 Sram_32KB_3(
    .A0   ( i_addr_14[0]  ),  .A1   ( i_addr_14[1]  ),  .A2  ( i_addr_14[2] ),  .A3  ( i_addr_14[3] ),  .A4  ( i_addr_14[4]   ),  
    .A5   ( i_addr_14[5]  ),  .A6   ( i_addr_14[6]  ),  .A7  ( i_addr_14[7] ),  .A8  ( i_addr_14[8] ),  .A9  ( i_addr_14[9]   ),  
    .A10  ( i_addr_14[10] ),  .A11  ( i_addr_14[11] ),                                   
    .DO0  ( w_data_64_s3[0]  ),  .DO1  ( w_data_64_s3[1]  ),  .DO2  ( w_data_64_s3[2]  ),  .DO3  ( w_data_64_s3[3]  ),  .DO4  ( w_data_64_s3[4]  ), 
    .DO5  ( w_data_64_s3[5]  ),  .DO6  ( w_data_64_s3[6]  ),  .DO7  ( w_data_64_s3[7]  ),  .DO8  ( w_data_64_s3[8]  ),  .DO9  ( w_data_64_s3[9]  ),  
    .DO10 ( w_data_64_s3[10] ),  .DO11 ( w_data_64_s3[11] ),  .DO12 ( w_data_64_s3[12] ),  .DO13 ( w_data_64_s3[13] ),  .DO14 ( w_data_64_s3[14] ), 
    .DO15 ( w_data_64_s3[15] ),  .DO16 ( w_data_64_s3[16] ),  .DO17 ( w_data_64_s3[17] ),  .DO18 ( w_data_64_s3[18] ),  .DO19 ( w_data_64_s3[19] ), 
    .DO20 ( w_data_64_s3[20] ),  .DO21 ( w_data_64_s3[21] ),  .DO22 ( w_data_64_s3[22] ),  .DO23 ( w_data_64_s3[23] ),  .DO24 ( w_data_64_s3[24] ),  
    .DO25 ( w_data_64_s3[25] ),  .DO26 ( w_data_64_s3[26] ),  .DO27 ( w_data_64_s3[27] ),  .DO28 ( w_data_64_s3[28] ),  .DO29 ( w_data_64_s3[29] ),  
    .DO30 ( w_data_64_s3[30] ),  .DO31 ( w_data_64_s3[31] ),  .DO32 ( w_data_64_s3[32] ),  .DO33 ( w_data_64_s3[33] ),  .DO34 ( w_data_64_s3[34] ),
    .DO35 ( w_data_64_s3[35] ),  .DO36 ( w_data_64_s3[36] ),  .DO37 ( w_data_64_s3[37] ),  .DO38 ( w_data_64_s3[38] ),  .DO39 ( w_data_64_s3[39] ),  
    .DO40 ( w_data_64_s3[40] ),  .DO41 ( w_data_64_s3[41] ),  .DO42 ( w_data_64_s3[42] ),  .DO43 ( w_data_64_s3[43] ),  .DO44 ( w_data_64_s3[44] ), 
    .DO45 ( w_data_64_s3[45] ),  .DO46 ( w_data_64_s3[46] ),  .DO47 ( w_data_64_s3[47] ),  .DO48 ( w_data_64_s3[48] ),  .DO49 ( w_data_64_s3[49] ),  
    .DO50 ( w_data_64_s3[50] ),  .DO51 ( w_data_64_s3[51] ),  .DO52 ( w_data_64_s3[52] ),  .DO53 ( w_data_64_s3[53] ),  .DO54 ( w_data_64_s3[54] ),  
    .DO55 ( w_data_64_s3[55] ),  .DO56 ( w_data_64_s3[56] ),  .DO57 ( w_data_64_s3[57] ),  .DO58 ( w_data_64_s3[58] ),  .DO59 ( w_data_64_s3[59] ),  
    .DO60 ( w_data_64_s3[60] ),  .DO61 ( w_data_64_s3[61] ),  .DO62 ( w_data_64_s3[62] ),  .DO63 ( w_data_64_s3[63] ),
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
    .WEB0 ( ~i_WEB_8[0]  ), .WEB1 ( ~i_WEB_8[1]  ), .WEB2 ( ~i_WEB_8[2]  ), .WEB3 ( ~i_WEB_8[3]  ), 
    .WEB4 ( ~i_WEB_8[4]  ), .WEB5 ( ~i_WEB_8[5]  ), .WEB6 ( ~i_WEB_8[6]  ), .WEB7 ( ~i_WEB_8[7]  ), 
    .CK ( i_sramTrig ),
    .CSB  ( ~csb_3 ),
    .OE   ( 1'b1 )
);

endmodule
