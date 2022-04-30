UID = $(shell id -u)
GID = $(shell id -g)

PANDOC = docker-compose build pandoc && UID=$(UID) GID=$(GID) docker-compose run --rm pandoc
LATEXMK = docker-compose build latex && UID=$(UID) GID=$(GID) docker-compose run --rm latex latexmk
LATEXMKFLAGS = -pdflatex=lualatex -pdf
PYTHON = docker-compose build python && UID=$(UID) GID=$(GID) docker-compose run --rm python python

all: output-covered.pdf

output-covered.pdf: cover.pdf output-uncovered.pdf
	$(PYTHON) merger.py $^ $@

output-uncovered.pdf: pandoc_out.tex
	$(LATEXMK) $(LATEXMKFLAGS) template.tex
	mv template.pdf $@

pandoc_out.tex: main.md
	$(PANDOC) --filter pandoc-crossref \
		--top-level-division=section \
		-M "crossrefYaml=pandoc.yml" \
		-o $@ \
		$^
