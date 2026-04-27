//-----------------------------------------------
//    module name: socmem
//    author: lu.yihua
//    version: 1st version (2024-10-17)
//    description: 
//    to realise rom write Icache, 
//    when init: LSU need to write Icache and Dcache, and IF only read from ROM
//    so I add some selector logic.
//-----------------------------------------------
`timescale 1ns / 1ps

module socmem(
    input  wire        		rst,
    input  wire        		clk,
    input  wire             UART_INIT_SEL,
    
    input  wire			    i_driveFrmIf,       
    output  wire			o_freeToIf,          
    
    output  wire		    o_driveNextToIf,     
    input  wire		        i_freeNextFrmIf,     
    
    // ICache: data_width 64bit
    input  wire 	[ 7:0] 	i_iwen_8,
    input  wire 	[31:0] 	i_iaddress_32,
    input  wire 	[63:0] 	i_idataW_64,
    output wire 	[63:0] 	o_idataR_64,
    
    input  wire			    i_driveFrmLsu,       
    output  wire			o_freeToLsu,        
    
    output  wire		    o_driveNextToLsu,     
    input  wire		        i_freeNextFrmLsu,     
    // DCache: data_width 64bit
    input  wire 	[ 7:0] 	i_dwen_8,          
    input  wire 	[31:0] 	i_daddress_32, 
    input  wire 	[63:0] 	i_ddataW_64,  
    output wire 	[63:0] 	o_ddataR_64,

	input	wire	        init_sig
    );
    
    wire        fire1Up, fire0Up;
    wire        itrigbufFire, dtrigbufFire;
    wire        if_Trig, lsu_Trig;
    wire [63:0] o_idataR_t_64, o_ddataR_t_64;
    wire [63:0] o_ddataR_tStack_64;
    wire [1:0]  w_fireLsu, w_fireIf;
    wire [15:0]  w_dcacheTrigBuf_2;
    wire [15:0]  w_icacheTrigBuf_2;
    wire        w_dcache, w_stack;  //write to w_dcache or w_stack

    reg [7:0]  r_iwen_8;
    reg [63:0] r_idataW_64;
    reg  [31:0] r_iaddress_32;

    reg [7:0]  r_dwen_8;
    reg [63:0] r_ddataW_64;
    reg  [31:0] r_daddress_32;
    reg dcache_routeSelect_N;
    reg dcache_en,stack_en;

    // 取指地址空间划分：如果地址是32'h00000000~32'h00000fff,就去ROM，否则去Icache
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg routeSelect;

    // 去Icache得把地址的值减掉ROM的大小和外设的地址空间，因为Icache存储器内部是从0开始编址的，但是进来的是统一编址的值
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_itemp;   //11.20 hrq: 把地址改成了reg类型
    // assign temp = r_iaddress_32 - 32'h00001200; 
    // 去Dcache得把地址的值减掉Icache的结尾，因为Dcache存储器内部是从0开始编址的，但是进来的是统一编址的值
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_dtemp;
    // assign temp_dcache = r_daddress_32 - 32'h00021200; 
    // 去stack 得把地址的值减掉Dcache的结尾，因为stacke存储器内部是从0开始编址的，但是进来的是统一编址的值
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0] r_stack;
    // assign temp_stack = r_daddress_32 - 32'h00041200;

    // wire w_isDcache;
    assign w_dcache = lsu_Trig && (dcache_en||UART_INIT_SEL);
    assign w_stack  = lsu_Trig && (stack_en||UART_INIT_SEL);

	CKMUX2M4HM	icachemux(.S(init_sig),.A(w_fireIf[1]),.B(clk),.Z(w_icacheTrigBuf_2[0]));
	BUFM2HM buf0(.A(w_icacheTrigBuf_2[0]), .Z(w_icacheTrigBuf_2[1]));
    BUFM2HM buf1(.A(w_icacheTrigBuf_2[1]), .Z(w_icacheTrigBuf_2[2]));
    BUFM2HM buf2(.A(w_icacheTrigBuf_2[2]), .Z(w_icacheTrigBuf_2[3]));
    BUFM2HM buf3(.A(w_icacheTrigBuf_2[3]), .Z(w_icacheTrigBuf_2[4]));
    BUFM2HM buf4(.A(w_icacheTrigBuf_2[4]), .Z(w_icacheTrigBuf_2[5]));
    BUFM2HM buf5(.A(w_icacheTrigBuf_2[5]), .Z(w_icacheTrigBuf_2[6]));
    BUFM2HM buf6(.A(w_icacheTrigBuf_2[6]), .Z(w_icacheTrigBuf_2[7]));
    BUFM2HM buf7(.A(w_icacheTrigBuf_2[7]), .Z(w_icacheTrigBuf_2[8]));
    BUFM2HM buf8(.A(w_icacheTrigBuf_2[8]), .Z(w_icacheTrigBuf_2[9]));
    BUFM2HM buf9(.A(w_icacheTrigBuf_2[9]), .Z(w_icacheTrigBuf_2[10]));
    BUFM2HM buf10(.A(w_icacheTrigBuf_2[10]), .Z(w_icacheTrigBuf_2[11]));
    BUFM2HM buf11(.A(w_icacheTrigBuf_2[11]), .Z(w_icacheTrigBuf_2[12]));
    BUFM2HM buf12(.A(w_icacheTrigBuf_2[12]), .Z(w_icacheTrigBuf_2[13]));
    BUFM2HM buf13(.A(w_icacheTrigBuf_2[13]), .Z(w_icacheTrigBuf_2[14]));
    BUFM2HM buf14(.A(w_icacheTrigBuf_2[14]), .Z(w_icacheTrigBuf_2[15]));
    BUFM2HM buf15(.A(w_icacheTrigBuf_2[15]), .Z(if_Trig));

	CKMUX2M4HM	dcachemux(.S(init_sig),.A(w_fireLsu[1]),.B(clk),.Z(w_dcacheTrigBuf_2[0]));
	BUFM2HM buf16(.A(w_dcacheTrigBuf_2[0]), .Z(w_dcacheTrigBuf_2[1]));
    BUFM2HM buf17(.A(w_dcacheTrigBuf_2[1]), .Z(w_dcacheTrigBuf_2[2]));
    BUFM2HM buf18(.A(w_dcacheTrigBuf_2[2]), .Z(w_dcacheTrigBuf_2[3]));
    BUFM2HM buf19(.A(w_dcacheTrigBuf_2[3]), .Z(w_dcacheTrigBuf_2[4]));
    BUFM2HM buf20(.A(w_dcacheTrigBuf_2[4]), .Z(w_dcacheTrigBuf_2[5]));
    BUFM2HM buf21(.A(w_dcacheTrigBuf_2[5]), .Z(w_dcacheTrigBuf_2[6]));
    BUFM2HM buf22(.A(w_dcacheTrigBuf_2[6]), .Z(w_dcacheTrigBuf_2[7]));
    BUFM2HM buf23(.A(w_dcacheTrigBuf_2[7]), .Z(w_dcacheTrigBuf_2[8]));
    BUFM2HM buf24(.A(w_dcacheTrigBuf_2[8]), .Z(w_dcacheTrigBuf_2[9]));
    BUFM2HM buf25(.A(w_dcacheTrigBuf_2[9]), .Z(w_dcacheTrigBuf_2[10]));
    BUFM2HM buf26(.A(w_dcacheTrigBuf_2[10]), .Z(w_dcacheTrigBuf_2[11]));
    BUFM2HM buf27(.A(w_dcacheTrigBuf_2[11]), .Z(w_dcacheTrigBuf_2[12]));
    BUFM2HM buf28(.A(w_dcacheTrigBuf_2[12]), .Z(w_dcacheTrigBuf_2[13]));
    BUFM2HM buf29(.A(w_dcacheTrigBuf_2[13]), .Z(w_dcacheTrigBuf_2[14]));
    BUFM2HM buf30(.A(w_dcacheTrigBuf_2[14]), .Z(w_dcacheTrigBuf_2[15]));
    BUFM2HM buf31(.A(w_dcacheTrigBuf_2[15]), .Z(lsu_Trig));

    /*************************** Icache access ************************/
    //when in init, Icache data is from LSU, after it is read only
    always @(posedge w_fireIf[0] or negedge rst) begin
        if(!rst)begin
            routeSelect   <= 0;  
            r_iwen_8      <= 0;
            r_iaddress_32 <= 0;   
            r_idataW_64   <= 0;
            r_itemp       <= 0;
        end
        else begin
            if(i_iaddress_32>32'h00000fff)begin
                routeSelect <= 1;
            end
            r_iaddress_32 <= i_iaddress_32;
            r_idataW_64   <= i_idataW_64;
            r_iwen_8      <= i_iwen_8;
            r_itemp       <= i_iaddress_32 - 32'h00001200;
        end
    end
    wire [1:0] w_driveNextToIf;
    delay16U delay_IF1 (.inR(w_driveNextToIf[0]), .outR(o_driveNextToIf),.rst(rst));
    


    cFifo2_socmem cFifo2_If(
        .i_drive        ( i_driveFrmIf       ),
        .o_free         ( o_freeToIf         ),
        .o_fire_2       ( w_fireIf           ),
        .rst            ( rst                ),  
        .o_driveNext    ( w_driveNextToIf[0] ),
        .i_freeNext     ( i_freeNextFrmIf    )
    );
    
    // UMC .11um  SRAM ip   :ICache
    // addr width : 14bit
    // data width : 64bit 
    wire [31:0] w_if_temp   = i_iaddress_32 - 32'h00001200;
    wire [31:0] w_lsu_temp  = i_daddress_32 - 32'h00001200;
    wire [31:0] w_itemp     = ~dcache_routeSelect_N ? w_if_temp   : w_lsu_temp  &{32{dcache_routeSelect_N}};
    wire [ 7:0] w_iwen_8    = ~dcache_routeSelect_N ? i_iwen_8    : i_dwen_8    &{ 8{dcache_routeSelect_N}};
    wire [63:0] w_idataW_64 = ~dcache_routeSelect_N ? i_idataW_64 : i_ddataW_64 &{64{dcache_routeSelect_N}};
    //wire i_trig = (lsu_Trig & dcache_routeSelect_N) |( if_Trig & (routeSelect|UART_INIT_SEL) );
    wire i_trig = lsu_Trig |( if_Trig & (routeSelect|UART_INIT_SEL) );
    sram_128k  ICache (
        .i_addr_14               ( w_itemp[13:0]        ),
        .i_data_64               ( w_idataW_64          ),
        .i_sramTrig              ( i_trig               ), 
        .i_WEB_8                 ( w_iwen_8             ), 
        .o_data_64               ( o_idataR_t_64        )
    );

    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [63:0] w_idataROM_64;
    (*dont_touch = "yes"*)ROM ROM(
        .clk                    ( w_fireIf[1]           ),
        .rst                    ( rst                   ),
        .i_addr                 ( r_iaddress_32[11:0]   ),
        .o_data                 ( w_idataROM_64         )	
    );

    assign o_idataR_64 = (routeSelect==1) ? o_idataR_t_64 : w_idataROM_64; 

    /*************************** Dcache access **********************/
 
    // Lsu access dcache
    wire [1:0] w_driveNextToLsu;
    wire w_freeToLsu;
    delay16U delay_LSU1 (.inR(w_driveNextToLsu[0]), .outR(w_driveNextToLsu[1]),.rst(rst));
    delay8U delay_LSU2 (.inR(w_driveNextToLsu[1]), .outR(o_driveNextToLsu),.rst(rst));
    cFifo2_socmem cFifo2_Lsu(
        .i_drive        ( i_driveFrmLsu     ),
        .o_free         ( o_freeToLsu       ),
        .o_fire_2       ( w_fireLsu         ),
        .rst            ( rst               ),
        .o_driveNext    ( w_driveNextToLsu[0]  ),
        .i_freeNext     ( i_freeNextFrmLsu  )
    );
    always @(posedge w_fireLsu[0] or negedge rst) begin
        if(!rst)begin 
            r_daddress_32 <= 0;  
            r_dwen_8      <= 0; 
            r_ddataW_64   <= 0;
            r_dtemp       <= 0;
            r_stack       <= 0;
            dcache_routeSelect_N <= 0;
            dcache_en     <= 0;
            stack_en      <= 0;
        end
        else begin
            r_daddress_32 <= i_daddress_32;  
            r_dwen_8      <= i_dwen_8; 
            r_ddataW_64   <= i_ddataW_64;
            r_dtemp       <= i_daddress_32 - 32'h00021200;
            r_stack       <= i_daddress_32 - 32'h00041200;
            dcache_routeSelect_N <= (i_daddress_32<32'h00021200 && i_daddress_32>=32'h00001200);
            dcache_en     <= (i_daddress_32>=32'h00021200 && i_daddress_32<32'h00041200);
            stack_en      <= (i_daddress_32>=32'h00041200);
        end
    end
 
    // UMC .11um  SRAM ip  :DCache
    // addr width : 14bit
    // data width : 64bit
    wire [31:0] w_dtemp;
    assign w_dtemp = i_daddress_32 - 32'h00021200;
    sram_128k  DCache (
        .i_addr_14               ( w_dtemp[13:0]        ),
        .i_data_64               ( i_ddataW_64          ),
        .i_sramTrig              ( w_dcache             ),  // //11.20 hrq:接上了 i_sramTrig
        .i_WEB_8                 ( i_dwen_8             ),
        .o_data_64               ( o_ddataR_t_64        )   
    );


    // UMC .11um  SRAM ip  :DCache
    // addr width : 10bit
    // data width : 64bit
    wire [31:0] w_stemp;
    assign w_stemp = i_daddress_32 - 32'h00021200;
    sram_8k  stack (
        .i_addr_10               ( w_stemp[9:0]         ),
        .i_data_64               ( i_ddataW_64          ),
        .i_sramTrig              ( w_stack              ),  
        .i_WEB_8                 ( i_dwen_8             ),

        .o_data_64               ( o_ddataR_tStack_64   )   
    );

    assign o_ddataR_64 = (r_daddress_32<32'h00021200) ? o_idataR_t_64 :
                         (r_daddress_32<32'h00041200) ? o_ddataR_t_64 : o_ddataR_tStack_64;



endmodule
