`timescale 1ns / 1ps

module multiStoreDataUpate(
    input rst,
    //从selector来的脉冲
    input i_fromMutexMerge_1,
    //存数用的地址
    input [31:0] i_address_32,
    //取出哪些寄存器中的数据
    input [15:0] i_registerList_16,
    
    //取的寄存器的值
    output [3:0] o_dHi_4,
    output [3:0] o_dLo_4,
    //读grf的使能信号
    output [1:0] o_wbackWen_2,
    //存数的使能信号
    output [7:0] o_dataRoutWen_8,
    //多字Store结束标志
    output o_endFlag_1,
    //剩余未处理的registerList
    output [15:0] o_nextRegisterList_16,
    //下一个存数地址
    output [31:0] o_nextAddress_32
);
(* dont_touch="true" *)reg [1:0] r_count_2;
(* dont_touch="true" *)reg [15:0] r_registerList_16;
(* dont_touch="true" *)reg [3:0] r_j_4;
(* dont_touch="true" *)reg [3:0] r_k_4;
(* dont_touch="true" *)reg [31:0] r_nextAddress_32;
(* dont_touch="true" *)reg [1:0] num;
integer i;
wire [1:0] w_count_2;
assign w_count_2 = i_address_32[2:0] == 3'b000 ? 2'b10 : (i_address_32[2:0] == 3'b100 ? 2'b01 : 2'b00);
always @(posedge i_fromMutexMerge_1 or negedge rst) begin
    if (!rst) begin
        num =2'b0;
        r_j_4 = 4'b0;
        r_k_4 = 4'b0;
        r_registerList_16 =16'hffff;
        r_nextAddress_32 = 32'b0;
        r_count_2 = 2'b0;
    end else begin
        r_registerList_16 = i_registerList_16;
        r_count_2 = w_count_2;
        // r_count_2 = i_address_32[2:0] == 3'b000 ? 2'b10 : (i_address_32[2:0] == 3'b100 ? 2'b01 : 2'b00);
        num = 2'b0;
        r_j_4 = 4'b0;
        r_k_4 = 4'b0;
        r_nextAddress_32 = i_address_32 + 4 * r_count_2;
        // 处理寄存器列表
        for (i = 0; i < 16; i = i + 1) begin
            if(num < r_count_2)begin
                if (r_registerList_16[i]) begin
                    if (num == 0)begin 
                        r_j_4 = i[3:0]; // Assign the 4-bit binary value of i to r_j_4
                        r_registerList_16[i] = 1'b0;
                        num = num + 1'b1;
                    end
                    else begin
                        r_k_4 = i[3:0]; // Assign the 4-bit binary value of i to r_k_4
                        r_registerList_16[i] = 1'b0;
                        num = num + 1'b1;
                    end
                        
                    
                end   
            end

        end
        // if (r_registerList_16[0] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0000; else r_k_4 = 4'b0000;
        //     r_registerList_16[0] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[1] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0001; else r_k_4 = 4'b0001;
        //     r_registerList_16[1] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[2] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0010; else r_k_4 = 4'b0010;
        //     r_registerList_16[2] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[3] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0011; else r_k_4 = 4'b0011;
        //     r_registerList_16[3] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[4] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0100; else r_k_4 = 4'b0100;
        //     r_registerList_16[4] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[5] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0101; else r_k_4 = 4'b0101;
        //     r_registerList_16[5] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[6] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0110; else r_k_4 = 4'b0110;
        //     r_registerList_16[6] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[7] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b0111; else r_k_4 = 4'b0111;
        //     r_registerList_16[7] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[8] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1000; else r_k_4 = 4'b1000;
        //     r_registerList_16[8] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[9] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1001; else r_k_4 = 4'b1001;
        //     r_registerList_16[9] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[10] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1010; else r_k_4 = 4'b1010;
        //     r_registerList_16[10] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[11] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1011; else r_k_4 = 4'b1011;
        //     r_registerList_16[11] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[12] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1100; else r_k_4 = 4'b1100;
        //     r_registerList_16[12] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[13] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1101; else r_k_4 = 4'b1101;
        //     r_registerList_16[13] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[14] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1110; else r_k_4 = 4'b1110;
        //     r_registerList_16[14] = 1'b0;
        //     num = num + 1'b1;
        // end
        // if (r_registerList_16[15] && num < r_count_2) begin
        //     if (num == 0) r_j_4 = 4'b1111; else r_k_4 = 4'b1111;
        //     r_registerList_16[15] = 1'b0;
        //     num = num + 1'b1;
        // end


    end
end

assign o_dHi_4 = r_k_4;
assign o_dLo_4 = r_j_4;
assign o_wbackWen_2 = num == 2'b01 ? 2'b01 : (num == 2'b10 ? 2'b11 : 2'b00);
assign o_endFlag_1 = (|r_registerList_16) == 0 ? 1'b1 : 1'b0;
assign o_nextAddress_32 = r_nextAddress_32;
assign o_dataRoutWen_8 = num == 2'b10 ?  8'b1111_1111 : 
                        (num==2'b01 ? 
                        (r_count_2 == 2'b10 ? 8'b0000_1111 : 8'b1111_0000) : 8'b0);
assign o_nextRegisterList_16 = r_registerList_16;
endmodule
