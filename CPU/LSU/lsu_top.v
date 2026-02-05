`timescale 1ns/1ps
module lsu_top(
    (*dont_touch = "yes"*)input           i_driveFromExe    ,
    (*dont_touch = "yes"*)output          o_freeToExe       ,
    (*dont_touch = "yes"*)input [246-1:0] i_dataFromExe_246 ,

    (*dont_touch = "yes"*)output          o_driveToMem      ,
    (*dont_touch = "yes"*)input           i_freeFromMem     ,
    (*dont_touch = "yes"*)output[136-1:0] o_dataToMem_136   ,
    
    (*dont_touch = "yes"*)input           i_driveFromMem    ,
    (*dont_touch = "yes"*)output          o_freeToMem       ,
    (*dont_touch = "yes"*)input [256-1:0] i_dataFromMem_256 ,

    (*dont_touch = "yes"*)output          o_driveToRetire   ,
    (*dont_touch = "yes"*)input           i_freeFromRetire  ,
    (*dont_touch = "yes"*)output[246-1:0] o_dataToRetire_246,

    (*dont_touch = "yes"*)input           rst            
);
(*dont_touch = "yes"*)reg [1:0]r_counter_2;//00-begin,01-ack1,10-end
(*dont_touch = "yes"*)wire fire1,w_fire5,w_loadSign,w_driveFifo1ToSel1,w_freeSel1ToFifo1,w_driveSel1ToMutex3,w_freeMutex3ToSel1,w_isMemOp,w_isCrosslineOp;
// additional interconnect signals (declared to avoid undefined-wire errors)
(*dont_touch = "yes"*)wire w_driveSel1ToSel2, w_freeSel2ToSel1;
(*dont_touch = "yes"*)wire w_driveSel2ToMutex1, w_freeMutex1ToSel2, w_driveSel2ToNat1, w_freeNat1ToSel2;
(*dont_touch = "yes"*)wire w_driveNat1ToArb1_0, w_freeArb1ToNat1_0, w_driveNat1ToArb1_1, w_freeArb1ToNat1_1;
(*dont_touch = "yes"*)wire w_driveArb1ToMutex1, w_freeMutex1ToArb1;
(*dont_touch = "yes"*)wire [135:0] w_data_memReqHigh_136, w_data_memReqLow_136, w_data_memReqArb1ToMutex1_136, w_data_memReqMutex1ToFifo2_136;
(*dont_touch = "yes"*)wire w_driveMutex1ToFifo, w_freeFifo2ToMutex1;
(*dont_touch = "yes"*)wire w_driveFifo2ToFifo3, w_freeFifo3ToFifo2, w_fire2;
(*dont_touch = "yes"*)wire w_driveFifo3ToFifo4, w_freeFifo4ToFifo3, w_fire3;
(*dont_touch = "yes"*)wire w_fire4; 
(*dont_touch = "yes"*)wire w_fire6;
(*dont_touch = "yes"*)wire [245:0] w_dataToRetireMem_246, w_dataToRetire_246;
(*dont_touch = "yes"*)wire [38:0] w_en_39;
(*dont_touch = "yes"*)wire w_driveFifo4ToFifo4, w_freeFifo6ToFifo4, w_driveFifo4ToEventSink1, w_freeEventSink1ToFifo4;
(*dont_touch = "yes"*)wire w_driveEventSource1ToMutex3;
(*dont_touch = "yes"*)reg[246-1:0]r_dataFromExe_246;
(* dont_touch="true" *)cFifo1_lsu u_fifo1(
    .i_drive            (i_driveFromExe             ),
    .o_free             (o_freeToExe                ),
    .o_driveNext        (w_driveFifo1ToSel1         ),
    .i_freeNext         (w_freeSel1ToFifo1          ),
    .o_fire             (w_fire1                    ),
    .rst                (rst                        )
);
always @(posedge w_fire1 or negedge rst) begin
    if(!rst)begin
        r_dataFromExe_246 <= 0;
    end
    else begin
        r_dataFromExe_246 <= i_dataFromExe_246;
    end
end
(* dont_touch="true" *)lsu_memReqFormat_comb u_lsu_memReqFormat_comb(
    .i_data_246         (r_dataFromExe_246          ),
    .o_memReqLow_136    (w_data_memReqLow_136       ),
    .o_memReqHigh_136   (w_data_memReqHigh_136      ),
    .o_en_39            (w_en_39                    ),
    .o_isMemOp          (w_isMemOp                  ),
    .o_isCrosslineOp    (w_isCrosslineOp            ),
    .o_isLoad           (w_isLoad                   ),
    .o_isSignLoad       (w_loadSign                 )
);
(* dont_touch="true" *)cSelSplit2_lsu u_sel1 (
    .i_drive            (w_driveFifo1ToSel1         ),
    .o_free             (w_freeSel1ToFifo1          ),
    .o_driveNext0       (w_driveSel1ToMutex3        ),
    .i_freeNext0        (w_freeMutex3ToSel1         ),
    .valid0             (~w_isMemOp                 ),
    .o_driveNext1       (w_driveSel1ToSel2          ),
    .i_freeNext1        (w_freeSel2ToSel1           ),
    .valid1             (w_isMemOp                  ),
    .rst                (rst                        )
);
(* dont_touch="true" *)cSelSplit2_lsu u_sel2(
    .i_drive            (w_driveSel1ToSel2          ),
    .o_free             (w_freeSel2ToSel1           ),
    .o_driveNext0       (w_driveSel2ToMutex1        ),
    .i_freeNext0        (w_freeMutex1ToSel2         ),
    .valid0             (~w_isCrosslineOp           ),
    .o_driveNext1       (w_driveSel2ToNat1          ),
    .i_freeNext1        (w_freeNat1ToSel2           ),
    .valid1             (w_isCrosslineOp            ),
    .rst                (rst                        )
);
(* dont_touch="true" *)cNatSplit2_lsu u_Nat1(
    .i_drive            (w_driveSel2ToNat1          ),
    .o_free             (w_freeNat1ToSel2           ),
    .o_driveNext0       (w_driveNat1ToArb1_0        ),
    .i_freeNext0        (w_freeArb1ToNat1_0         ),
    .o_driveNext1       (w_driveNat1ToArb1_1        ),
    .i_freeNext1        (w_freeArb1ToNat1_1         ),
    .rst                (rst                        )
);
(* dont_touch="true" *)freeSetDelay_lsu #(
    .DELAY_NUM  (10),
    .DELAY_WIDTH(8)
)u_freeSetDelay_Arb1_1(
    .inR                (w_driveNat1ToArb1_1        ),
    .outR               (w_driveNat1ToArb1_1_delay  ),
    .rst                (rst                        )
);
(* dont_touch="true" *)cArbMerge2_lsu #(
    .DATA_WIDTH(136)
)u_Arb1(
    .i_drive0       (w_driveNat1ToArb1_0            ),
    .o_free0        (w_freeArb1ToNat1_0             ), 
    .i_drive1       (w_driveNat1ToArb1_1_delay      ),
    .o_free1        (w_freeArb1ToNat1_1             ),
    .o_drive        (w_driveArb1ToMutex1            ),
    .i_free         (w_freeMutex1ToArb1             ),
    .i_data0        (w_data_memReqHigh_136          ), 
    .i_data1        (w_data_memReqLow_136           ),
    .o_data         (w_data_memReqArb1ToMutex1_136  ),
    .rst            (rst                            )
);
(* dont_touch="true" *)cMutexMerge2_d_lsu #(
    .DATA_WIDTH(136)
)u_Mutex1(
    .i_drive0       (w_driveSel2ToMutex1            ),
    .o_free0        (w_freeMutex1ToSel2             ),
    .i_drive1       (w_driveArb1ToMutex1            ),
    .o_free1        (w_freeMutex1ToArb1             ),
    .o_driveNext    (w_driveMutex1ToFifo            ),
    .i_freeNext     (w_freeFifo2ToMutex1            ),
    .i_data0        (w_data_memReqLow_136           ),
    .i_data1        (w_data_memReqArb1ToMutex1_136  ),
    .o_data         (w_data_memReqMutex1ToFifo2_136 ),
    .rst            (rst                            )
);
(* dont_touch="true" *)cFifo1_lsu u_fifo2(
    .i_drive        (w_driveMutex1ToFifo            ),
    .o_free         (w_freeFifo2ToMutex1            ),
    .o_driveNext    (o_driveToMem                   ),
    .i_freeNext     (i_freeFromMem                  ),
    .o_fire         (w_fire2                        ),
    .rst            (rst                            )
);
(*dont_touch = "yes"*)reg [135:0] r_dataToMem_136;
always @(posedge w_fire2 or negedge rst) begin
    if (!rst) begin
        r_dataToMem_136 <= 0;
    end
    else begin
        r_dataToMem_136 <= w_data_memReqMutex1ToFifo2_136;
    end
end
assign o_dataToMem_136 = r_dataToMem_136;
(* dont_touch="true" *)cFifo1_lsu u_fifo3(
    .i_drive        (i_driveFromMem                 ),
    .o_free         (o_freeToMem                    ),
    .o_driveNext    (w_driveFifo3ToFifo4            ),
    .i_freeNext     (w_freeFifo4ToFifo3             ),
    .o_fire         (w_fire3                        ),
    .rst            (rst                            )
);
(*dont_touch = "yes"*)reg [255:0]r_dataFromMem_256;
always @(posedge w_fire3 or negedge rst) begin
    if (!rst) begin
        r_dataFromMem_256 <= 0;
    end else begin
        r_dataFromMem_256 <= i_dataFromMem_256;
    end
end
(*dont_touch = "yes"*)reg [511:0]r_dataFromMem_512;
always @(posedge w_fire5 or negedge rst) begin
    if (!rst) begin
        r_dataFromMem_512 <= 0;
    end
    else begin
        if (r_counter_2 == 2'b01) begin
            r_dataFromMem_512[511:256] <= r_dataFromMem_256;
        end else if (r_counter_2 == 2'b10) begin
            r_dataFromMem_512[255:0]   <= r_dataFromMem_256;
        end
    end
end
(* dont_touch="true" *)lsu_memAckFormat_comb u_lsu_memAckFormat_comb(
    .i_dataFromMem_512  (r_dataFromMem_512          ),
    .i_en_39            (w_en_39                    ),
    .i_loadOrStore      (w_isLoad                   ),
    .i_state_2          (r_counter_2                ),
    .i_loadSign         (w_loadSign                 ),
    .i_dataFromExe_246  (r_dataFromExe_246          ),
    .o_dataToRetire_246 (w_dataToRetireMem_246      )
);
always @(posedge (w_fire4|w_fire6) or negedge rst) begin
    if (!rst) begin
        r_counter_2 <= 2'b0;
    end
    else begin
        case (r_counter_2)
            2'b00:begin
                if (w_isMemOp) begin
                    if (w_isCrosslineOp) begin
                        r_counter_2 <= 2'b01;   //ack1,high
                    end else begin
                        r_counter_2 <= 2'b10;   //ack
                    end
                end
                else begin
                    r_counter_2 <= 2'b00;
                end
            end
            2'b01:r_counter_2 <= 2'b10;     //ack2,low
            2'b10:r_counter_2 <= 2'b00;     //rst
            default:r_counter_2 <= 2'b00;
        endcase
    end
end
(* dont_touch="true" *)cFifo1_lsu u_fifo4(
    .i_drive        (w_driveFifo3ToFifo4        ),
    .o_free         (w_freeFifo4ToFifo3         ),
    .o_driveNext    (w_driveFifo4ToFifo5        ),
    .i_freeNext     (w_freeFifo5ToFifo4         ),
    .o_fire         (w_fire4                    ),
    .rst            (rst                        )
);
(* dont_touch="true" *)cFifo1_lsu u_fifo5(
    .i_drive        (w_driveFifo4ToFifo5        ),
    .o_free         (w_freeFifo5ToFifo4         ),
    .o_driveNext    (w_driveFifo5ToEventSink1   ),
    .i_freeNext     (w_freeEventSink1ToFifo5    ),
    .o_fire         (w_fire5                    ),
    .rst            (rst                        )
);
(* dont_touch="true" *)eventSink_lsu u_EventSink1(
    .i_drive        (w_driveFifo5ToEventSink1   ),
    .o_free         (w_freeEventSink1ToFifo5    ),
    .rst            (rst                        )
);
(* dont_touch="true" *)freeSetDelay_lsu #(
    .DELAY_NUM(1),
    .DELAY_WIDTH(8)
)u_EventSource1(
    .inR            (r_counter_2[1]             ),
    .outR           (w_driveEventSource1ToMutex3),
    .rst            (rst                        )
);
wire w_driveMutex3ToFifo6,w_freeFifo6ToMutex3;
(* dont_touch="true" *)cMutexMerge2_d_lsu #(
    .DATA_WIDTH(246)
)u_Mutex3(
    .i_drive0       (w_driveSel1ToMutex3        ),
    .o_free0        (w_freeMutex3ToSel1         ),
    .i_drive1       (w_driveEventSource1ToMutex3),
    .o_free1        (),
    .o_driveNext    (w_driveMutex3ToFifo6       ),
    .i_freeNext     (w_freeFifo6ToMutex3        ),
    .i_data0        (r_dataFromExe_246          ),
    .i_data1        (w_dataToRetireMem_246      ),
    .o_data         (w_dataToRetire_246         ),
    .rst            (rst                        )
);
(* dont_touch="true" *)cFifo1_lsu u_fifo6(
    .i_drive        (w_driveMutex3ToFifo6       ),
    .o_free         (w_freeFifo6ToMutex3        ),
    .o_driveNext    (o_driveToRetire            ),
    .i_freeNext     (i_freeFromRetire           ),
    .o_fire         (w_fire6                    ),
    .rst            (rst                        )
);
(*dont_touch = "yes"*)reg [245:0]r_dataToRetire_246;
always @(posedge w_fire6 or negedge rst) begin
    if (!rst) begin
        r_dataToRetire_246 <= 0;
    end
    else begin
        r_dataToRetire_246 <= w_dataToRetire_246;
    end
end
assign o_dataToRetire_246 = r_dataToRetire_246;
endmodule