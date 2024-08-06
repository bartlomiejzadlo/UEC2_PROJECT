/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

`timescale 1 ns / 1 ps

module vga_timing (
    input  logic clk,
    input  logic rst,
    vga_if.out out
);

import vga_pkg::*;

 // Declare counters
logic [10:0] hcounter_nxt;
logic [10:0] vcounter_nxt;
logic hblnk_nxt;
logic vblnk_nxt;
logic hsync_nxt;
logic vsync_nxt;

 // horizontal counter  
always_ff @(posedge clk) begin
    if (rst) begin
        out.hcount <= 0;
    end else begin
        out.hcount <= hcounter_nxt;
    end
end

always_comb begin
    if (out.hcount == HOR_TOT_PIX - 1) //1055
        hcounter_nxt = 0;
    else
        hcounter_nxt = out.hcount + 1;
end



// vertical counter
always_ff @(posedge clk) begin
    if (rst) begin
        out.vcount<= 0;
    end else begin
        out.vcount <= vcounter_nxt;
    end
end

always_comb begin
    if (out.hcount == HOR_TOT_PIX - 1) //1055
        if (out.vcount == VER_TOT_PIX - 1) //627
            vcounter_nxt = 0;
        else
            vcounter_nxt = out.vcount + 1;
    else vcounter_nxt = out.vcount; 
end


//sync/blanck

always_ff @(posedge clk) begin
    if(rst) begin
        out.hblnk <= 0;
        out.vblnk <= 0;
        out.hsync <= 0;
        out.vsync <= 0;
        out.rgb<=12'h0_0_0;
    end else begin
        out.hblnk <= hblnk_nxt;
        out.vblnk <= vblnk_nxt;
        out.hsync <= hsync_nxt;
        out.vsync = vsync_nxt;
        out.rgb<=12'h0_0_0;
    end
end

always_comb begin
    if(out.hcount >= HOR_SYNC_START - 1 && out.hcount < HOR_SYNC_END - 1) //839 && 967
        hsync_nxt = 1;
    else
        hsync_nxt = 0;

    if(out.hcount == HOR_TOT_PIX-1) begin
        if (out.vcount >= VER_PIXELS - 1  && out.vcount < VER_TOT_PIX - 1) //599 && 627
            vblnk_nxt = 1;
        else
            vblnk_nxt = 0;

        if (out.vcount >= VER_SYNC_START - 1 && out.vcount < VER_SYNC_END - 1) //600 && 604
            vsync_nxt = 1;
        else
            vsync_nxt = 0;
    end else begin
        vsync_nxt=out.vsync;
        vblnk_nxt=out.vblnk;
    end

    if(out.hcount >= HOR_PIXELS - 1 && out.hcount < HOR_TOT_PIX - 1) //799 && 1055 
        hblnk_nxt = 1;
    else
        hblnk_nxt = 0;

end

endmodule

// <= 1055-1 -> <= 1054
// <1056 -1 -> <1055