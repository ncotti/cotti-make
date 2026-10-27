#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the usage of verilator + cocotb + surfer for
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
    # Compilation alone does not generate the file
    run make -C "${PROJECT_DIR}" vcompile
    assert_success
    assert_output --partial "V e r i l a t i o n"

    run make -C "${PROJECT_DIR}" clean
    assert_success

    # Running tidy again should re-print the same message, but without
    # compiling
    run make -C "${PROJECT_DIR}" vrun
    assert_success
    #assert_file_exist "${BUILD_DIR}/counter_top/dump.fst"
}
