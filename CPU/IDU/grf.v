//RV64-GRF
module grf(
i_driveRead,i_dataRead_10,i_freeRead,i_driveWrite,i_dataWrite_69,rstn,
o_freeRead,o_driveRead,o_dataRead_128,o_freeWrite
);
    (*dont_touch = "yes"*)input           i_driveRead;
    (*dont_touch = "yes"*)output          o_freeRead;
    (*dont_touch = "yes"*)input [10-1:0]  i_dataRead_10;//{rs1_5,rs2_5}
    
    (*dont_touch = "yes"*)output          o_driveRead;
    (*dont_touch = "yes"*)input           i_freeRead;
    (*dont_touch = "yes"*)output[128-1:0] o_dataRead_128;

    (*dont_touch = "yes"*)input           i_driveWrite;
    (*dont_touch = "yes"*)output          o_freeWrite;
    (*dont_touch = "yes"*)input [69-1:0]  i_dataWrite_69;//{data_64,rd_5}

    (*dont_touch = "yes"*)input           rstn;

    (*dont_touch = "yes"*)wire w_fire_read,w_fire_write;
    (*dont_touch = "yes"*)wire w_driveWrite,w_freeWrite;
(* dont_touch="true" *)cFifo1_idu u_fifo_write(
    .i_drive    (i_driveWrite),
    .o_free     (o_freeWrite),
    .o_driveNext(w_driveWrite),
    .i_freeNext (w_freeWrite),
    .o_fire     (w_fire_write),
    .rst        (rstn)
);
(* dont_touch="true" *)freeSetDelay#(
    .N(10)
)u_freeSetDelay(
    .inR (w_driveWrite),
    .outR(w_freeWrite),
    .rst (rstn)
);
(* dont_touch="true" *)cFifo1_idu u_fifo_read(
    .i_drive    (i_driveRead),
    .o_free     (o_freeRead),
    .o_driveNext(o_driveRead),
    .i_freeNext (i_freeRead),
    .o_fire     (w_fire_read),
    .rst        (rstn)
);
(*dont_touch = "yes"*)reg [64-1:0]r_grf[0:32-1];
(*dont_touch = "yes"*)reg [64-1:0]r_grf_out1_64,r_grf_out2_64;
integer i;
always @(posedge w_fire_write or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i < 32; i = i + 1)begin
            r_grf[i] <= 0;
        end
    end
    else if (i_dataWrite_69[4:0]!=0) begin//x0 cannot be written
        r_grf[i_dataWrite_69[4:0]] <= i_dataWrite_69[68:5];
    end
end
always @(posedge w_fire_read or negedge rstn) begin
    if (!rstn) begin
        r_grf_out1_64 <= 0;
        r_grf_out2_64 <= 0;
    end
    else begin
        r_grf_out1_64 <=r_grf[i_dataRead_10[9:5]];
        r_grf_out2_64 <=r_grf[i_dataRead_10[4:0]];
    end
end
    assign o_dataRead_128 = {r_grf_out1_64,r_grf_out2_64};//{rs1,rs2}
endmodule