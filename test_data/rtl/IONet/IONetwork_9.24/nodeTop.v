//-----------------------------------------------
//    module name: nodeTop 
//    author: Anping HE (heap@lzu.edu.cn)
//    version: 1st version (2021-11-13)
//    description: 
//        top module for mesh node
//-----------------------------------------------
`timescale 1ns / 1ps

module nodeTop (
    rst,
    i_driveLocal,       o_freeLocal,        i_localInMsg_51,
    o_driveLocal,       i_freeLocal,        o_localMsg_51,
    i_driveWest,        o_freeWest,         i_westInMsg_51,
    o_driveWest,        i_freeWest,         o_westMsg_51,
    i_driveEast,        o_freeEast,         i_eastInMsg_51,
    o_driveEast,        i_freeEast,         o_eastMsg_51,
    i_driveNorth,       o_freeNorth,        i_northInMsg_51,
    o_driveNorth,       i_freeNorth,        o_northMsg_51,
    i_driveSouth,       o_freeSouth,        i_southInMsg_51,
    o_driveSouth,       i_freeSouth,        o_southMsg_51
);

    

input           rst;
input           i_driveLocal;
input           i_driveWest;
input           i_driveEast;
input           i_driveNorth;
input           i_driveSouth;
input           i_freeLocal;
input           i_freeWest;
input           i_freeEast;
input           i_freeNorth;
input           i_freeSouth;
input   [50:0]  i_localInMsg_51;
input   [50:0]  i_westInMsg_51;
input   [50:0]  i_eastInMsg_51;
input   [50:0]  i_northInMsg_51;
input   [50:0]  i_southInMsg_51;

output          o_driveLocal;
output          o_driveWest;
output          o_driveEast;
output          o_driveNorth;
output          o_driveSouth;
output          o_freeLocal;
output          o_freeWest;
output          o_freeEast;
output          o_freeNorth;
output          o_freeSouth;
output  [50:0]  o_localMsg_51;
output  [50:0]  o_westMsg_51;
output  [50:0]  o_eastMsg_51;
output  [50:0]  o_northMsg_51;
output  [50:0]  o_southMsg_51;



//-----------------------------------------------
//inner wires and regs
 wire w_local2localR, w_local2westR, w_local2eastR, w_local2northR, w_local2southR;
 wire w_local2localA, w_local2westA, w_local2eastA, w_local2northA, w_local2southA;
 wire [50:0] w_local2localMsg_51, w_local2westMsg_51, w_local2eastMsg_51, w_local2northMsg_51, w_local2southMsg_51;


 wire w_west2localR, w_west2westR, w_west2eastR, w_west2northR, w_west2southR;
 wire w_west2localA, w_west2westA, w_west2eastA, w_west2northA, w_west2southA;
 wire [50:0] w_west2localMsg_51, w_west2westMsg_51, w_west2eastMsg_51, w_west2northMsg_51, w_west2southMsg_51;


 wire w_east2localR, w_east2westR, w_east2eastR, w_east2northR, w_east2southR;
 wire w_east2localA, w_east2westA, w_east2eastA, w_east2northA, w_east2southA;
 wire [50:0] w_east2localMsg_51, w_east2westMsg_51, w_east2eastMsg_51, w_east2northMsg_51, w_east2southMsg_51;


 wire w_north2localR, w_north2westR, w_north2eastR, w_north2northR, w_north2southR;
 wire w_north2localA, w_north2westA, w_north2eastA, w_north2northA, w_north2southA;
 wire [50:0] w_north2localMsg_51, w_north2westMsg_51, w_north2eastMsg_51, w_north2northMsg_51, w_north2southMsg_51;


 wire w_south2localR, w_south2westR, w_south2eastR, w_south2northR, w_south2southR;
 wire w_south2localA, w_south2westA, w_south2eastA, w_south2northA, w_south2southA;
 wire [50:0] w_south2localMsg_51, w_south2westMsg_51, w_south2eastMsg_51, w_south2northMsg_51, w_south2southMsg_51;



//-----------------------------------------------
//local part
(*dont_touch = "yes"*)routeMsg localRouteMsg (
    .rst            (rst            ),
    .i_drive        (i_driveLocal   ),  .o_free         (o_freeLocal        ),  .i_msg_51           (i_localInMsg_51        ),
    .o_driveWArb    (w_local2westR  ),  .i_freeWArb     (w_west2localA      ),  .o_westMsg_51       (w_local2westMsg_51     ),
    .o_driveEArb    (w_local2eastR  ),  .i_freeEArb     (w_east2localA      ),  .o_eastMsg_51       (w_local2eastMsg_51     ),
    .o_driveNArb    (w_local2northR ),  .i_freeNArb     (w_north2localA     ),  .o_northMsg_51      (w_local2northMsg_51    ),
    .o_driveSArb    (w_local2southR ),  .i_freeSArb     (w_south2localA     ),  .o_southMsg_51      (w_local2southMsg_51    ),
    .o_driveLArb    (w_local2localR ),  .i_freeLArb     (w_local2localA     ),  .o_localMsg_51      (w_local2localMsg_51    )
);

(*dont_touch = "yes"*)arbMsg localArbMsg (
	.rst            (rst                ),
	.i_driveWest    (w_west2localR      ),  .o_freeWest     (w_local2westA      ),  .i_westMsg_51       (w_west2localMsg_51     ),
	.i_driveEast    (w_east2localR      ),  .o_freeEast     (w_local2eastA      ),  .i_eastMsg_51       (w_east2localMsg_51     ),
	.i_driveNorth   (w_north2localR     ),  .o_freeNorth    (w_local2northA     ),  .i_northMsg_51      (w_north2localMsg_51    ),
	.i_driveSouth   (w_south2localR     ),  .o_freeSouth    (w_local2southA     ),  .i_southMsg_51      (w_south2localMsg_51    ),
	.i_driveLocal   (w_local2localR     ),  .o_freeLocal    (w_local2localA     ),  .i_localMsg_51      (w_local2localMsg_51    ),
	.o_driveNext    (o_driveLocal       ),  .i_freeNext     (i_freeLocal        ),  .o_msg_51           (o_localMsg_51          )

);

//-----------------------------------------------
//west part
(*dont_touch = "yes"*)routeMsg westRouteMsg (
    .rst            (rst           ),
    .i_drive        (i_driveWest   ),  .o_free          (o_freeWest         ),  .i_msg_51           (i_westInMsg_51        ),
    .o_driveWArb    (w_west2westR  ),  .i_freeWArb      (w_west2westA       ),  .o_westMsg_51       (w_west2westMsg_51     ),
    .o_driveEArb    (w_west2eastR  ),  .i_freeEArb      (w_east2westA       ),  .o_eastMsg_51       (w_west2eastMsg_51     ),
    .o_driveNArb    (w_west2northR ),  .i_freeNArb      (w_north2westA      ),  .o_northMsg_51      (w_west2northMsg_51    ),
    .o_driveSArb    (w_west2southR ),  .i_freeSArb      (w_south2westA      ),  .o_southMsg_51      (w_west2southMsg_51    ),
    .o_driveLArb    (w_west2localR ),  .i_freeLArb      (w_local2westA      ),  .o_localMsg_51      (w_west2localMsg_51    )
);

(*dont_touch = "yes"*)arbMsg westArbMsg (
	.rst            (rst               ),
	.i_driveWest    (w_west2westR      ),  .o_freeWest     (w_west2westA      ),  .i_westMsg_51       (w_west2westMsg_51     ),
	.i_driveEast    (w_east2westR      ),  .o_freeEast     (w_west2eastA      ),  .i_eastMsg_51       (w_east2westMsg_51     ),
	.i_driveNorth   (w_north2westR     ),  .o_freeNorth    (w_west2northA     ),  .i_northMsg_51      (w_north2westMsg_51    ),
	.i_driveSouth   (w_south2westR     ),  .o_freeSouth    (w_west2southA     ),  .i_southMsg_51      (w_south2westMsg_51    ),
	.i_driveLocal   (w_local2westR     ),  .o_freeLocal    (w_west2localA     ),  .i_localMsg_51      (w_local2westMsg_51    ),
	.o_driveNext    (o_driveWest       ),  .i_freeNext     (i_freeWest        ),  .o_msg_51           (o_westMsg_51          )

);

//-----------------------------------------------
//east part
(*dont_touch = "yes"*)routeMsg eastRouteMsg (
    .rst            (rst           ),
    .i_drive        (i_driveEast   ),  .o_free         (o_freeEast         ),  .i_msg_51           (i_eastInMsg_51        ),
    .o_driveWArb    (w_east2westR  ),  .i_freeWArb      (w_west2eastA       ),  .o_westMsg_51       (w_east2westMsg_51     ),
    .o_driveEArb    (w_east2eastR  ),  .i_freeEArb      (w_east2eastA       ),  .o_eastMsg_51       (w_east2eastMsg_51     ),
    .o_driveNArb    (w_east2northR ),  .i_freeNArb      (w_north2eastA      ),  .o_northMsg_51      (w_east2northMsg_51    ),
    .o_driveSArb    (w_east2southR ),  .i_freeSArb      (w_south2eastA      ),  .o_southMsg_51      (w_east2southMsg_51    ),
    .o_driveLArb    (w_east2localR ),  .i_freeLArb      (w_local2eastA      ),  .o_localMsg_51      (w_east2localMsg_51    )
);

(*dont_touch = "yes"*)arbMsg eastArbMsg (
	.rst            (rst               ),
	.i_driveWest    (w_west2eastR      ),  .o_freeWest     (w_east2westA      ),  .i_westMsg_51       (w_west2eastMsg_51     ),
	.i_driveEast    (w_east2eastR      ),  .o_freeEast     (w_east2eastA      ),  .i_eastMsg_51       (w_east2eastMsg_51     ),
	.i_driveNorth   (w_north2eastR     ),  .o_freeNorth    (w_east2northA     ),  .i_northMsg_51      (w_north2eastMsg_51    ),
	.i_driveSouth   (w_south2eastR     ),  .o_freeSouth    (w_east2southA     ),  .i_southMsg_51      (w_south2eastMsg_51    ),
	.i_driveLocal   (w_local2eastR     ),  .o_freeLocal    (w_east2localA     ),  .i_localMsg_51      (w_local2eastMsg_51    ),
	.o_driveNext    (o_driveEast       ),  .i_freeNext     (i_freeEast        ),  .o_msg_51           (o_eastMsg_51          )

);

//-----------------------------------------------
//north part
(*dont_touch = "yes"*)routeMsg northRouteMsg (
    .rst            (rst            ),
    .i_drive        (i_driveNorth   ),  .o_free          (o_freeNorth         ),  .i_msg_51           (i_northInMsg_51        ),
    .o_driveWArb    (w_north2westR  ),  .i_freeWArb      (w_west2northA       ),  .o_westMsg_51       (w_north2westMsg_51     ),
    .o_driveEArb    (w_north2eastR  ),  .i_freeEArb      (w_east2northA       ),  .o_eastMsg_51       (w_north2eastMsg_51     ),
    .o_driveNArb    (w_north2northR ),  .i_freeNArb      (w_north2northA      ),  .o_northMsg_51      (w_north2northMsg_51    ),
    .o_driveSArb    (w_north2southR ),  .i_freeSArb      (w_south2northA      ),  .o_southMsg_51      (w_north2southMsg_51    ),
    .o_driveLArb    (w_north2localR ),  .i_freeLArb      (w_local2northA      ),  .o_localMsg_51      (w_north2localMsg_51    )
);

(*dont_touch = "yes"*)arbMsg northArbMsg (
	.rst            (rst                ),
	.i_driveWest    (w_west2northR      ),  .o_freeWest     (w_north2westA      ),  .i_westMsg_51       (w_west2northMsg_51     ),
	.i_driveEast    (w_east2northR      ),  .o_freeEast     (w_north2eastA      ),  .i_eastMsg_51       (w_east2northMsg_51     ),
	.i_driveNorth   (w_north2northR     ),  .o_freeNorth    (w_north2northA     ),  .i_northMsg_51      (w_north2northMsg_51    ),
	.i_driveSouth   (w_south2northR     ),  .o_freeSouth    (w_north2southA     ),  .i_southMsg_51      (w_south2northMsg_51    ),
	.i_driveLocal   (w_local2northR     ),  .o_freeLocal    (w_north2localA     ),  .i_localMsg_51      (w_local2northMsg_51    ),
	.o_driveNext    (o_driveNorth       ),  .i_freeNext     (i_freeNorth        ),  .o_msg_51           (o_northMsg_51          )

);


//-----------------------------------------------
//south part
(*dont_touch = "yes"*)routeMsg southRouteMsg (
    .rst            (rst            ),
    .i_drive        (i_driveSouth   ),  .o_free          (o_freeSouth         ),  .i_msg_51           (i_southInMsg_51        ),
    .o_driveWArb    (w_south2westR  ),  .i_freeWArb      (w_west2southA       ),  .o_westMsg_51       (w_south2westMsg_51     ),
    .o_driveEArb    (w_south2eastR  ),  .i_freeEArb      (w_east2southA       ),  .o_eastMsg_51       (w_south2eastMsg_51     ),
    .o_driveNArb    (w_south2northR ),  .i_freeNArb      (w_north2southA      ),  .o_northMsg_51      (w_south2northMsg_51    ),
    .o_driveSArb    (w_south2southR ),  .i_freeSArb      (w_south2southA      ),  .o_southMsg_51      (w_south2southMsg_51    ),
    .o_driveLArb    (w_south2localR ),  .i_freeLArb      (w_local2southA      ),  .o_localMsg_51      (w_south2localMsg_51    )
);

(*dont_touch = "yes"*)arbMsg southArbMsg (
	.rst            (rst                ),
	.i_driveWest    (w_west2southR      ),  .o_freeWest     (w_south2westA      ),  .i_westMsg_51       (w_west2southMsg_51     ),
	.i_driveEast    (w_east2southR      ),  .o_freeEast     (w_south2eastA      ),  .i_eastMsg_51       (w_east2southMsg_51     ),
	.i_driveNorth   (w_north2southR     ),  .o_freeNorth    (w_south2northA     ),  .i_northMsg_51      (w_north2southMsg_51    ),
	.i_driveSouth   (w_south2southR     ),  .o_freeSouth    (w_south2southA     ),  .i_southMsg_51      (w_south2southMsg_51    ),
	.i_driveLocal   (w_local2southR     ),  .o_freeLocal    (w_south2localA     ),  .i_localMsg_51      (w_local2southMsg_51    ),
	.o_driveNext    (o_driveSouth       ),  .i_freeNext     (i_freeSouth        ),  .o_msg_51           (o_southMsg_51          )

);

endmodule

