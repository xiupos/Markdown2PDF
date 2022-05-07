UID = $(shell id -u)
GID = $(shell id -g)

MAIN_MD = main.md

PANDOC = docker-compose build pandoc && \
	UID=$(UID) GID=$(GID) docker-compose run --rm pandoc
PANDOC_CONFIG = pandoc.yml
PANDOC_OUT_MAIN = pandoc_out-main.tex
PANDOC_OUT_TITLE = pandoc_out-title.tex
PANDOC_TEMPLATE_TITLE = template-title.tex

LATEXMK = docker-compose build latex && \
	UID=$(UID) GID=$(GID) docker-compose run --rm latex latexmk
LATEXMK_FLAGS = -pdflatex=lualatex -pdf
LATEXMK_FRAME = frame.tex

PYTHON = docker-compose build python && \
	UID=$(UID) GID=$(GID) docker-compose run --rm python python
PYTHON_SCRIPT = merger.py
PYTHON_COVER_PDF = pdf/cover.pdf

OUTPUT = output-uncovered.pdf
OUTPUT_COVERED = output-covered.pdf


all: $(OUTPUT) $(OUTPUT_COVERED)

$(OUTPUT_COVERED): $(PYTHON_COVER_PDF) $(OUTPUT)
	$(PYTHON) $(PYTHON_SCRIPT) $^ $@

$(OUTPUT): $(PANDOC_OUT_MAIN) $(PANDOC_OUT_TITLE)
	$(LATEXMK) $(LATEXMK_FLAGS) $(LATEXMK_FRAME)
	mv $(LATEXMK_FRAME:.tex=.pdf) $@

$(PANDOC_OUT_TITLE): $(MAIN_MD)
	$(PANDOC) -f markdown+raw_tex \
		--template=$(PANDOC_TEMPLATE_TITLE) \
		-o $@ \
		$^

$(PANDOC_OUT_MAIN): $(MAIN_MD)
	$(PANDOC) --filter pandoc-crossref \
		--top-level-division=section \
		-M "crossrefYaml=$(PANDOC_CONFIG)" \
		-o $@ \
		$^
