#!/bin/bash

## This script runs the docker environment locally

export HOST_UID
export HOST_GID
export BATS_PATH

HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

docker compose run --rm toolchain
