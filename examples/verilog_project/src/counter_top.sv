// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0

`include "counter.svh"

module counter_top (
    input logic clk,
    input logic rst,
    input logic ena,
    output logic [`COUNTER_WIDTH-1:0] count
);

    timeunit 1ns; timeprecision 1ns;

    counter u_counter (
        .clk  (clk),
        .rst  (rst),
        .ena  (ena),
        .count(count)
    );

endmodule
