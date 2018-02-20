# Tested on Ubuntu 16.04
#
# Prerequisites:
#   $ sudo apt-get install -y \
#    texlive-latex-recommended \
#    texlive-latex-extra \
#    texlive-fonts-recommended \
#    texlive-science \
#    aspell

FILENAME=vldb_sample
PDFLATEX_B=pdflatex -halt-on-error -file-line-error -interaction=batchmode
PDFLATEX=pdflatex -halt-on-error -file-line-error
BIBTEX=bibtex
PDFLATEX_OUTPUT=pdflatex-output
BIBTEX_OUTPUT=bibtex-output

.PHONY: all build clean aspell

all: build aspell

build: $(FILENAME).bbl $(FILENAME).tex
	$(PDFLATEX_B) $(FILENAME) > /dev/null || $(PDFLATEX) $(FILENAME)
	$(PDFLATEX_B) $(FILENAME) > /dev/null || $(PDFLATEX) $(FILENAME)

$(FILENAME).bbl: $(FILENAME).tex $(FILENAME).aux
	$(BIBTEX) $(FILENAME) > $(BIBTEX_OUTPUT) 2>&1 || (cat $(BIBTEX_OUTPUT) && exit 1)
	@# Halt on warnings or errors
	@if [ "`grep -E '(warning|error message)' $(BIBTEX_OUTPUT) | wc -l`" -ne "0" ]; then\
		cat $(BIBTEX_OUTPUT); \
		exit 1;\
	fi

$(FILENAME).aux: $(FILENAME).tex
	$(PDFLATEX_B) $(FILENAME) > $(PDFLATEX_OUTPUT) 2>&1 || $(PDFLATEX) $(FILENAME)
	@# Halt on undefined
	@if [ "`grep -i undefined $(PDFLATEX_OUTPUT) | wc -l`" -ne "0" ]; then\
		printf "There were undefined warnings. Check file %s\n" $(PDFLATEX_OUTPUT); \
		exit 1;\
	fi

clean:
	rm -rf $(FILENAME).pdf $(FILENAME).aux $(FILENAME).log $(FILENAME).bbl $(FILENAME).blg $(FILENAME).toc $(FILENAME).out $(PDFLATEX_OUTPUT) $(BIBTEX_OUTPUT)

aspell:
	cat *.tex | aspell list -t | sort -f | uniq > aspell-personal-dict && git diff aspell-personal-dict
