module adder5 (
    input [4:0] oprand1,
    input [4:0] oprand2,
    input carry_in,
    input symbol,
    output [4:0] result,
    output carry_out,
    output overflow
);
    // 中间信号
   (* dont_touch="true" *) wire [5:0] unsignedSum;  // 5位宽度的无符号加法结果，包括进位位
    (* dont_touch="true" *)wire signed [5:0] signedSum;  // 5位宽度的有符号加法结果，包括进位位

    // 执行加法
    assign unsignedSum = {1'b0, oprand1} + {1'b0, oprand2} + carry_in;
    assign signedSum = $signed({oprand1[4], oprand1}) + $signed({oprand2[4], oprand2}) + $signed({1'b0,carry_in});

    // 根据symbol选择无符号或有符号结果
    assign result = symbol ? unsignedSum[4:0] : signedSum[4:0];

    // 无符号加法的进位输出是 unsignedSum 的第33位
    assign carry_out = symbol ? unsignedSum[5] : 1'b0;

    // 有符号加法的溢出判断
    assign overflow = symbol ? 1'b0 : (oprand1[4] == oprand2[4]) && (oprand1[4] != result[4]);

endmodule
