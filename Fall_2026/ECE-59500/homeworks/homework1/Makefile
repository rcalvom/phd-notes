TEMPLATE_DIR := ../template
HOMEWORK := homework1
SOURCE := ../homework1/report/homework1.tex

.DEFAULT_GOAL := pdf

.PHONY: pdf check open clean

pdf:
	$(MAKE) -C "$(TEMPLATE_DIR)" assignment \
		HOMEWORK="$(HOMEWORK)" ASSIGNMENT_SOURCE="$(SOURCE)"

check:
	$(MAKE) -C "$(TEMPLATE_DIR)" assignment-check \
		HOMEWORK="$(HOMEWORK)" ASSIGNMENT_SOURCE="$(SOURCE)"

open: pdf
	xdg-open submission.pdf >/dev/null 2>&1 &

clean:
	rm -f submission.aux submission.bbl submission.blg submission.log \
		submission.listing submission.out submission.run.xml submission.synctex.gz
	rm -rf _minted-submission
