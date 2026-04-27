`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 16:22:29
// Design Name: 
// Module Name: wb
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
module wb(
input i_lsuDriveToWB, //lsu > WB
input i_driveMutexMerge2,
input i_wbFreeFromGRF,
output [7:0] o_WBdataToGRF_8, //WB > GRF w_grfAddrH_4,w_grfAddrL_4
output o_WBfreeGRF, //freeGRF
input i_wbFreeFromReadGRF,
input [63:0] i_dataFromGRF_64,//GRF data > WB
output o_wbDriveReadGRF,
input [102:0] i_data_103, //all
output o_drive_prf,
output [39:0] o_prfData_40,
input i_wbFreeFROMPrf,
output o_drive_pc,
output [31:0] o_pcData_32,
input i_wbFreeFromIF,
output o_drive_grf,
output [73:0] o_grfData_74, 
output o_drive_xpsr,
output [3:0] o_xpsrData_4,
input i_wbFreeFromXpsr,
output o_free, 
output o_bitOpOver_1,   
input rst
);
    
(*KEEP="TRUE"*) wire [7:0] w_prfAddr_8;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrH_4;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrL_4;
(*KEEP="TRUE"*) wire [63:0] w_data_64,w_dataTopro_64;
(*KEEP="TRUE"*) wire [1:0] w_rdWen_2;
(*KEEP="TRUE"*) wire [4:0] w_msbit_5,w_lsbit_5;
(*KEEP="TRUE"*) wire w_writeRd_1,w_bfc_1,w_bfi_1,w_s_1,w_sbfx,w_ubfx;
(*KEEP="TRUE"*) wire [3:0] w_nzcv_4;
(*KEEP="TRUE"*) wire w_msr_1,w_drivecFifo1,w_freecFifo1,w_selector_1;
(*KEEP="TRUE"*) wire w_driveSelector1, w_drive1Selector1, w_driveSelector2,w_freeSplitter1,w_freeSplitter2;
(*KEEP="TRUE"*) wire w_freeSelector13,w_freeSelector15,w_freeSelector16,w_freeSelector22;
(*KEEP="TRUE"*) wire [97:0] w_temp1_98;
(*KEEP="TRUE"*) wire [4:0] w_temp2_5;
(*KEEP="TRUE"*) wire w_driveMutexMerge11,w_driveMutexMerge12,w_driveMutexMerge2;
(*KEEP="TRUE"*) wire [73:0] w_grf1Data_74,w_prodata_74;
(*KEEP="TRUE"*) wire [86:0] w_grf2Data_87;
(*KEEP="TRUE"*) wire w_freeMutexMerge2,w_fire_1,w_fire_2,w_fire_3,w_drive1Selector2;

(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) cSplitter2_103b_wb Splitter(
        .i_drive      ( i_lsuDriveToWB   ),
        .o_free       ( o_free        ),  
        .i_data_103   ( i_data_103      ),    
        .i_freeNext0  ( w_freeSplitter1      ),
        .o_driveNext0 ( w_driveSelector1     ),
        .o_data0_98   ( w_temp1_98           ),
        .i_freeNext1  ( w_freeSplitter2       ),
        .o_driveNext1 ( w_driveSelector2     ),  
        .o_data1_5    ( w_temp2_5           ),
        .rst          ( rst                 )
);

assign {w_prfAddr_8,w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2,w_msr_1,w_msbit_5,w_lsbit_5,w_bfi_1,w_bfc_1,w_sbfx,w_ubfx,w_writeRd_1} = w_temp1_98;
assign {w_s_1,w_nzcv_4} = w_temp2_5;

(*KEEP="TRUE"*) wire w_prfValid_1,w_grf1Valid_1,w_grf2Valid_1,w_grf3Valid_1,w_pcValid_1,w_noneValid_1;
(*KEEP="TRUE"*) wire [2:0] w_valid_3;
assign w_prfValid_1 = w_msr_1;
assign w_pcValid_1 = (w_grfAddrH_4 == 4'b1111) ? 1'b1 : 1'b0;
assign w_grf2Valid_1 = (w_bfi_1 | w_bfc_1) ? 1'b1 : 1'b0;
assign w_grf3Valid_1 = (w_sbfx | w_ubfx) ? 1'b1 : 1'b0;
assign w_grf1Valid_1 = (!w_bfi_1 & !w_bfc_1 & !w_sbfx & !w_ubfx & !w_pcValid_1 & !w_prfValid_1 & !w_noneValid_1) ? 1'b1 : 1'b0;
assign w_noneValid_1 = (w_writeRd_1 == 1'b0) ? 1'b1 : 1'b0;
assign w_valid_3 = {3{w_prfValid_1}} & 3'b000
                | {3{w_pcValid_1}} & 3'b001
                | {3{w_grf1Valid_1}} & 3'b010 | {3{w_grf2Valid_1}} & 3'b011 | {3{w_grf3Valid_1}} & 3'b100
                | {3{w_noneValid_1}} & 3'b101;

(*KEEP="TRUE"*)wire [86:0] w_dataReadGRF_87;
wire w_wbFreeFromIF,w_drive_pc;
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) delay8U  delay1(.inR(w_driveSelector1), .outR(w_drive1Selector1), .rst(rst));
//12/8 zwm write PC maybe also need write normal grf,so add a splitter
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *)cSelector6_101b_wb Selector1(
        .i_drive      ( w_drive1Selector1   ),
        .o_free       ( w_freeSplitter1        ),
        .i_data_101    ( {w_temp1_98,w_valid_3}   ),   
        .i_freeNext0  ( i_wbFreeFROMPrf      ),
        .o_driveNext0 ( o_drive_prf     ),
        .o_data0_40   ( o_prfData_40     ),
        .i_freeNext1  ( w_wbFreeFromIF      ),
        .o_driveNext1 ( w_drive_pc    ), 
        .o_data1_32   ( o_pcData_32     ),
        .i_freeNext2  ( w_freeSelector13      ),
        .o_driveNext2 ( w_driveMutexMerge11     ),
        .o_data2_74   ( w_grf1Data_74     ),
        .i_freeNext3  ( i_wbFreeFromReadGRF      ),
        .o_driveNext3 ( o_wbDriveReadGRF     ),
        .o_data3_87   ( w_dataReadGRF_87),
        .i_freeNext4  ( w_freeSelector15       ),
        .o_driveNext4 ( w_driveMutexMerge2     ),
        .o_data4_87   ( w_grf2Data_87    ),
        .i_freeNext5 ( w_freeSelector16       ),
        .o_driveNext5 ( w_freeSelector16     ),
        .rst          ( rst                 )
);

//-------------------------------------------------------add a splitter---------------------------------------//
wire w_wbSplitterDriveToMutexMerge1_1,w_mutexMerge1FreeToWbSplitter_1;
wire [73:0] w_wbSplitterToMutexMerge1Data_74;
assign w_wbSplitterToMutexMerge1Data_74 ={w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2};
cSplitter2_1b wbSplitter(
        .i_drive(w_drive_pc), .i_data_1(1'b0), .o_free(w_wbFreeFromIF),
        .o_driveNext0(o_drive_pc), .i_freeNext0(i_wbFreeFromIF), .o_data0_1(),
        .o_driveNext1(w_wbSplitterDriveToMutexMerge1_1), .o_data1_1(), .i_freeNext1(w_mutexMerge1FreeToWbSplitter_1),
        .rst(rst)
);

//-------------------------------------------------------end------------------------------------------------//

(*KEEP="TRUE"*)wire w_valid_1;  
assign w_valid_1 = w_s_1;
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) delay4U  delay8(.inR(w_driveSelector2), .outR(w_drive1Selector2), .rst(rst));
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) cSelector2_5b_wb Selector2(
        .i_drive      ( w_drive1Selector2   ),
        .o_free       ( w_freeSplitter2      ), 
        .i_data_5     ({w_nzcv_4,w_valid_1} ),         
        .i_freeNext0  ( i_wbFreeFromXpsr    ),
        .o_driveNext0 ( o_drive_xpsr     ),
        .o_data0_4    ( o_xpsrData_4     ),
        .i_freeNext1  ( w_freeSelector22   ),
        .o_driveNext1 ( w_freeSelector22   ),  
        .rst          ( rst               )
);

(*KEEP="TRUE"*)wire w_selector1,w_selector2;
(*KEEP="TRUE"*)wire [63:0] w_data1_64,w_data2_64;
(*KEEP="TRUE"*)wire [1:0] w_selectorbf_2,w_selectorfx_2;
(*KEEP="TRUE"*)wire [4:0] w_lsbit1_5,w_msbit1_5,w_msbit2_5,w_lsbit2_5,w_mlresult_5;
assign o_WBdataToGRF_8 = w_dataReadGRF_87[85:78];
assign w_data1_64 = w_dataReadGRF_87[77:14];
assign w_data2_64 = w_grf2Data_87[77:14];
assign w_selectorbf_2 = w_dataReadGRF_87[1:0];
assign w_selectorfx_2 = w_grf2Data_87[1:0] ;
assign w_lsbit1_5 = w_dataReadGRF_87[6:2];
assign w_msbit1_5 = w_dataReadGRF_87[11:7];
assign w_lsbit2_5 = w_grf2Data_87[6:2];
assign w_msbit2_5 = w_data2_64[36:32];
assign w_mlresult_5 = w_msbit2_5 - w_lsbit2_5;
assign w_selector1 = w_dataReadGRF_87[86];
assign w_selector2 = w_grf2Data_87[86];
//assign w_selector_1 = (w_selector1 == 1'b1) ? 1'b0 : (w_selector2 == 1'b1) ? 1'b1 : 1'b0; 

(*KEEP="TRUE"*)wire [63:0] w_dataToMutexMerge2_64;
//12/17 zwm change i_dataFromGRF_64[31:0] to i_dataFromGRF_64[63:32]
assign w_dataToMutexMerge2_64 = {i_dataFromGRF_64[63:32],w_data1_64[63:32]};

(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) cMutexMerge2_64b_wb MutexMerge2(
      .i_drive0(i_driveMutexMerge2),
      .i_data0_64(w_dataToMutexMerge2_64), 
      .o_free0(o_WBfreeGRF),
      .i_drive1(w_driveMutexMerge2), 
      .i_data1_64(w_data2_64), 
      .o_free1(w_freeSelector15),
      .i_freeNext(w_freeMutexMerge2), 
      .o_driveNext(w_drivecFifo1),
      .o_data_64(w_dataTopro_64),
      .rst(rst)
);

(*KEEP="TRUE"*)(* keep_hierarchy="yes" *)cFifo1 cFifo1(
      .i_drive(w_drivecFifo1),
      .o_free(w_freeMutexMerge2),
      .rst(rst),
      .o_driveNext(w_driveMutexMerge12),
      .i_freeNext(w_freecFifo1),
      .o_fire_1(w_fire_1)
);


(*KEEP="TRUE"*)reg [31:0] r_pro_32,r_d_32,r_n_32;
(*KEEP="TRUE"*)reg [4:0] j;
(*KEEP="TRUE"*)integer i;
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) delay4U delay2(.inR(w_fire_1), .outR(w_fire_2),.rst(rst));
//12/17 zwm change w_dataTopro_64[63:32] to w_dataTopro_64[63:32]
always@(posedge w_fire_2 or negedge rst)begin     
     if(!rst)
       begin
          r_n_32 <=32'b0;
          r_d_32 <=32'b0;
end else begin 
   if (w_selector1 == 1'b1) 
       begin
           r_n_32 <= w_dataTopro_64[31:0];
           r_d_32 <= w_dataTopro_64[63:32];  
       end
   else if (w_selector2 == 1'b1)
       begin  
          r_n_32 <= w_dataTopro_64[31:0];    
end
end
end
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *) delay16U delay3(.inR(w_fire_2), .outR(w_fire_3),.rst(rst));

always@(posedge w_fire_3 or negedge rst)begin    
if(!rst)
begin
    r_pro_32 = 32'b0;
end
else begin 
        if (w_selector1 == 1'b1) 
        begin
           if (w_selectorbf_2 == 2'b10) 
             begin
               for (i = 0;i <= 5'b11111; i = i + 1'b1)
                  begin
                     if(w_msbit1_5 >= i && i >= w_lsbit1_5) 
                         begin
                             r_pro_32[i] = r_n_32[i - w_lsbit1_5];
                         end else begin
                             r_pro_32[i] = r_d_32[i];
                         end
                   end

             end
           else if (w_selectorbf_2 == 2'b01)
              begin 
                 for (i = 0;i <= 5'b11111; i=i+1'b1)
                    begin
                       if(w_msbit1_5 >= i && i >= w_lsbit1_5)
                          begin
                              r_pro_32[i] = 1'b0;
                          end else begin
                              r_pro_32[i] = r_d_32[i];
                          end
                    end
            end
         end
         else if (w_selector2 == 1'b1)
         begin 
             if (w_selectorfx_2 == 2'b01)
                 begin
                  for (i = 0;i <= 5'b11111; i=i+1'b1)
                     begin
                       if(w_msbit2_5 <= 5'b11111) 
                          begin
                              if(w_mlresult_5 >= i && i >= 1'b0) 
                                 begin
                                     r_pro_32[i] = r_n_32[i + w_lsbit2_5];
                                 end
                     else begin
                           r_pro_32[i] = 1'b0;
                     end
             end
             end
             end else if (w_selectorfx_2 == 2'b10)
              begin 
                  for (i = 0;i <= 5'b11111; i=i+1'b1)
                  begin
                     if(w_msbit2_5 <= 5'b11111) begin
                       if(w_mlresult_5 >= i && i >= 1'b0) begin
                           r_pro_32[i] = r_n_32[i + w_lsbit2_5];
                        end
                     else begin
                           r_pro_32[i] = r_n_32[31];
                     end
end
end
end
end
end
end

//12/17 zwm first write high then low
assign w_prodata_74 = {w_dataReadGRF_87[85:78],r_pro_32,{32{1'b0}},w_dataReadGRF_87[13:12]};

wire w_drive_grf;

//12/8 zwm due to before add a path,so this need add a port
// (*KEEP="TRUE"*)(* keep_hierarchy="yes" *)cMutexMerge2_74b_wb MutexMerge1(
//       .i_drive0(w_driveMutexMerge11),
//       .i_data0_74(w_grf1Data_74), 
//       .o_free0(w_freeSelector13),
//       .i_drive1(w_driveMutexMerge12), 
//       .i_data1_74(w_prodata_74), 
//       .o_free1(w_freecFifo1),
//       .i_freeNext(i_wbFreeFromGRF), 
//       .o_driveNext(w_drive_grf),
//       .o_data_74(o_grfData_74),
//       .rst(rst)
// );
//12/17 zwm due to bit operation is little slow ,need add delay
wire w_driveMutexMerge12Delay_1;
(* dont_touch="true" *) delay16U bitOperationDelay(.inR(w_driveMutexMerge12), .outR(w_driveMutexMerge12Delay_1), .rst(rst)); 
(*KEEP="TRUE"*)(* keep_hierarchy="yes" *)cMutexMerge3_74b_wb MutexMerge1(
    .i_drive0(w_driveMutexMerge11),
    .i_data0_74(w_grf1Data_74), 
    .o_free0(w_freeSelector13),
    .i_drive1(w_driveMutexMerge12Delay_1), 
    .i_data1_74(w_prodata_74), 
    .o_free1(w_freecFifo1),
    .i_drive2(w_wbSplitterDriveToMutexMerge1_1), 
    .i_data2_74(w_wbSplitterToMutexMerge1Data_74), 
    .o_free2(w_mutexMerge1FreeToWbSplitter_1),
    .i_freeNext(i_wbFreeFromGRF), 
    .o_driveNext(w_drive_grf),
    .o_data_74(o_grfData_74),
    .rst(rst)
);
(* dont_touch="true" *) delay4U toGrfDelay(.inR(w_drive_grf), .outR(o_drive_grf), .rst(rst)); 


assign o_bitOpOver_1 = w_driveMutexMerge12Delay_1;

endmodule

