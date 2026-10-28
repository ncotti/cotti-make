#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "make print[_XXX]" functionality.
## These are pre-compilation prints.

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export src_dir1="$BATS_FILE_TMPDIR/src1"
    export src_dir2="$BATS_FILE_TMPDIR/src2"
    export src_dir3="$BATS_FILE_TMPDIR/src3"

    export inc_dir1="$BATS_FILE_TMPDIR/inc1"
    export inc_dir2="$BATS_FILE_TMPDIR/inc2"
    export inc_dir3="$BATS_FILE_TMPDIR/inc3"

    export tb_dir1="$BATS_FILE_TMPDIR/tb1"
    export tb_dir2="$BATS_FILE_TMPDIR/tb2"
    export tb_dir3="$BATS_FILE_TMPDIR/tb3"

    export not_dir1="$BATS_FILE_TMPDIR/not_dir"
    export not_dir2="$BATS_FILE_TMPDIR/wrong_dir"

    export src_file1="${src_dir1}/main.sv"
    export src_file2="${src_dir1}/help.sv"
    export src_file3="${src_dir2}/hello.sv"
    export src_file4="${src_dir2}/bye.v"
    export src_file5="${src_dir3}/bootloader.v"
    export src_file6="${src_dir3}/init.v"

    export inc_file1="${inc_dir1}/main.svh"
    export inc_file2="${inc_dir1}/help.svh"
    export inc_file3="${inc_dir2}/hello.svh"
    export inc_file4="${inc_dir2}/bye.svh"
    export inc_file5="${inc_dir3}/bootloader_def.svh"
    export inc_file6="${inc_dir3}/init_def.svh"

    export tb_file1="${tb_dir1}/main_tb.py"
    export tb_file2="${tb_dir1}/help_tb.py"
    export tb_file3="${tb_dir2}/hello_tb.py"
    export tb_file4="${tb_dir2}/bye_tb.py"
    export tb_file5="${tb_dir3}/bootloader_tb.py"
    export tb_file6="${tb_dir3}/init_tb.py"

    export empty_dir="$BATS_FILE_TMPDIR/empty_dir"

    mkdir "${src_dir1}" "${src_dir2}" "${src_dir3}"
    mkdir "${inc_dir1}" "${inc_dir2}" "${inc_dir3}"
    mkdir "${tb_dir1}" "${tb_dir2}" "${tb_dir3}"
    mkdir "${empty_dir}"
    touch "${src_file1}" "${src_file2}" "${src_file3}" "${src_file4}" \
        "${src_file5}" "${src_file6}"
    touch "${inc_file1}" "${inc_file2}" "${inc_file3}" "${inc_file4}" \
        "${inc_file5}" "${inc_file6}"
    touch "${tb_file1}" "${tb_file2}" "${tb_file3}" "${tb_file4}" \
        "${tb_file5}" "${tb_file6}"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Print source files" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vprint_src \
        V_SRC_DIRS="${src_dir1} ${src_dir2}"
    assert_success
    assert_output --partial "SystemVerilog source files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}
${src_file4}
${src_file3}

EOF
}

@test "Print testbenches files" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vprint_tb \
        V_TEST_DIRS="${tb_dir1} ${tb_dir2}"
    assert_success
    assert_output --partial "Cocotb testbenches:"
    assert_output --partial --stdin <<EOF
${tb_file2}
${tb_file1}
${tb_file4}
${tb_file3}

EOF
}

@test "No V_INC_DIRS declared and print_header is called" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vprint_header
    assert_success
    assert_output --partial "SystemVerilog header files:"
}

@test "Print headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vprint_header \
        V_INC_DIRS="${inc_dir1}"
    assert_success
    assert_output --partial "SystemVerilog header files:"
    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}

EOF
}

@test "Print sources, testbenches and headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vprint \
        V_SRC_DIRS="${src_dir1}" \
        V_INC_DIRS="${inc_dir1} ${inc_dir2}" \
        V_TEST_DIRS="${tb_dir3}"

    assert_success
    assert_output --partial "SystemVerilog source files:"
    assert_output --partial "Cocotb testbenches:"
    assert_output --partial "SystemVerilog header files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}

EOF
    assert_output --partial --stdin <<EOF
${tb_file5}
${tb_file6}

EOF

    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}
${inc_file4}
${inc_file3}

EOF
}

@test "Directories pointing to ../ should be replaced with absolute paths" {
     run make -C "${MAKE_DIR}" -f cottimake.mk vprint \
        V_SRC_DIRS="${src_dir1}/../src3" \
        V_INC_DIRS="${inc_dir1}/../inc3"
    assert_success
    assert_output --partial "${src_file5}"
    assert_output --partial "${inc_file5}"
    refute_output --partial ".."
}
