`timescale 1ns / 1ps
module adder (
    i_oprand1_64,i_oprand2_64,i_adderType_2,i_carryInType_1,i_addSymbolFlag_1,o_adderResult_64,o_adderCarryOut_1,o_adderOverFlow_1,rst
);
    input rst;
    input [1:0] i_adderType_2;
    input i_carryInType_1;
    input i_addSymbolFlag_1;
    input [63:0] i_oprand1_64;
    input [63:0] i_oprand2_64;
    output o_adderCarryOut_1;
    output o_adderOverFlow_1;
    output [63:0] o_adderResult_64;



(* dont_touch="true" *)wire [31:0] w_oprand1_32;
(* dont_touch="true" *)wire [31:0] w_oprand2_32;
(* dont_touch="true" *)wire [4:0] w_oprand1_5;
(* dont_touch="true" *)wire [4:0] w_oprand2_5;

assign w_oprand1_32 = i_oprand1_64[31:0];
assign w_oprand2_32 = i_oprand2_64[31:0];
assign w_oprand1_5 = i_oprand1_64[31:0];
assign w_oprand2_5 = i_oprand2_64[31:0];

(* dont_touch="true" *)wire [4:0] w_adder5Result_5;
(* dont_touch="true" *)wire w_adder5CarryOut_1;
(* dont_touch="true" *)wire w_adder5OverFlow_1;

(* dont_touch="true" *)wire [31:0] w_adder32Result_32;
(* dont_touch="true" *)wire w_adder32CarryOut_1;
(* dont_touch="true" *)wire w_adder32OverFlow_1;

(* dont_touch="true" *)wire [63:0] w_adder64Result_64;
(* dont_touch="true" *)wire w_adder64CarryOut_1;
(* dont_touch="true" *)wire w_adder64OverFlow_1;

adder5 adder5(
.oprand1(w_oprand1_5),.oprand2(w_oprand2_5),.carry_in(i_carryInType_1),.symbol(i_addSymbolFlag_1),.result(w_adder5Result_5),.carry_out(w_adder5CarryOut_1),.overflow(w_adder5OverFlow_1)
);
adder32 adder32(.oprand1(w_oprand1_32),.oprand2(w_oprand2_32),.symbol(i_addSymbolFlag_1),.carry_in(i_carryInType_1),.result(w_adder32Result_32),.carry_out(w_adder32CarryOut_1),.overflow(w_adder32OverFlow_1)
);
adder64 adder64(.oprand1(i_oprand1_64),.oprand2(i_oprand2_64),.symbol(i_addSymbolFlag_1),.carry_in(i_carryInType_1),.result(w_adder64Result_64),.carry_out(w_adder64CarryOut_1),.overflow(w_adder64OverFlow_1)
);


assign o_adderResult_64 = i_adderType_2 == 2'b00 ? w_adder32Result_32 : (i_adderType_2==2'b01 ? w_adder5Result_5 :(i_adderType_2 == 2'b10 ? w_adder64Result_64 : 64'b0));
assign o_adderCarryOut_1 = i_adderType_2 == 2'b00 ? w_adder32CarryOut_1 : (i_adderType_2==2'b01 ? w_adder5CarryOut_1 :(i_adderType_2 == 2'b10 ? w_adder64CarryOut_1 : 1'b0));
assign o_adderOverFlow_1 = i_adderType_2 == 2'b00 ? w_adder32OverFlow_1 : (i_adderType_2==2'b01 ? w_adder5OverFlow_1 :(i_adderType_2 == 2'b10 ? w_adder64OverFlow_1 : 1'b0));
endmodule 