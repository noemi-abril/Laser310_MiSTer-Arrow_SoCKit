
`define BASE_SYS_ROM
//`define	BENNVENN_DOS_ROM
`define BASE_DOS_ROM
`define BOOT_ROM_6000
`define BASE_RAM_78	//2k
`define BASE_RAM_16K
`define RAM_16K_EXPANSION
`define SHRG			// Extended drawing mode support
//`define VRAM_2K
`define VRAM_8K
//`define VRAM_24K		// SUPER SHRG!

`define CASS_EMU
//`define CASS_EMU_16K

`ifndef VERILATOR
`define SN76489
`endif

//=========================================================================================================

// Enable Lower Case chars in $00-$1F range
// Also requires SHRG extension active to allow access to GM0 bit
// GM0 = 0 selects INVERSE, GM0 = 1 selects L/CASE in Text mode (LATCHED_IO_SHRG[2] in Port $20)

// OUT 32,12 selects Lower Case chars, OUT 32,8 selects INVERSE chars.
 
// Mimics the behaviour of the 6847T1 chip.
// affects char gen rom select in module: char_gen_rom

`define LCASE		

//=========================================================================================================

// enable 64x32 text mode sysrom load.
// SWITCH 3 OFF selects 32x16 text mode, SWITCH3 ON selects 64x32 text mode
// only supported by ON-CHIP rom image at this point in time.

//`define WIDTH_64

//=========================================================================================================

//`ifdef CASS_EMU_8K
//`ifdef CASS_EMU_4K
//`ifdef CASS_EMU_2K

//Switches
//  9 Latch BANK_4000
//  8 Latch BANK_4000
//  7 Latch BANK_4000
//  6 Latch BANK_0000
//  5 Latch BANK_0000
//  4 Latch BANK_0000
//  3 
//  2 SHRG_EN
//  1 Dosrom Enable
//  0 Turbo

								
module LASER310_TOP(
input				CLK10MHZ,
input				CLK42MHZ,
input				RESET,//Active Low
output	[7:0]	VGA_RED,
output	[7:0]	VGA_GREEN,
output	[7:0]	VGA_BLUE,
output			VGA_HS,
output			VGA_VS,
output         h_blank,
output         v_blank,
output         ce_pix,
input				VIDEO_MODE,
output	[1:0]	AUD_ADCDAT,
output	[7:0]	audio_s,
input				key_strobe,
input				key_pressed,
input		[7:0]	key_code,
input		[9:0]	SWITCH,
input				UART_RXD,
output			UART_TXD,
input [7:0] dn_index,
input [7:0] dn_data,
input [15:0] dn_addr,
input  dn_wr,
input dn_download,
output led,
output led2,
input arm_1,
input fire_1,
input right_1,
input left_1,
input down_1,
input up_1,
input arm_2,
input fire_2,
input right_2,
input left_2,
input down_2,
input up_2

); 

reg		[3:0]		CLK;

wire					MEM_OP_WR;
reg               AMEM_OP_WR;
//reg					MEM_RD;
(*keep*)reg				GPIO_CPU_CLK;
// Processor
(*keep*)reg				CPU_CLK;
(*keep*)wire[15:0]	CPU_A;
(*keep*)wire [7:0]	CPU_DI;
(*keep*)wire [7:0]	CPU_DO;
(*keep*)wire			CPU_RESET;
(*keep*)wire			CPU_HALT;
(*keep*)wire			CPU_MREQ;
(*keep*)wire			CPU_RD;
(*keep*)wire			CPU_WR;
(*keep*)wire			CPU_IORQ;
(*keep*)reg				CPU_INT;
(*keep*)wire			CPU_M1;
wire						CPU_BUSRQ;
wire						CPU_BUSAK;
wire						CPU_RFSH;
(*keep*)wire			CPU_RESET_N;
(*keep*)wire			CPU_HALT_N;
(*keep*)wire			CPU_MREQ_N;
(*keep*)wire			CPU_RD_N;
(*keep*)wire			CPU_WR_N;
(*keep*)wire			CPU_IORQ_N;
(*keep*)wire			CPU_INT_N;
(*keep*)wire			CPU_M1_N;
wire						CPU_BUSRQ_N;
wire						CPU_BUSAK_N;
wire						CPU_RFSH_N;
// VRAM
(*keep*)wire[12:0]	VRAM_ADDRESS;
(*keep*)wire			VRAM_WR;
(*keep*)wire [7:0]	VRAM_DATA_OUT;
(*keep*)wire			VDG_RD;
(*keep*)wire [14:0]	VDG_ADDRESS;	// 14 for SSHRG 24KB modes
(*keep*)wire [7:0]	VDG_DATA;
// ROM IO RAM
reg					LATCHED_DOSROM_EN;
reg					LATCHED_BOOTROM_EN;
reg					LATCHED_AUTOSTARTROM_EN;
wire	[7:0]		SYS_ROM_DATA;
wire	[7:0]		DOS_ROM_DATA;
wire	[7:0]		AUTOSTART_ROM_DATA;
wire	[7:0]		BOOT_ROM_6000_DATA;
reg					BOOTROM_EN;
reg		[7:0]		BOOTROM_BANK;
reg					AUTOSTARTROM_EN;
reg		[7:0]		AUTOSTARTROM_BANK;
//wire	[7:0]		IO_DATA;
//wire	[7:0]		IO_WR;
wire				RAM_16K_WR;
wire	[7:0]		RAM_16K_DATA_OUT;
wire				RAM_78_WR;
wire	[7:0]		RAM_78_DATA;
wire				RAM_16K_EXP_WR;
wire	[7:0]		RAM_16K_EXP_DATA_OUT;
wire				RAM_89AB_WR;
wire	[7:0]		RAM_89AB_DATA;
wire				RAM_CDEF_WR;
wire	[7:0]		RAM_CDEF_DATA;
wire	[7:0]		MEM_CDEF_DATA_OUT;
wire	[7:0]		RAM_89AB_DATA_OUT;
wire	[7:0]		RAM_CDEF_DATA_OUT;
wire				ADDRESS_ROM;
wire				ADDRESS_DOSROM;
wire				ADDRESS_IO;
wire				ADDRESS_VRAM;
wire				ADDRESS_BOOTROM_6000;
wire				ADDRESS_AUTOSTARTROM;
wire				ADDRESS_89AB;
wire				ADDRESS_CDEF;
wire				ADDRESS_RAM_78;
wire				ADDRESS_RAM_16K;
wire				ADDRESS_RAM_16K_EXP;
wire				ADDRESS_IO_SHRG;
wire				ADDRESS_IO_BANK;
wire				ADDRESS_RAM_CHIP;
reg		[7:0]		LATCHED_IO_DATA_WR;
//reg	[7:0]		LATCHED_IO_DATA_RD;
reg		[7:0]		LATCHED_BANK_0000;
reg		[7:0]		LATCHED_BANK_4000;
reg		[7:0]		LATCHED_BANK_C000;
reg		[7:0]		LATCHED_BANK_4DEF;
`ifdef SHRG
reg				LATCHED_SHRG_EN;
reg		[7:0]		LATCHED_IO_SHRG;		// 7:5 unused, 4:2 = 6847 GM[2:0], 1:0 = VRAM bank (4x2KB)
								// 6:5 == VRAM bank 3:2 for 64x32 modes (16 x 2KB, but only 24KB required)
`endif

