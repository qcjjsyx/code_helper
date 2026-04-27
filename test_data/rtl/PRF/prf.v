`timescale 1ns / 1ps


module prf (
    input   rst,
    //READ
    //Lanch <--> psr
    output[31:0]  o_psrDataToLaunch_32,    //给分派的读取到的psr的数据
    input         i_psrDriveFromLaunch_1,  //psr给分派的脉冲
    output        o_psrDriveToLaunch_1,
    input         i_psrFreeFromLaunch_1,   //分派来的读取psr数据的脉冲
    output        o_psrFreeToLaunch_1,
    //Lanch <--> prf
    input [7:0]   i_rsAddr_8,               //选择要读的prf
    input         i_prfDriveFromLaunch_1,   //分派来的读取prf数据的脉冲
    output        o_prfDriveToLaunch_1,
    input         i_prfFreeFromLaunch_1,
    output        o_prfFreeToLaunch_1,
    output[31:0]  o_prfDataToLaunch_32,
    //Exception <--> psr
    input         i_psrDriveFromExp_1,      //中断异常来的读取xpsr数据的脉冲
    output        o_psrDriveToExp_1,
    input         i_psrFreeFromExp_1,
    output        o_psrFreeToExp_1,
    output[31:0]  o_psrDataToExp_32,        //给中断异常读取到的xpsr的数据

    // WRITE
    //  WB <--> prf,psr  
    input [7:0]   i_rdAddr_8,              //选择要写入的prf
    input [3:0]   i_wbnzcv_4,                //要写入psr的[31:28]
    input [3:0]   i_wben_4 ,
    input [31:0]  i_rdDataToPrf_32,        //要写入prf的数据

    input         i_psrDriveFromWB_1,      //写数来的写psr脉冲
    output        o_psrFreeToWB_1,
    input         i_prfDriveFromWB_1,      //写数来的写prf脉冲
    output        o_prfFreeToWB_1,
   
    //Exception <--> psr
    input         i_psrwDriveFromExp_1,    //中断异常来的x写psr脉冲
    output        o_psrwFreeToExp_1,
    input [3:0]   i_expnzcv_4 ,            //要写入psr的[31:28]
    input [3:0]   i_expen_4
);

    localparam MSR_BASEPRL   = 8'h11;
    localparam MSR_FAULTMASK = 8'h13;
    localparam MSR_PRIMASK   = 8'h10;
    localparam MSR_CONTROL   = 8'h14;
    localparam MSR_PSR       = 8'h03;

(* dont_touch="true" *)reg [31:0] r_baseprl_32;
(* dont_touch="true" *)reg [31:0] r_faultmask_32;
(* dont_touch="true" *)reg [31:0] r_primask_32;
(* dont_touch="true" *)reg [31:0] r_control_32;
(* dont_touch="true" *)reg [31:0] r_xpsr_32;(* dont_touch="true" *)
(* dont_touch="true" *)reg [31:0] r_prfValue_32;
(* dont_touch="true" *)reg [31:0] r_psrValue_32;
(* dont_touch="true" *)reg [31:0] r_psrValue2_32;(* dont_touch="true" *)
(* dont_touch="true" *)wire w_fire_5[4:0];
(* dont_touch="true" *)wire w_read;
(* dont_touch="true" *)wire w_driveTopsr, w_freeFrompsr;
(* dont_touch="true" *)wire[7:0] w_data_8;

/*
| 31 30 29 28 27 | 26 25 24 | 23 ... 20 | 19 ... 16 | 15 ... 10 | 9 | 8 ..... 0 |
|  N  Z  C  V  Q | ICI/IT   | Reserved  | Reserved  | ICI/IT    | R | Exception |
|----------------|----------|-----------|-----------|-----------|---|-----------|
|     APSR       |   EPSR   |           |           |   EPSR    |   |    IPSR   |
*/
//Read
//Lanch <--> prf
(* dont_touch="true" *)cFifo1 cFifo1_prf1(
        .i_drive(i_prfDriveFromLaunch_1), 
        .i_freeNext(i_prfFreeFromLaunch_1), 
        .rst(rst), 
        .o_free(o_prfFreeToLaunch_1), 
        .o_driveNext(o_prfDriveToLaunch_1), 
        .o_fire_1(w_fire_5[0])
    );

    always @(posedge i_prfDriveFromLaunch_1 or negedge rst) begin
        if (!rst) begin
            r_prfValue_32 <= 32'b0;
        end 
        else begin
            case (i_rsAddr_8)
            MSR_BASEPRL:    begin  r_prfValue_32 <= r_baseprl_32;   end
            MSR_FAULTMASK:  begin  r_prfValue_32 <= r_faultmask_32; end
            MSR_PRIMASK:    begin  r_prfValue_32 <= r_primask_32;   end
            MSR_CONTROL:    begin  r_prfValue_32 <= r_control_32;   end

            default:        begin  r_prfValue_32 <= 32'b0;          end
            endcase           
        end
    end
    assign o_prfDataToLaunch_32 = r_prfValue_32;
//Lanch <--> psr
(* dont_touch="true" *)cFifo1 cFifo1_prf2 (
        .i_drive    ( i_psrDriveFromLaunch_1 ), 
        .i_freeNext ( i_psrFreeFromLaunch_1  ), 
        .rst        ( rst                    ), 
        .o_free     ( o_psrFreeToLaunch_1    ), 
        .o_driveNext( o_psrDriveToLaunch_1   ), 
        .o_fire_1   ( w_fire_5[1]            )
    );
    always @(posedge i_psrDriveFromLaunch_1 or negedge rst) begin
        if (!rst) begin
            r_psrValue_32 <= 32'b0;
        end 
        else begin
          r_psrValue_32 <= r_xpsr_32;

        end
    end
    assign o_psrDataToLaunch_32 = r_psrValue_32;
//Excption <--> psr
(* dont_touch="true" *)cFifo1 cFifo1_prf3 (
        .i_drive    ( i_psrDriveFromExp_1  ), 
        .i_freeNext ( i_psrFreeFromExp_1   ), 
        .rst        ( rst                  ), 
        .o_free     ( o_psrFreeToExp_1     ), 
        .o_driveNext( o_psrDriveToExp_1    ), 
        .o_fire_1   ( w_fire_5[2]          )
    );  
    always @(posedge i_psrDriveFromExp_1 or negedge rst) begin
        if (!rst) begin
            r_psrValue2_32 <= 32'b0;
        end 
        else begin
            r_psrValue2_32  <= r_xpsr_32;

        end
    end
    assign o_psrDataToExp_32 = r_psrValue2_32;
//WRITE
//write prf  
(* dont_touch="true" *)cLastFifo1 cLastFifo1_prf1 (
        .i_drive      ( i_prfDriveFromWB_1), 
        .rst          ( rst               ), 
        .o_free       ( o_prfFreeToWB_1   ), 
        .o_driveNext  (                   ), 
        .o_fire_1     ( w_fire_5[3]       )
    );
    always @ (posedge i_prfDriveFromWB_1 or negedge rst) begin
        if(!rst) begin
            r_baseprl_32   <= 32'b0;  
            r_faultmask_32 <= 32'b0; 
            r_primask_32   <= 32'b0;   
            r_control_32   <= 32'b0;
            end 
            else begin
                case (i_rdAddr_8) 
                    MSR_BASEPRL:   begin    r_baseprl_32   <= i_rdDataToPrf_32;    end
                    MSR_FAULTMASK: begin    r_faultmask_32 <= i_rdDataToPrf_32;    end
                    MSR_PRIMASK:   begin    r_primask_32   <= i_rdDataToPrf_32;    end
                    MSR_CONTROL:   begin    r_control_32   <= i_rdDataToPrf_32;    end
                    default:       begin    end
                endcase
            end
        end

//write psr
(* dont_touch="true" *)cMutexMerge2_8b cMutexMerge2_8b(
        .rst         (  rst                       ), 
        .i_drive0    (  i_psrwDriveFromExp_1      ), 
        .i_drive1    (  i_psrDriveFromWB_1        ),
        .o_free0     (  o_psrwFreeToExp_1         ), 
        .o_free1     (  o_psrFreeToWB_1           ), 
        .i_data0_8   (  {i_expnzcv_4,i_expen_4}   ),
        .i_data1_8   (  {i_wbnzcv_4,i_wben_4}     ),
        .o_data_8    (  w_data_8                  ),
        .o_driveNext (  w_driveTopsr              ), 
        .i_freeNext  (  w_freeFrompsr             )
    ); 


(* dont_touch="true" *)cLastFifo1 cLastFifo2_prf2 (
        .i_drive      (  w_driveTopsr   ), 
        .rst          (  rst            ), 
        .o_free       (  w_freeFrompsr  ), 
        .o_driveNext  (                 ), 
        .o_fire_1     (  w_fire_5[4]    )
    );  

// xpsr reference:
// w_wen_3[2] : write APSR when 1
/*              
                w_mask_5[0] : APSR.Q
                w_mask_5[1] : APSR.V
                w_mask_5[2] : APSR.C
                w_mask_5[3] : APSR.Z
                w_mask_5[4] : APSR.N
*/
// w_wen_3[1] : write EPSR when 1 
// w_wen_3[0] : write IPSR when 1
integer i;
    always @(posedge w_fire_5[4] or negedge rst) begin
        if (!rst) begin
            r_xpsr_32 <= 32'h010000000;
        end 
        else begin
            //update APSR
            if(w_wen_3[2])begin
                for(i=0;i<5;i=i+1)begin
                    r_xpsr_32[i + 27] <= (w_mask_5[i]) ? w_xpsr_32[i + 27] : r_xpsr_32[i + 27];
                end
            end
            //update EPSR
            if(w_wen_3[1])begin
               {r_xpsr_32[26:25],r_xpsr_32[15:10]} <= {w_xpsr_32[26:25],w_xpsr_32[15:10]};
            end
            //update IPSR
            if(w_wen_3[0])begin
                r_xpsr_32[8:0] <= w_xpsr_32[8:0];
            end
        end
    end
    // always @(posedge w_fire_5[4] or negedge rst) begin
    //     if (!rst) begin
    //         r_psr_32 <= 32'b0;
    //     end 
    //     else begin
    //         case(w_data_8[3:0])
    //         4'b0000:begin
    //             r_psr_32[31:28] <= r_psr_32[31:28];
    //         end
    //         4'b0001:begin
    //             r_psr_32[28]    <= w_data_8[4];
    //         end
    //         4'b0010:begin
    //             r_psr_32[29]    <= w_data_8[5];
    //         end
    //         4'b0011:begin
    //             r_psr_32[29:28] <= w_data_8[5:4];
    //         end
    //         4'b0100:
    //         begin
    //             r_psr_32[30]    <= w_data_8[6];
    //         end
    //         4'b0101:begin
    //             r_psr_32[30]    <= w_data_8[6];
    //             r_psr_32[28]    <= w_data_8[4];
    //         end
    //         4'b0110:begin
    //             r_psr_32[30:29] <= w_data_8[6:5];
    //         end
    //         4'b0111:begin
    //             r_psr_32[30:28] <= w_data_8[6:4];
    //         end
    //         4'b1000:begin
    //             r_psr_32[31]    <= w_data_8[7];
    //         end
    //         4'b1001:begin
    //             r_psr_32[28]    <= w_data_8[4];
    //             r_psr_32[31]    <= w_data_8[7];
    //         end
    //         4'b1010:begin
    //             r_psr_32[29]    <= w_data_8[5];
    //             r_psr_32[31]    <= w_data_8[7];
    //         end
    //         4'b1011:begin
    //             r_psr_32[29:28] <= w_data_8[5:4];
    //             r_psr_32[31]    <= w_data_8[7];
    //         end
    //         4'b1100:
    //         begin
    //             r_psr_32[31:30] <= w_data_8[7:6];
    //         end
    //         4'b1101:begin
    //             r_psr_32[31:30] <= w_data_8[7:6];
    //             r_psr_32[28]    <= w_data_8[4];
    //         end
    //         4'b1110:begin
    //             r_psr_32[31:29] <= w_data_8[7:5];
    //         end
    //         4'b1111:begin
    //             r_psr_32[31:28] <= w_data_8[7:4];
    //         end
    //         endcase

    //     end
    // end
endmodule