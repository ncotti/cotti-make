# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file ensures that all user-defined variables are correct before
## proceeding with any compilation step

#------------------------------------------------------------------------------
# Clean-up any "rubbish" from the user input
#------------------------------------------------------------------------------
# The goal that was used when calling this Makefile, as "make <goal>"
GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),$(.DEFAULT_GOAL))

# Checks will be done on the raw sum of source and include files
ALL_SRC_DIRS := $(SRC_DIRS) $(TEST_SRC_DIRS) $(TEST_FRAMEWORK_SRC_DIRS)
ALL_INC_DIRS := $(INC_DIRS) $(TEST_INC_DIRS)

# If any of the paths contains a double "..", convert them to absolute paths
# "override" is used to enforce this change, even if these variables where
# passed from the command-line.
override SRC_DIRS := $(foreach dir,$(SRC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))
override INC_DIRS := $(foreach dir,$(INC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))

override TEST_SRC_DIRS := $(foreach dir,$(TEST_SRC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))
override TEST_INC_DIRS := $(foreach dir,$(TEST_INC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))

override TEST_FRAMEWORK_SRC_DIRS := $(foreach dir,$(TEST_FRAMEWORK_SRC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))

# Sort files
override SRC_DIRS := $(sort $(SRC_DIRS))
override INC_DIRS := $(sort $(INC_DIRS))
override TEST_SRC_DIRS := $(sort $(TEST_SRC_DIRS))
override TEST_INC_DIRS := $(sort $(TEST_INC_DIRS))
override TEST_FRAMEWORK_SRC_DIRS := $(sort $(TEST_FRAMEWORK_SRC_DIRS))

#------------------------------------------------------------------------------
# SRC_DIRS and INC_DIRS checking
#------------------------------------------------------------------------------
# Only execute these checks for compilation targets
ifeq ($(filter help clean,$(GOALS)),)

# SRC_DIRS must be defined
ifndef SRC_DIRS
$(error $(MSG_NO_SRC_DIRS))
endif

# There should not be duplicates in SRC_DIRS
DUPLICATES := $(shell printf "%s\n" $(strip $(ALL_SRC_DIRS)) | tr ' ' '\n' | sort | uniq -d)
ifneq ($(strip $(DUPLICATES)),)
$(error $(MSG_REPEATED_SRC_DIRS) $(DUPLICATES))
endif

# There should not be duplicates in INC_DIRS
DUPLICATES := $(shell printf "%s\n" $(strip $(ALL_INC_DIRS)) | tr ' ' '\n' | sort | uniq -d)
ifneq ($(strip $(DUPLICATES)),)
$(error $(MSG_REPEATED_INC_DIRS) $(DUPLICATES))
endif

# All source directories must exist and be directories
NOT_DIRS := $(foreach dir, $(ALL_SRC_DIRS), $(shell [ ! -d $(dir) ] && echo "$(dir)"))
ifneq ($(strip $(NOT_DIRS)),)
$(error $(MSG_WRONG_SRC_DIRS) $(NOT_DIRS))
endif

# Source directories must not be empty
EMPTY_DIRS := $(foreach dir,$(ALL_SRC_DIRS), \
  $(shell find "$(dir)" -maxdepth 1 \
    \( -name "*.c" -o -name "*.s" -o -name "*.S" \) \
    -print -quit | grep -q . || echo "$(dir)"))
ifneq ($(strip $(EMPTY_DIRS)),)
$(error $(MSG_EMPTY_SRC_DIR) $(EMPTY_DIRS))
endif

# All include directories must exist and be directories
NOT_DIRS := $(foreach dir, $(ALL_INC_DIRS), $(shell [ ! -d $(dir) ] && echo "$(dir)"))
ifneq ($(strip $(NOT_DIRS)),)
$(error $(MSG_WRONG_INC_DIRS) $(NOT_DIRS))
endif

# Include directories must not be empty
EMPTY_DIRS := $(foreach dir,$(ALL_INC_DIRS), \
  $(shell find "$(dir)" -maxdepth 1 \
    \( -name "*.h" -o -name "*.s" -o -name "*.S" \) \
      -print -quit | grep -q . || echo "$(dir)"))
ifneq ($(strip $(EMPTY_DIRS)),)
$(error $(MSG_EMPTY_INC_DIR) $(EMPTY_DIRS))
endif

#------------------------------------------------------------------------------
# Toolchain verification
#------------------------------------------------------------------------------
ifeq ($(shell command -v $(T_CC) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_CC))
endif

ifeq ($(shell command -v $(T_AS) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_AS))
endif

ifeq ($(shell command -v $(T_LD) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_LD))
endif

ifeq ($(shell command -v $(T_OBJDUMP) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_OBJDUMP))
endif

ifeq ($(shell command -v $(T_OBJCOPY) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_OBJCOPY))
endif

ifeq ($(shell command -v $(T_AR) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_AR))
endif

# For GDB, the user might have defined "gdb-multiarch", therefore it could
# not exists inside the toolchain and that would be fine
ifeq ($(shell command -v $(T_GDB) 2>/dev/null),)
T_GDB := $(GDB)
ifeq ($(shell command -v $(T_GDB) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_GDB))
endif
endif

ifdef SIM

# First, check that the simulator is installed
ifeq ($(shell command -v $(SIM) 2>/dev/null),)
$(error $(MSG_INVALID_SIM) $(SIM))
endif

# Then, check if it is either qemu or renode, won't support any other simulator
ifeq ($(findstring qemu,$(SIM)),)
ifeq ($(findstring renode,$(SIM)),)
$(error $(MSG_INVALID_SIM) $(SIM))
endif
endif

endif # SIM

ifneq ($(TERMINAL),)
ifeq ($(shell command -v $(TERMINAL) 2>/dev/null),)
$(error $(MSG_INVALID_TERMINAL) $(TERMINAL))
endif
endif

endif # Compilation targets
