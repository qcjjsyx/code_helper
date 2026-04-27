`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/09 11:12:52
// Design Name: 
// Module Name: clk_div
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


module clk_div(
input       clk         ,
input       rst_n       ,
input       rx_only     ,
input       M_en        ,
input       enable      ,
input       DFF         ,
input [2:0] BR          ,
output reg nss_out      ,
output      sclk_m      ,
output      sclk_out
);
localparam DISABLE = 3'b000;
localparam WAIT = 3'b001;
localparam CNT_BIT = 3'b010;
localparam CNT_ALL = 3'b011;
localparam CNT0_WAIT = 3'b100;
localparam CNT1_WAIT = 3'b101;
localparam CNT0_OUT = 3'b110;
localparam CNT1_OUT = 3'b111;
reg [7:0]cnt;
reg [4:0]sclk_cnt;
reg [2:0]state;
//reg sclk_done;
wire sclk_done;
wire bit8_out;
reg sclk_cnt_buf;
//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
        cnt <= 8'b0;
        nss_out <= 1'b1;
    end
    else begin
        case(state)
        DISABLE: begin
            cnt <= 8'b0;
            nss_out <= 1'b1;
            if(M_en) begin
                if(!rx_only) state <= WAIT;
                else begin
                    nss_out <= 1'b0;
                    state <= CNT0_OUT;
                end
            end
            else state <= DISABLE;
        end
        WAIT: begin
            cnt <= 8'b0;
            if(M_en) begin
                if(enable) begin
                    nss_out <= 1'b0;
                    state <= CNT0_OUT;
                end
                else begin
                    state <= WAIT;
                end
            end
            else state <= DISABLE;
        end
        CNT0_OUT: begin
            if(M_en) state <= CNT1_OUT;
            else state <= DISABLE;
        end
        CNT1_OUT: begin
            if(M_en) begin
                if(rx_only) state <= CNT_ALL;
                else state <= CNT_BIT;
            end
            else state <= DISABLE;
        end
        CNT_BIT: begin
            if(M_en) begin
                if(sclk_done) begin
                    nss_out <= 1'b0;
                    state <= CNT0_WAIT;
                end
                else begin
                    cnt <= cnt + 8'b1;
                    state <= CNT_BIT;
                end
            end
            else state <= DISABLE;
        end
        CNT_ALL: begin
            cnt <= cnt + 8'b1;
            if(M_en) state <= CNT_ALL;
            else state <= DISABLE;
        end
        CNT0_WAIT: begin
            if(M_en) state <= CNT1_WAIT;
            else state <= DISABLE;
        end
        CNT1_WAIT: begin
            if(M_en) begin
                nss_out <= 1'b1;
                state <= WAIT;
            end
            else state <= DISABLE;
        end
        default: begin
            state <= DISABLE;
        end
        endcase
    end
end
assign bit8_out = (sclk_cnt != 0) ? 1'b1 : 1'b0;
assign sclk_m = nss_out ? 1'b0 :cnt[BR];
assign sclk_out = rx_only ? sclk_m : (bit8_out ? sclk_m : 1'b0);

//sclk cnt
always@(negedge sclk_m or negedge rst_n) begin
    if(!rst_n) sclk_cnt <= 5'b0;
    else if(!rx_only) begin
        if(!DFF & sclk_cnt >= 5'd8) sclk_cnt <= 5'b0;
        else if(DFF & sclk_cnt >= 5'd16) sclk_cnt <= 5'b0;
        else sclk_cnt <= sclk_cnt + 1'b1;
    end
    else sclk_cnt <= 5'b0;
end

//sclk done
always @(posedge clk)
begin
    if(DFF) sclk_cnt_buf <= sclk_cnt[4];
    else sclk_cnt_buf <= sclk_cnt[3];
   //sclk_done <= (~sclk_cnt[WIDTH-1]) & sclk_cnt_buf;
end
assign sclk_done = DFF ? ((~sclk_cnt[4]) & sclk_cnt_buf) : ((~sclk_cnt[3]) & sclk_cnt_buf);

endmodule
