module draw_rect_ctl(
    input  logic clk,
    input  logic rst,
    input  logic left,
    input  logic right,
    input  logic endgame_from_obstacle,  // Nowe wejście

    output logic endgame_from_rect,
    output logic [11:0] ypos
);

import vga_pkg::*;

reg [2:0] state, state_nxt;
reg [11:0] ypos_nxt;

logic [24:0] cycle_counter;
logic endgame_from_rect_nxt;

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        ypos <= 12'b0;
        cycle_counter <= 0;
        endgame_from_rect <= '0;
    end else begin
        state <= state_nxt;
        ypos <= ypos_nxt;
        endgame_from_rect <= endgame_from_rect_nxt;

        
        if (cycle_counter < 2_000_000) begin
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= 0;
        end
    end
end

always_comb begin
    state_nxt = state;
    ypos_nxt = ypos;

    case(state)
        IDLE: begin
            endgame_from_rect_nxt = '0;
            ypos_nxt = 0;
            if (right) begin
                state_nxt = DOWN;
            end
        end

        DOWN: begin
            if (ypos < (VER_PIXELS - H_OF_REC)) begin
                if (cycle_counter == 2_000_000) begin
                    ypos_nxt = ypos + 1;
                end
                state_nxt = DOWN;
            end else begin
                state_nxt = ENDGAME;
            end

            if (left) begin
                state_nxt = UP;
            end
            endgame_from_rect_nxt = endgame_from_rect;
        end

        UP: begin
            if (ypos > 0) begin
                if (cycle_counter == 2_000_000) begin
                    ypos_nxt = ypos - 1;
                end
                state_nxt = UP;
            end else begin
                // Jeśli ypos = 0, przejdź do stanu ENDGAME
                state_nxt = ENDGAME;
            end

            if (right) begin
                state_nxt = DOWN;
            end
            endgame_from_rect_nxt = endgame_from_rect;
        end

        ENDGAME: begin
            endgame_from_rect_nxt = '1;
            state_nxt = ENDGAME;
            ypos_nxt = ypos;
        end
            
        default: begin
            state_nxt = IDLE;
            ypos_nxt = 0;
            endgame_from_rect_nxt = '0;
        end
    endcase

    // Sprawdzenie kolizji
    if (endgame_from_obstacle) begin
        state_nxt = ENDGAME;
    end
end

endmodule
