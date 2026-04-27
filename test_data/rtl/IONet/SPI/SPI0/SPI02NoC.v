`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2024/10/05 10:59:24
// Design Name: CJ 
// Module Name: SPI02NoC
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


module SPI02NoC(
                            input              clk,
                            input              rst,
                            input              rst_finish,
                    
                            input              i_driveFrmMesh,
                            output             o_freeToMesh,
(*dont_touch = "yes"*)     input [50:0]       i_dataFrmNoc,
                            
                            output             o_driveNextToMesh,
                            input              i_freeNextFrmMesh,
(*dont_touch = "yes"*)      output  reg [50:0]  o_data2Noc,
                            //disable opt
                            output      [7:0] address,

(*dont_touch = "yes"*)      output           startRead,
(*dont_touch = "yes"*)      output              busy,
                            input                miso,
                            output               sclk,
                            output               cs_n,
                            output               mosi                        
    );
    
                            wire[31:0]  dataFrmSpi;
                            wire[31:0]  data2Spi;
                            wire        dataReady;
(*dont_touch = "yes"*)      reg        readFlag;
   
	wire [1:0]      w_fire_2;
	reg             w_en;
	
(*dont_touch = "yes"*)	wire            r_en;
(*dont_touch = "yes"*)	wire            w_finish;
    
    wire             o_driveNextToMeshTmp;      //临时存放cFifo输出的i_drive，因为实际出现时间太早，不可使用
    
//------------------------------------
//获取数据来源，以实现数据回传
//------------------------------------
    assign address = i_dataFrmNoc[49:42];
    wire w_driveNext,w_freeNext,w_driveNext_delay;
	// cFifo2's two relay need to delay.
    cFifo1 cFifo1(
        .rst            ( rst               ),
        .i_drive        ( i_driveFrmMesh    ),
        .o_free         ( o_freeToMesh      ),
        .o_fire_1       ( w_fire_2[0]          ),

        .o_driveNext    ( w_driveNext ),
        .i_freeNext     ( w_freeNext )
   
    );

    delay4U delay1 (.inR(w_driveNext), .outR(w_driveNext_delay), .rst(rst));
    cFifo1 cFifo2(
        .rst            ( rst               ),
        .i_drive        ( w_driveNext_delay    ),
        .o_free         ( w_freeNext      ),
        .o_fire_1       ( w_fire_2[1]          ),

        .o_driveNext    ( o_driveNextToMesh ),
        .i_freeNext     ( i_freeNextFrmMesh )
   
    );
	
	always @(posedge w_fire_2[0] or negedge rst) begin
		if(!rst) begin
			 w_en <= 1'b1;
		end else begin
		     w_en <= ~i_dataFrmNoc[50];
		    
		end
	end
    	
(*dont_touch = "yes"*)reg [7:0] r_CR;
wire [7:0] w_SR;
(*dont_touch = "yes"*)reg [31:0] r_TDR;
wire [31:0] w_RDR;
reg [31:0] r_DEFAULT;
wire [31:0] w_data2noc;
wire w_TXE;
//localparam
localparam CR = 4'h0;
localparam SR = 4'h1;
localparam TDR = 4'h4;
localparam RDR = 4'h8;

assign w_SR = {dataReady,w_TXE,busy,w_finish,4'b0};

assign w_data2noc = (address[3:0] == CR) ? {24'b0,r_CR} :
                    (address[3:0] == SR) ? {24'b0,w_SR} :
                    (address[3:0] == TDR) ? r_TDR :
                    (address[3:0] == RDR) ? w_RDR : 32'b0;
//assign o_data2Noc = {i_dataFrmNoc[50],address,w_data2noc,10'b0};
//write
always @(posedge w_fire_2[1] or negedge rst) begin
    if(!rst) begin
        r_CR = 8'b0;
		r_TDR = 32'b0;
	end 
	else if(w_en)begin
	    case(address[3:0])
	    CR: r_CR = i_dataFrmNoc[17:10];
		TDR: r_TDR = i_dataFrmNoc[41:10];
		default: r_DEFAULT = i_dataFrmNoc[41:10];
		endcase
	end
end

//read
always @(posedge w_fire_2[1] or negedge rst) begin
    if(!rst) begin
        o_data2Noc <= 51'b0;
    end 
    else begin
        o_data2Noc <= {i_dataFrmNoc[50],address,w_data2noc,10'b0};
    end
end


    assign r_en = (!w_en) & dataReady;               //判断是读请求并且数据准备好
    
//----------------------------------------------
//进行数据读取，及向Noc的传输
//----------------------------------------------
(*dont_touch = "yes"*)    wire startRead_fire; 

    
    //fireOut
    always @(posedge clk or negedge rst_finish) begin
		if(!rst_finish) begin
		     readFlag <= 1'b0;
		end else if(startRead) begin
		     readFlag <= 1'b0;
		end else begin
		     if(r_en & ~readFlag & (address[3:0] == RDR)) begin
		        readFlag <= 1'b1;
		     end else begin
		        readFlag <= readFlag;
		     end
		end
	end
	
	wire o_driveNextToMesh_tmp2;
	
	assign o_driveNextToMesh_tmp2 = readFlag;
	
assign startRead_fire = ((address[3:0] == TDR) & w_en) ? w_fire_2[1] : 1'b0;
fire2SyncPluse fire2SyncPluse_u(
.fire(startRead_fire),
.clk(clk),
.rst(rst),
.rst_finish(rst_finish),
.rise(startRead)
);    
//---------------------------------------------------
//延迟输出startRead和data2spi    
//---------------------------------------------------
wire w_en_tmp;
assign w_en_tmp = w_en & (address == 8'h64);
    //module inst
    flash_state u_flash(
        .clk        (clk        ),
        .rst_n      (rst_finish        ),

        .i_startRead(startRead),
        .i_ctl     (r_CR     ), 
        .i_data2spi (r_TDR ), 
        .o_dataFspi (w_RDR ), 

        .i_w_en     (w_en_tmp     ), 
        .i_readflag (readFlag ), 
        .o_busy     (busy     ), 
        .o_RXNE     (dataReady), 
        .o_TXE      (w_TXE    ), 
        .o_finish   (w_finish ),

        .i_miso     (miso     ), 
        .o_sclk     (sclk     ),
        .o_cs_n     (cs_n     ),
        .o_mosi     (mosi     )
    );
	
endmodule
