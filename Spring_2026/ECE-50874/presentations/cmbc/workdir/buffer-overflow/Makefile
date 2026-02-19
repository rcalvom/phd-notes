CBMC ?= cbmc

.PHONY: verify properties

verify:
	$(CBMC) source.c --bounds-check --pointer-check

properties:
	$(CBMC) source.c --show-properties --bounds-check --pointer-check
