# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains all messages to be printed on the screen

#------------------------------------------------------------------------------
# Error messages from Makefile
#------------------------------------------------------------------------------
define MSG_NO_SRC_DIRS
$(M_RED)[ERROR #001]$(M_NC)
Variable "SRC_DIRS" must be defined.
SRC_DIRS should contain the path to the sources' location
endef

define MSG_WRONG_SRC_DIRS
$(M_RED)[ERROR #002]$(M_NC)
Variable "SRC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_WRONG_INC_DIRS
$(M_RED)[ERROR #003]$(M_NC)
Variable "INC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_EMPTY_SRC_DIR
$(M_RED)[ERROR #004]$(M_NC)
Variable "SRC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_EMPTY_INC_DIR
$(M_RED)[ERROR #005]$(M_NC)
Variable "INC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_REPEATED_SRC_DIRS
$(M_RED)[ERROR #006]$(M_NC)
Variable "SRC_DIRS" should not have repeated directories.
Repeated directories:
endef

define MSG_REPEATED_INC_DIRS
$(M_RED)[ERROR #007]$(M_NC)
Variable "INC_DIRS" should not have repeated directories.
Repeated directories:
endef

define MSG_INVALID_TOOLCHAIN
$(M_RED)[ERROR #008]$(M_NC)
Either CROSS_COMPILE toolchain or CC do not exist.
Specified toolchain was:
endef

define MSG_INVALID_SIM
$(M_RED)[ERROR #009]$(M_NC)
SIM simulator does not exist, or is an invalid one.
Supported simulators are qemu[*] or renode.
Specified simulator was:
endef

define MSG_INVALID_TERMINAL
$(M_RED)[ERROR #010]$(M_NC)
TERMINAL, program for launching new terminal windows, does not exist.
Specified terminal emulator was:
endef

define MSG_DEBUG_NO_G_FLAG
$(RED)[ERROR #011]$(NC)\nTrying to debug executable file, but missing \"-g\" flag in CFLAGS.\n
endef

#------------------------------------------------------------------------------
# Info messages
#------------------------------------------------------------------------------
define MSG_CLEAN_OK
$(BOLD_GREEN)All files successfully erased$(NC) $(CHECKMARK)\n
endef

define MSG_COMPILE_OK
$(BOLD_GREEN)Executable file successfully compiled$(NC) $(CHECKMARK)\n
endef

define MSG_STATIC_LIB_OK
$(BOLD_GREEN)Static library successfully compiled$(NC) $(CHECKMARK)\n
endef

define MSG_DYNAMIC_LIB_OK
$(BOLD_GREEN)Dynamic library successfully compiled$(NC) $(CHECKMARK)\n
endef

define MSG_RUN
$(BOLD_MAGENTA)Executing:$(NC)\n
endef

define MSG_DEBUG
$(BOLD_MAGENTA)Debugging:$(NC)\n
endef

define MSG_SIM_TERMINAL
$(BOLD_MAGENTA)Running simulation in a new terminal:$(NC)\n
endef

define MSG_SIM_DAEMON
$(BOLD_MAGENTA)Running simulation as a daemon in the background:$(NC)\n
endef

define MSG_SIM_OUTPUT
$(BOLD_MAGENTA)Simulator output written to: %s$(NC)\n
endef

define MSG_SIM_CLOSING
$(BOLD_MAGENTA)Closing automatically in $(SIM_TIMEOUT_TO_EXIT) seconds.\nOutput will be sent to $(SIM_OUTPUT_FILE)$(NC)\n
endef

define MSG_TIDY
$(BOLD_MAGENTA)Running static analyzer:$(NC)\n
endef

define MSG_TIDY_DONE
endef

define MSG_FORMAT
$(BOLD_MAGENTA)Running formatter:$(NC)\n
endef

#------------------------------------------------------------------------------
# Compilation step messages
#------------------------------------------------------------------------------
# Note: all these messages must have a consistent spacing between the closing
# bracket "]" and the "$(NC)" variable
define MSG_COMPILE_C_FILE
$(MAGENTA)[CC]     $(NC) $<\n
endef

define MSG_COMPILE_ASM_FILE
$(MAGENTA)[AS]     $(NC) $<\n
endef

define MSG_LINK
$(MAGENTA)[LD]     $(NC) $@\n
endef

define MSG_BIN
$(MAGENTA)[BIN]    $(NC) $@\n
endef

define MSG_AR
$(MAGENTA)[AR]     $(NC) $@\n
endef

define MSG_HEADER_FILE
$(MAGENTA)[HEAD]   $(NC) $@\n
endef

define MSG_DASM_FILE
$(MAGENTA)[DASM]   $(NC) $@\n
endef

define MSG_COMPILE_C_TEST_FILE
$(MAGENTA)[TEST_CC]$(NC) $@\n
endef

define MSG_LINK_TEST
$(MAGENTA)[TEST_LD]$(NC) $@\n
endef
