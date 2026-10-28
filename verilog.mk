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
V_HEADERS := $(foreach dir, $(V_INC_DIRS), $(wildcard $(dir)/*.svh))

# Test files
V_TESTS := $(foreach dir, $(V_TEST_DIRS), $(wildcard $(dir)/*.py))

# Test modules, without the .py extension, paths and comma-separated
# A file like "./test1.py ./test2.py" gets converted to just "test1,test2".
V_TEST_MODULES := $(foreach tb, $(V_TESTS), $(basename $(notdir $(tb))))
V_TEST_MODULES := $(strip $(V_TEST_MODULES))

# Only keep the test modules that matches the top value
#V_TEST_MODULES := $(foreach tb,$(V_TEST_MODULES),$(if $(findstring $(V_TOP),$(tb)),$(tb)))
#V_TEST_MODULES := $(subst $(SPACE),$(COMMA),$(V_TEST_MODULES))

# Test dirs as a colon-separated list
V_TEST_DIRS_COLON := $(strip $(V_TEST_DIRS))
V_TEST_DIRS_COLON := $(subst $(SPACE),:,$(V_TEST_DIRS_COLON))
V_TEST_DIRS_COLON := $(if $(PYTHONPATH),$(V_TEST_DIRS_COLON):$(PYTHONPATH),$(V_TEST_DIRS_COLON))

# Test dirs with the format -I<dir>, for using directly into verilator
V_INC_FLAGS := $(addprefix -I,$(V_INC_DIRS))


## VERILATOR
# Arguments passes to the compiler and simulator directly
V_FLAGS += -Wall -Wpedantic -Wwarn-lint -Wwarn-style \
	--MMD --MP \
	-sv

# Dump a VCD file for waveform visualization
V_FLAGS += --trace --trace-fst --trace-structs


## IVERILOG
#V_FLAGS := -s "$(V_TOP)" -o "$(BUILD_DIR)/$(V_BUILD_DIR)/a.out" -g2012 -Wall

# Waveform dump file
V_DUMP_FILE := dump.fst

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: vrun ## Runs cocotb testbenches.
vrun: $(V_SRCS) $(V_HEADERS) $(V_TESTS) $(MISC_DEPS) | $(BUILD_DIR)/$(V_BUILD_DIR)
	# This command is allowed to fail, and the waveform file might be
	# generated regardless

	for tb in $(V_TEST_MODULES); do \
		top="$${tb%_tb}"; \
		mkdir -p "$(BUILD_DIR)/$(V_BUILD_DIR)/$${top}"; \
		printf "$(BOLD_MAGENTA)[TB] $(NC) $${tb}\n"; \
		$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim sim \
			SIM=verilator \
			WAVES=1 \
			COCOTB_TOPLEVEL="$${top}" \
			VERILOG_SOURCES="$(V_SRCS) $(V_HEADERS)" \
			VERILOG_INCLUDE_DIRS="$(V_INC_DIRS)" \
			EXTRA_ARGS="$(V_FLAGS) --top $${top}" \
			TOPLEVEL_LANG=verilog \
			SIM_BUILD="$(BUILD_DIR)/$(V_BUILD_DIR)/$${top}/" \
			COCOTB_TEST_MODULES="$${tb}" \
			PYTHONPATH="$(V_TEST_DIRS_COLON)" \
			COCOTB_RESULTS_FILE="$(BUILD_DIR)/$(V_BUILD_DIR)/$${top}/results.xml" || true; \
		if [ -f $(V_DUMP_FILE) ]; then mv $(V_DUMP_FILE) $(BUILD_DIR)/$(V_BUILD_DIR)/$${top}/$(V_DUMP_FILE); fi; \
	done

.PHONY: vcompile ## Lints and compiles the verilog design.
vcompile: $(V_SRCS) $(V_HEADERS) $(MISC_DEPS) | $(BUILD_DIR)/$(V_BUILD_DIR)
	$(T_V_LINT) --check_syntax --lint_fatal --parse_fatal $(V_SRCS)
	$(T_V_COMPILER) $(V_FLAGS) $(V_INC_FLAGS) \
		-Mdir "$(BUILD_DIR)/$(V_BUILD_DIR)/$(V_TOP)" \
		--top $(V_TOP) \
		--lint-only $(V_SRCS)

.PHONY: vdebug ## Runs cocotb, and also opens the waveform traces.
vdebug:
	if [ -f $(BUILD_DIR)/$(V_BUILD_DIR)/$(V_TOP)/$(V_DUMP_FILE) ]; then \
		surfer $(BUILD_DIR)/$(V_BUILD_DIR)/$(V_TOP)/$(V_DUMP_FILE); \
	else \
		printf "$(BOLD_RED)Could not find traces for $(V_TOP).$(NC)\n"; \
	fi

.PHONY: vfmt ## Format SystemVerilog files
vfmt:
	$(T_V_FMT) \
	--column_limit=80 --indentation_spaces=4 \
	--inplace $(V_SRCS)

#------------------------------------------------------------------------------
# Auxiliary targets
#------------------------------------------------------------------------------
$(BUILD_DIR)/$(V_BUILD_DIR):
	mkdir -p $@
