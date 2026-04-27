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


module tx_m
# (
parameter WIDTH = 3,
parameter BIT = 8
)
(
input               sclk            ,
input               clk             ,
input               rst_n           ,
input               M_en            ,
input               DR_w            ,
input [BIT-1:0]     data_in         ,
input               LSBFIRST        ,
output reg          TXE             ,
output              busy            ,
output reg          dataout
    );
//localparam
localparam DISABLE = 2'b00;
localparam WAIT = 2'b01;
localparam SEND = 2'b10;
//reg and wire
reg [WIDTH-1:0]data_cnt;
reg [BIT-1:0]data_shift;
reg send_end;
reg cnt_buf;
reg enable;
reg [1:0] state;
assign busy = enable & TXE;
//data shift
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) data_shift <= 'b0;
    else if(M_en) begin
        if(!TXE & !enable) data_shift <= data_in;
        else data_shift <= data_shift;
    end
    else data_shift <= 'b0;
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

//data_cnt
always@(posedge sclk or negedge rst_n) begin 
    if(!rst_n) begin
        data_cnt <= 4'b0;
    end
    else if(enable)begin
        data_cnt <= data_cnt+1;
    end
    else begin
        data_cnt <= 4'b0;
    end
end

//data send
always@(posedge sclk) begin 
    if(enable) begin
        if(LSBFIRST) begin
            dataout <= data_shift[0];
            data_shift <= data_shift >> 1; 
        end
        else begin
            dataout <= data_shift[BIT-1];
            data_shift <= data_shift << 1;
        end
    end
    else dataout <= 1'b0;
end

//Êý¾Ý´«Êä¼ì²â
always @(posedge clk)
begin
   cnt_buf <= data_cnt[WIDTH-1];
   send_end <= data_cnt[WIDTH-1] & (~cnt_buf);
end

//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
    end
    else begin
        case(state)
        DISABLE: begin
            enable <= 1'b0;
            if(M_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            enable <= 1'b0;
            if(M_en) begin
                if(TXE) state <= WAIT;
                else state <= SEND;
            end
            else state <= DISABLE;
        end
        SEND: begin
            enable <= 1'b1;
            if(M_en) begin
                if(send_end) state <= WAIT;
                else state <= SEND;
            end
            else state <= DISABLE;
        end
        default: begin
            enable <= 1'b0;
        end
        endcase
    end
end
endmodule
