/**
 * Copyright (C) 2023  AGH University of Science and Technology
 * MTM UEC2
 * Author: BZ
 *
 * Description:
 * Buforing and delaying the control signals of vga by one clock cycle
 */

module d_bufor(
    input clk,
    input logic [11:0] xpos_nxt,
    input logic [11:0] ypos_nxt,
    output logic [11:0] xpos,
    output logic [11:0] ypos
);


always_ff @(posedge clk) begin
    xpos <= xpos_nxt;
    ypos <= ypos_nxt;
end

endmodule