CBMC ?= cbmc
UNWIND ?= 4

.PHONY: verify properties

verify:
	$(CBMC) harness.c --function harness --bounds-check --pointer-check --unwinding-assertions --unwind $(UNWIND)

properties:
	$(CBMC) harness.c --function harness --show-properties
