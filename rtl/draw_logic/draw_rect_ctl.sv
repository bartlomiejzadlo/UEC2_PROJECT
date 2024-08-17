`timescale 1ns / 1ps

module draw_rect_ctl(
    input  logic clk,
    input  logic rst_n,
    input  logic left,
    input  logic right,

    output logic endgame,
    output logic [11:0] ypos
);

import vga_pkg::*;

// Lokalny sygnał dla maszyny stanów i pozycji
reg [2:0] state, state_nxt;
reg [11:0] ypos_nxt;

logic [24:0] cycle_counter; // Licznik cykli zegara dla 0.25 sekundy


// Maszyna stanów z rejestrowaniem sygnałów wyjściowych
always_ff @(posedge clk) begin
    if (rst_n) begin
        state <= IDLE;
        ypos <= 12'b0;
        cycle_counter <= 0; // Reset licznika cykli zegara
        //endgame <= 0;
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
    endgame = 0;     // Domyślnie ustawiamy `endgame` na 0
    
    case(state)
        IDLE: begin
            ypos_nxt = 0;
            if (right) begin
                state_nxt = DOWN;
            end
        end

        DOWN: begin
            if (ypos < (VER_PIXELS - H_OF_REC)) begin
                if (cycle_counter == 4_000_000) begin // Sprawdzenie, czy upłynęło 0.25 sekundy
                    ypos_nxt = ypos + 1;
                end
                state_nxt = DOWN;
            end else begin
                state_nxt = ENDGAME; // Przejście do stanu ENDGAME, gdy ypos osiągnie VER_PIXELS - 1
            end

            if (left) begin
                state_nxt = UP;
            end
        end

        UP: begin
            if (ypos > 0) begin
                if (cycle_counter == 4_000_000) begin
                    ypos_nxt = ypos - 1; // Unoszenie się do góry
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
            state_nxt = ENDGAME; // Pozostajemy w stanie ENDGAME
            ypos_nxt = ypos;     // Zachowanie pozycji ypos w momencie wejścia do ENDGAME
        end
            
        default: begin
            state_nxt = IDLE;
            ypos_nxt = 0;
            endgame = 0;
        end
    endcase
end

endmodule

