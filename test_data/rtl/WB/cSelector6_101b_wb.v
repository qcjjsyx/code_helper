`timescale 1ns / 1ps


module cSelector6_101b_wb(
i_drive, i_data_101, o_free,
o_driveNext0, i_freeNext0, o_data0_40,
o_driveNext1, o_data1_32, i_freeNext1,
o_driveNext2, o_data2_74, i_freeNext2,
o_driveNext3, o_data3_87, i_freeNext3,
o_driveNext4, o_data4_87, i_freeNext4,
o_driveNext5, o_data5_32, i_freeNext5,
rst);

input i_drive;
input i_freeNext0,i_freeNext1,i_freeNext2,i_freeNext3,i_freeNext4,i_freeNext5;
input rst;
input [100:0] i_data_101;

output o_free;
output o_driveNext0,o_driveNext1, o_driveNext2,o_driveNext3,o_driveNext4,o_driveNext5;
output [39:0] o_data0_40;
output [31:0] o_data1_32; 
output [73:0] o_data2_74; 
output [86:0] o_data3_87; 
output [86:0] o_data4_87; 
output [31:0] o_data5_32; 

wire [1:0] w_outRRelay_2,w_outARelay_2;
wire w_fire,w_selector1,w_selector2;
wire w_free_1;
wire w_freeNext;
wire w_freeNext0;
wire w_driveNext0;
wire [95:0] w_temp_96;
wire [2:0] w_valid_3;

(*KEEP="TRUE"*) wire [7:0] w_prfAddr_8;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrH_4;
(*KEEP="TRUE"*) wire [3:0] w_grfAddrL_4;
(*KEEP="TRUE"*) wire [63:0] w_data_64;
(*KEEP="TRUE"*) wire [1:0] w_rdWen_2;
(*KEEP="TRUE"*) wire [4:0] w_msbit_5,w_lsbit_5;
(*KEEP="TRUE"*) wire w_writeRd_1,w_bfc_1,w_bfi_1,w_s_1,w_sbfx,w_ubfx,w_msr_1;

assign {w_prfAddr_8,w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2,w_msr_1,w_msbit_5,w_lsbit_5,w_bfi_1,w_bfc_1,w_sbfx,w_ubfx,w_writeRd_1,w_valid_3} = i_data_101;

wire w_valid_1;
wire w_valid1_1;
wire w_valid2_1;
wire w_valid3_1;
wire w_valid4_1;
wire w_valid5_1;

reg r_valid_1;
reg r_valid1_1;
reg r_valid2_1;
reg r_valid3_1;
reg r_valid4_1;
reg r_valid5_1;

assign w_valid_1 = (w_valid_3 == 3'b000) ? 1'b1 : 1'b0;
assign w_valid1_1 = (w_valid_3 == 3'b001) ? 1'b1 : 1'b0;
assign w_valid2_1 = (w_valid_3 == 3'b010) ? 1'b1 : 1'b0;
assign w_valid3_1 = (w_valid_3 == 3'b011) ? 1'b1 : 1'b0;
assign w_valid4_1 = (w_valid_3 == 3'b100) ? 1'b1 : 1'b0;
assign w_valid5_1 = (w_valid_3 == 3'b101) ? 1'b1 : 1'b0;

reg [31:0] r_data0_32;

//pipeline
sender sender(
	.i_drive(i_drive),
	.o_free(w_free_1),
	.outR(w_outRRelay_2[0]),
	.i_free(w_fire),
	.rst(rst)
);

relay relay0(
	.inR(w_outRRelay_2[0]),
	.inA(w_outARelay_2[0]),
	.outR(w_outRRelay_2[1]),
	.outA(w_outARelay_2[1]),
	.fire(w_fire),
	.rst(rst)
);

receiver receiver(
	.inR(w_outRRelay_2[1]),
	.inA(w_outARelay_2[1]),
	.i_freeNext(w_freeNext0),
	.rst(rst)
);

always @(posedge w_fire or negedge rst) begin
	if (!rst) begin
		r_valid_1 <= 1'b0; 
		r_valid1_1 <= 1'b0; 
		r_valid2_1 <= 1'b0;
		r_valid3_1 <= 1'b0;
		r_valid4_1 <= 1'b0;
		r_valid5_1 <= 1'b0;
	end else begin
		r_valid_1 <= w_valid_1; 
		r_valid1_1 <= w_valid1_1; 
		r_valid2_1 <= w_valid2_1; 
		r_valid3_1 <= w_valid3_1;
		r_valid4_1 <= w_valid4_1;
		r_valid5_1 <= w_valid5_1;
	end
end

assign o_data0_40 = {w_prfAddr_8,w_data_64[31:0]}; 
assign o_data1_32 = w_data_64[63:32]; 
assign o_data2_74 = {w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2};
assign o_data3_87 = {w_selector1,w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2,w_msbit_5,w_lsbit_5,w_bfi_1,w_bfc_1};
assign o_data4_87 = {w_selector2,w_grfAddrH_4,w_grfAddrL_4,w_data_64,w_rdWen_2,w_msbit_5,w_lsbit_5,w_sbfx,w_ubfx};

//control signal
(* dont_touch="true" *)delay2U outdelay2 (.inR(w_free_1), .outR(o_free), .rst(rst));
delay2U outdelay0(.inR(w_fire), .outR(w_driveNext0),.rst(rst));
assign o_driveNext0 = w_driveNext0 & ~w_valid_3[0] & ~w_valid_3[1] & ~w_valid_3[2];
assign o_driveNext1 = w_driveNext0 &  w_valid_3[0] & ~w_valid_3[1] & ~w_valid_3[2];
assign o_driveNext2 = w_driveNext0 & ~w_valid_3[0] &  w_valid_3[1] & ~w_valid_3[2];
assign o_driveNext3 = w_driveNext0 &  w_valid_3[0] &  w_valid_3[1] & ~w_valid_3[2];
assign o_driveNext4 = w_driveNext0 & ~w_valid_3[0] & ~w_valid_3[1] &  w_valid_3[2];
assign o_driveNext5 = w_driveNext0 &  w_valid_3[0] & ~w_valid_3[1] &  w_valid_3[2];
assign w_selector1 = ( w_valid_3 == 3'b011) ? 1'b1 : 1'b0;
assign w_selector2 = (w_valid_3 == 3'b100) ? 1'b1 : 1'b0;

assign w_freeNext = i_freeNext0 | i_freeNext1 | i_freeNext2 | i_freeNext3 | i_freeNext4 | i_freeNext5;

(* dont_touch="true" *)delay4U outdelay3 (.inR(w_freeNext), .outR(w_freeNext0), .rst(rst));

endmodule


