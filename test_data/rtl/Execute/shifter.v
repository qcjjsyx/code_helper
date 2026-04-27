`timescale 1ns / 1ps
module shifter (
    oprand,i_shiftNumber_8,i_shiftType_3,i_carryIn_1,i_xtFlag_1,i_notFlag_1,i_shiftOpcode_3,result,o_carryOut_1,rst
);
    input [31:0] oprand;
    output [31:0] result;
    input rst;
    input [2:0] i_shiftType_3;
    input [7:0] i_shiftNumber_8;
    input i_carryIn_1;
    input i_xtFlag_1;
    input i_notFlag_1;
    input [2:0] i_shiftOpcode_3;
    output o_carryOut_1;

//LSL_C
(* dont_touch="true" *)wire [31:0] w_lslResult_32;
(* dont_touch="true" *)wire w_lslCarryOut_1;
assign {w_lslCarryOut_1 , w_lslResult_32} = i_shiftNumber_8 >= 8'd32 ? {1'b0,32'b0} : {oprand[31 - i_shiftNumber_8 + 1] , oprand << i_shiftNumber_8};

//LSR_C
(* dont_touch="true" *)wire [31:0] w_lsrResult_32;
(* dont_touch="true" *)wire w_lsrCarryOut_1;
assign {w_lsrResult_32,w_lsrCarryOut_1} = i_shiftNumber_8 == 8'b0 ? {oprand,1'b0} : {oprand >> i_shiftNumber_8,oprand[i_shiftNumber_8-1]};

//ASR_C
(* dont_touch="true" *)wire [31:0] w_asrResult_32;
(* dont_touch="true" *)wire w_asrCarryOut_1;
assign w_asrCarryOut_1 = i_shiftNumber_8 == 8'b0 ? 1'b0 : (oprand >> ( i_shiftNumber_8 - 1));
assign w_asrResult_32 = oprand[31] == 1'b1 ? ((32'hffff_ffff << (32 - i_shiftNumber_8[4:0])) | (oprand >> i_shiftNumber_8)) : (oprand >> i_shiftNumber_8);


//ROR_C
(* dont_touch="true" *)wire [31:0] w_rorResult_32;
(* dont_touch="true" *)wire w_rorCarryOut_1;
(* dont_touch="true" *)wire [4:0] w_shiftActRorNumber_5;
assign w_shiftActRorNumber_5 = i_shiftNumber_8 % 32;
assign w_rorResult_32 = w_shiftActRorNumber_5 == 5'b0 ? oprand : ((oprand >> w_shiftActRorNumber_5) | (oprand << (32 - w_shiftActRorNumber_5)));
assign w_rorCarryOut_1 = w_rorResult_32[31];

//ROL_C
(* dont_touch="true" *)wire [31:0] w_rolResult_32;
(* dont_touch="true" *)wire w_rolCarryOut_1;
(* dont_touch="true" *)wire [4:0] w_shiftActRolNumber_5;
assign w_shiftActRolNumber_5 = i_shiftNumber_8 % 32;
assign w_rolResult_32 = w_shiftActRolNumber_5 == 5'b0 ? oprand : ((oprand >> w_shiftActRolNumber_5) | (oprand << (32 - w_shiftActRolNumber_5)));
assign w_rolCarryOut_1 = w_rolResult_32[31];

//RRX_C
(* dont_touch="true" *)wire [31:0] w_rrxResult_32;
(* dont_touch="true" *)wire w_rrxCarryOut_1;
assign w_rrxResult_32 = {i_carryIn_1,oprand[31:1]};
assign w_rrxCarryOut_1 = oprand[0];

//初步处理
(* dont_touch="true" *)wire [31:0] w_resultTmp1_32;
assign w_resultTmp1_32 = i_shiftType_3 == 3'b000 ? w_lslResult_32 :
                        (i_shiftType_3 == 3'b001 ? w_lsrResult_32 :
                        (i_shiftType_3 == 3'b010 ? w_asrResult_32 :
                        (i_shiftType_3 == 3'b011 ? w_rorResult_32:
                        (i_shiftType_3 == 3'b100 ? w_rrxResult_32 :
                        (i_shiftType_3 == 3'b101 ? w_rolResult_32 : 
                        32'b0)))));
assign o_carryOut_1 = i_shiftOpcode_3[0] == 1'b0 ? 1'b0 :
                        (i_shiftType_3 == 3'b000 ? w_lslCarryOut_1 :
                        (i_shiftType_3 == 3'b001 ? w_lsrCarryOut_1 :
                        (i_shiftType_3 == 3'b010 ? w_asrCarryOut_1 :
                        (i_shiftType_3 == 3'b011 ? w_rorCarryOut_1 :
                        (i_shiftType_3 == 3'b100 ? w_rrxCarryOut_1:
                        (i_shiftType_3 == 3'b101 ? w_rolCarryOut_1 : 
                        1'b0))))));

//XT处理和NOT处理
(* dont_touch="true" *)wire [31:0] w_resultTmp2_32;
assign w_resultTmp2_32 = i_xtFlag_1 == 1'b0 ? w_resultTmp1_32 : 
                        ((i_shiftOpcode_3[1] == 1'b0) && (i_shiftOpcode_3[2] == 1'b0) ? {{24{1'b0}},w_resultTmp1_32[7:0]}:
                        ((i_shiftOpcode_3[1] == 1'b1) && (i_shiftOpcode_3[2] == 1'b0) ? {{24{w_resultTmp1_32[7]}},w_resultTmp1_32[7:0]}:
                        ((i_shiftOpcode_3[1] == 1'b0) && (i_shiftOpcode_3[2] == 1'b1) ? {{16{1'b0}},w_resultTmp1_32[15:0]}:
                        {{16{w_resultTmp1_32[15]}},w_resultTmp1_32[15:0]})));
assign result = i_notFlag_1 == 1'b1 ? ~w_resultTmp2_32 : w_resultTmp2_32;

endmodule