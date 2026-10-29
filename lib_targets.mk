# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains all targets related to compiling static and dynamic
## libraries

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# Name of the static library
LIBA		:= $(BUILD_DIR)/lib$(EXE).a

# Name of the dynamic library
LIBSO		:= $(BUILD_DIR)/lib$(EXE).so

# Since dynamic libraries require object files to be compiled with the "-fPIC"
# flag, create a "copy" of all object flags with that flag enforced
OBJS_PIC := $(patsubst %.o, %.pic.o, $(OBJS))

#------------------------------------------------------------------------------
# Library targets
#------------------------------------------------------------------------------
.PHONY: compile_static_lib ## Compile sources as a static library
compile_static_lib: $(LIBA)

.PHONY: compile_dynamic_lib ## Compile sources as a dynamic library
compile_dynamic_lib: $(LIBSO)

#------------------------------------------------------------------------------
# Library compilation targets
#------------------------------------------------------------------------------
# Static library linking
$(LIBA): $(OBJS)
	@printf "$(MSG_AR)"
	$(Q)$(T_AR) rcs $@ $^
	@printf "$(MSG_STATIC_LIB_OK)"

# Dynamic library linking
$(LIBSO): $(OBJS_PIC) | $(INFO_DIR)
	@printf "$(MSG_LINK)"
	$(Q)$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) -shared
	@printf "$(MSG_DYNAMIC_LIB_OK)"

# Compiling object files from C sources with PIC (position independent code)
$(BUILD_DIR)/%.pic.o: %.c $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	@printf "$(MSG_COMPILE_C_FILE)"
	$(Q)$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) -fPIC $(HEADER_FLAGS) -o $@ -c $<
