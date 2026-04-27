//-----------------------------------------------
//    module name: 
//    author: zhanglzh
//  
//    version: 1st version (2021-10-01)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps
module gpio_slot(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     rst_finish,
    input  wire [16-1:0]            io_pin_i,
    output wire [31:0]              gpio_ctrl_o,
    output wire [31:0]              gpio_data_o,


	input	wire	                i_driveFrmMesh,     // i_driveFrmMesh
	output	wire	                o_freeToMesh,       // o_freeToMesh
	output	wire	                o_driveNextToMesh,  // o_driveNextToMesh
	input	wire	                i_freeNextFrmMesh,  // i_freeNextFrmMesh

    output wire [50:0]              data_to,
    input  wire [50:0]              data_from,   
    
    output wire                     irq
    );
    
    wire           we;
    wire [31:0]    addr_i;
    wire [31:0]    data_i;
    wire [31:0]    data_o;

    wire [50:0] w_data_to;
    reg [9:0] XY;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            XY=0;
        end
    end
    assign data_to = {w_data_to[50:10],XY};
    perip_slot slot(
        .clk                (clk               ),
        .rst                (rst               ),
        .rst_finish         (rst_finish        ),
                       
        .i_driveFrmMesh     (i_driveFrmMesh    ),
        .o_freeToMesh       (o_freeToMesh      ),
        .o_driveNextToMesh  (o_driveNextToMesh ),
        .i_freeNextFrmMesh  (i_freeNextFrmMesh ),

        .data_to            (w_data_to         ),
        .data_from          (data_from         ),

        .we                 (we                ),
        .addr_i             (addr_i            ),
        .data_i             (data_i            ),
        .data_o             (data_o            )
    );

    gpio_module gpio_module(
        .clk             (clk               ),
        .rst             (rst_finish        ),

        .we_i            (we                ),
        .addr_i          (addr_i            ),
        .data_i          (data_i            ),
        .data_o          (data_o            ),
        .gpio_ctrl_o     (gpio_ctrl_o       ),
        .gpio_data_o     (gpio_data_o       ),
        .io_pin_i        (io_pin_i          ),
        .irq             (irq               )
    );
    
    
endmodule
