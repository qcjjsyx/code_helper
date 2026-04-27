`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 13:39:59
// Design Name: 
// Module Name: OVR_state
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/11 20:41:17
// Design Name: 
// Module Name: state
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


module state0(
input   clk,
input   rst_n,
input   S1,
input   S2,
input   S3,
output  reg   stateout

);
reg [1:0] state,n_state;
reg S3buf;
reg S3rise;
parameter SET = 2'b00;
parameter WAIT = 2'b01;
parameter RESET = 2'b10;

always @(posedge clk or negedge rst_n)//…œ…˝—ÿºÏ≤‚
begin
    if(!rst_n) begin
        S3buf <= 1'b0;
        S3rise <= 1'b0;
    end
    else begin
        S3buf <= S3;
        S3rise <= (~S3buf) & S3;
    end
end

always@(posedge clk or negedge rst_n) begin
        if(!rst_n) state <= RESET;
        else state <= n_state;
end

always@( S1 or  S2 or  S3rise or rst_n)
begin
    if(!rst_n)
    n_state = RESET;
    else case(state)
        SET:
            if(S1) n_state = WAIT;
            else n_state = SET;
        WAIT:
            if(S2) n_state = RESET;
            else n_state = WAIT;
        RESET:
            if(S3rise) n_state = SET;
            else n_state = RESET;
        default: 
            n_state = RESET;
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        stateout <= 1'b0;
    end
    else begin
    case(state)
        SET:
            begin
                stateout <= 1'b1;
            end
        WAIT:
            begin              
                stateout <= stateout;  
            end
        RESET:
            begin 
                stateout <= 1'b0;  
            end
        default:
            begin             
                stateout <= 1'b0;  
            end     
    endcase
    end
end         
endmodule
