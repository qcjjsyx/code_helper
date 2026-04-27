`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date: 2024/08/01 16:22:10
// Design Name: 
// Module Name: noc_GeneralSpi_slot

// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
`define DATAWIDTH 32;

module noc_generalSpi_slot(
                            input              clk,
                            input              rst,
                    
                            input              i_driveFrmMesh,
                            output             o_freeToMesh,
(*dont_touch = "yes"*)     input [50:0]       i_dataFrmNoc,
                            
                            output             o_driveNextToMesh,
                            input              i_freeNextFrmMesh,
(*dont_touch = "yes"*)      output reg [50:0]  o_data2Noc,

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
                            wire[7:0]   address;
//                            wire        finish;
//                            reg         r_enT;
(*dont_touch = "yes"*)      reg        readFlag;
   
	wire [1:0]      w_fire_2;
	reg             w_en;
	
//	reg             r_enT;
(*dont_touch = "yes"*)	wire            r_en;
(*dont_touch = "yes"*)	wire            w_finish;
    
    wire             o_driveNextToMeshTmp;      //临时存放cFifo输出的i_drive，因为实际出现时间太早，不可使用
    
//------------------------------------
//获取数据来源，以实现数据回传
//------------------------------------
    assign address = i_dataFrmNoc[49:42];
    
    reg i_driveFrmMesh_sync1, i_driveFrmMesh_sync2;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            i_driveFrmMesh_sync1 <= 1'b0;
            i_driveFrmMesh_sync2 <= 1'b0;
        end
        else begin
            i_driveFrmMesh_sync1 <= i_driveFrmMesh;  // 第一级同步器
            i_driveFrmMesh_sync2 <= i_driveFrmMesh_sync1;  // 第二级同步器
        end
    end
    
    wire i_driveFrmMesh_rising = i_driveFrmMesh_sync2 & ~i_driveFrmMesh_sync1;

//    always @(posedge clk or negedge rst) begin
//        if (!rst)
//            startSpi <= 1'b0;
//        else if (i_driveFrmMesh_rising)
//            startSpi <= 1'b1;
//        else
//            startSpi <= 1'b0;
//    end

	// cFifo2's two relay need to delay.
    cFifo2 cFifo2(
        .rst            ( rst               ),
        .i_drive        ( i_driveFrmMesh    ),
        .o_free         ( o_freeToMesh      ),
        .o_fire_2       ( w_fire_2          ),

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
    	
//	always @(posedge w_fire_2[0] or negedge rst) begin
//	   if(!rst) begin
//	       r_enT <= 1'b1;
//	   end else 
//	       r_enT <= i_dataFrmNoc[50];
//	end
	
//-----------------------------------------
//寄存器配置
//-----------------------------------------	

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
localparam TDR = 4'h2;
localparam RDR = 4'h3;

assign w_SR = {dataReady,w_TXE,busy,w_finish,4'b0};

assign w_data2noc = (address[3:0] == CR) ? r_CR :
                    (address[3:0] == SR) ? w_SR :
                    (address[3:0] == TDR) ? r_TDR :
                    (address[3:0] == RDR) ? w_RDR : 32'b0;

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
    else if(!w_en) begin
        o_data2Noc <= {w_en,address,w_data2noc,10'b0};
    end
    else o_data2Noc <= o_data2Noc;
end

//----------------------------------------------
//时钟计数
//----------------------------------------------	
//(*dont_touch = "yes"*)	clkSynch clkSynch(
//	   .fire0(w_fire_2[0]),
//	   .DATAWIDTH(dataWidth),
//	   .clk(clk),
//	   .rst(rst),
//	   .dataReady(dataReady)
//	);

    assign r_en = (!w_en) & dataReady;               //判断是读请求并且数据准备好
    
//----------------------------------------------
//进行数据读取，及向Noc的传输
//----------------------------------------------

//(*dont_touch = "yes"*)    reg readFlag;            //判断是否已经读取到数据
(*dont_touch = "yes"*)    wire startRead_fire;            // 用于保存a_drive信号的寄存器
//(*dont_touch = "yes"*)    reg [31:0] data2spi_reg;      // 用于保存b_data信号的寄存器
    
//    assign data2Spi = w_en ? i_dataFrmNoc[41:10] : 32'b0;
    
    //fireOut
    always @(posedge clk or negedge rst) begin
		if(!rst) begin
		     readFlag <= 1'b0;
		end else if(startRead) begin
		     readFlag <= 1'b0;		     
		end else begin
//		     startRead <= 1'b0;
		     if(r_en & ~readFlag & (address == RDR)) begin
		        readFlag <= 1'b1;
		     end else begin
		        readFlag <= readFlag;
		     end
		end
	end
	
	wire o_driveNextToMesh_tmp2;
	
	assign o_driveNextToMesh_tmp2 = readFlag;
	
//	assign o_driveNextToMesh = (!w_en) ? o_driveNextToMesh_tmp2 : o_driveNextToMeshTmp;
assign startRead_fire = ((address[3:0] == TDR) & w_en) ? w_fire_2[1] : 1'b0;
fire2SyncPluse fire2SyncPluse_u(
.fire(startRead_fire),
.clk(clk),
.rst(rst),
.rise(startRead)
);
//---------------------------------------------------
//延迟输出startRead和data2spi    
//---------------------------------------------------
//    always @(posedge w_finish or negedge rst or posedge w_fire_2[1]) begin
//        if (!rst) begin
//            // 异步复位
//	         startRead_fire = 1'b0;
	         
//	    end else if(w_fire_2[1] & (address[3:0] == TDR) & w_en) begin
//		     startRead_fire = 1'b1;
		     
//        end else begin       
//            // 当finish信号到达时，输出保存的a_drive和b_data
//            if (w_finish) begin
//                startRead_fire = 1'b0;

//            end else begin
//                startRead_fire =  startRead_fire;
//            end
//        end
//    end
//    always @(posedge clk or negedge rst) begin
//        if (!rst) begin
//            // 异步复位
//             startRead <= 1'b0;
//        end else begin       
//            // 当finish信号到达时，输出保存的a_drive和b_data
//            if (w_finish) begin
//                startRead <= startRead_fire;
//            end else begin
//                startRead <= 1'b0;      // 如果finish未到，保持输出为0（或其它默认值）
//            end
//        end
//    end
    
    
    //module inst
    flash_state u_flash(
        .clk        (clk        ),
        .rst_n      (rst        ),

        .i_startRead(startRead),
        .i_ctl     (r_CR     ), 
        .i_data2spi (r_TDR ), 
        .o_dataFspi (w_RDR ), 

        .i_w_en     (w_en     ), 
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
