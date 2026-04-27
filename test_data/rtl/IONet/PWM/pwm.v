`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jiang Yilong
// 
// Create Date: 2024/09/12 11:03:19
// Design Name: 
// Module Name: pwm
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


module pwm(
     input wire clk,           // ����ʱ���ź�
     input wire rst,         // ��λ�ź�
     input wire en,
     input wire [15:0] duty,    // 31λռ�ձ�����
     input wire [15:0] frequency,   //pwmƵ��:����period������period = ����ʱ��Ƶ�� / ����pwmƵ�� 
     output reg pwm_out        // PWM����ź�
    );
    (*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] counter;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] duty_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [15:0] fre_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg en_reg;

	always @(posedge clk or negedge rst)
    begin
		if(!rst)
		begin
		duty_reg <= 16'h0000;
		fre_reg <= 16'h0000;
		en_reg <= 1'b0;
		end
		else 
		begin 
		duty_reg <= duty;
		fre_reg <= frequency - 1'b1;
		en_reg <= en;
		end
	end
    //��һ��pwm�����ڵ���ʱ
    always @(posedge clk or negedge rst)
    begin
        if (!rst) 
        begin
            counter <= 16'h0000;  // ��λ������
			
        end
        else if(counter<fre_reg && en_reg)
            counter <= counter + 1'b1; 
        else
            counter <= 16'b0000;    
     end
        
    
     // ÿ��ʱ�����ڸ��¼�������PWM���,ռ�ձȼ���
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pwm_out <= 1'b0;  // ��λPWM���
        end
        else begin
            if (counter < duty_reg && en_reg)         // ���������С��ռ�ձȣ�������ߵ�ƽ
                pwm_out <= 1'b1;
            else                        // ��������͵�ƽ
                pwm_out <= 1'b0;
        end
    end
    
endmodule
