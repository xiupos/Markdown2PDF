MAIN_MD = main.md
LATEX = lualatex

DOCKER = docker
DOCKER_FLAGS = --rm -v $(PWD):/worker -w /worker -u $(shell id -u):$(shell id -g)

PANDOC = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-pandoc
PANDOC_CONFIG = pandoc.yml
PANDOC_OUT_MAIN = pandoc_out-main.tex
PANDOC_OUT_TITLE = pandoc_out-title.tex
PANDOC_TEMPLATE_TITLE = template-title.tex

LILYPOND = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-lilypond lilypond-book
LILYPOND_FLAGS = --pdf --latex-program=$(LATEX)

LATEXMK = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-latex latexmk
LATEXMK_FLAGS = -pdflatex=$(LATEX) -pdf
LATEXMK_FRAME = frame.tex

PYTHON = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-python python
PYTHON_SCRIPT = merger.py
PYTHON_COVER_PDF = pdf/cover.pdf

OUTPUT = output-uncovered.pdf
OUTPUT_COVERED = output-covered.pdf


all: $(OUTPUT) $(OUTPUT_COVERED)

$(OUTPUT_COVERED): $(PYTHON_COVER_PDF) $(OUTPUT)
	$(PYTHON) $(PYTHON_SCRIPT) $^ $@

$(OUTPUT): $(PANDOC_OUT_MAIN) $(PANDOC_OUT_TITLE)
	mv $(PANDOC_OUT_MAIN) $(PANDOC_OUT_MAIN:.tex=.lytex)
	$(LILYPOND) $(LILYPOND_FLAGS) $(PANDOC_OUT_MAIN:.tex=.lytex)
	$(LATEXMK) $(LATEXMK_FLAGS) $(LATEXMK_FRAME)
	$(LATEXMK) -c
	mv $(LATEXMK_FRAME:.tex=.pdf) $@

$(PANDOC_OUT_TITLE): $(MAIN_MD)
	$(PANDOC) -f markdown+raw_tex \
		--template=$(PANDOC_TEMPLATE_TITLE) \
		-o $@ \
		$^

$(PANDOC_OUT_MAIN): $(MAIN_MD)
	$(PANDOC) -f markdown+raw_tex \
		--filter pandoc-crossref \
		--top-level-division=section \
		-M "crossrefYaml=$(PANDOC_CONFIG)" \
		-o $@ \
		$^
