`timescale 1ns / 1ps

/*
lsu的状态转换
*/
module stateUpdate(
input rst,
//从updateSplitter来的脉冲及数据
input i_driveFromUpdateSplitter_1,
input [6:0] i_fromUpdateSplitterData_7,
//从stateUpdateSelector来的复位
input i_freeFromStateUpdateSelector_1,

//给updateSplitter的复位
output o_freeToUpdateSplitter_1,

//给stateUpdatSelector的脉冲
output o_driveToStateUpdateSelector_1,
output [11:0] o_stateValid_12,
output o_misaligned_1
);
wire w_driveToLoadAndStoreSelector_1;
wire w_loadAndStoreSelectorToFifo1_1;
(* dont_touch="true" *)wire w_isLoad_1;      
(* dont_touch="true" *)wire w_isStore_1;     
(* dont_touch="true" *)wire [1:0] w_lsuType_2;     
(* dont_touch="true" *)wire [2:0] w_memAddrLtb_3;

(* dont_touch="true" *)cFifo1_7b_lsu Fifo1(
    .i_drive(i_driveFromUpdateSplitter_1),
    .i_freeNext(w_loadAndStoreSelectorToFifo1_1),
    .rst(rst),
    .o_free(o_freeToUpdateSplitter_1),
    .o_driveNext(w_driveToLoadAndStoreSelector_1),
    .i_data_7(i_fromUpdateSplitterData_7),
    .o_data_7({w_isLoad_1,w_isStore_1,w_lsuType_2,w_memAddrLtb_3})
);

// loadAndStoreSelector
wire w_loadFifoToLoadAndStoreSelector_1;
wire w_loadAndStoreSelectorToLoadFifo_1;
wire w_storeFifoToLoadAndStoreSelector_1;
wire w_loadAndStoreSelectorToStoreFifo_1;
(* dont_touch="true" *)cSelector2_2b_lsu loadAndStoreSelector(
    .i_drive(w_driveToLoadAndStoreSelector_1),
    .i_freeNext0(w_loadFifoToLoadAndStoreSelector_1),
    .i_freeNext1(w_storeFifoToLoadAndStoreSelector_1),
    .i_data_2({w_isStore_1,w_isLoad_1}),
    .o_data0_2(),
    .o_data1_2(),
    .rst(rst),
    .o_free(w_loadAndStoreSelectorToFifo1_1),
    .o_driveNext0(w_loadAndStoreSelectorToLoadFifo_1),
    .o_driveNext1(w_loadAndStoreSelectorToStoreFifo_1)
);

//这里的clastfifo改的有问题
// loadFifo
wire w_loadFifoOver_1;
wire w_loadFifoDrive_1;
wire [6:0] w_loadFifoData_7;
wire w_loadOrStoreMutexMergeToLoadFifo_1;
(* dont_touch="true" *)cFifo1_7b_lsu loadFifo(
    .i_drive(w_loadAndStoreSelectorToLoadFifo_1),
    .i_freeNext(w_loadOrStoreMutexMergeToLoadFifo_1),
    .rst(rst),
    .o_free(w_loadFifoToLoadAndStoreSelector_1),
    .o_driveNext(w_loadFifoDrive_1),
    .i_data_7(7'b0),
    .o_data_7(w_loadFifoData_7)
);

// storeFifo
wire w_storeFifoOver_1;
wire w_storeFifoDrive_1;
wire [6:0] w_storeFifoData_7;
wire w_loadOrStoreMutexMergeToStoreFifo_1;
(* dont_touch="true" *)cFifo1_7b_lsu storeFifo(
    .i_drive(w_loadAndStoreSelectorToStoreFifo_1),
    .i_freeNext(w_loadOrStoreMutexMergeToStoreFifo_1),
    .rst(rst),
    .o_free(w_storeFifoToLoadAndStoreSelector_1),
    .o_driveNext(w_storeFifoDrive_1),
    .i_data_7(7'b0),
    .o_data_7(w_storeFifoData_7)
);
//11/13 zwm change to mutexMerge
// assign o_driveToStateUpdateSelector_1 = w_storeFifoDrive_1 | w_loadFifoDrive_1;
wire [7:0] w_over_8;
cMutexMerge2_8b_lsu loadOrStoreMutexMerge(
    .i_drive0(w_storeFifoDrive_1), .i_data0_8(8'b0), .o_free0(w_loadOrStoreMutexMergeToStoreFifo_1),
    .i_drive1(w_loadFifoDrive_1), .i_data1_8(8'b0), .o_free1(w_loadOrStoreMutexMergeToLoadFifo_1),
    .i_freeNext(i_freeFromStateUpdateSelector_1), .o_driveNext(o_driveToStateUpdateSelector_1), .o_data_8(w_over_8),
    .rst(rst)
    );

// 组合逻辑
localparam	state_Idle		    =	4'b0000;
localparam	state_LoadByteEnd	=	4'b0001;
localparam	state_LoadHwordEnd	=	4'b0010;
localparam	state_LoadWordEnd	=	4'b0011;
localparam  state_LoadDwordEnd  =   4'b0100;
localparam	state_LoadHwordmisa	=	4'b0101;
localparam	state_LoadWordmisa	=	4'b0110;
localparam	state_LoadDwordmisa	=	4'b0111;
localparam	state_StoreWordEnd	=	4'b1000;
localparam	state_StoreHwordEnd	=	4'b1001;
localparam	state_StoreDwordEnd	=	4'b1010;

wire w_misaligned_1;
wire idle;		
wire lbValid;		
wire lhwValid;	
wire lwValid;		
wire lhwmValid;	
wire lwmValid;	
wire swValid;		
wire shwValid;
wire ldwValid;
wire ldwmValid;
wire sdwValid;

wire LoadIdleValid;
wire StoreIdleValid;
wire [3:0] w_nextState_4;
reg [3:0] r_nextStoreState_4;
reg [3:0] r_nextLoadState_4;
(* dont_touch="true" *)wire [11:0] w_stateValid_12;
(* dont_touch="true" *)reg [3:0] r_state_4;	

assign	w_misaligned_1 = (w_lsuType_2 == 2'b11 & (w_memAddrLtb_3 == 3'b101 | w_memAddrLtb_3 == 3'b110 | w_memAddrLtb_3 == 3'b111))  
				     | ((w_lsuType_2 == 2'b01) & w_memAddrLtb_3 == 3'b111)
                     | ((w_lsuType_2 == 2'b10) & w_memAddrLtb_3 == 3'b100);

assign	idle		=	(~r_state_4[3])&(~r_state_4[2])&(~r_state_4[1])&(~r_state_4[0]);
assign	lbValid		=	(~r_state_4[3])&(~r_state_4[2])&(~r_state_4[1])&(r_state_4[0]);
assign	lhwValid	=	(~r_state_4[3])&(~r_state_4[2])&(r_state_4[1])&(~r_state_4[0]);
assign	lwValid		=	(~r_state_4[3])&(~r_state_4[2])&(r_state_4[1])&(r_state_4[0]);
assign  ldwValid    =	(~r_state_4[3])&(r_state_4[2])&(~r_state_4[1])&(~r_state_4[0]);
assign	lhwmValid	=	(~r_state_4[3])&(r_state_4[2])&(~r_state_4[1])&(r_state_4[0]);
assign	lwmValid	=	(~r_state_4[3])&(r_state_4[2])&(r_state_4[1])&(~r_state_4[0]);
assign	ldwmValid	=	(~r_state_4[3])&(r_state_4[2])&(r_state_4[1])&(r_state_4[0]);
assign	swValid		=	(r_state_4[3])&(~r_state_4[2])&(~r_state_4[1])&(~r_state_4[0]);
assign	shwValid	=	(r_state_4[3])&(~r_state_4[2])&(~r_state_4[1])&(r_state_4[0]);
assign	sdwValid	=	(r_state_4[3])&(~r_state_4[2])&(r_state_4[1])&(~r_state_4[0]);

assign	LoadIdleValid = w_isLoad_1 & idle;
assign	StoreIdleValid = w_isStore_1 & idle;

assign	w_nextState_4	=	{4{w_isLoad_1 & LoadIdleValid}} & r_nextLoadState_4 
						  | {4{w_isStore_1 & StoreIdleValid}} & r_nextStoreState_4
				          | {4{lbValid}} & state_Idle
				          | {4{lhwValid}} & state_Idle
                          | {4{ldwValid}} & state_Idle
				          | {4{lwValid}} & state_Idle
				          | {4{lhwmValid}} & state_LoadHwordEnd
                          | {4{ldwmValid}} & state_LoadDwordEnd
				          | {4{lwmValid}} & state_LoadWordEnd
				          | {4{swValid}} & state_Idle
				          | {4{shwValid}} & state_Idle
                          | {4{sdwValid}} & state_Idle;
 
assign 	w_stateValid_12 = {LoadIdleValid, lbValid, lhwValid, ldwValid, lwValid, 
                        lhwmValid, ldwmValid, lwmValid, StoreIdleValid, swValid, shwValid, sdwValid};


// 控制状态变化
wire w_stateUpdateFire;
reg r_misaligned_1;
reg [11:0] r_stateValid_12;
assign w_stateUpdateFire = w_loadAndStoreSelectorToLoadFifo_1 | w_loadAndStoreSelectorToStoreFifo_1;
always@(posedge w_stateUpdateFire or negedge rst)
begin
	if(!rst)
    begin
	    r_state_4 <= state_Idle;
	end
	else   
    begin
	    r_state_4 <= w_nextState_4; 
	end
end

//有效信号的产生应该在w_stateUpdateFire之后
wire w_stateUpdateFireDelay;
delay8U outdelay0(.inR(w_stateUpdateFire), .outR(w_stateUpdateFireDelay),.rst(rst));
always@(posedge w_stateUpdateFireDelay or negedge rst)
begin
	if(!rst)
    begin
        // r_misaligned_1 <= 1'b0;
        r_stateValid_12 <= 12'b0000_0000_0000;
	end
	else   
    begin
        // r_misaligned_1 <= w_misaligned_1;
        r_stateValid_12 <= w_stateValid_12;
	end
end
assign o_misaligned_1 = w_misaligned_1;
assign o_stateValid_12 = r_stateValid_12;


// load和store未对齐需要保存上回的状态
always@(*)
begin
	case(w_lsuType_2)
	2'b11:		    begin	r_nextLoadState_4 = !w_misaligned_1 ? state_LoadWordEnd : state_LoadWordmisa;	end
	2'b01:	        begin	r_nextLoadState_4 = !w_misaligned_1 ? state_LoadHwordEnd : state_LoadHwordmisa;	end
    2'b10:          begin	r_nextLoadState_4 = !w_misaligned_1 ? state_LoadDwordEnd : state_LoadDwordmisa;	end
	2'b00:		    begin	r_nextLoadState_4 = state_LoadByteEnd;						                    end
	endcase
end

always@(*)
begin
	if(!w_misaligned_1) 
    begin
	    r_nextStoreState_4 = state_Idle;
	end
	else 
    begin
	    case(w_lsuType_2)
	    2'b11:		    begin	r_nextStoreState_4 = state_StoreWordEnd;	end
	    2'b01:	        begin	r_nextStoreState_4 = state_StoreHwordEnd;	end
        2'b10:	        begin	r_nextStoreState_4 = state_StoreDwordEnd;	end
	    default:	    begin	r_nextStoreState_4 = state_Idle;		    end
	    endcase
	end
end
endmodule
