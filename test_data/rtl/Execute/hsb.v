`timescale 1ns / 1ps
module hsb (
    input [31:0] oprand,
    input rst,
    input notFlag,
    output reg signed [31:0] result
);

    always @(*) begin
        if (!rst) begin
            result = 32'hFFFFFFFF; // Reset to -1
        end else begin
            result = 32'hFFFFFFFF; // ³õÊ¼ÉèÎª-1
            
            if (oprand[31:16] != 0) begin
                if (oprand[31:24] != 0) begin
                    if (oprand[31:28] != 0) begin
                        if (oprand[31:30] != 0) begin
                            if (oprand[31] == 1) result = 31;
                            else result = 30;
                        end else begin
                            if (oprand[29] == 1) result = 29;
                            else result = 28;
                        end
                    end else begin
                        if (oprand[27:26] != 0) begin
                            if (oprand[27] == 1) result = 27;
                            else result = 26;
                        end else begin
                            if (oprand[25] == 1) result = 25;
                            else result = 24;
                        end
                    end
                end else begin
                    if (oprand[23:20] != 0) begin
                        if (oprand[23:22] != 0) begin
                            if (oprand[23] == 1) result = 23;
                            else result = 22;
                        end else begin
                            if (oprand[21] == 1) result = 21;
                            else result = 20;
                        end
                    end else begin
                        if (oprand[19:18] != 0) begin
                            if (oprand[19] == 1) result = 19;
                            else result = 18;
                        end else begin
                            if (oprand[17] == 1) result = 17;
                            else result = 16;
                        end
                    end
                end
            end else begin
                if (oprand[15:8] != 0) begin
                    if (oprand[15:12] != 0) begin
                        if (oprand[15:14] != 0) begin
                            if (oprand[15] == 1) result = 15;
                            else result = 14;
                        end else begin
                            if (oprand[13] == 1) result = 13;
                            else result = 12;
                        end
                    end else begin
                        if (oprand[11:10] != 0) begin
                            if (oprand[11] == 1) result = 11;
                            else result = 10;
                        end else begin
                            if (oprand[9] == 1) result = 9;
                            else result = 8;
                        end
                    end
                end else begin
                    if (oprand[7:4] != 0) begin
                        if (oprand[7:6] != 0) begin
                            if (oprand[7] == 1) result = 7;
                            else result = 6;
                        end else begin
                            if (oprand[5] == 1) result = 5;
                            else result = 4;
                        end
                    end else begin
                        if (oprand[3:2] != 0) begin
                            if (oprand[3] == 1) result = 3;
                            else result = 2;
                        end else begin
                            if (oprand[1] == 1) result = 1;
                            else result = 32'hFFFFFFFF;
                        end
                    end
                end
            end
            
            if (notFlag) begin
                result = ~result;
            end
        end
    end

endmodule
