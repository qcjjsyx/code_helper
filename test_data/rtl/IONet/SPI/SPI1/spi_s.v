`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 20:25:31
// Design Name: 
// Module Name: tx_s
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


module spi_s
(
input sclk,
input clk,
input rst_n,
input S_en,
input DR_w,
input DFF,
input [15:0]data_in,
input LSBFIRST,
input rx,
input DR_r,
input rxonly,
input CRC_next,
input [15:0]TXCRC,
input CPHA,
output reg [15:0]data_out,
output reg TXE,
output  busy,
output reg OVR,
output reg RXNE,
output reg enable,
output reg crc_en,
output tx
    );

//localparam
localparam DISABLE = 2'b00;
localparam WAIT = 2'b01;
localparam SEND = 2'b11;
localparam CRCSEND = 2'b10;
//reg and wire
reg [3:0]tx_cnt;
reg [3:0]crc_cnt;
reg [3:0]rx_cnt;
reg [15:0]data_shift_tx;
reg [15:0]data_shift_rx;
wire tx_done;
wire crc_done;
wire rx_done;
//reg [2:0] cnt_buf_tx;
reg cnt_buf_tx;
reg cnt_buf_crc;
reg cnt_buf_rx;
//reg crc_en;
wire sclk_rise;
reg sclk_buf;
reg tx_reg0;
reg tx_reg;

//reg enable;
reg [1:0] state;
assign busy = enable | !TXE | crc_en;
assign tx = rxonly ? 1'b0 :(CPHA ? tx_reg :((tx_cnt == 4'b0) ? tx_reg0 : tx_reg));
/***************************receive*******************************/
//rx_cnt
always@(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        rx_cnt <= 4'b0;
    end
    else if(S_en)begin
        if(sclk_rise) begin
            if(!DFF & rx_cnt >= 4'd7) rx_cnt <= 4'b0;
            else rx_cnt <= rx_cnt+1;
        end
        else rx_cnt <= rx_cnt;
    end
    else begin
        rx_cnt <= 4'b0;
    end
end

//data receive
always@(posedge sclk or negedge rst_n) begin
    if(!rst_n) data_shift_rx <= 16'b0; 
    else if(S_en) begin
        if(LSBFIRST) begin
            data_shift_rx[rx_cnt] <= rx;
        end
        else begin
            if(DFF) data_shift_rx[15-rx_cnt] <= rx;
            else data_shift_rx[7-rx_cnt] <= rx;
        end
    end
end

//数据传输检测
always @(posedge clk)
begin
    if(DFF) cnt_buf_rx <= rx_cnt[3];
    else cnt_buf_rx <= rx_cnt[2];
end
assign rx_done = DFF ? ((~rx_cnt[3]) & cnt_buf_rx) : ((~rx_cnt[2]) & cnt_buf_rx);

////data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_out <= 'b0;
    else if(rx_done & (!RXNE)) begin
        data_out <= data_shift_rx;
    end
    else data_out <= data_out;
end

//RXNE标志
always@( posedge clk or negedge rst_n)
begin
    if(!rst_n) RXNE <= 1'b0;
    else if(DR_r) RXNE <= 1'b0;
    else if(rx_done) RXNE <= 1'b1;
end

//OVR
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) OVR <= 1'b0;
    else if(rx_done) begin
        if(RXNE) OVR <= 1'b1;
        else OVR <= 1'b0;
    end
    else OVR <= OVR;
end
/**********************************send******************************/
//data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_shift_tx <= 'b0;
    else if(S_en) begin
        if(!TXE & state == WAIT) data_shift_tx <= data_in;
        else if(tx_done) data_shift_tx <= 'b0;
        else data_shift_tx <= data_shift_tx;
    end
    else data_shift_tx <= 'b0;
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
always@(negedge sclk or negedge rst_n) begin 
    if(!rst_n) begin
        tx_cnt <= 4'b0;
    end
    else if(S_en)begin
        if(!DFF & tx_cnt >= 3'b111) tx_cnt <= 4'b0;
        else tx_cnt <= tx_cnt+1;
    end
    else begin
        tx_cnt <= 4'b0;
    end
end

//data send

always@(*) begin
    if(!rst_n) tx_reg0 = 1'b0;
    else if(crc_en & crc_cnt == 4'b0) begin
        case ({CPHA,LSBFIRST,DFF}) 
        3'b000: tx_reg0 = TXCRC[7];
        3'b001: tx_reg0 = TXCRC[15];
        3'b010,3'b011: tx_reg0 = TXCRC[0];
        default: tx_reg0 = 1'b0;
        endcase
    end
    else if(S_en & tx_cnt == 4'b0) begin
        case ({CPHA,LSBFIRST,DFF}) 
        3'b000: tx_reg0 = data_in[7];
        3'b001: tx_reg0 = data_in[15];
        3'b010,3'b011: tx_reg0 = data_in[0];
        default: tx_reg0 = 1'b0;
        endcase
    end
    else tx_reg0 = 1'b0;
    
end

always@(negedge sclk) begin
    if(CPHA) begin
        if(S_en) begin
            if(LSBFIRST) tx_reg <= data_shift_tx[tx_cnt];
            else begin
                if(DFF) tx_reg <= data_shift_tx[15-tx_cnt];
                else tx_reg <= data_shift_tx[7-tx_cnt];
            end
        end
        else if(crc_en) begin
            if(LSBFIRST) tx_reg <= TXCRC[crc_cnt];
            else begin
                if(DFF) tx_reg <= TXCRC[15-crc_cnt];
                else tx_reg <= TXCRC[7-crc_cnt];
            end
        end
        else tx_reg <= 1'b0;
    end
    else begin
        if(enable) begin
            if(LSBFIRST) begin
                if(tx_cnt != 4'd15) tx_reg <= data_shift_tx[tx_cnt+1];
                else tx_reg <= 1'b0;
            end
            else begin
                if(DFF & tx_cnt != 4'd15) tx_reg <= data_shift_tx[14-tx_cnt];
                else if (!DFF & tx_cnt != 4'd7) tx_reg <= data_shift_tx[6-tx_cnt];
                else tx_reg <= 1'b0;
            end
        end
        else if(crc_en) begin
            if(LSBFIRST) begin
                if(crc_cnt != 4'd15) tx_reg <= TXCRC[crc_cnt+1];
                else tx_reg <= 1'b0;
            end
            else begin
                if(DFF & crc_cnt != 4'd15) tx_reg <= TXCRC[14-crc_cnt];
                else if (!DFF & crc_cnt != 4'd7) tx_reg <= TXCRC[6-crc_cnt];
                else tx_reg <= 1'b0;
            end
        end
        else tx_reg <= 1'b0;
    end
end

//数据传输检测
always @(posedge clk)
begin
    if(DFF) cnt_buf_tx <= tx_cnt[3];
    else cnt_buf_tx <= tx_cnt[2];
end
assign tx_done = DFF ? ((~tx_cnt[3]) & cnt_buf_tx) : ((~tx_cnt[2]) & cnt_buf_tx);

//sclk 检测
always @(posedge clk)
begin
    sclk_buf <= sclk;
//   sclk_rise <= (~sclk) & sclk_buf;
end
assign sclk_rise = S_en ? (~sclk_buf) & sclk : 1'b0;

//crc_cnt
always@(negedge sclk or negedge rst_n) begin 
    if(!rst_n) begin
        crc_cnt <= 4'b0;
    end
    else if(crc_en)begin
        if(!DFF & crc_cnt >= 3'b111) crc_cnt <= 4'b0;
        else crc_cnt <= crc_cnt+1;
    end
    else begin
        crc_cnt <= 4'b0;
    end
end

//CRC数据传输检测
always @(posedge clk)
begin
    if(DFF) cnt_buf_crc <= crc_cnt[3];
    else cnt_buf_crc <= crc_cnt[2];
end
assign crc_done = DFF ? ((~crc_cnt[3]) & cnt_buf_crc) : ((~crc_cnt[2]) & cnt_buf_crc);

//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
        enable <= 1'b0;
        crc_en <= 1'b0;
    end
    else begin
        case(state)
        DISABLE: begin
            enable <= 1'b0;
            crc_en <= 1'b0;
            if(S_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            crc_en <= 1'b0;
            if(S_en) begin
                if(!sclk_rise) begin
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
            if(S_en) begin
                if(rx_done) begin
                    enable <= 1'b0;
                    if(CRC_next) begin
                        crc_en <= 1'b1;
                        state <= CRCSEND;
                    end
                    else state <= WAIT;
                end
                else begin
                    enable <= 1'b1;
                    state <= SEND;
                end
            end
            else state <= DISABLE;
        end
        CRCSEND: begin
            enable <= 1'b0;
            if(rx_done) begin
                crc_en <= 1'b0;
                state <= WAIT;
            end
            else begin
                crc_en <= 1'b1;
                state <= CRCSEND;
            end
        end
        default: begin
            state <= DISABLE;
            enable <= 1'b0;
            crc_en <= 1'b0;
        end
        endcase
    end
end
endmodule
