## STEPS ##
# STEP1: md -> md @PRE
# STEP2: md(1) -> lytex @PANDOC_MAIN
# STEP3: md(1) -> tex @PANDOC_TITLE
# STEP4: lytex(2) -> tex @LILYPOND
# STEP5: tex(3), tex(4) -> pdf @LATEX
# STEP6: pdf(5) -> pdf @POST

SRC_DIR = src
CONFIG_DIR = $(SRC_DIR)/.config
BUILD_DIR = .build
REPORT_DIR = reports
SCRIPT_DIR = script

INPUT = $(SRC_DIR)/main.md
OUTPUT = $(REPORT_DIR)/report.pdf

DOCKER = docker
DOCKER_FLAGS = --rm -v $(PWD):/worker -w /worker -u $(shell id -u):$(shell id -g)
PYTHON = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-python python
PANDOC = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-pandoc
LILYPOND_BOOK = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-lilypond lilypond-book
LATEX = lualatex
LATEXMK = $(DOCKER) run $(DOCKER_FLAGS) ghcr.io/xiupos/md2pdf-latex latexmk

# STEP1
PRE = $(PYTHON) $(SCRIPT_DIR)/pre.py
PRE_IN = $(INPUT)
PRE_OUT = $(BUILD_DIR)/pre_out.md

# STEP2
PANDOC_MAIN = $(PANDOC)
PANDOC_MAIN_FLAGS = -f markdown+raw_tex \
	--filter pandoc-crossref \
	--top-level-division=section \
	-M "crossrefYaml=$(PANDOC_MAIN_CONFIG)"
PANDOC_MAIN_IN = $(PRE_OUT)
PANDOC_MAIN_OUT = $(BUILD_DIR)/main_out.lytex
PANDOC_MAIN_CONFIG = $(BUILD_DIR)/pandoc.yml

# STEP3
PANDOC_TITLE = $(PANDOC)
PANDOC_TITLE_FLAGS = -f markdown+raw_tex \
	--template=$(PANDOC_TITLE_TEMPLATE)
PANDOC_TITLE_IN = $(PRE_OUT)
PANDOC_TITLE_OUT = $(BUILD_DIR)/title_out.tex
PANDOC_TITLE_TEMPLATE = $(BUILD_DIR)/title_template.tex

# STEP4
LILYPOND = $(LILYPOND_BOOK)
LILYPOND_FLAGS = --pdf \
	--latex-program=$(LATEX) \
	-o $(BUILD_DIR)
LILYPOND_IN = $(PANDOC_MAIN_OUT)
LILYPOND_OUT = $(BUILD_DIR)/lilypond_out.tex

# STEP5
LATEXMK_FLAGS = -pdflatex=$(LATEX) \
	-pdf \
	-cd
LATEXMK_IN = $(PANDOC_TITLE_OUT) $(LILYPOND_OUT)
LATEXMK_OUT = $(BUILD_DIR)/latex_out.pdf
LATEXMK_FRAME = $(BUILD_DIR)/frame.tex

# STEP6
POST = $(PYTHON) $(SCRIPT_DIR)/post.py
POST_IN = $(LATEXMK_OUT)
POST_OUT = $(OUTPUT)

all: clean create_dirs $(OUTPUT)


# STEP1 @PRE
$(PRE_OUT): $(PRE_IN)
	$(PRE) $^ $@

# STEP2 @PANDOC_MAIN
$(PANDOC_MAIN_OUT): $(PANDOC_MAIN_IN)
	$(PANDOC_MAIN) $(PANDOC_MAIN_FLAGS) $^ -o ${@:.lytex=.tex}
	mv ${@:.lytex=.tex} $@

# STEP3 @PANDOC_TITLE
$(PANDOC_TITLE_OUT): $(PANDOC_TITLE_IN)
	$(PANDOC_TITLE) $(PANDOC_TITLE_FLAGS) $^ -o $@

# STEP4 @LILYPOND
$(LILYPOND_OUT): $(LILYPOND_IN)
	$(LILYPOND) $(LILYPOND_FLAGS) $^
	mv $(^:.lytex=.tex) $@

# STEP5 @LATEX
$(LATEXMK_OUT): $(LATEXMK_IN)
	$(LATEXMK) $(LATEXMK_FLAGS) $(LATEXMK_FRAME)
	mv $(LATEXMK_FRAME:.tex=.pdf) $@

# STEP6 @POST
$(POST_OUT): $(POST_IN)
	$(POST) $^ $@


create_dirs: $(BUILD_DIR) $(REPORT_DIR)

$(BUILD_DIR): $(CONFIG_DIR) $(SRC_DIR)
	cp -r $(SRC_DIR) $@
	cp -r $(CONFIG_DIR)/* $@

$(REPORT_DIR):
	mkdir $@

clean:
	rm -rf $(BUILD_DIR) $(REPORT_DIR)
