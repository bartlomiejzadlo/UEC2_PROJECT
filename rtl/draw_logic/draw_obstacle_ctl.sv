module draw_obstacle_ctl(
    input  logic clk,
    input  logic rst_n,
    input  logic [11:0] y_from_draw_rect,
    input logic endgame,
    output logic [11:0] obstacle_xpos_1,
    output logic [11:0] obstacle_ypos_1,
    output logic [11:0] obstacle_ypos_2
);

import vga_pkg::*;

// State and position registers
reg [2:0] state, state_nxt;
reg [11:0] xpos_nxt;

assign obstacle_ypos_1 = 250;
assign obstacle_ypos_2 = 440;

logic [24:0] cycle_counter;

// State machine with output signal assignment
always_ff @(posedge clk) begin
    if (rst_n) begin
        state <= IDLE;
        obstacle_xpos_1 <= 750; // Set initial x position to 750
        cycle_counter <= 0; // Reset the clock cycle counter
    end else begin
        state <= state_nxt;
        obstacle_xpos_1 <= xpos_nxt;

        // Increment the clock cycle counter
        if (cycle_counter < 4_000_000) begin
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= 0; // Reset the counter after 0.25 seconds
        end
    end
end

// State machine logic
always_comb begin
    state_nxt = state;
    xpos_nxt = obstacle_xpos_1; // Default assignment
    //endgame = 0;                // Default endgame signal

    case(state)
        IDLE: begin
            if (xpos_nxt == 0) begin
                state_nxt = START;
                xpos_nxt = 750; // Reset to 750
            end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
            end
        end

        START: begin
            if (xpos_nxt > 0) begin
                if (cycle_counter == 4_000_000) begin // 0.25 seconds elapsed
                    xpos_nxt = obstacle_xpos_1 - 1;
                end
                state_nxt = START;
            end 
            
            // Collision detection with both edges of the obstacle
            if (((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_1 >= y_from_draw_rect) && (obstacle_ypos_1 <= y_from_draw_rect + H_OF_REC)) ||
                ((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_2 >= y_from_draw_rect) && (obstacle_ypos_2 <= y_from_draw_rect + H_OF_REC))) begin
                state_nxt = ENDGAME;
            end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
            end
        end

        ENDGAME: begin
            //endgame = 1;
            state_nxt = ENDGAME;
            xpos_nxt = obstacle_xpos_1;
        end

        default: begin
            state_nxt = IDLE;
            xpos_nxt = 0;
            //endgame = 0;
        end
    endcase
end

endmodule