// keyboard
reg		[4:0]		KB_CLK;

wire	[7:0]		SCAN;
wire				PRESS;
wire				PRESS_N;
wire				EXTENDED;

reg		[63:0]		KEY;
reg		[9:0]		KEY_EX;
reg		[11:0]		KEY_Fxx;
wire	[7:0]		KEY_DATA;
//reg	[63:0]		LAST_KEY;
//reg				CAPS_CLK;
//reg				CAPS;
wire				A_KEY_PRESSED;

reg		[7:0]		LATCHED_KEY_DATA;

// emu keyboard
wire	[63:0]		EMU_KEY;
wire	[9:0]		EMU_KEY_EX;
wire				EMU_KEY_EN;
// cassette

(*keep*)wire	[1:0]	CASS_OUT;
(*keep*)wire			CASS_IN;
(*keep*)wire			CASS_IN_L;
(*keep*)wire			CASS_IN_R;


// 用于外部磁带仿真计数
//(*keep*)reg				EMU_CASS_CLK;

(*keep*)wire			EMU_CASS_EN;
(*keep*)wire	[1:0]	EMU_CASS_DAT;


reg		[16:0]		RESET_KEY_COUNT;
wire				RESET_KEY_N, RESET_N;

wire				TURBO_SPEED		=	SWITCH[0];


RESET_DE RESET_DE(
	.CLK(CLK42MHZ),
	.SYS_RESET_N(RESET),
	.RESET_N(RESET_N)
);


// 键盘 ctrl + f12 系统复位
assign RESET_KEY_N = RESET_KEY_COUNT[16];

reg 		[17:0]	INT_CNT;

always @ (negedge CLK10MHZ)
	case(INT_CNT[17:0])
		18'd0:
		begin
			CPU_INT <= 1'b1;
			INT_CNT <= 18'd1;
		end
		18'd640:
		begin
			CPU_INT <= 1'b0;
			INT_CNT <= 18'd641;
		end
		18'd199999:
		begin
			INT_CNT <= 18'd0;
		end
		default:
		begin
			INT_CNT <= INT_CNT + 1;
		end
	endcase

