#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests that a recompilation is triggered whenever a
## source file, header file, Makefile, or linker script are changed.

setup_file() {
    true
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    # For this test, we will copy all the cottimake's Makefiles into the
    # test's tmp folder.
    export COTTI_MAKE_DIR="$BATS_TEST_TMPDIR/cottimake"

    mkdir -p "${COTTI_MAKE_DIR}"

    # Allow word-splitting to copy the folder's contents
    # shellcheck disable=SC2046
    cp $(ls "$BATS_TEST_DIRNAME"/../*.mk) "${COTTI_MAKE_DIR}"

    export MAKE_DIR="$BATS_TEST_TMPDIR"
    export BUILD_DIR="$BATS_TEST_TMPDIR/build"

    export src_dir="$BATS_TEST_TMPDIR/src1"
    export inc_dir="$BATS_TEST_TMPDIR/inc1"
    export src_file1="${src_dir}/main.c"
    export src_file2="${src_dir}/help.c"
    export inc_file1="${inc_dir}/main.h"
    export inc_file2="${inc_dir}/help.h"
    export make_file="$BATS_TEST_TMPDIR/Makefile"
    export linker_file="$BATS_TEST_TMPDIR/linker.ld"
    export exe_file="$BATS_TEST_TMPDIR/build/exe"

    mkdir "${src_dir}" "${inc_dir}"

    cat > "${make_file}" <<EOF
SRC_DIRS := ${src_dir}
INC_DIRS := ${inc_dir}
LDSCRIPT := ${linker_file}
BUILD_DIR := ${BUILD_DIR}

include ${COTTI_MAKE_DIR}/cottimake.mk
EOF

    cat > "${src_file1}" <<EOF
#include "main.h"
#include "help.h"

int main (void) {
    helper_printf("Hello world\n");
    printf("Hello world\n");
    return 0;
}
EOF

    cat > "${inc_file1}" << EOF
#include <stdio.h>
EOF

    cat > "${src_file2}" <<EOF
#include "help.h"

void helper_printf(const char *str) {
    printf(str);
}
EOF

    cat > "${inc_file2}" << EOF
#include <stdio.h>

void helper_printf(const char *str);
EOF

    cat > "${linker_file}" << EOF
/* Just an empty file, nothing to worry about */
INSERT AFTER .rodata;
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
    assert_output --partial "${exe_file}"

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

