`timescale 1ns / 1ps
//===============================================================================
// Project:        TPU
// Module:         CPUwithCache_txt_tb
// version:        
// Author:         Hongrui Miao
// Reviser:        Hongrui Miao
// Date:           2025/12/19
// Connect Mail：  miaohr21@lzu.edu.cn
// Description:    CPU测试模块
//===============================================================================

module CPUwithCache_txt_tb;
reg         rst;
reg         switch;

reg         i_driveFromTPUtoCPU; //TPU读写接口的输入
reg [79:0]  i_dataTPUtoCPU_80;
wire        o_freeFromCPUtoTPU;

wire        o_driveFromCPUtoTPU; //输出给TPU读写接口
reg         i_freeFromTPUtoCPU;

wire        o_driveFromCPUtoTS; //任务调度单元的交互   TASK SCHEDULING
wire[127:0] o_dataCPUtoTS_128;
reg         i_freeFromTStoCPU;

reg         i_driveFromTStoCPU;
wire        o_freeFromCPUtoTS;

// tpuSlot <--> icache
reg           i_icache_drvFTPUSlot; 
wire          o_icache_free2TPUSlot;
reg [55 :0]   i_icache_tpuSlotPA_56;
reg [127:0]   i_icache_instData_128;
wire          o_icache_drv2TPUSlot; 
reg           i_icache_freeFTPUSlot;

// tmu <--> dcache
reg           i_dcache_drvFTMU;   
wire          o_dcache_free2TMU;  
reg           i_dcache_tmuWen;       
reg  [55 :0]  i_dcache_tmuPA_56;   
reg  [63 :0]  i_dcache_tmuData_64;
wire          o_dcache_drv2tmuR;  
reg           i_dcache_freeFtmuR; 
wire [63 :0]  o_dcache_tmuRData_64;
wire          o_dcache_drv2tmuW;    
reg           i_dcache_freeFtmuW;

// l2cache <--> ddr
reg           i_drvFDDRRefill;  
wire          o_free2DDRRefill; 
reg  [255:0]  i_ddrRefillLine_256;
reg           i_drvFDDRWriteOver;
wire          o_free2DDRWriteOver;
wire          o_drv2DDRRead;    
reg           i_freeFDDRRead;    
wire [55 :0]  o_readPA_56;      
wire          o_drv2DDRWrite;   
reg           i_freeFDDRWrite;   
wire [55 :0]  o_writePA_56;     
wire [255:0]  o_writeLine_256;


parameter FILE_PATH = "/project/TPU2025/RTL/CPU/txt/rv64um-p-div.inst.txt";
integer file_handle;
integer line_index;
integer line_counter;  // 循环计数器
integer found;  // 标志是否找到目标行

reg [255:0] line_data;
reg [7:0] temp_char;
integer char_index;


CPUwithCache uut(
.rst(rst),
.switch(switch),

.i_driveFromTPUtoCPU(i_driveFromTPUtoCPU), //TPU读写接口的输入
.i_dataTPUtoCPU_80(i_dataTPUtoCPU_80),
.o_freeFromCPUtoTPU(o_freeFromCPUtoTPU),

.o_driveFromCPUtoTPU(o_driveFromCPUtoTPU), //输出给TPU读写接口
.i_freeFromTPUtoCPU(i_freeFromTPUtoCPU),

.o_driveFromCPUtoTS(o_driveFromCPUtoTS), //任务调度单元的交互   TASK SCHEDULING
.o_dataCPUtoTS_128(o_dataCPUtoTS_128),
.i_freeFromTStoCPU(i_freeFromTStoCPU),

.i_driveFromTStoCPU(i_driveFromTStoCPU),
.o_freeFromCPUtoTS(o_freeFromCPUtoTS),

// tpuSlot <--> icache
.i_icache_drvFTPUSlot(i_icache_drvFTPUSlot), 
.o_icache_free2TPUSlot(o_icache_free2TPUSlot),
.i_icache_tpuSlotPA_56(i_icache_tpuSlotPA_56),
.i_icache_instData_128(i_icache_instData_128),
.o_icache_drv2TPUSlot(o_icache_drv2TPUSlot), 
.i_icache_freeFTPUSlot(i_icache_freeFTPUSlot),

// tmu <--> dcache
.i_dcache_drvFTMU(i_dcache_drvFTMU),   
.o_dcache_free2TMU(o_dcache_free2TMU),  
.i_dcache_tmuWen(i_dcache_tmuWen),       
.i_dcache_tmuPA_56(i_dcache_tmuPA_56),   
.i_dcache_tmuData_64(i_dcache_tmuData_64),
.o_dcache_drv2tmuR(o_dcache_drv2tmuR),  
.i_dcache_freeFtmuR(i_dcache_freeFtmuR), 
.o_dcache_tmuRData_64(o_dcache_tmuRData_64),
.o_dcache_drv2tmuW(o_dcache_drv2tmuW),    
.i_dcache_freeFtmuW(i_dcache_freeFtmuW),

// l2cache <--> ddr
// cache -> ddr 
.o_writePA_56(o_writePA_56),     // write pa
.o_writeLine_256(o_writeLine_256), // write data

// ddr -> cache
.i_drvFDDRRefill(i_drvFDDRRefill),  // read over
.o_free2DDRRefill(o_free2DDRRefill), 
.i_ddrRefillLine_256(i_ddrRefillLine_256), // read data

.i_drvFDDRWriteOver(i_drvFDDRWriteOver), // write over
.o_free2DDRWriteOver(o_free2DDRWriteOver)
);




  always @(posedge o_drv2DDRRead or negedge rst) begin
    if (!rst) begin
        i_ddrRefillLine_256 <= 256'h0;
    end else if(o_readPA_56 >= 56'h21200) begin
       // 延迟响应
        #10;
        i_freeFDDRRead <= ~i_freeFDDRRead;
        #2;
        i_freeFDDRRead <= ~i_freeFDDRRead;

        #5;
       i_ddrRefillLine_256 = {256'h00000000000000000000000000000000f00ff00f0ff00ff0ff00ff0000ff00ff};
       //ld  f00ff00ff00ff00f0ff00ff00ff00ff0ff00ff00ff00ff0000ff00ff00ff00ff
       //lb  000000000000000000000000000000000000000000000000000000000ff000ff
       //lh  000000000000000000000000000000000000000000000000f00f0ff0ff0000ff
       //lw  00000000000000000000000000000000f00ff00f0ff00ff0ff00ff0000ff00ff

       #10;
       i_drvFDDRRefill = ~i_drvFDDRRefill;
       #2;
       i_drvFDDRRefill = ~i_drvFDDRRefill;
    end else begin
        // 延迟响应
        #10;
        i_freeFDDRRead <= ~i_freeFDDRRead;
        #2;
        i_freeFDDRRead <= ~i_freeFDDRRead;

        // 计算行号
        line_index = ((o_readPA_56 - 56'h1200) >> 5) + 1;
        $display("[%0t ns] DDR Read Request: Address=0x%h, Line Index=%0d", 
                 $time, o_readPA_56, line_index);

        // 打开文件并读取特定行
        file_handle = $fopen(FILE_PATH, "r");
        if (file_handle == 0) begin
            $display("Error: Cannot open file %s", FILE_PATH);
            i_ddrRefillLine_256 <= 256'h0;
        end else begin
            found = 0;
            line_counter = 0;

            // 逐行读取直到找到目标行
            while (!$feof(file_handle) && !found) begin
                line_counter = line_counter + 1;
                if (line_counter == line_index) begin
                    // 读取目标行
                    $fscanf(file_handle, "%h\n", i_ddrRefillLine_256);
                    $display("[%0t ns] Successfully read line %0d: Data=%h", 
                             $time, line_index, i_ddrRefillLine_256);
                    found = 1;
                end else begin
                    // 使用简单的循环来跳过一行
                    char_index = 0;
                    while (char_index < 256) begin
                        temp_char = $fgetc(file_handle);
                        if (temp_char == "\n" || temp_char == 8'hFF) begin
                            char_index = 256;  // 遇到换行符或EOF，结束循环
                        end else begin
                            char_index = char_index + 1;
                        end
                    end
                end
            end

            if (!found) begin
                $display("Error: Line %0d not found in file", line_index);
                i_ddrRefillLine_256 <= 256'h0;
            end
          $fclose(file_handle);
        end
      end
       i_drvFDDRRefill <= ~i_drvFDDRRefill;
        #2;
       i_drvFDDRRefill <= ~i_drvFDDRRefill;
      #10;
   end

   always @(posedge o_drv2DDRWrite) begin
    if (rst) begin
        #10;
        i_freeFDDRWrite <= ~i_freeFDDRWrite;
        #2;
        i_freeFDDRWrite <= ~i_freeFDDRWrite;

        $display("[%0t ns] Write to DDR: PA=0x%h, Data=%h",  $time, o_writePA_56, o_writeLine_256);

        #10;
        i_drvFDDRWriteOver <= ~i_drvFDDRWriteOver;
        #2;
        i_drvFDDRWriteOver <= ~i_drvFDDRWriteOver;
    end
end


initial begin

rst = 1;
switch = 0;
i_driveFromTPUtoCPU = 0; //TPU读写接口的输入
i_dataTPUtoCPU_80 = 0;
i_freeFromTPUtoCPU = 0;
i_freeFromTStoCPU = 0;
i_driveFromTStoCPU = 0;
i_icache_drvFTPUSlot = 0; 
i_icache_tpuSlotPA_56 = 0;
i_icache_instData_128 = 0;
i_icache_freeFTPUSlot = 0;
i_dcache_drvFTMU = 0;   
i_dcache_tmuWen = 0;       
i_dcache_tmuPA_56 = 0;   
i_dcache_tmuData_64 = 0;
i_dcache_freeFtmuR = 0;   
i_dcache_freeFtmuW = 0;
i_drvFDDRRefill = 0;  
i_ddrRefillLine_256 = 0;
i_drvFDDRWriteOver = 0;  
i_freeFDDRRead = 0;      
i_freeFDDRWrite = 0;   

file_handle = 0;
line_index = 0;
line_data = 0;
line_counter = 0;
found = 0;


#50;
   rst = 0;
   #150;
   rst = 1;
   #100;

   #10;
   switch = ~switch;
   #2;
   switch = ~switch;
   @(posedge o_driveFromCPUtoTPU);
   #10;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;
   #2;
   i_freeFromTPUtoCPU = ~i_freeFromTPUtoCPU;

   #10;
   i_dataTPUtoCPU_80 = {16'b0000001001011000,64'h1200};
   #5;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;
   #2;
   i_driveFromTPUtoCPU = ~i_driveFromTPUtoCPU;



   #1000;


#10000;
$finish;    
end

endmodule