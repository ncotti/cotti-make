`ifndef TOP_H_
`define TOP_H_

package top_defines;

    timeunit 1ns; timeprecision 1ns;

    /* verilator lint_off UNUSEDPARAM */
    // Path is relative to the Makefile
    localparam string RomFilename = "tb/rom.hex";

endpackage : top_defines

`endif  // TOP_H_
