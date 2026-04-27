`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jiang Yilong
// 
// Create Date: 2024/09/13 10:02:43
// Design Name: 
// Module Name: pwm1_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pwm1_top(
    //inputs
    input clk,
    input rst,
    input rst_finish,
    input i_drive,
	input i_free,
	input [50:0] i_msg,
    //[50:49] 1bit write enable 
    //[49:42] 8bits address to control pwm mode, see defines
    //[41:10] 32bit data: [25:10]frequency [41:26]duty
    //[9:0] route data
    //outputs
    //2 mesh
    output o_drive,
	output o_free,
	output [50:0] o_msg,
    //[41:10] 32bit data: [25:10]frequency [41:26]duty
    output pwm_out
);

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] frequency_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] duty_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg en_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [9:0] o_route_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0] i_msg_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0] o_msg_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [1:0]fire;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire o_drive_in;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire o_free_in;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire i_free_in;

//defines-------------------------------------------------
`define pwm1_start 9'h031
`define pwm1_set_fre 9'h032
`define pwm1_set_duty 9'h033
`define pwm1_get_fre 9'h134
`define pwm1_get_duty 9'h135
`define pwm1_stop 9'h036
`define pwm2cpu_route 10'b1000100000

//cfifo1
cFifo1_pwm pwm_fifo1(
    .i_drive(i_drive),
    .i_freeNext(i_free_in),
    .rst(rst),
    .o_free(o_free),
    .o_driveNext(o_drive_in),
    .o_fire_1(fire[0])
);
cFifo1_pwm pwm_fifo2(
    .i_drive(o_drive_in),
    .i_freeNext(i_free),
    .rst(rst),
    .o_free(i_free_in),
    .o_driveNext(o_drive),
    .o_fire_1(fire[1])
);

//imsgreg
always @(posedge fire[0] or negedge rst)
begin
    if(!rst)
	begin
		i_msg_reg <= 51'd0;
	end
    else begin
		i_msg_reg <= i_msg;
	end
end

//
always @(posedge fire[1] or negedge rst)
begin
    if(!rst)
    begin
		o_route_reg <= 0;
        duty_reg <= 16'd0;
        frequency_reg <= 16'd0;
        en_reg <= 0;
        o_msg_reg <= 51'd0;
    end
    else
    begin
        case(i_msg_reg[50:42])
        `pwm1_start:
        begin
            duty_reg <= i_msg_reg[41:26];
            frequency_reg <= i_msg_reg[25:10];
            en_reg <= 1;
			o_route_reg <= `pwm2cpu_route;
            o_msg_reg <= {`pwm1_start, 32'b0,`pwm2cpu_route};
        end
        `pwm1_set_fre:
        begin
            frequency_reg <= i_msg_reg[25:10];
            en_reg <= 1;
			o_route_reg <= `pwm2cpu_route;
            o_msg_reg <= {`pwm1_set_fre, 32'b0,o_route_reg[9:0]};
        end
        `pwm1_set_duty:
        begin
            duty_reg <= i_msg_reg[41:26];
            en_reg <= 1;
			o_route_reg <= `pwm2cpu_route;
            o_msg_reg <= {`pwm1_set_duty, 32'b0,o_route_reg[9:0]};
        end
        `pwm1_get_fre:
        begin
			o_route_reg <= `pwm2cpu_route;
            o_msg_reg <= {`pwm1_get_fre, duty_reg[15:0], frequency_reg[15:0],o_route_reg[9:0]};
        end
        `pwm1_get_duty:
        begin
			o_route_reg <= `pwm2cpu_route;
            o_msg_reg <= {`pwm1_get_duty, duty_reg[15:0], frequency_reg[15:0],o_route_reg[9:0]};
        end
        `pwm1_stop:
        begin
			o_route_reg <= `pwm2cpu_route;
            duty_reg <= 16'd0;
            frequency_reg <= 16'd0;
            en_reg <= 0;    //key step
            o_msg_reg <= {`pwm1_stop, 32'b0,o_route_reg[9:0]};
        end
		default:
		begin
			o_route_reg <= 0;
        	duty_reg <= 16'd0;
        	frequency_reg <= 16'd0;
        	en_reg <= 0;
        	o_msg_reg <= {`pwm1_stop, 32'b0,o_route_reg[9:0]};
    	end
    endcase
    end
end
assign o_msg = o_msg_reg;
pwm pwm_module(
     .clk(clk),           // ����ʱ���ź�
     .rst(rst_finish),         // ��λ�ź�
     .duty(duty_reg),    // 15λռ�ձ�����
     .frequency(frequency_reg),   //pwmƵ��:����period������period = ����ʱ��Ƶ�� / ����pwmƵ�� 
     .en(en_reg),
     .pwm_out(pwm_out)        // PWM����ź�
    );

endmodule
