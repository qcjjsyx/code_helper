`timescale 1ns / 1ps
module adder32 (
    input [31:0] oprand1,
    input [31:0] oprand2,
    input carry_in,
    input symbol,
    output [31:0] result,
    output carry_out,
    output overflow
);
    // 中间信号
    (* dont_touch="true" *) wire [32:0] unsignedSum;  // 33位宽度的无符号加法结果，包括进位位
    (* dont_touch="true" *) wire signed [32:0] signedSum;  // 33位宽度的有符号加法结果，包括进位位

    // 执行加法
    assign unsignedSum = {1'b0, oprand1} + {1'b0, oprand2} + carry_in;
    assign signedSum = $signed({oprand1[31],oprand1}) + $signed({oprand2[31],oprand2}) +  $signed({1'b0,carry_in});

    // 根据symbol选择无符号或有符号结果
    assign result = symbol ? unsignedSum[31:0] : signedSum[31:0];

    // 无符号加法的进位输出是 unsignedSum 的第33位
    assign carry_out = symbol ? unsignedSum[32] : 1'b0;

    // 有符号加法的溢出判断
    assign overflow = symbol ? 1'b0 : (oprand1[31] == oprand2[31]) && (oprand1[31] != result[31]);

endmodule
