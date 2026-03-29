`timescale 1ns / 1ps
//===============================================================================
// Project:        utils
// Module:         eventSource
// version:        1st version (2025-06-03)
// Author:         Haiyi Wang
// Reviser:        Haiyi Wang
// Date:           2025/06/03
// Connect Mail：  whaiyi2024@lzu.edu.cn
// Description:    一个基础的事件源产生模块。输入为电平信号（低电平），检测电平上升沿，根据相位差，产生脉冲信号。
//===============================================================================


(* dont_touch="true" *)module eventSource_cpu (
    /* switch 为输入的电平信号 */
    switch,
    /* fire 为输出的脉冲信号 */
    fire,
    /* rst */
    rst
);

    /* input & output ports */
    (* dont_touch="true" *)input  switch;
    (* dont_touch="true" *)input  rst;
    (* dont_touch="true" *)output fire;

    /* wire and reg */
    wire reverse_switch;
    wire delayed_switch;

    /* 将输入电平取反 */
    assign reverse_switch = ~switch;
    
    /* 将取反后的电平信号经过延时单元 */
    delay4U dealy(.inR(reverse_switch), .outR(delayed_switch), .rst(rst));

    /* 初始输入电平（switch）与取反并经过延时的电平（delayed_switch）经过与门，利用相位差，产生脉冲信号 fire */
    assign fire = switch & delayed_switch;

endmodule

