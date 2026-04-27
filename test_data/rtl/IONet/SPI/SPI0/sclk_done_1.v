module sclk_done_1(
input clk,
input sclk_cnt_5,
output sclk_done
);
reg sclk_cnt_buf;
always @(posedge clk)
begin
    sclk_cnt_buf <= sclk_cnt_5;
end
assign sclk_done = (~sclk_cnt_5) & sclk_cnt_buf;
endmodule
