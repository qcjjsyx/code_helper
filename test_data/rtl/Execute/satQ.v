`timescale 1ns / 1ps
module satQ (
    i_oprand1_32,i_oprand2_32,i_satQSymbolFlag_1,o_saQResult_32,sat,rst
);
    input rst;
    output sat;
    input signed [31:0] i_oprand1_32;
    input [31:0] i_oprand2_32;
    input i_satQSymbolFlag_1;
    output signed [31:0] o_saQResult_32;
//SignedSatQ
(* dont_touch="true" *)wire signed [31:0] w_saturated1_32;
(* dont_touch="true" *)wire signed [31:0] w_maxOprand1_32;
wire w_sat1_1;
assign w_maxOprand1_32 = i_oprand1_32 > $signed(-(1<<(i_oprand2_32[5:0]-1))) ? i_oprand1_32 : $signed(-(1<<(i_oprand2_32[5:0]-1)));
assign w_saturated1_32 = w_maxOprand1_32 > $signed(1<<(i_oprand2_32[5:0] - 1)-1) ? $signed(1<<(i_oprand2_32[5:0] - 1)-1) : w_maxOprand1_32;
assign w_sat1_1 =( i_oprand1_32 < $signed(-(1<<(i_oprand2_32[5:0]-1))) ) || (i_oprand1_32 >= 1<<(i_oprand2_32[5:0] - 1));

//UnsignedSatQ
(* dont_touch="true" *)wire signed [31:0] w_satuarted2_32;
(* dont_touch="true" *)wire signed [31:0] w_maxOprand2_32;
wire w_sat2_1;
assign w_maxOprand2_32 = i_oprand1_32 > 0 ? i_oprand1_32 : 0;
assign w_satuarted2_32 = w_maxOprand2_32 > ((1<<i_oprand2_32[5:0]) - 1) ? (1<<i_oprand2_32[5:0]) - 1 : w_maxOprand2_32;
assign w_sat2_1 = (i_oprand1_32 < 0) || (i_oprand1_32 >= 1<<i_oprand2_32[5:0]);

assign o_saQResult_32 = i_satQSymbolFlag_1 == 1'b1 ? w_saturated1_32 : w_satuarted2_32;
assign sat = i_satQSymbolFlag_1 == 1'b1 ? w_sat1_1 : w_sat2_1;
endmodule