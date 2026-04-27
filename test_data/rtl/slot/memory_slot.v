//-----------------------------------------------
//    module name: memory_slot
//    author: Lu.yihua
//    version: 1st version (2024-10-17)
//    description: 该模块实例化了socmem模块和data_init模块，并通过init_enable控制两个模块：
//                 当init_enable为高电平时，data_init模块工作，初始化存储器，
//                 当init_enable为低电平时，socmem模块工作，从存储器中读出数据
//
//-----------------------------------------------
`timescale 1ns / 1ps
module memory_slot(

  input   wire         rst,
  input   wire         rst_finish,

  // initial module
  input   wire         clk,
  
  input   wire         UART_INIT_SEL,
  output  wire         init_sig,
  input   wire         init_rx,
  output  wire         init_tx,
  
  // LSU module
  input   wire          i_driveFrmLsu,       
  output  wire          o_freeToLsu,    
  input   wire [ 7:0]   i_dbus_we,
  input   wire [31:0]   i_dbus_addr,
  input   wire [63:0]   i_dbus_data,
  
  output  wire          o_driveNextToLsu,     
  input   wire          i_freeNextFrmLsu,     
  output  wire [63:0]   o_dbus_data,

  // fetch module
  input   wire          i_driveFrmIf,         
  output  wire          o_freeToIf,           
  input   wire [ 7:0]   i_ibus_we,
  input   wire [32:0]   i_ibus_addr,
  input   wire [63:0]   i_ibus_data,
  
  output  wire          o_driveNextToIf,      
  input   wire          i_freeNextFrmIf,      
  output  wire [64:0]   o_ibus_data
  );
  
  /************************** clk *******************************/

  /************************** icache and dcache input *******************************/

  wire init_sig_temp;
  wire init_sig_temp2 = init_sig_temp & UART_INIT_SEL;
  assign init_sig = init_sig_temp ;

  wire [7:0]          memory_ibus_we;
  wire [32:0]         memory_ibus_addr_i;      
  wire [63:0]         memory_ibus_data_i;        
  wire [64:0]         memory_ibus_data_o;   

  wire [7:0]          memory_dbus_we;        
  wire [31:0]         memory_dbus_addr_i; 
  wire [63:0]         memory_dbus_data_i; 
  wire [63:0]         memory_dbus_data_o; 
  
  wire                init_ibus_we      ;
  wire [31:0]         init_ibus_addr    ;      
  wire [63:0]         init_ibus_data    ;        
  
  wire                init_dbus_we      ;        
  wire [31:0]         init_dbus_addr    ; 
  wire [63:0]         init_dbus_data    ; 

  
  assign memory_ibus_we      = init_sig_temp2 ?  {8{init_ibus_we}}    :  i_ibus_we    ;
  assign memory_ibus_addr_i  = init_sig_temp2 ?  {init_ibus_addr,1'b0}:  i_ibus_addr  ;
  assign memory_ibus_data_i  = init_sig_temp2 ?  init_ibus_data       :  i_ibus_data  ;
  assign memory_dbus_we      = init_sig_temp2 ?  {8{init_dbus_we}}    :  i_dbus_we    ;
  assign memory_dbus_addr_i  = init_sig_temp2 ?  init_dbus_addr       :  i_dbus_addr  ;
  assign memory_dbus_data_i  = init_sig_temp2 ?  init_dbus_data       :  i_dbus_data  ;
  
  assign o_ibus_data = memory_ibus_data_o; 
  assign o_dbus_data = memory_dbus_data_o;
    

  socmem socmem(
      .rst                (rst                ),
      .clk                (clk&UART_INIT_SEL  ),
      .init_sig           (init_sig_temp2     ),
      
      // access Icache
      .i_driveFrmIf       (i_driveFrmIf       ),
      .o_freeToIf         (o_freeToIf         ),
      .o_driveNextToIf    (o_driveNextToIf    ),
      .i_freeNextFrmIf    (i_freeNextFrmIf    ),
      
      .i_iwen_8           (memory_ibus_we     ),          
      .i_iaddress_33      (memory_ibus_addr_i ), 
      .i_idataW_64        (memory_ibus_data_i ),  
      .o_idataR_65        (memory_ibus_data_o ),
      // access Dcache
      .i_driveFrmLsu      (i_driveFrmLsu      ),
      .o_freeToLsu        (o_freeToLsu        ),
      .o_driveNextToLsu   (o_driveNextToLsu   ),
      .i_freeNextFrmLsu   (i_freeNextFrmLsu   ),
      
      .i_dwen_8           (memory_dbus_we     ),              
      .i_daddress_32      (memory_dbus_addr_i ),
      .i_ddataW_64        (memory_dbus_data_i ),   
      .o_ddataR_64        (memory_dbus_data_o )
  );
  
    data_init u_data_init(
       .clk             (clk                ),        
       .rst             (rst                ),
       .init_sig        (init_sig_temp      ),
       
       .uart_rx         (init_rx            ),    // read data from UART
       .uart_tx         (init_tx            ),    // write respone to outside
       
       .ibus_we         (init_ibus_we       ),
       .ibus_addr_o     (init_ibus_addr     ),
       .ibus_data_o     (init_ibus_data     ),
       .dbus_we         (init_dbus_we       ),
       .dbus_addr_o     (init_dbus_addr     ),
       .dbus_data_o     (init_dbus_data     )
    );
    
endmodule    

