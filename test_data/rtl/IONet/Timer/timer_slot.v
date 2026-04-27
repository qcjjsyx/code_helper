//-----------------------------------------------
//    module name: 
//    author: zhanglzh
//  
//    version: 1st version (20220718)
//    description: 
//        
//
//
//-----------------------------------------------
`timescale 1ns / 1ps
module timer_slot(
	input	wire		    clk,
	input	wire		    rst,
	input	wire		    rst_finish,        // reset timer_module, when data init finished then rst_finish is valid.
	output	wire	[ 4:0]	int_sig_o,
    
	input	wire	        i_driveFrmMesh,     // i_driveFrmMesh
	output	wire	        o_freeToMesh,       // o_freeToMesh
    input	wire	[50:0]	data_from,
	
    output	wire	        o_driveNextToMesh,  // o_driveNextToMesh
	input	wire	        i_freeNextFrmMesh,  // i_freeNextFrmMesh
	output	wire	[50:0]	data_to
    );
    
    wire           we;
    wire [31:0]    addr_i;
    wire [31:0]    data_i;
    wire [31:0]    data_o;


 	perip_slot_timer slot(
        .clk                (clk               ),
        .rst                (rst               ), 
        .i_driveFrmMesh     (i_driveFrmMesh    ),
        .o_freeToMesh       (o_freeToMesh      ),
        .o_driveNextToMesh  (o_driveNextToMesh ),
        .i_freeNextFrmMesh  (i_freeNextFrmMesh ),

        .data_to            (data_to           ),
        .data_from          (data_from         ),
        
        .we                 (we                ),
        .addr_i             (addr_i            ),
        .data_i             (data_i            ),
        .data_o             (data_o            )
    );


    timer_module timer_module(
        .clk            (clk              ),
        .rst		    (rst_finish       ),
        .we_i		    (we               ),
        .addr_i		    (addr_i           ),
        .data_i		    (data_i           ),
        .data_o		    (data_o           ),
        .int_sig_o	    (int_sig_o        )
    );

    
endmodule
