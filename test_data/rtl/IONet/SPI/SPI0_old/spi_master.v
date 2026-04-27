`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/09 17:19:49
// Design Name: 
// Module Name: tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_master
(
output sclk_out,
output nss_out,
input clk,
input rst_n,
input DR_w,
input [31:0]data_in,
input rx,
input DR_r,
input [7:0]ADDR,
input r_enT,
output reg [31:0]data_out,
output reg RXNE,
output reg tx,
output tx_done,
output rx_done
    );
    
//localparam
localparam DISABLE = 2'b00;
localparam WAIT = 2'b01;
localparam SEND = 2'b10;
localparam CRCSEND = 2'b11;
//reg and wire
wire [2:0]BR = ADDR[4:2];
wire CPOL = ADDR[1];
wire CPHA = ADDR[0];
wire sclk_out_div;//分频输出
wire sclk_m_div;//分频输出
wire sclk_m = CPHA ? ~sclk_m_div : sclk_m_div;//主机时钟驱动
assign sclk_out = CPOL ? ~sclk_out_div : sclk_out_div;//主机时钟输出
(*dont_touch = "yes"*)wire M_en = 1'b1;

(*dont_touch = "yes"*)reg [5:0]tx_cnt;
//reg [4:0]crc_cnt;
(*dont_touch = "yes"*)reg [5:0]rx_cnt;
                       reg [31:0]data_shift_tx;
(*dont_touch = "yes"*)reg TXE;
                       reg [31:0]data_shift_rx;
//                       wire tx_done;
                        //wire crc_done;
//                        wire rx_done;
                        reg cnt_buf_tx;
                      //reg cnt_buf_crc;
                      reg cnt_buf_rx;
                     //reg crc_en;
(*dont_touch = "yes"*)reg enable;
(*dont_touch = "yes"*)reg [1:0] state;
//assign busy = enable;

/*************clk_div***************/

clk_div clk_div_u(
.clk     (clk     ),
.rst_n   (rst_n   ),
.M_en    (enable    ),
.BR      (BR      ),
.nss_out (nss_out ),
.sclk_m  (sclk_m_div  ),
.sclk_out(sclk_out_div)
);

/***************************receive*******************************/
//rx_cnt
always@(posedge sclk_m or negedge rst_n) begin 
    if(!rst_n) begin
        rx_cnt <= 6'b0;
    end
    else if(!nss_out)begin
        if(rx_cnt >= 6'd32) rx_cnt <= 6'b0;
        else rx_cnt <= rx_cnt+1;
    end
    else begin
        rx_cnt <= 6'b0;
    end
end

//data receive
always@(posedge sclk_m or negedge rst_n) begin
    if(!rst_n) data_shift_rx <= 32'b0; 
    else if(M_en & rx_cnt != 6'b0) begin
        data_shift_rx[32-rx_cnt] <= rx;
    end
    else data_shift_rx <= 32'b0; 
end

//数据传输检测
//always @(posedge clk)
//begin
//    if(DFF) cnt_buf_rx <= rx_cnt[4];
//    else cnt_buf_rx <= rx_cnt[3];
//end
//assign rx_done = DFF ? ((~rx_cnt[4]) & cnt_buf_rx) : ((~rx_cnt[3]) & cnt_buf_rx);

always @(posedge clk)
begin
    cnt_buf_rx <= rx_cnt[5];
end
assign rx_done = (~rx_cnt[5]) & cnt_buf_rx;

////data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_out <= 32'b0;
    else if(rx_done & (!RXNE)) begin
        data_out <= data_shift_rx;
    end
    else data_out <= data_out;
end

//RXNE标志
always@( posedge clk or negedge rst_n)
begin
    if(!rst_n) RXNE <= 1'b0;
    else if(!r_enT) RXNE <= 1'b0;
    else if(DR_r) RXNE <= 1'b0;
    else if(rx_done) RXNE <= 1'b1;
end

/**********************************send******************************/
//data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_shift_tx <= 32'b0;
    else if(M_en) begin
        if(!TXE & state == WAIT) data_shift_tx <= data_in;
        else if(tx_done) data_shift_tx <= 32'b0;
        else data_shift_tx <= data_shift_tx;
    end
    else data_shift_tx <= 32'b0;
end

//TXE
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    TXE<=1'b1;
	else if(DR_w)
	TXE<=1'b0; 
	else if(enable)
	TXE<=1'b1;
	else TXE <= TXE;
end

//tx_cnt
always@(negedge sclk_m or negedge rst_n) begin 
    if(!rst_n) begin
        tx_cnt <= 6'b0;
    end
    else if(enable)begin
        if(CPHA) begin
            if(tx_cnt >= 6'd32) tx_cnt <= 6'b0;
            else tx_cnt <= tx_cnt+1;
        end
        else begin
            if(tx_cnt >= 6'd31) tx_cnt <= 6'b0;
            else tx_cnt <= tx_cnt+1;
        end
    end
    else begin
        tx_cnt <= 6'b0;
    end
end

//data send
always@(negedge sclk_m or negedge rst_n) begin
    if(!rst_n) tx <= 1'b0; 
    else if(enable) begin
        if(CPHA) begin
            tx <= data_shift_tx[32-tx_cnt];
        end
        else begin
            tx <= data_shift_tx[31-tx_cnt];
        end
    end
    else tx <= 1'b0;
end

//数据传输检测
always @(posedge clk)
begin
    if(CPHA)cnt_buf_tx <= tx_cnt[5];
    else cnt_buf_tx <= tx_cnt[4];
end
assign tx_done = CPHA ? (~tx_cnt[5]) & cnt_buf_tx :  (~tx_cnt[4]) & cnt_buf_tx ;

//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
        enable <= 1'b0;
    end
    else begin
        case(state)
        DISABLE: begin
            enable <= 1'b0;
            if(M_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            if(M_en) begin
                if(TXE) begin
                    enable <= 1'b0;
                    state <= WAIT;
                end
                else begin
                    enable <= 1'b1;
                    state <= SEND;
                end
            end
            else state <= DISABLE;
        end
        SEND: begin
            if(M_en) begin
//                if(!CPHA) begin
                    if(tx_done) begin
                        enable <= 1'b0;
                        state <= WAIT;
                    end
                    else begin
                        enable <= 1'b1;
                        state <= SEND;
                    end
//                end
//                else begin
//                    if(rx_done) begin
//                        enable <= 1'b0;
//                        state <= WAIT;
//                    end
//                    else begin
//                        enable <= 1'b1;
//                        state <= SEND;
//                    end
//                end
            end
            else state <= DISABLE;
        end
        default: begin
            state <= DISABLE;
        end
        endcase
    end
end
endmodule