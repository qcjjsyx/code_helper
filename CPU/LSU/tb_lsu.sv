`timescale 1ns/1ps

module tb_lsu_top;
    reg           i_driveFromExe    ;
    wire          o_freeToExe       ;
    reg [246-1:0] i_dataFromExe_246 ;
    wire          o_driveToMem      ;
    reg           i_freeFromMem     ;
    wire[136-1:0] o_dataToMem_136   ;
    reg           i_driveFromMem    ;
    wire          o_freeToMem       ;
    reg [256-1:0] i_dataFromMem_256 ;
    wire          o_driveToRetire   ;
    reg           i_freeFromRetire  ;
    wire[246-1:0] o_dataToRetire_246;
    reg           rstn              ;
    integer fileOutput;
lsu_top u_lsu_top (
    .i_driveFromExe     (i_driveFromExe    ),
    .o_freeToExe        (o_freeToExe       ),
    .i_dataFromExe_246  (i_dataFromExe_246 ),
    .o_driveToMem       (o_driveToMem      ),
    .i_freeFromMem      (i_freeFromMem     ),
    .o_dataToMem_136    (o_dataToMem_136   ),
    .i_driveFromMem     (i_driveFromMem    ),
    .o_freeToMem        (o_freeToMem       ),
    .i_dataFromMem_256  (i_dataFromMem_256 ),
    .o_driveToRetire    (o_driveToRetire   ),
    .i_freeFromRetire   (i_freeFromRetire  ),
    .o_dataToRetire_246 (o_dataToRetire_246),
    .rst                (rstn              )
);
initial begin
    init();
    reset();
    //store cross cache line, "pass"
    exeInput(4'b0010,3'b011,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
    memInput(256'b0);
    memInput(256'b0);
    //load cross cache line, "pass"
    exeInput(4'b0011,3'b111,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
    memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
    memInput(256'hFFFF_EEEE_DDDD_CCCC_BBBB_AAAA_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000);
//not cross cache line
    //store byte
        $fdisplay(fileOutput,"========time: %0t, test: store byte========",$time);
        exeInput(4'b0010,3'b000,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'b0);
    //store half
        $fdisplay(fileOutput,"========time: %0t, test: store half========",$time);
        exeInput(4'b0010,3'b001,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'b0);
    //store word
        $fdisplay(fileOutput,"========time: %0t, test: store word========",$time);
        exeInput(4'b0010,3'b010,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'b0);
    //store double
        $fdisplay(fileOutput,"========time: %0t, test: store double========",$time);
        exeInput(4'b0010,3'b011,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'b0);
    //load byte unsign
        $fdisplay(fileOutput,"========time: %0t, test: load byte unsign========",$time);
        exeInput(4'b0011,3'b000,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
    //load half unsign
        $fdisplay(fileOutput,"========time: %0t, test: load half unsign========",$time);
        exeInput(4'b0011,3'b001,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
    //load word sign
        $fdisplay(fileOutput,"========time: %0t, test: load word sign========",$time);
        exeInput(4'b0011,3'b110,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
    //load double sign
        $fdisplay(fileOutput,"========time: %0t, test: load double sign========",$time);
        exeInput(4'b0011,3'b111,64'h0000_0000_FFFF_0000,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
//cross cache line
    //store half
        $fdisplay(fileOutput,"========time: %0t, test: store half========",$time);
        exeInput(4'b0010,3'b001,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'b0);
        memInput(256'b0);
    //store word
        $fdisplay(fileOutput,"========time: %0t, test: store word========",$time);
        exeInput(4'b0010,3'b010,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'b0);
        memInput(256'b0);
    //store double
        $fdisplay(fileOutput,"========time: %0t, test: store double========",$time);
        exeInput(4'b0010,3'b011,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'b0);
        memInput(256'b0);
    //load half sign
        $fdisplay(fileOutput,"========time: %0t, test: load half sign========",$time);
        exeInput(4'b0011,3'b101,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
        memInput(256'hFFFF_EEEE_DDDD_CCCC_BBBB_AAAA_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000);
    //load word unsign
        $fdisplay(fileOutput,"========time: %0t, test: load word unsign========",$time);
        exeInput(4'b0011,3'b010,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
        memInput(256'hFFFF_EEEE_DDDD_CCCC_BBBB_AAAA_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000);
    //load double unsign
        $fdisplay(fileOutput,"========time: %0t, test: load double unsign========",$time);
        exeInput(4'b0011,3'b011,64'h0000_0000_FFFF_FFFF,64'h1234_5678_9abc_def0);
        memInput(256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF);
        memInput(256'hFFFF_EEEE_DDDD_CCCC_BBBB_AAAA_9999_8888_7777_6666_5555_4444_3333_2222_1111_0000);
    #200;
    $finish;
end
initial begin
    fileOutput = $fopen("/team/asc/sun.yingjie/TPU/lsu/RTL/tb/tbOutput.txt","w");
end
final begin
    $fclose(fileOutput);
end
always @(posedge o_driveToRetire) begin
    # 100;
    i_freeFromRetire = 1;
    # 1;
    i_freeFromRetire = 0;
end
always @(u_lsu_top.r_counter_2) begin
    $fdisplay(fileOutput,
        "time=%0t r_counter_2=%b",
        $time,
        u_lsu_top.r_counter_2
    );
end
always @(posedge o_driveToMem) begin
    $fdisplay(fileOutput,"====o_dataToMem_136====");
    $fdisplay(fileOutput,"Wen:8'b%b",o_dataToMem_136[135:128]);
    $fdisplay(fileOutput,"addr:0x%h(64'b%b)",o_dataToMem_136[127:64],o_dataToMem_136[127:64]);
    $fdisplay(fileOutput,"data:0x%h(64'b%b)",o_dataToMem_136[63:0],o_dataToMem_136[63:0]);
end
always @(posedge o_driveToRetire) begin
    $fdisplay(fileOutput,"====o_dataToRetire_246====");
    $fdisplay(fileOutput,"pc:0x%h,\ncompress_1:1'b%b,\ninstr:0x%h,\ntype_4:4'b%b,rd_5:5'b%b,\nfunc_12:12'b%b,\naddr_64:0x%h,\ndata_64:0x%h",
    o_dataToRetire_246[245:182],
    o_dataToRetire_246[181],
    o_dataToRetire_246[180:149],
    o_dataToRetire_246[148:145],
    o_dataToRetire_246[144:140],
    o_dataToRetire_246[139:128],
    o_dataToRetire_246[127:64],
    o_dataToRetire_246[63:0]);
end
task reset;
    begin
        rstn = 0;#1000;
        rstn = 1;#500;
    end
endtask
task init;
    begin
        rstn = 1;
        i_driveFromExe = 0;
        i_dataFromExe_246 = 246'b0;
        i_freeFromMem = 0;
        i_driveFromMem = 0;
        i_dataFromMem_256 = 256'b0;
        i_freeFromRetire = 0;
        #500;
    end
endtask
task exeInput(
    input [3:0] type_4,
    input [2:0] func_12_3,
    input [63:0]addr_64,
    input [63:0]data_64
);
    begin
        i_dataFromExe_246 = {
            64'h6666_6666_6666_6666,
            1'b0,
            32'hABCD_1234,
            type_4,
            5'b11111,
            9'b0,
            func_12_3,
            addr_64,
            data_64
        };
        #5;
        i_driveFromExe = 1;
        #1;
        i_driveFromExe = 0;
        #10000;
    end
endtask
task memInput(
    input [255:0]data_256
);
    begin
        i_freeFromMem = 1;
        #1;
        i_freeFromMem = 0;
        #1000;
        i_dataFromMem_256 = data_256;
        #5;
        i_driveFromMem = 1;
        #1;
        i_driveFromMem = 0;
        #10000;
    end
endtask
endmodule