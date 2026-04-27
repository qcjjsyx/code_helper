//	module name: nvic
//	author: zhangLongtao
//  modifier:
//	version: 1nd version (2024-07-30)
//	description:
//  exc and int
//
//-----------------------------------------------

`timescale 1ns/1ps

module intAndExc (

    input i_intDriveFromIF,//来自指令预取模块的中断驱�??
    input [37:0] i_intPCAndIntNum_38,
    output o_intFreeToIF,

    input i_excDriveFromIF,//来自指令预取模块的异常驱�??
    input [35:0] i_ifPCAndNum_36,
    output o_excFreeToIf, 

    input i_excDriveFromDec,//来自译码模块的异常驱�??
    input [35:0] i_decPCAndNum_36,
    output o_excFreeToDec,

    input i_excDriveFromExe,//来自执行模块的异常驱�??
    input [35:0] i_exePCAndNum_36,
    output o_excFreeToExe,

    input i_excDriveFromLsu,//来自LSU模块的异常驱�??
    input [35:0] i_lsuPCAndNum_36,
    output o_excFreeToLsu,

    output o_driveToRGRF_1,//GRF和PSR大概是保存现场的寄存器组
    input i_freeFromRGRF_1,

    input i_driveFromRGRF_1,
    input [191:0] i_grfData_192,
    output o_freeToRGRF_1,

    output o_driveToRPSR_1,
    input i_freeFromRPSR_1,

    input i_driveFromRPSR_1,
    input [31:0] i_psrData_32,
    output o_freeToRPSR_1,

    output o_DriveToIf_1,//指令预取部分的反�??
    output [31:0] o_intPC_32,
    input i_freeFromIf_1,

    input i_driveFromWB,//？？WB
    output o_freeToWB,

    output o_driveToDataRoute_1,//数据路由
    output [103:0] o_dataRouteData_104,
    input i_freeFromDataRoute_1,

    input i_driveFromDR_1,//和上面的是一�??
    input [63:0] i_DRdata_64,
    output o_freeToDR_1,

    output o_driveToWGRF_1,//上面的GRF和PSR和这个应该一个是出栈一个是入栈
    output [71:0] o_dataToWGRF_72,
    input i_freeFromWGRF_1,

    output o_driveToWPSR_1,
    output [31:0] o_dataToWPSR_32,
    input i_freeFromWPSR_1,

    output [2:0] o_intAndExc_cnt,//中断嵌套层数
    output o_intIsGo_1,//
    output [5:0] o_intNewType_6,
    input rst
);



wire w_pcDriveToDataRoute_1,w_freeFromWbtopcMerge_1;
(* dont_touch="true" *) wire [5:0] w_intType_6;//6种类型中断的存储
(* dont_touch="true" *) wire [5:0] w_intNewType_6;//屏蔽�??6种类型中�??
(* dont_touch="true" *) reg  [5:0] r_intMask_6;//6种类型中断的屏蔽�??
(* dont_touch="true" *) wire [3:0] w_intNum_4;//中断�??
(* dont_touch="true" *) wire [3:0] w_intNum1_4;
(* dont_touch="true" *) wire [3:0] w_excNum_4;    //选中的中断码   
wire w_inOutDriToDataSpli_1, w_freeFormDataSpli_1, w_inOutDriToOutMer_1, w_freeFromOutMer_1;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask1;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask2;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask3;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask4;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask5;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask6;
(* dont_touch="true" *) reg  [2:0] r_intAndExc_cnt_mask7;
(* dont_touch="true" *) reg  [2:0] r_int_cnt;
(* dont_touch="true" *) reg  [2:0] state;
(* dont_touch="true" *) wire w_drvMask = w_freeFromOutMer_1 | w_pcDriveToDataRoute_1;

parameter NO_MASK = 3'b000;
parameter MASK1   = 3'b001;
parameter MASK2   = 3'b010;
parameter MASK3   = 3'b011;
parameter MASK4   = 3'b100;
parameter MASK5   = 3'b101;
parameter MASK6   = 3'b110;
parameter MASK7   = 3'b111;

always @(posedge w_drvMask or negedge rst)begin
  if(!rst) begin
    r_intAndExc_cnt_mask1 <= 3'b0;
    r_intAndExc_cnt_mask2 <= 3'b0;
    r_intAndExc_cnt_mask3 <= 3'b0;
    r_intAndExc_cnt_mask4 <= 3'b0;
    r_intAndExc_cnt_mask5 <= 3'b0;
    r_intAndExc_cnt_mask6 <= 3'b0;
    r_intAndExc_cnt_mask7 <= 3'b0;
    r_int_cnt <= 3'b0;
    state <= NO_MASK;
    r_intMask_6 <= 6'b111111;
  end
  else begin
    case(state)
      NO_MASK: begin
        if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[1] == 1'b1) begin
          r_intMask_6 <= 6'b000001;
          state <= MASK3;
          r_intAndExc_cnt_mask3 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[2] == 1'b1) begin
          r_intMask_6 <= 6'b000011;
          state <= MASK4;
          r_intAndExc_cnt_mask4 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[3] == 1'b1) begin
          r_intMask_6 <= 6'b000111;
          state <= MASK5;
          r_intAndExc_cnt_mask5 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[4] == 1'b1) begin
          r_intMask_6 <= 6'b001111;
          state <= MASK6;
          r_intAndExc_cnt_mask6 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[5] == 1'b1) begin
          r_intMask_6 <= 6'b011111;
          state <= MASK7;
          r_intAndExc_cnt_mask7 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intAndExc_cnt_mask1 <= 3'b0;
          r_intAndExc_cnt_mask2 <= 3'b0;
          r_intAndExc_cnt_mask3 <= 3'b0;
          r_intAndExc_cnt_mask4 <= 3'b0;
          r_intAndExc_cnt_mask5 <= 3'b0;
          r_intAndExc_cnt_mask6 <= 3'b0;
          r_intAndExc_cnt_mask7 <= 3'b0;
          r_intMask_6 <= 6'b111111;
          state <= NO_MASK;
          r_int_cnt <= 3'b0;
        end
      end

      MASK1: begin//(exc)
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask1) begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask2: begin
                r_intMask_6 <= 6'b000000;
                state <= MASK2;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask3: begin
                r_intMask_6 <= 6'b000001;
                state <= MASK3;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask4: begin
                r_intMask_6 <= 6'b000011;
                state <= MASK4;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask5: begin
                r_intMask_6 <= 6'b000111;
                state <= MASK5;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask6: begin
                r_intMask_6 <= 6'b001111;
                state <= MASK6;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin
                r_intMask_6 <= r_intMask_6;
                state <= MASK1;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK1;
          r_int_cnt <= r_int_cnt;
        end
      end
      
      MASK2: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask2)begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask3: begin
                r_intMask_6 <= 6'b000001;
                state <= MASK3;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask4: begin
                r_intMask_6 <= 6'b000011;
                state <= MASK4;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask5: begin
                r_intMask_6 <= 6'b000111;
                state <= MASK5;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask6: begin
                r_intMask_6 <= 6'b001111;
                state <= MASK6;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin//逻辑上进不来这儿
                r_intMask_6 <= r_intMask_6;
                state <= MASK2;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK2;
          r_int_cnt <= r_int_cnt;
        end
      end

      MASK3: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask3)begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask4: begin
                r_intMask_6 <= 6'b000011;
                state <= MASK4;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask5: begin
                r_intMask_6 <= 6'b000111;
                state <= MASK5;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask6: begin
                r_intMask_6 <= 6'b001111;
                state <= MASK6;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin//逻辑上进不来这个default
                r_intMask_6 <= r_intMask_6;
                state <= MASK3;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK3;
          r_int_cnt <= r_int_cnt;
        end
      end

      MASK4: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask4)begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask5: begin
                r_intMask_6 <= 6'b000111;
                state <= MASK5;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask6: begin
                r_intMask_6 <= 6'b001111;
                state <= MASK6;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin//逻辑上进不来这个default
                r_intMask_6 <= r_intMask_6;
                state <= MASK4;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[1] == 1'b1) begin 
          r_intMask_6 <= 6'b000001;
          state <= MASK3;
          r_intAndExc_cnt_mask3 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK4;
          r_int_cnt <= r_int_cnt;
        end
      end

      MASK5: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask5)begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask6: begin
                r_intMask_6 <= 6'b001111;
                state <= MASK6;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin//逻辑上进不来这个default
                r_intMask_6 <= r_intMask_6;
                state <= MASK5;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[1] == 1'b1) begin 
          r_intMask_6 <= 6'b000001;
          state <= MASK3;
          r_intAndExc_cnt_mask3 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[2] == 1'b1) begin 
          r_intMask_6 <= 6'b000011;
          state <= MASK4;
          r_intAndExc_cnt_mask4 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK5;
          r_int_cnt <= r_int_cnt;
        end
      end

      MASK6: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask6)begin
          if(r_int_cnt == 3'b1) begin
            r_intMask_6 <= 6'b111111;
            state <= NO_MASK;
            r_int_cnt <= 3'b0;
          end
          else begin
            case (r_intAndExc_cnt - 3'b1)
              r_intAndExc_cnt_mask7: begin
                r_intMask_6 <= 6'b011111;
                state <= MASK7;
                r_int_cnt <= r_int_cnt - 3'b1;
              end
              default: begin//逻辑上进不来这个default
                r_intMask_6 <= r_intMask_6;
                state <= MASK6;
                r_int_cnt <= r_int_cnt;
              end
            endcase
          end
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[1] == 1'b1) begin 
          r_intMask_6 <= 6'b000001;
          state <= MASK3;
          r_intAndExc_cnt_mask3 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[2] == 1'b1) begin 
          r_intMask_6 <= 6'b000011;
          state <= MASK4;
          r_intAndExc_cnt_mask4 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[3] == 1'b1) begin 
          r_intMask_6 <= 6'b000111;
          state <= MASK5;
          r_intAndExc_cnt_mask5 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK6;
          r_int_cnt <= r_int_cnt;
        end
      end

      MASK7: begin
        if(r_intAndExc_cnt == r_intAndExc_cnt_mask7)begin
          r_intMask_6 <= 6'b111111;
          state <= NO_MASK;
          r_int_cnt <= 3'b0;
        end
        else if(w_excNum_4[3:2] == 2'b01) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK1;
          r_intAndExc_cnt_mask1 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[0] == 1'b1) begin 
          r_intMask_6 <= 6'b000000;
          state <= MASK2;
          r_intAndExc_cnt_mask2 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[1] == 1'b1) begin 
          r_intMask_6 <= 6'b000001;
          state <= MASK3;
          r_intAndExc_cnt_mask3 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[2] == 1'b1) begin 
          r_intMask_6 <= 6'b000011;
          state <= MASK4;
          r_intAndExc_cnt_mask4 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[3] == 1'b1) begin 
          r_intMask_6 <= 6'b000111;
          state <= MASK5;
          r_intAndExc_cnt_mask5 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else if(w_intNewType_6[4] == 1'b1) begin 
          r_intMask_6 <= 6'b001111;
          state <= MASK6;
          r_intAndExc_cnt_mask6 <= r_intAndExc_cnt;
          r_int_cnt <= r_int_cnt + 3'b1;
        end
        else begin
          r_intMask_6 <= r_intMask_6;
          state <= MASK7;
          r_int_cnt <= r_int_cnt;
        end
      end

      default: begin
        r_intAndExc_cnt_mask1 <= 3'b0;
        r_intAndExc_cnt_mask2 <= 3'b0;
        r_intAndExc_cnt_mask3 <= 3'b0;
        r_intAndExc_cnt_mask4 <= 3'b0;
        r_intAndExc_cnt_mask5 <= 3'b0;
        r_intAndExc_cnt_mask6 <= 3'b0;
        r_intAndExc_cnt_mask7 <= 3'b0;
        r_int_cnt <= 3'b0;
        state <= NO_MASK;
        r_intMask_6 <= 6'b111111;
      end
    endcase
  end
end
assign w_intNewType_6 = r_intMask_6 & w_intType_6;
assign o_intNewType_6 = w_intNewType_6;
//(* dont_touch="true" *) reg [3:0] r_intNum_4;//和w_intNum_4配对

(* dont_touch="true" *) wire [31:0] w_intPC_32;//初始中断数据�??32位是中断指令，码
(* dont_touch="true" *) wire [31:0] w_ifPC_32;
(* dont_touch="true" *) wire [31:0] w_decPC_32;
(* dont_touch="true" *) wire [31:0] w_exePC_32;
(* dont_touch="true" *) wire [31:0] w_lsuPC_32;

(* dont_touch="true" *) wire [31:0] w_intPC1_32;//走完中断判定分支后的中断数据�??32位可能是中断程序地址
(* dont_touch="true" *) wire [31:0] w_ifPC1_32;
(* dont_touch="true" *) wire [31:0] w_decPC1_32;
(* dont_touch="true" *) wire [31:0] w_exePC1_32;
(* dont_touch="true" *) wire [31:0] w_lsuPC1_32;

(* dont_touch="true" *) wire [3:0] w_ifExcNum_4;//初始中断�??
(* dont_touch="true" *) wire [3:0] w_decExcNum_4;
(* dont_touch="true" *) wire [3:0] w_exeExcNum_4;
(* dont_touch="true" *) wire [3:0] w_lsuExcNum_4;

(* dont_touch="true" *) wire [3:0] w_ifExc1Num_4;//走完中断判定分支后的中断�??
(* dont_touch="true" *) wire [3:0] w_decExc1Num_4;
(* dont_touch="true" *) wire [3:0] w_exeExc1Num_4;
(* dont_touch="true" *) wire [3:0] w_lsuExc1Num_4;

(* dont_touch="true" *) wire [19:0] w_allExcNum_20;//初始中断码合�??
(* dont_touch="true" *) wire [159:0] w_allPC_160;//初始中断数据合集�??32位可能是中断程序地址
(* dont_touch="true" *) wire [159:0] w_allPC1_160;//走完中断判定分支后的中断数据合集�??32位可能是中断程序地址
(* dont_touch="true" *) wire w_SRDrive_1, w_freeSR_1;
(* dont_touch="true" *) wire w_intSeleFree_1, w_intSeleDrive_1, w_freeFromPreStackSpli;

assign {w_intPC_32,w_intType_6} = i_intPCAndIntNum_38;
assign {w_ifPC_32,w_ifExcNum_4} = i_ifPCAndNum_36; // 0100//异常�?? 4/5/6/7
assign {w_decPC_32,w_decExcNum_4} = i_decPCAndNum_36; // 0101
assign {w_exePC_32,w_exeExcNum_4} = i_exePCAndNum_36; // 0110
assign {w_lsuPC_32,w_lsuExcNum_4} = i_lsuPCAndNum_36; // 0111

assign w_intNum_4 = (w_intNewType_6[0] == 1'b1) ? 4'b1000 :
                    (w_intNewType_6[1] == 1'b1) ? 4'b1001 :
                    (w_intNewType_6[2] == 1'b1) ? 4'b1010 :
                    (w_intNewType_6[3] == 1'b1) ? 4'b1011 :
                    (w_intNewType_6[4] == 1'b1) ? 4'b1100 :
                    (w_intNewType_6[5] == 1'b1) ? 4'b1101 : 4'b1111;
contTap firstTap(
.trig(w_intSeleDrive_1 | w_SRDrive_1),
.req(o_intIsGo_1),
.rst(rst)
);
//w_cmpMerDrive_1是后端比较中断模块的驱动，w_intAndExeSeleFree_1是后端比较中断模块的反馈，w_intAndExeSeleDriveToMe是后端中断比较模块的向下输出，（下级还没找到
(* dont_touch="true" *) wire w_cmpMerDrive_1, w_intAndExeSeleFree_1, w_intAndExeSeleDriveToMe;
//汇聚所有中断异常后组合成一路数据输出，将五种中断异常码汇聚成一路数据，标志有中断事件发生，供后续模块进行判定到底何种中断异常发�??
//1/10 zwm change w_intAndExeSeleFree_1 to w_intAndExeSeleDriveToMe | o_DriveToIf_1
//1/13 zwm add a always
reg [3:0] r_intNum_4;
reg [31:0] r_intPC_32;
always @(posedge i_intDriveFromIF or negedge rst) begin
  if(!rst)begin
    r_intNum_4 <=4'b0;
    r_intPC_32 <=32'b0;
  end else begin
    r_intNum_4 <= w_intNum_4;
    r_intPC_32 <= w_intPC_32;
  end
end
(* dont_touch="true" *) cWaitMerge5_180b_int cmpMerge(.i_drive0(i_intDriveFromIF), .i_data0_36({w_intNum_4,w_decPC_32}), .o_free0(o_intFreeToIF),
                         .i_drive1(i_excDriveFromIF), .i_data1_36({w_ifExcNum_4,w_decPC_32}), .o_free1(o_excFreeToIf),
                         .i_drive2(i_excDriveFromDec), .i_data2_36({w_decExcNum_4,w_decPC_32}), .o_free2(o_excFreeToDec),
                         .i_drive3(i_excDriveFromExe), .i_data3_36({w_exeExcNum_4,w_exePC_32}), .o_free3(o_excFreeToExe),
                         .i_drive4(i_excDriveFromLsu), .i_data4_36({w_lsuExcNum_4,w_lsuPC_32}), .o_free4(o_excFreeToLsu),
                         .o_driveNext(w_cmpMerDrive_1), .o_data_180({w_allExcNum_20, w_allPC_160}), .i_freeNext(w_intAndExeSeleDriveToMe | o_DriveToIf_1),
                         .rst(rst));

(* dont_touch="true" *) wire w_intAndExeValid_1;//中断异常标志，高有效，表明发生了中断异常
// 全为1代表没有中断异常
//w_intNum_4信号有代码写1111标志正常，另外四个中断码来自输入，输入端保证在无中断时全一？有中断时为相应的中断码
assign w_intAndExeValid_1 = (w_allExcNum_20 != 20'hf_ffff);
wire w_cmpMerDrive1_1;
(* dont_touch="true" *) delay2U Delay0(.inR(w_intAndExeSeleDriveToMe), .outR(w_intSeleFree_1), .rst(rst)); //无中断分支的终点，直接反馈i_free，到此为歀�??
(* dont_touch="true" *) delay6U Delay3(.inR(w_cmpMerDrive_1), .outR(w_cmpMerDrive1_1), .rst(rst)); //无中断分支的终点，直接反馈i_free，到此为歀�??
// 先测试用 无中断异分支
//择路，选择无中断异常的分支（我猜是根据（i_data_181({1'b0, w_allExcNum_20, w_allPC_160})这一段里面的数据最高有效位决定了有无中断异常，正常来说这个数据位应该是w_intAndExeValid_1信号驱动
(* dont_touch="true" *) cSelector2_181b_int intAndExeSele(.i_drive(w_cmpMerDrive1_1), .i_data_181({w_intAndExeValid_1, w_allExcNum_20, w_allPC_160}), .o_free(w_intAndExeSeleFree_1),
                         .o_driveNext0(w_intSeleDrive_1), .o_data0_180({{w_intNum1_4,w_ifExc1Num_4,w_decExc1Num_4,w_exeExc1Num_4,w_lsuExc1Num_4}, w_allPC1_160}), .i_freeNext0(w_SRDrive_1),//有中断分�??
                         .o_driveNext1(w_intAndExeSeleDriveToMe), .o_data1_180(), .i_freeNext1(w_intSeleFree_1),//无中断分�??
                         .rst(rst));
//再取一遍中断码，应该是根据有无中断决定中断码向下传递的数据

assign {w_intPC1_32,
        w_ifPC1_32,
        w_decPC1_32, 
        w_exePC1_32, 
        w_lsuPC1_32} = w_allPC1_160;
 
(* dont_touch="true" *) wire [31:0] w_pc_32;        //选中的中断数�??
(* dont_touch="true" *) wire [31:0] w_exeAddr_32;//中断�??*4
(* dont_touch="true" *) wire [31:0] w_vecAddr_32;//中断向量（就是中断码*4
(* dont_touch="true" *) wire [31:0] w_SP_32;


reg [3:0] r_excNum_4;//与w_excNum_4配套使用

//优先级判定，由高至低分别为：指令预取异常、译码异常、执行异常、LSU异常、中�??
wire w_intSeleDriveBuf_1;
(* dont_touch="true" *) delay4U Delay1(.inR(w_intSeleDrive_1), .outR(w_intSeleDriveBuf_1), .rst(rst)); //无中断分支的终点，直接反馈i_free，到此为歀�??
// always @(posedge w_intSeleDriveBuf_1 or negedge rst) begin
//     if(!rst) r_excNum_4 = 4'b1111;
//     else if (w_ifExc1Num_4 != 4'hf) r_excNum_4 = w_ifExc1Num_4;//中断�?? 8/9/10/11/12
//     else if (w_lsuExc1Num_4 != 4'hf) r_excNum_4 = w_lsuExc1Num_4;
//     else if (w_exeExc1Num_4 != 4'hf) r_excNum_4 = w_exeExc1Num_4;
//     else if (w_decExc1Num_4 != 4'hf) r_excNum_4 = w_decExc1Num_4;
//     else r_excNum_4 = w_intNum1_4;
// end

assign w_excNum_4 = (w_lsuExc1Num_4 != 4'hf) ? w_lsuExc1Num_4:
                    (w_exeExc1Num_4 != 4'hf) ? w_exeExc1Num_4:
                    (w_decExc1Num_4 != 4'hf) ? w_decExc1Num_4:
                    (w_ifExc1Num_4 != 4'hf) ? w_ifExc1Num_4:
                    (w_intNum1_4 != 4'hf) ? w_intNum1_4: 4'b1111;

assign w_pc_32 = w_excNum_4 == w_intNum1_4 ? w_intPC1_32 : //根据优先级判定结果选择带哪个中断下�??
                 w_excNum_4 == w_ifExc1Num_4 ? w_ifPC1_32 : 
                 w_excNum_4 == w_decExc1Num_4 ? w_decPC1_32 :
                 w_excNum_4 == w_exeExc1Num_4 ? w_exePC1_32 : w_lsuPC1_32;

assign w_exeAddr_32 = w_excNum_4 * 4; // 需要修改地址-->如果是异常返回需要变成从原来的栈中拿PC，访问Sarm的地址需要变
assign w_vecAddr_32 = (w_excNum_4 == 4'b0010) ? (w_SP_32 + 24) : w_exeAddr_32;

(* dont_touch="true" *) reg [31:0] r_stackPoint_32;

wire w_preSSpliDriToWbMer_1, w_preFreeFromWbMer_1, w_vecSpliDriToWbMer_1, w_vecSpliFreeFromWbMer_1;
wire w_WbMerDriToInOut_1, w_freeFromInOut_1, w_vecDriveToDataRoute_1, w_freeFromDataRouteMer_1;
wire w_intSeleDrive1_1;
wire w_DRSeleDriTovec_1, w_freeFromDRSele_1;
wire [63:0] w_pcAndPsr_64;
wire w_outMerDriToDR_1,w_freeFromDRMer_1;
(* dont_touch="true" *) delay8U preDelay0(.inR(w_intSeleDrive_1), .outR(w_intSeleDrive1_1), .rst(rst));  
wire [31:0] w_pcToif_32;
assign w_pcToif_32 = (w_excNum_4 == 4'b0010) ? w_pcAndPsr_64[63:32] : 
                     (w_excNum_4 == 4'b0111) ? 32'h0000_1224 : 
                     (w_excNum_4 == 4'b0101) ? 32'h0000_1220 : 
                     (w_excNum_4 == 4'b0100) ? 32'h0000_121c : 
                     (w_excNum_4 == 4'b1000) ? 32'h0000_1204 : 
                     (w_excNum_4 == 4'b1001) ? 32'h0000_1208 : 
                     (w_excNum_4 == 4'b1010) ? 32'h0000_120c : 
                     (w_excNum_4 == 4'b1011) ? 32'h0000_1214 : 
                     (w_excNum_4 == 4'b1100) ? 32'h0000_1210 : 
                     (w_excNum_4 == 4'b1101) ? 32'h0000_1218 : 32'h0000_1200;
//输入驱动为有中断分支的下级驱动，所以应该是有中断分支的流程
//分流，一走多模块，为什么没有输入数据，因为没有中断需要处理？
//只是一个复制驱动的模块，所以不用带数据
//感觉像是走存栈的流程
(* dont_touch="true" *) cSplitter2_1b preStackSpli(.i_drive(w_intSeleDrive1_1), .i_data_1(), .o_free(w_freeFromPreStackSpli),
                        .o_driveNext0(w_preSSpliDriToWbMer_1), .i_freeNext0(w_preFreeFromWbMer_1), .o_data0_1(),
                        .o_driveNext1(w_vecDriveToDataRoute_1), .i_freeNext1(w_freeFromDataRouteMer_1), .o_data1_1(),
                        .rst(rst));                        

(* dont_touch="true" *) cSplitter2_32b_int vectorSpli(.i_drive(w_DRSeleDriTovec_1), .i_data_32(w_pcToif_32), .o_free(w_freeFromDRSele_1),
                        .o_driveNext0(w_vecSpliDriToWbMer_1), .i_freeNext0(w_vecSpliFreeFromWbMer_1), .o_data0_32(),
                        .o_driveNext1(o_DriveToIf_1), .i_freeNext1(i_freeFromIf_1), .o_data1_32(o_intPC_32),
                        .rst(rst));

(* dont_touch="true" *) cWaitMerge3_1b WbMerge(.i_drive0(i_driveFromWB), .i_data0_1(), .o_free0(o_freeToWB),
                        .i_drive1(w_preSSpliDriToWbMer_1), .i_data1_1(), .o_free1(w_preFreeFromWbMer_1),
                        .i_drive2(w_vecSpliDriToWbMer_1), .i_data2_1(), .o_free2(w_vecSpliFreeFromWbMer_1),
                        .o_driveNext(w_WbMerDriToInOut_1), .o_data_1(), .i_freeNext(w_freeFromInOut_1),
                        .rst(rst)); // 等待所有的正常指令结束  
                        
wire w_en_DRValid;
wire [1:0] w_DRValid_2;//取值为10/01/01入栈/10出栈/00取PC指令
reg [1:0] r_DRValid_2;

assign w_en_DRValid = w_vecSpliDriToWbMer_1 | w_SRDrive_1;
//出入栈选择
always@(posedge w_en_DRValid or negedge rst) // 初始化为00去找PC，然后看是出栈还是入栈来修改valid
begin
    if(!rst) begin 
      r_DRValid_2 = 2'b0;
    end
  else begin
      if(w_SRDrive_1) begin
        r_DRValid_2 = 2'b0;
      end
      else if (w_excNum_4 == 4'b0010) begin
        r_DRValid_2 = 2'b10;        
      end else begin
        r_DRValid_2 = 2'b01;        
      end
    end
end

assign w_DRValid_2 = r_DRValid_2;
wire w_DRSeleDriToinStackSele_1, w_freeFrominStackSele_1;
wire w_inStackDriToDR_1, w_freeFormDR_1, w_inStackDri_1;
wire [95:0] w_inData_96;
wire [31:0] w_addrToDR_32;

//选择SP地址
(* dont_touch="true" *)reg [31:0] r_SP_32;
(* dont_touch="true" *)wire [31:0] w_i_SP_inStack_32;
(* dont_touch="true" *)wire [31:0] w_i_SP_outStack_32;
(* dont_touch="true" *)wire [31:0] w_o_SP_inStack_32;
(* dont_touch="true" *)wire [31:0] w_o_SP_outStack_32;
(* dont_touch="true" *)wire [31:0] w_o_SP_32;
(* dont_touch="true" *)wire [31:0] w_inData3Addr_32;
(* dont_touch="true" *)wire [31:0] w_NAddr_32 = 32'h0002_1600;


  always@(posedge w_SRDrive_1 or negedge rst)
  begin
      if(!rst) begin 
        r_SP_32 <= w_NAddr_32;//未定义地址，w_NAddr_32没有赋值语句？？？
      end
    else begin
         r_SP_32 <= w_o_SP_32;//入栈指令的初始栈地址？？
      end
  end

  assign w_SP_32 = r_SP_32;

  (* dont_touch="true" *)wire w_inOutDri = w_inOutDriToDataSpli_1 | w_inOutDriToOutMer_1;

always@(posedge w_inOutDri or negedge rst)
begin
  if(!rst) r_intAndExc_cnt = 0;
  else if(w_excNum_4 == 4'b1111) r_intAndExc_cnt = r_intAndExc_cnt;
  else if(w_excNum_4 == 4'b0010) r_intAndExc_cnt = r_intAndExc_cnt - 1;
  else r_intAndExc_cnt = r_intAndExc_cnt + 1;
end

assign o_intAndExc_cnt = r_intAndExc_cnt;
//w_inStackFree_1, w_inStackSeleToMe_1;
//preStackSpli模块、vectorSpli模块、WB都准备好了就走这一步。根据w_DRValid_2决定是出栈还是入栈（01入栈/10出栈）�?
(* dont_touch="true" *) cSelector2_34b_int inOutSele(.i_drive(w_WbMerDriToInOut_1), .i_data_34({w_DRValid_2,w_SP_32}), .o_free(w_freeFromInOut_1),
                        .o_driveNext0(w_inOutDriToDataSpli_1), .i_freeNext0(w_freeFormDataSpli_1), .o_data0_32(w_i_SP_inStack_32),//入栈
                        .o_driveNext1(w_inOutDriToOutMer_1), .i_freeNext1(w_freeFromOutMer_1), .o_data1_32(w_i_SP_outStack_32),//出栈
                        .rst(rst)); // 区分出栈和入栈，带SP

(* dont_touch="true" *) cWaitMerge2_1b WbtopcMerge(.i_drive0(i_driveFromWB), .i_data0_1(), .o_free0(),
.i_drive1(w_vecDriveToDataRoute_1), .i_data1_1(), .o_free1(w_freeFromDataRouteMer_1),
.o_driveNext(w_pcDriveToDataRoute_1), .o_data_1(), .i_freeNext(w_freeFromWbtopcMerge_1),
.rst(rst)); // 等待所有的正常指令结束 
// 中断异常去DR一共有三路
//带的数据有啥用？
(* dont_touch="true" *) cMutexMerge3_104b_int dataRoteMerge(.i_drive0(w_pcDriveToDataRoute_1), .i_data0_104({72'b0, w_vecAddr_32}), .o_free0(w_freeFromWbtopcMerge_1),
                        .i_drive1(w_inStackDriToDR_1), .i_data1_104({8'b1111_1111, w_inData_96}), .o_free1(w_freeFormDR_1),
                        .i_drive2(w_outMerDriToDR_1), .i_data2_104({8'b0000_0000, 64'b0, w_addrToDR_32}), .o_free2(w_freeFromDRMer_1),
                        .i_freeNext(i_freeFromDataRoute_1), .o_driveNext(o_driveToDataRoute_1), .o_data_104(o_dataRouteData_104),
                        .rst(rst));
 wire w_DRSeleDriToWbSpli_1, w_freeFromWbSpli_1;
 wire [63:0] w_DRdata_64;
// wire [3:0] w_grfAddrH_4, w_grfAddrL_4;
(* dont_touch="true" *) cSelector3_66b_int DRSelector (.i_drive(i_driveFromDR_1), .i_data_66({w_DRValid_2, i_DRdata_64}), .o_free(o_freeToDR_1),
                        .o_driveNext0(w_DRSeleDriTovec_1), .i_freeNext0(w_freeFromDRSele_1), .o_data0_64(w_pcAndPsr_64),
                        .o_driveNext1(w_DRSeleDriToinStackSele_1), .i_freeNext1(w_freeFrominStackSele_1), .o_data1_64(), //入栈不需要返回数�??
                        .o_driveNext2(w_DRSeleDriToWbSpli_1), .i_freeNext2(w_freeFromWbSpli_1), .o_data2_64(w_DRdata_64),//出栈
                        .rst(rst)); // 修改条件
//SP选择
(* dont_touch="true" *)wire w_driveFrominStackSP;
(* dont_touch="true" *)wire w_driveFromoutStackSP;
(* dont_touch="true" *)wire w_freeToinStackSP;
(* dont_touch="true" *)wire w_freeTooutStackSP;
(* dont_touch="true" *) delay8U SRDelay0(.inR(w_SRDrive_1), .outR(w_freeSR_1), .rst(rst)); //延时打拍
(* dont_touch="true" *) cMutexMerge2_32b_int SRMerge(
                        .i_drive0(w_driveFrominStackSP), .i_data0_32(w_o_SP_inStack_32), .o_free0(w_freeToinStackSP),//驱动来自入栈
                        .i_drive1(w_driveFromoutStackSP), .i_data1_32(w_o_SP_outStack_32), .o_free1(w_freeTooutStackSP),//驱动来自出栈
                        .i_freeNext(w_freeSR_1), .o_driveNext(w_SRDrive_1), .o_data_32(w_o_SP_32),//更新SP
                        .rst(rst));
 // 出栈              
intAndExc_pop  u_outStack (
    .i_driveFromTop          ( w_inOutDriToOutMer_1   ),
    .i_SP_32                 ( w_i_SP_outStack_32      ),
    .i_freeFromDR            ( w_freeFromDRMer_1      ),
    .i_driveFromDR           ( w_DRSeleDriToWbSpli_1     ),
    .i_DRdata_64             ( w_DRdata_64       ),
    .i_freeFromWGRF          ( i_freeFromWGRF_1    ),
    .i_freeFromWPSR          ( i_freeFromWPSR_1    ),
    .i_freeFromSP            ( w_freeTooutStackSP      ),
    .rst                     ( rst               ),

    .o_freeToTop             ( w_freeFromOutMer_1       ),

    .o_driveToDR             ( w_outMerDriToDR_1       ),
    .o_addrToDR_32           ( w_addrToDR_32     ),//
    .o_freeToDR              ( w_freeFromWbSpli_1        ),
    .o_driveToWGRF           ( o_driveToWGRF_1     ),
    .o_dataToWGRF_72         ( o_dataToWGRF_72   ),
    .o_driveToWPSR           ( o_driveToWPSR_1     ),
    .o_dataToWPSR_32         ( o_dataToWPSR_32   ),
    .o_driveToSP             ( w_driveFromoutStackSP       ),
    .o_SP_32                 ( w_o_SP_outStack_32           )
);

 // 入栈
//去DR的数据和来自DR的数�??
 inStack u_inStack(
    .i_inOutDriToDataSpli_1(w_inOutDriToDataSpli_1),
    .rst(rst),
    .i_freeFromRGRF_1(i_freeFromRGRF_1),
    .i_freeFromRPSR_1(i_freeFromRPSR_1),
    .i_driveFromRGRF_1(i_driveFromRGRF_1),
    .i_driveFromRPSR_1(i_driveFromRPSR_1),
    
    .i_grfData_192(i_grfData_192),
    .i_psrData_32(i_psrData_32),
    .i_DRSeleDriToinStackSele_1(w_DRSeleDriToinStackSele_1),//lian jie dao sram na ge mo kuai yin chu lai de xian
    .i_freeFromDR_1(w_freeFormDR_1),
    .i_SP_32(w_i_SP_inStack_32),
    .i_freeFromSPDec(w_freeToinStackSP),
    .i_pc_32(w_pc_32),

    .o_w_inStackDriToDR_1(w_inStackDriToDR_1),
    .o_freeFrominStackSele_1(w_freeFrominStackSele_1),
    .o_SP_32(w_o_SP_inStack_32),
    .o_driveFromSPDec(w_driveFrominStackSP),
    .o_data_96               ( w_inData_96),

    .o_freeFromInStack(w_freeFormDataSpli_1),
    .o_freeToRGRF_1(o_freeToRGRF_1),
    .o_freeToRPSR_1(o_freeToRPSR_1),
    .o_driveToRGRF_1(o_driveToRGRF_1),
    .o_driveToRPSR_1(o_driveToRPSR_1)
    
);
 endmodule
