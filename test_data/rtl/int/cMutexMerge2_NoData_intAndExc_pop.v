//	module name: cMutexMerge2_NoData_intAndExc_pop
//	author: xing.yunpeng
//  modifier:
//	version: 1nd version (2024-12-23)
//	description:
//
//-----------------------------------------------

`timescale 1ns / 1ps

module cMutexMerge2_NoData_intAndExc_pop(
i_drive0, /* i_data0_1, */ o_free0,
i_drive1, /* i_data1_1, */ o_free1,
i_freeNext, o_driveNext, /* o_data_1 */
rst
);

//input & output port
input i_drive0, i_drive1;
/* input i_data0_1, i_data1_1; */
input i_freeNext;
input rst;

output o_free0, o_free1;
output o_driveNext;
/* output o_data_1; */


//wire & reg
wire w_firstFire_1,w_secondFire_1,w_sendFire_1;
wire w_firstTrig,w_secondTrig;
wire w_firstReq,w_secondReq;
wire w_driveNext0,w_driveNext1,w_driveNext;
wire w_free0,w_free1,w_free;
/* wire w_data0_1,w_data1_1,w_data_1 ;
reg r_data0_1,r_data1_1,r_data_1 ; */

//firstFifo
// cFifo1 firstFifo
// (
// .i_drive(i_drive0),
// .i_freeNext(w_free0),
// .o_free(o_free0),
// .o_driveNext(w_driveNext0),
// .o_fire_1(w_firstFire_1),
// .rst(rst)
// );


assign w_firstTrig = i_drive0 | o_free0;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
contTap firstTap(
.trig(w_firstTrig),
.req(w_firstReq),
.rst(rst)
);

//secondFifo
// cFifo1 secondFifo(
// .i_drive(i_drive1),
// .i_freeNext(w_free1),
// .o_free(o_free1),
// .o_driveNext(w_driveNext1),
// .o_fire_1(w_secondFire_1),
// .rst(rst)
// );

assign w_secondTrig = i_drive1 | o_free1;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)
contTap secondTap(
.trig(w_secondTrig),
.req(w_secondReq),
.rst(rst)
);


//sendFifo
// cFifo1 sendFifo(
// .i_drive(w_driveNext),
// .i_freeNext(i_freeNext),
// .o_free(w_free),
// .o_driveNext(o_driveNext),
// .o_fire_1(w_sendFire_1),
// .rst(rst)
// );

// always@(posedge w_sendFire_1 or negedge rst)
// begin
//     if(!rst) begin
// 		r_data_1 <= 1'b0;
// 		end
// 	else begin
// 		r_data_1 <= w_data_1;
// 		end
// end

assign o_driveNext = i_drive0 
                     | i_drive1;
                   
// wire o_driveNext_tmp;
// assign o_driveNext_tmp = i_drive0 
				   // | i_drive1;
// // xyp修订于2024/12/23，不加延时不够地址正确生成    
// (* dont_touch="true" *)delay4U outdelay0 (.inR(o_driveNext_tmp), .outR(o_driveNext));


assign o_free0 = i_freeNext & w_firstReq;
assign o_free1 = i_freeNext & w_secondReq;

// assign w_data_1 = (w_firstReq == 1'b1) ? i_data0_1 :
			// ((w_secondReq == 1'b1) ? i_data1_1 : 1'b0);

// assign o_data_1 = w_data_1;

endmodule
