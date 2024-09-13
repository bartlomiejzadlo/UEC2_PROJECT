//Author WS
//module for reset managment purposes


module reset_maganer(
    input logic clk,
    input wire reset_button,
    input logic pl2_rst,

    output logic rst,
    output logic out_rst
);

always_ff@(posedge clk)begin
    if(reset_button)begin
        out_rst <= '1;
        rst     <= '1;
    end
    else begin
        out_rst <= '0;
        rst     <=  pl2_rst;
    end
end


endmodule