`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 16:00:06
// Design Name: 
// Module Name: instSplit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// The combinational logic module of this set is designed to split the 
// incoming 64-bit instruction set and output all the instructions for this round.
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module instSplit(
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input rst,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_drvFICache,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_free2ICache,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input i_freeFMerge,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output o_drv2Merge,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input w_intExcpBranchValid,

    // the PC that used to fetch
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [31:0] i_basePC_32,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)input [63:0] i_inst_64,

    // indicates who caused this instruction fetch, whether it is due to an interrupt exception, a jump, or a normal instruction fetch
    // input [1:0] w_PCFrom,
    // each inst has 1 bit in front of its inst to indicate if it is valid 
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [32:0] o_inst0_33,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [32:0] o_inst1_33,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [32:0] o_inst2_33,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [32:0] o_inst3_33,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_inst0PC_32,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_inst1PC_32,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_inst2PC_32,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_inst3PC_32,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [2:0] o_instCount,

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)output [31:0] o_normNextPc_32

    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [32:0] r_inst0_33,r_inst1_33,r_inst2_33,r_inst3_33;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_inst0PC_32,r_inst1PC_32,r_inst2PC_32,r_inst3PC_32;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_normNextPc_32;

    
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [2:0] r_instCont_3;     // count how much insts are their in this turn 
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg r_preState;             // the state of last fetch, if it has remaining,
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] r_remaining_16;  //the inst remain from before

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [1:0] w_start;         // fetch may not start at base. The address may be misaligned.  
    assign w_start = i_basePC_32[2:1];

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_state;
    assign w_state = ~w_intExcpBranchValid & r_preState;  // if there is interrupt or exception or branch we dont need to care about last state

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [15:0] w_part1_16;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [15:0] w_part2_16;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [15:0] w_part3_16;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [15:0] w_part4_16;
    assign w_part1_16 = i_inst_64[15:0];
    assign w_part2_16 = i_inst_64[31:16];
    assign w_part3_16 = i_inst_64[47:32];
    assign w_part4_16 = i_inst_64[63:48];
    reg [15:0] r_empty16;
    reg r_16Mode,r_32Mode; 
    
    // mode 0:this part is the mode of 16 bit
    // mode 1:this part is the mode of 32 bit
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_part1Mode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_part2Mode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_part3Mode;
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire w_part4Mode;
    assign w_part1Mode = (w_part1_16[15:13]==3'b111 && w_part1_16[12:11]!=2'b00) ? 1'b1 : 1'b0;
    assign w_part2Mode = (w_part2_16[15:13]==3'b111 && w_part2_16[12:11]!=2'b00) ? 1'b1 : 1'b0;
    assign w_part3Mode = (w_part3_16[15:13]==3'b111 && w_part3_16[12:11]!=2'b00) ? 1'b1 : 1'b0;
    assign w_part4Mode = (w_part4_16[15:13]==3'b111 && w_part4_16[12:11]!=2'b00) ? 1'b1 : 1'b0;

    wire [31:0] w_PC_Loclast = i_basePC_32-32'h0000_0002;
    wire [31:0] w_PC_Loc2    = i_basePC_32+2;
    wire [31:0] w_PC_Loc4    = i_basePC_32+4;
    wire [31:0] w_PC_Loc6    = i_basePC_32+6;
    wire [31:0] w_PC_Loc8    = i_basePC_32+8;

    wire [32:0] w_inst16_p1 = {r_16Mode,r_empty16,i_inst_64[15: 0]};
    wire [32:0] w_inst16_p2 = {r_16Mode,r_empty16,i_inst_64[31:16]};
    wire [32:0] w_inst16_p3 = {r_16Mode,r_empty16,i_inst_64[47:32]};
    wire [32:0] w_inst16_p4 = {r_16Mode,r_empty16,i_inst_64[63:48]};

    wire [32:0] w_inst32_p0 = {r_32Mode,r_remaining_16  ,i_inst_64[15: 0]};
    wire [32:0] w_inst32_p1 = {r_32Mode,i_inst_64[15: 0],i_inst_64[31:16]};
    wire [32:0] w_inst32_p2 = {r_32Mode,i_inst_64[31:16],i_inst_64[47:32]};
    wire [32:0] w_inst32_p3 = {r_32Mode,i_inst_64[47:32],i_inst_64[63:48]};

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [2:0] w_fetchFire0_3;
    //11/29 zwm add delay
    wire w_drvFICache,w_drvFICache_t,w_drvFICache_t1,w_drv2Merge;
    delay8U fetchFifoDelay_in1 (.inR(i_drvFICache),.outR(w_drvFICache_t), .rst(rst));
    delay8U fetchFifoDelay_in2 (.inR(w_drvFICache_t),.outR(w_drvFICache_t1), .rst(rst));
    delay8U fetchFifoDelay_in3 (.inR(w_drvFICache_t1),.outR(w_drvFICache), .rst(rst));
    delay4U fetchFifoDelay1 (.inR(w_drv2Merge),.outR(o_drv2Merge), .rst(rst));
    cFifo3_fetch fetchFifo(
    .i_drive		(w_drvFICache),
    .o_free			(o_free2ICache),
    .i_freeNext		(i_freeFMerge),
    .o_driveNext	(w_drv2Merge),
    .o_fire_3		(w_fetchFire0_3),
    .rst			(rst)
    );

    // this part determine how many insts are there in this turn
    // preState:shows if last fetch remain half 32bit
    // start:shows where this turn of fetch start
    // partXMode:shows how this part looks like
    wire w_fetchFire0_3_1, w_fetchFire0_3_2, w_fetchFire0_3_3, w_fetchFire0_3_4, w_fetchFire0_3_5;
	wire w_fetchFire0_3_6, w_fetchFire0_3_7, w_fetchFire0_3_8, w_fetchFire0_3_9, w_fetchFire0_3_10;
	wire w_fetchFire0_3_11, w_fetchFire0_3_12, w_fetchFire0_3_13, w_fetchFire0_3_14, w_fetchFire0_3_15;

	BUFM2HM buf0 (.A(w_fetchFire0_3[1]),   .Z(w_fetchFire0_3_1));
	BUFM2HM buf1 (.A(w_fetchFire0_3_1),    .Z(w_fetchFire0_3_2));
	BUFM2HM buf2 (.A(w_fetchFire0_3_2),    .Z(w_fetchFire0_3_3));
	BUFM2HM buf3 (.A(w_fetchFire0_3_3),    .Z(w_fetchFire0_3_4));
	BUFM2HM buf4 (.A(w_fetchFire0_3_4),    .Z(w_fetchFire0_3_5));
	BUFM2HM buf5 (.A(w_fetchFire0_3_5),    .Z(w_fetchFire0_3_6));
	BUFM2HM buf6 (.A(w_fetchFire0_3_6),    .Z(w_fetchFire0_3_7));
	BUFM2HM buf7 (.A(w_fetchFire0_3_7),    .Z(w_fetchFire0_3_8));
	BUFM2HM buf8 (.A(w_fetchFire0_3_8),    .Z(w_fetchFire0_3_9));
	BUFM2HM buf9 (.A(w_fetchFire0_3_9),    .Z(w_fetchFire0_3_10));
	BUFM2HM buf10 (.A(w_fetchFire0_3_10),    .Z(w_fetchFire0_3_11));
	BUFM2HM buf11 (.A(w_fetchFire0_3_11),    .Z(w_fetchFire0_3_12));
	BUFM2HM buf12 (.A(w_fetchFire0_3_12),    .Z(w_fetchFire0_3_13));
	BUFM2HM buf13 (.A(w_fetchFire0_3_13),    .Z(w_fetchFire0_3_14));
	BUFM2HM buf14 (.A(w_fetchFire0_3_14),    .Z(w_fetchFire0_3_15));

    always@(posedge w_fetchFire0_3[0]  or negedge rst)begin
    if(!rst)begin
            r_16Mode        <= 0;
            r_32Mode        <= 1;
            r_empty16       <= 0;
        end
    end


    always@(posedge w_fetchFire0_3_15  or negedge rst)begin
        if(!rst)begin
            r_inst0_33 <= 33'b0;
            r_inst1_33 <= 33'b0;
            r_inst2_33 <= 33'b0;
            r_inst3_33 <= 33'b0;
            r_inst0PC_32 <= 32'b0;
            r_inst1PC_32 <= 32'b0;
            r_inst2PC_32 <= 32'b0;
            r_inst3PC_32 <= 32'b0;
            r_remaining_16  <= 16'b0;
            // initial fetch from base
            r_normNextPc_32 <= 32'h00000090;
            r_instCont_3 <= 3'b0;
            r_preState <= 1'b0;
        end
        else begin
            case({w_state,w_start,w_part1Mode,w_part2Mode,w_part3Mode,w_part4Mode})
                /**
                * start from base addr
                */
                // 4*16bit insts
                7'b0_00_0000:
                begin 
                    r_inst0_33 <= w_inst16_p1;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst16_p3;
                    r_inst3_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_inst3PC_32 <= w_PC_Loc6;
                    r_instCont_3 <= 3'd4;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                //16 16 16 32
                7'b0_00_0001:
                begin 
                    r_inst0_33 <= w_inst16_p1;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst16_p3;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b1;
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                //16 16 32 
                7'b0_00_0010,7'b0_00_0011:
                begin 
                    r_inst0_33 <= w_inst16_p1;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst32_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // 16 32 16
                7'b0_00_0100,7'b0_00_0110:
                begin
                    r_inst0_33 <= w_inst16_p1;
                    r_inst1_33 <= w_inst32_p2;
                    r_inst2_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc6;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // 16 32 32
                7'b0_00_0101,7'b0_00_0111:
                begin
                    r_inst0_33 <= w_inst16_p1;
                    r_inst1_33 <= w_inst32_p2;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b1;
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                //32 16 16
                7'b0_00_1000,7'b0_00_1100:
                begin
                    r_inst0_33 <= w_inst32_p1;
                    r_inst1_33 <= w_inst16_p3;
                    r_inst2_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc4;
                    r_inst2PC_32 <= w_PC_Loc6;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                //32 16 32
                7'b0_00_1001,7'b0_00_1101:
                begin
                    r_inst0_33 <= w_inst32_p1;
                    r_inst1_33 <= w_inst16_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                //32 32
                7'b0_00_1010,7'b0_00_1011,7'b0_00_1110,7'b0_00_1111:
                begin
                    r_inst0_33 <= w_inst32_p1;
                    r_inst1_33 <= w_inst32_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // _32 16 16 16
                7'b1_00_1000,7'b1_00_0000:
                begin
                    r_inst0_33 <= w_inst32_p0;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst16_p3;
                    r_inst3_33 <= w_inst16_p4;
                    r_inst0PC_32 <= w_PC_Loclast;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_inst3PC_32 <= w_PC_Loc6;
                    r_instCont_3 <= 3'd4;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // _32 16 16 32
                7'b1_00_0001,7'b1_00_1001:
                begin
                    r_inst0_33 <= w_inst32_p0;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst16_p3;
                    r_inst0PC_32 <= w_PC_Loclast;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                // _32 16 32
                7'b1_00_1010,7'b1_00_0010,7'b1_00_1011,7'b1_00_0011:
                begin
                    r_inst0_33 <= w_inst32_p0;
                    r_inst1_33 <= w_inst16_p2;
                    r_inst2_33 <= w_inst32_p3;
                    r_inst0PC_32 <= w_PC_Loclast;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // _32 32 16
                7'b1_00_0100,7'b1_00_1100,7'b1_00_0110,7'b1_00_1110:
                begin
                    r_inst0_33 <= w_inst32_p0;
                    r_inst1_33 <= w_inst32_p2;
                    r_inst2_33 <= w_inst16_p4;
                    r_inst0PC_32 <= w_PC_Loclast;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= i_basePC_32+6;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc8;
                end
                // _32 32 32
                7'b1_00_0101,7'b1_00_1101,7'b1_00_0111,7'b1_00_1111:
                begin
                    r_inst0_33 <= w_inst32_p0;
                    r_inst1_33 <= w_inst32_p2;
                    r_inst0PC_32 <= w_PC_Loclast;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                /**
                * start from 01 addr
                */
                // 16 16 16
                7'b0_01_0000,7'b0_01_1000,7'b1_01_0000,7'b1_01_1000:
                begin
                    r_inst0_33 <= w_inst16_p2;
                    r_inst1_33 <= w_inst16_p3;
                    r_inst2_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_inst2PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd3;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                // 16 16 32_
                7'b0_01_0001,7'b0_01_1001,7'b1_01_0001,7'b1_01_1001:
                begin
                    r_inst0_33 <= w_inst16_p2;
                    r_inst1_33 <= w_inst16_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= i_basePC_32 + 4;
                end
                // 16 32
                7'b0_01_0010,7'b0_01_0011,7'b0_01_1010,7'b0_01_1011, 7'b1_01_0010,7'b1_01_0011,7'b1_01_1010,7'b1_01_1011:
                begin
                    r_inst0_33 <= w_inst16_p2;
                    r_inst1_33 <= w_inst32_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                // 32 16
                7'b0_01_0100,7'b0_01_0110,7'b0_01_1100,7'b0_01_1110, 7'b1_01_0100,7'b1_01_0110,7'b1_01_1100,7'b1_01_1110:
                begin
                    r_inst0_33 <= w_inst32_p2;
                    r_inst1_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc4;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc6;
                end
                // 32 32_
                7'b0_01_0101,7'b0_01_0111,7'b0_01_1101,7'b0_01_1111, 7'b1_01_0101,7'b1_01_0111,7'b1_01_1101,7'b1_01_1111:
                begin
                    r_inst0_33 <= w_inst32_p2;
                    r_inst0PC_32 <= i_basePC_32;
                    r_instCont_3 <= 3'd1;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc4;
                end
                /**
                * start from 10 addr
                */
                // 16 32_
                7'b0_10_0001,7'b0_10_0101,7'b0_10_1001,7'b0_10_1101,7'b1_10_0001,7'b1_10_0101,7'b1_10_1001,7'b1_10_1101:
                begin
                    r_inst0_33 <= w_inst16_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_instCont_3 <= 3'd1;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc2;
                end
                // 16 16
                7'b0_10_0000,7'b0_10_0100,7'b0_10_1000,7'b0_10_1100,7'b1_10_0000,7'b1_10_0100,7'b1_10_1000,7'b1_10_1100:
                begin
                    r_inst0_33 <= w_inst16_p3;
                    r_inst1_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_inst1PC_32 <= w_PC_Loc2;
                    r_instCont_3 <= 3'd2;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc4;
                end
                // 32
                7'b0_10_0010,7'b0_10_0011,7'b0_10_0110,7'b0_10_0111,7'b0_10_1010,7'b0_10_1011,7'b0_10_1110,7'b0_10_1111,
                7'b1_10_0010,7'b1_10_0011,7'b1_10_0110,7'b1_10_0111,7'b1_10_1010,7'b1_10_1011,7'b1_10_1110,7'b1_10_1111:
                begin 
                    r_inst0_33 <= w_inst32_p3;
                    r_inst0PC_32 <= i_basePC_32;
                    r_instCont_3 <= 3'd1;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc4;
                end
                /**
                * start from 11
                */
                // 16
                7'b0_11_000_0,7'b0_11_001_0,7'b0_11_010_0,7'b0_11_011_0,7'b0_11_100_0,7'b0_11_101_0,7'b0_11_110_0,7'b0_11_111_0,
                7'b1_11_000_0,7'b1_11_001_0,7'b1_11_010_0,7'b1_11_011_0,7'b1_11_100_0,7'b1_11_101_0,7'b1_11_110_0,7'b1_11_111_0:
                begin 
                    r_inst0_33 <= w_inst16_p4;
                    r_inst0PC_32 <= i_basePC_32;
                    r_instCont_3 <= 3'd1;
                    r_preState   <= 1'b0;
                    r_normNextPc_32 <= w_PC_Loc2;
                end
                // 32_
                7'b0_11_000_1,7'b0_11_001_1,7'b0_11_010_1,7'b0_11_011_1,7'b0_11_100_1,7'b0_11_101_1,7'b0_11_110_1,7'b0_11_111_1,
                7'b1_11_000_1,7'b1_11_001_1,7'b1_11_010_1,7'b1_11_011_1,7'b1_11_100_1,7'b1_11_101_1,7'b1_11_110_1,7'b1_11_111_1:
                begin 
                    r_instCont_3 <= 3'd0;
                    r_preState   <= 1'b1;
                    r_remaining_16 <= i_inst_64[63:48];
                    r_normNextPc_32 <= w_PC_Loc2;
                end
            endcase
        end
    end

    assign o_inst0_33 = r_inst0_33;
    assign o_inst1_33 = r_inst1_33;
    assign o_inst2_33 = r_inst2_33;
    assign o_inst3_33 = r_inst3_33;

    assign o_inst0PC_32 = r_inst0PC_32;
    assign o_inst1PC_32 = r_inst1PC_32;
    assign o_inst2PC_32 = r_inst2PC_32;
    assign o_inst3PC_32 = r_inst3PC_32;
    
    assign o_instCount = r_instCont_3;
    assign o_normNextPc_32 = r_normNextPc_32;



endmodule
