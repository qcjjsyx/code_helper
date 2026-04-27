`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/28 15:19:33
// Design Name: 
// Module Name: flash_state
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


module flash_state(
                            input                clk                ,
                            input                rst_n              ,
                    
                            input                i_startRead        ,
(*dont_touch = "yes"*)     input [7:0]          i_addr              ,
(*dont_touch = "yes"*)     input [31:0]         i_data2spi          ,
(*dont_touch = "yes"*)     output [31:0]        o_dataFspi          ,

(*dont_touch = "yes"*)     input                i_r_enT             ,
(*dont_touch = "yes"*)     input                i_readflag          ,
(*dont_touch = "yes"*)     output reg           o_busy              ,
(*dont_touch = "yes"*)     output               o_dataready         ,
(*dont_touch = "yes"*)     output               o_finish            ,

(*dont_touch = "yes"*)     input                i_miso              ,
                            output               o_sclk             ,
                            output reg           o_cs_n             ,
                            output               o_mosi

    );
//Flash INSTRUCTION 
localparam Read = 8'h03;
localparam Page_Program = 8'h02;
localparam Block_Erase = 8'hd8;
localparam Sector_Erase = 8'h20;
localparam Chip_Erase = 8'hc7;
localparam Read_SR1 = 8'h05;
localparam Write_en = 8'h06;

//state
(*dont_touch = "yes"*) reg [3:0] r_state;
localparam R_BUSY = 4'h0;
localparam IDLE = 4'h1;
localparam WAIT = 4'h2;
localparam W_EN = 4'h3;
localparam PAGE_PRO = 4'h4;
localparam B_ERASE = 4'h5;
localparam S_ERASE = 4'h6;
localparam C_ERASE = 4'h7;
localparam READ = 4'h8;

//Signal
(*dont_touch = "yes"*)reg r_start_spi;
(*dont_touch = "yes"*)reg r_start_spi_buf;
(*dont_touch = "yes"*)reg [31:0] r_data2spi;
(*dont_touch = "yes"*)wire [7:0] cmd = i_data2spi[31:24];
(*dont_touch = "yes"*)wire [5:0] w_sclk_cnt;
(*dont_touch = "yes"*)wire w_cnt_end = w_sclk_cnt >= 5'd9 ? 1'b1 : 1'b0;
(*dont_touch = "yes"*)wire w_spi_en;
(*dont_touch = "yes"*) wire w_spi_cs_n;
(*dont_touch = "yes"*) reg r_spi_cs_n_buf;
(*dont_touch = "yes"*) wire w_spi_cs_n_rise;

//pulse for spi_en
always @(posedge clk)
begin
    r_start_spi_buf <= r_start_spi;
end
assign w_spi_en = (r_state == READ | r_state == PAGE_PRO) ? (i_startRead | ((~r_start_spi_buf) & r_start_spi)) 
                                                          : ((~r_start_spi_buf) & r_start_spi);
//end sclk cnt
//always @(posedge clk)
//begin
//    if(w_sclk_cnt >= 5'd8) r_cnt_end <= 1'b1;
//    else r_cnt_end <= 1'b0;
//end
//rise for w_spi_cs_n
always @(posedge clk)
begin
    r_spi_cs_n_buf <= w_spi_cs_n;
end
assign w_spi_cs_n_rise = (~r_spi_cs_n_buf) & w_spi_cs_n;
assign o_finish = w_spi_cs_n;

//module inst
spi_master  u_spi_master(
        .clk(clk),
        .rst_n(rst_n),
        
        .rx(i_miso),
        .sclk_out(o_sclk),
        .nss_out(w_spi_cs_n),
        .tx(o_mosi),
        
        .data_in(r_data2spi),
        .data_out(o_dataFspi),
        .RXNE(o_dataready),
        
        .sclk_cnt_div(w_sclk_cnt),
        .DR_w(w_spi_en),
        .ADDR(i_addr),
        .DR_r(i_readflag),
        .r_enT(i_r_enT)
      );
//state
always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
        r_state <= IDLE;
        r_start_spi <= 1'b0;
        o_cs_n <= 1'b1;
        o_busy <= 1'b0;
        r_data2spi <= 32'b0;
    end
    else begin
        case(r_state)
        IDLE: begin
            r_start_spi <= 1'b0;
            o_cs_n <= 1'b1;
            r_data2spi <= 32'b0;
            if(i_startRead) begin
                case(cmd)
                    Read: r_state <= READ;
                    Read_SR1: r_state <= R_BUSY;
                    Page_Program,Block_Erase,Sector_Erase,Chip_Erase: r_state <= W_EN;
                    default: r_state <= IDLE;
                endcase
            end
            else r_state <= IDLE;
        end
        R_BUSY: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise) begin
                r_state <= IDLE;
                o_busy <= o_dataFspi[0];
            end
            else r_state <= R_BUSY;
        end
        READ: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise & (i_addr[7:5] == 3'b111)) r_state <= IDLE;
            else r_state <= READ;
        end
        W_EN: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= {Write_en,24'h0};
            if(w_cnt_end) begin
                o_cs_n <= 1'b1;
                r_state <= WAIT;
            end
            else r_state <= W_EN;
        end
        WAIT: begin
            o_cs_n <= 1'b1;
            r_start_spi <= 1'b0;
            if(w_spi_cs_n_rise) begin
                case(cmd)
                    Page_Program: r_state <= PAGE_PRO;
                    Block_Erase: r_state <= B_ERASE;
                    Sector_Erase: r_state <= S_ERASE;
                    Chip_Erase: r_state <= C_ERASE;
                default: r_state <= IDLE;
                endcase
            end
        end
        PAGE_PRO: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise & (i_addr[7:5] == 3'b111)) r_state <= IDLE;
            else r_state <= PAGE_PRO;
        end
        B_ERASE: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise) r_state <= IDLE;
            else r_state <= B_ERASE;
        end
        S_ERASE: begin
            o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise) r_state <= IDLE;
            else r_state <= S_ERASE;
        end
        C_ERASE: begin
            if(w_cnt_end) o_cs_n <= 1'b1;
            else o_cs_n <= 1'b0;
            r_start_spi <= 1'b1;
            r_data2spi <= i_data2spi;
            if(w_spi_cs_n_rise) r_state <= IDLE;
            else r_state <= C_ERASE;
        end
        default: begin
            r_state <= IDLE;
        end
        endcase
    end
end

endmodule
