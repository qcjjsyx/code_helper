`timescale 1ns / 1ps
//fire -> clk sync pluse
module fire2SyncPluse
(
	input  wire        fire,
  input  wire        clk,
	input  wire        rst,	
	input  wire        rst_finish,
	output wire        rise
);

  reg pluse,pluse_level,pluse_level_t,pluse_level_tt;
    always @(posedge fire or negedge rst) begin
		if(!rst) begin
             pluse  <= 1'b0;
		end else begin
             pluse <= ~pluse;
		end
	end

    always@(posedge clk or negedge rst_finish) begin
        if(!rst_finish) begin
             pluse_level  <= 1'b0;
             pluse_level_t <= 1'b0;
             pluse_level_tt <= 1'b0;
		end else begin
             pluse_level_tt <= pluse_level_t;
             pluse_level_t <= pluse_level;
             pluse_level <= pluse;
		end
    end
    assign rise = pluse_level_t ^ pluse_level_tt;

endmodule
