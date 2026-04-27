//---------ONLY FOR SETTING ---------
`define RESETADDR 32'h00000000
`define GPIO_NUM 16
`define DC_ENV // for run dc
`define FREQ 25
`define BUS_BY_FUTONG
//--------ONLY FOR SETTING ------


`define ROM_MAX_ADDR   32'h00007FFF
`define RAM_MAX_ADDR   32'h0000FFFF
`define UART_MIN_ADDR  32'h00010000
`define UART_MAX_ADDR  32'h0001000F
`define GPIO_MIN_ADDR  32'h00020000
`define GPIO_MAX_ADDR  32'h0002000F
`define TIMER_MIN_ADDR 32'h00040000
`define TIMER_MAX_ADDR 32'h0004000F
`define SPI_MIN_ADDR   32'h00080000
`define SPI_MAX_ADDR   32'h0008000F

`define C_OP_C0             2'b00
`define C_OP_C1             2'b01
`define C_OP_C2             2'b10

`define C_FUNCT3_ADDI4SPN   3'b000
`define C_FUNCT3_FLD        3'b001
`define C_FUNCT3_LW         3'b010
`define C_FUNCT3_FLW        3'b011
`define C_FUNCT3_reserved   3'b100
`define C_FUNCT3_FSD        3'b101
`define C_FUNCT3_SW         3'b110
`define C_FUNCT3_FSW        3'b111
`define C_FUNCT3_ADDI       3'b000
`define C_FUNCT3_JAL        3'b001
`define C_FUNCT3_LI         3'b010
`define C_FUNCT3_LUI        3'b011
`define C_FUNCT3_ADDI16SP   3'b011
`define C_FUNCT3_MISC_ALU   3'b100
`define C_FUNCT3_J          3'b101
`define C_FUNCT3_BEQZ       3'b110
`define C_FUNCT3_BNEZ       3'b111
`define C_FUNCT3_SLLI       3'b000
`define C_FUNCT3_FLDSP      3'b001
`define C_FUNCT3_LWSP       3'b010
`define C_FUNCT3_FLWSP      3'b011
`define C_FUNCT3_JALR       3'b100
`define C_FUNCT3_JR         3'b100
`define C_FUNCT3_MV         3'b100
`define C_FUNCT3_ADD        3'b100
`define C_FUNCT3_EBREAK     3'b100
`define C_FUNCT3_FSDSP      3'b101
`define C_FUNCT3_SWSP       3'b110
`define C_FUNCT3_FSWSP      3'b111

`define C_FUNCT4_JR         4'b1000
`define C_FUNCT4_JALR       4'b1001
`define C_FUNCT4_MV         4'b1000
`define C_FUNCT4_ADD        4'b1001
`define C_FUNCT4_EBREAK     4'b1001

`define C_FUNCT6_AND        6'b100011
`define C_FUNCT6_OR         6'b100011
`define C_FUNCT6_XOR        6'b100011
`define C_FUNCT6_SUB        6'b100011

`define C_FUNCT2_SRLI       2'b00
`define C_FUNCT2_SRAI       2'b01
`define C_FUNCT2_ANDI       2'b10
`define C_FUNCT2_AND        2'b11
`define C_FUNCT2_OR         2'b10
`define C_FUNCT2_XOR        2'b01
`define C_FUNCT2_SUB        2'b00


`define FUNCT3_BEQ       3'b000
`define FUNCT3_BNE       3'b001
`define FUNCT3_BLT       3'b100
`define FUNCT3_BGE       3'b101
`define FUNCT3_BLTU      3'b110
`define FUNCT3_BGEU      3'b111


`define FUNCT3_LB        3'b000
`define FUNCT3_LH        3'b001
`define FUNCT3_LW        3'b010
`define FUNCT3_LBU       3'b100
`define FUNCT3_LHU       3'b101
`define FUNCT3_SB        3'b000
`define FUNCT3_SH        3'b001
`define FUNCT3_SW        3'b010

`define FUNCT3_ADDI        3'b000
`define FUNCT3_SLTI        3'b010
`define FUNCT3_SLTIU       3'b011
`define FUNCT3_XORI        3'b100
`define FUNCT3_ORI         3'b110
`define FUNCT3_ANDI        3'b111

`define FUNCT3_SLLI        3'b001
`define FUNCT3_SRLI        3'b101
`define FUNCT3_SRAI        3'b101

`define FUNCT3_ADD        3'b000
`define FUNCT3_SUB        3'b000
`define FUNCT3_SLL        3'b001
`define FUNCT3_SLT        3'b010
`define FUNCT3_SLTU       3'b011
`define FUNCT3_XOR        3'b100
`define FUNCT3_SRL        3'b101
`define FUNCT3_SRA        3'b101
`define FUNCT3_OR         3'b110
`define FUNCT3_AND        3'b111

