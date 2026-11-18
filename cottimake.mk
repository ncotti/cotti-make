# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## CottiMake is a general purpose Makefile for C and ASM projects
## This is the main Makefile file, the one which should be included from
## your project's Makefile.

#------------------------------------------------------------------------------
# Makefile Initialization
#------------------------------------------------------------------------------
SHELL=/bin/bash
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help

# Path to this Makefile, relative to the location from where it was called.
# E.g. If your project looks like the following, and you execute "make" from
# the "." directory, then MAKE_ROOT will be equal to "cottimake":
# .
# ├── Makefile ( Your own project Makefile, which contains the statement
# │				 "include cottimake/Makefile")
# └── cottimake
#	  └── cottimake.mk (this file)
MAKE_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

# Name of the "main" Makefile, i.e., the one that was called from the terminal
MAKE_ORIGIN := $(firstword $(MAKEFILE_LIST))

include $(MAKE_ROOT)/colors.mk
include $(MAKE_ROOT)/constants.mk
include $(MAKE_ROOT)/messages.mk
include $(MAKE_ROOT)/goals.mk

#------------------------------------------------------------------------------
# Used-defined variables: default values
#------------------------------------------------------------------------------
# Default values for user variables
include $(MAKE_ROOT)/defaults.mk

# Verbosity variable
ifeq ($(VERBOSE),1)
    Q :=
else
    Q := @
endif

# The following are the result of combining the chosen tools and toolchain
T_CC		:= $(CROSS_COMPILE)$(CC)
T_AS		:= $(CROSS_COMPILE)$(AS)
T_LD		:= $(CROSS_COMPILE)$(LD)
T_OBJDUMP	:= $(CROSS_COMPILE)$(OBJDUMP)
T_OBJCOPY 	:= $(CROSS_COMPILE)$(OBJCOPY)
T_AR		:= $(CROSS_COMPILE)$(AR)
T_GDB		:= $(CROSS_COMPILE)$(GDB)

T_V_COMPILER := verilator
T_WAVEFORM	:= surfer
T_COCOTB	:= cocotb-config
T_V_FMT		:= verible-verilog-format
T_V_LINT	:= verible-verilog-lint

# GDB flags that are always included, on top of the ones provided by the user
EXTRA_GDBFLAGS += -q
ifneq (,$(GDBSCRIPT))
EXTRA_GDBFLAGS += -x $(GDBSCRIPT)
endif

# C compiler flags that are always included, on top of the ones provided by the user
# Add dependency generation flags for compiler
EXTRA_CFLAGS += -MMD -MP

# Linker flags that are always included, on top of the ones provided by the user
# Utilize linker script provided by the user
ifneq (,$(LDSCRIPT))
EXTRA_LDFLAGS += -T $(LDSCRIPT)
endif

# If you are using the C compiler for assembly files, use all the extra
# cflags for assembling
ifeq ($(T_CC),$(T_AS))
EXTRA_ASFLAGS += $(EXTRA_CFLAGS)
endif

# Check that all tools are installed correctly
include $(MAKE_ROOT)/install_check.mk

# Check if all variables are ok
include $(MAKE_ROOT)/arg_check.mk

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------
# Generated .elf and .bin files
ELF 		:= $(BUILD_DIR)/$(EXE).elf
BIN 		:= $(BUILD_DIR)/$(EXE).bin
HEX			:= $(BUILD_DIR)/$(EXE).hex

# Source files
C_SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
ASM_SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
SRCS := $(sort $(C_SRCS) $(ASM_SRCS))

# Header files and flags for compilation
HEADER_FLAGS := $(addprefix -I,$(INC_DIRS))
LIB_FLAGS := $(addprefix -L,$(LIB_DIRS))
LIB_FLAGS += $(addprefix -l,$(LDLIBS))

C_HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.h))
ASM_HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
HEADERS := $(sort $(C_HEADERS) $(ASM_HEADERS))

# Object files. Assembly files have the "_asm" suffix added to account for the
# possibility of a ".c" and ".S" file with the same name.
OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %_asm.o, $(OBJS))
OBJS := $(patsubst %.S, %_asm.o, $(OBJS))
OBJS := $(sort $(OBJS))

# Dependency files generated with the "-MMD" flag
DEPS := $(patsubst %.o, %.d, $(OBJS))

# Directories for all the compilation artifacts
BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))

# Miscellaneous dependencies that should trigger source file recompilation
MISC_DEPS := $(LDSCRIPT) $(MAKE_ORIGIN)

