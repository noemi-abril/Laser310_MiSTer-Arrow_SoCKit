// LASER310 VZ200
// mc6847

module MC6847_VGA(
	input			PIX_CLK,
	input			RESET_N,
	
	input 		width_64,		// select 64x32 text screen mode
	
// memory interface
	output			RD,			// Read request output
	output	[14:0]	DA,		// 8KB Address space, 24KB for SSHRG mode!
	input	[7:0]	DD,				// Data from mem

// control Inputs
	input			AG,				// _A/G     	_Alphanumeric/Graphics                                
	input			AS,				// _A/S			_Alphanumeric/Semi-Graphics                           
	input			EXT,			// _INT/EXT		_Internal/external                                    
	input			INV,			// INV			0 = normal, 1 = inverse                               
	input			CSS,			// CSS			Colour Set Select. 0 = BLACK/GREEN, 1 = BLACK/ORANGE                                                                        
	input	[2:0]	GM,				// GM[2:0]		Select 1 of 8 Gfx modes when _AG == 0                 
									// fixed graphic 010 mode = 128x64 colour on stock machine                                                                             
// vga out
	output   h_blank,
	output   v_blank,

	output		VGA_OUT_HSYNC,	                                                                      
	output		VGA_OUT_VSYNC,	
	output	[7:0]	VGA_OUT_RED,
	output	[7:0]	VGA_OUT_GREEN,
	output	[7:0]	VGA_OUT_BLUE
);

reg		LATCHED_AG;
reg		LATCHED_AS;
reg		LATCHED_EXT;
reg		LATCHED_INV;
reg		[2:0]	LATCHED_GM;
reg		LATCHED_CSS;

wire		pixel_clock;				// generated from SYSTEM CLOCK
wire		reset;						// reset asserted when DCMs are NOT LOCKED

wire	[7:0]	vga_red;				// red video data
wire	[7:0]	vga_green;				// green video data
wire	[7:0]	vga_blue;				// blue video data

// internal video timing signals
wire 			h_synch;					// horizontal synch for VGA connector
wire 			v_synch;					// vertical synch for VGA connector
wire	[10:0]	pixel_count;				// bit mapped pixel position within the line
wire	[9:0]	line_count;					// bit mapped line number in a frame lines within the frame

wire			show_border;

// text
wire	[3:0]	subchar_pixel;				// pixel position within the character
wire	[4:0]	subchar_line;				// identifies the line number within a character block
wire	[6:0]	char_column;				// character number on the current line
wire	[6:0]	char_line;					// line number on the screen

// graph
wire	[8:0]	graph_pixel;				// pixel number on the current line
wire	[9:0]	graph_line_2x;				// line number on the screen
wire	[9:0]	graph_line_3x;				// line number on the screen

/*
wire	[11:0]	ROM_ADDRESS;
wire	[7:0]	ROM_DATA;
*/

assign	reset = ~RESET_N;
assign	pixel_clock = PIX_CLK;

//assign	vga_red = 8'hff;
//assign	vga_green = 8'h7f;
//assign	vga_blue = 8'h7f;

// Character generator
/*
char_rom_4k_altera char_rom(
	.address(ROM_ADDRESS),
	.clock(pixel_clock),
	.q(ROM_DATA)
);
*/

// ???????????????????????????????????????????????????????????????????????????
// In order to prevent the splash screen, mode controls are sampled only on the vertical mode retrace signal.

// ** This is incorrect **
// *REAL* 6847 allows the AS,EXT,CSS and INV signals to be changed on a "character by character basis".

always @ (posedge v_synch or negedge RESET_N)
begin
	if(!RESET_N)
	begin
		LATCHED_AG		<=	1'b0;
		LATCHED_AS		<=	1'b0;
		LATCHED_EXT		<=	1'b0;
		LATCHED_INV		<=	1'b0;
		LATCHED_GM		<=	3'b0;
		LATCHED_CSS		<=	1'b0;
	end
	else
	begin
		LATCHED_AG <= AG;
		LATCHED_AS <= AS;
		LATCHED_EXT <= EXT;
		LATCHED_INV <= INV;
		LATCHED_GM <= GM;
		LATCHED_CSS <= CSS;
	end
end

// instantiate the character generator
PIXEL_DISPLAY PIXEL_DISPLAY(
	.pixel_clock(pixel_clock),
	.reset(reset),
	.show_border(show_border),
	// mode
	.ag(LATCHED_AG),
	.gm(LATCHED_GM),
	.width_64(width_64),
	.css(LATCHED_CSS),
	// text
	.char_column(char_column),
	.char_line(char_line),
	.subchar_line(subchar_line),
	.subchar_pixel(subchar_pixel),
	// graph
	.graph_pixel(graph_pixel),
	.graph_line_2x(graph_line_2x),
	.graph_line_3x(graph_line_3x),
	// vram
	.vram_rd_enable(RD),
	.vram_addr(DA),
	.vram_data(DD),
	// vga
	.vga_red(vga_red),
	.vga_green(vga_green),
	.vga_blue(vga_blue)
);

// instantiate the video timing generator
SVGA_TIMING_GENERATION SVGA_TIMING_GENERATION
(
	.pixel_clock(pixel_clock),
	.reset(reset),
	.h_synch(h_synch),
	.v_synch(v_synch),
	.h_blank(h_blank),
	.v_blank(v_blank),
	.pixel_count(pixel_count),
	.line_count(line_count),
	.show_border(show_border),
	.width_64(width_64),

	// text
	.subchar_pixel(subchar_pixel),
	.subchar_line(subchar_line),
	.char_column(char_column),
	.char_line(char_line),

	// graph
	.graph_pixel(graph_pixel),  
	.graph_line_2x(graph_line_2x),
	.graph_line_3x(graph_line_3x) 
);

// instantiate the video output mux
VIDEO_OUT VIDEO_OUT
(
	.pixel_clock(pixel_clock),
	.reset(reset),
	.vga_red_data(vga_red),
	.vga_green_data(vga_green),
	.vga_blue_data(vga_blue),
	.h_synch(h_synch),
	.v_synch(v_synch),
	.blank(blank),

	.VGA_OUT_HSYNC(VGA_OUT_HSYNC),
	.VGA_OUT_VSYNC(VGA_OUT_VSYNC),
	.VGA_OUT_RED(VGA_OUT_RED),
	.VGA_OUT_GREEN(VGA_OUT_GREEN),
	.VGA_OUT_BLUE(VGA_OUT_BLUE)
);

endmodule
