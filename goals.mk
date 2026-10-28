# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains classifies all the "goals" or "targets"
## from the Makefile into useful categories for other parts.

# The goal that was used when calling this Makefile, as "make <goal>"
GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),$(.DEFAULT_GOAL))

# Goals that require the C-toolchain installed.
GOALS_C_TOOLCHAIN := bin compile compile_dynamic_lib compile_static_lib \
	dasm debug fmt headers hex run sim test tidy

# Goals that require GDB or simulation.
GOALS_C_DBG := debug sim

# C language static analyzer or formatter.
GOALS_C_LINT := tidy fmt

# Verilog compilation goals
GOALS_VERILOG := vcompile vdebug vrun vfmt vlint vdebug

# Verilog linting
GOALS_VERILOG_LINT := vfmt vlint

# Verilog waveforms
GOALS_WAVEFORM := vdebug
