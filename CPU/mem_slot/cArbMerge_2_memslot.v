`timescale 1ns / 1ps
//===============================================================================
// Project:        utils
// Module:         ArbMerge_2
// version:        1st version (2025-06-03)
// Author:         Longtao Zhang, Haiyi Wang
// Reviser:        Haiyi Wang, Anping He
// Date:           2025/06/03
// Connect Mail：  whaiyi2024@lzu.edu.cn
// Description:    一个二路ArbMerge模板。多事件输入，不等待/同步所有事件。一路到则一路出，多路到则仲裁一路出。保持未选择数据流。
//===============================================================================
//! 收到i_free 再发o_free

(* dont_touch="true" *)module cArbMerge_2_memslot#(
    parameter DATA_WIDTH = 2      //2'b
)(
    /* input & output ports */
    (* dont_touch="true" *)input                   rst,
    (* dont_touch="true" *)input                   i_drive0,   
    (* dont_touch="true" *)input                   i_drive1,
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data0, 
    (* dont_touch="true" *)input  [DATA_WIDTH-1:0] i_data1,
    (* dont_touch="true" *)output                  o_free0, 
    (* dont_touch="true" *)output                  o_free1,
    (* dont_touch="true" *)output                  o_drive,
    (* dont_touch="true" *)output [DATA_WIDTH-1:0] o_data,
    (* dont_touch="true" *)input                   i_free

);

    localparam NUM_PORTS = 2;

    (* dont_touch="true" *)wire [DATA_WIDTH-1:0] w_idata [NUM_PORTS-1:0];
    (* dont_touch="true" *)reg  [DATA_WIDTH-1:0] r_data  [NUM_PORTS-1:0];

    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1id;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1if;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1of;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1od;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1fire;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf1pmt;

    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf2id;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf2if;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf2of;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf2od;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_pf2fire;

    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_trig;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_req;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_grant;
    (* dont_touch="true" *)wire [NUM_PORTS-1:0] w_reset;

    assign w_pf1id = {i_drive1, i_drive0};
    assign {o_free1, o_free0} = w_pf2if;
    assign w_idata[1] = i_data1;
    assign w_idata[0] = i_data0;
    assign o_data = ({DATA_WIDTH{w_grant[0]}} & r_data[0])| 
                    ({DATA_WIDTH{w_grant[1]}} & r_data[1]);

    assign o_drive  = |w_pf2od;
    assign w_pf1pmt = {NUM_PORTS{~(|w_req)}};
    assign w_grant  = w_req & (~w_req + 1'b1);

    genvar i;
    generate
        for (i = 0; i < NUM_PORTS; i = i + 1) begin : arbUnit
            assign w_pf1if[i] = w_pf2of[i];
            assign w_pf2if[i] = i_free & w_grant[i];

            (* dont_touch="true" *)cPmtFifo1_mem u_PmtFifo1(
                .i_drive        (w_pf1id[i]),
                .i_freeNext     (w_pf1if[i]),
                .o_free         (w_pf1of[i]),
                .o_driveNext    (w_pf1od[i]),
                .o_fire         (w_pf1fire[i]),
                .pmt            (w_pf1pmt[i]),
                .rst            (rst)
            );

            always @(posedge w_pf1fire[i] or negedge rst) begin
                if (!rst) begin
                    r_data[i] <= {DATA_WIDTH{1'b0}};
                end else begin
                    r_data[i] <= w_idata[i];
                end
            end

            assign w_trig[i] = w_pf1fire[i] | w_reset[i];
            (* dont_touch="true" *)contTap u_tap(
                .trig(w_trig[i] ),
                .req (w_req[i]  ),
                .rst (rst       )
            );

            (* dont_touch="true" *)freeSetDelay #(.N(8)) u_delay1(
                .inR  (w_pf1od[i]),
                .outR (w_pf2id[i]),
                .rst  (rst       )
            );

            (* dont_touch="true" *)cPmtFifo1_mem u_PmtFifo2(
                .i_drive    (w_pf2id[i]),
                .i_freeNext (w_pf2if[i]),
                .o_free     (w_pf2of[i]),
                .o_driveNext(w_pf2od[i]),
                .o_fire     (w_pf2fire[i]),
                .pmt        (w_grant[i]),
                .rst        (rst)
            );

            (* dont_touch="true" *)freeSetDelay #(.N(3)) u_delay2(
                .inR  (w_grant[i] & i_free),
                .outR (w_reset[i]         ),
                .rst  (rst                )
            );
        end
    endgenerate


endmodule
