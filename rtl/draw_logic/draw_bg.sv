/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */



 `timescale 1 ns / 1 ps

 module draw_bg(
     input  logic clk,
     input  logic rst,
     vga_if.in in,
     vga_if.out out   
 );
    
     
     logic [11:0] rgb_nxt;
     import vga_pkg::*;

     /**
      * Internal logic
      */
     
     always_ff @(posedge clk) begin : bg_ff_blk
         if (rst) begin
             out.vcount <= '0;
             out.vsync  <= '0;
             out.vblnk  <= '0;
             out.hcount <= '0;
             out.hsync <= '0;
             out.hblnk  <= '0;
             out.rgb   <= '0;
         end else begin
             out.vcount <= in.vcount;
             out.vsync <= in.vsync;
             out.vblnk  <= in.vblnk;
             out.hcount <= in.hcount;
             out.hsync  <= in.hsync;
             out.hblnk  <= in.hblnk;
             out.rgb   <= rgb_nxt;
         end
     end
     
     always_comb begin : bg_comb_blk
         if (in.vblnk || in.hblnk) begin             // Blanking region:
             rgb_nxt = in.rgb;                    // - make it it black.
         end else begin                              // Active region:
                 rgb_nxt = 12'h8_8_8;                // - fill with gray.
         end
     end
     
 endmodule