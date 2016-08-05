SUBDIRS := $(wildcard */.)

export ITERATION := $(shell git rev-list HEAD 2>/dev/null | awk 'END {print NR}')

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
