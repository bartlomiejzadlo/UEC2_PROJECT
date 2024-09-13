// Modified by BZ and WS

`timescale 1 ns / 1 ps

 module top_vga (
     input  logic clk75MHz,
     input  logic clk100MHz,
     input  logic rst,
     input  logic [7:0] player2_ypos,
     input  logic pl2_endgame,
     output logic my_endgame,
     output logic [7:0] my_ypos,
     output logic vs,
     output logic hs,
     output logic [3:0] r,
     output logic [3:0] g,
     output logic [3:0] b,
     inout  wire  ps2_clk,
     inout  wire  ps2_data
 );
 
 assign vs = dfont_dmouse_if.vsync;
 assign hs = dfont_dmouse_if.hsync;
 assign {r,g,b} = dfont_dmouse_if.rgb;
 
 import vga_pkg::*;
 
 wire [11:0] rect_ctl_ypos;
 logic [11:0] player2_ypos_scaled;
 wire left_sync;
 wire right_sync;
 
 wire endgame_from_rect, endgame_from_obstacle; 
 logic endgame, endgame_from_rect_wp2, endgame_from_obstacle_wp2;


 
 wire [11:0] obstacle_ctl_xpos_1, obstacle_ctl_ypos_1, obstacle_ctl_ypos_2;

 assign player2_ypos_scaled = {player2_ypos, 4'b0};
 assign my_ypos = rect_ctl_ypos[11:4];


 vga_if tim_dbg_if();
 vga_if dbg_drect_if();
 vga_if pl2_if();
 vga_if drect_do_if();
 vga_if do_dmouse_if();
 vga_if do_dfont_if();
 vga_if dfont_dmouse_if();
 
 localparam font_rect font_params = '{
     x: 480,
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
 endgame_manager u_endgame_manager(
    .clk(clk75MHz),
    .rst,
    .pl2_endgame,

    .endgame_cond1(endgame_from_rect),
    .endgame_cond2(endgame_from_obstacle),

    .endgame_cond1_withpl1(endgame_from_rect_wp2),
    .endgame_cond1_withpl2(endgame_from_obstacle_wp2),
    .my_endgame,
    .endgame
);


 vga_timing u_vga_timing (
     .clk(clk75MHz),
     .rst,
     .out(tim_dbg_if)
 );
 
 draw_bg u_draw_bg (
     .clk(clk75MHz),
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
     .clk(clk75MHz),
     .rst,
     .ypos(rect_ctl_ypos),
     .in(dbg_drect_if),
     .out(pl2_if)
 );


 draw_rect u_draw_rect_pl2 (
     .clk(clk75MHz),
     .rst,
     .ypos(player2_ypos_scaled),
     .in(pl2_if),
     .out(drect_do_if)
 );

 draw_rect_ctl u_draw_rect_ctl(
     .clk(clk75MHz),
     .rst,
     .ypos(rect_ctl_ypos),
     .endgame_from_obstacle(endgame_from_obstacle_wp2),
     .endgame_from_rect(endgame_from_rect), 
     .left(left_sync),
     .right(right_sync)
 );
 
 draw_obstacle_ctl u_draw_obstacle_ctl(
     .clk(clk75MHz),
     .rst,
     .y_from_draw_rect(rect_ctl_ypos),
     .endgame_from_rect(endgame_from_rect_wp2),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .obstacle_xpos_1(obstacle_ctl_xpos_1),
     .endgame_from_obstacle(endgame_from_obstacle)    
 );
 

 draw_obstacle u_draw_obstacle (
     .clk(clk75MHz),
     .rst,
     .obstacle_xpos_1(obstacle_ctl_xpos_1),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .in(drect_do_if),
     .out(do_dfont_if)
 );
 

 draw_rect_char #(
     .p(font_params)
 ) u_draw_rect_char (
     .clk(clk75MHz),
     .char_pixel(char_pixel),
     .char_xy(char_xy),
     .char_line(char_line),
     .endgame,         
     .in(do_dfont_if),
     .out(dfont_dmouse_if)
 );
 

 char_rom_16x16 u_char_rom_16x16 (
     .char_xy(char_xy),
     .char_code(char_code)
 );
 

 font_rom u_font_rom(
     .clk(clk75MHz),
     .addr({char_code, char_line}),
     .char_line_pixels(char_pixel)
 );
 
 endmodule
