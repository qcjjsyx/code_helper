/*
 * @Description: 参数化延迟匹配模块,只延迟一根线
 * @Author: liaozz, yyy, sun.yingjie
 * @Date: 2024-08-10 10:33:17
 * @LastEditors: sun.yingjie
 * @LastEditTime: 20254-7-3
 * @Design version: 3.0 将delay更换到电平上
 * delayTime = 134ps + n*59ps under 28nm RVT 0.8V 85c
 */
module freeSetDelay #(
    parameter DELAY_UNIT_NUM = 1 
) (
    input  wire i_pulse,
    output wire o_pulse,
    input  wire rstn
);

  (* dont_touch = "yes" *) wire [DELAY_UNIT_NUM+1-1:0] w_link;  //!width=DELAY_UNIT_NUM+1
  wire req0, req0n, req1, req1d, req1n, trig, outt, temp1;

  genvar i;
  generate
    for (i = 0; i < DELAY_UNIT_NUM; i = i + 1) begin : delay_block
      delay1U u_delay1Unit_donttouch (
          .inR (w_link[i]),
          .outR(w_link[i+1]),
          .rstn (rstn)
      );
    end
  endgenerate

  DRNQV2_140P9T35R ffState0_donttouch (
        .D (req0n),
        .CK(i_pulse),
        .RDN(rstn),
        .Q (req0)
    );
  INV2_140P9T35R invTmp0_donttouch (
      .I(req0),
      .ZN(req0n)
  );

  XOR2V2_140P9T35R neqIn_donttouch (
      .A1(w_link[DELAY_UNIT_NUM]),
      .A2(req1d),
      .Z(outt)
  );

  CLKAND2V3_140P9T35R andDrive_donttouch (
      .A1(outt),
      .A2(rstn),
      .Z(o_pulse)
  );

  DRNQV2_140P9T35R ffState_donttouch (
      .D (req1n),
      .CK(o_pulse),
      .RDN(rstn),
      .Q (req1)
  );

  INV2_140P9T35R invTmp1_donttouch (
      .I(req1),
      .ZN(req1n)
  );
  DEL1V4_140P9T35R delay1_donttouch (
      .I(req1),
      .Z(temp1)
  );
  DEL1V4_140P9T35R delaya2_donttouch (
      .I(temp1),
      .Z(req1d)
  );  

  BUFV2_140P9T35R buf_donttouch ( .I(req0), .Z(w_link[0]) );
endmodule  //freeSetDelay
