module CHAR_GEN(
	// control
	input		reset,
	
	input		pixel_clock,

	input		GM0,
	input		width_64,
	// select 64x32 Text mode

	
	input	[7:0]	char_code,
	input	[4:0]	subchar_line,		// line number within 12 line block	0-31
	
	input	[3:0]	subchar_pixel,		// pixel position within 8 pixel block  0-16
	
	
	output	reg	pixel_on


);

reg		[7:0]	latched_data;


//wire [11:0] rom_addr = {char_code[7:0], subchar_line[3:0]};	// every line displayed once	- 64x32

//wire	[11:0]	rom_addr = {char_code[7:0], subchar_line[4:1]};	// every line displayed twice	normal - 32x16



wire [11:0] rom_addr = (width_64)? {char_code[7:0], subchar_line[3:0]}: {char_code[7:0], subchar_line[4:1]};


wire	[7:0]	rom_data;
 
// characters organised as 8 bits x 16 bytes in the ROM. Only 12 rows are displayed.
// Both text and graphics are in the ROM 

wire lcase_add = GM0 & !(rom_addr[11] | rom_addr[10] | rom_addr[9]);		// A[11:9] = char[7:5]  $00-$1F
// test only
//wire lcase_add = !(rom_addr[11] | rom_addr[10] | rom_addr[9]);		// A[11:9] = char[7:5]  $00-$1F

`ifdef LCASE
sprom #(
	.init_file("./roms/charrom_4k_lcase.mif"),
	.widthad_a(13),
	.width_a(8))
CHAR_GEN_ROM(
	.address({lcase_add,rom_addr}),
	.clock(pixel_clock),
	.q(rom_data)
	);

`else
sprom #(
	`ifndef VERILATOR
		.init_file("./roms/charrom_4k.mif"),
	`else
		.init_file("./roms/charrom_4k.hex"),
	`endif
	.widthad_a(12),
	.width_a(8))
CHAR_GEN_ROM(
	.address(rom_addr),
	.clock(pixel_clock),
	.q(rom_data)
	);
`endif


// serialize the CHARACTER MODE data
always @ (posedge pixel_clock or posedge reset) begin
	if (reset)
 		begin
			pixel_on <= 1'b0;
			latched_data  <= 8'h00;
		end

	else begin
		case(subchar_pixel)
			4'b0101:
				latched_data [7:0] <= {rom_data[0],rom_data[1],rom_data[2],rom_data[3],rom_data[4],rom_data[5],rom_data[6],rom_data[7]};
			default:
			begin
				
				if (width_64)
					{pixel_on,latched_data [7:1]} <= latched_data [7:0];		// 64x32 text mode
				else
	
					if(subchar_pixel[0]==1'b0)		// each pixel displays for 2 clocks = 256*2 = 512 horizontal pixels
						{pixel_on,latched_data [7:1]} <= latched_data [7:0];	// 32x16 text mode
	
			end

		endcase
	end
end

endmodule //CHAR_GEN
