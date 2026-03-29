module lsu_memReqFormat_comb(
//Inputs
    i_data_246,
//Outputs   
    o_memReqLow_136,o_memReqHigh_136,
    o_en_39,o_isMemOp,o_isCrosslineOp,o_isLoad,o_isSignLoad
);
// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Port declarations
//----------------------------------------------------------------------------
    (*dont_touch = "yes"*)input   [246-1:0]   i_data_246;     //{64-pc,1-compress,32-instr,4-type,5-rd,12-func,64-addr,64-data}
    (*dont_touch = "yes"*)output  [136-1:0]   o_memReqHigh_136;//{8-wen,64-addr,64-data}
    (*dont_touch = "yes"*)output  [136-1:0]   o_memReqLow_136;  
    (*dont_touch = "yes"*)output  [38:0]      o_en_39;
    (*dont_touch = "yes"*)output              o_isMemOp;
    (*dont_touch = "yes"*)output              o_isCrosslineOp;
    (*dont_touch = "yes"*)output              o_isLoad;
    (*dont_touch = "yes"*)output              o_isSignLoad;
// ---------------------------------------------------------------------------
// Signal declarations
// ---------------------------------------------------------------------------
    (*dont_touch = "yes"*)wire                w_isLoad;
    (*dont_touch = "yes"*)wire                w_isStore;
    (*dont_touch = "yes"*)wire                w_isMemOp;
    (*dont_touch = "yes"*)wire                w_loadSign;
    (*dont_touch = "yes"*)wire                w_isDouble;
    (*dont_touch = "yes"*)wire                w_isWord;
    (*dont_touch = "yes"*)wire                w_isHalf;
    (*dont_touch = "yes"*)wire                w_isByte;
    (*dont_touch = "yes"*)wire    [63:0]      w_addr_64;
    (*dont_touch = "yes"*)wire    [63:0]      w_data_64;
    (*dont_touch = "yes"*)wire                w_isLineCross;
    (*dont_touch = "yes"*)wire    [4:0]       w_offsetByte_4;
    (*dont_touch = "yes"*)wire    [4:0]       w_byteEnStart_5;
    (*dont_touch = "yes"*)wire    [5:0]       w_byteEnEnd_5;
    (*dont_touch = "yes"*)reg     [38:0]      r_byteEn_39;
    (*dont_touch = "yes"*)wire    [38:0]      w_byteEn_39;
    (*dont_touch = "yes"*)wire    [7:0]       w_enHigh_8;
    (*dont_touch = "yes"*)wire    [7:0]       w_enLow_8;
    (*dont_touch = "yes"*)wire    [63:0]      w_dataHigh_64;
    (*dont_touch = "yes"*)wire    [63:0]      w_dataLow_64;
    (*dont_touch = "yes"*)wire    [63:0]      w_addrHigh_64;
    (*dont_touch = "yes"*)wire    [63:0]      w_addrLow_64;
    (*dont_touch = "yes"*)wire    [7:0]       w_wenHigh_8;
    (*dont_touch = "yes"*)wire    [7:0]       w_wenLow_8;

    assign w_isLoad         = i_data_246[148:145] == 4'b0011;
    assign w_isStore        = i_data_246[148:145] == 4'b0010;
    assign w_isMemOp        = w_isLoad | w_isStore;
    assign w_isDouble       = i_data_246[129:128] == 2'b11;
    assign w_isWord         = i_data_246[129:128] == 2'b10;
    assign w_isHalf         = i_data_246[129:128] == 2'b01;
    assign w_isByte         = i_data_246[129:128] == 2'b00;
    assign w_addr_64        = i_data_246[127:64];
    assign w_data_64        = i_data_246[63:0];
    assign w_isLineCross    = w_isHalf   &  (w_addr_64[4:0] == 5'b1_1111)|
                              w_isWord   &  (w_addr_64[4:1] == 4'b1111  )|
                              w_isDouble &  (w_addr_64[4:2] == 3'b111   );
    assign w_byteEnStart_5  = w_addr_64[4:0];
    assign w_byteEnEnd_5    = w_isDouble ? w_byteEnStart_5 + 8 - 1:
                              w_isWord   ? w_byteEnStart_5 + 4 - 1:
                              w_isHalf   ? w_byteEnStart_5 + 2 - 1:
                                           w_byteEnStart_5 + 1 - 1;
    integer k;
    always @* begin
        r_byteEn_39 = {39{1'b0}};
        if (w_isMemOp) begin
            for (k = 0; k < 39; k = k + 1) begin
                if (k >= w_byteEnStart_5 && k <= w_byteEnEnd_5)
                    r_byteEn_39[k] = 1'b1;
                else
                    r_byteEn_39[k] = 1'b0;
            end
        end
    end
    assign w_byteEn_39      = r_byteEn_39;
    assign w_enHigh_8       = {1'b0,w_byteEn_39[38:32]};
    assign w_enLow_8        = w_isDouble ? 8'b1111_1111:
                              w_isWord   ? 8'b0000_1111:
                              w_isHalf   ? 8'b0000_0011:
                                           8'b0000_0001;
    assign w_dataHigh_64    = w_data_64 >> ((32 - w_byteEnStart_5) * 8);
    assign w_dataLow_64     = w_data_64;
    assign w_addrHigh_64    = {w_addr_64[63:4],4'b0000} + 5'b1_0000;
    assign w_addrLow_64     = w_addr_64;
    assign w_wenHigh_8      = w_isStore ? w_enHigh_8 : 8'b0000_0000;
    assign w_wenLow_8       = w_isStore ? w_enLow_8  : 8'b0000_0000;
    assign o_memReqHigh_136 = {w_wenHigh_8,w_addrHigh_64,w_dataHigh_64};
    assign o_memReqLow_136  = {w_wenLow_8,w_addrLow_64,w_dataLow_64};
    assign o_isMemOp        = w_isMemOp;
    assign o_isCrosslineOp  = w_isLineCross;
    assign o_isLoad         = w_isLoad;
    assign o_isSignLoad     = i_data_246[130];
    assign o_en_39          = w_byteEn_39;
endmodule