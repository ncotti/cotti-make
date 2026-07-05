#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the inclusion of the CLang utils:
## * bear and creation of compilation_commands.json
## * clang-tidy
## * clang-formatter
## This test re-utilizes the "examples/c_project"

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/c_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${PROJECT_DIR}/build/c_project_exe.elf"

    run make -C "${PROJECT_DIR}" clean

    if ! command -v bear &>/dev/null; then
        sudo apt install -y bear
    fi

    if ! command -v clang-tidy &>/dev/null; then
        sudo apt install -y clang-tidy
    fi

    if ! command -v clang-format &>/dev/null; then
        sudo apt install -y clang-format
    fi
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

@test "Clang-tidy runs as expected" {
    # Compilation alone does not generate the file
    run make -C "${PROJECT_DIR}" compile
    assert_success
    assert_file_not_exist "${BUILD_DIR}/compile_commands.json"

    # Running tidy should trigger a re-compilation and generate the
    # compile_commands.json file
    run make -C "${PROJECT_DIR}" tidy
    assert_success
    assert_output --partial "[CC]"
    refute_output --partial "[LD]"
    # This line ensures that the four source files were checked
    assert_output --partial "[4/4]"
    assert_file_exist "${BUILD_DIR}/compile_commands.json"

    # Running tidy again should re-print the same message, but without
    # compiling
    run make -C "${PROJECT_DIR}" tidy
    assert_success
    refute_output --partial "[CC]"
    refute_output --partial "[LD]"
    # This line ensures that the four source files were checked
    assert_output --partial "[4/4]"
    assert_file_exist "${BUILD_DIR}/compile_commands.json"
}

@test "Using custom .clang-tidy file" {
    # If you point to a wrong file, it should fail
    run make -C "${PROJECT_DIR}" tidy \
        CLANG_TIDY_CONFIG_FILE="xd"
    assert_failure
    assert_output --partial "xd"
    assert_output --partial "can't read config-file"
}

@test "Formatting files should succeed" {
    run make -C "${PROJECT_DIR}" format
    assert_success
    assert_output --partial "[CC]"
    assert_file_exist "${BUILD_DIR}/compile_commands.json"

    # This line ensures that the four source files and the four
    # header files were checked
    assert_output --partial "[8/8]"
}

@test "Using custom .clang-format file" {
    # If you point to a wrong file, it should fail
    run make -C "${PROJECT_DIR}" format \
        CLANG_FORMAT_CONFIG_FILE="xd"
    assert_failure
    assert_output --partial "Error reading xd: No such file or directory"
}