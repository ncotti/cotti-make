`include "top_defines.svh"

module top #(
    int ADDR_WIDTH = 8,
    int DATA_WIDTH = 8
) (
    input logic clk,
    input logic rstN,
    input logic ena,
    input logic [ADDR_WIDTH-1:0] start_addr,
    output logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);
    import top_defines::RomFilename;

    timeunit 1ns; timeprecision 1ns;

    logic reset_rising_edge;

    // Detect a rising rising edge in the reset line.
    always_ff @(posedge clk) begin
        logic prev_rstN;
        prev_rstN <= rstN;
        reset_rising_edge <= ~prev_rstN & rstN;
    end

    rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ROM_FILE  (RomFilename)
    ) rom_i (
        .clk (clk),
        .addr(addr),
        .dout(data)
    );

    counter #(
        .WIDTH(ADDR_WIDTH)
    ) counter_i (
        .clk(clk),
        .rstN(rstN),
        .ena(ena),
        .load(start_addr),
        .load_enable(reset_rising_edge),
        .count(addr)
    );
endmodule : top
