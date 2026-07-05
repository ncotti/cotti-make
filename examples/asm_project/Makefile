# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

SRC_DIRS ?= src startup
INC_DIRS ?= inc

CROSS_COMPILE ?= arm-none-eabi-

CC ?= gcc

CFLAGS ?= -Wall -g -marm -mcpu=cortex-a8 -mfloat-abi=softfp
LDFLAGS ?= -nostartfiles -Wl,--gc-sections

LDSCRIPT ?= linker_script.ld

GDB ?= gdb-multiarch
GDBSCRIPT ?= debug_interactive.gdb

BUILD_DIR ?= build
EXE ?= exe

SIM ?= qemu-system-arm

define _SIMFLAGS_QEMU
-M realview-pb-a8 \
-m 32M \
-no-reboot -nographic \
-monitor stdio \
-serial telnet:localhost:2222,server,nowait \
-S -gdb tcp:localhost:2159 \
-device loader,file=$(BUILD_DIR)/$(EXE).elf
endef

define _SIMFLAGS_RENODE
resc.resc
endef

ifneq ($(findstring qemu,$(SIM)),)
SIMFLAGS ?= $(_SIMFLAGS_QEMU)
else ifneq ($(findstring renode,$(SIM)),)
SIMFLAGS ?= $(_SIMFLAGS_RENODE)
endif

include ../../cottimake.mk
