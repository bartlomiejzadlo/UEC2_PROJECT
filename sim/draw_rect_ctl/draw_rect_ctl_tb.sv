`timescale 1 ns / 1 ps

module draw_rect_ctl_tb;


/**
 *  Local parameters
 */

localparam CLK_PERIOD = 10;     // 100 MHz
localparam CLK_PERIOD25 = 25;   // 40MHz

/**
 * Local variables and signals
 */

logic clk100MHz, clk40MHz, rst;
wire vs, hs;
logic left;
wire [3:0] r, g, b;
wire [11:0] mouse_xpos;
wire [11:0] mouse_ypos;
wire [11:0] rect_ctl_xpos;
wire [11:0] rect_ctl_ypos;
wire [11:0] mouse_xpos_sync=0;
wire [11:0] mouse_ypos_sync=0;
wire [11:0] rgb_rom;
wire [11:0] adress_rom;

/**
 * Clock generation
 */

initial begin
    clk100MHz = 1'b0;
    forever #(CLK_PERIOD/2) clk100MHz = ~clk100MHz;
end

initial begin
    clk40MHz = 1'b0;
    forever #(CLK_PERIOD25/2) clk40MHz = ~clk40MHz;
end

 //VGA interfaces
vga_if tim_bg_if();
vga_if bg_rect_if();
vga_if rect_out_if();
vga_if draw_mouse_if();



/**
 * Signals assignments
 */

assign vs = draw_mouse_if.vsync;
assign {r,g,b} = draw_mouse_if.rgb;

draw_rect_ctl u_dut(
    .clk(clk100MHz),
    .rst(rst),
    .mouse_x_pos(mouse_xpos_sync),
    .mouse_y_pos(mouse_ypos_sync),
    .ypos(rect_ctl_ypos),
    .xpos(rect_ctl_xpos),
    .left(left)
);

tiff_writer #(
    .XDIM(16'd1056),
    .YDIM(16'd628),
    .FILE_DIR("../../results")
) u_tiff_writer (
    .clk(clk40MHz),
    .r({r,r}), // fabricate an 8-bit value
    .g({g,g}), // fabricate an 8-bit value
    .b({b,b}), // fabricate an 8-bit value
    .go(vs)
);
/*
synchr u_synchr(
    .clk(clk40MHz),
    .rst(rst),
    .rect_x_pos_in(mouse_xpos),
    .rect_y_pos_in(mouse_ypos),
    .rect_x_pos_out(mouse_xpos_sync),
    .rect_y_pos_out(mouse_ypos_sync),
    .left_in(left_mouse),
    .left_out(left_synchr)
 );*/


  draw_mouse u_draw_mouse(
    .in(rect_out_if.in),
    .out(draw_mouse_if.out),
    .mouse_x_pos(mouse_xpos_sync),
    .mouse_y_pos(mouse_ypos_sync),
    .clk(clk40MHz),
    .rst(rst)
 );

 image_rom u_image_rom(
    .rgb(rgb_rom),
    .address(adress_rom),
    .clk(clk40MHz)
 );


 vga_timing u_vga_timing (
     .clk(clk40MHz),
     .rst,
     .out(tim_bg_if.out)
 );
 
 draw_bg u_draw_bg (
     .clk(clk40MHz),
     .rst,
     .in(tim_bg_if.in),
     .out(bg_rect_if.out)
 );
 
 draw_rect u_draw_rect (
     .clk(clk40MHz),
     .rst,
     .rect_x_pos(rect_ctl_xpos),
     .rect_y_pos(rect_ctl_ypos),
     .address(adress_rom),
     .rgb(rgb_rom),
     .in(bg_rect_if.in),
     .out(rect_out_if.out)
 );
/*
 MouseCtl u_MouseCtl(
    .clk(clk100MHz),
    .rst(rst),
    .xpos(mouse_xpos),
    .ypos(mouse_ypos),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),

    .zpos(),
    .left(left_mouse),
    .middle(),
    .right(),
    .new_event(),
    .value(),
    .setx(),
    .sety(),
    .setmax_x(),
    .setmax_y()
 );*/



initial begin
    rst = 1'b0;
    # 1000 rst = 1'b1;
    # 2000 rst = 1'b0;
    
    left = 1'b0;
    # 1000 left = 1'b1;
    # 4000 left = 1'b0;


    $display("If simulation ends before the testbench");
    $display("completes, use the menu option to run all.");
    $display("Prepare to wait a long time...");

    wait (vs == 1'b0);
    @(negedge vs) $display("Info: negedge VS at %t",$time);
    @(negedge vs) $display("Info: negedge VS at %t",$time);




    // End the simulation.
    $display("Simulation is over, check the waveforms.");
    $finish;
end


endmodule
