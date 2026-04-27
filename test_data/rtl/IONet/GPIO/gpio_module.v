//-----------------------------------------------
//    module name: gpio
//    author: lu.yihua
//    version: Updated with refined interrupt logic
//-----------------------------------------------
`timescale 1ns / 1ps
module gpio_module #(
    parameter GPIO_NUM = 16
    )(
    input  wire        clk,
    input  wire        rst,

    input  wire        we_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,

    output wire [31:0] gpio_ctrl_o,
    output wire [31:0] gpio_data_o,

    input  wire [GPIO_NUM-1:0] io_pin_i,
    output wire        irq
);

    // 寄存器地址映射
    localparam GPIO_CTRL            = 8'h90;   // GPIO 控制寄存器
    localparam GPIO_DATA            = 8'h94;   // GPIO 控制寄存器
    localparam GPIO_INT_ENABLE      = 8'h98;   // 全局中断使能寄存器
    localparam GPIO_RISING_EDGE_EN  = 8'h9C;   // 上升沿中断能寄存器
    localparam GPIO_FALLING_EDGE_EN = 8'hA0;   // 下降沿中断使能
    localparam GPIO_INT_STATUS      = 8'hA4;   // 中断状态寄存器
    localparam GPIO_HIGH_LEVEL_EN   = 8'hA8;   // 高电平中断使能
    localparam GPIO_LOW_LEVEL_EN    = 8'hAC;   // 低电平中断使能


    // GPIO 控制和数据寄存器
    reg [31:0] gpio_ctrl;
    reg [31:0] gpio_data;

    // 中断控制寄存�?
    reg [GPIO_NUM-1:0] int_enable;
    reg [GPIO_NUM-1:0] rising_edge_en;
    reg [GPIO_NUM-1:0] falling_edge_en;
    reg [GPIO_NUM-1:0] int_status;
    reg [GPIO_NUM-1:0] high_level_en;
    reg [GPIO_NUM-1:0] low_level_en;

    // 输入信号同步寄存�?
    reg [GPIO_NUM-1:0] io_pin_sync1;
    reg [GPIO_NUM-1:0] io_pin_sync2;
    reg [GPIO_NUM-1:0] io_pin_prev;

    // 写入使能信号
    wire write_reg_ctrl_en         = we_i & (addr_i[7:0] == GPIO_CTRL);
    wire write_reg_data_en         = we_i & (addr_i[7:0] == GPIO_DATA);
    wire write_reg_int_enable_en   = we_i & (addr_i[7:0] == GPIO_INT_ENABLE);
    wire write_reg_rising_edge_en  = we_i & (addr_i[7:0] == GPIO_RISING_EDGE_EN);
    wire write_reg_falling_edge_en = we_i & (addr_i[7:0] == GPIO_FALLING_EDGE_EN);
    wire write_reg_int_status_en   = we_i & (addr_i[7:0] == GPIO_INT_STATUS);
    wire write_reg_high_level_en = we_i & (addr_i[7:0] == GPIO_HIGH_LEVEL_EN);
    wire write_reg_low_level_en  = we_i & (addr_i[7:0] == GPIO_LOW_LEVEL_EN);

    // 输出寄存器�?
    assign gpio_ctrl_o = gpio_ctrl;
    assign gpio_data_o = gpio_data;

    assign data_o = (addr_i[7:0] == GPIO_CTRL)            ? gpio_ctrl :
                    (addr_i[7:0] == GPIO_DATA)            ? gpio_data :
                    (addr_i[7:0] == GPIO_INT_ENABLE)      ? int_enable :
                    (addr_i[7:0] == GPIO_RISING_EDGE_EN)  ? rising_edge_en :
                    (addr_i[7:0] == GPIO_FALLING_EDGE_EN) ? falling_edge_en :
                    (addr_i[7:0] == GPIO_INT_STATUS)      ? int_status    :
                    (addr_i[7:0] == GPIO_HIGH_LEVEL_EN)   ? high_level_en :
                    (addr_i[7:0] == GPIO_LOW_LEVEL_EN)    ? low_level_en : 32'b0;

    // 输入信号同步处理
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            io_pin_sync1 <= 0;
            io_pin_sync2 <= 0;
            io_pin_prev <= 0;
        end else begin
            io_pin_sync1 <= io_pin_i;
            io_pin_sync2 <= io_pin_sync1;
            io_pin_prev <= io_pin_sync2;
        end
    end

    // GPIO 控制寄存器逻辑
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            gpio_ctrl <= 0;
        end else if (write_reg_ctrl_en) begin
            gpio_ctrl <= data_i;
        end
    end

    // GPIO 数据寄存器逻辑
    genvar i;
    generate
        for (i = 0; i < GPIO_NUM; i = i + 1) begin : gpio_data_proc
            always @(posedge clk or negedge rst) begin
                if (!rst) begin
                    gpio_data[i] <= 1'b0;
                end else begin
                    if (write_reg_data_en & gpio_ctrl[i]) begin
                        gpio_data[i] <= data_i[i];
                    end else if (!gpio_ctrl[i]) begin
                        gpio_data[i] <= io_pin_sync2[i];
                    end
                end
            end
        end
    endgenerate

    generate
        for (i = GPIO_NUM; i < 32; i = i + 1) begin : gpio_data_rst
            always @(posedge clk or negedge rst) begin
                if (!rst) begin
                    gpio_data[i] <= 1'b0;
                end
            end
        end
    endgenerate


    // GPIO 使能寄存器逻辑
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            int_enable <= 0;
        end else if (write_reg_int_enable_en) begin
            int_enable <= data_i;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rising_edge_en <= 0;
        end else if (write_reg_rising_edge_en) begin
            rising_edge_en <= data_i;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            falling_edge_en <= 0;
        end else if (write_reg_falling_edge_en) begin
            falling_edge_en <= data_i;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            high_level_en <= 0;
        end else if (write_reg_high_level_en) begin
            high_level_en <= data_i;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            low_level_en <= 0;
        end else if (write_reg_low_level_en) begin
            low_level_en <= data_i;
        end
    end
    // 中断检测逻辑
    generate
        for (i = 0; i < GPIO_NUM; i = i + 1) begin : int_detection
            always @(posedge clk or negedge rst) begin
                if (!rst) begin
                    int_status[i] <= 1'b0;
                end else begin
                    // 清除中断状态
                    if (write_reg_int_status_en & !data_i[i]) begin
                        int_status[i] <= 1'b0;
                    end else begin
                        // 上升沿检测
                        if (!io_pin_prev[i] && io_pin_sync2[i] && rising_edge_en[i] && int_enable[i]) begin
                            int_status[i] <= 1'b1;
                        end
                        // 下降沿检测
                        if (io_pin_prev[i] && !io_pin_sync2[i] && falling_edge_en[i] && int_enable[i]) begin
                            int_status[i] <= 1'b1;
                        end
                        // 高电平检测
                        if (io_pin_sync2[i] && high_level_en[i] && int_enable[i]) begin
                            int_status[i] <= 1'b1;
                        end
                        // 低电平检测
                        if (!io_pin_sync2[i] && low_level_en[i] && int_enable[i]) begin
                            int_status[i] <= 1'b1;
                        end
                    end
                end
            end
        end
    endgenerate

    // 中断输出信号
    assign irq = |(int_status & int_enable);

endmodule
