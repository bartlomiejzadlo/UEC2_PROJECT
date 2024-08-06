# Copyright (C) 2023  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
    constraints/clk_wiz_0.xdc
    constraints/clk_wiz_0_late.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/top_logic/vga_if.sv
    ../rtl/top_logic/vga_pkg.sv
    ../rtl/top_logic/vga_timing.sv
    ../rtl/draw_logic/draw_bg.sv
    ../rtl/draw_logic/draw_rect.sv
    ../rtl/top_logic/top_vga.sv
    ../rtl/mouse_logic/draw_mouse.sv
    ../rtl/draw_logic/draw_rect_ctl.sv
    ../rtl/draw_logic/draw_obstacle_ctl.sv
    ../rtl/draw_logic/draw_obstacle.sv
    ../rtl/draw_logic/draw_rect_char.sv 
    ../rtl/rom/char_rom_16x16.sv 
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    rtl/clk_wiz_0.v
    rtl/clk_wiz_0_clk_wiz.v
    ../rtl/rom/font_rom.v 
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    rtl/Ps2Interface.vhd
    ../rtl/mouse_logic/MouseCtl.vhd
    ../rtl/mouse_logic/MouseDisplay.vhd
}


