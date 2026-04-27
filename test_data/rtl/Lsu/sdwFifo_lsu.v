
`timescale 1ns / 1ps

module sdwFifo_lsu(
i_drive, i_data_104, o_free,rst,
o_driveNext, o_data_104, i_freeNext
);

input i_drive, i_freeNext, rst;
input [103:0] i_data_104;
output o_free, o_driveNext;
output [103:0] o_data_104;

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_driveNext;
wire w_fire_1;

reg [31:0] r_sdwMemAddr_32;
reg [63:0] r_sdwMemData_64;
reg [7:0]  r_sdwMemWen_8;

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

always@(posedge w_fire_1 or negedge rst)
begin
	if(!rst) 
    begin
	    r_sdwMemAddr_32	<= 32'h0000_0000;
        r_sdwMemData_64 <= 64'h0000_0000_0000_0000;
	    r_sdwMemWen_8	<= 8'b0000_0000;
	end
	else 
    begin
	    r_sdwMemAddr_32	<= i_data_104[103:72];
        r_sdwMemData_64 <= i_data_104[71:8];
	    r_sdwMemWen_8   <=	8'b0000_1111;
	end
end

assign o_data_104 = {r_sdwMemAddr_32,r_sdwMemData_64,r_sdwMemWen_8};
// delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext));
// delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext));
delay2U outdelay0 (.inR(w_fire_1), .outR(w_driveNext), .rst(rst));
delay2U outdelay1 (.inR(w_driveNext),.outR(o_driveNext), .rst(rst));
endmodule

