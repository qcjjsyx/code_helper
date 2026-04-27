

module cWaitMerge2_224b_int(
i_drive0,i_data0_192,o_free0,
i_drive1,i_data1_32,o_free1,
o_driveNext,o_data_224,i_freeNext,rst
);

//input & output port
input i_drive0,i_drive1;
input [191:0] i_data0_192;
input [31:0] i_data1_32;
input i_freeNext;
input rst;

output o_free0,o_free1;
output o_driveNext;
output [223:0] o_data_224;

//wire & reg
wire w_drive0Next,w_drive1Next;
wire w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext;
wire w_sendDrive,w_sendFree;
wire [191:0] w_data0_192;
wire [31:0] w_data1_32;


reg [191:0] r_data0_192;
reg [31:0] r_data1_32;




assign w_data0_192 = i_data0_192;
assign w_firstTrig = i_drive0 | w_sendFree;
(* dont_touch="true" *)delay1U outdelay0 (.inR(i_drive0), .outR(w_drive0Next), .rst(rst));
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

assign w_data1_32 = i_data1_32;
assign w_secondTrig = i_drive1 | w_sendFree;
(* dont_touch="true" *)delay1U outdelay1 (.inR(i_drive1), .outR(w_drive1Next), .rst(rst));
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);

assign w_driveNext = w_drive0Next | w_drive1Next;
assign w_sendDrive = w_driveNext & w_secondReq & w_firstReq;
assign w_sendFree = i_freeNext;
assign o_free0 = i_freeNext;
assign o_free1 = i_freeNext;
assign o_data_224 = {w_data1_32, w_data0_192};
assign o_driveNext = w_sendDrive;

endmodule
