//-----------------------------------------------
//    module name: 
//    author: Liang
//  
//    version: 1st version (2021-10-01)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps
module timer_module(

    input  wire        clk,
    input  wire        rst,
    input  wire        we_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,

    output wire [ 4:0]  int_sig_o

    );

    // 寄存器(偏移)地址
    localparam REG_CTRL  = 8'h50;
    localparam REG_COUNT_L = 8'h51;
    localparam REG_COUNT_H = 8'h52;
    localparam REG_VALUE_L = 8'h53;
    localparam REG_VALUE_H = 8'h54;
    localparam REG_MSIP  = 8'h55; 

    // 定时器控制寄存器，可读可写
    // bit[0]: 定时器使能
    // bit[1]: 定时器中断使能
    // bit[2]: 定时器中断pending标志，写1清零
    // bit[3]: 定时器暂停，会停止计数
    reg[31:0] timer_ctrl;

    // 定时器当前计数值寄存器, 只读
    reg[63:0] timer_count;

    // 定时器溢出值寄存器，当定时器计数值达到该值时产生pending，可读可写
    reg[63:0] timer_value;

    // 托管TIMER的MSIP寄存器，写1发中断 0 4 8 c
    reg [31:0] msip_value;
    
    wire wen = we_i ;
    wire ren = (~we_i);
    wire timer_en = (timer_ctrl[0] == 1'b1);
    wire timer_int_en = (timer_ctrl[1] == 1'b1);
    wire timer_expired = (timer_count >= timer_value);
    wire timer_stop = (timer_ctrl[3] == 1'b1);
    wire write_reg_ctrl_en = wen & (addr_i[7:0] == REG_CTRL);
    wire write_reg_value_L_en = wen & (addr_i[7:0] == REG_VALUE_L);
    wire write_reg_value_H_en = wen & (addr_i[7:0] == REG_VALUE_H);
    wire write_reg_msip_en = wen & (addr_i[7:0] == REG_MSIP);

    // 计数
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            timer_count <= 64'h0;
        end else begin
            if (timer_en) begin
                if (timer_expired) begin
                    timer_count <= 64'h0;
                end
                else if(timer_stop) begin
                    timer_count <= timer_count;
                end
                else begin
                    timer_count <= timer_count + 1'b1;
                end
            end else begin
                timer_count <= 64'h0;
            end
        end
    end

    reg int_sig_r;
    // 产生中断信号
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            int_sig_r <= 1'b0;
        end else begin
            if (write_reg_ctrl_en & (data_i[2] == 1'b1)) begin
                int_sig_r <= 1'b0;
            end else if (timer_int_en & timer_en & timer_expired) begin
                int_sig_r <= 1'b1;
            end
        end
    end

    assign int_sig_o = {&msip_value[31:24],&msip_value[23:16],&msip_value[15:8],&msip_value[7:0],int_sig_r};

    // 写timer_ctrl
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            timer_ctrl <= 32'h0;
        end else begin
            if (write_reg_ctrl_en) begin
                timer_ctrl <= {24'b0,data_i[7:3], timer_ctrl[2] & (~data_i[2]), data_i[1:0]};
            end else begin
                if (timer_expired) begin
                    timer_ctrl[0] <= 1'b0;
                end
            end
        end
    end

    // 写timer_value
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            timer_value <= 64'h0;
        end else begin
            if (write_reg_value_L_en) begin
                 timer_value[31:0] <= data_i;
            end
            else if (write_reg_value_H_en) begin
                 timer_value[63:32] <= data_i;
            end
        end
    end
    
// 写timer_value
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            msip_value <= 32'h0;
        end else begin
            if (write_reg_msip_en) begin
                 msip_value <= data_i;
            end
        end
    end

    assign data_o = (addr_i[7:0] == REG_VALUE_L) ?  timer_value[31:0]:
                    (addr_i[7:0] == REG_VALUE_H) ?  timer_value[63:32]:
                    (addr_i[7:0] == REG_CTRL)   ?   timer_ctrl:
                    (addr_i[7:0] == REG_COUNT_L) ?  timer_count[31:0]:
                    (addr_i[7:0] == REG_COUNT_H) ?  timer_count[63:32]:
                    (addr_i[7:0] == REG_MSIP)  ?    msip_value:32'b0;
endmodule