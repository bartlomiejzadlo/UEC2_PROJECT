`timescale 1ns / 1ps

module draw_obstacle_ctl(
    input  logic clk,
    input  logic rst,

    input logic [11:0] y_from_draw_rect,

    output logic endgame,
    output logic [11:0] obstacle_xpos_1,
    output logic [11:0] obstacle_ypos_1,
    output logic [11:0] obstacle_ypos_2
);

import vga_pkg::*;

// Lokalny sygnał dla maszyny stanów i pozycji
reg [2:0] state, state_nxt;
reg [10:0] xpos_nxt;
//reg [10:0] ypos_nxt1;
//reg [10:0] ypos_nxt2;

assign obstacle_ypos_1 = 250;
assign obstacle_ypos_2 = 440;

logic [7:0] random_number_up;
logic [24:0] cycle_counter; // Licznik cykli zegara dla 0.25 sekundy


// Maszyna stanów z rejestrowaniem sygnałów wyjściowych
always_ff@(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        obstacle_xpos_1 <= 12'b0;
        //obstacle_ypos_1 <= 12'b0;
        //obstacle_ypos_2 <= 12'b0;
        cycle_counter <= 0; // Reset licznika cykli zegara
    end else begin
        state <= state_nxt;
        obstacle_xpos_1 <= xpos_nxt;
        //obstacle_ypos_1 <= ypos_nxt1;
       // obstacle_ypos_2 <= ypos_nxt2;
        
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
    case(state)
        IDLE: if (xpos_nxt == 0) begin
                state_nxt = START;
                xpos_nxt = 750;
                //ypos_nxt1 = 250;
                //ypos_nxt2 = 440;
            end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
                //ypos_nxt1 = 0;
                //ypos_nxt2 = 0;
            end
        
        START: if (xpos_nxt > 0) begin
                if (cycle_counter == 4_000_000) begin // Sprawdzenie, czy upłynęło 0.25 sekundy
                    xpos_nxt = obstacle_xpos_1 - 1;
                    //ypos_nxt1 = 250;
                    //ypos_nxt2 = 440;
                end
                    state_nxt = START;
            end else if (((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_1 >= y_from_draw_rect) && (obstacle_ypos_1 <= y_from_draw_rect + H_OF_REC)) ||
                ((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_2 >= y_from_draw_rect) && (obstacle_ypos_2 <= y_from_draw_rect + H_OF_REC))) begin
                state_nxt = ENDGAME;
                xpos_nxt = obstacle_xpos_1;
                end else begin
                state_nxt = IDLE;
                xpos_nxt = 0;
                //ypos_nxt1 = 250;
                //ypos_nxt2 = 440;
            end
        

        
            //if (((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_1 >= y_from_draw_rect) && (obstacle_ypos_1 <= y_from_draw_rect + H_OF_REC)) ||
              //  ((xpos_nxt >= 0) && (xpos_nxt <= W_OF_REC) && (obstacle_ypos_2 >= y_from_draw_rect) && (obstacle_ypos_2 <= y_from_draw_rect + H_OF_REC))) begin
                //state_nxt = ENDGAME;
                //xpos_nxt = obstacle_xpos_1;
                //ypos_nxt1 = 250;
                //ypos_nxt2 = 440;
            //end
        //end

        ENDGAME: begin
            state_nxt = ENDGAME;
            endgame = 1;
            xpos_nxt = obstacle_xpos_1;
            //ypos_nxt1 = 250;
            //ypos_nxt2 = 440;
        end
            
        default: begin
            state_nxt = IDLE;
            xpos_nxt = 0;
            endgame = 0;
        end
    endcase
end

endmodule
