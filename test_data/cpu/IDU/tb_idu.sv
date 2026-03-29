`timescale 1ns/1ps

module tb_idu_top;
    reg         rstn;
    reg         i_driveFromIfu;
    reg [96:0]  i_dataFromIfu_97;
    reg         i_freeFromExe;
    reg         i_driveWriteGrf;
    reg [68:0]  i_dataWriteGrf_69;
    reg         i_driveWriteCsr;
    reg [75:0]  i_dataWriteCsr_76;
    wire        o_freeToIfu;
    wire        o_driveToExe;
    wire [342:0] o_dataToExe_343;
    wire        o_freeWriteGrf;
    wire        o_freeWriteCsr;
    integer fileInput, fileOutput, r, n, j;
    reg [127:0] line = 0;
    reg c = 0;
    reg [63:0]  pc = 0;
    reg [31:0]  ins = 0;
    reg [4:0]   grfAddr = 0;
    reg [63:0]  grfData = 0;
    idu_top u_idu_top (
        .i_driveFromIfu(i_driveFromIfu),
        .i_dataFromIfu_97(i_dataFromIfu_97),
        .o_freeToIfu(o_freeToIfu),

        .o_driveToExe(o_driveToExe),
        .o_dataToExe_343(o_dataToExe_343),
        .i_freeFromExe(i_freeFromExe),

        .i_driveWriteGrf(i_driveWriteGrf),
        .i_dataWriteGrf_69(i_dataWriteGrf_69),
        .o_freeWriteGrf(o_freeWriteGrf),

        .i_driveWriteCsr(i_driveWriteCsr),
        .i_dataWriteCsr_76(i_dataWriteCsr_76),
        .o_freeWriteCsr(o_freeWriteCsr),
        .rstn(rstn)
    );
    initial begin
        fileInput   = $fopen("/team/asc/sun.yingjie/TPU/idu/RTL/tb/tbInput.txt"    ,"r");
        fileOutput  = $fopen("/team/asc/sun.yingjie/TPU/idu/RTL/tb/tbOutput.txt"   ,"w");
    end
    final begin
        $fclose(fileInput);
        $fclose(fileOutput);
    end
    initial begin
        init();
        reset();
        for (j = 0; j < 32; j++) begin
            writeGrf(j, {$urandom,$urandom});
        end
        sendInstructionsFromFile();
        #200;
        $finish;
    end
    always @(posedge o_driveToExe) begin
        # 100;
        i_freeFromExe = 1;
        # 1;
        i_freeFromExe = 0;
    end
    integer counter=0;
    always @(posedge i_driveFromIfu) begin
        counter++;
        $fdisplay(fileOutput,"========Number:%d,Time:%d============",counter,$time);
        $fdisplay(fileOutput,"Input:%1b,%16h,%8h,%d",i_dataFromIfu_97[96],i_dataFromIfu_97[95:32],i_dataFromIfu_97[31:0],$time);
    end
    always @(posedge o_driveToExe) begin
        $fdisplay(fileOutput,
        "Output-time:%d\nop1:0x%16h,\nop2:0x%16h,\nimm:0x%16h,\npc:0x%16h,\ninstr:0x%8h,\naluControl_12:%12b,\nmul_1:%1b,\nmulLowHigh_1:%1b,\ndiv_1:%1b,\nremainder_1:%1b,\nmulDivSign_2:%2b,\nCsrType_1:%1b,\nCsrCsw_3:%3b,\nstore_1:%1b,\nload_1:%1b,\nloadSign_1:%1b,\nloadStoreWidth_2:%2b,\nJal_1:%1b,\nJalr_1:%1b,\nBType_1:%1b,\nBTypeCon_4:%4b,\nbranchSign_1:%1b,\njumpOrNot_1:%1b,\nrd_5:%5b,\nrs2Csr_12:%12b,\ncompress_1:%1b,\nrv64_1:%1b"
        ,$time
        ,o_dataToExe_343[63:0]
        ,o_dataToExe_343[127:64]
        ,o_dataToExe_343[191:128]
        ,o_dataToExe_343[255:192]
        ,o_dataToExe_343[287:256]
        ,o_dataToExe_343[299:288]
        ,o_dataToExe_343[300]
        ,o_dataToExe_343[301]
        ,o_dataToExe_343[302]
        ,o_dataToExe_343[303]
        ,o_dataToExe_343[305:304]
        ,o_dataToExe_343[306]
        ,o_dataToExe_343[309:307]
        ,o_dataToExe_343[310]
        ,o_dataToExe_343[311]
        ,o_dataToExe_343[312]
        ,o_dataToExe_343[314:313]
        ,o_dataToExe_343[315]
        ,o_dataToExe_343[316]
        ,o_dataToExe_343[317]
        ,o_dataToExe_343[321:318]
        ,o_dataToExe_343[322]
        ,o_dataToExe_343[323]
        ,o_dataToExe_343[328:324]
        ,o_dataToExe_343[340:329]
        ,o_dataToExe_343[341]
        ,o_dataToExe_343[342]
        );
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
        i_driveFromIfu = 0;
        i_dataFromIfu_97 = 97'b0;
        i_freeFromExe = 0;
        i_driveWriteGrf = 0;
        i_dataWriteGrf_69 = 69'b0;
        i_driveWriteCsr = 0;
        i_dataWriteCsr_76 = 76'b0;
        #500;
    end
    endtask
task inputFromIFU;
    input        c;
    input [63:0] pc;
    input [31:0] ins;
    begin
        i_dataFromIfu_97 = {c, pc, ins};
        #5;
        i_driveFromIfu   = 1;
        #1;
        i_driveFromIfu   = 0;
        #10000;
    end
endtask
task sendInstructionsFromFile;
    begin
        if (fileInput == 0) begin
            $display("Error: Cannot open tbInput.txt");
            $finish;
        end
        n = 0;
        while (!$feof(fileInput)) begin
            r = $fscanf(fileInput, "%b %h %h\n", c, pc, ins);
            if (r == 3) begin
                inputFromIFU(c, pc, ins);
                n = n + 1;
            end
        end
        $display("Total %0d instructions sent from fileInput", n);
    end
endtask
task writeGrf;
    input [5-1:0]grfAddr;
    input [64-1:0]grfData;
    begin
        i_dataWriteGrf_69 = {grfAddr,grfData};
        #5;
        i_driveWriteGrf = 1;
        #1;
        i_driveWriteGrf = 0;
        #10000;
    end
endtask
endmodule