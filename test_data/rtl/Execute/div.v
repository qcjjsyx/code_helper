`timescale 1ns / 1ps

module div (
    input [31:0] oprand1,
    input [31:0] oprand2,
    input symbolFlag,
    input rst,
    output reg [31:0] result
);

// 声明内部寄存器
reg [31:0] unsigned_result;
reg [31:0] signed_result;

always @(*) begin
    // 检查复位信号
    if (!rst) begin
        result = 32'd0; // 复位时结果为0
    end else if (oprand2 == 32'd0) begin
        result = 32'd0; // 除数为零时结果为0
    end else begin
        // 计算无符号除法结果
        unsigned_result = oprand1 / oprand2;
        // 计算有符号除法结果
        signed_result = $signed(oprand1) / $signed(oprand2);
        // 根据符号标志选择结果
        result = symbolFlag ? unsigned_result : signed_result;
    end
end

endmodule