`timescale 1ns / 1ps

module tb_draw_rect_char;
    // Sygnały testbench
    logic clk;
    logic rst;
    logic endgame;
    logic [7:0] char_pixel;
    logic [7:0] char_xy;
    logic [3:0] char_line;
    vga_if.in in;
    vga_if.out out;

    // Instancja modułu
    draw_rect_char uut (
        .clk(clk),
        .char_pixel(char_pixel),
        .endgame(endgame),
        .char_xy(char_xy),
        .char_line(char_line),
        .in(in),
        .out(out)
    );

    // Generowanie zegara
    initial begin
        clk = 0;
        forever #12.5 clk = ~clk; // Zegar 40 MHz (okres 25 ns)
    end

    // Symulacja
    initial begin
        // Reset na 40 ns
        rst = 1;
        endgame = 0;
        char_pixel = 8'b0;
        in.vcount = 0;
        in.hcount = 0;
        in.vsync = 0;
        in.vblnk = 0;
        in.hsync = 0;
        in.hblnk = 0;
        in.rgb = 12'h000;
        #40;
        rst = 0;

        // Symulacja aktywnego obszaru
        #100;
        in.hcount = 50;
        in.vcount = 50;
        #50;

        // Symulacja końca gry
        #200;
        endgame = 1;
        char_pixel = 8'b10101010; // Przykładowe wartości dla char_pixel
        #50;

        // Zatrzymanie symulacji po 1 sekundzie
        #1_000_000_000;
        $stop;
    end

    // Monitorowanie
    initial begin
        $monitor("Time: %0t | vsync: %0b | vblnk: %0b | hsync: %0b | hblnk: %0b | vcount: %0d | hcount: %0d | rgb: %0h | endgame: %0b | char_xy: %0h | char_line: %0h", 
                 $time, out.vsync, out.vblnk, out.hsync, out.hblnk, out.vcount, out.hcount, out.rgb, endgame, char_xy, char_line);
    end
endmodule
