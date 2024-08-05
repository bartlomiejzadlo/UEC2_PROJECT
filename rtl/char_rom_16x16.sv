`timescale 1ns/1ps

import vga_pkg::*;

module char_rom_16x16 (
	input  [7:0] char_xy,
	output [6:0] char_code
);

	wire [3:0] row, col;

	localparam [0:31] [7:0] lut = {
		"test1234 xyzwabcHello World!____"
	};

	assign char_code = (row>1) ? " " : lut[{row,col}];
	assign col =       char_xy[7:4];
	assign row =       char_xy[3:0];
endmodule