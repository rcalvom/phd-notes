XOPP_FILES := $(wildcard */*.xopp)
PDF_FILES := $(XOPP_FILES:.xopp=.pdf)

.PHONY: all clean

all: $(PDF_FILES)

%.pdf: %.xopp
	xournalpp --create-pdf="$@" "$<"

clean:
	rm -f -- $(PDF_FILES)
