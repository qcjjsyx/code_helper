//-----------------------------------------------
//    module name: routeMsg 
//    author: Anping HE (heap@lzu.edu.cn)
//  modifier: Fu Tong , Baoxia Wan , Mingshu Chen ,Kang Li Zhao
//    version: 2st version (2021-11-17)
//    description: 
//        routing message 
//        have a lock mechanism that supports any cases
//-----------------------------------------------

`timescale 1ns / 1ps

module routeMsg (
    rst,
    i_drive,      o_free,      i_msg_51,
    o_driveWArb,  i_freeWArb,  o_westMsg_51,
    o_driveEArb,  i_freeEArb,  o_eastMsg_51,
    o_driveNArb,  i_freeNArb,  o_northMsg_51,
    o_driveSArb,  i_freeSArb,  o_southMsg_51,
    o_driveLArb,  i_freeLArb,  o_localMsg_51
);

input         rst;
input         i_drive;
input         i_freeWArb;
input         i_freeEArb;
input         i_freeNArb;
input         i_freeSArb;
input         i_freeLArb;
(*dont_touch = "yes"*)input  [50:0] i_msg_51;

output        o_free;
output        o_driveWArb;
output        o_driveEArb;
output        o_driveNArb;
output        o_driveSArb;
output        o_driveLArb;
(*dont_touch = "yes"*)output [50:0] o_westMsg_51;
(*dont_touch = "yes"*)output [50:0] o_eastMsg_51;
(*dont_touch = "yes"*)output [50:0] o_northMsg_51;
(*dont_touch = "yes"*)output [50:0] o_southMsg_51;
(*dont_touch = "yes"*)output [50:0] o_localMsg_51;



(*dont_touch = "yes"*)(* mark_debug = "true" *)wire [50:0] w_eastTmpMsg_51;
(*dont_touch = "yes"*)wire [50:0] w_westTmpMsg_51;
(*dont_touch = "yes"*)wire [50:0] w_southTmpMsg_51;
(*dont_touch = "yes"*)wire [50:0] w_northTmpMsg_51;

wire [50:0] w_westMsg_51;     
wire [50:0] w_eastMsg_51;       
wire [50:0] w_northMsg_51;     
wire [50:0] w_southMsg_51;   

(*dont_touch = "yes"*)wire w_localVld;
(*dont_touch = "yes"*)wire w_westVld;     
(*dont_touch = "yes"*)wire w_eastVld;     
(*dont_touch = "yes"*)wire w_northVld;   
(*dont_touch = "yes"*)wire w_southVldNS;   
(*dont_touch = "yes"*)wire w_southVld;   
(*dont_touch = "yes"*)wire w_northVldSN;   

   
wire [50:0] w_localMsg_51;   

reg [50:0] r_localMsg_51;
reg [50:0] r_westMsg_51;
reg [50:0] r_eastMsg_51;
reg [50:0] r_northMsg_51;
reg [50:0] r_southMsg_51;


(*dont_touch = "yes"*)wire        w_driveFork;
(*dont_touch = "yes"*)wire        w_freeFork;
(*dont_touch = "yes"*)wire        w_fire0;
(*dont_touch = "yes"*)wire [50:0] w_msg_51;
(*dont_touch = "yes"*)wire        w_driveWFifo;
(*dont_touch = "yes"*)wire        w_freeWFifo;
(*dont_touch = "yes"*)wire        w_driveEFifo;
(*dont_touch = "yes"*)wire        w_freeEFifo;
(*dont_touch = "yes"*)wire        w_driveNFifo;
(*dont_touch = "yes"*)wire        w_freeNFifo;
(*dont_touch = "yes"*)wire        w_driveSFifo;
(*dont_touch = "yes"*)wire        w_freeSFifo;
(*dont_touch = "yes"*)wire        w_driveLFifo;
(*dont_touch = "yes"*)wire        w_freeLFifo;
(*dont_touch = "yes"*)wire        w_fire1;
(*dont_touch = "yes"*)wire        w_fire2;
(*dont_touch = "yes"*)wire        w_fire3;
(*dont_touch = "yes"*)wire        w_fire4;
(*dont_touch = "yes"*)wire        w_fire5;
(*dont_touch = "yes"*)wire        w_fire6;

wire [50:0] w_forkMsg_51;
wire [3:0]  w_distance0_4;
wire [3:0]  w_distance1_4;
wire [3:0]  w_distance2_4;
wire [3:0]  w_distance3_4;
wire [50:0] w_wMsg_51;
wire [50:0] w_eMsg_51;
wire [50:0] w_nMsg_51;
wire [50:0] w_sMsg_51;
wire [50:0] w_lMsg_51;


(*dont_touch = "yes"*)reg  [50:0] r_msg_51;
(*dont_touch = "yes"*)reg  [50:0] r_forkMsg_51;
(*dont_touch = "yes"*)reg  [50:0] r_wMsg_51;
(*dont_touch = "yes"*)reg  [50:0] r_eMsg_51;
(*dont_touch = "yes"*)reg  [50:0] r_nMsg_51;
(*dont_touch = "yes"*)reg  [50:0] r_sMsg_51;
(*dont_touch = "yes"*)reg  [50:0] r_lMsg_51;


//receiving input data
cFifo1 receiveFifo (
    .i_drive        (i_drive        ),
    .i_freeNext     (w_freeFork     ),
    .rst            (rst            ),
    .o_free         (o_free         ),
    .o_driveNext    (w_driveFork    ),
    .o_fire_1       (w_fire0        )
);

(*dont_touch = "yes"*)wire w_driveFork_delay;
(*dont_touch = "yes"*)delay8U delayUart0 (.inR(w_driveFork), .outR(w_driveFork_delay),.rst(rst));

always @(posedge w_fire0 or negedge rst) begin
    if(!rst)    begin
        r_msg_51 <= 51'b0;
    end
    else begin
        r_msg_51 <= i_msg_51;
    end
end
assign w_msg_51 = r_msg_51;

//---------------------------------------------------------
//calculate the direction
//    first check local, east->west and west->east parallelly, 
//        (not involved) get local msg, or
//        get east or west message, or
//        get south_north message (possibly be zero);
//    then if south_north message not be zero,
//        check south->north and north->south parallely,
//        get south or north message
//    e.g., the priority is:
//        {east, west} > {south, north} > {local}
(*dont_touch = "yes"*)(* mark_debug = "true" *)wire r_9;
//inv v0(w_msg_51[9],r_9);
assign r_9 = ~w_msg_51[9];
(*dont_touch = "yes"*)(* mark_debug = "true" *)wire r_4;
//inv v1(r_msg_51[4],r_4);
assign r_4 = ~w_msg_51[4];
//get east->west info
assign w_eastTmpMsg_51 = (r_9 == 0) ? w_msg_51 : 51'b0;     //���Զ��ߵ�����

routeMsgEW eastToWest (                                     //�ɶ���������
    .i_coord_4      (w_eastTmpMsg_51[8:5]   ),
    .o_msgVld       (w_westVld              ) 
);

//get west->east info
assign w_westTmpMsg_51 = (r_9==1) ? w_msg_51 : 51'b0;        //�������ߵ�����

routeMsgEW westToEast(                                       //�����򶫴���
    .i_coord_4      (w_westTmpMsg_51[8:5]   ),
    .o_msgVld       (w_eastVld            ) 
);

//get south->north info
assign w_southTmpMsg_51 = (r_4==1)? w_msg_51 : 51'b0;         //�����ϱߵ�����

routeMsgSN southToNorth(                                      //�����򱱴���
    .i_coord_4      (w_southTmpMsg_51[3:0]  ),
    .o_msgVld       (w_northVldSN         ) 
);
assign w_northVld = w_northVldSN & ~(w_eastVld | w_westVld);     //


//get north->south info
assign    w_northTmpMsg_51 = (r_4==0) ? w_msg_51 : 51'b0;       //���Ա��ߵ�����

routeMsgSN northToSouth(                                        //�ɱ����ϴ���
    .i_coord_4      (w_northTmpMsg_51[3:0]  ),
    .o_msgVld       (w_southVldNS         ) 
);

assign w_southVld = w_southVldNS & ~(w_eastVld | w_westVld);     //

//get local info

assign w_localVld = 
    ~(w_westVld | 
    w_eastVld | 
    w_southVld | 
    w_northVld);    

    wire w_driveWFifo_t;
    wire w_driveEFifo_t;
    wire w_driveNFifo_t;
    wire w_driveSFifo_t;
    wire w_driveLFifo_t;

//according to valid to choosing a direction
(*dont_touch = "yes"*)cCondFork5 dirFork (
    .i_drive         (w_driveFork_delay    ),
    .i_freeNext0     (w_freeWFifo    ),
    .i_freeNext1     (w_freeEFifo    ),
    .i_freeNext2     (w_freeNFifo    ),
    .i_freeNext3     (w_freeSFifo    ),
    .i_freeNext4     (w_freeLFifo    ),
    .valid0          (w_westVld      ),
    .valid1          (w_eastVld      ),
    .valid2          (w_northVld     ),
    .valid3          (w_southVld     ),
    .valid4          (w_localVld     ),
    .o_fire          (w_fire1        ),
    .rst             (rst            ),
    .o_free          (w_freeFork     ),
    .o_driveNext0    (w_driveWFifo_t ),
    .o_driveNext1    (w_driveEFifo_t ),
    .o_driveNext2    (w_driveNFifo_t ),
    .o_driveNext3    (w_driveSFifo_t ),
    .o_driveNext4    (w_driveLFifo_t )
);
delay6U delayW (.inR(w_driveWFifo_t), .outR(w_driveWFifo), .rst(rst));  
delay6U delayE (.inR(w_driveEFifo_t), .outR(w_driveEFifo), .rst(rst));  
delay6U delayN (.inR(w_driveNFifo_t), .outR(w_driveNFifo), .rst(rst));  
delay6U delayS (.inR(w_driveSFifo_t), .outR(w_driveSFifo), .rst(rst));  
delay6U delayL (.inR(w_driveLFifo_t), .outR(w_driveLFifo), .rst(rst));    

always @(posedge w_fire1 or negedge rst) begin
    if(!rst) begin
        r_forkMsg_51 <= 51'b0;
    end
    else begin
        r_forkMsg_51 <= w_msg_51;
    end
end
assign w_forkMsg_51 = r_forkMsg_51;

//west Send
subtr4b westSubtr (
    .a(w_forkMsg_51[8:5]),
    .b(4'b0001),
    .differ(w_distance0_4)
);
assign w_wMsg_51 = {w_forkMsg_51[50:9], w_distance0_4, w_forkMsg_51[4:0]};

cFifo1 westSendFifo (
    .i_drive        (w_driveWFifo   ),
    .i_freeNext     (i_freeWArb     ),
    .rst            (rst            ),
    .o_free         (w_freeWFifo    ),
    .o_driveNext    (o_driveWArb    ),
    .o_fire_1       (w_fire2        )
);

always @(posedge w_fire2 or negedge rst) begin
    if(!rst) begin
        r_wMsg_51 <= 51'b0;
    end
    else begin
        r_wMsg_51 <= w_wMsg_51;
    end
end

//east send
subtr4b eastSubtr (
    .a(w_forkMsg_51[8:5]),
    .b(4'b0001),
    .differ(w_distance1_4)
);
assign w_eMsg_51 = {w_forkMsg_51[50:9], w_distance1_4, w_forkMsg_51[4:0]};

cFifo1 eastSendFifo (
    .i_drive        (w_driveEFifo   ),
    .i_freeNext     (i_freeEArb     ),
    .rst            (rst            ),
    .o_free         (w_freeEFifo    ),
    .o_driveNext    (o_driveEArb    ),
    .o_fire_1       (w_fire3        )
);

always @(posedge w_fire3 or negedge rst) begin
    if(!rst) begin
        r_eMsg_51 <= 51'b0;
    end
    else begin
        r_eMsg_51 <= w_eMsg_51;
    end
end

//north send
subtr4b northSubtr (
    .a(w_forkMsg_51[3:0]),
    .b(4'b0001),
    .differ(w_distance2_4)
);
assign w_nMsg_51 = {w_forkMsg_51[50:4], w_distance2_4};

cFifo1 northSendFifo (
    .i_drive        (w_driveNFifo   ),
    .i_freeNext     (i_freeNArb     ),
    .rst            (rst            ),
    .o_free         (w_freeNFifo    ),
    .o_driveNext    (o_driveNArb    ),
    .o_fire_1       (w_fire4        )
);

always @(posedge w_fire4 or negedge rst) begin
    if(!rst) begin
        r_nMsg_51 <= 51'b0;
    end
    else begin
        r_nMsg_51 <= w_nMsg_51;
    end
end

//south send
subtr4b southSubtr (
    .a(w_forkMsg_51[3:0]),
    .b(4'b0001),
    .differ(w_distance3_4)
);
assign w_sMsg_51 = {w_forkMsg_51[50:4], w_distance3_4};

cFifo1 southSendFifo (
    .i_drive        (w_driveSFifo   ),
    .i_freeNext     (i_freeSArb     ),
    .rst            (rst            ),
    .o_free         (w_freeSFifo    ),
    .o_driveNext    (o_driveSArb    ),
    .o_fire_1       (w_fire5        )
);

always @(posedge w_fire5 or negedge rst) begin
    if(!rst) begin
        r_sMsg_51 <= 51'b0;
    end
    else begin
        r_sMsg_51 <= w_sMsg_51;
    end
end

//local send
//local not subtract,send directly
assign w_lMsg_51 = {w_forkMsg_51[50:10], 10'b0};

cFifo1 localSendFifo (
    .i_drive        (w_driveLFifo   ),
    .i_freeNext     (i_freeLArb     ),
    .rst            (rst            ),
    .o_free         (w_freeLFifo    ),
    .o_driveNext    (o_driveLArb    ),
    .o_fire_1       (w_fire6        )
);

always @(posedge w_fire6 or negedge rst) begin
    if(!rst) begin
        r_lMsg_51 <= 51'b0;
    end
    else begin
        r_lMsg_51 <= w_lMsg_51;
    end
end



assign o_westMsg_51  = r_wMsg_51; 
assign o_localMsg_51 = r_lMsg_51;
assign o_eastMsg_51  = r_eMsg_51;
assign o_northMsg_51 = r_nMsg_51;
assign o_southMsg_51 = r_sMsg_51;



endmodule
