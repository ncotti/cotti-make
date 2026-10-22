# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains the "make print[_XXX]" targets

#------------------------------------------------------------------------------
# Print targets
#------------------------------------------------------------------------------
.PHONY: print_src ## Print source files
print_src:
	printf "$(BOLD_MAGENTA)Source files:$(NC)\n"
	for src in $(SRCS); do \
		printf "$${src}\n"; \
	done
	printf "\n"

.PHONY: print_obj ## Print object files
print_obj:
	printf "$(BOLD_MAGENTA)Object files:$(NC)\n"
	for obj in $(OBJS); do \
		printf "$${obj}\n"; \
	done
	printf "$(ELF)\n"; \
	printf "\n"

.PHONY: print_header ## Print header files
print_header:
	printf "$(BOLD_MAGENTA)Header files:$(NC)\n"
	for header in $(HEADERS); do \
		printf "$${header}\n"; \
	done
	printf "\n"

.PHONY: print ## Print all C files: sources, objects and headers
print: print_src print_obj print_header

.PHONY: v_print_src ## Print Verilog design files
v_print_src:
	printf "$(BOLD_MAGENTA)Verilog Source files:$(NC)\n"
	for src in $(V_SRCS); do \
		printf "$${src}\n"; \
	done
	printf "\n"

.PHONY: v_print_tb ## Print cocotb testbenches
v_print_tb:
	printf "$(BOLD_MAGENTA)Cocotb testbenches:$(NC)\n"
	for tb in $(V_TESTS); do \
		printf "$${tb}\n"; \
	done
	printf "\n"

.PHONY: v_print_header ## Print Verilog header files
v_print_header:
	printf "$(BOLD_MAGENTA)Verilog header files:$(NC)\n"
	for header in $(V_HEADERS); do \
		printf "$${header}\n"; \
	done
	printf "\n"

.PHONY: v_print ## Print all Verilog files: sources, testbenches and headers
v_print: v_print_src v_print_tb v_print_header
