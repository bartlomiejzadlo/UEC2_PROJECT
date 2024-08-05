/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: BZ
 *
 * Description:
 * Draw rectangle.
 */


 `timescale 1 ns / 1 ps

 module draw_rect(
     input  logic clk,
     input  logic rst,
     input  wire [11:0] xpos,
     input  wire [11:0] ypos,
     input logic [11:0] rgb_pixel,
     output logic [11:0] pixel_addr,
     vga_if.in in,
     vga_if.out out
 );
 
     import vga_pkg::*;
     logic [11:0] rgb_out;
     logic [5:0] xaddr;
     logic [5:0] yaddr;
 
     logic [10:0] vcount_nxt;
     logic [10:0] hcount_nxt;
     logic [11:0] rgb_nxt;
     logic [11:0] xpos_nxt;
     logic [11:0] ypos_nxt;
     
     logic [10:0] vcount_nxt2;
     logic [10:0] hcount_nxt2;
     logic [11:0] rgb_nxt2;
     logic [11:0] xpos_nxt2;
     logic [11:0] ypos_nxt2;
 
     logic vsync_nxt, vblnk_nxt,hsync_nxt, hblnk_nxt;
     logic vsync_nxt2, vblnk_nxt2, hsync_nxt2, hblnk_nxt2;
 
     /**
      * Internal logic
      */
     
      always_ff @(posedge clk) begin : rect_ff_blk
         if (rst) begin
             out.vcount <= '0;
             out.vsync  <= '0;
             out.vblnk  <= '0;
             out.hcount <= '0;
             out.hsync <= '0;
             out.hblnk  <= '0;
             out.rgb   <= '0;
             pixel_addr  <= '0;
         end else begin
             out.vcount <= vcount_nxt2;
             out.vsync <= vsync_nxt2;
             out.vblnk  <= vblnk_nxt2;
             out.hcount <= hcount_nxt2;
             out.hsync  <= hsync_nxt2;
             out.hblnk  <= hblnk_nxt2;
             out.rgb   <= rgb_out;
             pixel_addr  <= {yaddr,xaddr};
         end
 
         if (rst) begin
             vcount_nxt <= '0;
             vsync_nxt  <= '0;
             vblnk_nxt  <= '0;
             hcount_nxt <= '0;
             hsync_nxt  <= '0;
             hblnk_nxt  <= '0;
             rgb_nxt    <= '0;
             xpos_nxt   <= '0;
             ypos_nxt   <= '0;
         end else begin
             vcount_nxt <= in.vcount;
             vsync_nxt  <= in.vsync;
             vblnk_nxt  <= in.vblnk;
             hcount_nxt <= in.hcount;
             hsync_nxt <= in.hsync;
             hblnk_nxt  <= in.hblnk;
             rgb_nxt    <= in.rgb;
             xpos_nxt   <= xpos;
             ypos_nxt   <= ypos;
         end
 
         if (rst) begin
             vcount_nxt2 <= '0;
             vsync_nxt2  <= '0;
             vblnk_nxt2  <= '0;
             hcount_nxt2 <= '0;
             hsync_nxt2  <= '0;
             hblnk_nxt2  <= '0;
             rgb_nxt2    <= '0;
             xpos_nxt2   <= '0;
             ypos_nxt2   <= '0;
     
         end else begin
             vcount_nxt2 <= vcount_nxt;
             vsync_nxt2  <= vsync_nxt;
             vblnk_nxt2  <= vblnk_nxt;
             hcount_nxt2 <= hcount_nxt;
             hsync_nxt2 <= hsync_nxt;
             hblnk_nxt2  <= hblnk_nxt;
             rgb_nxt2   <= rgb_nxt;
             xpos_nxt2   <= xpos;
             ypos_nxt2   <= ypos;
         end
     end
 
     always_comb begin
         xaddr = in.hcount - xpos;
         yaddr = in.vcount - ypos;
         if (in.vblnk || in.hblnk) begin             // Blanking region:
             rgb_out = 12'h0_0_0;                    // - make it it black.
         end else begin                              // Active region:
             if ((in.hcount >= xpos) && (in.hcount <= xpos + W_OF_REC) && (in.vcount >= ypos) && (in.vcount <= ypos + H_OF_REC)) 
                 rgb_out = rgb_pixel;
             else
                 rgb_out = in.rgb;
         end
     end
     
 endmodule