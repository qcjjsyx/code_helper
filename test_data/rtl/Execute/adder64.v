module adder64 (
    input [63:0] oprand1,
    input [63:0] oprand2,
    input carry_in,
    input symbol,
    output [63:0] result,
    output carry_out,
    output overflow
);
    // 中间信号
   (* dont_touch="true" *) wire [64:0] unsignedSum;  // 65位宽度的无符号加法结果，包括进位位
    (* dont_touch="true" *)wire signed [64:0] signedSum;  // 65位宽度的有符号加法结果，包括进位位

    // 执行加法
    assign unsignedSum = {1'b0, oprand1} + {1'b0, oprand2} + carry_in;
    assign signedSum = $signed({oprand1[63], oprand1}) + $signed({oprand2[63], oprand2}) + $signed({1'b0,carry_in});

    // 根据symbol选择无符号或有符号结果
    assign result = symbol ? unsignedSum[63:0] : signedSum[63:0];

    // 无符号加法的进位输出是 unsignedSum 的第33位
    assign carry_out = symbol ? unsignedSum[64] : 1'b0;

    // 有符号加法的溢出判断
    assign overflow = symbol ? 1'b0 : (oprand1[63] == oprand2[63]) && (oprand1[63] != result[63]);

endmodule
