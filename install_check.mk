# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file ensures that all the required tools have been installed
## before trying to execute a command

#------------------------------------------------------------------------------
# C toolchain
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_C_TOOLCHAIN),$(GOALS)),)

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

endif # GOALS_C_TOOLCHAIN

#------------------------------------------------------------------------------
# Debug toolchain
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_C_DBG),$(GOALS)),)

# For GDB, the user might have defined "gdb-multiarch", therefore it could
# not exists inside the toolchain and that would be fine
ifeq ($(shell command -v $(T_GDB) 2>/dev/null),)
T_GDB := $(GDB)
ifeq ($(shell command -v $(T_GDB) 2>/dev/null),)
$(error $(MSG_INVALID_TOOLCHAIN) $(T_GDB))
endif
endif

ifdef SIM

# Check if the simulator is either qemu or renode, won't support any other.
ifeq ($(findstring qemu,$(SIM)),)
ifeq ($(findstring renode,$(SIM)),)
$(error $(MSG_INVALID_SIM) $(SIM))
endif
endif

# Check whether the simulator is installed
ifeq ($(shell command -v $(SIM) 2>/dev/null),)
$(error $(MSG_INVALID_SIM) $(SIM))
endif

ifneq ($(TERMINAL),)
ifeq ($(shell command -v $(TERMINAL) 2>/dev/null),)
$(error $(MSG_INVALID_TERMINAL) $(TERMINAL))
endif
endif

endif # SIM

endif # GOALS_C_DBG

#------------------------------------------------------------------------------
# C lint and format toolchain
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_C_LINT),$(GOALS)),)

ifeq ($(shell command -v bear 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) bear)
endif

ifeq ($(shell command -v clang-tidy 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) clang-tidy)
endif

ifeq ($(shell command -v clang-format 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) clang-format)
endif

endif # GOALS_C_LINT

#------------------------------------------------------------------------------
# Verilog toolchain
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_VERILOG),$(GOALS)),)

ifeq ($(shell command -v $(T_V_COMPILER) 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) $(T_V_COMPILER))
endif

ifeq ($(shell command -v $(T_V_LINT) 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) $(T_V_LINT))
endif

endif # GOALS_VERILOG

#------------------------------------------------------------------------------
# Verilog simulatiom
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_VERILOG_TB),$(GOALS)),)

ifeq ($(shell command -v $(T_COCOTB) 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) $(T_COCOTB))
endif

endif # GOALS_VERILOG_TB

#------------------------------------------------------------------------------
# Verilog formatter
#------------------------------------------------------------------------------

ifneq ($(filter $(GOALS_VERILOG_FMT),$(GOALS)),)

ifeq ($(shell command -v $(T_V_FMT) 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) $(T_V_FMT))
endif

ifeq ($(shell command -v ruff 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) ruff)
endif

endif # GOALS_VERILOG_FMT

#------------------------------------------------------------------------------
# Waveform toolchain
#------------------------------------------------------------------------------

# Only check for surfer if the user wants to see the waveforms
ifneq ($(filter $(GOALS_WAVEFORM),$(GOALS)),)

ifeq ($(shell command -v $(T_WAVEFORM) 2>/dev/null),)
$(error $(MSG_MISSING_DEPENDENCY) $(T_WAVEFORM))
endif

endif # GOALS_WAVEFORM
