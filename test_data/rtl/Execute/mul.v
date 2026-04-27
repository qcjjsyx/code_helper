`timescale 1ns / 1ps
module muller (
    i_oprand1_32,i_oprand2_32,i_notFlag_1,i_mulSymbolFlag_1,o_result_64,rst
);
    input rst;
    input [31:0] i_oprand1_32;
    input [31:0] i_oprand2_32;
    input i_notFlag_1;
    input i_mulSymbolFlag_1;
    output [63:0] o_result_64;

    wire signed [63:0] w_resultSignedTmp_64; 
    wire [63:0] w_resultUnsignedTmp_64;
    wire [63:0] w_resultTmp_64;
    assign w_resultSignedTmp_64 = (i_oprand1_32 == 32'b0 | i_oprand2_32 == 32'b0 ) ? 64'b0 : $signed(i_oprand1_32)*$signed(i_oprand2_32);
    assign w_resultUnsignedTmp_64 = (i_oprand1_32 == 32'b0 | i_oprand2_32 == 32'b0 ) ? 64'b0 : i_oprand1_32 * i_oprand2_32;
    assign w_resultTmp_64 = i_mulSymbolFlag_1 ==1'b1 ? w_resultUnsignedTmp_64 : w_resultSignedTmp_64;
    assign o_result_64 = i_notFlag_1 == 1'b1 ? ~w_resultTmp_64 : w_resultTmp_64;
endmodule