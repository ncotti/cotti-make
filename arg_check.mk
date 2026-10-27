# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file ensures that all user-defined variables are correct before
## proceeding with any compilation step

#------------------------------------------------------------------------------
# Clean-up any "rubbish" from the user input
#------------------------------------------------------------------------------

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

override V_SRC_DIRS := $(foreach dir,$(V_SRC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))
override V_INC_DIRS := $(foreach dir,$(V_INC_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))
override V_TEST_DIRS := $(foreach dir,$(V_TEST_DIRS),\
    $(if $(findstring ..,$(dir)),$(realpath $(dir)),$(dir)))

# Sort files
override SRC_DIRS := $(sort $(SRC_DIRS))
override INC_DIRS := $(sort $(INC_DIRS))
override TEST_SRC_DIRS := $(sort $(TEST_SRC_DIRS))
override TEST_INC_DIRS := $(sort $(TEST_INC_DIRS))
override TEST_FRAMEWORK_SRC_DIRS := $(sort $(TEST_FRAMEWORK_SRC_DIRS))
override V_SRC_DIRS := $(sort $(V_SRC_DIRS))
override V_INC_DIRS := $(sort $(V_INC_DIRS))
override V_TEST_DIRS := $(sort $(V_TEST_DIRS))

#------------------------------------------------------------------------------
# C compilation, simulation or debugging targets
#------------------------------------------------------------------------------
ifneq ($(filter $(GOALS_C_TOOLCHAIN),$(GOALS)),)

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

endif # GOALS_C_TOOLCHAIN

#------------------------------------------------------------------------------
# Verilog compilation or simulation
#------------------------------------------------------------------------------
ifneq ($(filter $(GOALS_VERILOG),$(GOALS)),)

# V_SRC_DIRS must be defined
ifndef V_SRC_DIRS
$(error $(MSG_NO_V_SRC_DIRS))
endif

# V_TEST_DIRS must be defined
ifndef V_TEST_DIRS
$(error $(MSG_NO_V_TEST_DIRS))
endif

# All source directories must exist and be directories
NOT_DIRS := $(foreach dir, $(V_SRC_DIRS), $(shell [ ! -d $(dir) ] && echo "$(dir)"))
ifneq ($(strip $(NOT_DIRS)),)
$(error $(MSG_WRONG_V_SRC_DIRS) $(NOT_DIRS))
endif

# Source directories must not be empty
EMPTY_DIRS := $(foreach dir,$(V_SRC_DIRS), \
  $(shell find "$(dir)" -maxdepth 1 \
    \( -name "*.v" -o -name "*.sv" \) \
    -print -quit | grep -q . || echo "$(dir)"))
ifneq ($(strip $(EMPTY_DIRS)),)
$(error $(MSG_EMPTY_V_SRC_DIR) $(EMPTY_DIRS))
endif

# All include directories must exist and be directories
NOT_DIRS := $(foreach dir, $(V_INC_DIRS), $(shell [ ! -d $(dir) ] && echo "$(dir)"))
ifneq ($(strip $(NOT_DIRS)),)
$(error $(MSG_WRONG_V_INC_DIRS) $(NOT_DIRS))
endif

# Include directories must not be empty
EMPTY_DIRS := $(foreach dir,$(V_INC_DIRS), \
  $(shell find "$(dir)" -maxdepth 1 \
    \( -name "*.svh" \) \
      -print -quit | grep -q . || echo "$(dir)"))
ifneq ($(strip $(EMPTY_DIRS)),)
$(error $(MSG_EMPTY_V_INC_DIR) $(EMPTY_DIRS))
endif

# All test directories must exist and be directories
NOT_DIRS := $(foreach dir, $(V_TEST_DIRS), $(shell [ ! -d $(dir) ] && echo "$(dir)"))
ifneq ($(strip $(NOT_DIRS)),)
$(error $(MSG_WRONG_V_TEST_DIRS) $(NOT_DIRS))
endif

# Test directories must not be empty
EMPTY_DIRS := $(foreach dir,$(V_TEST_DIRS), \
  $(shell find "$(dir)" -maxdepth 1 \
    \( -name "*.py" \) \
      -print -quit | grep -q . || echo "$(dir)"))
ifneq ($(strip $(EMPTY_DIRS)),)
$(error $(MSG_EMPTY_V_TEST_DIR) $(EMPTY_DIRS))
endif

endif # GOALS_VERILOG
