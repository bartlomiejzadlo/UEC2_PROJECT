`timescale 1ns / 1ps

module tb_draw_rect_ctl;
    // Sygnały testbench
    logic clk;
    logic rst;
    logic left;
    logic right;
    logic endgame;
    logic [11:0] ypos;

    // Instancja modułu
    draw_rect_ctl uut (
        .clk(clk),
        .rst(rst),
        .left(left),
        .right(right),
        .endgame(endgame),
        .ypos(ypos)
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
        left = 0;
        right = 0;
        #40;
        rst = 0;

        // Symulacja ruchu w dół
        #100;
        right = 1;
        #50;
        right = 0;

        // Symulacja ruchu w górę
        #200;
        left = 1;
        #50; // Tylko jeden cykl zegara dla stanu UP
        left = 0;

        // Symulacja ruchu w dół do stanu ENDGAME
        repeat(500) begin
            #25_000;
            if (endgame == 1) begin
                $display("ENDGAME reached at time: %0t | ypos: %0d", $time, ypos);
                $stop;
            end
        end

        // Zatrzymanie symulacji po 1 sekundzie
        #1_000_000_000;
        $stop;
    end

    // Monitorowanie
    initial begin
        $monitor("Time: %0t | ypos: %0d | endgame: %0b", $time, ypos, endgame);
    end
endmodule
