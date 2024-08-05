/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Package with vga related constants.
 */

package vga_pkg;

// Parameters for VGA Display 800 x 600 @ 60fps using a 40 MHz clock;
localparam HOR_PIXELS = 800;
localparam VER_PIXELS = 600;

// Add VGA timing parameters here and refer to them in other modules.
localparam HOR_TOT_PIX = 1056; 
localparam VER_TOT_PIX = 628;

localparam HOR_SYNC_START = 840; 
localparam VER_SYNC_START = 601; 

localparam HOR_SYNC_END = 968; 
localparam VER_SYNC_END = 605; 

// Parameters for rectangle;
//localparam X_OF_REC = 100;
//localparam Y_OF_REC = 200;
localparam W_OF_REC = 49;
localparam H_OF_REC = 63;
localparam C_OF_REC = 12'ha_f_0;

/**
 * States
 */
localparam IDLE = 3'b000;
localparam DOWN = 3'b001;
localparam UP = 3'b010;
localparam BOTTOM = 3'b011;
localparam BOUNCE = 3'b100;
localparam ENERGY_CTR_MAX = 500000;
localparam VEL_CTR_MAX = 1000000;

localparam START = 3'b001;

endpackage
