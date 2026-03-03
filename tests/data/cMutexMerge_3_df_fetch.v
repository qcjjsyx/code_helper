//===============================================================================
// Project:        RCA
// Module:         ConfMerge_3_df
// Author:         YiHua Lu
// Date:           2025/07/20
// Description:    三路互斥融合; 带数据版; 数据持久化处理
//===============================================================================
`timescale 1ns / 1ps




//@cc: schema: cc_header_v1
//@cc: name: cMutexMerge_3_df_fetch
//@cc: family: MutexMergeN
//@cc: params:
//@cc:   NUM_PORTS: 3
//@cc:   DATA_WIDTH: 210
//@cc:   DELAY: {TODO}
//@cc: roles:
//@cc:   upstream: [i_drive0, i_drive1, i_drive2, o_free0, o_free1, o_free2]
//@cc:   downstream: [o_driveNext, i_freeNext]
//@cc:   fire: []

module cMutexMerge_3_df_fetch#(
    parameter DATA_WIDTH = 210
)(
    input  wire                    i_drive0, i_drive1, i_drive2,
    input  wire [DATA_WIDTH-1:0]  i_data0,  i_data1,  i_data2,
    input  wire                    i_freeNext,
    input  wire                    rst,

    output wire                    o_free0, o_free1, o_free2,
    output wire                    o_driveNext,
    output wire [DATA_WIDTH-1:0]  o_data
);
    localparam N = 3;

    wire [N-1:0] w_req;
    wire [N-1:0] w_trig;
    wire [N-1:0] w_free;
    wire [N-1:0] w_free_delay;
    wire [N-1:0] w_fire;

    wire [N-1:0] i_drive = {i_drive2, i_drive1, i_drive0};
    
    assign o_free0 = w_free[0];
    assign o_free1 = w_free[1];
    assign o_free2 = w_free[2];


    wire [1:0] w_outRRelay[N-1:0];
    wire [1:0] w_outARelay[N-1:0];

    reg [DATA_WIDTH-1:0] r_data;

    // delay + contTap + sender/relay/receiver
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: gen_conf

            // Request 触发
            assign w_trig[i] = (i_drive[i] & ~w_req[i]) | w_free_delay[i];
            contTap u_tap(
                .trig(w_trig[i]),
                .req (w_req[i]),
                .rst (rst)
            );

            // Sender
            sender u_sender (
                .i_drive(i_drive[i]),
                .o_free(),
                .outR  (w_outRRelay[i][0]),
                .i_free(w_fire[i]),
                .rst   (rst)
            );

            // Relay
            relay u_relay (
                .inR  (w_outRRelay[i][0]),
                .inA  (w_outARelay[i][0]),
                .outR (w_outRRelay[i][1]),
                .outA (w_outARelay[i][1]),
                .fire (w_fire[i]),
                .rst  (rst)
            );

            // Receiver
            receiver u_receiver (
                .inR       (w_outRRelay[i][1]),
                .inA       (w_outARelay[i][1]),
                .i_freeNext(w_free[i]),
                .rst       (rst)
            );

            // Free 信号延迟
            assign w_free[i] = i_freeNext & w_req[i];
            delay4U u_delay (
                .inR(w_free[i]),
                .outR(w_free_delay[i]),
                .rst(rst)
            );
        end
    endgenerate

    wire w_fire_any = |w_fire;
    wire w_fire_delay;
    delay3U delay_fire (
        .inR(w_fire_any),
        .outR(w_fire_delay),
        .rst(rst)
    );

    // 数据保存逻辑
    always @(posedge w_fire_delay or negedge rst) begin
        if (!rst)
            r_data <= {DATA_WIDTH{1'b0}};
        else begin
            case (1'b1)
                w_req[0]: r_data <= i_data0;
                w_req[1]: r_data <= i_data1;
                w_req[2]: r_data <= i_data2;
                default:  r_data <= {DATA_WIDTH{1'b0}};
            endcase
        end
    end

    (* dont_touch="true" *) delay1U outdelay (
        .inR(|i_drive),
        .outR(o_driveNext),
        .rst(rst)
    );

    assign o_data  = r_data;


endmodule
