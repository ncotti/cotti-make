#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests that a recompilation is triggered whenever a
## Verilog source file, header, testbench or the Makefile are changed.

setup_file() {
    true
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    export COTTI_MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export MAKE_DIR="$BATS_TEST_TMPDIR"
    export BUILD_DIR="$BATS_TEST_TMPDIR/build"

    export src_dir="$BATS_TEST_TMPDIR/src1"
    export inc_dir="$BATS_TEST_TMPDIR/inc1"
    export tb_dir="$BATS_TEST_TMPDIR/tb1"
    export src_file1="${src_dir}/top.sv"
    export src_file2="${src_dir}/help.sv"
    export inc_file1="${inc_dir}/top_inc.h"
    export tb_file1="${tb_dir}/top_tb.py"
    export tb_file2="${tb_dir}/help_tb.py"
    export make_file="$BATS_TEST_TMPDIR/Makefile"

    mkdir "${src_dir}" "${inc_dir}" "${tb_dir}"

    cat > "${make_file}" <<EOF
V_SRC_DIRS := ${src_dir}
V_INC_DIRS := ${inc_dir}
V_TEST_DIRS := ${tb_dir}
BUILD_DIR := ${BUILD_DIR}

include ${COTTI_MAKE_DIR}/cottimake.mk
EOF

    cat > "${src_file1}" <<EOF
module top;
endmodule: top

EOF

    cat > "${src_file2}" <<EOF
module help;
endmodule: help

EOF

    cat > "${inc_file1}" << EOF
\`ifndef TOP_INC_H_
\`define TOP_INC_H_
package top_inc;
endpackage: top_inc
\`endif // TOP_INC_H_

EOF

    cat > "${tb_file1}" <<EOF
import cocotb

@cocotb.test
async def test_hello(dut)
    cocotb.log.info("Hi from tb_file1")

EOF

    cat > "${tb_file2}" <<EOF
import cocotb

@cocotb.test
async def test_hello(dut)
    cocotb.log.info("Hi from tb_file2")

EOF

}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Modifying a source file should trigger a re-compilation" {
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output

    # Modifying one source file should only trigger recompilation of that file
    # and the linker step
    printf "\n //Extra comment at the end \n" >> "${src_file1}"
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${exe_file}"
    refute_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output

    # Modifying the other source file
    printf "\n //Extra comment at the end \n" >> "${src_file2}"
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"
    refute_output --partial "${src_file1}"
}

@test "Modifying a header file should trigger a re-compilation" {
    run make -C "${MAKE_DIR}" --no-print-directory compile \
        CFLAGS=""
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"

    run make -C "${MAKE_DIR}" --no-print-directory compile \
        CFLAGS=""
    assert_success
    refute_output

    # Modifying main.h should only trigger a re-compilation of main.c
    printf "\n //Extra comment at the end \n" >> "${inc_file1}"
    run make -C "${MAKE_DIR}" --no-print-directory compile \
        CFLAGS=""
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${exe_file}"
    refute_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" --no-print-directory compile \
        CFLAGS=""
    assert_success
    refute_output

    # Modifying help.h should trigger recompilation of both files
    printf "\n //Extra comment at the end \n" >> "${inc_file2}"
    run make -C "${MAKE_DIR}" --no-print-directory compile \
        CFLAGS=""
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"
}

@test "Modifying the project's Makefile should trigger a re-compilation" {
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output

    printf "\n# Extra comment at the end \n" >> "${make_file}"
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output
}

@test "Modifying the project's linker script should trigger a re-compilation" {
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output

    printf "\n/* Extra comment at the end */\n" >> "${linker_file}"
    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
    assert_output --partial "${exe_file}"

    run make -C "${MAKE_DIR}" --no-print-directory compile
    assert_success
    refute_output
}

