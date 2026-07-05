# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

SRC_DIRS ?= src src/nested_src
INC_DIRS ?= inc inc/nested_inc
EXE ?= c_project_exe

GDBSCRIPT ?= interactive_gdb_script.gdb

CFLAGS ?= -Wall -Wpedantic -g

# Assembler flags)
ASFLAGS ?= $(CFLAGS)

# Linker flags
LDFLAGS ?=

include ../../cottimake.mk

.PHONY: custom_target ## Custom target
custom_target:
	printf "Hi\n"