//RV64-CSR
// `define CSRF
module csrf(
    input           i_driveRead,
    output          o_freeRead,
    input [12-1:0]  i_addrRead_12,

    output          o_driveRead,
    input           i_freeRead,
    output[64-1:0]  o_dataRead_64,

    input           i_driveWrite,
    output          o_freeWrite,
    input [76-1:0]  i_dataWrite_76,  // {write_en, addr_12, data_64}

    input           rstn
);
(*dont_touch = "yes"*)wire w_fire_read, w_fire_write;
(*dont_touch = "yes"*)wire w_driveWrite, w_freeWrite;
(* dont_touch="true" *) cFifo1_idu u_fifo_write(
    .i_drive    (i_driveWrite),
    .o_free     (o_freeWrite),
    .o_driveNext(w_driveWrite),
    .i_freeNext (w_freeWrite),
    .o_fire     (w_fire_write),
    .rst        (rstn)
);
(* dont_touch="true" *) freeSetDelay #(.N(10)) u_freeSetDelay(
    .inR  (w_driveWrite),
    .outR (w_freeWrite),
    .rst  (rstn)
);
(* dont_touch="true" *) cFifo1_idu u_fifo_read(
    .i_drive    (i_driveRead),
    .o_free     (o_freeRead),
    .o_driveNext(o_driveRead),
    .i_freeNext (i_freeRead),
    .o_fire     (w_fire_read),
    .rst        (rstn)
);
`ifdef CSRF
reg [63:0] r_csrf[0:4095];
reg [63:0] r_csrf_out;
integer i;
always @(posedge w_fire_write or negedge rstn) begin
    if (!rstn) begin
        for (i=0; i<4096; i=i+1) r_csrf[i] <= 64'd0;
    end else begin
        r_csrf[i_dataWrite_76[75:64]] <= i_dataWrite_76[63:0];
    end
end
always @(posedge w_fire_read or negedge rstn) begin
    if (!rstn)
        r_csrf_out <= 64'd0;
    else
        r_csrf_out <= r_csrf[i_addrRead_12];
end
assign o_dataRead_64 = r_csrf_out;
`else
assign o_dataRead_64 = 64'd0;
`endif

endmodule