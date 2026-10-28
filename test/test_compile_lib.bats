#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests compilation and usage of static and dynamic libraries
## using the "examples/externals" projects.

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/.."

    export EXT1_SRC_DIRS="$BATS_TEST_DIRNAME/../examples/externals/external_project1"
    export EXT1_INC_DIRS="$BATS_TEST_DIRNAME/../examples/externals/external_project1"

    export EXT2_SRC_DIRS="$BATS_TEST_DIRNAME/../examples/externals/external_project2/src"
    export EXT2_INC_DIRS="$BATS_TEST_DIRNAME/../examples/externals/external_project2/inc"

    export CONSUMER_SRC_DIRS="$BATS_TEST_DIRNAME/../examples/externals/external_consumer"
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    export EXT1_BUILD_DIR="$BATS_TEST_TMPDIR/build_ext1"
    export EXT2_BUILD_DIR="$BATS_TEST_TMPDIR/build_ext2"
    export CONSUMER_BUILD_DIR="$BATS_TEST_TMPDIR/build_consumer"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Compiling static library" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_static_lib \
        SRC_DIRS="${EXT1_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS}" \
        BUILD_DIR="${EXT1_BUILD_DIR}" \
        EXE="external1"
    assert_success
    assert_file_exists "${EXT1_BUILD_DIR}/libexternal1.a"
    assert_output --partial "${EXT1_BUILD_DIR}/libexternal1.a"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile_static_lib \
        SRC_DIRS="${EXT2_SRC_DIRS}" \
        INC_DIRS="${EXT2_INC_DIRS}" \
        BUILD_DIR="${EXT2_BUILD_DIR}" \
        EXE="external2"
    assert_success
    assert_file_exists "${EXT2_BUILD_DIR}/libexternal2.a"
    assert_output --partial "${EXT2_BUILD_DIR}/libexternal2.a"
}

@test "Compiling dynamic library" {
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_dynamic_lib \
        SRC_DIRS="${EXT1_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS}" \
        BUILD_DIR="${EXT1_BUILD_DIR}" \
        EXE="external1"
    assert_success
    assert_file_exists "${EXT1_BUILD_DIR}/libexternal1.so"
    assert_output --partial "${EXT1_BUILD_DIR}/libexternal1.so"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile_dynamic_lib \
        SRC_DIRS="${EXT2_SRC_DIRS}" \
        INC_DIRS="${EXT2_INC_DIRS}" \
        BUILD_DIR="${EXT2_BUILD_DIR}" \
        EXE="external2"
    assert_success
    assert_file_exists "${EXT2_BUILD_DIR}/libexternal2.so"
    assert_output --partial "${EXT2_BUILD_DIR}/libexternal2.so"
}

@test "Executing with static libraries" {
    # First compile external static libraries
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_static_lib \
        SRC_DIRS="${EXT1_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS}" \
        BUILD_DIR="${EXT1_BUILD_DIR}" \
        EXE="external1"
    assert_success
    assert_file_exists "${EXT1_BUILD_DIR}/libexternal1.a"
    assert_output --partial "${EXT1_BUILD_DIR}/libexternal1.a"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile_static_lib \
        SRC_DIRS="${EXT2_SRC_DIRS}" \
        INC_DIRS="${EXT2_INC_DIRS}" \
        BUILD_DIR="${EXT2_BUILD_DIR}" \
        EXE="external2"
    assert_success
    assert_file_exists "${EXT2_BUILD_DIR}/libexternal2.a"
    assert_output --partial "${EXT2_BUILD_DIR}/libexternal2.a"

    # Now compile consumer project
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS} ${EXT2_INC_DIRS}" \
        LIB_DIRS="${EXT1_BUILD_DIR} ${EXT2_BUILD_DIR}" \
        LDLIBS="external1 external2" \
        EXE="consumer" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_file_exists "${CONSUMER_BUILD_DIR}/consumer.elf"

    # Test execution (static libraries do not need to have the
    # library paths defined on execution)
    run LD_LIBRARY_PATH="" make -C "${MAKE_DIR}" -f cottimake.mk run \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        EXE="consumer" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_output --partial "Running consumer project. Value is: 19"

    # If no library paths are specified, nothing should be printed
    refute_output --partial "LD_LIBRARY_PATH"
}

