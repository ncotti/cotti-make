#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tries to compile a minimalistic hello world

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export src_dir="$BATS_FILE_TMPDIR/src1"
    export src_file="${src_dir}/main.c"
    mkdir "${src_dir}"

    cat > "${src_file}" <<EOF
#include <stdio.h>
int main(void) {
    printf("Hello world\n");
    return 0;
}
EOF

    if ! command -v clang &>/dev/null; then
        sudo apt install -y clang
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

@test "Minimal hello world compilation should succeed" {
    run make -C "${MAKE_DIR}" -f cottimake.mk print compile \
        SRC_DIRS="${src_dir}"
    assert_success
    assert_file_exist "${MAKE_DIR}/build/exe.elf"

   run make -C "${MAKE_DIR}" -f cottimake.mk clean

    # Changing build dir location
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir}" \
        BUILD_DIR="custom_build_dir"

    assert_success
    assert_file_exist "${MAKE_DIR}/custom_build_dir/exe.elf"

    run make -C "${MAKE_DIR}" -f cottimake.mk clean \
        BUILD_DIR="custom_build_dir"

    assert_success
    assert_dir_not_exist "${MAKE_DIR}/custom_build_dir"
}

@test "Changing name of exe file" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir}"
    assert_success
    assert_file_exist "${MAKE_DIR}/build/exe.elf"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir}" \
        EXE="custom_exe"
    assert_success
    assert_file_exist "${MAKE_DIR}/build/exe.elf"
    assert_file_exist "${MAKE_DIR}/build/custom_exe.elf"
}

@test "Using clang for compilation" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${src_dir}" \
        CC="clang"

    assert_success
    assert_file_exist "${MAKE_DIR}/build/exe.elf"
}
