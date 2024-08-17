module draw_obstacle_ctl(
    input  logic clk,
    input  logic rst_n,
    input  logic [11:0] y_from_draw_rect,
    input  logic endgame_from_rect,  // Nowe wejście

    output logic endgame_from_obstacle,
    output logic [11:0] obstacle_xpos_1,
    output logic [11:0] obstacle_ypos_1,
    output logic [11:0] obstacle_ypos_2
);

import vga_pkg::*;

reg [2:0] state, state_nxt;
reg [11:0] xpos_nxt;
logic [24:0] cycle_counter;

// Przechowuje aktualne wartości pozycji Y przeszkód
logic [11:0] obstacle_ypos_1_nxt;
logic [11:0] obstacle_ypos_2_nxt;

always_ff @(posedge clk) begin
    if (rst_n) begin
        state <= IDLE;
        obstacle_xpos_1 <= 750;
        obstacle_ypos_1 <= 250;
        obstacle_ypos_2 <= 450;
        cycle_counter <= 0;
    end else begin
        state <= state_nxt;
        obstacle_xpos_1 <= xpos_nxt;
        obstacle_ypos_1 <= obstacle_ypos_1_nxt;
        obstacle_ypos_2 <= obstacle_ypos_2_nxt;

        if (cycle_counter < 2_000_000) begin  // Zmniejszenie wartości dla szybszego przesuwania przeszkód
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= 0;
        end
    end
end

always_comb begin
    state_nxt = state;
    xpos_nxt = obstacle_xpos_1;
    obstacle_ypos_1_nxt = obstacle_ypos_1;
    obstacle_ypos_2_nxt = obstacle_ypos_2;


    case(state)
        IDLE: begin
            if (xpos_nxt == 0) begin
                state_nxt = START;
                xpos_nxt = 750;
                // Po resetowaniu, zmniejszanie obstacle_ypos_1 i zwiększanie obstacle_ypos_2
                obstacle_ypos_1_nxt = obstacle_ypos_1 - 10;
                obstacle_ypos_2_nxt = obstacle_ypos_2 - 10;
            end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
            end
        end

        START: begin
            if (xpos_nxt > 0) begin
                if (cycle_counter == 2_000_000) begin
                    xpos_nxt = obstacle_xpos_1 - 2;  // Przesuwanie szybciej
                end
                state_nxt = START;
            end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
            end

            // Sprawdzenie kolizji
            if (((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && 
                 (obstacle_ypos_1 >= y_from_draw_rect) && 
                 (obstacle_ypos_1 <= y_from_draw_rect + H_OF_REC)) ||
                ((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && 
                 (obstacle_ypos_2 >= y_from_draw_rect) && 
                 (obstacle_ypos_2 <= y_from_draw_rect + H_OF_REC))) begin
                state_nxt = ENDGAME;
            end
        end

        ENDGAME: begin
            endgame_from_obstacle = 1;
            state_nxt = ENDGAME;
            xpos_nxt = obstacle_xpos_1;
            obstacle_ypos_1_nxt = obstacle_ypos_1;
            obstacle_ypos_2_nxt = obstacle_ypos_2;
        end

        default: begin
            state_nxt = IDLE;
            xpos_nxt = 0;
            endgame_from_obstacle = 0;
        end
    endcase

    // Sprawdzenie warunku, gdy obstacle_ypos_1_nxt lub obstacle_ypos_2_nxt miałyby być <= 0
    if (obstacle_ypos_1_nxt <= 0) begin
        obstacle_ypos_1_nxt = 250;
    end
    if (obstacle_ypos_2_nxt <= 0) begin
        obstacle_ypos_2_nxt = 440;
    end

    // Sprawdzenie kolizji z prostokątem
    if (endgame_from_rect) begin
        state_nxt = ENDGAME;
    end
end

endmodule
