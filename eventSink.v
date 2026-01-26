`timescale 1ns / 1ps
//===============================================================================
// Project:        utils
// Module:         eventSink
// version:        1st version (2025-06-03)
// Author:         Haiyi Wang
// Reviser:        Haiyi Wang
// Date:           2025/06/03
// Connect Mail：  whaiyi2024@lzu.edu.cn
// Description:    一个基础的事件阱处理生模块。输入为脉冲信号（低电平），输出也为脉冲信号。
//===============================================================================


module eventSink (
    /* i_drive 为输入脉冲 */
    i_drive,
    /* o_free 为输出脉冲 */
    o_free,
    /* rstn */
    rstn
);

    /* input & output ports */
    input  i_drive;
    output o_free;
    input  rstn;
    /* 将 i_drive 稍微延迟，输出为 o_free*/
    delay1U delay(.inR(i_drive), .outR(o_free), .rstn(rstn));

endmodule