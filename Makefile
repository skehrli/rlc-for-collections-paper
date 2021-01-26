all: resource-leak.pdf

resource-leak.pdf: bib-update
	latexmk -pdf -interaction=nonstopmode -f resource-leak.tex

resource-leak-notodos.pdf: resource-leak.pdf
	pdflatex "\def\notodocomments{}\input{resource-leak}"
	pdflatex "\def\notodocomments{}\input{resource-leak}"
	cp -pf resource-leak.pdf $@

# Upload onefile.zip to the publisher website
onefile.zip: onefile.tex
	zip onefile.zip onefile.tex acmart.cls ACM-Reference-Format.bst
onefile.tex: $(filter-out onefile.tex, $(wildcard *.tex))
	latex-process-inputs resource-leak.tex > onefile.tex


# This target creates:
#   https://homes.cs.washington.edu/~mernst/tmp678/resource-leak.pdf
web: resource-leak-notodos.pdf
	cp -pf $^ ${HOME}/public_html/tmp678/resource-leak.pdf
.PHONY: resource-leak-singlecolumn.pdf resource-leak-notodos.pdf

martin: resource-leak.pdf
	open $<

export BIBINPUTS ?= .:bib
bib:
ifdef PLUMEBIB
	ln -s ${PLUMEBIB} $@
else
	git clone https://github.com/mernst/plume-bib.git $@
endif
.PHONY: bib-update
bib-update: bib
# Even if this command fails, it does not terminate the make job.
# However, to skip it, invoke make as:  make NOGIT=1 ...
ifndef NOGIT
	-(cd bib && make)
endif

TAGS: tags
tags:
	etags `latex-process-inputs -list resource-leak.tex`

## TODO: this should not delete ICSE2020-submission.pdf
clean:
	rm -f *.bbl *.aux *~ resource-leak.pdf *.blg *.log TAGS
