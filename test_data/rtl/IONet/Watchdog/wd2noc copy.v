`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jiang Yilong
// 
// Create Date: 2024/09/04 09:51:01
// Design Name: 
// Module Name: wd2noc
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

module wd2noc (
//inputs from mesh
input wire i_drive,
input wire [50:0] i_msg,
//[49:42] 8bits address to control wd mode, see defines
//[50:49] 1bit write enable have to be set as true
//[41:10] 32bit data
//[10:0] route data
input wire Noc_RES,
input wire rst_finish,
input wire i_free,

//watchdog clock
input wire wd_clk,

//outputs 2 mesh
output wire o_free,
output wire o_drive,
output wire [50:0] o_msg,
output wire o_RES,
output wire o_INT);

//defines------------------------------------------------------------------------
`include "./cmsdk_apb_watchdog_defs.v"
`define WD_START 9'h081  //start the watchdog
`define WD_SET_TIMER 9'h082 //set the count down
`define WD_CLEAR_INT 9'h083  //clear interupt
`define WD_CLEAR_RES 9'h084  //clear reset and interupt
`define WD_OFF 9'h085    //turn off the watchdog
//------------------------------------------------------------------------------

//internal signal---------------------------------------------------------------------
//internal signal connecting to watchdog
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire         pclk;        // APB clock

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg         penable;     // APB enable
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg         psel;        // APB periph select
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg  [11:2]  paddr;       // APB address bus
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg         pwrite;      // APB write
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [31:0]  pwdata;      // APB write data

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg         wdogclken;   // Watchdog clock enable
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg         wdogresn;    // Watchdog clock reset

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg  [3:0]  ecorevnum;   // ECO revision number

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire [31:0]  prdata;      // APB read data
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire         wdogint;     // Watchdog interrupt
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire         wdogres;    // Watchdog timeout reset
//internal signal 
//cfifo3
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire    [6:0]   fire;    //fire from cfifo2
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire    fifo_end;    //last cfifo2
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)wire    [5:0] o_driveNext,i_freeNext;    //wire between cfifo2
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg      [2:0]counter;

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0]i_msg_reg;    
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg [50:0]o_msg_reg;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg o_res_sync1;
(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)reg o_res_sync2;
  
//-------------------------------------------------------------------------------------
//cfifo
cFifo1_pwm fifo0(
	.rst(Noc_RES),
    // From Last
   .i_drive(i_drive), 
    .o_free(o_free), 
    // To Next
    .o_driveNext(o_driveNext[0]),
    .i_freeNext(i_freeNext[0]),
	.o_fire_1(fire[0])
	);
cFifo1_pwm fifo1(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[0]),
    .o_free(i_freeNext[0]),
    //to next
    .o_driveNext(o_driveNext[1]),
    .i_freeNext(i_freeNext[1]),
    //fire
    .o_fire_1(fire[1])
);
cFifo1_pwm fifo2(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[1]),
    .o_free(i_freeNext[1]),
    //to next
    .o_driveNext(o_driveNext[2]),
    .i_freeNext(i_freeNext[2]),
    //fire
    .o_fire_1(fire[2])
);
cFifo1_pwm fifo3(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[2]),
    .o_free(i_freeNext[2]),
    //to next
    .o_driveNext(o_driveNext[3]),
    .i_freeNext(i_freeNext[3]),
    //fire
    .o_fire_1(fire[3])
);
cFifo1_pwm fifo4(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[3]),
    .o_free(i_freeNext[3]),
    //to next
    .o_driveNext(o_driveNext[4]),
    .i_freeNext(i_freeNext[4]),
    //fire
    .o_fire_1(fire[4])
);
cFifo1_pwm fifo5(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[4]),
    .o_free(i_freeNext[4]),
    //to next
    .o_driveNext(o_driveNext[5]),
    .i_freeNext(i_freeNext[5]),
    //fire
    .o_fire_1(fire[5])
);
cFifo1_pwm fifo6(
    .rst(Noc_RES),
    //from prior
    .i_drive(o_driveNext[5]),
    .o_free(i_freeNext[5]),
    //to next
    .o_driveNext(o_drive),
    .i_freeNext(i_free),
    //fire
    .o_fire_1(fire[6])
);

assign pclk=fire[1]||fire[2]||fire[3]||fire[4]||fire[5]||fire[6];
always @ (posedge fire[0] or negedge Noc_RES)
begin
	if(!Noc_RES)
	begin
	i_msg_reg <= 51'b0;
	end
	else begin
	i_msg_reg <= i_msg[50:0];
	end
end
	

//set universal values
always @ (posedge pclk or negedge Noc_RES)
    begin
        if(!Noc_RES)
        begin
            penable <= 0;
            psel <= 0;
            paddr <= 10'b0000000000;
            pwrite <= 0;
            pwdata <= 32'h0000_0000;
            wdogclken <= 0;
            wdogresn <= 0;    
            ecorevnum <= 0;
	    	counter<=3'b000;
            o_msg_reg <= {9'b0,32'b0,10'b0000000000};
        end
        //01 start the wd
        else begin
        case(i_msg_reg[50:42])
         `WD_START:
        begin
              case(counter)
                    3'b000:     
                        begin
                        wdogclken <= 1;
                        wdogresn <= 1;
                        psel <= 1;
                        pwrite <= 1;
                        penable <= 0;
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCONTROLA};
                        pwdata <= 32'h00000003;
                        counter <= counter+1'b1;
                        end
                    3'b001:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCONTROLA};
                        counter <= counter+1'b1;
                    end
                    3'b010:
                    begin
                         paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                         pwdata <= i_msg_reg[41:10];
                         o_msg_reg <= {`WD_START,32'b0,10'b1000100000};
                         counter <= counter+1'b1;
                    end
                    3'b011:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGLOADA};
                        counter <= counter+1'b1;
                    end
                    3'b100:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                        counter <= counter+1'b1;
                    end
                    3'b101:
                    begin
                        counter <= 3'b000;
                    end
		    		default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
	    			counter<=3'b000;
                    o_msg_reg <= {`WD_START,32'b0,10'b1000100000};
					end
                   endcase
            end
            //02 set count down
             `WD_SET_TIMER:
            begin
            	case(counter)
                    3'b000:     
                        begin
                        wdogclken <= 1;
                        wdogresn <= 1;
                        psel <= 1;
                        pwrite <= 1;
                        penable <= 0;
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                        pwdata <= i_msg_reg[41:10];
                        counter <= counter+1'b1;
                        end
                    3'b001:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGLOADA};
                        counter <= counter+1'b1;
                    end
                    3'b010:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                         o_msg_reg <= {`WD_SET_TIMER,32'b0,10'b1000100000};
                         counter <= counter+1'b1;
                    end
                    3'b011:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGLOADA};
                        counter <= counter+1'b1;
                    end
                    3'b100:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                        counter <= counter+1'b1;
                    end
                    3'b101:
                    begin
                        counter <= 3'b000;
                    end
					default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
	    			counter<=3'b000;
                    o_msg_reg <= {`WD_SET_TIMER,32'b0,10'b1000100000};
					end
                   endcase
            end
			//03 clear int 
             `WD_CLEAR_INT:
            begin
                case(counter)
                    3'b000:     
                        begin
                        wdogclken <= 1;
                        wdogresn <= 1;
                        psel <= 1;
                        pwrite <= 1;
                        penable <= 0;
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCLEARA};
                        pwdata <= i_msg_reg[41:10];
                        counter <= counter+1'b1;
                        end
                    3'b001:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCLEARA};
                        counter <= counter+1'b1;
                    end
                    3'b010:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCLEARA};
                        counter <= counter+1'b1;
                    end
                    3'b011:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCLEARA};
                        counter <= counter+1'b1;
                   end
                   3'b100:
                   begin 
                        o_msg_reg <= {`WD_CLEAR_INT,32'b0,10'b1000100000};
                        counter <= counter+1'b1;
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                        counter <= counter+1'b1;
                   end
                   3'b101:
                   begin
                       counter <= 3'b000;
                   end
					default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
	    			counter<=3'b000;
                    o_msg_reg <= {`WD_CLEAR_INT,32'b0,10'b1000100000};
					end
                 endcase
            end
			//04 clear res
           `WD_CLEAR_RES:
            begin
            case(counter)
                    3'b000:     
                        begin
                        wdogclken <= 1;
                        wdogresn <= 1;
                        psel <= 1;
                        pwrite <= 1;
                        penable <= 0;
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCLEARA};
                        pwdata <= i_msg_reg[41:10];
                        counter <= counter+1'b1;
                        end
                    3'b001:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGLOADA};
                        wdogresn <= 1;
                        counter <= counter+1'b1;
                    end
                    3'b010:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                        counter <= counter+1'b1;
                    end
                    3'b011:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGLOADA};
                        wdogresn <=  0;
                        counter <= counter+1'b1;
                   end
                   3'b100:
                   begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGVALUEA};
                       o_msg_reg <= {`WD_CLEAR_RES,32'b0,10'b1000100000};
                       counter <= counter+1'b1;
                    end
                    3'b101:
                    begin
                        counter <= 3'b000;
                    end
					default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
                    o_msg_reg <= {`WD_CLEAR_RES,32'b0,10'b1000100000};
	    			counter<=3'b000;
					end
               endcase
            end
			//05 off
           `WD_OFF:
            begin
                 case(counter)
                    // 3'b000:     
                    //     begin
                    //     wdogclken <= 1;
                    //     wdogresn <= 1;
                    //     psel <= 1;
                    //     pwrite <= 1;
                    //     penable <= 0;
                    //     pwdata <= 32'h00000003;
                    //     counter <= counter+1'b1;
                    //     end
                    3'b000:
                    begin
                        paddr <= {`ARM_WDOG1A,`ARM_WDOGCONTROLA};
                        counter <= counter+1'b1;
                    end
                    3'b001:
                       begin
                         penable <= 0;
                         psel <= 0;
                         paddr <= 10'b0000000000;
                         pwrite <= 0;
                         pwdata <= 32'h0000_0000;
                         wdogclken <= 0;
                         wdogresn <= 0;    
                         ecorevnum <= 0;
                         o_msg_reg <= {`WD_OFF,32'b0,10'b1000100000};
                         counter <= counter+1'b1;
                       end
                    3'b010:
                       begin
                            counter <= counter+1'b1;
                       end
                    3'b011:
                       begin
                           counter <= counter+1'b1;
                       end
                    3'b100:
                       begin
                           counter <= counter+1'b1;
                       end
                    3'b101:
                       begin
                           counter <= 3'b000;
                       end
					default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
                    o_msg_reg <= {`WD_OFF,32'b0,10'b1000100000};
	    			counter<=3'b000;
					end
                   endcase
            end
			default:
		    		begin
            		penable <= 0;
            		psel <= 0;
            		paddr <= 10'b0000000000;
            		pwrite <= 0;
            		pwdata <= 32'h0000_0000;
           			wdogclken <= 0;
            		wdogresn <= 0;    
            		ecorevnum <= 0;
                    o_msg_reg <= {`WD_OFF,32'b0,10'b1000100000};
	    			counter<=3'b000;
					end
            endcase
            end
    end
    assign o_msg = o_msg_reg;

//o_RES 2clk
    always @(posedge wd_clk or negedge Noc_RES) begin
        if (!Noc_RES) begin
            o_res_sync1 <= 0;
            o_res_sync2 <= 0;
        end else begin
            o_res_sync2 <= o_res_sync1;
            o_res_sync1 <= wdogres;
        end
    end

(*KEEP="TRUE"*)(*dont_touch = "yes"*)(*OPTIMIZE="OFF"*)cmsdk_apb_watchdog utt_wd
(
    .PCLK   (pclk),        // APB clock
    .PRESETn    (rst_finish),     // APB reset
    .PENABLE    (penable),     // APB enable
    .PSEL   (psel),        // APB periph select
    .PADDR  (paddr),       // APB address bus
    .PWRITE (pwrite),      // APB write
    .PWDATA (pwdata),      // APB write data
    .WDOGCLK    (wd_clk),     // Watchdog clock
    .WDOGCLKEN  (wdogclken),   // Watchdog clock enable
    .WDOGRESn   (wdogresn),    // Watchdog clock reset
    .ECOREVNUM  (ecorevnum),   // ECO revision number
    .PRDATA (prdata),      // APB read data
    .WDOGINT(wdogint),     // Watchdog interrupt
    .WDOGRES(wdogres)    // Watchdog timeout reset
);
assign o_INT = wdogint;
assign o_RES = ~o_res_sync2;

endmodule
