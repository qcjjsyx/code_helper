`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 10:06:17
// Design Name: 
// Module Name: delay2Unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


(* dont_touch="true" *)module delay4Unit(
    inR, outR, rst
    );
    input inR;
    output outR;
    input rst;
    
    wire outR0;

    (* dont_touch="true" *)delay2Unit delay0(.inR(inR  ), .outR(outR0), .rst(rst));
    (* dont_touch="true" *)delay2Unit delay1(.inR(outR0), .outR(outR ), .rst(rst));
    
endmodule
