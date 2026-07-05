# cottiMake

A simple to setup, reusable and extendable build system for your C and assembly projects, written entirely with [GNU Make][make].

## Features

* Compile, execute, debug and test your code without having to write Make recipes.
* Cross-compilation support.
* Generation of a `compile_commands.json` file, usable with [clangd][clangd] LSP.
* Formatter and static analysis included with [clang-tidy][clang-tidy] and [clang-format][clang-format].
* Catches common configuration errors even before attempting to compile or execute the code.
* Smart re-compilation: knows exactly what files have been modified, and will only recompile what it is absolutely necessary.

## Quick Setup

Include this repository as a submodule, or copy all files in its root inside a folder in your project.

Then, create your own `Makefile`, define the variables `SRC_DIRS` and `INC_DIRS`, containing the paths to the source and header directories respectively, and finally include the file `cottimake.mk`, as shown below:

```make
SRC_DIRS := src
INC_DIRS := inc

include cottimake/cottimake.mk
```

And that's all! With that, you can call `make` and easily compile, run your code, and much more!

> [!TIP]
> The build system is controlled solely by variable definitions processed by `cottimake.mk`, which does the heavy-lifting so you can focus on what really matters: the code.

If you want to see a demo, go to [examples/c_project][c_project] and try the different `make` commands.

See the following sections for how to customize the build system to your liking.

## Compilation commands

You can select the tools and the cross-compilation toolchain with the following variables:

```make
CROSS_COMPILE ?=
CC  ?= gcc
AS  ?= $(CC)
LD  ?= $(CC)
```

Then, you can set the value for the flags for compiling and linking[^1] with:

```make
CFLAGS   ?= -Wall -g -Wpedantic
ASFLAGS  ?= $(CFLAGS)
LDFLAGS  ?=
LDLIBS   ?=
LIB_DIRS ?=
EXE ?= <Name of the executable or library to be compiled>
```

After that, a call to `make compile` or `make run` will trigger the compilation and execution. Also, you can compile libraries with `make compile_static_lib` or `make compile_dynamic_lib`.

## Testing framework

As the saying goes:
> Untested code is broken code

Therefore, **cottiMake** has you covered on compiling and running test cases.

You need to define the following three variables, and then call `make test`.

```make
TEST_SRC_DIRS ?= <your_test_cases>
TEST_INC_DIRS ?= <test_headers>
TEST_FRAMEWORK_SRC_DIRS ?= <required_srcs_that_are_not_executed>
```

## Execution, debugging and simulation

**cottiMake** supports three ways of executing your code:

1. Running locally: `make run`.
2. Running in a simulator ([QEMU][qemu] or [Renode][renode]) `make sim`.
3. Debugging with [GDB][gdb]: `make debug`.

```make
EXE ?= <executable_name>
EXEFLAGS ?= <command_line_args>

GDB ?= gdb
GDBFLAGS ?=
GDBSCRIPT ?=

SIM ?= <qemu | renode>
SIMFLAGS ?= <command_line_args_when_running_the_simulator>
```

Since setting up a simulation environment is not an easy task, the user is encouraged to check out the [examples/asm_project][asm_project], where this mechanism is exercised.

## Extending the build system

Need to do something custom that is not support with the default targets? Worry not! You can define new Make targets as you would normally do in any Makefile.

What's more, by adding a comment with a double numeral `##` after the `.PHONY` declaration, that custom target will appear in the `make help` menu.

```make
SRC_DIRS ?= src
INC_DIRS ?= inc

include cottimake/cottimake.mk

.PHONY: custom_target ## This comment will appear in the "make help" menu
custom_target:
    # Your recipe
```

## Reference

If you still have doubts about some of the variables, check out the comments on the [defaults.mk][defaults.mk] file, which defines all possible user-modifiable variables with default values.

## Contributing

**Found a bug?** Glad to fix it. Open an [issue][issue] containing the steps to replicate it, or open a [Pull Request][pr] with the fix.

You developed an exciting **new feature**, which extends the current functionality, and you would like to be include it in the repo? No problem, open a [Pull Request][pr] and I will review it.

<!-- Footnotes -->
[^1]: Some flags are automatically added for you, so you don't need to worry about them. Examples of those flags are the `-MMD` for creating dependency files or `-Map` to create a memory map of the executable.

<!-- External links -->
[make]: https://www.gnu.org/software/make/manual/make.html
[qemu]: https://www.qemu.org/
[renode]: https://renode.io/
[gdb]: https://www.sourceware.org/gdb/documentation/
[clang-tidy]: https://clang.llvm.org/extra/clang-tidy/
[clang-format]: https://clang.llvm.org/docs/ClangFormat.html
[clangd]: https://clangd.llvm.org/
[issue]: https://github.com/ncotti/cottiMake/issues
[pr]: https://github.com/ncotti/cottiMake/pulls

<!-- Internal links -->
[c_project]: examples/c_project/
[asm_project]: examples/asm_project/
[defaults.mk]: defaults.mk