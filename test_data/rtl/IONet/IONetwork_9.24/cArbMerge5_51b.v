/*
 * @Description: 改进的arbmerge，轮转输出
 * @Author: liaozz
 * @Date: 2024-09-10 12:10:41
 * @LastEditors: liaozz
 * @LastEditTime: 2024-09-19 10:07:48
 * @Design version: 
 */
module cArbMerge5_51b #(
    parameter DATA_WIDTH = 51
) (
    input [5-1:0] i_drive_5,
    input [DATA_WIDTH-1:0] i_data0,
    input [DATA_WIDTH-1:0] i_data1,
    input [DATA_WIDTH-1:0] i_data2,
    input [DATA_WIDTH-1:0] i_data3,
    input [DATA_WIDTH-1:0] i_data4,
    input i_freeNext,
    input rst,

    output [5-1:0] o_free_5,
    output o_driveNext,
    output [DATA_WIDTH-1:0] o_data
);

  localparam DELAY_w_driveNext = 5;//为了匹配仲裁器组合电路的时间+MUX时间
  localparam DELAY_w_sendDrive1 = 5;//此参数是为了配合MUX的延时
  localparam DELAY_w_reset =0;//此参数是为了避免因ifreeNext脉宽过宽带来的竞争冒险,注意:DELAY_w_reset必须<DELAY_w_sendDrive1

  (* dont_touch="true" *)wire [5-1:0] w_fire_8;
  (* dont_touch="true" *)wire [5-1:0] w_driveNext_8;
  (* dont_touch="true" *)wire [5-1:0] w_d_driveNext_8;

  (* dont_touch="true" *)wire w_sendFire_1;

  (* dont_touch="true" *)wire [5-1:0] w_reset_8;

  (* dont_touch="true" *)wire [5-1:0] w_trig_8;

  (* dont_touch="true" *)wire [5-1:0] w_req_8;

  (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_data0, w_data1, w_data2, w_data3, w_data4, w_data5, w_data6, w_data7, w_data;

  (* dont_touch="true" *)reg [DATA_WIDTH-1:0]r_data0, r_data1, r_data2, r_data3, r_data4, r_data5, r_data6, r_data7, r_data;

  (* dont_touch="true" *)wire w_sendFinish;
  (* dont_touch="true" *)wire pmt;
  (* dont_touch="true" *)wire pmtFinish;
  (* dont_touch="true" *)wire w_sendDrive;
  (* dont_touch="true" *)wire w_sendDrive0;
  (* dont_touch="true" *)wire w_sendDrive1;
  (* dont_touch="true" *)wire w_sendFree;
  (* dont_touch="true" *)wire [5-1:0] w_grant_8;
  (* dont_touch="true" *)wire [5-1:0] w_pmtIfreeNext_8;

  // save inputs
  genvar i;
  generate
    for (i = 0; i < 5; i = i + 1) begin : pmt_fifo
      assign w_pmtIfreeNext_8[i]=w_sendFire_1 & w_grant_8[i];
      cPmtFifo1 PmtFifo (
          .i_drive(i_drive_5[i]),
          .i_freeNext(w_pmtIfreeNext_8[i]),
          .o_free(o_free_5[i]),
          .o_driveNext(w_driveNext_8[i]),
          .o_fire_1(w_fire_8[i]),
          .pmt(pmt),
          .rst(rst)
      );
      assign w_trig_8[i]  = w_fire_8[i] | w_reset_8[i];
      freeSetDelay #(
        .DELAY_UNIT_NUM(DELAY_w_reset)
      ) delayReset (
          .i_signal(w_grant_8[i] & i_freeNext),
          .o_signal(w_reset_8[i]),
          .rst     (rst)
      );
      contTap tap (
          .trig(w_trig_8[i]),
          .req (w_req_8[i]),
          .rst (rst)
      );
      freeSetDelay #(
        .DELAY_UNIT_NUM(DELAY_w_driveNext)
      ) delayDriveNext (
          .i_signal(w_driveNext_8[i]),
          .o_signal(w_d_driveNext_8[i]),
          .rst     (rst)
      );
    end
  endgenerate


  always @(posedge w_fire_8[0] or negedge rst) begin
    if (!rst) begin
      r_data0 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data0 <= i_data0;
    end
  end
  assign w_data0 = r_data0;

  always @(posedge w_fire_8[1] or negedge rst) begin
    if (!rst) begin
      r_data1 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data1 <= i_data1;
    end
  end
  assign w_data1 = r_data1;

  always @(posedge w_fire_8[2] or negedge rst) begin
    if (!rst) begin
      r_data2 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data2 <= i_data2;
    end
  end
  assign w_data2 = r_data2;

  always @(posedge w_fire_8[3] or negedge rst) begin
    if (!rst) begin
      r_data3 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data3 <= i_data3;
    end
  end
  assign w_data3 = r_data3;

  always @(posedge w_fire_8[4] or negedge rst) begin
    if (!rst) begin
      r_data4 <= {DATA_WIDTH{1'b0}};
    end else begin
      r_data4 <= i_data4;
    end
  end
  assign w_data4 = r_data4;

  //lock
  assign pmt = ~(|w_req_8);

  // grant
  assign w_grant_8 = w_req_8 & (~w_req_8 + 1'b1);

  //sendFifo

  assign w_sendDrive0 = (|(w_d_driveNext_8 & w_grant_8));

  assign pmtFinish = (w_req_8==w_grant_8)?1'b0:1'b1;
  freeSetDelay #(
    .DELAY_UNIT_NUM(DELAY_w_sendDrive1)
  ) delayW_sendFire (
      .i_signal(i_freeNext & pmtFinish),
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
      r_data <= w_data;
    end
  end
  assign o_data = r_data;

  //Mux
  assign w_data = (w_grant_8 == 5'b00001) ? w_data0 :
                  (w_grant_8 == 5'b00010) ? w_data1 : 
                  (w_grant_8 == 5'b00100) ? w_data2 : 
                  (w_grant_8 == 5'b01000) ? w_data3 : 
                  (w_grant_8 == 5'b10000) ? w_data4 : {DATA_WIDTH{1'b0}};

endmodule  //cArbMerge8_N_retire
