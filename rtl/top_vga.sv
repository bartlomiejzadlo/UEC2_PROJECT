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
wire [11:0] xpos; //mouse_xpos
wire [11:0] ypos; 
wire [11:0] xpos_d; //mouse_xpos_sync
wire [11:0] ypos_d;

wire [11:0] pixel_address;
wire [11:0] pixel_rgb;

wire [11:0] rect_ctl_ypos, rect_ctl_xpos;
wire left_mouse, left_sync;


//declarations of interfaces
vga_if tim_dbg_if();
vga_if dbg_drect_if();
vga_if drect_dmouse_if();
vga_if dmouse_out_if();

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
    .xpos(xpos_d),
    .ypos(ypos_d)
);

d_bufor u_d_bufor(
    .clk(clk40MHz),
    .xpos_nxt(xpos_d),
    .ypos_nxt(ypos_d),
    .xpos(xpos),
    .ypos(ypos)
);


draw_rect u_draw_rect (
    .clk(clk40MHz),
    .rst,
    .xpos(xpos),
    .ypos(ypos),
    .in(dbg_drect_if),
    .out(drect_dmouse_if),
    .rgb_pixel(pixel_rgb),
    .pixel_addr(pixel_address)
);

draw_mouse u_draw_mouse (
    .clk40MHz(clk40MHz),
    .rst,
    .xpos(xpos),
    .ypos(ypos),
    .in(drect_dmouse_if),
    .out(dmouse_out_if)
);

image_rom u_image_rom(
    .clk(clk40MHz),
    .rgb(pixel_rgb),
    .address(pixel_address)

);

draw_rect_ctl u_draw_rect_ctl(
    .clk(clk100MHz),
    .rst(rst),
    .mouse_x_pos(xpos),
    .mouse_y_pos(ypos),
    .ypos(rect_ctl_ypos),
    .xpos(rect_ctl_xpos),
    .left(left_sync)
);


/*synchr u_synchr(
    .clk(clk40MHz),
    .rst(rst),
    .rect_x_pos_in(xpos_d),
    .rect_y_pos_in(ypos_d),
    .rect_x_pos_out(xpos),
    .rect_y_pos_out(ypos),
    .left_in(left_mouse),
    .left_out(left_sync)
 );
*/
endmodule