always @(posedge CLK42MHZ or negedge RESET_N)
	if(~RESET_N)
	begin
		CPU_CLK					<=	1'b0;
		GPIO_CPU_CLK			<=	1'b0;
		// 复位期间设置，避免拨动开关引起错误
		LATCHED_DOSROM_EN		<=	SWITCH[1];
		LATCHED_BANK_0000		<=	{5'b0,SWITCH[6:4]};
		LATCHED_BANK_4000		<=	{5'b0,SWITCH[9:7]};
		LATCHED_BOOTROM_EN		<=	BOOTROM_EN;
		LATCHED_AUTOSTARTROM_EN	<=	AUTOSTARTROM_EN;
		//LATCHED_BOOTROM_EN		<=	1'b0;

`ifdef SHRG									// Sampled during reset to avoid the error caused by the switch toggling randomly
		LATCHED_IO_SHRG			<=	8'b00001000;		// default to GM 010 mode: 128x64 colour + VRAM BANK 0000
		LATCHED_SHRG_EN			<=	SWITCH[2];
`endif

`ifdef IO_BANK
		if(BOOTROM_EN)
			LATCHED_BANK_C000		<=	BOOTROM_BANK;
		else
			LATCHED_BANK_C000		<=	8'b0;
		if(AUTOSTARTROM_EN)
			LATCHED_BANK_4DEF		<=	AUTOSTARTROM_BANK;
		else
			LATCHED_BANK_4DEF		<=	8'b0;
`endif


		AMEM_OP_WR				<=	1'b0;

		LATCHED_KEY_DATA		<=	8'b0;
		LATCHED_IO_DATA_WR		<=	8'b0;
		//EMU_CASS_CLK <= 1'b0;
		CLK						<=	4'd0;
	end
	else
	begin
		case (CLK[3:0])
		4'd0:
			begin
				// 同步内存，等待读写信号建立
				CPU_CLK				<=	1'b1;
				GPIO_CPU_CLK		<=	1'b1;
				AMEM_OP_WR			<=	1'b1;
				//EMU_CASS_CLK <= ~EMU_CASS_CLK;
				CLK					<=	4'd1;
			end

		4'd1:
			begin
				// 同步内存，锁存读写信号和地址
				CPU_CLK				<=	1'b0;
				AMEM_OP_WR			<=	1'b0;
				LATCHED_KEY_DATA	<=	KEY_DATA;
				if({CPU_MREQ,CPU_RD,CPU_WR,ADDRESS_IO}==4'b1011)
					LATCHED_IO_DATA_WR	<=	CPU_DO;
`ifdef SHRG
				if(LATCHED_SHRG_EN)
					if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_SHRG}==4'b1011)
						LATCHED_IO_SHRG		<=	CPU_DO;
`endif
`ifdef IO_BANK
				if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_BANK}==4'b1011)
					LATCHED_BANK_C000	<=	CPU_DO;
`endif
				CLK					<=	4'd2;
			end

		4'd2:
			begin
				// 完成读写操作，开始输出
				CPU_CLK				<=	1'b0;
				GPIO_CPU_CLK		<=	~TURBO_SPEED;

				AMEM_OP_WR			<=	1'b0;
				CLK					<=	4'd3;
			end
		4'd3:
			begin
				if(TURBO_SPEED)
					CLK				<=	4'd0;
				else
					CLK				<=	4'd4;
			end
		4'd7:
			begin
				CPU_CLK				<=	1'b0;
				GPIO_CPU_CLK		<=	1'b0;
				AMEM_OP_WR			<=	1'b0;
				CLK					<=	4'd8;
			end
		4'd11:// 正常速度
			begin
				CPU_CLK				<=	1'b0;
				AMEM_OP_WR			<=	1'b0;
				CLK					<=	4'd0;
			end
		default:
			begin
				CPU_CLK				<=	1'b0;
				AMEM_OP_WR			<=	1'b0;
				CLK					<=	CLK + 1'b1;
			end
		endcase
	end

// CPU
assign CPU_RESET = ~RESET_N;
assign CPU_M1 = ~CPU_M1_N;
assign CPU_MREQ = ~CPU_MREQ_N;
assign CPU_IORQ = ~CPU_IORQ_N;
assign CPU_RD = ~CPU_RD_N;
assign CPU_WR = ~CPU_WR_N;
assign CPU_RFSH = ~CPU_RFSH_N;
assign CPU_HALT= ~CPU_HALT_N;
assign CPU_BUSAK = ~CPU_BUSAK_N;
assign CPU_RESET_N = ~CPU_RESET;
//assign CPU_INT_N = VIDEO_MODE ? ~CPU_INT : ~VGA_VS;
assign CPU_INT_N =  ~VGA_VS; 
wire VGA_VS2;
assign CPU_BUSRQ_N = ~CPU_BUSRQ;

`ifdef VERILATOR
tv80s Z80CPU (
	.m1_n(CPU_M1_N),
	.mreq_n(ACPU_MREQ_N),
	.iorq_n(ACPU_IORQ_N),
	.rd_n(CPU_RD_N),
	.wr_n(ACPU_WR_N),
	.rfsh_n(CPU_RFSH_N),
	.halt_n(CPU_HALT_N),
	.busak_n(CPU_BUSAK_N),
	.A(ACPU_A),
	.dout(ACPU_DO),
	.reset_n(CPU_RESET_N),
//	.clk(CPU_CLK),
	.clk(GCLK),
	.wait_n(1'b1),
	.int_n(CPU_INT_N),
	.nmi_n(1'b1),
	.busrq_n(CPU_BUSRQ_N),
	.di(CPU_DI),
	.dir(execute_addr),
	.dirset(execute_enable)

);
`else
t80pa Z80CPU (
	.m1_n(CPU_M1_N),
	.mreq_n(ACPU_MREQ_N),
	.iorq_n(ACPU_IORQ_N),
	.rd_n(CPU_RD_N),
	.wr_n(ACPU_WR_N),
	.rfsh_n(CPU_RFSH_N),
	.halt_n(CPU_HALT_N),
	.busak_n(CPU_BUSAK_N),
	.A(ACPU_A),
	.do(ACPU_DO),
	.reset_n(CPU_RESET_N),
//	.clk(CPU_CLK),
	.clk(GCLK),
	.wait_n(1'b1),
	.int_n(CPU_INT_N),
	.nmi_n(1'b1),
	.busrq_n(CPU_BUSRQ_N),
	.di(CPU_IORQ_N ? CPU_DI : CPU_D_INPORT),

	.DIR(DIR),
	.DIRSet(DIRSet)

);
`endif

z80_regset #(16'hB7BB) regset (
	.execute_addr(execute_addr),
	.execute_enable(execute_enable),
	.dir_out(DIR),
	.dir_set(DIRSet)
);

wire [211:0] DIR;       // Z80 Register set as defined in T80pa / T80
wire DIRSet;                // Signal to set registers
wire [15:0] execute_addr;     // Start address for program start
wire execute_enable;   	    // Jump to start address (out_execute_addr) - Not implemented



wire[15:0]	ACPU_A;
wire [7:0]	ACPU_DO;
wire ACPU_WR_N;
wire ACPU_IORQ_N;
wire ACPU_MREQ_N;


/*
assign CPU_A =  ACPU_A;
assign CPU_DO = ACPU_DO;
wire GCLK =  CPU_CLK ;
*/

assign CPU_A = vz_wr ? vz_addr : ACPU_A;
assign CPU_DO = vz_wr ? vz_data : ACPU_DO;
wire GCLK = vz_wr ? 1'b0  : CPU_CLK ;
assign CPU_WR_N = vz_wr ? 1'b0 : ACPU_WR_N;
assign MEM_OP_WR = vz_wr ? 1'b1 : AMEM_OP_WR;
assign CPU_IORQ_N = vz_wr ? 1'b1: ACPU_IORQ_N;
assign CPU_MREQ_N = vz_wr ? 1'b0 : ACPU_MREQ_N;
wire [7:0] vz_data;
wire [15:0] vz_addr;
wire vz_wr;


vz_loader vz_loader(
        .I_CLK(CLK42MHZ),
		  .CPU_CLOCK(GCLK),
	
        .I_RST(~CPU_RESET_N),

        .ioctl_wr(dn_wr),
        .ioctl_addr(dn_addr),
        .ioctl_data(dn_data),
        .ioctl_download(dn_download),
		  
        .vz_addr(vz_addr),
        .vz_data(vz_data),
        .vz_wr(vz_wr),
        .led(led2),

	.execute_enable(execute_enable),
	.execute_addr(execute_addr)
);

// 0000 -- 3FFF ROM 16KB
// 4000 -- 5FFF DOS
// 6000 -- 67FF BOOT ROM
// 6800 -- 6FFF I/O
// 7000 -- 77FF VRAM 2KB (SRAM 6116)
// 7800 -- 7FFF RAM 2KB
// 8000 -- B7FF RAM 14KB
// B800 -- BFFF RAM ext 2KB
// C000 -- F7FF RAM ext 14KB

assign ADDRESS_ROM			=	(CPU_A[15:14] == 2'b00)?1'b1:1'b0;
assign ADDRESS_DOSROM			=	(CPU_A[15:13] == 3'b010)?LATCHED_DOSROM_EN:1'b0;
assign ADDRESS_BOOTROM_6000		=	(CPU_A[15:11] == 5'b01100)?LATCHED_BOOTROM_EN:1'b0;
assign ADDRESS_AUTOSTARTROM		=	(CPU_A[15:12] == 4'h4||CPU_A[15:12] == 4'hD||CPU_A[15:12] == 4'hE||CPU_A[15:12] == 4'hF)?LATCHED_AUTOSTARTROM_EN:1'b0;
assign ADDRESS_IO			=	(CPU_A[15:11] == 5'b01101)?1'b1:1'b0;
assign ADDRESS_VRAM			=	(CPU_A[15:11] == 5'b01110)?1'b1:1'b0;
assign ADDRESS_89AB			=	(CPU_A[15:14] == 2'b10)?1'b1:1'b0;
assign ADDRESS_CDEF			=	(CPU_A[15:14] == 2'b11)?1'b1:1'b0;

// 7800 -- 7FFF RAM 2KB
assign ADDRESS_RAM_78			=	(CPU_A[15:11] == 5'b01111)?1'b1:1'b0;

// ** if using the 7800 2k ram, bump the other ram up to $8000-$BFFF and $C000-$FFFF. **

`ifdef BASE_RAM_78

	assign ADDRESS_RAM_16K			= ADDRESS_89AB;
	assign ADDRESS_RAM_16K_EXP		= ADDRESS_CDEF;

`else

	// 7800 -- 7FFF RAM 2KB
	// 8000 -- B7FF RAM 14KB

	assign ADDRESS_RAM_16K	=	(CPU_A[15:12] == 4'h8)?1'b1:
					(CPU_A[15:12] == 4'h9)?1'b1:
					(CPU_A[15:12] == 4'hA)?1'b1:
					(CPU_A[15:11] == 5'b01111)?1'b1:
					(CPU_A[15:11] == 5'b10110)?1'b1:
					1'b0;

	// B800 -- BFFF RAM ext 2KB
	// C000 -- F7FF RAM ext 14KB

	assign ADDRESS_RAM_16K_EXP =	(CPU_A[15:12] == 4'hC)?1'b1:
					(CPU_A[15:12] == 4'hD)?1'b1:
					(CPU_A[15:12] == 4'hE)?1'b1:
					(CPU_A[15:11] == 5'b10111)?1'b1:
					(CPU_A[15:11] == 5'b11110)?1'b1:
					1'b0;

`endif

assign ADDRESS_IO_SHRG		=	(CPU_A[7:0] == 8'd32)?1'b1:1'b0;	// I/O $20

// 64K RAM expansion cartridge vz300_review.pdf 中的端口号是 IO 7FH 127
// 128K SIDEWAYS RAM SHRG2 HVVZUG23 (Mar-Apr 1989).PDF 中的端口号是 IO 112

assign ADDRESS_IO_BANK	=	(CPU_A[7:0] == 8'd127 || CPU_A[7:0] == 8'd112)?1'b1:1'b0;




`ifdef RAM_16K_EXPANSION
assign	ADDRESS_RAM_CHIP	=	ADDRESS_RAM_16K|ADDRESS_RAM_16K_EXP;
`else
assign	ADDRESS_RAM_CHIP	=	ADDRESS_RAM_16K;
`endif



assign VRAM_WR			= ({ADDRESS_VRAM,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;
assign RAM_78_WR		= ({ADDRESS_RAM_78,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;
assign RAM_16K_WR		= ({ADDRESS_RAM_16K,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;
assign RAM_16K_EXP_WR	= ({ADDRESS_RAM_16K_EXP,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;


assign RAM_89AB_WR		= ({ADDRESS_89AB,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;
assign RAM_CDEF_WR		= ({ADDRESS_CDEF,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;

assign RAM_89AB_WR		= ({ADDRESS_89AB,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;
assign RAM_CDEF_WR		= ({ADDRESS_CDEF,MEM_OP_WR,CPU_WR,CPU_IORQ} == 4'b1110)?1'b1:1'b0;


assign CPU_DI = 	
				ADDRESS_ROM		? SYS_ROM_DATA		:
				ADDRESS_AUTOSTARTROM	? AUTOSTART_ROM_DATA	:
				ADDRESS_DOSROM		? DOS_ROM_DATA		:
				ADDRESS_RAM_78		? RAM_78_DATA		:
`ifdef BOOT_ROM_6000
				ADDRESS_BOOTROM_6000	? BOOT_ROM_6000_DATA	:
`endif
				ADDRESS_IO		? LATCHED_KEY_DATA	:
				ADDRESS_VRAM		? VRAM_DATA_OUT		:
`ifdef BASE_RAM_16K
				ADDRESS_RAM_16K		? RAM_16K_DATA_OUT	:
`endif
`ifdef RAM_16K_EXPANSION
				ADDRESS_RAM_16K_EXP	? RAM_16K_EXP_DATA_OUT	:
`endif
				8'hzz;



`ifdef BASE_SYS_ROM
	`ifdef WIDTH_64
	// This ROM is 32KB.
	// Low half is normal V2.0, top half is patched version of V2.0 for 64x32 text mode

	sprom #(
		.init_file("./roms/sysrom32_64.mif"),
		.widthad_a(15),
		.width_a(8))
	sys_rom(
		.address({SWITCH[3],CPU_A[13:0]}),		// SW3 selects 64x32 text mode
		.clock(CLK42MHZ),
		.q(SYS_ROM_DATA)
		);
	`else

	sprom #(
	`ifndef VERILATOR
		.init_file("./roms/sysrom.mif"),
	`else
		.init_file("./roms/sysrom.hex"),
	`endif
		.widthad_a(14),
		.width_a(8))
	sys_rom(
		.address(CPU_A[13:0]),
		.clock(CLK42MHZ),
		.q(SYS_ROM_DATA)
		);

	`endif
`endif

//====================================================================
`ifdef BASE_DOS_ROM
sprom #(
`ifndef VERILATOR
	.init_file("./roms/dosrom.mif"),
`else
	.init_file("./roms/dosrom.hex"),
`endif
	.widthad_a(13),
	.width_a(8))
DOS_ROM(
	.address(CPU_A[12:0]),
	.clock(CLK42MHZ),
	.q(DOS_ROM_DATA)
	);
`endif

//====================================================================

`ifdef BOOT_ROM_6000
sprom #(
`ifndef VERILATOR
	.init_file("./roms/boot_rom_6000.mif"),
`else
	.init_file("./roms/boot_rom_6000.hex"),
`endif
	.widthad_a(9),
	.width_a(8))
BOOT_ROM(
	.address(CPU_A[8:0]),
	.clock(CLK42MHZ),
	.q(BOOT_ROM_6000_DATA)
	);
`endif

//====================================================================

`ifdef BASE_RAM_78
spram #(
	. addr_width_g(11),
	.data_width_g(8))
BASE_RAM78(
	.address(CPU_A[10:0]),
	.clken(1),
	.clock(CLK42MHZ),
	.data(CPU_DO),
	.wren(CPU_MREQ & RAM_78_WR),
	.q(RAM_78_DATA)
	);
`endif

`ifdef BASE_RAM_16K
spram #(
	. addr_width_g(14),
	.data_width_g(8))
BASE_RAM16k(
	.address(CPU_A[13:0]),
	.clken(1),
	.clock(CLK42MHZ),
	.data(CPU_DO),
	.wren(CPU_MREQ & RAM_16K_WR),
	.q(RAM_16K_DATA_OUT)
	);
`else
assign	RAM_16K_DATA_OUT		=	8'bz;
`endif

`ifdef RAM_16K_EXPANSION
spram #(
	. addr_width_g(14),
	.data_width_g(8))
BASE_RAM16kex(
	.address(CPU_A[13:0]),
	.clken(1),
	.clock(CLK42MHZ),
	.data(CPU_DO),
	.wren(CPU_MREQ & RAM_16K_EXP_WR),
	.q(RAM_16K_EXP_DATA_OUT)
	);
`else
assign	RAM_16K_EXP_DATA_OUT	=	8'bz;
`endif

//=====================================================================

`ifdef VRAM_2K
dpram #(
	.addr_width_g(11),
	.data_width_g(8))
vram_2k(
	.clk_a_i(CLK42MHZ),
	.en_a_i(1),
	.we_i(CPU_MREQ & VRAM_WR),
	.addr_a_i(CPU_A[10:0]),
	.data_a_i(CPU_DO),
	.data_a_o(VRAM_DATA_OUT),
	.clk_b_i(VDG_RD),
	.addr_b_i(VDG_ADDRESS[10:0]),
	.data_b_o(VDG_DATA)
	);
`endif


`ifdef VRAM_8K
dpram #(
	.addr_width_g(13),
	.data_width_g(8))
vram_8k(
	.clk_a_i(CLK42MHZ),
	.en_a_i(1),
	.we_i(CPU_MREQ & VRAM_WR),
	.addr_a_i({LATCHED_IO_SHRG[1:0],CPU_A[10:0]}),
	.data_a_i(CPU_DO),
	.data_a_o(VRAM_DATA_OUT),
	.clk_b_i(VDG_RD),
	.addr_b_i(VDG_ADDRESS[12:0]),
	.data_b_o(VDG_DATA)
	);
`endif

`ifdef VRAM_24K		// Super SHRG!
dpram #(
	.addr_width_g(15),
	.data_width_g(8))
