`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: cj
// 
// Create Date: 2024/09/27 10:10:57
// Design Name: 
// Module Name: SPI2NoC
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


module SPI2NoC(
    //Clock from outside
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input clk,
    
    // NoC
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst_finish,
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFNoc,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2Noc,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [50:0] i_dataFNoc_51,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Noc,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFNoc,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [50:0] o_data2Noc_51,

    // interrupt requerst
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output SPI_IRQ,
    // SPI Serial interface signals
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)inout  sclk,mosi,miso,nss
    
    );
    // APB总线信号
//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire RESETN;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg VAL;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [7:0] PADDR;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg PWRITE;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg PENABLE;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg PSEL;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] PWDATA;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0] PRDATA;
//APB state
    reg [2:0] state;
    parameter IDLE = 3'b000;
    parameter W_LOAD = 3'b001;
    parameter W_EN = 3'b011;
    parameter W_WAIT = 3'b100;
    parameter R_LOAD = 3'b010;
    parameter R_EN = 3'b110;
    parameter FINISH = 3'b111;
    // 直连复位信号
//    assign RESETN = rst;
    
    // 拆解网络数据
   (*dont_touch = "yes"*)reg[50:0] r_dataFNoc_51;
//   (*dont_touch = "yes"*)wire w_NoCRD;
//   assign w_NoCRD = r_dataFNoc_51[50];
//   (*dont_touch = "yes"*)wire [2:0] w_NoCaddress; 
//   assign w_NoCaddress = r_dataFNoc_51[44:42];
//   (*dont_touch = "yes"*)wire [31:0] w_NoCdata;
//   assign w_NoCdata = r_dataFNoc_51[41:10];
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire[4:0] w_X = r_dataFNoc_51[9:5];
    //(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire[4:0] w_Y = r_dataFNoc_51[4:0];
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_apbrdata;
    


    //----------阶段1：输入信号-----//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2fifo1,w_freeFfifo1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drvnext_fifo1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_mode0;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo0;
    cFifo3 cfifo0(
    .i_drive(i_drvFNoc),
    .o_free(o_free2Noc),
    .i_freeNext(w_freeFfifo1),
    .o_driveNext(w_drvnext_fifo1),
    .o_fire_3(w_firefifo0),
    .rst(rst)
    );
    (*dont_touch = "yes"*)reg [4:0] r_X;
    (*dont_touch = "yes"*)reg [4:0] r_Y;
    always@(posedge w_firefifo0[0] or negedge rst)begin
        if(!rst) begin
            r_dataFNoc_51<=0;
            r_X <= 0;
            r_Y <= 0;
        end 
        else begin
            r_dataFNoc_51 <= i_dataFNoc_51;
            r_X <= 5'b10001;
            r_Y <= 5'b00000;
        end
    end

//    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[7:0] ReceiveData;
    
    //in ASIC, 4*8U is 27.5ns, we need 40ns, so we use about 3*16U, additonally add 4U
//    wire w_drv2fifo1_dalay1;
//    wire w_drv2fifo1_dalay2;
//    wire w_drv2fifo1_dalay3;
//    wire w_drv2fifo1_dalay4;
//    delay16U delay1 (.inR(w_drv2fifo1), .outR(w_drv2fifo1_dalay1),.rst(rst));
//    delay16U delay2 (.inR(w_drv2fifo1_dalay1), .outR(w_drv2fifo1_dalay2),.rst(rst));
//    delay16U delay3 (.inR(w_drv2fifo1_dalay2), .outR(w_drv2fifo1_dalay3),.rst(rst));
//    delay2U delay4 (.inR(w_drv2fifo1_dalay3), .outR(w_drv2fifo1_dalay4),.rst(rst));
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire0 = w_firefifo0[0] | w_firefifo0[2];
    always@(posedge w_fire0 or negedge rst )begin
        if(!rst)begin
            r_mode0<=0;
        end
        else begin
            r_mode0<=~r_mode0;
        end
    end
    
    //--------------阶段2：完成写或者读入-----//
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_model;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)assign w_drv2fifo1 = (state == FINISH) ? 1'b1 :1'b0;
    cFifo3 cfifo1(
    .i_drive(w_drv2fifo1),
    .o_free(w_freeFfifo1),
    .i_freeNext(i_freeFNoc),
    .o_driveNext(o_drv2Noc),
    .o_fire_3(w_firefifo1),
    .rst(rst)
    );
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire1 = w_firefifo1[0] | w_firefifo1[2];
    always@(posedge w_fire1 or negedge rst )begin
        if(!rst)begin
            r_model<=0;
        end
        else begin
            r_model<=~r_model;
        end
    end
    
    //-----------两个阶段的控制----------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire = w_firefifo0[1] | w_firefifo1[1];
    always@(posedge w_fire or negedge rst )begin
        if(!rst)begin
            VAL <= 0;
        end
        else if(r_mode0) 
        begin
            VAL <= 1;
        end
        else if(r_model)begin
            VAL <= 0;
            //数据读出要在VAL变了以后
        end
        else begin
            VAL <= 0;
        end
    end
    
    //-------如果是读的话在fire[1]时需要把数据读出来-----//
    //-------如果是写的话在fire[0]时把数据放到线上-------//
    //-------APB总线状态机-------//

always@(posedge clk or negedge rst_finish) begin
    if(!rst_finish) begin
        state <= IDLE;
        PENABLE <= 1'b0;
        PSEL <= 1'b0;
        PWRITE <= 1'b1;
        PADDR <= 8'b0;
        PWDATA <= 32'b0;
        r_apbrdata <= 32'b0;
    end
    else begin
        case(state)
        IDLE: begin
            PENABLE <= 1'b0;
            PSEL <= 1'b0;
            PWRITE <= 1'b1;
            PADDR <= 8'b0;
            PWDATA <= 32'b0;
            if(VAL & (!r_dataFNoc_51[50])) state <= W_LOAD;
            else if(VAL & r_dataFNoc_51[50]) state <= R_LOAD;
            else state <= IDLE;
        end
        W_LOAD: begin
            PENABLE <= 1'b0;
            PSEL <= 1'b1;
            PWRITE <= (!r_dataFNoc_51[50]);
            PADDR <= r_dataFNoc_51[49:42];
            PWDATA <= r_dataFNoc_51[41:10];
            state <= W_EN;
        end
        W_EN: begin
            PENABLE <= 1'b1;
            PSEL <= 1'b1;
            PWRITE <= (!r_dataFNoc_51[50]);
            PADDR <= r_dataFNoc_51[49:42];
            PWDATA <= r_dataFNoc_51[41:10];
            state <= FINISH;
        end
        //W_WAIT: begin
        //    PENABLE <= 1'b1;
        //    PSEL <= 1'b1;
        //    PWRITE <= ~r_dataFNoc_51[50];
        //    PADDR <= r_dataFNoc_51[49:42];
        //    PWDATA <= r_dataFNoc_51[41:10];
        //    state <= FINISH;
        //end
        R_LOAD: begin
            PENABLE <= 1'b0;
            PSEL <= 1'b1;
            PWRITE <= (!r_dataFNoc_51[50]);
            PADDR <= r_dataFNoc_51[49:42];
            state <= R_EN;
        end
        R_EN: begin
            PENABLE <= 1'b1;
            PSEL <= 1'b1;
            PWRITE <= (!r_dataFNoc_51[50]);
            PADDR <= r_dataFNoc_51[49:42];
            r_apbrdata <= PRDATA;
            state <= FINISH;
        end
        FINISH: begin
            PENABLE <= 1'b0;
            PSEL <= 1'b0;
            PWRITE <= 1'b1;
            PADDR <= 8'b0;
            state <= IDLE;
        end
        default: begin
            state <= IDLE;
        end
        endcase
    end
end
    //-------根据给出的反馈信号将读出的数据放到输出的线上----//
    assign o_data2Noc_51 = {r_dataFNoc_51[50],r_dataFNoc_51[49:42],r_apbrdata,r_X,r_Y};
    //----------接入SPI--------//
//模块例化
SPI_control SPI_control_u(
.clk            (clk            ),
.rst_n          (rst_finish     ),

.PADDR          (PADDR          ),
.PENABLE        (PENABLE        ),
.PSEL           (PSEL           ),
.PWDATA         (PWDATA         ),
.PWRITE         (PWRITE         ),
.PRDATA         (PRDATA         ),

.SPI_interrupt(SPI_IRQ),
.sclk(sclk),
.miso(miso),
.mosi(mosi),
.nss (nss )

);

    
endmodule
