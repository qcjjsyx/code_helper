`timescale 1ns / 1ps
module ander (
    oprand1,oprand2,result,rst
);
    input [31:0] oprand1;
    input [31:0] oprand2;
    input rst;
    output [31:0] result;
assign result = oprand1 & oprand2;
endmodule