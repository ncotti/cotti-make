#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the "make test" command and all implications related
## to compiling test files
## This test re-utilizes the "examples/c_project"

setup_file() {
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/c_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${PROJECT_DIR}/build/c_project_exe.elf"

    export TEST_SRC_DIRS="${PROJECT_DIR}/../test"
    export TEST_INC_DIRS="${PROJECT_DIR}/../../test/framework/unity/src ${PROJECT_DIR}/../../test/framework/fff"
    export TEST_FRAMEWORK_SRC_DIRS="${PROJECT_DIR}/../../test/framework/unity/src"

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

@test "Test files should not be included in normal compilation" {
    run make -C "${PROJECT_DIR}" compile
    assert_success
    refute_output --partial "[TEST_CC]"
    refute_output --partial "[TEST_LD]"
}

@test "Tests should be run successfully" {
    run make -C "${PROJECT_DIR}" test
    assert_success
    assert_output --partial "[TEST_CC]"
    assert_output --partial "[TEST_LD]"
}

@test "Test files should be included in the static analysis" {
    run make -C "${PROJECT_DIR}" tidy
    assert_success
    assert_output --partial "[TEST_CC]"
    refute_output --partial "[TEST_LD]"
    # This line ensures that the four source files and the two test files
    # where checked. Test headers should not be included
    assert_output --partial "[6/6]"
    assert_file_exist "${BUILD_DIR}/compile_commands.json"
}

@test "Test files should be included in the formatter" {
    run make -C "${PROJECT_DIR}" format
    assert_success
    assert_output --partial "[CC]"
    assert_file_exist "${BUILD_DIR}/compile_commands.json"
    # This line ensures that the four source files, the four
    # header files and the two tests are being considered for formatting
    assert_output --partial "[10/10]"
}
