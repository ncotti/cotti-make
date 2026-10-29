# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains linting and formatting scripts for Python files.
## All python targets start with a "p".

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------

# Python source files
PYTHON_SRCS := $(foreach dir, $(PYTHON_SRC_DIRS) $(V_TEST_DIRS),$(wildcard $(dir)/*.py))

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: plint ## Lint Python files
plint: $(PYTHON_SRCS)
	$(Q)ruff -q --config "$(PYTHON_FORMAT_CONFIG_FILE)" check $^

.PHONY: pfmt ## Format Python files
pfmt: $(PYTHON_SRCS)
	$(Q)ruff -q --config "$(PYTHON_FORMAT_CONFIG_FILE)" format $^
