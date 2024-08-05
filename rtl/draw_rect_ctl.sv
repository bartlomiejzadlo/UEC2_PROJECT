`timescale 1ns / 1ps

module draw_rect_ctl(
    input  logic clk,
    input  logic rst,
    input  logic [11:0] mouse_x_pos,
    input  logic [11:0] mouse_y_pos,
    input  logic left,

    output logic [11:0] xpos,
    output logic [11:0] ypos
);


/**
 * Local params and signals
 */

import vga_pkg::*;

reg [2:0] state, state_nxt;
reg [11:0] ypos_nxt;
reg [7:0] energy, energy_nxt;
wire done_vel_ctr, done_enrg_ctr, counter_enable;

/**
 * Submodules and logic
 */
counter u_counter_energy(
    .clk(clk),
    .rst(rst),
    .max(ENERGY_CTR_MAX),
    .counting(counter_enable),
    .incr(energy),
    .done(done_enrg_ctr)
);

counter u_counter_vel(
    .clk(clk),
    .rst(rst),
    .max(VEL_CTR_MAX),
    .counting(counter_enable),
    .incr(8'b0),
    .done(done_vel_ctr)
);

assign counter_enable = ((state == DOWN) || (state == UP));

always_ff@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
        xpos <= 12'b0;
        ypos <= 12'b0;
        energy <= 8'b0;
    end
    else begin
        state <= state_nxt;
        xpos <= mouse_x_pos;
        ypos <= ypos_nxt;
        energy <= energy_nxt;
    end
end

always_comb begin
    case(state)
        IDLE:   if (left) begin
                    state_nxt = DOWN;
                    ypos_nxt = ypos;
                    energy_nxt = energy;
                end
                else begin
                    state_nxt = IDLE;
                    ypos_nxt = mouse_y_pos;
                    energy_nxt = energy;
                end
        
        DOWN:    if (ypos < (601 - H_OF_REC)) begin
                        if (done_vel_ctr) begin
                            ypos_nxt = ypos + 1;
                            energy_nxt = energy;
                            state_nxt = DOWN;
                        end
                        else if (done_enrg_ctr) begin
                            ypos_nxt = ypos;
                            state_nxt = DOWN;
                            energy_nxt = energy + 1;
                        end
                        else begin
                            ypos_nxt = ypos;
                            energy_nxt = energy;
                            state_nxt = DOWN;
                        end
                    end
                    else begin
                        ypos_nxt = 601 - H_OF_REC;
                        energy_nxt = energy;
                        state_nxt = BOUNCE;
                    end
        
        BOUNCE: if ((energy >> 1) > 0) begin
                    energy_nxt = energy >> 1;
                    state_nxt = UP;
                    ypos_nxt = 601 - H_OF_REC;
                end
                else begin
                    state_nxt = BOTTOM;
                    energy_nxt = energy;
                    ypos_nxt = 601 - H_OF_REC;
                end
        
        UP: if (energy > 0) begin
                    if (done_vel_ctr) begin
                        ypos_nxt = ypos - 1;
                        energy_nxt = energy;
                        state_nxt = UP;
                    end
                    else if (done_enrg_ctr) begin
                        state_nxt = UP;
                        energy_nxt = energy - 1; 
                        ypos_nxt = ypos;
                    end
                    else begin
                        state_nxt = UP;
                        energy_nxt = energy;
                        ypos_nxt = ypos;
                    end
                end
                else begin
                    ypos_nxt = ypos;
                    energy_nxt = energy;
                    state_nxt = DOWN;
                end
        
        BOTTOM: begin   state_nxt = BOTTOM;
                        ypos_nxt = 601 - H_OF_REC;
                        energy_nxt = energy;
                end
            
        default: begin  state_nxt = IDLE;
                        ypos_nxt = mouse_y_pos;
                        energy_nxt = energy;
                 end
    endcase
end



endmodule