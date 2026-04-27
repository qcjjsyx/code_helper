//-----------------------------------------------
//    module name: ROM
//    author: lu.yihua
//    modified: 
//    version: 1st version (2024-10-01)
//    description: use register as ROM for init the mem
//
//-----------------------------------------------
`timescale 1ns / 1ps

module ROM(                     
    input clk,
    input rst,                      
    input wire [11:0] i_addr,    
    output wire [63:0] o_data //数据位宽是一行    
);
    //这里为了对齐64Bit一行的存储
    wire [8:0] addr_t = i_addr[11:3];
    wire [9:0] addr = {addr_t,1'b0};

    //这里地址位宽用12为了上层和icache统一，实际ROM只需要96个
    reg [31:0] rom_mem [0:96];

    // ROM 初始化：复位时装载数据
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rom_mem[0]  = 32'h0094f241;
            rom_mem[1]  = 32'h22017801;
            rom_mem[2]  = 32'h29004011;
            rom_mem[3]  = 32'hf241d13d;
            rom_mem[4]  = 32'h21800000;
            rom_mem[5]  = 32'h210d70c1;
            rom_mem[6]  = 32'h21007001;
            rom_mem[7]  = 32'h70c17041;
            rom_mem[8]  = 32'h70c12103;
            rom_mem[9]  = 32'h70412101;
            rom_mem[10] = 32'h2200f241;
            rom_mem[11] = 32'hf806f000;
            rom_mem[12] = 32'h2212f240;
            rom_mem[13] = 32'hf0000212;
            rom_mem[14] = 32'he03ff801;
            rom_mem[15] = 32'h26042500;
            rom_mem[16] = 32'h29047881;
            rom_mem[17] = 32'h7941d1fc;
            rom_mem[18] = 32'hd1fc2961;
            rom_mem[19] = 32'h23ff7801;
            rom_mem[20] = 32'h022d4019;
            rom_mem[21] = 32'h3e01430d;
            rom_mem[22] = 32'hd1f12e00;
            rom_mem[23] = 32'h25001c2b;
            rom_mem[24] = 32'h78812604;
            rom_mem[25] = 32'hd1fc2904;
            rom_mem[26] = 32'h29617941;
            rom_mem[27] = 32'h7801d1fc;
            rom_mem[28] = 32'h402124ff;
            rom_mem[29] = 32'h430d022d;
            rom_mem[30] = 32'h2e003e01;
            rom_mem[31] = 32'h6015d1f1;
            rom_mem[32] = 32'h3b013204;
            rom_mem[33] = 32'hd1ea2b00;
            rom_mem[34] = 32'hf2414770;
            rom_mem[35] = 32'hf0002100;
            rom_mem[36] = 32'hf240f824;
            rom_mem[37] = 32'h02092112;
            rom_mem[38] = 32'hf840f000;
            rom_mem[39] = 32'h700222e7;
            rom_mem[40] = 32'h1222f241;
            rom_mem[41] = 32'hf2440412;
            rom_mem[42] = 32'h18d24388;
            rom_mem[43] = 32'h78426042;
            rom_mem[44] = 32'h40322690;
            rom_mem[45] = 32'hd1fa2a90;
            rom_mem[46] = 32'he7ff6885;
            rom_mem[47] = 32'h4012f240;
            rom_mem[48] = 32'h21000200;
            rom_mem[49] = 32'hf2402200;
            rom_mem[50] = 32'he8e04300;
            rom_mem[51] = 32'h3b011202;
            rom_mem[52] = 32'hd1fa2b00;
            rom_mem[53] = 32'h2000f241;
            rom_mem[54] = 32'hf2414700;
            rom_mem[55] = 32'h22070060;
            rom_mem[56] = 32'hf2407002;
            rom_mem[57] = 32'h04125200;
            rom_mem[58] = 32'h0201f202;
            rom_mem[59] = 32'h78426042;
            rom_mem[60] = 32'h40322690;
            rom_mem[61] = 32'hd1fa2a90;
            rom_mem[62] = 32'h78426885;
            rom_mem[63] = 32'h40322620;
            rom_mem[64] = 32'hd1ee2a00;
            rom_mem[65] = 32'h3200f240;
            rom_mem[66] = 32'hf2020412;
            rom_mem[67] = 32'h60420200;
            rom_mem[68] = 32'h26907842;
            rom_mem[69] = 32'h2a904032;
            rom_mem[70] = 32'h6885d1fa;
            rom_mem[71] = 32'h1222f241;
            rom_mem[72] = 32'hf2440412;
            rom_mem[73] = 32'h18d24388;
            rom_mem[74] = 32'h78426042;
            rom_mem[75] = 32'h40322690;
            rom_mem[76] = 32'hd1fa2a90;
            rom_mem[77] = 32'h1c2c6885;
            rom_mem[78] = 32'h1222f241;
            rom_mem[79] = 32'hf2440412;
            rom_mem[80] = 32'h18d24388;
            rom_mem[81] = 32'h78426042;
            rom_mem[82] = 32'h40322690;
            rom_mem[83] = 32'hd1fa2a90;
            rom_mem[84] = 32'h600d6885;
            rom_mem[85] = 32'h3c013104;
            rom_mem[86] = 32'hd1ed2c00;            
            rom_mem[87] = 32'h00004770;
            rom_mem[88] = 32'h00000000;
        end
    end
    
    assign o_data = {rom_mem[addr+10'd1],rom_mem[addr]};
    
endmodule

