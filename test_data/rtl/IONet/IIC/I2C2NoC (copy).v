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
// ????????????????????????I2C????????IO????????
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module I2C2NoC(
    //?????????????????????
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

    //---------CPU??????----------//
(* dont_touch="true" *)reg  [2:0]  ADDRESS;
(* dont_touch="true" *)wire        RESETN;
(* dont_touch="true" *)reg         RD;         
(* dont_touch="true" *)reg         VAL;
(* dont_touch="true" *)reg   [7:0] WDATA,RDATA;
(* dont_touch="true" *)wire  [7:0] w_rdata;
(* dont_touch="true" *)
(* dont_touch="true" *)// ??????????????????
                      assign RESETN = rst;
(* dont_touch="true" *)
(* dont_touch="true" *)// ???????????????????????
// (* dont_touch="true" *)wire w_NoCRD = i_dataFNoc_51[50];
// (* dont_touch="true" *)wire w_NoCVAL = i_dataFNoc_51[49];
// (* dont_touch="true" *)wire [2:0] w_NoCaddress = i_dataFNoc_51[44:42];
// (* dont_touch="true" *)wire [7:0] w_NoCdata = i_dataFNoc_51[17:10];
    // 

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_freeFfifo1,w_drv2delay1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_mode0;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[23:0]r_middle_24;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg[9:0] r_last_10;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0] r_dataFNoc;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo0;

    (* dont_touch="true" *)cFifo3_I2C_1 cfifo3_0(
    .i_drive(i_drvFNoc),
    .o_free(o_free2Noc),
    .i_freeNext(w_freeFfifo1),
    .o_driveNext(w_drv2delay1),
    .o_fire_3(w_firefifo0),
    .rst     (rst)
    );
    
    //????25M??????????FPGA???? ??????????????40ns??????????delay8U??????10ns?????????????????????????val??????????????????????????????????????40ns
    wire w_drv2fifo1_dalay1;
    wire w_drv2fifo1_dalay2;
    wire w_drv2fifo1_dalay3;
    wire w_drv2fifo1_dalay4;
    delay8U delay1 (.inR(w_drv2delay1),       .outR(w_drv2fifo1_dalay1),.rst(rst));
    delay8U delay2 (.inR(w_drv2fifo1_dalay1), .outR(w_drv2fifo1_dalay2),.rst(rst));
    delay8U delay3 (.inR(w_drv2fifo1_dalay2), .outR(w_drv2fifo1_dalay3),.rst(rst));
    delay8U delay4 (.inR(w_drv2fifo1_dalay3), .outR(w_drv2fifo1_dalay4),.rst(rst));
    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire0 = w_firefifo0[0] | w_firefifo0[2];
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
            r_dataFNoc <= i_dataFNoc_51;
        end
    end
    
    //--------------??????2???????????????????????????-----//
    
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_model;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_firefifo2;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire       w_firefifo1,w_drv2fifo2,w_freeFfifo2,w_drv2fifo1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire       w_drv2delay5,w_drv2delay6,w_drv2delay7,w_drv2delay8,w_drv2delay9,w_drv2delay10,w_drv2delay11,w_drv2delay12,w_drv2delay13;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay8U delay5 (.inR(w_drv2fifo1_dalay4), .outR(w_drv2delay5),.rst(rst));
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)delay4U delay6 (.inR(w_drv2delay5), .outR(w_drv2fifo1),.rst(rst));
// delay1Unit delay10 (.inR(w_drv2delay9), .outR(w_drv2fifo1),.rst(rst));

(* dont_touch="true" *) cFifo1 cfifo1(
    .i_drive(w_drv2fifo1),
    .o_free(w_freeFfifo1),
    .i_freeNext(w_freeFfifo2),
    .o_driveNext(w_drv2delay6),
    .o_fire_1(w_firefifo1),
    .rst(rst)
    );

    (* dont_touch="true" *)delay8U delay7 (.inR(w_drv2delay6), .outR(w_drv2delay7),.rst(rst));
//2.19
    (* dont_touch="true" *)delay8U delay8 (.inR(w_drv2delay7), .outR(w_drv2delay8),.rst(rst));
    (* dont_touch="true" *)delay8U delay9 (.inR(w_drv2delay8), .outR(w_drv2delay9),.rst(rst));
    (* dont_touch="true" *)delay8U delay10 (.inR(w_drv2delay9), .outR(w_drv2delay10),.rst(rst));
    (* dont_touch="true" *)delay8U delay11 (.inR(w_drv2delay10), .outR(w_drv2delay11),.rst(rst));
    (* dont_touch="true" *)delay8U delay12 (.inR(w_drv2delay11), .outR(w_drv2delay12),.rst(rst));
    (* dont_touch="true" *)delay8U delay13 (.inR(w_drv2delay12), .outR(w_drv2delay13),.rst(rst));
    (* dont_touch="true" *)delay8U delay14 (.inR(w_drv2delay13), .outR(w_drv2fifo2),.rst(rst));
 (* dont_touch="true" *)delay8U delay14 (.inR(w_drv2delay1), .outR(w_drv2fifo2),.rst(rst));
    
(* dont_touch="true" *) cFifo3_I2C cfifo2(
    .i_drive(w_drv2fifo2),
    .o_free(w_freeFfifo2),
    .i_freeNext(i_freeFNoc),
    .o_driveNext(o_drv2Noc),
    .o_fire_3(w_firefifo2),
    .rst(rst)
    );

    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire1 = w_firefifo2[0] | w_firefifo2[2];
    always@(posedge w_fire1 or negedge rst )begin
        if(!rst)begin
            r_model<=0;
        end
        else begin
            r_model<=~r_model;
        end
    end
    
    //-----------??????????????????????----------//

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_fire = w_firefifo0[1] | w_firefifo2[1];
    always@(posedge w_fire or negedge rst )begin
        if(!rst)begin
            RD <= 1;
            VAL <= 0;
            ADDRESS <= 3'b0;
            WDATA <= 8'b0;
        end
        else if(r_mode0) 
        begin
            RD  <= r_dataFNoc[50];
            VAL <= 1;
            ADDRESS <= r_dataFNoc[44:42];
            WDATA <= r_dataFNoc[17:10];
        
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
    //-------??????????????????????fire[1]??????????????????????????????-----//
    //-------??????????????????????fire[0]??????????????????????????-------//
    
    //-------???????????????????????????????????????????????????????????????????????????----//
    assign o_data2Noc_51 = {r_dataFNoc[50],r_dataFNoc[49:42],r_middle_24,RDATA,r_last_10};

    //-------????????I2C---------//

    /**
    * ????????????HSEN????????????FSEN??????????/????????????
    * ???????????????????????????????????????????????????????????????????????????????????????????????????????????????
    * 
    */
    mi2cv2 U1 (
                .FSEN(FSEN), 
                .HSEN(HSEN), 

                .CLOCK(CLOCK), 
                .RESETN(rst),
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
