# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains the compilation and simulation targets for a
## SystemVerilog project
## All verilog-related targets are prepended with a "v".
##
## For the list of cocotb Makefile variables, see
## https://docs.cocotb.org/en/stable/building.html

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------

# Source files
V_SRCS := $(foreach dir, $(V_SRC_DIRS), $(wildcard $(dir)/*.v) $(wildcard $(dir)/*.sv))

# Header files
V_HEADERS := $(foreach dir, $(V_INC_DIRS), $(wildcard $(dir)/*.svh))

# Test files
V_TESTS := $(foreach dir, $(V_TEST_DIRS), $(wildcard $(dir)/*.py))

ifdef V_TB_TOP
V_TESTS := $(foreach tb,$(V_TESTS),\
    $(if $(filter $(V_TB_TOP) $(V_TB_TOP)_tb,$(basename $(notdir $(tb)))),$(tb)))

V_TESTS := $(strip $(V_TESTS))

ifeq ($(V_TESTS),)
$(error $(MSG_WRONG_V_TB_TOP) $(V_TB_TOP))
endif

endif # V_TB_TOP

# Waveform files.
# A waveform is generated for each test, mimicking its path inside the
# "$(V_BUILD_DIR)/waves" folder.
V_WAVEFORMS := $(patsubst %.py, %_dump.fst, $(V_TESTS))
V_WAVEFORMS := $(addprefix $(V_BUILD_DIR)/waves/,$(V_WAVEFORMS))

# Lint files
# This files are created as a "proof of work", showing that the given module
# was compiled.
V_LINT_FILES := $(patsubst %.sv, %_lint_ok.txt, $(V_SRCS))
V_LINT_FILES := $(patsubst %.v, %_lint_ok.txt, $(V_LINT_FILES))
V_LINT_FILES := $(addprefix $(V_BUILD_DIR)/linter/, $(V_LINT_FILES))

# Test dirs as a colon-separated list
V_TEST_DIRS_COLON := $(strip $(V_TEST_DIRS))
V_TEST_DIRS_COLON := $(subst $(SPACE),:,$(V_TEST_DIRS_COLON))
V_TEST_DIRS_COLON := $(if $(PYTHONPATH),$(V_TEST_DIRS_COLON):$(PYTHONPATH),$(V_TEST_DIRS_COLON))

#------------------------------------------------------------------------------
# Compilation flags
#------------------------------------------------------------------------------

# Test dirs with the format -I<dir>, for using directly into verilator
V_INC_FLAGS := $(addprefix -I,$(V_INC_DIRS))

# Arguments passes to the compiler and simulator directly
V_FLAGS += -Wall -Wpedantic -Wwarn-lint -Wwarn-style \
	--MMD --MP -sv \
	$(if $(Q),--quiet,)

# Dump a VCD file for waveform visualization
V_FLAGS += --trace --trace-fst --trace-structs

#------------------------------------------------------------------------------
# Intermediate variables
#------------------------------------------------------------------------------

# This is the name of the waveform file generated after running cocotb.
# Cocotb will always generate the file "dump.fst" in the directory from
# where it was invoked.
V_DUMP_FILE := dump.fst

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: vrun ## Runs cocotb testbenches.
vrun: vcompile $(V_WAVEFORMS)
	@true

.PHONY: vcompile ## Lints and compiles the RTL design.
vcompile: $(V_LINT_FILES)
	@true

.PHONY: vdebug ## Opens the RTL testbench waveform
vdebug: vcompile $(V_WAVEFORMS)
	$(if $(Q),$(Q)RUST_LOG=warn,) surfer "$(lastword $(^))"

.PHONY: vfmt ## Format SystemVerilog files
vfmt: pfmt
	$(Q)$(T_V_FMT) \
	--column_limit=80 --indentation_spaces=4 \
	--inplace $(V_SRCS) $(V_HEADERS)

#------------------------------------------------------------------------------
# Auxiliary targets
#------------------------------------------------------------------------------
$(V_BUILD_DIR):
	@mkdir -p $@

$(V_BUILD_DIR)/linter/%_lint_ok.txt: %.sv $(V_SRCS) $(V_HEADERS) $(MISC_DEPS) | $(V_BUILD_DIR)
	@mkdir -p $(dir $@)
	@printf "$(MSG_COMPILE_V_FILE)  $<\n"
	$(Q)$(T_V_LINT) --check_syntax --lint_fatal --parse_fatal $(V_SRCS) $(V_HEADERS)
	$(Q)top=$$(basename "$<" .sv); \
	top=$$(basename "$${top}" .v); \
	$(T_V_COMPILER) $(V_FLAGS) $(V_INC_FLAGS) \
		-Mdir "$$(dirname $@)" \
		--top "$${top}" \
		--lint-only $(V_SRCS)

	$(Q)touch "$@"

# The simulation might fail, but execution won't be stopped.
$(V_BUILD_DIR)/waves/%_dump.fst: %.py $(V_SRCS) $(V_HEADERS) $(MISC_DEPS) | $(V_BUILD_DIR)
	@mkdir -p "$$(dirname $@)"
	@printf "$(MSG_V_TB) $<\n"
	$(Q)tb=$$(basename "$<" .py); \
	top="$${tb%_tb}"; \
	$(MAKE) --no-print-directory --quiet \
		-f $(shell cocotb-config --makefiles)/Makefile.sim sim \
		SIM=verilator \
		WAVES=1 \
		COCOTB_TOPLEVEL="$${top}" \
		VERILOG_SOURCES="$(V_SRCS) $(V_HEADERS)" \
		VERILOG_INCLUDE_DIRS="$(V_INC_DIRS)" \
		EXTRA_ARGS="$(V_FLAGS) --top $${top}" \
		TOPLEVEL_LANG=verilog \
		SIM_BUILD="$(V_BUILD_DIR)/$${top}/" \
		COCOTB_TEST_MODULES="$${tb}" \
		PYTHONPATH="$(V_TEST_DIRS_COLON)" \
		COCOTB_RESULTS_FILE="$(V_BUILD_DIR)/$${top}/results.xml" || true

	@if [ -f $(V_DUMP_FILE) ]; then \
		mv "$(V_DUMP_FILE)" "$@"; \
	fi;
