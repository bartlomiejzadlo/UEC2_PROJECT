/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: BZ
 *
 * Description:
 * Make an interface
 */


 `timescale 1 ns / 1 ps

 
 interface vga_if;
    
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;

    logic [11:0] rgb;

modport in (
    input vcount, vsync, vblnk, hcount, hsync, hblnk, rgb
);

modport out (
    output vcount, vsync, vblnk, hcount, hsync, hblnk, rgb
);

endinterface