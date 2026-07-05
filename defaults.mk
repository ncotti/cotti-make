# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains default values for user-defined variables.

#------------------------------------------------------------------------------
# Source include and lib directories
#------------------------------------------------------------------------------
# White-space separated list of paths where source files are.
# All files ending with ".c", ".s" or ".S" will be listed as source files.
SRC_DIRS ?=

# White-space separated list of paths where non-system header files are.
# All files ending with ".h", ".s" or ".S" will be listed as header files.
INC_DIRS ?=

# White-space separated list of paths where non-system libraries are.
# Library names must be defined in the "LDLIBS" variable
LIB_DIRS ?=

#------------------------------------------------------------------------------
# Compiler and toolchain selection
#------------------------------------------------------------------------------

# Toolchain used to compile.
# Compile commands will have the value of the toolchain prepended.
# E.g.: arm-none-eabi-, arm-linux-gnueabihf-, (left empty), etc
CROSS_COMPILE ?=

# C compiler, used to compile a ".c" file into an object file ".o"
ifeq ($(origin CC), default)
CC := gcc
endif

# Assembler, used to compile an ".S" or ".s" file into an object file ".o"
ifeq ($(origin AS), default)
AS := $(CC)
endif

# Linker, used when merging all object files into an executable file ".elf"
ifeq ($(origin LD), default)
LD := $(CC)
endif

# GDB debugger
# If $(CROSS_COMPILE)$(GDB) exists, it will be used.
# Otherwise, the binary defined here will be used instead.
GDB ?= gdb

# Simulator used when running "make sim" command
# Only valid ones are: qemu[*] | renode
SIM ?=

# Objdump binutil, used to create disassembly files and section headers
OBJDUMP	?= objdump

# Objcopy binutil, used to create stripped .bin and .hex files from .elf files
OBJCOPY ?= objcopy

# Archive binutil, used to create static libraries
ifeq ($(origin AR), default)
AR := ar
endif

# Program used to spawn new terminal windows
# Some targets of this Makefile require launching a new program and, for that
# purpose, create a new terminal for the user to see it running.
# If left blank, then no external display is shown.
TERMINAL ?= gnome-terminal

#------------------------------------------------------------------------------
# Compiler, assembler and linker flags
#------------------------------------------------------------------------------
# C compiler flags
CFLAGS ?= -Wall -g -Wpedantic

# Assembler flags
ASFLAGS ?= $(CFLAGS)

# Linker flags
LDFLAGS ?= -g

# Libraries to link against.
# Library <name>s must follow the convention: "lib<name>.so" or "lib<name>.a"
LDLIBS ?=

# Linker script (if any)
LDSCRIPT ?=

# GDB flags.
# The following flags are always added to the GDB command by default:
# -q
# -x $(GDBSCRIPT)
GDBFLAGS ?=

# Name of the gdb script (if any)
GDBSCRIPT ?=

# Simulator flags
SIMFLAGS ?=

#------------------------------------------------------------------------------
# Run-time variables
#------------------------------------------------------------------------------
# Name of the executable ".elf" file (without extension)
EXE ?= exe

# Parameters used when running the executable file
EXEFLAGS ?=

#------------------------------------------------------------------------------
# Test framework variables
#------------------------------------------------------------------------------
# White-space separated list of paths where test files are.
# Every single ".c" file located in these directories will be treated as a
# test case and will be executed independently from the rest.
TEST_SRC_DIRS ?=

# White-space separated list of paths where header files ".h" for the test are.
TEST_INC_DIRS ?=

# White-space separated list of paths where supporting sources for test cases
# are. These files will be compiled alongside test cases found in
# TEST_SRC_DIRS, but will not be executed themselves.
TEST_FRAMEWORK_SRC_DIRS ?=

#------------------------------------------------------------------------------
# Extra variables TODO better name?
#------------------------------------------------------------------------------
# Name of the folder where all build artifacts will be generated
BUILD_DIR ?= build

# Name of the clang-tidy configuration file
CLANG_TIDY_CONFIG_FILE ?= $(MAKE_ROOT)/.clang-tidy

# Name of the clang-format configuration file
CLANG_FORMAT_CONFIG_FILE ?= $(MAKE_ROOT)/.clang-format