`define FUNCT3_MUL        3'b000
`define FUNCT3_MULH       3'b001
`define FUNCT3_MULHSU     3'b010
`define FUNCT3_MULHU      3'b011
`define FUNCT3_DIV        3'b100
`define FUNCT3_DIVU       3'b101
`define FUNCT3_REM        3'b110
`define FUNCT3_REMU       3'b111

`define FUNCT7_RV32M        7'b0000001
`define FUNCT3_CSRRW        3'b001
`define FUNCT3_CSRRS        3'b010
`define FUNCT3_CSRRC        3'b011
`define FUNCT3_CSRRWI       3'b101
`define FUNCT3_CSRRSI       3'b110
`define FUNCT3_CSRRCI       3'b111

`define FUNCT7_FADD         7'b0000000
`define FUNCT7_FSUB         7'b0000100
`define FUNCT7_FMUL         7'b0001000
`define FUNCT7_FDIV         7'b0001100
`define FUNCT7_FCVTSW       7'b1101000
`define FUNCT7_FCVTWS       7'b1100000
`define FUNCT7_FCOMP        7'b1010000
`define FUNCT7_FSGNJS       7'b0010000
`define FUNCT7_FM           7'b0010100
`define FUNCT7_FMVXW        7'b1010011
`define FUNCT7_FMVWX        7'b1010011
`define FUNCT3_FMIN         3'b000
`define FUNCT3_FMAX         3'b001
`define FUNCT3_FEQ          3'b010
`define FUNCT3_FLT          3'b001
`define FUNCT3_FLE          3'b000



`define OP_LOAD             7'b0000011
`define OP_LOAD_FP          7'b0000111
`define OP_custom_0         7'b0001011
`define OP_MISC_MEM         7'b0001111
`define OP_OP_IMM           7'b0010011
`define OP_AUIPC            7'b0010111
`define OP_OP_IMM_32        7'b0011011
`define OP_48b0             7'b0011111
`define OP_STORE            7'b0100011
`define OP_STORE_FP         7'b0100111
`define OP_custom_1         7'b0101011
`define OP_AMO              7'b0101111
`define OP_OP               7'b0110011
`define OP_LUI              7'b0110111
`define OP_OP_32            7'b0111011
`define OP_MADD             7'b1000011
`define OP_MSUB             7'b1000111
`define OP_NMSUB            7'b1001011
`define OP_NMADD            7'b1001111
`define OP_OP_FP            7'b1010011
`define OP_reserved0        7'b1010111
`define OP_custom_2/rv128   7'b1011011
`define OP_48b1             7'b1011111
`define OP_BRANCH           7'b1100011
`define OP_JALR             7'b1100111
`define OP_reserved1        7'b1101011
`define OP_JAL              7'b1101111
`define OP_SYSTEM           7'b1110011
`define OP_reserved2        7'b1110111
`define OP_custom_3/rv128   7'b1111011
`define OP_80b              7'b1111111
`define OP_FP               7'b1010011
`define OP_EXTEND_MATRIX    7'b0001011
`define OP_EXTEND_CRYPT     7'b1101011
`define OP_EXTEND_RECONF    7'b0101011
`define OP_IO               7'b1111011
`define OP_END              7'b1011011

`define MODE_0      2'b00
`define MODE_1      2'b01

`define INT_ERR_NONE                5'b00000

`define SYS_BREAKPOINT              5'b00010   //breakpoint
`define SYS_ENVIRONMENT_CALL        5'b00110   //Environment call 
`define SYS_ENVIRONMENT_RET         5'b01101   //Environment RET

`define IF_VISIT_ERR                5'b00001   //Value access error     !!!!!!
`define ID_ILOGICAL_INSTR           5'b00011   //Illegal instruction    !!!!!!
`define WB_READ_MEM_MISALIGINMENT   5'b00111   //Read memory not aligned  !!!!!
`define WB_WRITE_MEM_MISALIGINMENT  5'b00101   //Write memory not aligned ??????????
`define WB_READ_MEM_ADDR_NOT_FOUND  5'b00100   //Read memory access address does not exist !!!!!
`define WB_WRITE_MEM_ADDR_NOT_FOUND 5'b01100   //Write memory access address does not exist !!!!!

`define TIMMER_INT    5'b00001                  //timer interrupt
`define SOFTWARE_INT  5'b00010                  //External interrupt
`define SOFTWARE_EXT1 5'b00100                  //External interrupt
`define SOFTWARE_EXT2 5'b01000                  //External interrupt
`define SOFTWARE_EXT3 5'b10000                  //External interrupt

`define nop                     32'h0000_0013
