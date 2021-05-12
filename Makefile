
CXX ?= clang++-12
CLANGD ?= clangd-12

all_log_files := \
  cxx_ok.log cxx_ill_ok.log cxx_ill_nok.log \
  clangd_ok.log clangd_ill_ok.log clangd_ill_nok.log

all: $(all_log_files)

clean:
	rm -f $(all_log_files)

cxx_%.log: test_%.cpp Makefile
	$(CXX) $< -fsyntax-only > $@ 2>&1 || true

clangd_%.log: test_%.cpp Makefile
	$(CLANGD) --check=$< > $@ 2>&1 || true
