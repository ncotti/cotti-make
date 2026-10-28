# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains the formatter and static analyzer targets

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# compile_commands.json required by clang tools
COMPILE_COMMANDS := $(BUILD_DIR)/compile_commands.json

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: tidy ## Do static analysis with clang-tidy
tidy: $(COMPILE_COMMANDS)
	printf "$(MSG_TIDY)"
	clang-tidy --verify-config --quiet 1>/dev/null
	clang-tidy -p $(BUILD_DIR) \
		--config-file=$(CLANG_TIDY_CONFIG_FILE) \
		--quiet \
		$(C_SRCS) $(TEST_SRCS)

.PHONY: fmt ## Code formatter with clang-format
fmt: $(COMPILE_COMMANDS)
	printf "$(MSG_FORMAT)"
	clang-format \
		--style="file:$(CLANG_FORMAT_CONFIG_FILE)" \
		-i \
		--verbose \
		$(C_SRCS) $(C_HEADERS) $(TEST_SRCS)

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Since the compile_commands.json should only be re-created when a new
# header or source file appears, not when they change; it does not have
# $(SRCS) or $(HEADERS) as prerequisites.
# It will only be re-created after a make clean
$(COMPILE_COMMANDS): | $(BUILD_DIR)
	bear --output $(COMPILE_COMMANDS) -- \
		$(MAKE) -B --no-print-directory $(OBJS) $(TEST_OBJS) $(TEST_FRAMEWORK_OBJS)
