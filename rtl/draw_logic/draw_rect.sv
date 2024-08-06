`timescale 1 ns / 1 ps

module draw_rect(
    input  logic clk,
    input  logic rst_n, // active low asynchronous reset
    input  logic [11:0] ypos,
    vga_if.in in,
    vga_if.out out
);

import vga_pkg::*;
logic [11:0] rgb_nxt;
logic rst; // synchronous reset

// Instancja synchronizatora resetu
sync_reset u_sync_reset (.clk(clk), .rst_n(rst_n), .rst(rst));

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
        out.rgb    <= '0;
    end else begin
        out.vcount <= in.vcount;
        out.vsync <= in.vsync;
        out.vblnk  <= in.vblnk;
        out.hcount <= in.hcount;
        out.hsync <= in.hsync;
        out.hblnk  <= in.hblnk;
        out.rgb    <= rgb_nxt;
    end
end

always_comb begin
    if (in.vblnk || in.hblnk) begin
        rgb_nxt = 12'h0_0_0; // Blanking region: make it black
    end else begin
        // Active region: Draw rectangle
        if ((in.hcount >= 0) && (in.hcount <= W_OF_REC) && (in.vcount >= ypos) && (in.vcount <= ypos + H_OF_REC)) 
            rgb_nxt = C_OF_REC;
        else
            rgb_nxt = in.rgb;
    end
end

endmodule
