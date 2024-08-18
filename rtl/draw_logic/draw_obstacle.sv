`timescale 1 ns / 1 ps

module draw_obstacle(
    input  logic clk,
    input  logic rst,
    input  logic [11:0] obstacle_xpos_1,
    input  logic [11:0] obstacle_ypos_1,
    input  logic [11:0] obstacle_ypos_2,

    vga_if.in in,
    vga_if.out out
);

    import vga_pkg::*;
    logic [11:0] rgb_nxt;



    always_ff @(posedge clk) begin
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
            out.hsync <= in.hsync;
            out.hblnk  <= in.hblnk;
            out.rgb   <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = 12'h0_0_0;
        end else begin
            if ((in.hcount >= obstacle_xpos_1) && (in.hcount <= obstacle_xpos_1 + 49) && 
                (in.vcount >= 0) && (in.vcount <= obstacle_ypos_1))
                rgb_nxt = 12'hf_f_0; 
            else if ((in.hcount >= obstacle_xpos_1) && (in.hcount <= obstacle_xpos_1 + 49) && 
                         (in.vcount >= obstacle_ypos_2) && (in.vcount <= VER_PIXELS - 1))
                rgb_nxt = 12'hf_f_0; 
            else
                rgb_nxt = in.rgb; 
            end
        end


endmodule
