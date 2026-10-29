# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains all variable definitions and targets related to
## compiling and executing tests for your code

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# Test sources. Each one corresponds to an executable test
TEST_SRCS := $(foreach dir, $(TEST_SRC_DIRS), $(wildcard $(dir)/*.c))

# Test headers are considered system includes
TEST_HEADER_FLAGS := $(addprefix -isystem , $(TEST_INC_DIRS))

# Test objects are differentiated from normal objects by ending in ".test.o"
TEST_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_OBJS := $(patsubst %.c, %.test.o, $(TEST_OBJS))

# Test framework objects are differentiated from normal object by ending
# in ".test_framework.o".
# They need to be different from the rest of test objects because they are not
# built for execution.
TEST_FRAMEWORK_SRCS := $(foreach dir, $(TEST_FRAMEWORK_SRC_DIRS), $(wildcard $(dir)/*.c))
TEST_FRAMEWORK_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_FRAMEWORK_SRCS))
TEST_FRAMEWORK_OBJS := $(patsubst %.c, %.test_framework.o, $(TEST_FRAMEWORK_OBJS))

# All tests should be compiled against the application object files, except the
# "main" one, to avoid redefinition of the "main" function
TEST_APP_OBJS := $(filter-out %main.o,$(OBJS))

# Executable tests
TEST_EXES := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_EXES := $(patsubst %.c, %.elf, $(TEST_EXES))

# Dependency files created with -MMD
TEST_DEPS := $(patsubst %.o, %.d, $(TEST_OBJS) $(TEST_FRAMEWORK_OBJS))

# Required directories inside the build folder
BUILD_TEST_DIRS := $(addprefix $(BUILD_DIR)/, $(TEST_SRC_DIRS) $(TEST_FRAMEWORK_SRC_DIRS))

#------------------------------------------------------------------------------
# Test user targets
#------------------------------------------------------------------------------
.PHONY: test ## Compile and execute tests
test: $(TEST_EXES) $(TEST_APP_OBJS)
	@for test in $(TEST_EXES); do \
		test_name=$$(basename $${test} .elf); \
		printf "$(BOLD_MAGENTA)Running test: $${test_name} $(NC)\n"; \
		./$${test}; \
		printf "\n"; \
	done

#------------------------------------------------------------------------------
# Test compilation targets
#------------------------------------------------------------------------------
# For each $(TEST_SRCS), create an executable test
$(BUILD_DIR)/%.elf: $(BUILD_DIR)/%.test.o $(TEST_FRAMEWORK_OBJS) $(TEST_APP_OBJS) | $(BUILD_TEST_DIRS) $(INFO_DIR)
	@printf "$(MSG_LINK_TEST)"
	$(Q)$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) $(LIB_FLAGS)

# Compile test and test framework object files
# The only difference with the project's object files is the inclusion of the
# $(TEST_HEADER_FLAGS)
$(BUILD_DIR)/%.test.o $(BUILD_DIR)/%.test_framework.o: %.c $(MISC_DEPS) | $(BUILD_TEST_DIRS)
	@printf "$(MSG_COMPILE_C_TEST_FILE)"
	$(Q)$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) $(HEADER_FLAGS) $(TEST_HEADER_FLAGS) -o $@ -c $<

# Create directories inside the "build" folder
$(BUILD_TEST_DIRS):
	@mkdir -p $@

# If they exist, include object targets generated with the "-MMD" flag.
-include $(TEST_DEPS)
