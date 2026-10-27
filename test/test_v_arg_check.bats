#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tries the different ways in which the Makefile could be included
## in your build environment

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export src_dir1="$BATS_FILE_TMPDIR/src1"
    export src_dir2="$BATS_FILE_TMPDIR/src2"

    export inc_dir1="$BATS_FILE_TMPDIR/inc1"
    export inc_dir2="$BATS_FILE_TMPDIR/inc2"

    export tb_dir1="$BATS_FILE_TMPDIR/tb1"
    export tb_dir2="$BATS_FILE_TMPDIR/tb2"

    export not_dir1="$BATS_FILE_TMPDIR/not_dir"
    export not_dir2="$BATS_FILE_TMPDIR/wrong_dir"

    export src_file1="${src_dir1}/main.sv"
    export src_file2="${src_dir1}/help.sv"
    export src_file3="${src_dir2}/hello.sv"
    export src_file4="${src_dir2}/bye.sv"

    export tb_file1="${tb_dir1}/main_tb.py"
    export tb_file2="${tb_dir2}/hello_tb.py"

    export inc_file1="${inc_dir1}/main.svh"
    export inc_file2="${inc_dir1}/help.svh"
    export inc_file3="${inc_dir2}/hello.svh"
    export inc_file4="${inc_dir2}/bye.svh"

    export empty_dir="$BATS_FILE_TMPDIR/empty_dir"

    mkdir "${src_dir1}" "${src_dir2}" \
        "${inc_dir1}" "${inc_dir2}" \
        "${tb_dir1}" "${tb_dir2}"
    mkdir "${empty_dir}"
    touch "${src_file1}" "${src_file2}" "${src_file3}" "${src_file4}"
    touch "${inc_file1}" "${inc_file2}" "${inc_file3}" "${inc_file4}"
    touch "${tb_file1}" "${tb_file2}"

    printf "int main(void) {return 0;}\n" >> "${src_file1}"
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

@test "Compiling with empty V_SRC_DIRS or V_TEST_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile
    assert_failure
    assert_output --partial "[ERROR #019]"

    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1}" \
        V_TEST_DIRS=""
    assert_failure
    assert_output --partial "[ERROR #023]"
}

@test "Compiling with not existent V_SRC_DIRS or V_TEST_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1} ${not_dir1}" \
        V_TEST_DIRS="${tb_dir1}"
    assert_failure
    assert_output --partial "[ERROR #020]"
    assert_output --partial "${not_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir2}" \
        V_TEST_DIRS="${tb_dir1} ${not_dir1}"
    assert_failure
    assert_output --partial "[ERROR #022]"
    assert_output --partial "${not_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${not_dir1} ${not_dir2}" \
        V_TEST_DIRS="${tb_dir1}"
    assert_failure
    assert_output --partial "[ERROR #020]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"

    # Try different combinations of arguments
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${not_dir1} ${src_dir1} ${not_dir2} ${src_dir2}" \
        V_TEST_DIRS="${tb_dir1}"
    assert_failure
    assert_output --partial "[ERROR #020]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"
}

@test "Setting a file in V_SRC_DIRS or V_TEST_DIRS should not be allowed" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1} ${src_dir2} ${src_file1} ${src_file2}" \
        V_TEST_DIRS="${tb_dir1}"

    assert_failure
    assert_output --partial "[ERROR #020]"
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir2}" \
        V_TEST_DIRS="${tb_dir1} ${tb_file1} ${tb_file2}"
    assert_failure
    assert_output --partial "[ERROR #022]"
    assert_output --partial "${tb_file1}"
    assert_output --partial "${tb_file2}"
}

@test "Compiling with not existent V_INC_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1}" \
        V_TEST_DIRS="${tb_dir1}" \
        V_INC_DIRS="${inc_dir1} ${inc_dir2} ${not_dir1} ${not_dir2}"
    assert_failure
    assert_output --partial "[ERROR #021]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"
}

@test "If a source dir does not have any source file, fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${empty_dir}" \
        V_TEST_DIRS="${tb_dir1}"
    assert_failure
    assert_output --partial "[ERROR #013]"
    assert_output --partial "${empty_dir}"

    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1}" \
        V_TEST_DIRS="${empty_dir}"
    assert_failure
    assert_output --partial "[ERROR #015]"
    assert_output --partial "${empty_dir}"
}

@test "If a header dir does not have any header file, fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk vcompile \
        V_SRC_DIRS="${src_dir1}" \
        V_TEST_DIRS="${tb_dir1}" \
        V_INC_DIRS="${empty_dir}"
    assert_failure
    assert_output --partial "[ERROR #014]"
    assert_output --partial "${empty_dir}"
}
