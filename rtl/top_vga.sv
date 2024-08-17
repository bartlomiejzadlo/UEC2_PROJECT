/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2023  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

 `timescale 1 ns / 1 ps

 module top_vga (
     input  logic clk40MHz,
     input logic clk100MHz,
     input  logic rst,
     output logic vs,
     output logic hs,
     output logic [3:0] r,
     output logic [3:0] g,
     output logic [3:0] b,
     inout  wire  ps2_clk,
     inout  wire  ps2_data
 );
 
 
 /**
  * Signals assignments
  */
 
 assign vs = dmouse_out_if.vsync;
 assign hs = dmouse_out_if.hsync;
 assign {r,g,b} = dmouse_out_if.rgb;
 
 
 /**
 * Local variables and signals
 */
 import vga_pkg::*;
 wire [11:0] xpos; //mouse_xpos
 wire [11:0] ypos; 
 wire [11:0] xpos_d; //mouse_xpos_sync
 wire [11:0] ypos_d;
 
 wire [11:0] pixel_address;
 wire [11:0] pixel_rgb;
 
 wire [11:0] rect_ctl_ypos, rect_ctl_xpos;
 wire left_sync;
 wire right_sync;

 wire endgame;
 
 wire [11:0] obstacle_ctl_xpos_1, obstacle_ctl_ypos_1, obstacle_ctl_ypos_2;
 
 
 //declarations of interfaces
 vga_if tim_dbg_if();
 vga_if dbg_drect_if();
 vga_if drect_do_if();
 vga_if do_dmouse_if();
 vga_if do_dfont_if();
 vga_if dfont_dmouse_if();
 vga_if dmouse_out_if();
 
 
 
 localparam font_rect font_params = '{
     x: 200,
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
  * Submodules instances
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
     .xpos(xpos_d),
     .ypos(ypos_d)
 );
 
 
 draw_rect u_draw_rect (
     .clk(clk40MHz),
     .rst,
     .ypos(rect_ctl_ypos),
     .in(dbg_drect_if),
     .out(drect_do_if)
 );
 
 draw_mouse u_draw_mouse (
     .clk40MHz(clk40MHz),
     .rst,
     .xpos(xpos),
     .ypos(ypos),
     .in(dfont_dmouse_if),
     .out(dmouse_out_if)
 );
 

 draw_rect_ctl u_draw_rect_ctl(
     .clk(clk100MHz),
     .rst(rst),
     .ypos(rect_ctl_ypos),
     .endgame(endgame),
     .left(left_sync),
     .right(right_sync)
 );
 
 draw_obstacle_ctl u_draw_obstacle_ctl(
     .clk(clk40MHz),
     .rst(rst),
     .y_from_draw_rect(rect_ctl_ypos),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .obstacle_xpos_1(obstacle_ctl_xpos_1)
 );
 
 
 draw_obstacle u_draw_obstacle (
     .clk(clk40MHz),
     .rst(rst),
     .obstacle_xpos_1(obstacle_ctl_xpos_1),
     .obstacle_ypos_1(obstacle_ctl_ypos_1),
     .obstacle_ypos_2(obstacle_ctl_ypos_2),
     .in(drect_do_if),
     .out(do_dfont_if)
 );
 

 draw_rect_char #(
     .p(font_params)
 ) u_draw_rect_char (
     .clk(clk40MHz),
 
     .char_pixel(char_pixel),
     .char_xy(char_xy),
     .char_line(char_line),

     .endgame(endgame),
 
     .in(do_dfont_if),
     .out(dfont_dmouse_if)
 );
 
 char_rom_16x16 u_char_rom_16x16 (
     .char_xy(char_xy),
     .char_code(char_code)
 );
 
 font_rom u_font_rom(
     .clk(clk40MHz),
     .addr({char_code, char_line}),
     .char_line_pixels(char_pixel)
 );
 
 
 
 endmodule
 