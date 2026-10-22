# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains the compilation targets for a SystemVerilog project
## All verilog-related targets are prepended with a "v_"
##
## For the list of cocotb Makefile variables, see
## https://docs.cocotb.org/en/stable/building.html

#------------------------------------------------------------------------------
# File location and intermediate variables
#------------------------------------------------------------------------------
# Source files
V_SRCS := $(foreach dir, $(V_SRC_DIRS), $(wildcard $(dir)/*.v) $(wildcard $(dir)/*.sv))

# Header files
V_HEADERS := $(foreach dir, $(V_INC_DIRS), $(wildcard $(dir)/*.v) $(wildcard $(dir)/*.sv))

# Test files
V_TESTS := $(foreach dir, $(V_TEST_DIRS), $(wildcard $(dir)/*.py))

# Test modules, without the .py extension, paths and comma-separated
# A file like "./test1.py ./test2.py" gets converted to just "test1 test2".
V_TEST_MODULES := $(foreach tb, $(V_TESTS), $(basename $(notdir $(tb))))
V_TEST_MODULES := $(strip $(V_TEST_MODULES))
V_TEST_MODULES := $(subst $(SPACE),$(COMMA),$(V_TEST_MODULES))

# Test dirs as a colon-separated list
V_TEST_DIRS_COLON := $(strip $(V_TEST_DIRS))
V_TEST_DIRS_COLON := $(subst $(SPACE),:,$(V_TEST_DIRS_COLON))
V_TEST_DIRS_COLON := $(if $(PYTHONPATH),$(V_TEST_DIRS_COLON):$(PYTHONPATH),$(V_TEST_DIRS_COLON))

# Test dirs with the format -I<dir>, for using directly into verilator
V_INC_FLAGS := $(addprefix -I,$(V_TEST_DIRS))

# Arguments passes to the compiler and simulator directly
V_FLAGS += -Wall -Wpedantic -Wwarn-lint -Wwarn-style \
	-Mdir "$(BUILD_DIR)/$(V_BUILD_DIR)" --MMD --MP \
	--top "$(V_TOP)"

# Dump a VCD file for waveform visualization
V_FLAGS += --trace --trace-fst --trace-structs

# Waveform dump file
V_DUMP_FILE := dump.fst

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: v_run ## Runs cocotb on the verilog design.
v_run: $(BUILD_DIR)/$(V_DUMP_FILE)

.PHONY: v_compile ## Lints the verilog design using just verilator.
v_compile: $(MISC_DEPS) | $(BUILD_DIR)/$(V_BUILD_DIR)
	$(T_VERILATOR) $(V_FLAGS) $(V_INC_FLAGS) --lint-only $(V_SRCS)

.PHONY: v_debug ## Runs cocotb, and also opens the waveform traces.
v_debug: $(BUILD_DIR)/$(V_DUMP_FILE)
	surfer $(BUILD_DIR)/$(V_DUMP_FILE)

#------------------------------------------------------------------------------
# Auxiliary targets
#------------------------------------------------------------------------------
$(BUILD_DIR)/$(V_DUMP_FILE): $(V_SRCS) $(V_HEADERS) $(V_TESTS) $(MISC_DEPS) | $(BUILD_DIR)/$(V_BUILD_DIR)
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim sim \
		SIM=verilator \
		WAVES=1 \
		COCOTB_TOPLEVEL="$(V_TOP)" \
		VERILOG_SOURCES="$(V_SRCS)" \
		VERILOG_INCLUDE_DIRS="$(V_INC_DIRS)" \
		EXTRA_ARGS="$(V_FLAGS)" \
		TOPLEVEL_LANG=verilog \
		SIM_BUILD="$(BUILD_DIR)/$(V_BUILD_DIR)" \
		COCOTB_TEST_MODULES="$(V_TEST_MODULES)" \
		PYTHONPATH="$(V_TEST_DIRS_COLON)" \
		COCOTB_RESULTS_FILE="$(BUILD_DIR)/results.xml"
	if [ -f $(V_DUMP_FILE) ]; then mv $(V_DUMP_FILE) $(BUILD_DIR)/$(V_DUMP_FILE); fi

$(BUILD_DIR)/$(V_BUILD_DIR):
	mkdir -p $@


