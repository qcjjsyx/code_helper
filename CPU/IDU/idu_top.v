module idu_top (
    i_driveFromIfu,i_dataFromIfu_97,i_freeFromExe,i_driveWriteGrf,i_dataWriteGrf_69,i_driveWriteCsr,i_dataWriteCsr_76,
    o_freeToIfu,o_driveToExe,o_dataToExe_343,o_freeWriteGrf,o_freeWriteCsr,
    rst
);
    (*dont_touch = "yes"*)input i_driveWriteGrf;
    (*dont_touch = "yes"*)output o_freeWriteGrf;
    (*dont_touch = "yes"*)input [69-1:0]i_dataWriteGrf_69;
    
    (*dont_touch = "yes"*)input i_driveWriteCsr;
    (*dont_touch = "yes"*)output o_freeWriteCsr;
    (*dont_touch = "yes"*)input [76-1:0]i_dataWriteCsr_76;

    (*dont_touch = "yes"*)input i_driveFromIfu;
    (*dont_touch = "yes"*)input [97-1:0]i_dataFromIfu_97;//{1-c,64-pc,32-ins}
    (*dont_touch = "yes"*)output o_freeToIfu;
    
    (*dont_touch = "yes"*)output o_driveToExe;
    (*dont_touch = "yes"*)input i_freeFromExe;
    (*dont_touch = "yes"*)output [343-1:0]o_dataToExe_343;

    (*dont_touch = "yes"*)input rst;
    (*dont_touch = "yes"*)wire w_fire_saveInputDataFromIfu,w_drive1,w_free1,w_aluImm_en;
    (*dont_touch = "yes"*)wire rstn = rst;
(*dont_touch = "yes"*)cFifo1_idu u_fifo_saveInputDataFromIfu(
    .i_drive    (i_driveFromIfu),
    .o_free     (o_freeToIfu),
    .o_driveNext(w_drive1),
    .i_freeNext (w_free1),
    .o_fire     (w_fire_saveInputDataFromIfu),
    .rst        (rstn)
);
(*dont_touch = "yes"*)reg [97-1:0]r_dataFromIfu_97;
always @(posedge w_fire_saveInputDataFromIfu or negedge rstn) begin
    if (!rstn) begin
        r_dataFromIfu_97 <= 0;
    end
    else begin
        r_dataFromIfu_97 <= i_dataFromIfu_97;
    end
end
    (*dont_touch = "yes"*)wire [32-1:0] w_ins_c_32;
(*dont_touch = "yes"*)decoder_c u_decoder_c(
    .i_ins_16(r_dataFromIfu_97[15:0]),
    .o_ins_32(w_ins_c_32)
);
    (*dont_touch = "yes"*)wire [32-1:0] w_ins_32;
    (*dont_touch = "yes"*)wire [55-1:0] o_data_55;
    (*dont_touch = "yes"*)wire [64-1:0] w_imm_64;
    (*dont_touch = "yes"*)wire [10-1:0] w_readGrf_10;
    assign w_ins_32 = r_dataFromIfu_97[96] ? w_ins_c_32 : r_dataFromIfu_97[31:0];
(*dont_touch = "yes"*)decoder u_decoder(
    .i_ins_33       ({r_dataFromIfu_97[96],w_ins_32}),
    .o_data_55      (o_data_55),
    .o_imm_64       (w_imm_64),
    .o_readGrf_10   (w_readGrf_10),
    .o_aluImm_en    (w_aluImm_en)
);

(*dont_touch = "yes"*)csrf u_csrf(
    .i_driveRead     (),
    .o_freeRead      (),
    .i_addrRead_12   (),
    .o_driveRead     (),
    .i_freeRead      (),
    .o_dataRead_64   (),
    .i_driveWrite    (i_driveWriteCsr   ),
    .o_freeWrite     (o_freeWriteCsr    ),
    .i_dataWrite_76  (i_dataWriteCsr_76 ),
    .rstn            (rstn              )
);
// (*dont_touch = "yes"*)wire w_drive2,w_free2;
(*dont_touch = "yes"*)wire [128-1:0]w_dataReadGrf_128;
(*dont_touch = "yes"*)grf u_grf(
    .i_driveRead     (w_drive1),
    .o_freeRead      (w_free1),
    .i_dataRead_10   (w_readGrf_10),
    .o_driveRead     (o_driveToExe),
    .i_freeRead      (i_freeFromExe),
    .o_dataRead_128  (w_dataReadGrf_128),
    .i_driveWrite    (i_driveWriteGrf   ),
    .o_freeWrite     (o_freeWriteGrf    ),
    .i_dataWrite_69  (i_dataWriteGrf_69 ),
    .rstn            (rstn)
);
(*dont_touch = "yes"*)wire[64-1:0] w_imm_grf_64;
assign w_imm_grf_64 = w_aluImm_en ? w_imm_64 : w_dataReadGrf_128[63:0];
assign o_dataToExe_343 = {
    o_data_55,                      //[342:288]
    r_dataFromIfu_97[31:0],         //[287:256]
    r_dataFromIfu_97[95:32],        //[255:192]
    w_imm_64,                       //[191:128]
    w_imm_grf_64,                   //!csr,[127:64],op2(rs2OrImm)
    w_dataReadGrf_128[127:64]       //[63:0],op1(rs1)
};
endmodule