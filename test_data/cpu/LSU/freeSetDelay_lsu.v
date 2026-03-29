//-----------------------------------------------
//	module name: freeSetDelay_lsu
//	author: sun.yingjie (syingjie2025@lzu.edu.cn)
//	version: 1st version (2025-12-16)
//	description: 
//		Parameterized delay unit triggered by the rising edge of the input,
//      generating a pulse output.
//  tech: xilinx fpga
//  modify: sun.yingjie: 
//----------------------------------------------
`timescale 1ns / 1ps

module freeSetDelay_lsu #(
    parameter integer DELAY_NUM   = 4,
    parameter integer DELAY_WIDTH = 8
)(
    (* dont_touch="true" *)input  wire inR,
    (* dont_touch="true" *)input  wire rst,
    (* dont_touch="true" *)output wire outR
);
    (* dont_touch="true" *)wire [  DELAY_NUM:0] w_linkNum   ;
    (* dont_touch="true" *)wire [DELAY_WIDTH:0] w_linkWidth ;

    (* dont_touch="true" *)contTap u_conTap_in(
        .trig   (inR            ),
        .req    (w_linkNum[0]   ),
        .rst    (rst            )
    );
    genvar i;
    generate
        for(i=0;i<DELAY_NUM;i=i+1)begin:genDelayNum
            (* dont_touch="true" *)delay1U u_delay1U_genNum(
                .inR (w_linkNum[i]  ),
                .outR(w_linkNum[i+1]),
                .rst (rst           )
            );
        end
    endgenerate
    (* dont_touch="true" *)contTap u_conTap_out(
        .trig   (outR           ),
        .req    (w_linkWidth[0] ),
        .rst    (rst            )
    );
    genvar j;
    generate
        for(j=0;j<DELAY_WIDTH;j=j+1)begin:genDelayWidth
            (* dont_touch="true" *)delay1U u_delay1U_genWidth(
                .rst (rst               ),
                .inR (w_linkWidth[j]    ),
                .outR(w_linkWidth[j+1]  )
            );
        end
    endgenerate
    assign outR = (w_linkNum[DELAY_NUM] ^ w_linkWidth[DELAY_WIDTH]) & rst;
endmodule
