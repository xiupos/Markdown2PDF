PANDOC = docker-compose build pandoc && docker-compose run --rm pandoc
LATEXMK = docker-compose build latex && docker-compose run --rm latex latexmk
LATEXMKFLAGS =
PYTHON = docker-compose build python && docker-compose run --rm python python

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
