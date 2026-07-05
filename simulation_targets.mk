# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains the variables and targets required to run a simulation
## from the compiled $(ELF) file.

#------------------------------------------------------------------------------
# Simulation variables
#------------------------------------------------------------------------------
# Process ID of the last simulator instance that was run
SIM_PID_FILE := $(BUILD_DIR)/sim.pid

# Last simulator instance's stdout and stderr logs
SIM_OUTPUT_FILE := $(BUILD_DIR)/sim_output.txt

# Timeout until the simulator window is closed
SIM_TIMEOUT_TO_EXIT := 10

# Adds the flag to create a "pidfile", i.e., the PID of the running simulator
# will be stored so that later can be killed.
ifneq ($(findstring qemu,$(SIM)),)
EXTRA_SIMFLAGS += -pidfile $(SIM_PID_FILE)
else ifneq ($(findstring renode,$(SIM)),)
EXTRA_SIMFLAGS += --pid-file $(SIM_PID_FILE)
endif

#------------------------------------------------------------------------------
# Simulation targets
#------------------------------------------------------------------------------
.PHONY: sim ## Execute program in simulation environment
sim: $(ELF) kill_sim
	if [ -n "$(TERMINAL)" ]; then \
		printf "$(MSG_SIM_TERMINAL)"; \
		printf "$(MAGENTA)$(SIM) $(SIMFLAGS) $(EXTRA_SIMFLAGS)$(NC)\n"; \
		$(TERMINAL) -- bash -c "\
			$(SIM) $(SIMFLAGS) $(EXTRA_SIMFLAGS) |& tee $(SIM_OUTPUT_FILE); \
			printf '$(MSG_SIM_CLOSING)'; \
			read -s -t $(SIM_TIMEOUT_TO_EXIT)"; \
	else \
		printf "$(MSG_SIM_DAEMON)"; \
		printf "$(MAGENTA)$(SIM) $(SIMFLAGS) $(EXTRA_SIMFLAGS)$(NC)\n"; \
		printf "$(MSG_SIM_OUTPUT)" "$(SIM_OUTPUT_FILE)"; \
		$(SIM) $(SIMFLAGS) $(EXTRA_SIMFLAGS) &>$(SIM_OUTPUT_FILE) & \
	fi

.PHONY: kill_sim ## Kills a running simulator instance
kill_sim:
	if [ -f "$(SIM_PID_FILE)" ]; then \
		kill "$$(cat $(SIM_PID_FILE))" &>/dev/null; \
		rm -f $(SIM_PID_FILE); \
	fi

# Add the prerequisite "sim" to the debug target
ifdef SIM
debug: $(ELF) sim
endif
