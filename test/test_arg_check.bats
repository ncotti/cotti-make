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

    export not_dir1="$BATS_FILE_TMPDIR/not_dir"
    export not_dir2="$BATS_FILE_TMPDIR/wrong_dir"

    export src_file1="${src_dir1}/main.c"
    export src_file2="${src_dir1}/help.c"
    export src_file3="${src_dir2}/hello.c"
    export src_file4="${src_dir2}/bye.c"

    export inc_file1="${inc_dir1}/main.h"
    export inc_file2="${inc_dir1}/help.h"
    export inc_file3="${inc_dir2}/hello.h"
    export inc_file4="${inc_dir2}/bye.h"

    export empty_dir="$BATS_FILE_TMPDIR/empty_dir"

    mkdir "${src_dir1}" "${src_dir2}" "${inc_dir1}" "${inc_dir2}"
    mkdir "${empty_dir}"
    touch "${src_file1}" "${src_file2}" "${src_file3}" "${src_file4}"
    touch "${inc_file1}" "${inc_file2}" "${inc_file3}" "${inc_file4}"

    printf "int main(void) {return 0;}\n" >> "${src_file1}"

    # Try to install arm-none-eabi-gcc
    if ! command -v arm-none-eabi-gcc &>/dev/null; then
        sudo apt install gcc-arm-none-eabi
    fi

    if ! command -v gdb &>/dev/null; then
        sudo apt install gdb
    fi

    if ! command -v gnome-terminal &>/dev/null; then
        sudo apt install gnome-terminal
    fi
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

@test "Compiling with empty SRC_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile
    assert_failure
    assert_output --partial "[ERROR #001]"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS=" "
    assert_failure
    assert_output --partial "[ERROR #001]"
}

@test "Compiling with not existent SRC_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1} ${not_dir1}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${not_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir2}" \
        TEST_SRC_DIRS="${src_dir1} ${not_dir1}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${not_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir2}" \
        TEST_FRAMEWORK_SRC_DIRS="${src_dir1} ${not_dir1}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${not_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${not_dir1} ${not_dir2}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"

     # Try different combinations of arguments
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${not_dir1} ${src_dir1} ${not_dir2} ${src_dir2}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"
}

@test "Setting a file in SRC_DIRS should not be allowed" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1} ${src_dir2} ${src_file1} ${src_file2}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir2}" \
        TEST_SRC_DIRS="${src_dir1} ${src_file1} ${src_file2}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir2}" \
        TEST_FRAMEWORK_SRC_DIRS="${src_dir1} ${src_file1} ${src_file2}"
    assert_failure
    assert_output --partial "[ERROR #002]"
    assert_output --partial "${src_file1}"
    assert_output --partial "${src_file2}"
}

@test "Compiling with not existent INC_DIRS should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1} ${inc_dir2} ${not_dir1} ${not_dir2}"
    assert_failure
    assert_output --partial "[ERROR #003]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        TEST_INC_DIRS="${inc_dir1} ${inc_dir2} ${not_dir1} ${not_dir2}"
    assert_failure
    assert_output --partial "[ERROR #003]"
    assert_output --partial "${not_dir1}"
    assert_output --partial "${not_dir2}"
}

@test "If a source dir does not have any source file, fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${empty_dir}"
    assert_failure
    assert_output --partial "[ERROR #004]"
    assert_output --partial "${empty_dir}"
}

@test "If a header dir does not have any header file, fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${empty_dir}"
    assert_failure
    assert_output --partial "[ERROR #005]"
    assert_output --partial "${empty_dir}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        TEST_INC_DIRS="${empty_dir}"
    assert_failure
    assert_output --partial "[ERROR #005]"
    assert_output --partial "${empty_dir}"
}

@test "Repeated source directories should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1} ${src_dir1}"
    assert_output --partial "[ERROR #006]"
    assert_output --partial "${src_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        TEST_SRC_DIRS="${src_dir1}"
    assert_output --partial "[ERROR #006]"
    assert_output --partial "${src_dir1}"
}

@test "Repeated include directories should fail" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1} ${inc_dir1} ${inc_dir2}"
    assert_output --partial "[ERROR #007]"
    assert_output --partial "${inc_dir1}"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        TEST_INC_DIRS="${inc_dir1}"
    assert_output --partial "[ERROR #007]"
    assert_output --partial "${inc_dir1}"
}

@test "Wrong toolchain fails" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        CROSS_COMPILE="arch-os-abi-"

    assert_failure
    assert_output --partial "[ERROR #008]"
    assert_output --partial "arch-os-abi-gcc"
}

@test "Correct toolchain, but wrong binutils" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        CROSS_COMPILE="" \
        CC="xd"

    assert_failure
    assert_output --partial "[ERROR #008]"
    assert_output --partial "xd"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        CROSS_COMPILE="arm-none-eabi-" \
        LD="xd"

    assert_failure
    assert_output --partial "[ERROR #008]"
    assert_output --partial "xd"
}

@test "If a simulator is specified, it should be installed and be either qemu or renode" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        SIM="xd"
    assert_failure
    assert_output --partial "[ERROR #009]"
    assert_output --partial "xd"

    # gcc is not a valid simulator, but a valid program.
    # It should fail regardless
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        SIM="gcc"
    assert_failure
    assert_output --partial "[ERROR #009]"
    assert_output --partial "gcc"
}

@test "Terminal launcher program should exist" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}" \
        TERMINAL="xd"
    assert_failure
    assert_output --partial "[ERROR #010]"
    assert_output --partial "xd"
}
