/*=============================================================
Project:ARMCPU
Module:cFifo1_1b
Author:zlt
Mail:zlt22@lzu.edu.cn
Date:2024/xx/xx
Description:cFifo1 of launch
==============================================================*/
`timescale 1ns / 1ps

module cFifo1_1b_launch(
i_drive, i_data_1, o_free,rst,
o_driveNext, o_data_1, i_freeNext
);

input i_drive, i_freeNext, rst;
input i_data_1;
output o_free, o_driveNext;
output o_data_1;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [31:0] r_data_1;


always @(posedge i_drive or negedge rst) begin
	if (!rst) begin
		r_data_1 = 1'b0;
	end else begin
		r_data_1 = i_data_1;
	end
end

assign o_data_1 = r_data_1;

// delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext));
// delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext));

assign o_driveNext = i_drive;
assign o_free = i_freeNext;

endmodule

