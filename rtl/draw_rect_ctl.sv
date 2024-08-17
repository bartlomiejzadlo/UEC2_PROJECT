`timescale 1ns / 1ps

module draw_rect_ctl(
    input  logic clk,
    input  logic rst,
    input logic left,
    input logic right,

    output logic endgame,
    output logic [11:0] ypos
);

import vga_pkg::*;

// Lokalny sygnał dla maszyny stanów i pozycji
reg [2:0] state, state_nxt;
reg [11:0] ypos_nxt;

logic [24:0] cycle_counter; // Licznik cykli zegara dla 0.25 sekundy
logic stop;


// Maszyna stanów z rejestrowaniem sygnałów wyjściowych
always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        ypos <= 12'b0;
        cycle_counter <= 0; // Reset licznika cykli zegara
        endgame <= 0;
        stop <= 0;
    end else begin
        state <= state_nxt;
        ypos <= ypos_nxt;
        
        // Inkrementacja licznika cykli zegara
        if (cycle_counter < 4_000_000) begin
            cycle_counter <= cycle_counter + 1;
        end else begin
            cycle_counter <= 0; // Reset licznika po 0.25 sekundy
        end
    end
end

// Logika maszyny stanów
always_comb begin
    state_nxt = state;
    ypos_nxt = ypos; // Domyślne przypisanie
    
    case(state)
        IDLE: begin
            if (right && stop == 0) begin
                state_nxt = DOWN;
                stop = 1;
            end else begin
                state_nxt = IDLE;
                ypos_nxt = 0;
            end
        end

        DOWN: begin
            if (ypos < (VER_PIXELS - 1)) begin
                if (cycle_counter == 4_000_000) begin // Sprawdzenie, czy upłynęło 0.25 sekundy
                    ypos_nxt = ypos + 1;
                end
                state_nxt = DOWN;
            end else begin
                state_nxt = ENDGAME;
            end

            if (left) begin
                state_nxt = UP;
                stop = 0;
            end
        end

        UP: begin
            if ((ypos > 0) && (stop == 0)) begin
                if (cycle_counter == 4_000_000) begin
                    ypos_nxt = ypos - 1; // Unoszenie się do góry
                    stop = 1;
                end
                state_nxt = DOWN;
            end else begin
                state_nxt = ENDGAME;
            end
        end

        ENDGAME: begin
            state_nxt = ENDGAME;
            endgame = 1;
        end

        default: begin
            state_nxt = IDLE;
            ypos_nxt = 0;
            stop = 0;
            endgame = 0;
        end
    endcase
end

endmodule

