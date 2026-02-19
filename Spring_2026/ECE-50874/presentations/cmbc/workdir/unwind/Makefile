CBMC ?= cbmc
UNWIND ?= 6
FUNCTION ?= binsearch

.PHONY: verify properties

verify:
	$(CBMC) source.c --function $(FUNCTION) --unwind $(UNWIND) --bounds-check --unwinding-assertions

properties:
	$(CBMC) source.c --function $(FUNCTION) --show-properties
