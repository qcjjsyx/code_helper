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

(*dont_touch = "yes"*)      output  reg         startRead,
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
                            reg         r_enT;
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

        .o_driveNext    ( o_driveNextToMeshTmp ),
        .i_freeNext     ( i_freeNextFrmMesh )
   
    );
	
	always @(posedge w_fire_2[0] or negedge rst) begin
		if(!rst) begin
			 w_en <= 1'b0;
		end else begin
		     w_en <= ~i_dataFrmNoc[50];
		    
		end
	end
    	
	always @(posedge w_fire_2[1] or negedge rst) begin
	   if(!rst) begin
	       r_enT <= 1'b0;
	   end else 
	       r_enT <= i_dataFrmNoc[50];
	end
	
//-----------------------------------------
//等待32位数据全部由miso送入
//-----------------------------------------	
    wire dataWidth;
    assign dataWidth = `DATAWIDTH 

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

    assign r_en = r_enT & dataReady;               //判断是读请求并且数据准备好
    
//----------------------------------------------
//进行数据读取，及向Noc的传输
//----------------------------------------------

//(*dont_touch = "yes"*)    reg readFlag;            //判断是否已经读取到数据
(*dont_touch = "yes"*)    reg startRead_reg;            // 用于保存a_drive信号的寄存器
(*dont_touch = "yes"*)    reg [31:0] data2spi_reg;      // 用于保存b_data信号的寄存器
    
    assign data2Spi = w_en ? i_dataFrmNoc[41:10] : 32'b0;
    
    //fireOut
    always @(posedge clk or negedge rst) begin
		if(!rst) begin
		     o_data2Noc <= {41'b0,10'b0000000000};
		     readFlag <= 1'b0;
		end else if(startRead) begin
		     readFlag <= 1'b0;
		     
		end else begin
//		     startRead <= 1'b0;
		     if(r_en & ~readFlag) begin
		        o_data2Noc <= {1'b0,8'b0,dataFrmSpi,10'b0000000000}; //CPU从(0,1)节点本地发送数据，从（1,1）节点North连接SPI1
		        readFlag <= 1'b1;
		     end else begin
		        o_data2Noc <= o_data2Noc;
		        readFlag <= readFlag;
		     end
		end
	end
	
	wire o_driveNextToMesh_tmp2;
	
	assign o_driveNextToMesh_tmp2 = readFlag;
	
	assign o_driveNextToMesh = r_enT ? o_driveNextToMesh_tmp2 : o_driveNextToMeshTmp;
    
//---------------------------------------------------
//延迟输出startRead和data2spi    
//---------------------------------------------------
    always @(posedge clk or negedge rst or posedge w_fire_2[0]) begin
        if (!rst) begin
            // 异步复位
             startRead <= 1'b0;
	         startRead_reg <= 1'b0;
	         
	    end else if(w_fire_2[0]) begin
		     startRead_reg <= 1'b1;
		     
        end else begin       
            // 当finish信号到达时，输出保存的a_drive和b_data
            if (w_finish) begin
                startRead <= startRead_reg;
                startRead_reg <= 1'b0;

            end else begin
                startRead <= 1'b0;      // 如果finish未到，保持输出为0（或其它默认值）
                startRead_reg <=  startRead_reg;
            end
        end
    end
    //module inst
    flash_state u_flash(
        .clk        (clk        ),
        .rst_n      (rst        ),

        .i_startRead(startRead),
        .i_addr     (address     ), 
        .i_data2spi (data2Spi ), 
        .o_dataFspi (dataFrmSpi ), 

        .i_r_enT    (r_enT    ), 
        .i_readflag (readFlag ), 
        .o_busy     (busy     ), 
        .o_dataready(dataReady), 
        .o_finish   (w_finish ),

        .i_miso     (miso     ), 
        .o_sclk     (sclk     ),
        .o_cs_n     (cs_n     ),
        .o_mosi     (mosi     )
    );
	
endmodule