# Transform white-space separated library directories into colon separated
# ones to be prepended to the LD_LIBRARY_PATH variable, so that when linking
# the libraries can be found
LIB_DIRS_COLON := $(strip $(LIB_DIRS))
LIB_DIRS_COLON := $(subst $(SPACE),:,$(LIB_DIRS_COLON))
override LD_LIBRARY_PATH := $(if $(LD_LIBRARY_PATH),$(LIB_DIRS_COLON):$(LD_LIBRARY_PATH),$(LIB_DIRS_COLON))

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: help ## Display this message.
help:
	@grep -E '^\.PHONY:.*## .*$$' $(MAKE_ROOT)/*.mk $(MAKE_ORIGIN) \
	| awk 'BEGIN {FS=":|## "}; \
	       {gsub(/^[ \t]+|[ \t]+$$/, "", $$3); \
	        printf "$(BOLD_CYAN)%-12s$(NC) %s\n", $$3, $$4}' \
	| sort

.PHONY: compile ## Compile source files and generate executable
compile: $(ELF)
	@true

.PHONY: bin ## Generate binary file, without ELF headers.
bin: $(BIN)
	@true

.PHONY: hex ## Create a text-based hexadecimal memory file, with 32-bit instructions per line.
hex: $(HEX)
	@true

.PHONY: clean ## Erase contents of build directory.
clean:
	@if [ -d "$(BUILD_DIR)" ]; then \
		rm -Rf $(BUILD_DIR) && \
		printf "$(MSG_CLEAN_OK)"; \
	fi

.PHONY: run ## Execute program
run: $(ELF)
	@printf "$(MSG_RUN)"
	@if [ -n "$(LD_LIBRARY_PATH)" ]; then \
		printf "$(MAGENTA)LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) \\ $(NC) \n"; \
	fi
	@printf "$(MAGENTA)$(ELF) $(EXEFLAGS)$(NC)\n"
	$(Q)LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(ELF) $(EXEFLAGS)

.PHONY: debug ## Debug executable file
debug: $(ELF)
	@if [ -z $(filter -g,$(CFLAGS)) ]; then \
		printf "$(MSG_DEBUG_NO_G_FLAG)"; \
		exit 11; \
	fi
	@printf "$(MSG_DEBUG)"
	@printf "$(MAGENTA)$(T_GDB) $(GDBFLAGS) $(EXTRA_GDBFLAGS) $(ELF)$(NC)\n"
	$(Q)$(T_GDB) $(GDBFLAGS) $(EXTRA_GDBFLAGS) $(ELF)
	@$(MAKE) --no-print-directory kill_sim

include $(MAKE_ROOT)/info_targets.mk

include $(MAKE_ROOT)/test_targets.mk

include $(MAKE_ROOT)/simulation_targets.mk

include $(MAKE_ROOT)/lib_targets.mk

include $(MAKE_ROOT)/tidy_targets.mk

# Must be included before verilog.mk, because it defines PYTHON_SRCS
include $(MAKE_ROOT)/python_targets.mk

include $(MAKE_ROOT)/verilog.mk

# Keep the print target for last
include $(MAKE_ROOT)/print_targets.mk

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Main executable linking
$(ELF): $(OBJS) | $(INFO_DIR)
	@printf "$(MSG_LINK)"
	$(Q)$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) $(LIB_FLAGS)
	@printf "$(MSG_COMPILE_OK)"

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	@printf "$(MSG_COMPILE_C_FILE)"
	$(Q)$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".s"
$(BUILD_DIR)/%_asm.o: %.s $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	@printf "$(MSG_COMPILE_ASM_FILE)"
	$(Q)$(T_AS) $(ASFLAGS) $(EXTRA_ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".S"
$(BUILD_DIR)/%_asm.o: %.S $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	@printf "$(MSG_COMPILE_ASM_FILE)"
	$(Q)$(T_AS) $(ASFLAGS) $(EXTRA_ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Copy ELF file into BIN file
$(BIN): $(ELF)
	@printf "$(MSG_BIN)"
	$(Q)$(T_OBJCOPY) -O binary $(ELF) $(BIN)

# Copy ELF file into HEX file
$(HEX): $(BIN)
	@printf "$(MSG_HEX)"
	$(Q)od -An -v -tx4 -w4 $(BIN) | tr -d ' ' | tr '[:lower:]' '[:upper:]' > $(HEX)

# Folders
$(BUILD_SRC_DIRS) $(BUILD_DIR):
	@mkdir -p $@

# Empty rule for miscellaneous dependencies
$(MISC_DEPS):

-include $(DEPS)
