module sync_reset (
    input  logic clk,
    input  logic rst_n, // active low asynchronous reset
    output logic rst    // synchronous reset
);

    logic [1:0] sync_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sync_reg <= 2'b00;
        else
            sync_reg <= {sync_reg[0], 1'b1};
    end

    assign rst = ~sync_reg[1];

endmodule
