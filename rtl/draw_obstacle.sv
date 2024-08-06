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

    // Rejestry dla losowych zakresów
    //reg [9:0] obstacle_y_start1, obstacle_y_end1;
    //reg [9:0] obstacle_y_start2, obstacle_y_end2;
    //reg [24:0] counter; // Licznik do generowania nowych losowych wartości co 0.5 sekundy

    // Logika aktualizacji zakresów co 0.5 sekundy
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out.vcount <= '0;
            out.vsync  <= '0;
            out.vblnk  <= '0;
            out.hcount <= '0;
            out.hsync <= '0;
            out.hblnk  <= '0;
            out.rgb   <= '0;
            //counter <= 0;
            //obstacle_y_start1 <= $urandom_range(100, 250);
            //obstacle_y_start2 <= $urandom_range(350, 500);
        end else begin
            out.vcount <= in.vcount;
            out.vsync <= in.vsync;
            out.vblnk  <= in.vblnk;
            out.hcount <= in.hcount;
            out.hsync <= in.hsync;
            out.hblnk  <= in.hblnk;
            out.rgb   <= rgb_nxt;

            /*
            if (counter < 20_000_000) begin
                counter <= counter + 1;
            end else begin
                // Generowanie nowych losowych wartości co 0.5 sekundy
                counter <= 0;
               //obstacle_y_start1 <= $urandom_range(100, 250);
               // obstacle_y_start2 <= $urandom_range(350, 500);
            end
            */
        end
    end

    always_comb begin : bg_comb_blk
        if (in.vblnk || in.hblnk) begin
            rgb_nxt = 12'h0_0_0; // Blanking region: make it black
        end else begin
            // Active region: Draw obstacles with random vertical positions
            if ((in.hcount >= obstacle_xpos_1) && (in.hcount <= obstacle_xpos_1 + 49) && 
                (in.vcount >= 0) && (in.vcount <= obstacle_ypos_1))

                rgb_nxt = 12'hf_f_0; // Top obstacle
            else if ((in.hcount >= obstacle_xpos_1) && (in.hcount <= obstacle_xpos_1 + 49) && 
                         (in.vcount >= obstacle_ypos_2) && (in.vcount <= VER_PIXELS - 1))
                rgb_nxt = 12'hf_f_0; // Bottom obstacle
            else
                rgb_nxt = in.rgb; // Default to background color
            end
        end


endmodule
