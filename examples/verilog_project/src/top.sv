`include "top_defines.svh"

module top #(
    int ADDR_WIDTH = 8,
    int DATA_WIDTH = 8
) (
    input logic clk,
    input logic rstN,
    input logic ena,
    output logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);
    import top_defines::RomFilename;

    timeunit 1ns; timeprecision 1ns;

    logic [ADDR_WIDTH-1:0] rom_addr;

    always_ff @(posedge clk) begin
        addr <= rom_addr;
    end

    rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ROM_FILE  (RomFilename)
    ) rom_i (
        .clk (clk),
        .addr(rom_addr),
        .dout(data)
    );

    counter #(
        .WIDTH(ADDR_WIDTH)
    ) counter_i (
        .clk(clk),
        .rstN(rstN),
        .ena(ena),
        .load('0),
        .load_enable(1'b0),
        .count(rom_addr)
    );
endmodule : top
