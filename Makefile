
## User variables

# Optional: directory containing self-built 'clang++' and 'clangd' executables.
LLVM_BIN_DIR ?=

# Intended to be the system one:
LLVM_CONFIG ?= llvm-config-12

## Non-user variables

# NOTE: will be wrong if this Makefile is invoked from outside.
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

DEFAULT_CXX := clang++-12
DEFAULT_CLANGD := clangd-12

cxx := $(if $(LLVM_BIN_DIR),$(LLVM_BIN_DIR)/clang++,$(DEFAULT_CXX))
clangd := $(if $(LLVM_BIN_DIR),$(LLVM_BIN_DIR)/clangd,$(DEFAULT_CLANGD))

llvm-config := $(shell which $(LLVM_CONFIG))

ifeq ($(llvm-config),)
    $(error "$(LLVM_CONFIG) not found, use LLVM_CONFIG=<path/to/llvm-config> make")
endif

full_llvm_version := $(shell $(llvm-config) --version)
llvm_version := $(full_llvm_version:git=)
libdir := $(shell $(llvm-config) --libdir)
llvm_libdir_include := $(libdir)/clang/$(llvm_version)/include

cxxflags := -std=c++17 $(if $(LLVM_BIN_DIR),-isystem $(llvm_libdir_include))

all_log_files := \
  cxx_ok.log cxx_ill_ok.log cxx_ill_nok.log \
  clangd_ok.log clangd_ill_ok.log clangd_ill_nok.log

## Targets

all: $(all_log_files)

compile_commands.json: compile_commands.json.in Makefile
	sed 's|@cxxflags@|$(cxxflags)|g; s|@dir@|$(THIS_DIR)|g' $< > $@

clean:
	rm -f $(all_log_files) compile_commands.json
	rm -f $(patsubst %,%~,$(all_log_files))

cxx_ok.log:
cxx_ill_ok.log: cxx_ok.log
cxx_ill_nok.log: cxx_ill_ok.log
cxx_%.log: test_%.cpp Makefile
	$(cxx) $(cxxflags) $< -fsyntax-only > $@ 2>&1; \
	  test $$? $(if $(findstring _ill_,$@),-ne,-eq) 0 || (mv $@ $@~ && false)

# FIXME: we don't distinguish between errors in the execution of clangd itself
#  (e.g. compile_commands.json not found) and compilation errors of the translation
#  unit under test.

clangd_ok.log:
clangd_ill_ok.log: clangd_ok.log
clangd_ill_nok.log: clangd_ill_ok.log
clangd_%.log: test_%.cpp compile_commands.json Makefile
	$(clangd) --check=$< > $@ 2>&1; \
	  test $$? $(if $(findstring _ill_,$@),-ne,-eq) 0 || (mv $@ $@~ && false)
