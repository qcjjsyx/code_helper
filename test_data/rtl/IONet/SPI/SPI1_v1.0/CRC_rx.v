`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/20 21:57:49
// Design Name: 
// Module Name: CRC_rx
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


module CRC_rx(
input           clk         ,
input           rst_n       ,
input           CRC_en      ,
input           RXNE        ,
input           DFF         ,
input           CRC_next    ,
(*dont_touch = "yes"*)input [15:0]    datain      ,
(*dont_touch = "yes"*)input [15:0]    poly        ,
(*dont_touch = "yes"*)output [15:0]   CRC_out     ,
output reg      CRCERR      ,
output reg      CRC_busy
    );
//para
parameter DISABLE = 3'b000;
parameter WAIT = 3'b001;
parameter CRC8 = 3'b010;
parameter CRC8_pre = 3'b011;
parameter CRC_end = 3'b100;//标志着处理的这一帧数据是最后一帧数据，下一帧收到数据是CRC数据，不用进行CRC
parameter CRC16 = 3'b101;
parameter CRC16_pre = 3'b110;
parameter CRC_compare = 3'b111;


//reg wire
(*dont_touch = "yes"*)reg [15:0]CRC16_reg;
reg [7:0]CRC8_reg;
reg [2:0]state;
reg RXNE_buf;
reg RXNE_rise;
reg CRC_next_buf;
reg CRC_next_rise;
(*dont_touch = "yes"*)reg CRC_next_flag;
reg [2:0] cnt_crc8;
(*dont_touch = "yes"*)reg [3:0] cnt_crc16;

assign CRC_out = DFF ? CRC16_reg : {8'b0,CRC8_reg};

//RXNErise
always @(posedge clk)
begin
   RXNE_buf <= RXNE;
   RXNE_rise <= (~RXNE_buf) & RXNE;
end

//CRC_next_rise
always @(posedge clk)
begin
   CRC_next_buf <= CRC_next;
   CRC_next_rise <= (~CRC_next_buf) & CRC_next;
end

//CRC_next flag
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n) CRC_next_flag <= 1'b0;
    else if(CRC_next_rise) CRC_next_flag <= 1'b1;
    else if(state == CRC_end) CRC_next_flag <= 1'b0;
    else CRC_next_flag <= CRC_next_flag;
end

//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
        CRC8_reg <= 8'b0;
        CRC16_reg <= 16'b0;
        CRC_busy <= 1'b0;
        cnt_crc8 <= 3'b0;
        cnt_crc16 <= 4'b0;
        CRCERR <= 1'b0;
    end
    else begin
        case(state)
        DISABLE: begin
            CRC8_reg <= 8'b0;
            CRC16_reg <= 16'b0;
            CRC_busy <= 1'b0;
            cnt_crc8 <= 3'b0;
            cnt_crc16 <= 4'b0;
            CRCERR <= 1'b0;
            if(CRC_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            CRC_busy <= 1'b0;
            cnt_crc8 <= 3'b0;
            cnt_crc16 <= 4'b0;
            if(CRC_en) begin
                if(CRC_next & !CRC_next_flag) state <= WAIT;
                else if(RXNE_rise & DFF) state<= CRC16_pre;
                else if(RXNE_rise & !DFF) state<= CRC8_pre;
                else state <= WAIT;
            end
            else state <= DISABLE;
        end
        CRC8_pre: begin
            CRC_busy <= 1'b1;
            CRC8_reg <= datain[7:0]^CRC8_reg;
            state <= CRC8;
        end
        CRC8: begin
            cnt_crc8 <= cnt_crc8 + 1'b1;
            CRC8_reg <= CRC8_reg[7]? ({CRC8_reg[6:0], 1'b0} ^ poly[7:0]) : {CRC8_reg[6:0], 1'b0};//实际上，这步我们做了运算与移动操作
            if(CRC_en) begin
                if(cnt_crc8 == 3'b111 & CRC_next_flag) state <= CRC_end;
                else if(cnt_crc8 == 3'b111 & !CRC_next_flag) state <= WAIT;
                else state <= CRC8;
            end
            else state <= DISABLE;
        end
        CRC16_pre: begin
            CRC_busy <= 1'b1;
            CRC16_reg <= datain[15:0]^CRC16_reg;
            state <= CRC16;
        end
        CRC16: begin
            cnt_crc16 <= cnt_crc16 + 1'b1;
            CRC16_reg <= CRC16_reg[15]? {CRC16_reg[14:0],1'b0} ^ poly : {CRC16_reg[14:0],1'b0};//实际上，这步我们做了运算与移位操作
            if(CRC_en) begin
                if(cnt_crc16 == 4'b1111 & CRC_next_flag) state <= CRC_end;
                else if(cnt_crc16 == 4'b1111 & !CRC_next_flag) state <= WAIT;
                else state <= CRC16;
            end
            else state <= DISABLE;
        end
        CRC_end: begin
            CRC_busy <= 1'b0;
            if(CRC_en) begin
                if(RXNE_rise) state <= CRC_compare;
                else state <= CRC_end;
                end
            else state <= DISABLE;
        end
        CRC_compare: begin
            if(CRC_en) begin
                if(DFF & CRC_out == datain) CRCERR <= 1'b0;
                else if(!DFF & CRC_out[7:0] == datain[7:0])  CRCERR <= 1'b0;
                else CRCERR <= 1'b1;
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

endmodule