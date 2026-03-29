//===============================================================================
// Project:        RCA
// Module:         ConfMerge_2_df
// Author:         YiHua Lu
// Date:           2025/06/18
// Description:    互斥融合;带数据版;对数据做持久化处理；
//                 这种做法可以消除数据随着控制链流动的模型中数据的不稳定因素
//                 测试值：128bit，5ns左右给出去
//===============================================================================
`timescale 1ns / 1ps

module cMutexMerge_2_df_memslot#(
    parameter DATA_WIDTH = 256
)(
    input  wire i_drive0,i_drive1,
    input  wire [DATA_WIDTH-1:0] i_data0,i_data1,
    input  wire i_freeNext,

    output wire o_free0,o_free1,
    output wire o_driveNext,
    output wire [DATA_WIDTH-1:0] o_data,

    input wire rst

);
    wire                    w_trig0,w_trig1;
    wire                    w_req0,w_req1;
    wire                    w_free0,w_free1,w_fire;
    wire                    w_fire0,w_fire1;
    wire                    w_free0_delay,w_free1_delay,w_fire_delayed;
    wire [1:0]              w_outRRelay_2_1, w_outARelay_2_1,w_outRRelay_2_2, w_outARelay_2_2;
    reg  [DATA_WIDTH-1:0]   r_data;

    // 产生req标记当前路线
    assign w_trig0 = (i_drive0&~w_req0) | w_free0_delay;
    assign w_trig1 = (i_drive1&~w_req1) | w_free1_delay;
    contTap tap0(.trig(w_trig0), .req(w_req0), .rst(rst));
    contTap tap1(.trig(w_trig1), .req(w_req1), .rst(rst));

    // 分别处理保存数据逻辑
    sender sender0(
        .i_drive (i_drive0),
        .o_free  (),
        .outR    (w_outRRelay_2_1[0]),
        .i_free  (w_fire0),
        .rst    (rst)
    );
    relay relay0(
        .inR   (w_outRRelay_2_1[0]),
        .inA   (w_outARelay_2_1[0]),
        .outR  (w_outRRelay_2_1[1]),
        .outA  (w_outARelay_2_1[1]),
        .fire  (w_fire0),
	    .rst  (rst)
    );
    receiver receiver0(
        .inR     (w_outRRelay_2_1[1]),
        .inA     (w_outARelay_2_1[1]),
        .i_freeNext  (w_free0),
        .rst    (rst)
    );

    sender sender1(
        .i_drive (i_drive1),
        .o_free  (),
        .outR    (w_outRRelay_2_2[0]),
        .i_free  (w_fire1),
        .rst    (rst)
    );
    relay relay1(
        .inR   (w_outRRelay_2_2[0]),
        .inA   (w_outARelay_2_2[0]),
        .outR  (w_outRRelay_2_2[1]),
        .outA  (w_outARelay_2_2[1]),
        .fire  (w_fire1),
	    .rst  (rst)
    );
    receiver receiver1(
        .inR     (w_outRRelay_2_2[1]),
        .inA     (w_outARelay_2_2[1]),
        .i_freeNext  (w_free1),
        .rst    (rst)
    );

    // i_free进入后，先复位receiver，给出free，再敲低对应的conTap
    assign w_free0 = i_freeNext & w_req0;
    assign w_free1 = i_freeNext & w_req1;
    delay4U delay0 (.inR(w_free0)   , .outR(w_free0_delay), .rst(rst));
    delay4U delay1 (.inR(w_free1)   , .outR(w_free1_delay), .rst(rst));

    assign w_fire = w_fire0 | w_fire1;
    wire w_fire_delay;
    // fire要加延时不然波形上看不太够
    delay3U delay_fire (.inR(w_fire)   , .outR(w_fire_delay), .rst(rst));
    always @(posedge w_fire_delay or negedge rst) begin
        if (!rst) begin
            r_data <= {DATA_WIDTH{1'b0}};
        end
        else begin
            r_data <= w_req0 ? i_data0 : i_data1;
        end
    end

    // 输出延迟统一用i_drive产生，确保数据保存下来了
    (* dont_touch="true" *)delay1U outdelay (.inR(i_drive0|i_drive1), .outR(o_driveNext),.rst(rst));
    assign o_data         = r_data;
    assign o_free0        = w_free0;
    assign o_free1        = w_free1;

endmodule
