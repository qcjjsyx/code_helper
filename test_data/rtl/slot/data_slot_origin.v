//-----------------------------------------------
//    module name: data_slot
//    author: Lu.yihua
//  
//    version: 1st version (2024-10-15)
//    description: 
//                 
//
//
//-----------------------------------------------
`timescale 1ns / 1ps

module data_slot(
    input         rst,
    // CPU ---> memory | Mesh
    // from CPU LSU 
    input         i_drvCpu2Mux,            
    output        o_freeCPUFMux,           
    input  [103:0] i_dataCPU2Mux_104,      

    // to Dcache/and when init should write Icache
    output        o_driveToDcache,         
    input         i_freeFromDcache,        
    output  [7:0] o_dcache_we,             
    output [31:0] o_dcache_addr,           
    output [63:0] o_dcache_data,           

    // to IO Network
    output        o_driveToMesh,           
    input         i_freeFromMesh,          
    output [50:0] o_data2Mesh,  

    // MEMOEY | Mesh -->  CPU LSU
    output        o_driveToCpu,            
    input         i_freeFromCpu,          
    output [63:0] o_memData_64,    
 
    // from Dcache
    input         i_driveFromDcache,       
    output        o_freeToDcache,          
    input  [63:0] i_dcache_data,       

    // from IO Network
    input         i_driveFromMesh,         
    output        o_freeToMesh,            
    input  [50:0] i_dataFMesh              
    );   
    
    // i_dataCPU2Mux_104: 32bit addr + 64bit data + 8bit wen
    // MESH ： 1bit wen + 8bit addr + 32bit data + 10xy 
    
    // ROM      ->  0x00000 ~ 0x00FFF
    // UART0    ->  0x01000 ~ 0x0100F
    // UART1    ->  0x01010 ~ 0x0101F
    // PWM0     ->  0x01020 ~ 0x0102F
    // PWM1     ->  0x01030 ~ 0x0103F
    // IIC0     ->  0x01040 ~ 0x0104F
    // TIMER    ->  0x01050 ~ 0x0105F
    // SPI0     ->  0x01060 ~ 0x0106F
    // SPI1     ->  0x01070 ~ 0x0107F
    // WatchDog ->  0x01080 ~ 0x0108F
    // GPIO     ->  0x01090 ~ 0x0109F
    // Icache   ->  0x01200 ~ 0x21200  // 128KB
    // Dcache   ->  0x21200 ~ 0x41200  // 128KB
    // Stack    ->  0x41200 ~ 0x43200  // 8KB


    /***************************** from CPU out ****************************/
    
    wire [2:0]fire0;
    wire w_driveToDcache, w_driveToMesh;

    // data to dcache
    reg [7:0]  r_cpuWen_8;
    reg [63:0] r_cpu_data;
    reg [31:0] r_cpu_addr;

    wire [7:0] w_cpuWen_8;
    wire [63:0] w_toDcache_64; 
    assign o_dcache_we = r_cpuWen_8;
    assign o_dcache_data = r_cpu_data;
    assign o_dcache_addr = r_cpu_addr;

    // data to mesh
    wire [50:0] data_pre_51;
    wire        w_meshWen_1;      
    wire [ 7:0] w_meshAddr_8;     
    wire [31:0] w_meshData_32;    
    wire [ 4:0] w_meshX_5;        
    wire [ 4:0] w_meshY_5; 
    
    reg [50:0] r_data_pre_51;  
    reg [31:0] r_data0;  
    
    wire [31:0] i_data_bus_addr;
    assign i_data_bus_addr = i_dataCPU2Mux_104[103:72];

    wire w_toMesh_1;              // Mesh
    wire w_toCache_1;             // cache
    wire w_toUART0_1;              // UART0
    wire w_toUART1_1;              // UART1
    wire w_toGPIO_1;              // GPIO
    wire w_toTIMER_1;             // TIMER
    wire w_toSPI0_1;               // SPI0
    wire w_toSPI1_1;               // SPI1
    wire w_toIIC_1;               // IIC
    wire w_toPWM0_1;               // PWM0
    wire w_toPWM1_1;               // PWM1
    wire w_toWD_1;                // WD
    assign w_toMesh_1    =    i_data_bus_addr>=32'h00001000&&i_data_bus_addr<32'h00001200;          
    assign w_toCache_1   =    i_data_bus_addr>=32'h00021200;    
    assign w_toUART0_1  =    i_data_bus_addr >= 32'h00001000 && i_data_bus_addr <= 32'h0000100F;
    assign w_toUART1_1  =    i_data_bus_addr >= 32'h00001010 && i_data_bus_addr <= 32'h0000101F;
    assign w_toPWM0_1   =    i_data_bus_addr >= 32'h00001020 && i_data_bus_addr <= 32'h0000102F;
    assign w_toPWM1_1   =    i_data_bus_addr >= 32'h00001030 && i_data_bus_addr <= 32'h0000103F;
    assign w_toIIC_1    =    i_data_bus_addr >= 32'h00001040 && i_data_bus_addr <= 32'h0000104F;
    assign w_toTIMER_1  =    i_data_bus_addr >= 32'h00001050 && i_data_bus_addr <= 32'h0000105F;
    assign w_toSPI0_1   =    i_data_bus_addr >= 32'h00001060 && i_data_bus_addr <= 32'h0000106F;
    assign w_toSPI1_1   =    i_data_bus_addr >= 32'h00001070 && i_data_bus_addr <= 32'h0000107F;
    assign w_toWD_1     =    i_data_bus_addr >= 32'h00001080 && i_data_bus_addr <= 32'h0000108F;
    assign w_toGPIO_1   =    i_data_bus_addr >= 32'h00001090 && i_data_bus_addr <= 32'h0000109F;
    
    reg [23:0] r_zeroData;      
    wire [7:0] we = r_cpuWen_8;
    wire [63:0] data = r_cpu_data;
    always @(negedge rst) begin
        r_zeroData <= 24'b0;
    end

    //生成发往mesh的51bit数据
    assign w_meshWen_1   = r_cpuWen_8[7]|r_cpuWen_8[6]|r_cpuWen_8[5]|r_cpuWen_8[4]|
                            r_cpuWen_8[3]|r_cpuWen_8[2]|r_cpuWen_8[1]|r_cpuWen_8[0];                           
    assign w_meshAddr_8  = r_cpu_addr[7:0];   
    assign w_meshData_32 =  (we==8'h80) ? {r_zeroData,data[63: 56]} :
                            (we==8'h40) ? {r_zeroData,data[55: 48]} :
                            (we==8'h20) ? {r_zeroData,data[47: 40]} :
                            (we==8'h10) ? {r_zeroData,data[39: 32]} :
                            (we==8'h08) ? {r_zeroData,data[31: 24]} :
                            (we==8'h04) ? {r_zeroData,data[23: 16]} :
                            (we==8'h02) ? {r_zeroData,data[15:  8]} :
                            (we==8'h01) ? {r_zeroData,data[ 7:  0]} :
                            (we==8'hf0) ? data[63: 32] :
                            (we==8'h0f) ? data[31:  0] : data[31:  0];

                            
    assign w_meshX_5     = {{5{w_toUART0_1 | w_toGPIO_1 }} & {5'b10001}}        
                         | {{5{w_toTIMER_1 | w_toSPI0_1}}  & {5'b00000}}       
                         | {{5{w_toUART1_1 | w_toSPI1_1 | w_toPWM0_1 | w_toPWM1_1}}  & {5'b00001}}
                         | {{5{w_toWD_1    | w_toIIC_1 }}  & {5'b00010}};
                   
    assign w_meshY_5     = {{5{w_toGPIO_1 | w_toSPI1_1 | w_toIIC_1 | w_toUART0_1 | w_toUART1_1 | w_toWD_1}} & {5'b00000}}       
                         | {{5{w_toTIMER_1 | w_toPWM0_1 }} & {5'b00001}}      
                         | {{5{w_toSPI0_1 | w_toPWM1_1  }} & {5'b10001}};         

    assign data_pre_51 = {w_meshWen_1,w_meshAddr_8,w_meshData_32,w_meshX_5,w_meshY_5};

    delay8U delay2(.inR(w_driveToMesh  ), .outR(o_driveToMesh  ), .rst(rst));
    delay8U delay3(.inR(w_driveToDcache), .outR(o_driveToDcache), .rst(rst));

    wire w_drvCpu2Mux,w_freeCPUFMux;
    cFifo3_fetch cfifo0(
        .i_drive        (i_drvCpu2Mux),
        .o_free         (o_freeCPUFMux ),
        .i_freeNext     (w_freeCPUFMux ),
        .o_driveNext    (w_drvCpu2Mux  ),
        .o_fire_3       (fire0),
        .rst            (rst)
    );

    cSelector2_1b select1 (
        .i_drive        (w_drvCpu2Mux       ),
        .i_data_1       (w_toMesh_1         ),
        .o_free         (w_freeCPUFMux      ),

        .o_driveNext0   (w_driveToMesh      ),
        .i_freeNext0    (i_freeFromMesh     ),
        .o_driveNext1   (w_driveToDcache    ),
        .i_freeNext1    (i_freeFromDcache   ),

        .rst            (rst)
    ); 

    always @(posedge fire0[0] or negedge rst)begin
        if(!rst)begin
            r_cpuWen_8         <=    8'b0;
            r_cpu_data         <=    64'h0;
            r_cpu_addr         <=    32'h0;
            r_data_pre_51      <=    51'b0;
            r_data0            <=    32'b0;
        end
        else begin
            r_cpuWen_8         <=    i_dataCPU2Mux_104[7:0];
            r_cpu_data         <=    i_dataCPU2Mux_104[71:8];
            r_cpu_addr         <=    i_dataCPU2Mux_104[103:72];
            r_data_pre_51      <=    data_pre_51;
        end
    end

    assign o_data2Mesh = r_data_pre_51;

    /***************************** from Dcache/Mesh to CPU ****************************/

    wire [63:0] w_dataFromMesh_64; 
    assign w_dataFromMesh_64 = {r_data0,i_dataFMesh[41:10]};

    wire w_driveToCpu;

    cMutexMerge2_64b_launch MutexMerge (
        .rst            ( rst                   ),
        .i_drive0       ( i_driveFromMesh       ),
        .o_free0        ( o_freeToMesh          ),
        .i_data0_64     ( w_dataFromMesh_64     ),
        .i_drive1       ( i_driveFromDcache     ),
        .o_free1        ( o_freeToDcache        ),
        .i_data1_64     ( i_dcache_data         ),

        .o_driveNext    ( w_driveToCpu          ),
        .i_freeNext     ( i_freeFromCpu         ),
        .o_data_64      ( o_memData_64          )
    );
    delay8U delay2CPU_1(.inR(w_driveToCpu  ), .outR(o_driveToCpu  ), .rst(rst));
    
endmodule    
