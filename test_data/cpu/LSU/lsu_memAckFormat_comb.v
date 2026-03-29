module lsu_memAckFormat_comb (
//Input
    i_dataFromMem_512,i_en_39,i_loadOrStore,i_state_2,i_loadSign,
    i_dataFromExe_246,
//Output
    o_dataToRetire_246
);
    (*dont_touch = "yes"*)input     [511:0]     i_dataFromMem_512;
    (*dont_touch = "yes"*)input     [38:0]      i_en_39;
    (*dont_touch = "yes"*)input                 i_loadOrStore;
    (*dont_touch = "yes"*)input     [1:0]       i_state_2;
    (*dont_touch = "yes"*)input                 i_loadSign;
    (*dont_touch = "yes"*)input     [245:0]     i_dataFromExe_246;
    (*dont_touch = "yes"*)output    [245:0]     o_dataToRetire_246;
    
    (*dont_touch = "yes"*)wire      [311:0]     w_data_312;
    (*dont_touch = "yes"*)wire      [4:0]       w_byteEnStart_5;
    (*dont_touch = "yes"*)wire      [63:0]      w_data_64;
    (*dont_touch = "yes"*)wire                  w_isDouble;
    (*dont_touch = "yes"*)wire                  w_isWord;
    (*dont_touch = "yes"*)wire                  w_isHalf;
    (*dont_touch = "yes"*)wire                  w_isByte;
    (*dont_touch = "yes"*)wire      [63:0]      w_dataSignExtend_64;
    (*dont_touch = "yes"*)wire      [63:0]      w_dataZeroExtend_64;
    (*dont_touch = "yes"*)wire      [63:0]      w_data2_64;
    assign w_data_312           = i_dataFromMem_512[311:0];
    assign w_isDouble           = i_dataFromExe_246[129:128] == 2'b11;
    assign w_isWord             = i_dataFromExe_246[129:128] == 2'b10;
    assign w_isHalf             = i_dataFromExe_246[129:128] == 2'b01;
    assign w_isByte             = i_dataFromExe_246[129:128] == 2'b00;
    assign w_byteEnStart_5      = i_dataFromExe_246[127:64];
    // assign w_data_64            = w_data_312 >> ((32 - w_byteEnStart_5) * 8);
    assign w_data_64            = w_data_312 >> (w_byteEnStart_5 * 8);
    assign w_dataSignExtend_64  = w_isDouble ? w_data_64:
                                  w_isWord   ? {{32{w_data_64[31]}},w_data_64[31:0]}:
                                  w_isHalf   ? {{48{w_data_64[15]}},w_data_64[15:0]}:
                                              {{56{w_data_64[7] }},w_data_64[7:0]};
    assign w_dataZeroExtend_64  = w_isDouble ? w_data_64:
                                  w_isWord   ? {32'b0,w_data_64[31:0]}:
                                  w_isHalf   ? {48'b0,w_data_64[15:0]}:
                                              {56'b0,w_data_64[7:0]};
    assign w_data2_64           = ~i_loadOrStore ? 64'b0:
                                  i_loadSign     ? w_dataSignExtend_64: 
                                                   w_dataZeroExtend_64;
    assign o_dataToRetire_246   = {
            i_dataFromExe_246[245:64],
            w_data2_64
    };
endmodule