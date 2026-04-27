
`timescale 1ns / 1ps

module cFifo1_12_24b(
i_drive, i_data_12, o_free,rst,
o_driveNext, o_data_24, i_freeNext
);

input i_drive, i_freeNext, rst;
input [11:0] i_data_12;
output o_free, o_driveNext;
output [23:0] o_data_24;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [3:0] r_preRd1Addr_4;
reg [3:0] r_preRd2Addr_4;

reg [7:0] r_preSRd1Addr_8;
reg [7:0] r_preSRd2Addr_8;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(o_free),
	.outR(w_outRRelay_2[0]),
	.i_free(w_driveNext),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire_1),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(i_freeNext),
	.rst(rst)
);

always @(posedge w_fire_1 or negedge rst) begin
	if (!rst) begin
		r_preRd1Addr_4 = 4'b0;
		r_preRd2Addr_4 = 4'b0;
		r_preSRd1Addr_8 = 8'b0;
		r_preSRd2Addr_8 = 8'b0;
	end else begin
		r_preRd2Addr_4 = r_preRd1Addr_4;
		r_preRd1Addr_4 = i_data_12[7:0];
		r_preSRd2Addr_8 = r_preSRd1Addr_8;
		r_preSRd1Addr_8 = i_data_12[11:8];
	end
end

assign o_data_24 = {r_preRd2Addr_4, r_preRd1Addr_4, r_preSRd2Addr_8, r_preSRd1Addr_8};

delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext), .rst(rst));
delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule

