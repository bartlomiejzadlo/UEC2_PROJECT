/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 * Modified by BZ and WS for variable management purposes
 */

package vga_pkg;


localparam HOR_PIXELS = 1024;
localparam VER_PIXELS = 768;

localparam HOR_TOT_PIX = 1344; 
localparam VER_TOT_PIX = 806;

localparam HOR_SYNC_START = 1048; 
localparam VER_SYNC_START = 771; 

localparam HOR_SYNC_END = 1184; 
localparam VER_SYNC_END = 777; 

localparam W_OF_REC = 49;
localparam H_OF_REC = 63;
localparam C_OF_REC = 12'ha_f_0;

/**
 * States
 */
localparam IDLE = 3'b000;
localparam DOWN = 3'b001;
localparam UP = 3'b010;

localparam START = 3'b001;
localparam ENDGAME = 3'b100;

typedef struct packed {
	int x;
	int y;
	
	byte rows;
	byte columns;

	byte cwidth;
	byte cheight;
} font_rect;

function logic between(input int v, s, e);
	return (v >= s) && (v < e);
endfunction

function logic in_rect(input int hc, vc, x, y, w, h);
	return between(hc, x, x + w) && between(vc, y, y + h);
endfunction

endpackage
