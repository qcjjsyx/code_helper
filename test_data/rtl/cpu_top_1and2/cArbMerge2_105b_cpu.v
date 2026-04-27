/*
 * @Description: 改进的arbmerge
 * @Author: liaozz
 * @Date: 2024-07-28 19:33:13
 * @LastEditors: liaozz
 * @LastEditTime: 2024-12-17 19:56:02
 * @Design version: 
 */


 module cArbMerge2_105b_cpu
 #(
  parameter DATA_WIDTH = 105
 )(
     input [2-1:0] i_drive_2,
     input [DATA_WIDTH-1:0] i_data0,
     input [DATA_WIDTH-1:0] i_data1,
     input i_freeNext,
     input rst,
 
     output [2-1:0] o_free_2,
     output o_driveNext,
     output [DATA_WIDTH-1:0] o_data
 );
 
   localparam DELAY_CL = 20;//为了匹配仲裁器组合电路的时间+MUX时间
 
   (* dont_touch="true" *)wire [2-1:0] w_fire_2;
   (* dont_touch="true" *)wire [2-1:0] w_driveNext_2;
   (* dont_touch="true" *)wire [2-1:0] w_d_fire_2;
 
   (* dont_touch="true" *)wire w_sendFire_1;
 
   (* dont_touch="true" *)wire [2-1:0] w_reset_2;
 
   (* dont_touch="true" *)wire [2-1:0] w_trig_2;
 
   (* dont_touch="true" *)wire [2-1:0] w_req_2;
 
   (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data0, w_data1;
   (* dont_touch="true" *)reg [DATA_WIDTH-1:0] r_wdata;
 
   (* dont_touch="true" *)reg [DATA_WIDTH-1:0]r_data0,r_data1, r_data;
 
   (* dont_touch="true" *)wire w_sendFinish;
   (* dont_touch="true" *)wire pmt;
   (* dont_touch="true" *)wire pmtFinish;
   (* dont_touch="true" *)wire w_sendDrive;
   (* dont_touch="true" *)wire w_sendDrive0;
   (* dont_touch="true" *)wire w_sendDrive1;
   (* dont_touch="true" *)wire w_sendFree;
   (* dont_touch="true" *)wire [2-1:0] w_grant_2;
   (* dont_touch="true" *)wire [2-1:0] w_pmtIfreeNext_2;
   wire w_freeNext;
   wire [2-1:0] w_ifreeReq_2;
 
   // save inputs
   genvar i;
   generate
     for (i = 0; i < 2; i = i + 1) begin : pmt_fifo
       assign w_pmtIfreeNext_2[i]=w_sendFire_1 & w_grant_2[i];
       cPmtFifo1 PmtFifo (
           .i_drive(i_drive_2[i]),
           .i_freeNext(w_pmtIfreeNext_2[i]),
           .o_free(o_free_2[i]),
           .o_driveNext(w_driveNext_2[i]),
           .o_fire_1(w_fire_2[i]),
           .pmt(pmt),
           .rst(rst)
       );
       assign w_trig_2[i]  = w_fire_2[i] | w_reset_2[i];
       assign w_reset_2[i] = w_grant_2[i] & w_freeNext;
       contTap tap (
           .trig(w_trig_2[i]),
           .req (w_req_2[i]),
           .rst (rst)
       );
       (* dont_touch="true" *)freeSetDelay #(
         .DELAY_UNIT_NUM( DELAY_CL )
       ) delayDriveNext (
           .i_signal(w_fire_2[i]),
           .o_signal(w_d_fire_2[i]),
           .rst     (rst)
       );
     end
   endgenerate
 
 
   always @(posedge w_fire_2[0] or negedge rst) begin
     if (!rst) begin
       r_data0 <= {DATA_WIDTH{1'b0}};
     end else begin
       r_data0 <= i_data0;
     end
   end
   assign w_data0 = r_data0;
 
   always @(posedge w_fire_2[1] or negedge rst) begin
     if (!rst) begin
       r_data1 <= {DATA_WIDTH{1'b0}};
     end else begin
       r_data1 <= i_data1;
     end
   end
   assign w_data1 = r_data1;
 
 
   //lock
   assign pmt = ~(|w_req_2);
 
   // grant
   assign w_grant_2 = w_req_2 & (~w_req_2 + 1'b1);
 
   // Shorten pulse width
   contTap d_ifreeNext (
     .trig(i_freeNext),
     .req (w_ifreeReq_2[0]),
     .rst (rst)
   );
   delay2U delayifreeReq_donttouch(.inR(w_ifreeReq_2[0]),.rst(rst), .outR(w_ifreeReq_2[1]));
   assign w_freeNext = w_ifreeReq_2[0]^w_ifreeReq_2[1];
 
   //sendFifo
   assign w_sendDrive0 = (|(w_d_fire_2 & w_grant_2));
 
   assign pmtFinish = (w_req_2==w_grant_2)?1'b0:1'b1;
   (* dont_touch="true" *)freeSetDelay #(
     .DELAY_UNIT_NUM(DELAY_CL)
   ) delayW_sendFire (
       .i_signal( (|w_reset_2) & pmtFinish),
       .o_signal(w_sendDrive1),
       .rst     (rst)
   );
   assign w_sendDrive = w_sendDrive0 | w_sendDrive1;
 
   cFifo1 sendFifo (
       .i_drive(w_sendDrive),
       .i_freeNext(i_freeNext),
       .o_free(w_sendFree),
       .o_driveNext(o_driveNext),
       .o_fire_1(w_sendFire_1),
       .rst(rst)
   );
 
   always @(posedge w_sendFire_1 or negedge rst) begin
     if (!rst) begin
       r_data <= {DATA_WIDTH{1'b0}};
     end else begin
       r_data <= r_wdata;
     end
   end
   assign o_data = r_data;
 
   //Mux
   always @(w_grant_2) begin
     case (w_grant_2)
         2'b01: r_wdata <= w_data0 ;
         2'b10: r_wdata <= w_data1 ;
         default : r_wdata <= {DATA_WIDTH{1'b0}};
     endcase
   end
 
 endmodule  //cArbMerge2
 