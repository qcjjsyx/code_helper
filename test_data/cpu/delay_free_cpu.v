`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/11/18 10:00:04
// Design Name: dalay1Unit    ->    delay1U
// Module Name: delay1U
// Project Name: 
// Target Devices: FPGA
// Description: 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//只能delay inR outR初始时相同的情况

 (* dont_touch="true" *)module delay_free_cpu #(
    parameter DELAY_UNIT_NUM = 1
 )(
	inR, outR, rst
    );

	(* dont_touch="true" *) input   rst;
	(* dont_touch="true" *) input 	inR;
	(* dont_touch="true" *) output	outR;
 (* dont_touch = "true" *) wire [DELAY_UNIT_NUM+1-1:0] w_link;  //!width=DELAY_UNIT_NUM+1

  genvar i;
  generate
    for (i = 0; i < DELAY_UNIT_NUM; i = i + 1) begin : delay_block
      delay1U u_delay1Unit_donttouch (
          .inR (w_link[i]),
          .outR(w_link[i+1]),
          .rst (rst)
      );
    end
  endgenerate

assign w_link[0] = inR;
assign outR = w_link[DELAY_UNIT_NUM];

endmodule
