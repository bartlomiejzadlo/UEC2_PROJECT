/**
 *  Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

 `timescale 1 ns / 1 ps

 module vga_timing_tb;
 
 import vga_pkg::*;
 
 
 /**
  *  Local parameters
  */
 
 localparam CLK_PERIOD = 25;     // 40 MHz
 
 
 /**
  * Local variables and signals
  */
 
 logic clk;
 logic rst;
 
 wire [10:0] vcount, hcount;
 wire        vsync,  hsync;
 wire        vblnk,  hblnk;
 
 
 /**
  * Clock generation
  */
 
 initial begin
     clk = 1'b0;
     forever #(CLK_PERIOD/2) clk = ~clk;
 end
 
 
 /**
  * Reset generation
  */
 
 initial begin
                        rst = 1'b0;
     #(1.25*CLK_PERIOD) rst = 1'b1;
                        rst = 1'b1;
     #(2.00*CLK_PERIOD) rst = 1'b0;
 end
 
 
 /**
  * Dut placement
  */
 
 vga_timing dut(
     .clk,
     .rst,
     .vcount,
     .vsync,
     .vblnk,
     .hcount,
     .hsync,
     .hblnk
 );
 
 /**
  * Tasks and functions
  */
 
  // Here you can declare tasks with immediate assertions (assert).
 task test_hcount_max;
     assert (hcount <= HOR_TOT_PIX - 1) //1055
         $display("hcount is correct");
     else 
         $error("hcount is above good value");
 endtask
 
 task test_vcount_max;
     assert (vcount <= VER_TOT_PIX - 1) //627
         $display("vcount is correct");
     else 
         $error("vcount is above good value");
 endtask
 
 /**
  * Assertions
  */
 
 // Here you can declare concurrent assertions (assert property).
 
 //hblnk test
  assert property (@(posedge clk) ((hcount >= HOR_PIXELS - 1) && (hcount < HOR_TOT_PIX - 1) |-> (hblnk == 1))) else //799 && 1055
 $error("hlbkn is not correct");
 
 //vblnk test
 assert property (@(posedge clk) ((vcount >= VER_PIXELS - 1) && (vcount < VER_TOT_PIX - 1) |-> (vblnk == 1))) else //599 && 627
 $error("vlbkn is not correct");
 
 
 //hsync test
 assert property (@(posedge clk) ((hcount >= HOR_SYNC_START - 1) && (hcount < HOR_SYNC_END - 1) |-> (hsync == 1))) else //839 && 967
 $error("hsync is not correct");
 
 
 //vsync
 assert property (@(posedge clk) ((vcount >= VER_SYNC_START - 1) && (vcount < VER_SYNC_END - 1) |-> (vsync == 1))) else //600 && 604
 $error("vsync is not correct");
 
 
 /**
  * Main test
  */
 
 initial begin
     @(posedge rst);
     @(negedge rst);
 
     wait (vsync == 1'b0);
     @(negedge vsync)
     @(negedge vsync)
 
     $finish;
 end
 
 endmodule
 