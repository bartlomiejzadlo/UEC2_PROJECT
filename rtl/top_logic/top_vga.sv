`timescale 1 ns / 1 ps

 module top_vga (
     input  logic clk40MHz,
     input  logic clk100MHz,
     input  logic rst,
     input  logic opponent_failed,
     output logic you_failed,
     output logic vs,
     output logic hs,
     output logic [3:0] r,
     output logic [3:0] g,
     output logic [3:0] b,
     inout  wire  ps2_clk,
     inout  wire  ps2_data
 );
 
 // Przypisania sygnałów
 assign vs = dfont_dmouse_if.vsync;
 assign hs = dfont_dmouse_if.hsync;
 assign {r,g,b} = dfont_dmouse_if.rgb;
 
 // Lokalne zmienne i sygnały
 import vga_pkg::*;
 
 wire [11:0] rect_ctl_ypos;
 wire left_sync;
 wire right_sync;
 logic game_lost, game_over;
 
 wire endgame_from_rect, endgame_from_obstacle;  // Sygnał endgame
 
 wire [11:0] obstacle_ctl_xpos_1, obstacle_ctl_ypos_1, obstacle_ctl_ypos_2;

 assign game_lost = endgame_from_obstacle || endgame_from_rect;
 assign you_failed = game_lost;

 assign game_over = opponent_failed || you_failed;


 // Deklaracje interfejsów
 vga_if tim_dbg_if();
 vga_if dbg_drect_if();
 vga_if pl2_if();
 vga_if drect_do_if();
 vga_if do_dmouse_if();
 vga_if do_dfont_if();
 vga_if dfont_dmouse_if();
 
 localparam font_rect font_params = '{
     x: 325,
     y: 100,
 
     rows:    16,
     columns: 16,
 
     cwidth:  8,
     cheight: 16
 };
 
 logic [7:0] char_pixel;
 logic [3:0] char_line;
 logic [6:0] char_code;
 logic [7:0] char_xy;
 
 /**
  * Instancje modułów
  */
 
 vga_timing u_vga_timing (
     .clk(clk40MHz),
     .rst,
     .out(tim_dbg_if)
 );
 
 draw_bg u_draw_bg (
     .clk(clk40MHz),
     .rst,
     .in(tim_dbg_if),
     .out(dbg_drect_if)
 );
 
 MouseCtl u_MouseCtl (
     .clk(clk100MHz),
     .rst,
     .ps2_clk(ps2_clk),
     .ps2_data(ps2_data),
     .left(left_sync),
     .right(right_sync),
     .xpos(),
     .ypos(),

     .zpos(),
     .middle(),
     .new_event(),
     .value(12'b0),
     .setx(1'b0),
     .sety(1'b0),
     .setmax_x(1'b0),
     .setmax_y(1'b0)
 );
 
 draw_rect u_draw_rect (
     .clk(clk40MHz),
     .rst,
     .ypos(rect_ctl_ypos),
     .in(dbg_drect_if),
     .out(drect_do_if)
 );


//  draw_mouse u_draw_mouse (
//      .clk40MHz(clk40MHz),
//      .rst,
//      //.xpos(xpos),
//      //.ypos(ypos),
//      .in(dfont_dmouse_if),
//      .out(dfont_dmouse_if)
//  );
 
 // Moduł kontrolujący ruch klocka
 draw_rect_ctl u_draw_rect_ctl(
     .clk(clk40MHz),
     .rst,
     .ypos(rect_ctl_ypos),
     .endgame_from_obstacle(endgame_from_obstacle),
     .endgame_from_rect(endgame_from_rect),         // Podłączenie sygnału endgame z draw_obstacle_ctl
     .left(left_sync),
     .right(right_sync)
 );
 
 // Moduł kontrolujący przeszkodę
 draw_obstacle_ctl u_draw_obstacle_ctl(
     .clk(clk40MHz),
     .rst,
     .y_from_draw_rect(rect_ctl_ypos),
     .endgame_from_rect(endgame_from_rect),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .obstacle_xpos_1(obstacle_ctl_xpos_1),
     .endgame_from_obstacle(endgame_from_obstacle)          // Generowanie sygnału endgame w momencie kolizji
 );
 
 // Moduł rysujący przeszkodę
 draw_obstacle u_draw_obstacle (
     .clk(clk40MHz),
     .rst,
     .obstacle_xpos_1(obstacle_ctl_xpos_1),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .in(drect_do_if),
     .out(do_dfont_if)
 );
 
 // Moduł rysujący tekst końca gry
 draw_rect_char #(
     .p(font_params)
 ) u_draw_rect_char (
     .clk(clk40MHz),
     .char_pixel(char_pixel),
     .char_xy(char_xy),
     .char_line(char_line),
     .endgame(game_over),         // Użycie sygnału endgame do sygnalizowania końca gry
     .in(do_dfont_if),
     .out(dfont_dmouse_if)
 );
 
 // Pamięć znaków
 char_rom_16x16 u_char_rom_16x16 (
     .char_xy(char_xy),
     .char_code(char_code)
 );
 
 // ROM fontu
 font_rom u_font_rom(
     .clk(clk40MHz),
     .addr({char_code, char_line}),
     .char_line_pixels(char_pixel)
 );
 
 endmodule
