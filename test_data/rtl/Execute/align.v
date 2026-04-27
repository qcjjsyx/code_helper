`timescale 1ns / 1ps
module align (
    oprand,result,rst
);
    input [31:0] oprand;
    input rst;
    output [31:0] result;
    wire [31:0] oprandTmp;
assign oprandTmp = oprand + 4;
assign result = {oprandTmp[31:2],{2{1'b0}}};
endmodule