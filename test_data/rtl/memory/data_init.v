//-----------------------------------------------
//    module name: data_init
//    author: Sun Zhe
//    modified: zhanglzh
//    version: 1st version (2021-10-01)
//    modified: CJ
//    version: 2st version (2024-11-8)
//    description: 当enable信号为高电平时该模块工作，完成对存储器的初始??
//                 1. 实现对数据包中数据的接收（数据包??131Byte，其中数据部分共128Byte，下面会给出详细的数据包结构??
//                 2. 将接收的数据??4Byte??组发送出去，并根据目的地??决定发???给Icache或Dcache
//                 3. 对接收到的数据包进行CRC校验，并通过tx_pin引脚发???校验结果ACK/NAK
// 
//-----------------------------------------------
`timescale 1ns / 1ps
//`define FREQ = 25;
//`include "./riscv.h"
module data_init
(
    input wire         clk,
    input wire         rst,                        //复位信号，低电平有效
    input wire         uart_rx,                    //用于接收外部数据（即数据包），每次接??1bit
    output wire        uart_tx,                    //用于CRC校验后发送ACK/NAK信号，与uart_rx??样，每次传输1bit数据
    
    output wire        init_sig,
    output wire        ibus_we,                    //Icache写使能信号，当数据发送给Icache时有??
    output wire [31:0] ibus_addr_o,                //Icache的目的地??
    output wire [63:0] ibus_data_o,                //发???往Icache的数据，从data寄存器中取出，每次发??32bit
    output wire        dbus_we,                    //Dcache写使能信号，当数据发送给Dcache时有??
    output wire [31:0] dbus_addr_o,                //Dcache的目的地??
    output wire [63:0] dbus_data_o                 //发???往Dcache的数据，从data寄存器中取出，每次发??32bit

);

    
    localparam UART_RESP_ACK          = 8'h6  ;    //uart接收确认信号ACK
    localparam UART_RESP_NAK          = 8'h15 ;    //uart接收未确认信号NAK
    localparam UART_REMAIN_PACKET_LEN = 8'd132;    //数据包长??132Byte

    //data_init状???机, 独热??, 18个状??
    localparam  IDLE       =  18'h00000;
    localparam  NUM0       =  18'h00001;
    localparam  NUM1       =  18'h00002;
    localparam  DATA0      =  18'h00004;
    localparam  DATA1      =  18'h00008;
    localparam  DATA2      =  18'h00010;
    localparam  DATA3      =  18'h00020;
    localparam  DATA4      =  18'h00040;
    localparam  DATA5      =  18'h00080;
    localparam  DATA6      =  18'h00100;
    localparam  DATA7      =  18'h00200;
    localparam  SEND       =  18'h00400;
    localparam  CRC1       =  18'h00800;
    localparam  CRC_START  =  18'h01000;
    localparam  CRC_CALC   =  18'h02000;
    localparam  CRC_END    =  18'h04000;
    localparam  SENDRSP    =  18'h08000;
    localparam  WAITSEND   =  18'h10000;
    localparam  STACK      =  18'h20000;

    reg        r_ibus_we;
    reg [31:0] r_ibus_addr_o;
    reg [63:0] r_ibus_data_o;
    reg        r_dbus_we;
    reg [31:0] r_dbus_addr_o;
    reg [63:0] r_dbus_data_o;

    
    reg [ 7:0] tx_data;          //DATAing data
    reg        tx_data_valid;    //DATAing data valid
    wire       tx_data_ready;    //singal for DATAing data
    wire [7:0] rx_data;          //receiving data
    wire       rx_data_valid;    // receiving data valid
    //wire       rx_data_ready;    // singal for receiving data
    reg  [17:0] c_state;         // current
    reg  [17:0] n_state;         // next state

    wire d_finish;
    wire w_finish;
    //assign rx_data_ready = 1'b1;
    
    reg [63:0] data;             //接收来自rx的数据，每次接收8bit
    reg [ 7:0] count;            //已接收多少Byte的数据，累计??128时数据部分接收完毕，进入CRC
    reg [31:0] addr_i;           //Icache地址
    reg [31:0] addr_d;           //Dcache地址
    reg [ 9:0] cnt_s;            //Stack_cnt
    wire [31:0] addr_s;           //Stack地址
    reg        valid;            //SEND状???暂存rx_data_valid信号
    
    //文件大小包的序号，用于标识发??Icache还是Dcache
    reg [ 5:0] number;
    //是否为第??个包（第??个包只需CRC不需要存储）
    reg [ 15:0] first;
    reg [ 9:0] size;

    //用于CRC计算
    reg [ 7:0] crc_data[0:129];
    reg [ 7:0] rec_bytes_index;
    reg [ 7:0] need_to_rec_bytes;
    reg [15:0] crc_result;
    reg [ 3:0] crc_bit_index;
    reg [ 7:0] crc_byte_index;
    reg [15:0] r_crc_16;

    //-----{三段式状态机}begin
    //-----{时序逻辑，描述状态转移}begin
    always @(posedge clk or negedge rst) begin
        if(!rst)
            c_state <= IDLE;
        else 
            c_state <= n_state;
    end
    //-----{时序逻辑，描述状态转移}end

    //-----{组合逻辑，判断状态转移条件}begin
    always @(*) begin
        case (c_state)
            IDLE:begin
                if(rx_data_valid)
                    n_state = NUM0;
                else 
                    n_state = IDLE;
            end
            NUM0:begin
                if(rx_data_valid)
                    n_state = NUM1;
                else 
                    n_state = NUM0;
            end
            NUM1:begin
                if(rx_data_valid)
                    n_state = DATA0;
                else 
                    n_state = NUM1;
            end
            DATA0:begin
                if(rx_data_valid)
                    n_state = DATA1;
                else 
                    n_state = DATA0;
            end
            DATA1:begin
                if(rx_data_valid)
                    n_state = DATA2;
                else 
                    n_state = DATA1;
            end
            DATA2:begin
                if(rx_data_valid)
                    n_state = DATA3;
                else 
                    n_state = DATA2;
            end        
            DATA3:begin
                if(rx_data_valid)
                    n_state = DATA4;
                else
                    n_state = DATA3;
            end
            DATA4:begin
                if(rx_data_valid)
                    n_state = DATA5;
                else 
                    n_state = DATA4;
            end
            DATA5:begin
                if(rx_data_valid)
                    n_state = DATA6;
                else 
                    n_state = DATA5;
            end
            DATA6:begin
                if(rx_data_valid)
                    n_state = DATA7;
                else 
                    n_state = DATA6;
            end
            DATA7:begin
                if(rx_data_valid)
                    n_state = SEND;
                else 
                    n_state = DATA7;
            end
            SEND:begin
                if(count == 8'd128)
                    n_state = CRC1;
                else 
                    n_state = DATA0;
            end
            CRC1:begin
                if(rx_data_valid)
                    n_state = CRC_START;
                else
                    n_state = CRC1;            
            end
            CRC_START:begin//简化成无条件跳转
                if(valid && count == 8'd128)//rx_data_vaild不对，没用，进入CRC里面的时候应该停止接收数据，因为数据没法接收
                    n_state = CRC_CALC;
                else
                    n_state = CRC_START;    
            end
            CRC_CALC:begin
                if ((crc_byte_index == need_to_rec_bytes - 2) && crc_bit_index == 4'h8)
                    n_state = CRC_END;
                else 
                    n_state = CRC_CALC;
            end
            CRC_END:begin
				n_state = SENDRSP;
            end
            SENDRSP:begin
				n_state = WAITSEND;
            end
	    WAITSEND:begin
		if(tx_data_ready )
		    if(d_finish)
                        n_state = STACK;
		    else if ( rx_data_valid )
			    n_state = NUM0;
			else 
			    n_state = WAITSEND;
        else
                    n_state = WAITSEND;
			end
	    STACK:begin
	        if(cnt_s >= 10'h3ff &&( rx_data_valid ))
		    n_state = NUM0;
		else
		    n_state = STACK;
	    end
            default: 
                n_state = IDLE;
        endcase
    end
    //-----{组合逻辑，判断状态转移条件}end
    
    //-----{时序逻辑，对每个状???的输出进行判断}begin
	integer i; 
	
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            for(i = 0 ; i < 130;i = i + 1) begin
                crc_data[i] <= 8'b0;
            end
            r_ibus_we       <= 1'b0;
            r_ibus_addr_o   <= 32'b0;
            r_ibus_data_o   <= 64'b0;
            r_dbus_we       <= 1'b0;
            r_dbus_addr_o   <= 32'b0;
            r_dbus_data_o   <= 64'b0;
            tx_data         <= 8'b0;
            tx_data_valid   <= 1'b0;
            data            <= 64'b0;
            count           <= 8'b0;
            //统一编址的基地址
            addr_i          <= 32'h00001200;
            addr_d          <= 32'h00021200;


            number          <= 6'b0;
            first           <= 16'b0;
            valid           <= 1'b0;
            r_crc_16        <= 16'h0;
            rec_bytes_index <= 8'b1;
            size            <= 10'b0;        //这里要更新吗??
        end
        else begin
            case (n_state)
                NUM0:      begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    tx_data_valid   <= 1'b0;
                    rec_bytes_index <= 8'b1;
                    crc_data[0]     <= rx_data;
                    /*
                    first和number都是存放数据包序号，
                    first每来??个数据包都要更新??
                    number只在Icache和Dcache切换时更??
                    */
                    first[15:8]           <= rx_data;
                    if(rx_data[7:2] == 6'h20 || rx_data[7:2] == 6'h01)begin
                        number  <= rx_data[7:2];
                        size [9:8] <= rx_data[1:0];
                    end
                            
                end
                NUM1:      begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    tx_data_valid   <= 1'b0;
                    rec_bytes_index <= 8'b1;
                    crc_data[1]     <= rx_data;
                    /*
                    first和number都是存放数据包序号，
                    first每来??个数据包都要更新??
                    number只在Icache和Dcache切换时更??
                    */
                    first[7:0]           <= rx_data;
                    if((number == 6'h20 || number == 6'h01)&&(first[15:10]== 6'b100000 ||first[15:10] == 6'b000001))
                        size [7:0] <= rx_data;
                end
                DATA0:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[63:56]   <= rx_data;
                    end
                    else if(valid)
                        data[63:56] <= rx_data;
                end 
                DATA1:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[55:48] <= rx_data;
                    end
                end
                DATA2:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if (rx_data_valid) begin
                        count       <= count+1;
                        data[47:40] <= rx_data;
                    end
                end
                DATA3:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[39:32] <= rx_data;
                    end
                end
                DATA4:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[31:24] <= rx_data;
                    end
                end 
                DATA5:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[23:16] <= rx_data;
                    end
                end
                DATA6:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if (rx_data_valid) begin
                        count       <= count+1;
                        data[15:8]  <= rx_data;
                    end
                end
                DATA7:    begin
                    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    if(rx_data_valid)begin
                        count       <= count+1;
                        data[7:0]   <= rx_data;
                    end
                end
                SEND:     begin
                    //crc_data暂存数据包数据以进行CRC校验
                    crc_data[rec_bytes_index+1] <= data[63:56];
                    crc_data[rec_bytes_index+2] <= data[55:48];
                    crc_data[rec_bytes_index+3] <= data[47:40];
                    crc_data[rec_bytes_index+4] <= data[39:32];
                    crc_data[rec_bytes_index+5] <= data[31:24];
                    crc_data[rec_bytes_index+6] <= data[23:16];
                    crc_data[rec_bytes_index+7] <= data[15:8];
                    crc_data[rec_bytes_index+8] <= data[7:0];
                    rec_bytes_index             <= rec_bytes_index + 8;
                    valid                       <= rx_data_valid;
                    //根据地址判断发往Icache还是Dcache
                    //先判断发送方向（number），再判断是否为第一个包
                    if(number == 6'h20)begin
                        r_dbus_we     <= 1'b0;
                        r_ibus_addr_o <= addr_i;
                        r_ibus_data_o <= data;
                        if(first[15:10] != 6'h20)
                          begin
                              r_ibus_we <= 1'b1;
                              addr_i    <= addr_i + 8;
                          end
                        else
                          r_ibus_we <= 1'b0;
                    end
                    else if(number == 6'h01) begin
                        r_ibus_we     <= 1'b0;
                        r_dbus_addr_o <= addr_d;
                        r_dbus_data_o <= data;
                        if(first[15:10] != 6'h01)
                          begin
                              r_dbus_we <= 1'b1;
                              addr_d    <= addr_d + 8;
                          end
                        else
                          r_dbus_we <= 1'b0;
                    end
                    else begin                    
                        r_ibus_we     <= 1'b0;
                        r_ibus_addr_o <= 32'b0;
                        r_ibus_data_o <= 64'b0;
                        r_dbus_we     <= 1'b0;
                        r_dbus_addr_o <= 32'b0;
                        r_dbus_data_o <= 64'b0;
                        tx_data       <= 8'b0;
                        tx_data_valid <= 1'b0;
                        data          <= 64'b0;
                        count         <= 8'b0;
                    end
                    if(count < 8'd128)
                        count         <= count+1;
                end
                CRC1:     begin
				    r_ibus_we       <= 1'b0;
                    r_dbus_we       <= 1'b0;
                    r_crc_16[15:8]  <= rx_data;
                end
                CRC_START:begin
                    r_ibus_we      <= 1'b0;
                    r_dbus_we      <= 1'b0;
                    r_crc_16[ 7:0] <= rx_data;
                end
                SENDRSP:      begin
                    r_ibus_we     <= 1'b0;
                    r_dbus_we     <= 1'b0;
                    tx_data_valid <= 1'b1;
                    tx_data       <= (crc_result == r_crc_16)?UART_RESP_ACK:UART_RESP_NAK;
                end
                STACK:  begin
                    r_dbus_we       <=1'b1;
                    r_dbus_addr_o   <=addr_s;
                    r_dbus_data_o   <=64'b0;
                end
                default:  begin
                    r_ibus_we     <= 1'b0;
                    r_ibus_addr_o <= 32'b0;
                    r_ibus_data_o <= 64'b0;
                    r_dbus_we     <= 1'b0;
                    r_dbus_addr_o <= 32'b0;
                    r_dbus_data_o <= 64'b0;
                    tx_data       <= 8'b0;
                    tx_data_valid <= 1'b0;
                    data          <= 64'b0;
                    count         <= 8'b0;
                end 
            endcase
        end
    end
    //-----{时序逻辑，对每个状???的输出进行判断}end

    assign ibus_we     = r_ibus_we;
    assign ibus_addr_o = r_ibus_addr_o;
    assign ibus_data_o = {r_ibus_data_o[31:0], r_ibus_data_o[63:32]};
    assign dbus_we     = r_dbus_we;
    assign dbus_addr_o = r_dbus_addr_o;
    assign dbus_data_o = {r_dbus_data_o[31:0], r_dbus_data_o[63:32]};

    //-----{stack cnt}begin
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            cnt_s <= 10'h0;
        end else if(cnt_s >= 10'h3ff) begin
            cnt_s <= 10'h3ff;
        end else if(n_state == STACK) begin
            cnt_s <= cnt_s + 1;
        end
	else begin
	    cnt_s <= 10'h0;
	end
    end
    //-----{stack send}
    assign addr_s = 32'h00041200 + 32'h8*cnt_s;

    //-----{CRC计算}begin
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            need_to_rec_bytes <= 8'h0;
        end else begin
            need_to_rec_bytes <= UART_REMAIN_PACKET_LEN;
        end
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            crc_result <= 16'h0;
        end else begin
            case (c_state)
                CRC_START: begin
                    crc_result <= 16'hffff;
                end
                CRC_CALC: begin
                    if (crc_bit_index == 4'h0) begin
                        crc_result <= crc_result ^ crc_data[crc_byte_index];
                    end else begin
                        if (crc_bit_index < 4'h9) begin
                            if (crc_result[0]) begin
                                crc_result <= {1'b0, crc_result[15:1]} ^ 16'ha001;
                            end else begin
                                crc_result <= {1'b0, crc_result[15:1]};
                            end
                        end
                    end
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            crc_bit_index <= 4'h0;
        end else begin
            case (c_state)
                CRC_START: begin
                    crc_bit_index <= 4'h0;
                end
                CRC_CALC: begin
                    if (crc_bit_index < 4'h9) begin
                        crc_bit_index <= crc_bit_index + 1'b1;
                    end else begin
                        crc_bit_index <= 4'h0;
                    end
                end
            endcase
        end
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            crc_byte_index <= 8'h0;
        end else begin
            case (c_state)
                CRC_START: begin
                    crc_byte_index <= 8'h0;
                end
                CRC_CALC: begin
                    if (crc_bit_index == 4'h0) begin
                        crc_byte_index <= crc_byte_index + 1'b1;
                    end
                end
            endcase
        end
    end
    //-----{CRC计算}end
    
uart_rx#
(
    .CLK_FRE(25),
    .BAUD_RATE(115200)
) uart_rx_inst
(
    .clk                        (clk                      ),
    .rst                        (rst                      ),
    .rx_data                    (rx_data                  ),
    .rx_data_valid              (rx_data_valid            ),
    .rx_data_ready              (1'b1                     ),
    .rx_pin                     (uart_rx                  )
);

uart_tx#
(
    .CLK_FRE(25),
    .BAUD_RATE(115200)
) uart_tx_inst
(
    .clk                        (clk                      ),
    .rst                        (rst                      ),
    .tx_data                    (tx_data                  ),
    .tx_data_valid              (tx_data_valid            ),
    .tx_data_ready              (tx_data_ready            ),
    .tx_pin                     (uart_tx                  )
);
    reg r_init_1;
    assign init_sig = r_init_1;
    assign d_finish = (first[9:0] == (size-1)) & ( number == 6'h01 ) & c_state == WAITSEND & tx_data_ready;//finish有什么用？
    assign w_finish = c_state == STACK & cnt_s == 10'h3ff;
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            r_init_1 <= 1'b1;
        end else begin
            if(w_finish) begin
                r_init_1 <= 1'b0;
            end
        end

    end
endmodule
