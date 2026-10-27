// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0

`include "counter.svh"

module counter (
    input logic clk,
    input logic rst,
    input logic ena,
    output logic [`COUNTER_WIDTH-1:0] count
);

    timeunit 1ns; timeprecision 1ns;

    always_ff @(posedge clk) begin
        if (rst) begin
            count <= '0;
        end else begin
            if (ena) begin
                count <= count + 1;
            end else begin
                count <= count;
            end
        end
    end

endmodule
