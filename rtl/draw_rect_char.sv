`timescale 1ns/1ps

import vga_pkg::*;

`define default_font_config '{ \
	x:0, y:0, \
	rows:16, columns: 16, \
	cwidth:8, cheight: 16 \
}

module char_addr #(
	font_rect p = `default_font_config
)(
	input logic [10:0] x,
	input logic [10:0] y,

	output logic [7:0] char_xy,
	output logic [3:0] char_line
);

	logic [3:0] row, col;

	always_comb begin
		col = (x - p.x) / p.cwidth;
		row = (y - p.y) / p.cheight;
		
		char_xy = {col, row};
		char_line <= (y - p.y) % p.cheight;
	end

endmodule

module draw_rect_char #(
	font_rect p = `default_font_config
)(
	input logic clk,

	input  logic [7:0] char_pixel,

	output logic [7:0] char_xy,
	output logic [3:0] char_line,

	vga_if.in in,
	vga_if.out out
);

	logic        active_area;
	logic [11:0] rgb;

	char_addr #(
		.p(p)
	) u_char_addr (
		.y(in.vcount),
		.x(in.hcount),

		.char_xy(char_xy),
		.char_line(char_line)
	);

	always_comb begin
		out.vsync  <= in.vsync;
		out.vblnk  <= in.vblnk;
		out.hsync  <= in.hsync;
		out.hblnk  <= in.hblnk;

	        out.vcount <= in.vcount;
        	out.hcount <= in.hcount;

		out.rgb <= rgb;
	end	


	always_comb begin
		active_area <= in_rect(
			in.hcount,
			in.vcount,
			p.x,
			p.y,
			p.cwidth * p.columns,
			p.cheight * p.rows
		);
	end

	always @(posedge clk) begin
		if (active_area) begin
			if (char_pixel[(p.x - in.hcount) % p.cwidth])
				rgb <= 'hfff;
			else
				rgb <= 'h000;
		end else begin
			rgb <= in.rgb;
		end
	end

endmodule