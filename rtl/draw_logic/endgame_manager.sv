// Author WS
// Module for managing endgame signal for both players

module endgame_manager(
    input logic clk,
    input logic rst,
    input logic pl2_endgame,

    input logic endgame_cond1,
    input logic endgame_cond2,

    output logic endgame_cond1_withpl1,
    output logic endgame_cond1_withpl2,

    output logic my_endgame,
    output logic endgame
);

always_ff@(posedge clk)begin
    if(rst)begin
        my_endgame <= '0;
        endgame    <= '0;
        endgame_cond1_withpl1 <= '0;
        endgame_cond1_withpl2 <= '0;
    end
    else begin
        my_endgame <= endgame_cond1 || endgame_cond2;
        endgame    <= my_endgame || pl2_endgame;
        endgame_cond1_withpl1 <= endgame_cond1 || pl2_endgame;
        endgame_cond1_withpl2 <= endgame_cond2 || pl2_endgame;
    end
end


endmodule