`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: hrq
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
// ��ģ�������Ž�I2Cģ���IO����
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module I2C2NoC(
    //�ⲿ�����ʱ��?
    input CLOCK,
    // NoC
    input rst_finish,
    input rst,
    input i_drvFNoc,
    output o_free2Noc,
    input [50:0] i_dataFNoc_51,

    output o_drv2Noc,
    input i_freeFNoc,
    output [50:0] o_data2Noc_51,

    // interrupt requerst
    output INTR,
    
    // I2C Serial interface signals
    
    input        FSEN,        //Full/(standard) Speed Enable, Set to 10x full/standard speed I2C bit rate
    input        HSEN,        //High Speed Enable, Set to 10x high speed I2C bit rate
    input        ISCL, ISDA, IFSDA,
    
    output       OSCL, OSDA,
    output       ENDRV,
    output       CKISO, DAISO, DAGND

    
    );

    //---------CPU�ӿ�----------//
(* dont_touch="true" *)reg  [2:0]  ADDRESS;
(* dont_touch="true" *)wire        RESETN;
(* dont_touch="true" *)reg         RD;         
(* dont_touch="true" *)reg         VAL;
(* dont_touch="true" *)reg   [7:0] WDATA,RDATA;
(* dont_touch="true" *)wire  [7:0] w_rdata;
(* dont_touch="true" *)
(* dont_touch="true" *)// ֱ����λ�ź�
                      assign RESETN = rst;
(* dont_touch="true" *)
(* dont_touch="true" *)// �����������?
// (* dont_touch="true" *)wire w_NoCRD = i_dataFNoc_51[50];
// (* dont_touch="true" *)wire w_NoCVAL = i_dataFNoc_51[49];
// (* dont_touch="true" *)wire [2:0] w_NoCaddress = i_dataFNoc_51[44:42];
// (* dont_touch="true" *)wire [7:0] w_NoCdata = i_dataFNoc_51[17:10];
    // 

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_freeFfifo1,w_drv2delay1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_writefire1, w_writefire2;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_mode0;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[23:0]r_middle_24;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[9:0] r_last_10;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0] r_dataFNoc;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo0;

    //--------------�׶�2�����д���߶���?-----//
        //��25Mʱ����FPGA�� һ������40ns��һ��delay8U��Լ10ns��������?����val���Ա�ϵͳʱ�Ӳɼ���Ҫ����40ns
    wire w_drv2fifo1_dalay1;
    wire w_drv2fifo1_dalay2;
    wire w_drv2fifo1_dalay3;
    wire w_drv2fifo1_dalay4;
    wire w_modelfire;

    (* dont_touch="true" *)cFifo3_I2C_1 cfifo3_0(
    .i_drive(i_drvFNoc),
    .o_free(),
    .i_freeNext(w_freeFfifo1),
    .o_driveNext(w_drv2delay1),
    .o_fire_3(w_firefifo0),
    .rst     (rst)
    );
    

    delay1U delay1_2  (.inR( w_firefifo0[1]),.outR(w_writefire1),.rst(rst));
    delay6U delay1_1  (.inR( w_firefifo0[2]),.outR(w_modelfire),.rst(rst));
   
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire0 = w_firefifo0[0] | w_modelfire;
    always@(posedge w_fire0 or negedge rst )begin
        if(!rst)begin
            r_mode0 <= 0;
            r_middle_24  <= 24'b0;
            r_last_10    <= 10'b1000100000;
        end
        else begin
            r_mode0 <= ~r_mode0;
        end
    end

    always@(posedge w_firefifo0[0] or negedge rst )begin
        if(!rst)begin
            r_dataFNoc <= 51'b0;
        end
        else begin
        //     r_dataFNoc[17:10] <= i_dataFNoc_51[17:10];
	    // r_dataFNoc[50]    <= i_dataFNoc_51[50];
	    // r_dataFNoc[49:42] <= i_dataFNoc_51[49:42];
        r_dataFNoc <= i_dataFNoc_51;
        end
    end
    


(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_model;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo2;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire       w_firefifo1,w_drv2fifo2,w_freeFfifo2,w_drv2fifo1,w_modelfire2,w_drv2Noc;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire       w_drv2delay2,w_drv2delay3,w_drv2delay4,w_drv2delay5,w_drv2delay6,w_drv2delay7,w_drv2delay8,w_drv2delay9,w_modelfire2_0,w_drv2delay10,w_drv2delay11,w_drv2delay12,w_drv2delay13,w_drv2delay14,w_drv2delay15,w_drv2delay16,w_drv2delay17,w_drv2delay18;

    assign o_free2Noc = w_freeFfifo2;


     delay8U delay1  (.inR(w_drv2delay1),       .outR(w_drv2delay2),.rst(rst));
     delay8U delay2  (.inR(w_drv2delay2), .outR(w_drv2delay3),.rst(rst));
     delay8U delay3  (.inR(w_drv2delay3), .outR(w_drv2delay4),.rst(rst));
     delay8U delay4  (.inR(w_drv2delay4), .outR(w_drv2delay5),.rst(rst));
     delay8U delay5  (.inR(w_drv2delay5), .outR(w_drv2delay6),      .rst(rst));
     delay8U delay6 (.inR(w_drv2delay6),       .outR(w_drv2delay7),       .rst(rst));
     delay8U delay7 (.inR(w_drv2delay7),       .outR(w_drv2delay8),       .rst(rst));
     delay8U delay8 (.inR(w_drv2delay8),       .outR(w_drv2delay9),       .rst(rst));
     delay8U delay9 (.inR(w_drv2delay9),       .outR(w_drv2delay10),       .rst(rst));
     delay8U delay10 (.inR(w_drv2delay10),       .outR(w_drv2delay11),       .rst(rst));
     delay8U delay11 (.inR(w_drv2delay11),       .outR(w_drv2delay12),       .rst(rst));
     delay8U delay12 (.inR(w_drv2delay12),       .outR(w_drv2delay13),       .rst(rst));
     delay8U delay13 (.inR(w_drv2delay13),       .outR(w_drv2delay14),       .rst(rst));
     delay8U delay14 (.inR(w_drv2delay14),       .outR(w_drv2delay15),       .rst(rst));
     delay8U delay15 (.inR(w_drv2delay15),       .outR(w_drv2delay17),       .rst(rst));    
     delay8U delay16 (.inR(w_drv2delay17),       .outR(w_drv2fifo1),       .rst(rst)); 


(* dont_touch="true" *) cFifo1 cfifo1(
    .i_drive(w_drv2fifo1),
    .o_free(w_freeFfifo1),
    .i_freeNext(w_freeFfifo2),
    .o_driveNext(w_drv2delay16),
    .o_fire_1(w_firefifo1),
    .rst(rst)
    );

delay8U delay17 (.inR(w_drv2delay16), .outR(w_drv2delay18),.rst(rst));
delay8U delay18  (.inR( w_drv2delay18),.outR(w_drv2fifo2),.rst(rst));

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire       w_drv2Noc1,w_drv2Noc2,w_drv2Noc3,w_modelfire2_1;
(* dont_touch="true" *) cFifo3_I2C cfifo2(
    .i_drive(w_drv2fifo2),
    .o_free(w_freeFfifo2),
    .i_freeNext(i_freeFNoc),
    .o_driveNext(w_drv2Noc1),
    .o_fire_3(w_firefifo2),
    .rst(rst)
    );


    delay8U delay2_1  (.inR( w_firefifo2[1]),.outR(w_writefire2),.rst(rst));
    delay4U delay2_2  (.inR( w_drv2Noc1),.outR(w_drv2Noc2),.rst(rst));
    delay8U delay2_7  (.inR( w_drv2Noc2),.outR(w_drv2Noc3),.rst(rst));
    delay8U delay2_3  (.inR( w_drv2Noc3),.outR(o_drv2Noc),.rst(rst));
    //delay8U delay2_2  (.inR( w_drv2delay15),.outR(w_writefire2),.rst(rst));
    delay8U delay2_4  (.inR( w_firefifo2[2]),.outR(w_modelfire2_0),.rst(rst));
    delay8U delay2_5  (.inR( w_modelfire2_0),.outR(w_modelfire2_1),.rst(rst)); 
    delay8U delay2_6  (.inR( w_modelfire2_1),.outR(w_modelfire2),.rst(rst));  
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire1 = w_firefifo2[0] | w_modelfire2;
    always@(posedge w_fire1 or negedge rst )begin
        if(!rst)begin
            r_model<=0;
        end
        else begin
            r_model<=~r_model;
        end
    end
    
    //-----------�����׶εĿ���----------//

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire = w_writefire1 | w_writefire2;
    always@(posedge w_fire or negedge rst )begin
        if(!rst)begin
            RD <= 1;
            VAL <= 0;
            ADDRESS <= 3'b0;
            WDATA <= 8'b0;
        end
        else if(r_mode0) 
        begin
            RD      <= r_dataFNoc[50];
            VAL     <= 1;
            ADDRESS <= r_dataFNoc[44:42];
            WDATA   <= r_dataFNoc[17:10];
        
        end
        
        else if(r_model)begin
            RD <= 1;
            VAL <= 0;
            ADDRESS <= 3'b0;
            WDATA <= 8'b0;
            

        end
    end
    
    always@(posedge w_firefifo1 or negedge rst )begin
        if(!rst)begin
            RDATA<=0;
        end
        else 
        begin
            //if(VAL == 1'b1 & RD == 1'b1)
            RDATA  <= w_rdata;
        end
    
    end
    //-------����Ƕ��Ļ���fire[1]ʱ��Ҫ�����ݶ�����-----//
    //-------�����д�Ļ���fire[0]ʱ�����ݷŵ�����-------//
    
    //-------���ݸ����ķ����źŽ����������ݷŵ����������?----//
    assign o_data2Noc_51 = {r_dataFNoc[50],r_dataFNoc[49:42],r_middle_24,RDATA,r_last_10};

    //-------����I2C---------//

    /**
    * ʱ��ѡ��HSENΪ���٣�FSENΪ����/��׼�ٶ�
    * ��Щʱ��ʹ�ܿ������ⲿ���ɣ�Ҳ����ʹ�ÿ�ѡ������ʱ�ӷ�������ϵͳʱ������
    * 
    */
    mi2cv2 U1 (
                .FSEN(FSEN), 
                .HSEN(HSEN), 

                .CLOCK(CLOCK), 
                .RESETN(rst_finish),
                .VAL(VAL), 
                .ADDRESS(ADDRESS), 
                .RD(RD), 
                .WDATA(WDATA), 
                .ISCL(ISCL), 
                .ISDA(ISDA), 
                .IFSDA(IFSDA),
                .RDATA(w_rdata), 
                .INTR(INTR), 
                .OSCL(OSCL), 
                .OSDA(OSDA), 
                .ENDRV(ENDRV), 
                .CKISO(CKISO), 
                .DAISO(DAISO), 
                .DAGND(DAGND)
                );



endmodule
