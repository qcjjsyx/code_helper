`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: lu yh
// 
// Create Date: 2024/08/01 10:22:28
// Design Name: 
// Module Name: UARTInterface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// ��ģ�������Ž�UARTģ���IO����
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module NoCUART1(
    //Clock from outside
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input CLOCK,
    
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
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output IRQ,
    // UART Serial interface signals
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       RCLK,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input       NDCD, NRI, NDSR, NCTS, SIN, RCLK_BAUD, BRGE,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output      NOUT2, NOUT1, NRTS, NDTR, SOUT, BAUD
    
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0]   r_dataFNoc_51;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [23:0]   r_dataHigh;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [4:0]    r_X;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [4:0]    r_Y;
    //---------------要进入UART的实际值-----------------//
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] ADDRESS = r_dataFNoc_51[44:42];
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire RD = r_dataFNoc_51[50];
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg  VAL;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [7:0] WDATA = r_dataFNoc_51[17:10];
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire NDVL,RXRDY,TXRDY,ACK;

    //---------------网络进入的数据在第一个fifo的第一个fire暂存------//
   
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [7:0] w_rdata;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg  [7:0] ReceiveData;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_drv2fifo1,w_freeFfifo1;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [1:0] w_firefifo0;
    
    wire w_drv2Pmt,w_freeFPmt; 
    cFifo2 cfifo0(
    .i_drive        (i_drvFNoc      ),
    .o_free         (o_free2Noc     ),
    .i_freeNext     (w_freeFPmt     ),
    .o_driveNext    (w_drv2Pmt      ),
    .o_fire_2       (w_firefifo0    ),
    .rst            (rst            )
    );

    cPmtFifo1 pmtAck (
        .rst(rst),
        .i_drive(w_drv2Pmt),
        .o_free(w_freeFPmt),
        .pmt(ACK),
        .o_driveNext(w_drv2fifo1),
        .i_freeNext(w_freeFfifo1)
    );

    always@(posedge w_firefifo0[0] or negedge rst)begin
        if(!rst) begin
            r_dataFNoc_51<=0;
            r_dataHigh <= 0;
            r_X <= 0;
            r_Y <= 0;
        end 
        else begin
            r_dataFNoc_51 <= i_dataFNoc_51;
            r_X <= 5'b10001;
            r_Y <= 5'b00000;
        end
    end
   
    //-----------------第二个fifo关闭读写过程----------------//
    wire  w_firefifo1,w_drv2Noc_delay,w_drv2Noc_delay1,w_drv2Noc_delay2,w_drv2fifo1_delay;
	delay16U delay11 (.inR(w_drv2fifo1), .outR(w_drv2fifo1_delay),.rst(rst));
    cFifo1 cfifo1(
    .i_drive        (w_drv2fifo1_delay  ),
    .o_free         (w_freeFfifo1       ),
    .i_freeNext     (i_freeFNoc         ),
    .o_driveNext    (w_drv2Noc_delay    ),
    .o_fire_1       (w_firefifo1        ),
    .rst            (rst                )
    );

    delay64U delay8 (.inR(w_drv2Noc_delay), .outR(w_drv2Noc_delay1),.rst(rst));
    delay32U delay9 (.inR(w_drv2Noc_delay1), .outR(w_drv2Noc_delay2),.rst(rst));
    delay8U delay10 (.inR(w_drv2Noc_delay2), .outR(o_drv2Noc),.rst(rst));
       
    reg in;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire = w_firefifo0[1] | w_firefifo1;
    always@(posedge w_fire or negedge rst )begin
        if(!rst)begin
            in<=0;
            ReceiveData <= 0;
        end
        else begin
            in<=~in;
            //在关掉的同时写数据，因为第二个周期上升沿读出来的数据依然是不稳定的
            ReceiveData <= w_rdata;
        end
    end

    //-----------异步转同步逻辑--------------//
    reg in_r;
    always@(posedge CLOCK or negedge rst )begin
    if(!rst)begin
	   in_r   <= 0;
    end
    else begin
	   in_r    <= in;
    end
    end
    //在时钟上升沿检测
    reg [2:0] state;
    always@(posedge CLOCK or negedge rst )begin
        if(!rst)begin
            state   <= 0;
            VAL     <= 0;
        end
        else if(in_r) 
        begin
            //第一阶段
           if(state==0)begin
            state       <= state+1;
            VAL         <= 1;
           end
           //第二阶段
           else if(state==1)begin
            VAL         <= 0;
            state       <= state+1;
           end
           else begin
            VAL         <= 0;
            state       <= 3;
           end
        end
        else begin
            state   <= 0;
        end
    end


    assign o_data2Noc_51 = {r_dataFNoc_51[50],r_dataFNoc_51[49:42],r_dataHigh,ReceiveData,r_X,r_Y};
    //----------UART instance--------//
    m16550s uart_instance (
        .CLOCK(CLOCK),
        .RESETN(rst),
        .ADDRESS(ADDRESS),
        .WDATA(WDATA),
        .RD(RD),
        .VAL(VAL),
        .RCLK(RCLK),
        .RCLK_BAUD(RCLK_BAUD),
        .BRGE(BRGE),
        .NDCD(NDCD),
        .NRI(NRI),
        .NDSR(NDSR),
        .NCTS(NCTS),
        .SIN(SIN),
        .RDATA(w_rdata),
        .IRQ(IRQ),
        .ACK(ACK),
        .NDVL(NDVL),
        .NOUT2(NOUT2),
        .NOUT1(NOUT1),
        .NRTS(NRTS),
        .NDTR(NDTR),
        .SOUT(SOUT),
        .BAUD(BAUD),
        .TXRDY(TXRDY),
        .RXRDY(RXRDY)
    );

    
endmodule
