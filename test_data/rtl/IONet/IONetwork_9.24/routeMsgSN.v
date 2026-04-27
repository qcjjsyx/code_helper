//-----------------------------------------------
//    module name: routeMsgSN
//    author: Anping HE (heap@lzu.edu.cn)
//    version: 1st version (2021-11-07)
//    description: 
//        corrdination = corrdination -1;
//        trim a message that will pass to next dir
//-----------------------------------------------

`timescale 1ns / 1ps

module routeMsgSN(i_coord_4, o_msgVld);

input [3:0] i_coord_4;

// output [31:0] o_msg_32;
output o_msgVld;

//  wire [3:0] distance;

//calculate the distance
// subtr4b sub (
//     .a(i_coord_4),
//     .b(4'b0001),
//     .differ(distance)
// );

assign o_msgVld = i_coord_4[3]|i_coord_4[2]|i_coord_4[1]|i_coord_4[0];

// assign    o_msg_32 = (o_msgVld ==1) ? 
//         {i_msg_32[31:4], distance} : 32'b0;


endmodule
