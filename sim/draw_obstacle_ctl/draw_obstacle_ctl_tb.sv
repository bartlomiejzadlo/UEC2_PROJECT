`timescale 1ns / 1ps

module tb_draw_obstacle_ctl;
    // Sygnały testbench
    logic clk;
    logic rst;
    logic [11:0] y_from_draw_rect;
    logic endgame;
    logic [11:0] obstacle_xpos_1;
    logic [11:0] obstacle_ypos_1;
    logic [11:0] obstacle_ypos_2;

    // Instancja modułu
    draw_obstacle_ctl uut (
        .clk(clk),
        .rst(rst),
        .y_from_draw_rect(y_from_draw_rect),
        .endgame(endgame),
        .obstacle_xpos_1(obstacle_xpos_1),
        .obstacle_ypos_1(obstacle_ypos_1),
        .obstacle_ypos_2(obstacle_ypos_2)
    );

    // Generowanie zegara
    initial begin
        clk = 0;
        forever #12.5 clk = ~clk; // Zegar 40 MHz (okres 25 ns)
    end

    // Symulacja
    initial begin
        // Reset na 40 ns
        rst = 1;
        y_from_draw_rect = 12'd300;
        #40;
        rst = 0;

        // Symulacja ruchu przeszkody
        repeat(500) begin
            #25_000;
            if (endgame == 1) begin
                $display("ENDGAME reached at time: %0t | obstacle_xpos_1: %0d", $time, obstacle_xpos_1);
                $stop;
            end
        end

        // Zatrzymanie symulacji po 1 sekundzie
        #1_000_000_000;
        $stop;
    end

    // Monitorowanie
    initial begin
        $monitor("Time: %0t | obstacle_xpos_1: %0d | obstacle_ypos_1: %0d | obstacle_ypos_2: %0d | endgame: %0b", 
                 $time, obstacle_xpos_1, obstacle_ypos_1, obstacle_ypos_2, endgame);
    end
endmodule
