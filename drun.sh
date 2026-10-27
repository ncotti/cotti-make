#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This script runs the docker environment locally

export HOST_UID
export HOST_GID
export BATS_PATH

HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

docker compose run --rm toolchain
