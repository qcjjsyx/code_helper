module eventSource ( switch, fire, rstn );
  input switch, rstn;
  output fire;
  wire   reverse_switch, delayed_switch;

  delay1U dealy ( .inR(reverse_switch), .outR(delayed_switch), .rstn(rstn) );
  INV2_140P9T35R qufan ( .I(switch), .ZN(reverse_switch) );
  CLKAND2V1_140P9T35R yumen ( .A1(delayed_switch), .A2(switch), .Z(fire) );
endmodule