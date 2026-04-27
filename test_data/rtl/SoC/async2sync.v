`timescale 1ns / 1ps
module async2sync(
	input clk,
        input rst_async_n,
        output rst_sync_n

);

reg rst_s1,rst_s2;
always @ (posedge clk, negedge rst_async_n)  
if (!rst_async_n) begin   
	rst_s1 <= 1'b0;  
	rst_s2 <= 1'b0;  
end  
else begin  
	rst_s1 <= 1'b1;  
	rst_s2 <= rst_s1;  
end  
 
assign rst_sync_n = rst_s2;   

endmodule
