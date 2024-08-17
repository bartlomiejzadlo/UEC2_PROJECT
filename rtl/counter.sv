`timescale 1ns / 1ps

module counter(
    input wire clk,
    input wire rst,
    input wire [31:0] max,
    input wire counting,
    input wire [7:0] incr,
    output wire done
    );
    
    reg [31:0] ctr, ctr_nxt;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ctr <= 32'b0;
        end
        else begin
            ctr <= ctr_nxt;
        end
    end
    
    always_comb begin
        if (counting) begin
            if(ctr < max) begin
                ctr_nxt = ctr + 1 + incr;
            end
            else begin
                ctr_nxt = 0;    
            end
        end
        else begin
            ctr_nxt = ctr;
        end
    end
    
    assign done = (ctr >= max);
    
endmodule