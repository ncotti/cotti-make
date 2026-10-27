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

.PHONY: vprint_src ## Print Verilog design files
vprint_src:
	printf "$(BOLD_MAGENTA)Verilog Source files:$(NC)\n"
	for src in $(V_SRCS); do \
		printf "$${src}\n"; \
	done
	printf "\n"

.PHONY: vprint_tb ## Print cocotb testbenches
vprint_tb:
	printf "$(BOLD_MAGENTA)Cocotb testbenches:$(NC)\n"
	for tb in $(V_TESTS); do \
		printf "$${tb}\n"; \
	done
	printf "\n"

.PHONY: vprint_header ## Print Verilog header files
vprint_header:
	printf "$(BOLD_MAGENTA)Verilog header files:$(NC)\n"
	for header in $(V_HEADERS); do \
		printf "$${header}\n"; \
	done
	printf "\n"

.PHONY: vprint ## Print all Verilog files: sources, testbenches and headers
vprint: vprint_src vprint_tb vprint_header
