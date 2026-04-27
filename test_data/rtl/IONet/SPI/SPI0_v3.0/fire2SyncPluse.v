`timescale 1ns / 1ps
//fire -> clk sync pluse
module fire2SyncPluse
(
	input  wire        fire,
        input  wire        clk,
	input  wire        rst,
	output wire        rise
);

reg pluse,pluse_level,pluse_level_t;
    always @(posedge fire or negedge rst) begin
		if(!rst) begin
             pluse  <= 1'b0;
		end else begin
             pluse <= ~pluse;
		end
	end

    always@(posedge clk or negedge rst) begin
        if(!rst) begin
             pluse_level  <= 1'b0;
             pluse_level_t <= 1'b0;
		end else begin
             pluse_level_t <= pluse_level;
             pluse_level <= pluse;
		end
    end
    assign rise = pluse_level_t ^ pluse_level;

endmodule
