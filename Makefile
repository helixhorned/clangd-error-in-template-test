
LLVM_BIN_DIR ?=

DEFAULT_CXX := clang++-12
DEFAULT_CLANGD := clangd-12

cxx := $(if $(LLVM_BIN_DIR),$(LLVM_BIN_DIR)/clang++,$(DEFAULT_CXX))
clangd := $(if $(LLVM_BIN_DIR),$(LLVM_BIN_DIR)/clangd,$(DEFAULT_CLANGD))

all_log_files := \
  cxx_ok.log cxx_ill_ok.log cxx_ill_nok.log \
  clangd_ok.log clangd_ill_ok.log clangd_ill_nok.log

all: $(all_log_files)

clean:
	rm -f $(all_log_files)

cxx_ok.log:
cxx_ill_ok.log:
cxx_ill_nok.log:
cxx_%.log: test_%.cpp Makefile
	$(cxx) $< -fsyntax-only > $@ 2>&1; \
	  test $$? $(if $(findstring _ill_,$@),-ne,-eq) 0

# FIXME: we don't distinguish between errors in the execution of clangd itself
#  (e.g. compile_commands.json not found) and compilation errors of the translation
#  unit under test.

clangd_ok.log:
clangd_ill_ok.log:
clangd_ill_nok.log:
clangd_%.log: test_%.cpp Makefile
	$(clangd) --check=$< > $@ 2>&1; \
	  test $$? $(if $(findstring _ill_,$@),-ne,-eq) 0
