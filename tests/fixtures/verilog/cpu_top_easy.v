// cpu_top.v sample for verilog_parser test
module cpu_top (
    input clk
);

    // Instantiate Fetch
    Fetch_top u_Fetch_top (
        .clk(clk)
    );

    // parameterized instantiation of idu
    idu_top #(.WIDTH(32)) u_idu_top (
        .clk(clk)
    );

    exe_top u_exe_top();

    // multiple instances of lsu_top
    lsu_top u_lsu_top1();
    lsu_top u_lsu_top2();

    mem_slot u_mem_slot();

    writeBack u_writeBack();

endmodule
