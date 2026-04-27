
`timescale 1ns / 1ps

module cFifo1_32b_fetch(
i_drive, i_data_32, o_free,rst,
o_driveNext, o_data_32, i_freeNext
);

input i_drive, i_freeNext, rst;
input [31:0] i_data_32;
output o_free, o_driveNext;
output [31:0] o_data_32;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [31:0] r_data_32;

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
		r_data_32 = 32'b0;
	end else begin
		r_data_32 = i_data_32;
	end
end

assign o_data_32 = r_data_32;

delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext), .rst(rst));
delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule

