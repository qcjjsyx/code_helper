//	module name: intAndExc_pop
//	author: xing.yunpeng
//  modifier:
//	version: 1nd version (2024-12-23)
//	description:
//  exc and int 出栈pop
//-----------------------------------------------

`timescale 1ns/1ps

module intAndExc_pop (
    // 事件来自区分是入栈还是出栈
    input i_driveFromTop,
    output o_freeToTop,
    
    // 出栈的初始地址
    input [31:0] i_SP_32,
    
    // 事件去往栈读取数据
    output o_driveToDR,
    output [31:0] o_addrToDR_32, // addr32
    input i_freeFromDR,
    
    // 事件来自DR
    input i_driveFromDR,
    input [63:0] i_DRdata_64,
    output o_freeToDR,
    
    // 写寄存器GRF
    output o_driveToWGRF,
    output [71:0] o_dataToWGRF_72, // addr8_data64
    input i_freeFromWGRF,
    
    // 写寄存器PRF
    output o_driveToWPSR,
    output [31:0] o_dataToWPSR_32, // data32
    input i_freeFromWPSR,
    
    // 去往更改堆栈地址的事件
    output o_driveToSP,
    input i_freeFromSP,
    output [31:0] o_SP_32,

    input rst
);

// wire
wire w_drive0, w_drive1, w_drive2;
wire w_free0, w_free1, w_free2;
wire w_fire0;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
cMutexMerge2_NoData_intAndExc_pop  u0_cMutexMerge2_NoData_intAndExc_pop (
    .i_drive0                ( i_driveFromTop      ),
    .i_drive1                ( w_drive2            ),
    .i_freeNext              ( i_freeFromDR        ),
	.rst                     ( rst                 ),

    .o_free0                 ( o_freeToTop         ),
    .o_free1                 ( w_free2             ),
    .o_driveNext             ( o_driveToDR         )
);

// reg
reg [1:0] r_outNum_2; // 记录循环次数
assign w_fire0 = i_driveFromTop | w_drive2;
always@(posedge w_fire0 or negedge rst) begin
    if(!rst) begin
        r_outNum_2 <= 2'b11;
    end
    else begin
        r_outNum_2 <= r_outNum_2 + 1'b1;
    end
end

// 去往栈的地址
wire [31:0] w_addrToDR0_32;
wire [31:0] w_addrToDR1_32;
wire [31:0] w_addrToDR2_32;
wire [31:0] w_addrToDR3_32;
assign w_addrToDR0_32 = i_SP_32;
assign w_addrToDR1_32 = i_SP_32 + 8;
assign w_addrToDR2_32 = i_SP_32 + 16;
assign w_addrToDR3_32 = i_SP_32 + 24;
assign o_addrToDR_32 =  (r_outNum_2 == 2'b00)?  w_addrToDR0_32:
                        (r_outNum_2 == 2'b01)?  w_addrToDR1_32:
                        (r_outNum_2 == 2'b10)?  w_addrToDR2_32:
                                                w_addrToDR3_32;


// 事件分流
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
cSplitter2_NoData_intAndExc_pop  u0_cSplitter2_NoData_intAndExc_pop (
    .i_drive                 ( i_driveFromDR        ),
    .i_freeNext0             ( w_free0              ),
    .i_freeNext1             ( w_free1              ),
    .rst                     ( rst                  ),

    .o_free                  ( o_freeToDR           ),
    .o_driveNext0            ( w_drive0             ),
    .o_driveNext1            ( w_drive1             )
);


// wire    
wire w_GPvalid_1;
wire [7:0] w_grfAddr_8;

assign w_GPvalid_1 = (r_outNum_2 == 2'b11)? 1'b0 : 1'b1;
// assign w_grfAddr_8 = (r_outNum_2 == 2'b00)? {4'd13, 4'd14}: // R12, LR?
                     // (r_outNum_2 == 2'b01)? {4'd2,  4'd3 }: // R2, R3
                     // (r_outNum_2 == 2'b10)? {4'd0,  4'd1 }: // R0, R1        
                                             // 8'b0;
// 入栈时R0 R1最后入栈；出栈时应为第1个出栈
assign w_grfAddr_8 = (r_outNum_2 == 2'b00)? {4'd0,  4'd1}: // R0, 1?
                     (r_outNum_2 == 2'b01)? {4'd2,  4'd3 }: // R2, R3
                     (r_outNum_2 == 2'b10)? {4'd13, 4'd14 }: // R12, LR
                                             8'b0;
                                             
// 去往写寄存器的择路
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
cSelector2_73b_intAndExc_pop  u0_cSelector2_73b_intAndExc_pop (
    .i_drive                 ( w_drive0          ),
    .i_freeNext0             ( i_freeFromWGRF    ),
    .i_freeNext1             ( i_freeFromWPSR    ),
    .rst                     ( rst               ),
    .i_data_73               ( {w_GPvalid_1, w_grfAddr_8, i_DRdata_64} ),

    .o_free                  ( w_free0           ),
    .o_driveNext0            ( o_driveToWGRF     ),
    .o_driveNext1            ( o_driveToWPSR     ),
    .o_data0_72              ( o_dataToWGRF_72   ),// addr8_data64
    .o_data1_32              ( o_dataToWPSR_32   ) // 使32位为PSR
);

// 去往cMutexMerge的择路
wire w_valid;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
assign w_valid = ~w_GPvalid_1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
cSelector2_1b_intAndExc_pop  u0_cSelector2_1b_intAndExc_pop (
    .i_drive                 ( w_drive1            ),
    .i_freeNext0             ( i_freeFromSP        ),
    .i_freeNext1             ( w_free2             ),
    .rst                     ( rst                 ),
    .i_data                  ( w_valid             ),

    .o_free                  ( w_free1             ),
    .o_driveNext0            ( o_driveToSP         ),
    .o_driveNext1            ( w_drive2            )
);

// 新的SP
assign o_SP_32 = i_SP_32 + 32;

endmodule