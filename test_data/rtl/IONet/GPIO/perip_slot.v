//-----------------------------------------------
//    module name: 
//    author:  liangzc
//    modified: zhanglzh
//    version: 1st version (2023-07-18)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps

module perip_slot(
    input  wire          clk,
    input  wire          rst,
    input  wire          rst_finish,

    // mesh --> perip_slot
    input  wire          i_driveFrmMesh,        // i_driveFrmMesh
    output  wire         o_freeToMesh,          // i_driveFrmMesh
    input  wire [50:0]   data_from,             // i_dataFrmMesh_51

    // perip_slot --> mesh
    output wire          o_driveNextToMesh,     // o_driveToMesh
    input wire           i_freeNextFrmMesh,     // o_driveToMesh
    output reg  [50:0]   data_to,               // o_dataToMesh_51

    // perip --> perip_slot
    input  wire [31:0]   data_o,
    
    // perip_slot --> perip
    output wire          we,
    output reg  [31:0]   addr_i,
    output reg  [31:0]   data_i
    );
    
    reg [9:0] XY;
    reg [23:0] addr;

    reg             we_r;
    wire            rise;
	wire            w_fire_0,w_fire_1;

    // cFifo2's two relay need to delay.
    //cFifo2_perip_slot_0 cFifo2(
    //    .rst            ( rst               ),
    //    .i_drive        ( i_driveFrmMesh    ),
    //    .o_free         ( o_freeToMesh      ),
    //    .o_fire_2       ( w_fire_2          ),
//
    //    .o_driveNext    ( o_driveNextToMesh ),
    //    .i_freeNext     ( i_freeNextFrmMesh )
    //);
    wire w_drv2Fifo2,w_freeFfifo2,w_drv2Fifo2_delay1,w_drv2Fifo2_delay2;
    cFifo1 cFifo_1(
        .rst            ( rst               ),
        .i_drive        ( i_driveFrmMesh    ),
        .o_free         ( o_freeToMesh      ),
        .o_fire_1       ( w_fire_0          ),

        .o_driveNext    ( w_drv2Fifo2       ),
        .i_freeNext     ( w_freeFfifo2      )
    );

    delay64U delay0(.inR(w_drv2Fifo2  ), .outR(w_drv2Fifo2_delay1), .rst(rst));
    delay32U delay1(.inR(w_drv2Fifo2_delay1  ), .outR(w_drv2Fifo2_delay2), .rst(rst));

    cFifo1 cFifo_2(
        .rst            ( rst                   ),
        .i_drive        ( w_drv2Fifo2_delay2    ),
        .o_free         ( w_freeFfifo2          ),
        .o_fire_1       ( w_fire_1              ),

        .o_driveNext    ( o_driveNextToMesh ),
        .i_freeNext     ( i_freeNextFrmMesh )
    );
    //fireIn
	always @(posedge w_fire_0 or negedge rst) begin
		if(!rst) begin
		    addr_i <= 32'b0;
		    data_i <= 32'b0;
            we_r   <= 1'b1;
		end else begin
            we_r   <= data_from[50];
		    addr_i <= {addr,data_from[49:42]};
		    data_i <= data_from[41:10];
		end
	end
    
    //fireOut
    //left 0 right 1
    always @(posedge clk or negedge rst_finish) begin
        if(!rst_finish)begin
            XY <= 0;
            addr <= 0;
        end else begin
            XY <= 10'b10001_00000;
            addr <= 0;
        end
    end
    always @(posedge w_fire_1 or negedge rst) begin
		if(!rst) begin
		     data_to <= 1'b0;
		end else begin
		     data_to <= {we_r,addr_i[7:0],data_o,XY};
		end
	end
    
    fire2SyncPluse f2p_we(.fire(w_fire_0),.clk(clk),.rst(rst),.rst_finish(rst_finish),.rise(rise));
    assign we = (!we_r) & rise;

endmodule
