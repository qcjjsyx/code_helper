
`timescale 1ns / 1ps

module lbFifo_lsu(
i_drive, i_data_32, o_free,rst,
o_driveNext, o_data_34, i_freeNext
);

input i_drive, i_freeNext, rst;
input [31:0] i_data_32;
output o_free, o_driveNext;
output [33:0] o_data_34;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [31:0] r_lbGrfData_32;
reg [1:0]  r_lbGrfWen_2;

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

always@(posedge	w_driveNext or negedge rst)
begin
	if(!rst)
    begin
        r_lbGrfData_32 <= 32'b0;
	    r_lbGrfWen_2	   <= 2'b00;
	end
	else 
    begin
        r_lbGrfData_32  <=  i_data_32;
	    r_lbGrfWen_2		<=	2'b10;
	end
end

assign o_data_34 = {r_lbGrfData_32,r_lbGrfWen_2};
// delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext));
// delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext));
delay6U outdelay0 (.inR(w_fire_1), .outR(w_driveNext), .rst(rst));
delay4U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule