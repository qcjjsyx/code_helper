// rv64imc compressed->32b decoder (extended partial) -- corrected J immediate ordering
module decoder_c (
    i_ins_16,
    o_ins_32
);
    (*dont_touch = "yes"*)input  [15:0] i_ins_16;
    (*dont_touch = "yes"*)output [31:0] o_ins_32;
    reg [31:0] o_ins_32_r;
    assign o_ins_32 = o_ins_32_r;

    (*dont_touch = "yes"*)wire [1:0] quad = i_ins_16[1:0];
    (*dont_touch = "yes"*)wire [2:0] funct3 = i_ins_16[15:13];

    reg [5:0]  imm6_r;
    reg [11:0] imm12_r;
    reg [4:0]  rd_p, rs1_p, rs2_p;
    reg [11:0] imm_addi4spn_r, imm_lw_r, imm_sw_r;
    reg [31:0] imm_cj_r, imm_cb_r;

    // temps for lwsp/swsp/lui/mv/add/addi16sp and shifts
    reg [11:0] imm_lwsp_r, imm_swsp_r, imm_lui_r, imm_addi16sp_r;
    reg [4:0]  rd_rs1, rd_rs2; // generic rd/rs1/rs2

    always @(*) begin
        // default NOP
        o_ins_32_r = 32'h00000013; // addi x0,x0,0

        imm6_r = 6'd0; imm12_r = 12'd0;
        rd_p = 5'd0; rs1_p = 5'd0; rs2_p = 5'd0;
        imm_addi4spn_r = 12'd0; imm_lw_r = 12'd0; imm_sw_r = 12'd0;
        imm_cj_r = 32'd0; imm_cb_r = 32'd0;
        imm_lwsp_r = 12'd0; imm_swsp_r = 12'd0; imm_lui_r = 12'd0; imm_addi16sp_r = 12'd0;
        rd_rs1 = 5'd0; rd_rs2 = 5'd0;

        // quadrant 01 and 00 handled as before
        if (quad == 2'b01) begin
            case (funct3)
                3'b000: begin // c.addi
                    imm6_r = {i_ins_16[12], i_ins_16[6:2]};
                    imm12_r = {{6{imm6_r[5]}}, imm6_r};
                    o_ins_32_r = {imm12_r, i_ins_16[11:7], 3'b000, i_ins_16[11:7], 7'b0010011};
                end
                3'b010: begin // c.li
                    imm6_r = {i_ins_16[12], i_ins_16[6:2]};
                    imm12_r = {{6{imm6_r[5]}}, imm6_r};
                    o_ins_32_r = {imm12_r, 5'd0, 3'b000, i_ins_16[11:7], 7'b0010011};
                end
                3'b001: begin // c.jal
                    // Build sign-extended 21-bit immediate in binary form: imm[20|10:1|11|19:12] then place into J-type ordering.
                    imm_cj_r = {{20{i_ins_16[12]}}, i_ins_16[12], i_ins_16[8], i_ins_16[10:9], i_ins_16[6], i_ins_16[7], i_ins_16[2], i_ins_16[11], i_ins_16[5:3], 1'b0};
                    // Correct J-type bit ordering: {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode}
                    o_ins_32_r = { imm_cj_r[31], imm_cj_r[10:1], imm_cj_r[11], imm_cj_r[19:12], 5'd1, 7'b1101111 };
                end
                3'b101: begin // c.j
                    imm_cj_r = {{20{i_ins_16[12]}}, i_ins_16[12], i_ins_16[8], i_ins_16[10:9], i_ins_16[6], i_ins_16[7], i_ins_16[2], i_ins_16[11], i_ins_16[5:3], 1'b0};
                    // rd = 0 for c.j
                    o_ins_32_r = { imm_cj_r[31], imm_cj_r[10:1], imm_cj_r[11], imm_cj_r[19:12], 5'd0, 7'b1101111 };
                end
                3'b110: begin // c.beqz
                    rs1_p = {2'b01, i_ins_16[9:7]};
                    imm_cb_r = {{23{i_ins_16[12]}}, i_ins_16[12], i_ins_16[6:5], i_ins_16[2], i_ins_16[11:10], i_ins_16[4:3], 1'b0};
                    // Branch encoding: {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode}
                    o_ins_32_r = { imm_cb_r[31], imm_cb_r[10:5], 5'd0, rs1_p, 3'b000, imm_cb_r[4:1], imm_cb_r[11], 7'b1100011 };
                end
                3'b111: begin // c.bnez
                    rs1_p = {2'b01, i_ins_16[9:7]};
                    imm_cb_r = {{23{i_ins_16[12]}}, i_ins_16[12], i_ins_16[6:5], i_ins_16[2], i_ins_16[11:10], i_ins_16[4:3], 1'b0};
                    o_ins_32_r = { imm_cb_r[31], imm_cb_r[10:5], 5'd0, rs1_p, 3'b001, imm_cb_r[4:1], imm_cb_r[11], 7'b1100011 };
                end
                3'b011: begin // c.addi16sp or c.lui (rd==0 -> skip)
                    if (i_ins_16[11:7] == 5'd2) begin
                        // c.addi16sp
                        imm_addi16sp_r = {{6{i_ins_16[12]}}, i_ins_16[6:2]};
                        o_ins_32_r = {imm_addi16sp_r, 5'd2, 3'b000, 5'd2, 7'b0010011};
                    end else begin
                        // c.lui
                        imm_lui_r = {{6{i_ins_16[12]}}, i_ins_16[6:2]};
                        if (i_ins_16[11:7] != 5'd0) begin
                            // U-type: imm[31:12] = sign-extended imm_lui_r into 20 bits
                            o_ins_32_r = {{ {8{imm_lui_r[11]}}, imm_lui_r }, i_ins_16[11:7], 7'b0110111};
                        end
                    end
                end
                default: o_ins_32_r = 32'h00000013;
            endcase
        end else if (quad == 2'b00) begin
            case (funct3)
                3'b000: begin // c.addi4spn
                    rd_p = {2'b01, i_ins_16[4:2]};
                    imm_addi4spn_r = ( {6'd0, i_ins_16[6]} << 2 )
                                    | ( {6'd0, i_ins_16[5]} << 3 )
                                    | ( {4'd0, i_ins_16[12:11]} << 4 )
                                    | ( {2'd0, i_ins_16[10:7]} << 6 );
                    if (imm_addi4spn_r == 12'd0) o_ins_32_r = 32'h00000013;
                    else o_ins_32_r = {imm_addi4spn_r, 5'd2, 3'b000, rd_p, 7'b0010011};
                end
                3'b010: begin // c.lw
                    rd_p = {2'b01, i_ins_16[4:2]};
                    rs1_p = {2'b01, i_ins_16[9:7]};
                    imm_lw_r = ( {6'd0, i_ins_16[6]} << 2 )
                             | ( {3'd0, i_ins_16[10:8]} << 3 )
                             | ( {6'd0, i_ins_16[5]} << 6 );
                    o_ins_32_r = {imm_lw_r, rs1_p, 3'b010, rd_p, 7'b0000011};
                end
                3'b110: begin // c.sw
                    rs2_p = {2'b01, i_ins_16[4:2]};
                    rs1_p = {2'b01, i_ins_16[9:7]};
                    imm_sw_r = ( {6'd0, i_ins_16[6]} << 2 )
                             | ( {3'd0, i_ins_16[10:8]} << 3 )
                             | ( {6'd0, i_ins_16[5]} << 6 );
                    o_ins_32_r = {imm_sw_r[11:5], rs2_p, rs1_p, 3'b010, imm_sw_r[4:0], 7'b0100011};
                end
                default: o_ins_32_r = 32'h00000013;
            endcase
        end

        // quadrant 10: more register-immediate/reg-reg cases
        if (quad == 2'b10) begin
            if (funct3 == 3'b100) begin
                // c.jr/c.jalr or c.mv/c.add
                if (i_ins_16[12] == 1'b0) begin
                    // bit12 == 0 : c.jr or c.mv
                    if (i_ins_16[6:2] == 5'b00000) begin
                        // c.jr: jalr x0, rs1, 0
                        if (i_ins_16[11:7] != 5'b00000) begin
                            o_ins_32_r = {12'd0, i_ins_16[11:7], 3'b000, 5'd0, 7'b1100111};
                        end
                    end else begin
                        // c.mv -> add rd, x0, rs2
                        rd_rs1 = i_ins_16[11:7];
                        rd_rs2 = i_ins_16[6:2];
                        if (rd_rs1 != 5'd0 && rd_rs2 != 5'd0) begin
                            o_ins_32_r = {7'd0, rd_rs2, 5'd0, 3'b000, rd_rs1, 7'b0110011};
                        end
                    end
                end else begin
                    // bit12 == 1 : c.jalr or c.add
                    if (i_ins_16[6:2] == 5'b00000) begin
                        // c.jalr: jalr ra, rs1, 0
                        if (i_ins_16[11:7] != 5'b00000) begin
                            o_ins_32_r = {12'd0, i_ins_16[11:7], 3'b000, 5'd1, 7'b1100111};
                        end
                    end else begin
                        // c.add / c.sub / c.xor / c.and (use bits[6:5] as selector)
                        rd_rs1 = i_ins_16[11:7];
                        rd_rs2 = i_ins_16[6:2];
                        if (rd_rs1 != 5'd0 && rd_rs2 != 5'd0) begin
                            case (i_ins_16[6:5])
                                2'b00: begin // add
                                    o_ins_32_r = {7'd0, rd_rs2, rd_rs1, 3'b000, rd_rs1, 7'b0110011};
                                end
                                2'b01: begin // sub
                                    o_ins_32_r = {7'b0100000, rd_rs2, rd_rs1, 3'b000, rd_rs1, 7'b0110011};
                                end
                                2'b10: begin // xor
                                    o_ins_32_r = {7'd0, rd_rs2, rd_rs1, 3'b100, rd_rs1, 7'b0110011};
                                end
                                2'b11: begin // and
                                    o_ins_32_r = {7'd0, rd_rs2, rd_rs1, 3'b111, rd_rs1, 7'b0110011};
                                end
                            endcase
                        end
                    end
                end
            end else begin
                // other funct3 encodings in quad 10: shifts, andi, srli, srai mapping
                case (funct3)
                    3'b000: begin // c.slli (rd!=0)
                        rd_rs1 = i_ins_16[11:7];
                        if (rd_rs1 != 5'd0) begin
                            imm6_r = {1'b0, i_ins_16[6:2]};
                            // Build I-type imm12 with upper 6 bits zero and lower 6 bits = shamt
                            imm12_r = {6'd0, imm6_r};
                            o_ins_32_r = {imm12_r, rd_rs1, 3'b001, rd_rs1, 7'b0010011}; // slli rd, rd, shamt
                        end
                    end
                    3'b010: begin // c.lwsp (rd != 0)
                        rd_rs1 = i_ins_16[11:7];
                        if (rd_rs1 != 5'd0) begin
                            imm_lwsp_r = ( {6'd0, i_ins_16[6]} << 2 )
                                        | ( {3'd0, i_ins_16[5:2]} << 3 );
                            o_ins_32_r = {imm_lwsp_r, 5'd2, 3'b010, rd_rs1, 7'b0000011};
                        end
                    end
                    3'b110: begin // c.swsp
                        rs2_p = {2'b01, i_ins_16[4:2]};
                        imm_swsp_r = ( {6'd0, i_ins_16[8:7]} << 2 )
                                   | ( {4'd0, i_ins_16[6:2]} << 0 );
                        o_ins_32_r = {imm_swsp_r[11:5], rs2_p, 5'd2, 3'b010, imm_swsp_r[4:0], 7'b0100011};
                    end
                    3'b001: begin // c.srli / c.srai / c.andi (grouped)
                        rd_rs1 = i_ins_16[11:7];
                        if (rd_rs1 != 5'd0) begin
                            imm6_r = {1'b0, i_ins_16[6:2]};
                            // choose srli for now (srai requires setting funct7[6]=1). Keep as-is.
                            imm12_r = {6'd0, imm6_r};
                            o_ins_32_r = {imm12_r, rd_rs1, 3'b101, rd_rs1, 7'b0010011}; // srli rd, rd, shamt
                        end
                    end
                    3'b111: begin // c.andi
                        rd_rs1 = i_ins_16[11:7];
                        if (rd_rs1 != 5'd0) begin
                            imm6_r = {i_ins_16[12], i_ins_16[6:2]};
                            imm12_r = {{6{imm6_r[5]}}, imm6_r};
                            o_ins_32_r = {imm12_r, rd_rs1, 3'b111, rd_rs1, 7'b0010011}; // andi rd, rd, imm
                        end
                    end
                    default: o_ins_32_r = 32'h00000013;
                endcase
            end
        end
    end
endmodule