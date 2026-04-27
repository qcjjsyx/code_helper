/*
 * @Description: ������������������,������������
 * @Author: liaozz
 * @Date: 2024-08-10 10:33:17
 * @LastEditors: liaozz
 * @LastEditTime: 2024-08-10 10:52:51
 * @Design version: 
 */
module freeSetDelay #(
    parameter DELAY_UNIT_NUM = 15
) (
    input  wire i_signal,
    output wire o_signal,
    input  wire rst
);

  (* dont_touch = "yes" *) wire [DELAY_UNIT_NUM+1-1:0] w_link;  //!width=DELAY_UNIT_NUM+1

  genvar i;
  generate
    for (i = 0; i < DELAY_UNIT_NUM; i = i + 1) begin : delay_block
      delay1U u_delay1Unit (
          .inR (w_link[i]),
          .outR(w_link[i+1]),
          .rst (rst)
      );
    end
  endgenerate

  assign w_link[0]=i_signal;
  assign o_signal=w_link[DELAY_UNIT_NUM];
endmodule  //freeSetDelay

