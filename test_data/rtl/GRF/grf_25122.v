`timescale 1ns / 1ps


module grf (
    input   rst,
    // launch <--> grf
    input [7:0]     i_rsAddr_8,              
    output[63:0]    o_grfDataToLaunch_64,    
    input           i_grfDriveFromLaunch_1,  
    output          o_grfDriveToLaunch_1,
    input           i_grfFreeFromLaunch_1,
    output          o_grfFreeToLaunch_1,

    //EXE <--> grf
    input [7:0]     i_rs2Addr_8,          
    output[63:0]    o_grfDataToExe_64,    
    input           i_driveFromExe_1,     
    output          o_grfDriveToExe_1,
    input           i_grfFreeFromExe_1,
    output          o_grfFreeToExe_1,

    //LSU <--> grf
    //read
    input [7:0]     i_rs3Addr_8,          
    output[63:0]    o_grfDataToLsu_64,    
    input           i_driveFromLsu_1,     
    output          o_grfDriveToLsu_1,
    input           i_grfFreeFromLsu_1,
    output          o_grfFreeToLsu_1,
    //write  
    input [7:0]     i_lsuAddr_8,           
    input [63:0]    i_lsuDataToGrf_64,     
    input [1:0]     i_lsuWen_2,
    input           i_grfwDriveFromLsu_1, 
    output          o_grfwFreeToLsu_1,   
 
    // WB <--> grf
    //read 
    input [7:0]     i_rs4Addr_8,           
    output[63:0]    o_grfDataToWb_64,     
    input           i_driveFromWb_1,      
    output          o_grfDriveToWb_1,
    input           i_grfFreeFromWb_1,
    output          o_grfFreeToWb_1,
    //WRITE      
    input [7:0]     i_wbAddr_8,           
    input [63:0]    i_wbDataToGrf_64,     
    input [1:0]     i_wbWen_2,            
    input           i_grfwDriveFromWB_1,   
    output          o_grfwFreeToWB_1,

    //Exception
    //read
    input           i_driveFromExp_1,      
    output          o_grfDriveToExp_1,
    input           i_grfFreeFromExp_1,
    output          o_grfFreeToExp_1,
    output[191:0]   o_grfDataToExp_192,   
    //write
    input [7:0]     i_expAddr_8,           
    input [63:0]    i_expDataToGrf_64,     
    input [1:0]     i_expWen_2,
    input           i_grfwDriveFromExp_1,  
    output          o_grfwFreeToExp_1     
);

(* dont_touch="true" *)wire          w_FreefromWrite,w_driveToWrite;
(* dont_touch="true" *)wire[5:0]     w_fire_6;
(* dont_touch="true" *)wire[3:0]     w_index2_4,w_index1_4,w_lsuindex1_4,w_lsuindex2_4,w_exeindex1_4,w_exeindex2_4,w_lauindex1_4,w_lauindex2_4,w_wbindex1_4,w_wbindex2_4;



(* dont_touch="true" *)wire[73:0]    w_data_74;
(* dont_touch="true" *)reg[191:0]    r_rsValue_192;
(* dont_touch="true" *)reg[31:0]     r_rsValue_32[7:0];
(* dont_touch="true" *)reg[31:0]     regs[20:0];
    //launch <--> grf
assign w_lauindex1_4 = i_rsAddr_8[3:0];
assign w_lauindex2_4 = i_rsAddr_8[7:4];
(* dont_touch="true" *)cFifo1_grf cFifo1_1(
        .i_drive    (  i_grfDriveFromLaunch_1  ),
        .i_freeNext (  i_grfFreeFromLaunch_1   ),
        .rst        (  rst                     ),
        .o_free     (  o_grfFreeToLaunch_1     ),
        .o_driveNext(  w_fire_6[0]             ),
        .o_fire_1   (               )
    );
    wire w_grfDriveToLaunch_1;
(* dont_touch="true" *) delay4U cFifo1_1Delay0(.inR(w_fire_6[0]), .outR(w_grfDriveToLaunch_1), .rst(rst)); 
(* dont_touch="true" *) delay8U cFifo1_1Delay1(.inR(w_fire_6[0]), .outR(o_grfDriveToLaunch_1), .rst(rst)); 
     always @(posedge w_grfDriveToLaunch_1 or negedge rst) begin

        if (!rst) begin
            r_rsValue_32[0] <= 32'b0;
            r_rsValue_32[1] <= 32'b0;
        end else begin
            r_rsValue_32[0] <= regs[w_lauindex1_4];
            r_rsValue_32[1] <= regs[w_lauindex2_4];            
        end
    end


    assign o_grfDataToLaunch_64 = {r_rsValue_32[1], r_rsValue_32[0]};

    //EXE <--> grf
    assign w_exeindex1_4 = i_rs2Addr_8[3:0];
    assign w_exeindex2_4 = i_rs2Addr_8[7:4];
(* dont_touch="true" *)cFifo1_grf cFifo1_2(
        .i_drive    (  i_driveFromExe_1    ),
        .i_freeNext (  i_grfFreeFromExe_1  ),
        .rst        (  rst                 ),
        .o_free     (  o_grfFreeToExe_1    ),
        .o_driveNext(  o_grfDriveToExe_1   ),
        .o_fire_1   (  w_fire_6[1]         )
    );
     always @(posedge w_fire_6[1] or negedge rst) begin

        if (!rst) begin
            r_rsValue_32[2] <= 32'b0;
            r_rsValue_32[3] <= 32'b0;
        end else begin
            r_rsValue_32[2] <= regs[w_exeindex1_4];
            r_rsValue_32[3] <= regs[w_exeindex2_4];            
        end
    end
    assign o_grfDataToExe_64 = {r_rsValue_32[3], r_rsValue_32[2]};

    //LSU <--> grf
assign w_lsuindex1_4 = i_rs3Addr_8[3:0];
assign w_lsuindex2_4 = i_rs3Addr_8[7:4];
(* dont_touch="true" *)cFifo1_grf cFifo1_3(
        .i_drive    (  i_driveFromLsu_1    ),
        .i_freeNext (  i_grfFreeFromLsu_1  ),
        .rst        (  rst                 ),
        .o_free     (  o_grfFreeToLsu_1    ),
        .o_driveNext(  w_fire_6[2]         ),
        .o_fire_1   (                      )
    );
(* dont_touch="true" *) delay8U cFifo1_3Delay0(.inR(w_fire_6[2]), .outR(o_grfDriveToLsu_1), .rst(rst)); 
     always @(posedge w_fire_6[2] or negedge rst) begin

        if (!rst) begin
            r_rsValue_32[4] <= 32'b0;
            r_rsValue_32[5] <= 32'b0;
        end else begin
            r_rsValue_32[4] <= regs[w_lsuindex1_4];
            r_rsValue_32[5] <= regs[w_lsuindex2_4];            
        end
    end
    assign o_grfDataToLsu_64 = {r_rsValue_32[5], r_rsValue_32[4]};
// WB <--> grf
//Read
    assign w_wbindex1_4 = i_rs4Addr_8[3:0];
    assign w_wbindex2_4 = i_rs4Addr_8[7:4];
(* dont_touch="true" *)cFifo1_grf cFifo1_4(
        .i_drive    (  i_driveFromWb_1     ),
        .i_freeNext (  i_grfFreeFromWb_1   ),
        .rst        (  rst                 ),
        .o_free     (  o_grfFreeToWb_1     ),
        .o_driveNext(  o_grfDriveToWb_1    ),
        .o_fire_1   (  w_fire_6[3]         )
    );
     always @(posedge w_fire_6[3] or negedge rst) begin

        if (!rst) begin
            r_rsValue_32[6] <= 32'b0;
            r_rsValue_32[7] <= 32'b0;
        end else begin
            r_rsValue_32[6] <= regs[w_wbindex1_4]; 
            r_rsValue_32[7] <= regs[w_wbindex2_4];           
        end
    end
    assign o_grfDataToWb_64 = {r_rsValue_32[7], r_rsValue_32[6]};

// Exp <--> grf
(* dont_touch="true" *)cFifo1_grf cFifo1_5(
        .i_drive    (  i_driveFromExp_1    ),
        .i_freeNext (  i_grfFreeFromExp_1  ),
        .rst        (  rst                 ),
        .o_free     (  o_grfFreeToExp_1    ),
        .o_driveNext(  o_grfDriveToExp_1   ),
        .o_fire_1   (  w_fire_6[5]         )
    );
     always @(posedge w_fire_6[5] or negedge rst) begin

        if (!rst) begin
            r_rsValue_192 <= 192'b0;
        end else begin
            r_rsValue_192 <= {regs[14][31:0],regs[12][31:0],regs[3][31:0],regs[2][31:0],regs[1][31:0],regs[0][31:0]};          
        end
    end
    assign o_grfDataToExp_192 = r_rsValue_192;

//WRITE
// assign w_driveToWrite = i_grfwDriveFromWB_1 | i_grfwDriveFromLsu_1 | i_grfwDriveFromExp_1;
// assign o_grfwFreeToLsu_1 = i_grfwDriveFromLsu_1 ;
//assign o_grfwFreeToExp_1 = (i_grfwDriveFromExp_1 == 1'b1)? w_FreefromWrite : 1'b0;
//assign o_grfwFreeToWB_1    = i_grfwDriveFromWB_1; //修改--ldj 10.30

// 11.4 hrq 新增了写接口
(* dont_touch="true" *)cMutexMerge3_end_74b cMutexMerge3_end_74b(
        .rst         (  rst                       ), 
        .i_drive0    (  i_grfwDriveFromLsu_1      ), 
        .i_drive1    (  i_grfwDriveFromWB_1       ),
        .i_drive2    (  i_grfwDriveFromExp_1      ),
        .o_free0     (  o_grfwFreeToLsu_1         ), 
        .o_free1     (  o_grfwFreeToWB_1          ), 
        .o_free2     (  o_grfwFreeToExp_1         ), 
        .i_data0_74  (  {i_lsuWen_2, i_lsuAddr_8, i_lsuDataToGrf_64 } ),
        .i_data1_74  (  {i_wbWen_2 , i_wbAddr_8 , i_wbDataToGrf_64  } ),
        .i_data2_74  (  {i_expWen_2, i_expAddr_8, i_expDataToGrf_64 } ),
        .o_data_74   (  w_data_74                ),
        .o_driveNext (  w_driveToWrite           ), 
        .i_freeNext  (  w_FreefromWrite          )
    );
(* dont_touch="true" *)cLastFifo1 cLastFifo1_grf(
        .i_drive    (  w_driveToWrite      ), 
        .rst        (  rst                 ), 
        .o_free     (  w_FreefromWrite     ), 
        .o_driveNext(                      ), 
        .o_fire_1   (  w_fire_6[4]         )
    );
integer i;
assign w_index1_4 = w_data_74[71:68];
assign w_index2_4 = w_data_74[67:64];
always @(posedge w_fire_6[4] or negedge rst) begin
        if (!rst) begin
            for(i=0;i<21;i=i+1)                        
                regs[i]	<= 32'b0;
        end
        else begin 
            if(w_data_74[73:72] == 2'b10) begin 
                regs[w_index1_4] <= w_data_74[63:32];
            end
            else if(w_data_74[73:72] == 2'b01)begin
                regs[w_index2_4] <= w_data_74[31:0];
	        end
            else if(w_data_74[73:72] == 2'b11)begin
                regs[w_index2_4] <= w_data_74[31:0];
                regs[w_index1_4] <= w_data_74[63:32];
                end
            end
        end    

endmodule
