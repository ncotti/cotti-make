#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the usage of verilator + cocotb for
## SystemVerilog designs.

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/verilog_project"
    export BUILD_DIR="${PROJECT_DIR}/build"

    run make -C "${PROJECT_DIR}" clean
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    rm -rf "${PROJECT_DIR}/build"

    assert_dir_not_exist "${PROJECT_DIR}/build"
}

teardown() {
    run make -C "${PROJECT_DIR}" clean
}

teardown_file() {
    true
}

@test "Test verilog project runs as expected" {
    run make -C "${PROJECT_DIR}" vcompile
    assert_success
    assert_file_exist "${BUILD_DIR}/verilog/linter/src/top_lint_ok.txt"
    assert_file_exist "${BUILD_DIR}/verilog/linter/src/counter_lint_ok.txt"

    run make -C "${PROJECT_DIR}" vfmt
    assert_success

    run make -C "${PROJECT_DIR}" vrun
    assert_success
    assert_file_exist "${BUILD_DIR}/verilog/waves/tb/top_tb_dump.fst"
}
