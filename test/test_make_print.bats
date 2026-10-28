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

    export not_dir1="$BATS_FILE_TMPDIR/not_dir"
    export not_dir2="$BATS_FILE_TMPDIR/wrong_dir"

    export src_file1="${src_dir1}/main.c"
    export src_file2="${src_dir1}/help.c"
    export src_file3="${src_dir2}/hello.c"
    export src_file4="${src_dir2}/bye.c"
    export src_file5="${src_dir3}/bootloader.S"
    export src_file6="${src_dir3}/init.s"

    export inc_file1="${inc_dir1}/main.h"
    export inc_file2="${inc_dir1}/help.h"
    export inc_file3="${inc_dir2}/hello.h"
    export inc_file4="${inc_dir2}/bye.h"
    export inc_file5="${inc_dir3}/bootloader_def.S"
    export inc_file6="${inc_dir3}/init_def.s"

    export obj_file1="build/${src_dir1}/main.o"
    export obj_file2="build/${src_dir1}/help.o"
    export obj_file3="build/${src_dir2}/hello.o"
    export obj_file4="build/${src_dir2}/bye.o"
    export obj_file5="build/${src_dir3}/bootloader_asm.o"
    export obj_file6="build/${src_dir3}/init_asm.o"

    export empty_dir="$BATS_FILE_TMPDIR/empty_dir"

    mkdir "${src_dir1}" "${src_dir2}" "${src_dir3}"
    mkdir "${inc_dir1}" "${inc_dir2}" "${inc_dir3}"
    mkdir "${empty_dir}"
    touch "${src_file1}" "${src_file2}" "${src_file3}" "${src_file4}" \
        "${src_file5}" "${src_file6}"
    touch "${inc_file1}" "${inc_file2}" "${inc_file3}" "${inc_file4}" \
        "${inc_file5}" "${inc_file6}"
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
    run make -C "${MAKE_DIR}" -f cottimake.mk print_src \
        SRC_DIRS="${src_dir1} ${src_dir2}"
    assert_success
    assert_output --partial "Source files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}
${src_file4}
${src_file3}

EOF
}

@test "Print object files" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_obj \
        SRC_DIRS="${src_dir1} ${src_dir2}"
    assert_success
    assert_output --partial "Object files:"
    assert_output --partial --stdin <<EOF
${obj_file2}
${obj_file1}
${obj_file4}
${obj_file3}
build/exe.elf

EOF
}

@test "No INC_DIRS declared and print_header is called" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_header \
        SRC_DIRS="${src_dir1}"
    assert_success
    assert_output --partial "Header files:"
}

@test "Print headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_header \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1}"
    assert_success
    assert_output --partial "Header files:"
    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}

EOF
}

@test "Print sources, objects and headers" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print \
        SRC_DIRS="${src_dir1}" \
        INC_DIRS="${inc_dir1} ${inc_dir2}"

    assert_success
    assert_output --partial "Source files:"
    assert_output --partial "Object files:"
    assert_output --partial "Header files:"
    assert_output --partial --stdin <<EOF
${src_file2}
${src_file1}

EOF
    assert_output --partial --stdin <<EOF
${obj_file2}
${obj_file1}
build/exe.elf

EOF

    assert_output --partial --stdin <<EOF
${inc_file2}
${inc_file1}
${inc_file4}
${inc_file3}

EOF
}

@test "Files with .s or .S should both be valid sources" {
     run make -C "${MAKE_DIR}" -f cottimake.mk print_src \
        SRC_DIRS="${src_dir3}"
    assert_success
    assert_output --partial "Source files:"
        assert_output --partial --stdin <<EOF
${src_file5}
${src_file6}

EOF
}

@test "Assembly object files should end with _asm.o" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_obj \
        SRC_DIRS="${src_dir3}"
    assert_success
    assert_output --partial "Object files:"
    assert_output --partial --stdin <<EOF
${obj_file5}
${obj_file6}

EOF
}

@test "Assembly files might be header files aswell" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print_header \
        SRC_DIRS="${src_dir3}" \
        INC_DIRS="${inc_dir3}"
    assert_success
    assert_output --partial "Header files:"
    assert_output --partial --stdin <<EOF
${inc_file5}
${inc_file6}

EOF
}

@test "Directories pointing to ../ should be replaced with absolute paths" {
     run make -C "${MAKE_DIR}" -f cottimake.mk print \
        SRC_DIRS="${src_dir1}/../src3" \
        INC_DIRS="${inc_dir1}/../inc3"
    assert_success
    assert_output --partial "${src_file5}"
    assert_output --partial "${inc_file5}"
    refute_output --partial ".."
}
