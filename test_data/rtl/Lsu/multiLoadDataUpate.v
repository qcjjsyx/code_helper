`timescale 1ns / 1ps

module multiLoadDataUpate(
    input rst,
    //从datarout来的脉冲
    input i_fromDataRout_1,
    //从datarout来的数据
    input [63:0] i_fromDataRoutData_64,
    //取数用的地址
    input [31:0] i_address_32,
    //加载入哪些寄存器中
    input [15:0] i_registerList_16,
    
    //回写的寄存器的值
    output [3:0] o_dHi_4,
    output [3:0] o_dLo_4,
    //回写的数据
    output [63:0] o_wbackData_64,
    //回写的使能信号
    output [1:0] o_wbackWen_2,
    //多字load结束标志
    output o_endFlag_1,
    //剩余未处理的registerList
    output [15:0] o_nextRegisterList_16,
    //下一个取数地址
    output [31:0] o_nextAddress_32
);
(* dont_touch="true" *)reg [1:0] r_count_2;
(* dont_touch="true" *)reg [15:0] r_registerList_16;
(* dont_touch="true" *)reg [3:0] r_j_4;
(* dont_touch="true" *)reg [3:0] r_k_4;
(* dont_touch="true" *)reg [31:0] r_nextAddress_32;

(* dont_touch="true" *)reg[3:0] num;
always @(posedge i_fromDataRout_1 or negedge rst) begin
    if (!rst) begin
        num=4'b0;
        r_j_4 = 4'b0;
        r_k_4 = 4'b0;
        r_registerList_16 = 16'hffff;
        r_nextAddress_32 = 32'b0;
    end else begin
        r_registerList_16 = i_registerList_16;
        r_count_2 = i_address_32[2:0] == 3'b000 ? 2'b10 : (i_address_32[2:0] == 3'b100 ? 2'b01 : 2'b00);
        num = 4'b0;
        r_j_4 = 4'b0;
        r_k_4 = 4'b0;
        // 处理寄存器列表
        if (r_registerList_16[0] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0000; else r_k_4 = 4'b0000;
            r_registerList_16[0] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[1] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0001; else r_k_4 = 4'b0001;
            r_registerList_16[1] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[2] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0010; else r_k_4 = 4'b0010;
            r_registerList_16[2] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[3] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0011; else r_k_4 = 4'b0011;
            r_registerList_16[3] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[4] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0100; else r_k_4 = 4'b0100;
            r_registerList_16[4] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[5] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0101; else r_k_4 = 4'b0101;
            r_registerList_16[5] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[6] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0110; else r_k_4 = 4'b0110;
            r_registerList_16[6] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[7] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b0111; else r_k_4 = 4'b0111;
            r_registerList_16[7] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[8] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1000; else r_k_4 = 4'b1000;
            r_registerList_16[8] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[9] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1001; else r_k_4 = 4'b1001;
            r_registerList_16[9] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[10] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1010; else r_k_4 = 4'b1010;
            r_registerList_16[10] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[11] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1011; else r_k_4 = 4'b1011;
            r_registerList_16[11] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[12] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1100; else r_k_4 = 4'b1100;
            r_registerList_16[12] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[13] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1101; else r_k_4 = 4'b1101;
            r_registerList_16[13] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[14] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1110; else r_k_4 = 4'b1110;
            r_registerList_16[14] = 1'b0;
            num = num + 1'b1;
        end
        if (r_registerList_16[15] && num < r_count_2) begin
            if (num == 0) r_j_4 = 4'b1111; else r_k_4 = 4'b1111;
            r_registerList_16[15] = 1'b0;
            num = num + 1'b1;
        end
        
        r_nextAddress_32 = i_address_32 + 4 * r_count_2;
    end
end
assign o_dHi_4 = r_k_4;
assign o_dLo_4 = r_j_4;
assign o_wbackData_64 = num==2'b10 ? i_fromDataRoutData_64 : 
                       (num==2'b01 ? (r_count_2 == 2'b10 ? 
                       {32'b0,i_fromDataRoutData_64[31:0]}: {32'b0,i_fromDataRoutData_64[63:32]}):64'b0);
assign o_wbackWen_2 = num == 2'b01 ? 2'b01 : (num == 2'b10  ? 2'b11 : 2'b00);
assign o_endFlag_1 = (|r_registerList_16) == 0 ? 1'b1 : 1'b0;
assign o_nextAddress_32 = r_nextAddress_32;
assign o_nextRegisterList_16 = r_registerList_16;
endmodule
