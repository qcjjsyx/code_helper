`timescale 1ns / 1ps
module orrer (
    oprand1,oprand2,result,rst
);
    input [31:0] oprand1;
    input [31:0] oprand2;
    output [31:0] result;
    input rst;
    
    assign result = oprand1 | oprand2;
endmodule