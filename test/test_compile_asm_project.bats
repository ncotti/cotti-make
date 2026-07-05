#!/usr/bin/env bats
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file tests the compilation of the "asm_project" in the "examples"
## folder

setup_file() {
    export MAKE_DIR="$BATS_TEST_DIRNAME/../"
    export PROJECT_DIR="$BATS_TEST_DIRNAME/../examples/asm_project"
    export BUILD_DIR="${PROJECT_DIR}/build"
    export ELF_FILE="${BUILD_DIR}/exe.elf"

    # Try to install arm-none-eabi-gcc and qemu-system-arm
    if ! command -v arm-none-eabi-gcc &>/dev/null; then
        sudo apt install -y gcc-arm-none-eabi
    fi

    if ! command -v qemu-system-arm &>/dev/null; then
        sudo apt install -y qemu-system-arm
    fi

    if ! command -v gdb-multiarch &>/dev/null; then
        sudo apt install -y gdb-multiarch
    fi

    if ! command -v renode &>/dev/null; then
        if [ ! -x "/tmp/renode/renode" ]; then
            mkdir -p /tmp/renode
            wget -qO- https://github.com/renode/renode/releases/download/v1.16.1/renode-1.16.1.linux-portable.tar.gz | \
                tar -xz --strip-components=1 -C /tmp/renode/
        fi
        export PATH="${PATH}:/tmp/renode"
    fi
}

setup() {
    load "framework/bats-support/load"
    load "framework/bats-assert/load"
    load "framework/bats-file/load"

    rm -rf "${BUILD_DIR}"

    assert_dir_not_exist "${BUILD_DIR}"
}

teardown() {
    true
}

teardown_file() {
    true
}

@test "Compilation should succeed" {
    run make -C "${PROJECT_DIR}" compile
    assert_success
    assert_file_exist "${ELF_FILE}"
}

@test "Trying to run a cross compiled file locally should fail" {
    run make -C "${PROJECT_DIR}" run
    assert_failure
}

@test "Launching and killing QEMU simulation environment" {
    run make -C "${PROJECT_DIR}" sim \
        SIM="qemu-system-arm"
    sleep 2
    assert_success
    assert_file_exists "${BUILD_DIR}/sim.pid"

    run make -C "${PROJECT_DIR}" kill_sim \
        SIM="qemu-system-arm"
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
}

@test "Running QEMU simulation" {
    run make -C "${PROJECT_DIR}" debug \
        SIM="qemu-system-arm" \
        GDB="gdb-multiarch" \
        GDBSCRIPT="debug.gdb"
    sleep 2
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
    assert_output --partial "Value retrieved from gdb: 12"
}

@test "Launching and killing Renode simulation environment" {
    run make -C "${PROJECT_DIR}" sim \
        SIM="renode"
    sleep 2
    assert_success
    assert_file_exists "${BUILD_DIR}/sim.pid"

    run make -C "${PROJECT_DIR}" kill_sim \
        SIM="renode"
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
}

@test "Running Renode simulation" {
    run make -C "${PROJECT_DIR}" debug \
        SIM="renode" \
        GDB="gdb-multiarch" \
        GDBSCRIPT="debug.gdb"
    sleep 2
    assert_success
    assert_file_not_exist "${BUILD_DIR}/sim.pid"
    assert_output --partial "Value retrieved from gdb: 12"
}