vram_24k(
	.clk_a_i(CLK42MHZ),
	.en_a_i(1),
	.we_i(CPU_MREQ & VRAM_WR),
	.addr_a_i({LATCHED_IO_SHRG[6:5],LATCHED_IO_SHRG[1:0],CPU_A[10:0]}),		// CPU only has a 2KB window for access. 
	.data_a_i(CPU_DO),
	.data_a_o(VRAM_DATA_OUT),
	.clk_b_i(VDG_RD),
	.addr_b_i(VDG_ADDRESS[14:0]),
	.data_b_o(VDG_DATA)
	);
`endif

//=====================================================================
// FROM ALICE


reg		LATCHED_AG;
reg		[2:0]	LATCHED_GM;
reg		LATCHED_CSS;

always @ (posedge CLK42MHZ )
begin
	if(!RESET_N)
	begin
		LATCHED_AG		<=	1'b0;
		LATCHED_GM		<=	3'b0;
		LATCHED_CSS		<=	1'b0;
	end
	else
	begin
		LATCHED_AG <= LATCHED_IO_DATA_WR[3];
		LATCHED_GM <= LATCHED_IO_SHRG[4:2];
		LATCHED_CSS <= LATCHED_IO_DATA_WR[4];
	end
end

reg clk_14M318_ena ;
reg [1:0] count;


always @(posedge CLK42MHZ)
begin
	if (~RESET_N)
		count<=0;
	else
	begin
		clk_14M318_ena <= 0;
		if (count == 'd2)
		begin
		  clk_14M318_ena <= 1;
        count <= 0;
		end
		else
		begin
			count<=count+1;
		end
	end
end  
wire vs,hs;
assign VGA_VS=~vs;
assign VGA_HS=~hs;
mc6847 mc6847(
  .clk(CLK42MHZ),
  `ifdef VERILATOR
  .clk_ena(1),
  `else
  .clk_ena(clk_14M318_ena),
  `endif
  .reset(~RESET_N),
  .da0(),
  .videoaddr(VDG_ADDRESS),
  .dd(VDG_DATA),
  .an_g(LATCHED_AG),
  .an_s(1'b0),
  .intn_ext(1'b0), // ?
  .gm(LATCHED_GM),
//  .gm(3'b010 ),
  .css(LATCHED_CSS),
  .inv(1'b0),
  .red(VGA_RED),
  .green(VGA_GREEN),
  .blue(VGA_BLUE),
  .hsync(hs),
  .vsync(vs),
  .hblank(h_blank),
  .vblank(v_blank),
  .artifact_en(1'b1),
  .artifact_set(1'b0),
  .artifact_phase(1'b1),
  .cvbs(),
  .black_backgnd(1'b1),
  .pixel_clk(ce_pix)
);
assign VDG_RD = CLK42MHZ;
/*
//=====================================================================
MC6847_VGA MC6847_VGA(
	.PIX_CLK(CLK25MHZ),
	.RESET_N(RESET_N),
	.width_64(SWITCH[3]),			// Switch 3 enables 64x32 text

	.RD(VDG_RD),
	.DD(VDG_DATA),
	.DA(VDG_ADDRESS),

	.AG(LATCHED_IO_DATA_WR[3]),		// _A/G     		_Alphanumeric/Graphics                             
	.AS(1'b0),				// _A/S			_Alphanumeric/Semi-Graphics
	.EXT(1'b0),				// _INT/EXT		_Internal/external         
	.INV(1'b0),				// INV			0 = normal, 1 = inverse    
`ifdef SHRG
	.GM(LATCHED_IO_SHRG[4:2]),		// GM[2:0]		Select 1 of 8 Gfx modes when _AG == 0
`else
	.GM(3'b010),				// fixed graphic 010 mode = 128x64 colour 
`endif
	.CSS(LATCHED_IO_DATA_WR[4]),		// CSS			Colour Set Select. 0 = BLACK/GREEN, 1 = BLACK/ORANGE
	// vga
	.h_blank(h_blank2),
	.v_blank(v_blank2),
	.VGA_OUT_HSYNC(VGA_HS),
	.VGA_OUT_VSYNC(VGA_VS),
	.VGA_OUT_RED(VGA_RED2),
	.VGA_OUT_GREEN(VGA_GREEN2),
	.VGA_OUT_BLUE(VGA_BLUE2)
);
*/

/*****************************************************************************
*  VZ Loader
******************************************************************************/



// keyboard

/*****************************************************************************
* Convert PS/2 keyboard to ASCII keyboard
******************************************************************************/

/*
   KD5 KD4 KD3 KD2 KD1 KD0 扫描用地址
A0  R   Q   E       W   T  68FEH       0
A1  F   A   D  CTRL S   G  68FDH       8
A2  V   Z   C  SHFT X   B  68FBH      16
A3  4   1   3       2   5  68F7H      24
A4  M  空格 ，      .   N  68EFH      32
A5  7   0   8   -   9   6  68DFH      40
A6  U   P   I  RETN O   Y  68BFH      48
A7  J   ；  K   :   L   H  687FH      56
*/

//  7: 0
// 15: 8
// 23:16
// 31:24
// 39:32
// 47:40
// 55:48
// 63:56



// 键盘检测的方法，就是循环地问每一行线发送低电平信号，也就是用该地址线为“0”的地址去读取数据。
// 例如，检测第一行时，使A0为0，其余为1；加上选通IC4的高五位地址01101，成为01101***11111110B（A8~A10不起作用，
// 可为任意值，故68FEH，69FEH，6AFEH，6BFEH，6CFEH，6DFEH，6EFEH，6FFEH均可）。
// 读 6800H 判断是否有按键按下。

// The method of keyboard detection is to cyclically ask each line to send a low level signal, 
// that is, to read the data with the address line "0".
// For example, when detecting the first line, make A0 0 and the rest 1; plus the high five-bit address 01101 of the strobe IC4, 
// become 01101***11111110B (A8~A10 does not work,
// It can be any value, so 68FEH, 69FEH, 6AFEH, 6BFEH, 6CFEH, 6DFEH, 6EFEH, 6FFEH can be).
// Read 6800H to determine if there is a button press.

// 键盘选通，整个竖列有一个选通的位置被按下，对应值为0。
// The keyboard is strobed, and a strobe position is pressed in the entire vertical column, and the corresponding value is 0.

// 键盘扩展
// 加入方向键盘
// Keyboard extension

// left:  ctrl M      37 KEY_EX[5]
// right: ctrl ,      35 KEY_EX[6]
// up:    ctrl .      33 KEY_EX[4]
// down:  ctrl space  36 KEY_EX[7]
// esc:   ctrl -      42 KEY_EX[3]
// backspace:  ctrl M      37 KEY_EX[8]

// R-Shift


wire	[63:0]	KEY_C		=	EMU_KEY_EN?EMU_KEY:KEY;
wire	[9:0]	KEY_EX_C	=	EMU_KEY_EN?EMU_KEY_EX:KEY_EX;

//wire KEY_CTRL_ULRD = (KEY_EX[7:4]==4'b1111);
wire KEY_CTRL_ULRD_BRK = (KEY_EX[8:3]==6'b111111);

wire KEY_DATA_BIT5 = (CPU_A[7:0]|{KEY_C[61], KEY_C[53], KEY_C[45],           KEY_C[37]&KEY_EX_C[5]&KEY_EX_C[8], KEY_C[29], KEY_C[21],           KEY_C[13],                   KEY_C[ 5]})==8'hff;
wire KEY_DATA_BIT4 = (CPU_A[7:0]|{KEY_C[60], KEY_C[52], KEY_C[44],           KEY_C[36]&KEY_EX_C[7], KEY_C[28], KEY_C[20],           KEY_C[12],                   KEY_C[ 4]})==8'hff;
wire KEY_DATA_BIT3 = (CPU_A[7:0]|{KEY_C[59], KEY_C[51], KEY_C[43],           KEY_C[35]&KEY_EX_C[6], KEY_C[27], KEY_C[19],           KEY_C[11],                   KEY_C[ 3]})==8'hff;
wire KEY_DATA_BIT2 = (CPU_A[7:0]|{KEY_C[58], KEY_C[50], KEY_C[42]&KEY_EX_C[3], KEY_C[34],           KEY_C[26], KEY_C[18]&KEY_EX_C[0], KEY_C[10]&KEY_CTRL_ULRD_BRK, KEY_C[ 2]})==8'hff;
wire KEY_DATA_BIT1 = (CPU_A[7:0]|{KEY_C[57], KEY_C[49], KEY_C[41],           KEY_C[33]&KEY_EX_C[4], KEY_C[25], KEY_C[17],           KEY_C[ 9],                   KEY_C[ 1]})==8'hff;
wire KEY_DATA_BIT0 = (CPU_A[7:0]|{KEY_C[56], KEY_C[48], KEY_C[40],           KEY_C[32],             KEY_C[24], KEY_C[16],           KEY_C[ 8],                   KEY_C[ 0]})==8'hff;

/*
wire KEY_DATA_BIT5 = (CPU_A[7:0]|{KEY[61], KEY[53], KEY[45], KEY[37], KEY[29], KEY[21], KEY[13], KEY[ 5]})==8'hff;
wire KEY_DATA_BIT4 = (CPU_A[7:0]|{KEY[60], KEY[52], KEY[44], KEY[36], KEY[28], KEY[20], KEY[12], KEY[ 4]})==8'hff;
wire KEY_DATA_BIT3 = (CPU_A[7:0]|{KEY[59], KEY[51], KEY[43], KEY[35], KEY[27], KEY[19], KEY[11], KEY[ 3]})==8'hff;
wire KEY_DATA_BIT2 = (CPU_A[7:0]|{KEY[58], KEY[50], KEY[42], KEY[34], KEY[26], KEY[18], KEY[10], KEY[ 2]})==8'hff;
wire KEY_DATA_BIT1 = (CPU_A[7:0]|{KEY[57], KEY[49], KEY[41], KEY[33], KEY[25], KEY[17], KEY[ 9], KEY[ 1]})==8'hff;
wire KEY_DATA_BIT0 = (CPU_A[7:0]|{KEY[56], KEY[48], KEY[40], KEY[32], KEY[24], KEY[16], KEY[ 8], KEY[ 0]})==8'hff;
*/

wire KEY_DATA_BIT7 = 1'b1;	// 没有空置，具体用途没有理解
//wire KEY_DATA_BIT6 = CASS_IN;
wire KEY_DATA_BIT6 = ~CASS_IN;

assign KEY_DATA = { KEY_DATA_BIT7, KEY_DATA_BIT6, KEY_DATA_BIT5, KEY_DATA_BIT4, KEY_DATA_BIT3, KEY_DATA_BIT2, KEY_DATA_BIT1, KEY_DATA_BIT0 };

/*
assign KEY_DATA = 	(CPU_A[0]==1'b0) ? KEY[ 7: 0] :
					(CPU_A[1]==1'b0) ? KEY[15: 8] :
					(CPU_A[2]==1'b0) ? KEY[23:16] :
					(CPU_A[3]==1'b0) ? KEY[31:24] :
					(CPU_A[4]==1'b0) ? KEY[39:32] :
					(CPU_A[5]==1'b0) ? KEY[47:40] :
					(CPU_A[6]==1'b0) ? KEY[55:48] :
					(CPU_A[7]==1'b0) ? KEY[63:56] :
					8'hff;

assign KEY_DATA =
					(CPU_A[7]==1'b0) ? KEY[63:56] :
					(CPU_A[6]==1'b0) ? KEY[55:48] :
					(CPU_A[5]==1'b0) ? KEY[47:40] :
					(CPU_A[4]==1'b0) ? KEY[39:32] :
					(CPU_A[3]==1'b0) ? KEY[31:24] :
					(CPU_A[2]==1'b0) ? KEY[23:16] :
					(CPU_A[1]==1'b0) ? KEY[15: 8] :
					(CPU_A[0]==1'b0) ? KEY[ 7: 0] :
					8'hff;
*/


assign A_KEY_PRESSED = (KEY[63:0] == 64'hFFFFFFFFFFFFFFFF) ? 1'b0:1'b1;

always @(posedge KB_CLK[3] or negedge RESET)
begin
	if(~RESET)
	begin
		KEY					<=	64'hFFFFFFFFFFFFFFFF;
		KEY_EX				<=	10'h3FF;
		KEY_Fxx				<=	12'h000;
//		CAPS_CLK			<=	1'b0;
		RESET_KEY_COUNT		<=	17'h1FFFF;

		BOOTROM_BANK		<=	0;
		BOOTROM_EN			<=	1'b0;

		AUTOSTARTROM_BANK	<=	0;
		AUTOSTARTROM_EN		<=	1'b0;
	end
	else
	begin
		//KEY[?] <= CAPS;
		if(RESET_KEY_COUNT[16]==1'b0)
			RESET_KEY_COUNT <= RESET_KEY_COUNT+1;

		case(key_code)
		8'h07:
		begin
				KEY_Fxx[11]	<= PRESS;	// F12 RESET
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b0;
					BOOTROM_BANK		<=	0;
					AUTOSTARTROM_EN		<=	1'b0;
					AUTOSTARTROM_BANK	<=	0;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h78:	KEY_Fxx[10] <= PRESS;	// F11
		8'h09:	KEY_Fxx[ 9] <= PRESS;	// F10 CASS STOP
		8'h01:	KEY_Fxx[ 8] <= PRESS;	// F9  CASS PLAY
		8'h0A:
		begin
				KEY_Fxx[ 7] <= PRESS;	// F8  Ctrl or L-Shift BOOT 8
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	39;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	23;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h83:
		begin
				KEY_Fxx[ 6] <= PRESS;	// F7  Ctrl or L-Shift BOOT 7
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	38;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	22;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h0B:
		begin
				KEY_Fxx[ 5] <= PRESS;	// F6  Ctrl or L-Shift BOOT 6
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	37;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	21;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h03:
		begin
				KEY_Fxx[ 4] <= PRESS;	// F5  Ctrl or L-Shift BOOT 5
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	36;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	20;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h0C:
		begin
				KEY_Fxx[ 3] <= PRESS;	// F4  Ctrl or L-Shift BOOT 4
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	35;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	19;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h04:
		begin
				KEY_Fxx[ 2] <= PRESS;	// F3  Ctrl or L-Shift BOOT 3
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	34;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	18;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h06:
		begin
				KEY_Fxx[ 1] <= PRESS;	// F2  Ctrl or L-Shift BOOT 2
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	33;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	17;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end
		8'h05:
		begin
				KEY_Fxx[ 0] <= PRESS;	// F1  Ctrl or L-Shift BOOT 1
				if(PRESS && (KEY[18]==PRESS_N))
				begin
					BOOTROM_EN			<=	1'b1;
					BOOTROM_BANK		<=	32;
					RESET_KEY_COUNT		<=	17'h0;
				end
				else
				if(PRESS && (KEY[10]==PRESS_N))
				begin
					AUTOSTARTROM_EN		<=	1'b1;
					AUTOSTARTROM_BANK	<=	16;
					RESET_KEY_COUNT		<=	17'h0;
				end
		end

		8'h16:	KEY[28] <= PRESS_N;	// 1 !
		8'h1E:	KEY[25] <= PRESS_N;	// 2 @
		8'h26:	KEY[27] <= PRESS_N;	// 3 #
		8'h25:	KEY[29] <= PRESS_N;	// 4 $
		8'h2E:	KEY[24] <= PRESS_N;	// 5 %
		8'h36:	KEY[40] <= PRESS_N;	// 6 ^
		8'h3D:	KEY[45] <= PRESS_N;	// 7 &
//		8'h0D:	KEY[?] <= PRESS_N;	// TAB
		8'h3E:	KEY[43] <= PRESS_N;	// 8 *
		8'h46:	KEY[41] <= PRESS_N;	// 9 (
		8'h45:	KEY[44] <= PRESS_N;	// 0 )
		8'h4E:	KEY[42] <= PRESS_N;	// - _
//		8'h55:	KEY[?] <= PRESS_N;	// = +
		8'h66:	KEY_EX[8] <= PRESS_N;	// backspace
//		8'h0E:	KEY[?] <= PRESS_N;	// ` ~
//		8'h5D:	KEY[?] <= PRESS_N;	// \ |
		8'h49:	KEY[33] <= PRESS_N;	// . >
		8'h4b:	KEY[57] <= PRESS_N;	// L
		8'h44:	KEY[49] <= PRESS_N;	// O
//		8'h11	KEY[?] <= PRESS_N; // line feed (really right ALT (Extended) see below
		8'h5A:	KEY[50] <= PRESS_N;	// CR
//		8'h54:	KEY[?] <= PRESS_N;	// [ {
//		8'h5B:	KEY[?] <= PRESS_N;	// ] }
		8'h52:	KEY[58] <= PRESS_N;	// ' "
		8'h1D:	KEY[ 1] <= PRESS_N;	// W
		8'h24:	KEY[ 3] <= PRESS_N;	// E
		8'h2D:	KEY[ 5] <= PRESS_N;	// R
		8'h2C:	KEY[ 0] <= PRESS_N;	// T
		8'h35:	KEY[48] <= PRESS_N;	// Y
		8'h3C:	KEY[53] <= PRESS_N;	// U
		8'h43:	KEY[51] <= PRESS_N;	// I
		8'h1B:	KEY[ 9] <= PRESS_N;	// S
		8'h23:	KEY[11] <= PRESS_N;	// D
		8'h2B:	KEY[13] <= PRESS_N;	// F
		8'h34:	KEY[ 8] <= PRESS_N;	// G
		8'h33:	KEY[56] <= PRESS_N;	// H
		8'h3B:	KEY[61] <= PRESS_N;	// J
		8'h42:	KEY[59] <= PRESS_N;	// K
		8'h22:	KEY[17] <= PRESS_N;	// X
		8'h21:	KEY[19] <= PRESS_N;	// C
		8'h2a:	KEY[21] <= PRESS_N;	// V
		8'h32:	KEY[16] <= PRESS_N;	// B
		8'h31:	KEY[32] <= PRESS_N;	// N
		8'h3a:	KEY[37] <= PRESS_N;	// M
		8'h41:	KEY[35] <= PRESS_N;	// , <
		8'h15:	KEY[ 4] <= PRESS_N;	// Q
		8'h1C:	KEY[12] <= PRESS_N;	// A
		8'h1A:	KEY[20] <= PRESS_N;	// Z
		8'h29:	KEY[36] <= PRESS_N;	// Space
//		8'h4A:	KEY[?] <= PRESS_N;	// / ?
		8'h4C:	KEY[60] <= PRESS_N;	// ; :
		8'h4D:	KEY[52] <= PRESS_N;	// P
		8'h14:	KEY[10] <= PRESS_N;	// Ctrl either left or right
		8'h12:	KEY[18] <= PRESS_N;	// L-Shift
		8'h59:	KEY_EX[0] <= PRESS_N;	// R-Shift
		8'h11:
		begin
			if(~EXTENDED)
					KEY_EX[1] <= PRESS_N;	// Repeat really left ALT
			else
					KEY_EX[2] <= PRESS_N;	// LF really right ALT
		end
		8'h76:	KEY_EX[3] <= PRESS_N;	// Esc
		8'h75:	KEY_EX[4] <= PRESS_N;	// up
		8'h6B:	KEY_EX[5] <= PRESS_N;	// left
		8'h74:	KEY_EX[6] <= PRESS_N;	// right
		8'h72:	KEY_EX[7] <= PRESS_N;	// down
		endcase
	end
end



always @ (posedge CLK42MHZ)				// 50MHz
	KB_CLK <= KB_CLK + 1'b1;			// 50/32 = 1.5625 MHz

assign PRESS_N = ~key_pressed;


`ifdef CASS_EMU

wire			CASS_BUF_RD;
wire	[15:0]	CASS_BUF_A;
wire			CASS_BUF_WR;
wire	[7:0]	CASS_BUF_DAT;
wire	[7:0]	CASS_BUF_Q;

// F9    CASS PLAY
// F10   CASS STOP
//assign led = KEY_Fxx[8];
assign led = vz_wr;

EMU_CASS_KEY	EMU_CASS_KEY(
	KEY_Fxx[8],
	KEY_Fxx[9],
	// cass emu
	CASS_BUF_RD,
	//
	CASS_BUF_A,
	CASS_BUF_WR,
	CASS_BUF_DAT,
	CASS_BUF_Q,
	//	Control Signals
	EMU_CASS_EN,
	EMU_CASS_DAT,

	// key emu
	EMU_KEY,
	EMU_KEY_EX,
	EMU_KEY_EN,
    /*
     * UART: 115200 bps, 8N1
     */
    UART_RXD,
    UART_TXD,

	// System
	TURBO_SPEED,
	// Clock: 10MHz
	CLK42MHZ,
	RESET_N
);


`ifdef CASS_EMU_16K

wire [13:0] cass_addr = dn_wr? dn_addr : CASS_BUF_A[13:0];

cass_ram_16k_altera cass_buf(
	.address(cass_addr),
	.clock(CLK42MHZ),
//	.data(CASS_BUF_DI),
	.data(dn_data),
	.wren(CASS_BUF_WR || dn_wr),
	.q(CASS_BUF_Q)
);

`endif


`ifdef CASS_EMU_8K

cass_ram_8k_altera cass_buf(
	.address(CASS_BUF_A[12:0]),
	.clock(CLK42MHZ),
	.data(CASS_BUF_DI),
	.wren(CASS_BUF_WR),
	.q(CASS_BUF_Q)
);

`endif


`ifdef CASS_EMU_4K

cass_ram_4k_altera cass_buf(
	.address(CASS_BUF_A[11:0]),
	.clock(CLK42MHZ),
	.data(CASS_BUF_DAT),
	.wren(CASS_BUF_WR),
	.q(CASS_BUF_Q)
);

`endif


`ifdef CASS_EMU_2K

cass_ram_2k_altera cass_buf(
	.address(CASS_BUF_A[10:0]),
	.clock(CLK42MHZ),
	.data(CASS_BUF_DAT),
	.wren(CASS_BUF_WR),
	.q(CASS_BUF_Q)
);

`endif

`endif



assign	CASS_OUT = EMU_CASS_EN ? EMU_CASS_DAT : {LATCHED_IO_DATA_WR[2], 1'b0};

(*keep*)wire trap = (CPU_RD|CPU_WR) && (CPU_A[15:12] == 4'h0);
//assign audio_s = 0;
//assign audio_s = { aud,aud,aud,aud,1'b0,1'b0,1'b0,1'b0};
assign audio_s = { LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[0],1'b0,1'b0,1'b0,1'b0};

//assign audio_s = { LATCHED_IO_DATA_WR[5],LATCHED_IO_DATA_WR[0],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
//assign audio_s = { LATCHED_IO_DATA_WR[5]^LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[5]^LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[5]^LATCHED_IO_DATA_WR[0],1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
wire aud = LATCHED_IO_DATA_WR[0]|LATCHED_IO_DATA_WR[5];
assign AUD_ADCDAT = {LATCHED_IO_DATA_WR[0],LATCHED_IO_DATA_WR[5]};


// floppy
wire				ADDRESS_IO_FDC;
wire				ADDRESS_IO_FDC_CT;
wire				ADDRESS_IO_FDC_DATA;
wire				ADDRESS_IO_FDC_POLL;
wire				ADDRESS_IO_FDC_WP;
reg		[7:0]		LATCHED_IO_FDC;
reg		[7:0]		LATCHED_IO_FDC_CT;
reg		[7:0]		LATCHED_RAM_DATA_FDC;

// floppy
(*keep*)wire					FDC_RAM_R;
(*keep*)wire					FDC_RAM_W;
(*keep*)wire		[17:0]		FDC_RAM_ADDR_R;
(*keep*)wire		[17:0]		FDC_RAM_ADDR_W;
reg			[7:0]		LAST_WRITE_DATA;
(*keep*)wire		[7:0]		FDC_RAM_DATA_W;

(*keep*)wire	[7:0]		FLOPPY_RD_DATA;
(*keep*)wire	[7:0]		FLOPPY_DATA;

// FDC
//				if({CPU_IORQ,CPU_RD,CPU_WR,ADDRESS_IO_FDC_CT}==4'b1011)
//					LATCHED_IO_FDC_CT	<=	CPU_DO;

//				if({CPU_IORQ,CPU_RD,CPU_WR}==3'b110)
//					LATCHED_IO_FDC	<=	ADDRESS_IO_FDC_POLL	?	{FDC_POLL, 7'h7F}	:
//										ADDRESS_IO_FDC_DATA	?	FDC_DATA			:
//										ADDRESS_IO_FDC_WP	?	{FDC_WP, 7'h7F}		:
//										8'hFF;
wire FLOPPY_WP_READ	= 1'b0;
wire RAM_ADDRESS_FD_R	=		FDC_RAM_ADDR_R;
wire RAM_ADDRESS_FD_W	=		FDC_RAM_ADDR_W;

assign ADDRESS_IO_FDC	=	(CPU_A[7:2] == 6'b000100)?1'b1:1'b0;

assign ADDRESS_IO_FDC_CT	=	(CPU_A[7:0] == 8'h10)?1'b1:1'b0;
assign ADDRESS_IO_FDC_DATA	=	(CPU_A[7:0] == 8'h11)?1'b1:1'b0;
assign ADDRESS_IO_FDC_POLL	=	(CPU_A[7:0] == 8'h12)?1'b1:1'b0;
assign ADDRESS_IO_FDC_WP	=	(CPU_A[7:0] == 8'h13)?1'b1:1'b0;


wire	[7:0]		FDC_DATA;
wire				FDC_POLL;
wire				FDC_WP;

wire	[7:0]		SECTOR_BYTE;
wire	[7:0]		TRACK1_NO;
wire	[7:0]		TRACK2_NO;
wire				DRIVE1;
wire				DRIVE2;
wire				MOTOR;

wire		FDC_IO_R;
wire		FDC_IO_W;

wire		FDC_SIG;
wire		FDC_SIG_CLK;

wire FDC_IO		=	(CPU_IORQ&ADDRESS_IO_FDC);
wire FDC_IO_POLL	=	(CPU_IORQ&ADDRESS_IO_FDC_POLL);
wire FDC_IO_DATA	=	(CPU_IORQ&ADDRESS_IO_FDC_DATA);
wire FDC_IO_CT	=	(CPU_IORQ&ADDRESS_IO_FDC_CT);

FDC_IF FDC_U (
	.FDC_CLK(CPU_CLK),
	.RESET_N(RESET_N),
	.SW(SWITCH[3:2]),
	.DBG(SWITCH[9:6]),

	.FDC_RAM_R(FDC_RAM_R),
	.FDC_RAM_W(FDC_RAM_W),
	.FDC_RAM_ADDR_R(FDC_RAM_ADDR_R),
	.FDC_RAM_ADDR_W(FDC_RAM_ADDR_W),
	.FDC_RAM_DATA_R(LATCHED_RAM_DATA_FDC),
	.FDC_RAM_DATA_W(FDC_RAM_DATA_W),

	.FDC_IO(FDC_IO),
	.FDC_IO_POLL(FDC_IO_POLL),
	.FDC_IO_DATA(FDC_IO_DATA),
	.FDC_IO_CT(FDC_IO_CT),

	.FDC_SIG(FDC_SIG),
	.FDC_SIG_CLK(FDC_SIG_CLK),

	.FDC_CT(LATCHED_IO_FDC_CT),
	.FDC_DATA(FDC_DATA),
	.FDC_POLL(FDC_POLL),
	.FDC_WP(FDC_WP),

	.FLOPPY_SECTOR_BYTE(SECTOR_BYTE),
	.TRACK1_NO(TRACK1_NO),
	.TRACK2_NO(TRACK2_NO),
	.DRIVE1(DRIVE1),
	.DRIVE2(DRIVE2),
	.MOTOR(MOTOR)
);


// PAGE 10 from tech manual
// alanswx
// AJS put joystick code in

//assign CPU_D_INPORT	=	ADDRESS_IO_FDC			? LATCHED_IO_FDC	:
//						8'hzz;
/*
wire [7:0] CPU_D_INPORT	=	
	ADDRESS_JOYSTICK_1_A ? JOYSTICK_1_DATA_A :
	ADDRESS_JOYSTICK_1_B ? JOYSTICK_1_DATA_B :
	ADDRESS_JOYSTICK_2_A ? JOYSTICK_2_DATA_A :
	ADDRESS_JOYSTICK_2_B ? JOYSTICK_2_DATA_B :
						8'hzz;
*/
wire [7:0] CPU_D_INPORT    =
	ADDRESS_JOYSTICK ?  (
    (ADDRESS_JOYSTICK_1_A ? JOYSTICK_1_DATA_A : 8'hff) &
    (ADDRESS_JOYSTICK_1_B ? JOYSTICK_1_DATA_B : 8'hff) &
    (ADDRESS_JOYSTICK_2_A ? JOYSTICK_2_DATA_A : 8'hff) &
    (ADDRESS_JOYSTICK_2_B ? JOYSTICK_2_DATA_B : 8'hff)) : 
    	8'hzz;


wire ADDRESS_JOYSTICK = ( CPU_A[7:4]  == 4'b0010 )?1'b1:1'b0;
wire ADDRESS_JOYSTICK_1_A = (ADDRESS_JOYSTICK & (CPU_A[0] == 1'b0))?1'b1:1'b0;
wire [7:0] JOYSTICK_1_DATA_A = { 3'b111, ~fire_1, ~right_1, ~left_1,~down_1,~up_1 };
wire ADDRESS_JOYSTICK_1_B = (ADDRESS_JOYSTICK & (CPU_A[1] == 1'b0))?1'b1:1'b0;
wire [7:0] JOYSTICK_1_DATA_B = { 3'b111, ~arm_1, 4'b1111};
wire ADDRESS_JOYSTICK_2_A = (ADDRESS_JOYSTICK & (CPU_A[2] == 1'b0))?1'b1:1'b0;
wire [7:0] JOYSTICK_2_DATA_A = { 3'b111, ~fire_2, ~right_2, ~left_2,~down_2,~up_2 };
wire ADDRESS_JOYSTICK_2_B = (ADDRESS_JOYSTICK & (CPU_A[3] == 1'b0))?1'b1:1'b0;
wire [7:0] JOYSTICK_2_DATA_B = { 3'b111, ~arm_2, 4'b1111};

endmodule
