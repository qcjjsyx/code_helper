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


module spi_m
(
input sclk,
input clk,
input rst_n,
input M_en,
input DR_w,
input DFF,
input [15:0]data_in,
input LSBFIRST,
input rx,
input DR_r,
input CRC_next,
input rxonly,
input [15:0]TXCRC,
input CPHA,
output reg [15:0]data_out,
output reg TXE,
output reg OVR,
output  busy,
output reg RXNE,
output reg enable,
output reg crc_en,
output reg tx
    );
//localparam
localparam DISABLE = 2'b00;
localparam WAIT = 2'b01;
localparam SEND = 2'b10;
localparam CRCSEND = 2'b11;
//reg and wire
reg [4:0]tx_cnt;
reg [4:0]crc_cnt;
reg [4:0]rx_cnt;
reg [15:0]data_shift_tx;
reg [15:0]data_shift_rx;
wire tx_done;
wire crc_done;
wire rx_done;
reg cnt_buf_tx;
reg cnt_buf_crc;
reg cnt_buf_rx;
//reg crc_en;
//reg enable;
reg [1:0] state;
assign busy = enable | !TXE | crc_en;
/***************************receive*******************************/
//rx_cnt
always@(posedge sclk or negedge rst_n) begin 
    if(!rst_n) begin
        rx_cnt <= 5'b0;
    end
    else if(M_en)begin
        if(!DFF & rx_cnt >= 5'd8) rx_cnt <= 5'b0;
        else if(DFF & rx_cnt >= 5'd16) rx_cnt <= 5'b0;
        else rx_cnt <= rx_cnt+1;
    end
    else begin
        rx_cnt <= 5'b0;
    end
end

//data receive
always@(posedge sclk or negedge rst_n) begin
    if(!rst_n) data_shift_rx <= 16'b0; 
    else if(M_en & rxonly) begin
        if(LSBFIRST) begin
            data_shift_rx[rx_cnt] <= rx;
        end
        else begin
            if(DFF) data_shift_rx[15-rx_cnt] <= rx;
            else data_shift_rx[7-rx_cnt] <= rx;
        end
    end
    else if(M_en & rx_cnt != 5'b0) begin
        if(LSBFIRST) begin
            data_shift_rx[rx_cnt-1] <= rx;
        end
        else begin
            if(DFF) data_shift_rx[16-rx_cnt] <= rx;
            else data_shift_rx[8-rx_cnt] <= rx;
        end
    end
    else data_shift_rx <= 16'b0; 
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
    case({rxonly,DFF})
    2'b10: cnt_buf_rx <= rx_cnt[2];
    2'b00,2'b11: cnt_buf_rx <= rx_cnt[3];
    2'b01: cnt_buf_rx <= rx_cnt[4];
    default: cnt_buf_rx <= 1'b0;
    endcase
end
assign rx_done = (rxonly^DFF) ? (DFF ? ((~rx_cnt[4]) & cnt_buf_rx) : (~rx_cnt[2]) & cnt_buf_rx) : ((~rx_cnt[3]) & cnt_buf_rx) ;

////data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_out <= 16'b0;
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
    if(!rst_n) data_shift_tx <= 16'b0;
    else if(M_en) begin
        if(!TXE & state == WAIT) data_shift_tx <= data_in;
        else if(tx_done) data_shift_tx <= 16'b0;
        else data_shift_tx <= data_shift_tx;
    end
    else data_shift_tx <= 16'b0;
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
        tx_cnt <= 5'b0;
    end
    else if(enable)begin
        if(CPHA) begin
            if(!DFF & tx_cnt >= 5'd8) tx_cnt <= 5'b0;
            else if(DFF & tx_cnt >= 5'd16) tx_cnt <= 5'b0;
            else tx_cnt <= tx_cnt+1;
        end
        else begin
            if(!DFF & tx_cnt >= 5'd7) tx_cnt <= 5'b0;
            else if(DFF & tx_cnt >= 5'd15) tx_cnt <= 5'b0;
            else tx_cnt <= tx_cnt+1;
        end
    end
    else begin
        tx_cnt <= 4'b0;
    end
end

//data send
always@(negedge sclk or negedge rst_n) begin
    if(!rst_n) tx <= 1'b0; 
    else if(rxonly) tx<= 1'b0;
    else if(enable) begin
        if(CPHA) begin
            if(LSBFIRST) begin
                tx <= data_shift_tx[tx_cnt-1];
            end
            else begin
                if(DFF) tx <= data_shift_tx[16-tx_cnt];
                else tx <= data_shift_tx[8-tx_cnt];
            end
        end
        else begin
            if(LSBFIRST) begin
                tx <= data_shift_tx[tx_cnt];
            end
            else begin
                if(DFF) tx <= data_shift_tx[15-tx_cnt];
                else tx <= data_shift_tx[7-tx_cnt];
            end
        end
    end
    else if(crc_en) begin
        if(CPHA) begin
            if(LSBFIRST) begin
                tx <= TXCRC[crc_cnt-1];
            end
            else begin
                if(DFF) tx <= TXCRC[16-crc_cnt];
                else tx <= TXCRC[8-crc_cnt];
            end
        end
        else begin
            if(LSBFIRST) begin
                tx <= TXCRC[crc_cnt];
            end
            else begin
                if(DFF) tx <= TXCRC[15-crc_cnt];
                else tx <= TXCRC[7-crc_cnt];
            end
        end
    end
    else tx <= 1'b0;
end

//数据传输检测
always @(posedge clk)
begin
    case({CPHA,DFF})
    2'b00: cnt_buf_tx <= tx_cnt[2];
    2'b01,2'b10: cnt_buf_tx <= tx_cnt[3];
    2'b11: cnt_buf_tx <= tx_cnt[4];
    default: cnt_buf_tx <= 1'b0;
    endcase
end
assign tx_done = (CPHA^DFF) ? ((~tx_cnt[3]) & cnt_buf_tx) : (DFF ? ((~tx_cnt[4]) & cnt_buf_tx) : (~tx_cnt[2]) & cnt_buf_tx);

//crc_cnt
always@(negedge sclk or negedge rst_n) begin 
    if(!rst_n) begin
        crc_cnt <= 5'b0;
    end
    else if(crc_en)begin
        if(CPHA) begin
            if(!DFF & crc_cnt >= 5'd8) crc_cnt <= 5'b0;
            else if(DFF & crc_cnt >= 5'd16) crc_cnt <= 5'b0;
            else crc_cnt <= crc_cnt+1;
        end
        else begin
            if(!DFF & crc_cnt >= 5'd7) crc_cnt <= 5'b0;
            else if(DFF & crc_cnt >= 5'd15) crc_cnt <= 5'b0;
            else crc_cnt <= crc_cnt+1;
        end
    end
    else begin
        crc_cnt <= 5'b0;
    end
end

//CRC数据传输检测
always @(posedge clk)
begin
    case({CPHA,DFF})
    2'b00: cnt_buf_crc <= crc_cnt[2];
    2'b01,2'b10: cnt_buf_crc <= crc_cnt[3];
    2'b11: cnt_buf_crc <= crc_cnt[4];
    default: cnt_buf_crc <= 1'b0;
    endcase
end
assign crc_done = (CPHA^DFF) ? ((~crc_cnt[3]) & cnt_buf_crc) : (DFF ? ((~crc_cnt[4]) & cnt_buf_crc) : (~crc_cnt[2]) & cnt_buf_crc);

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
            if(M_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            crc_en <= 1'b0;
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
                if(tx_done) begin
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
            if(M_en) begin
                if(crc_done) begin
                    crc_en <= 1'b0;
                    state <= WAIT;
                end
                else begin
                    crc_en <= 1'b1;
                    state <= CRCSEND;
                end
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
