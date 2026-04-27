`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 09:52:06
// Design Name: 
// Module Name: CRC8
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


module CRC_tx(
input           clk         ,
input           rst_n       ,
input           CRC_en      ,
//input           TXE         ,
input           DFF         ,
//input           CRC_next    ,
input [15:0]    datain      ,
input [15:0]    poly        ,

input enable,
input crc_en,

output [15:0]   CRC_out     ,
output reg      CRC_busy
    );
//para
parameter DISABLE = 3'b000;
parameter WAIT = 3'b001;
parameter CRC8 = 3'b010;
parameter CRC8_pre = 3'b011;
parameter CRC16 = 3'b100;
parameter CRC16_pre = 3'b101;

//reg wire
reg [15:0]CRC16_reg;
reg [7:0]CRC8_reg;
reg [2:0]state;
reg TXE_buf;
reg TXE_rise;
reg [2:0] cnt_crc8;
reg [3:0] cnt_crc16;

reg enable_buf;
wire enable_rise;

assign CRC_out = DFF ? CRC16_reg : {8'b0,CRC8_reg};

//TXErise
//always @(posedge clk)
//begin
//   TXE_buf <= TXE;
//   TXE_rise <= (~TXE_buf) & TXE;
//end

always @(posedge clk)
begin
   enable_buf <= enable;
//   enable_rise <= (~enable) & enable_buf;
end
assign enable_rise = (~enable_buf) & enable;

//state
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= DISABLE;
        CRC8_reg <= 8'b0;
        CRC16_reg <= 16'b0;
        CRC_busy <= 1'b0;
        cnt_crc8 <= 3'b0;
        cnt_crc16 <= 4'b0;
    end
    else begin
        case(state)
        DISABLE: begin
            CRC8_reg <= 8'b0;
            CRC16_reg <= 16'b0;
            CRC_busy <= 1'b0;
            cnt_crc8 <= 3'b0;
            cnt_crc16 <= 4'b0;
            if(CRC_en) state <= WAIT;
            else state <= DISABLE;
        end
        WAIT: begin
            CRC_busy <= 1'b0;
            cnt_crc8 <= 3'b0;
            cnt_crc16 <= 4'b0;
            if(CRC_en) begin
                if(crc_en) state <= WAIT;
                else if(enable_rise & DFF) state<= CRC16_pre;
                else if(enable_rise & !DFF) state<= CRC8_pre;
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
                if(cnt_crc8 == 3'b111) state <= WAIT;
                else state <= CRC8;
            end
            else state <= DISABLE;
        end
        CRC16_pre: begin
            CRC_busy <= 1'b1;
            CRC16_reg <= datain[15:0]^CRC16_reg;//输入数据按字节按位取反（not 0 to 1, 是数据倒序排序）
            state <= CRC16;
        end
        CRC16: begin
            cnt_crc16 <= cnt_crc16 + 1'b1;
            CRC16_reg <= CRC16_reg[15]? {CRC16_reg[14:0],1'b0} ^ poly : {CRC16_reg[14:0],1'b0};//实际上，这步我们做了运算与移位操作
            if(CRC_en) begin
                if(cnt_crc16 == 4'b1111) state <= WAIT;
                else state <= CRC16;
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