@test "Executing with dynamic libraries" {
    # First compile external dynamic libraries
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_dynamic_lib \
        SRC_DIRS="${EXT1_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS}" \
        BUILD_DIR="${EXT1_BUILD_DIR}" \
        EXE="external1"
    assert_success
    assert_file_exists "${EXT1_BUILD_DIR}/libexternal1.so"
    assert_output --partial "${EXT1_BUILD_DIR}/libexternal1.so"

    run make -C "${MAKE_DIR}" -f cottimake.mk compile_dynamic_lib \
        SRC_DIRS="${EXT2_SRC_DIRS}" \
        INC_DIRS="${EXT2_INC_DIRS}" \
        BUILD_DIR="${EXT2_BUILD_DIR}" \
        EXE="external2"
    assert_success
    assert_file_exists "${EXT2_BUILD_DIR}/libexternal2.so"
    assert_output --partial "${EXT2_BUILD_DIR}/libexternal2.so"

    # Now compile consumer project
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS} ${EXT2_INC_DIRS}" \
        LIB_DIRS="${EXT1_BUILD_DIR} ${EXT2_BUILD_DIR}" \
        LDLIBS="external1 external2" \
        EXE="consumer" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_file_exists "${CONSUMER_BUILD_DIR}/consumer.elf"

    # Test execution
    # Both library paths are needed
    run export LD_LIBRARY_PATH="" make -C "${MAKE_DIR}" -f cottimake.mk run \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        EXE="consumer" \
        LIB_DIRS="${EXT1_BUILD_DIR} ${EXT2_BUILD_DIR}" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_output --partial "Running consumer project. Value is: 19"
    assert_output --partial "LD_LIBRARY_PATH=${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}"

    # There should not be a semicolon at the start or end
    refute_output --partial "LD_LIBRARY_PATH=:${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}"
    refute_output --partial "LD_LIBRARY_PATH=${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}:"

    # Execute again, but now with an extra path in the LD_LIBRARY_PATH
    run LD_LIBRARY_PATH=/some/random/lib/path make -C "${MAKE_DIR}" -f cottimake.mk run \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        EXE="consumer" \
        LIB_DIRS="${EXT1_BUILD_DIR} ${EXT2_BUILD_DIR}" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_output --partial "Running consumer project. Value is: 19"
    assert_output --partial "LD_LIBRARY_PATH=${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}:${LD_LIBRARY_PATH}"

    # There should not be a semicolon at the start or end
    refute_output --partial "LD_LIBRARY_PATH=:${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}:${LD_LIBRARY_PATH}"
    refute_output --partial "LD_LIBRARY_PATH=${EXT1_BUILD_DIR}:${EXT2_BUILD_DIR}:${LD_LIBRARY_PATH}:"
}

@test "Executing with static and dynamic libraries" {
    # Compile static library
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_static_lib \
        SRC_DIRS="${EXT1_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS}" \
        BUILD_DIR="${EXT1_BUILD_DIR}" \
        EXE="external1"
    assert_success
    assert_file_exists "${EXT1_BUILD_DIR}/libexternal1.a"
    assert_output --partial "${EXT1_BUILD_DIR}/libexternal1.a"

    # Compile dynamic library
    run make -C "${MAKE_DIR}" -f cottimake.mk compile_dynamic_lib \
        SRC_DIRS="${EXT2_SRC_DIRS}" \
        INC_DIRS="${EXT2_INC_DIRS}" \
        BUILD_DIR="${EXT2_BUILD_DIR}" \
        EXE="external2"
    assert_success
    assert_file_exists "${EXT2_BUILD_DIR}/libexternal2.so"
    assert_output --partial "${EXT2_BUILD_DIR}/libexternal2.so"

    # Now compile consumer project
    run make -C "${MAKE_DIR}" -f cottimake.mk compile \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        INC_DIRS="${EXT1_INC_DIRS} ${EXT2_INC_DIRS}" \
        LIB_DIRS="${EXT1_BUILD_DIR} ${EXT2_BUILD_DIR}" \
        LDLIBS="external1 external2" \
        EXE="consumer" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_file_exists "${CONSUMER_BUILD_DIR}/consumer.elf"

    # Test execution
    # Only dynamic lib library path is needed
    export LD_LIBRARY_PATH=""
    run make -C "${MAKE_DIR}" -f cottimake.mk run \
        SRC_DIRS="${CONSUMER_SRC_DIRS}" \
        EXE="consumer" \
        LIB_DIRS="${EXT2_BUILD_DIR}" \
        BUILD_DIR="${CONSUMER_BUILD_DIR}"
    assert_success
    assert_output --partial "Running consumer project. Value is: 19"
    assert_output --partial "LD_LIBRARY_PATH=${EXT2_BUILD_DIR}"

    # There should not be a semicolon at the start or end
    refute_output --partial "LD_LIBRARY_PATH=:${EXT2_BUILD_DIR}"
    refute_output --partial "LD_LIBRARY_PATH=${EXT2_BUILD_DIR}:"
}