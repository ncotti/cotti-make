module counter #(
    int WIDTH = 32
) (
    input logic clk,
    input logic rstN,
    input logic ena,
    input logic [WIDTH-1:0] load,
    input logic load_enable,
    output logic [WIDTH-1:0] count
);
    timeunit 1ns; timeprecision 1ns;

    always_ff @(posedge clk) begin
        if (!rstN) begin
            count <= '0;
        end else if (ena) begin
            count <= (load_enable) ? load : count + 1;
        end else begin
            count <= count;
        end
    end
endmodule : counter
