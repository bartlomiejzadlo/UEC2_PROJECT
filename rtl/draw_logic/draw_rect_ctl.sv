module draw_rect_ctl(
    input  logic clk,
    input  logic rst_n,
    input  logic left,
    input  logic right,
    output logic endgame,
    output logic [11:0] ypos
);

import vga_pkg::*;

// State and position registers
reg [2:0] state, state_nxt;
reg [11:0] ypos_nxt;

logic [24:0] cycle_counter;

// State machine with output signal assignment
always_ff @(posedge clk) begin
    if (rst_n) begin
        state <= IDLE;
        ypos <= 12'b0;
        cycle_counter <= 0; // Reset clock cycle counter
    end else begin
        state <= state_nxt;
        ypos <= ypos_nxt;
        
        // Increment clock cycle counter
        if (cycle_counter < 4_000_000) begin
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= 0; // Reset counter after 0.25 seconds
        end
    end
end

// State machine logic
always_comb begin
    state_nxt = state;
    ypos_nxt = ypos; // Default assignment
    endgame = 0;     // Default endgame signal
    
    case(state)
        IDLE: begin
            ypos_nxt = 0;
            if (right) begin
                state_nxt = DOWN;
            end
        end

        DOWN: begin
            if (ypos < (VER_PIXELS - H_OF_REC)) begin
                if (cycle_counter == 4_000_000) begin // 0.25 seconds elapsed
                    ypos_nxt = ypos + 1;
                end
                state_nxt = DOWN;
            end else begin
                state_nxt = ENDGAME; // Enter ENDGAME if ypos reaches VER_PIXELS - 1
            end

            if (left) begin
                state_nxt = UP;
            end
        end

        UP: begin
            if (ypos > 0) begin
                if (cycle_counter == 4_000_000) begin
                    ypos_nxt = ypos - 1; // Move up
                end
                state_nxt = UP;
            end else begin
                state_nxt = IDLE;
            end

            if (right) begin
                state_nxt = DOWN;
            end
        end

        ENDGAME: begin
            endgame = 1;
            state_nxt = ENDGAME; // Stay in ENDGAME
            ypos_nxt = ypos;     // Maintain ypos
        end
            
        default: begin
            state_nxt = IDLE;
            ypos_nxt = 0;
            endgame = 0;
        end
    endcase
end

endmodule

