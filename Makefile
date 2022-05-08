SRC_DIR = src
CONFIG_DIR = .config

BUILD_DIR = .build
BUILD_MK = $(BUILD_DIR)/build.mk
BUILD_OUT = $(BUILD_DIR)/output-uncovered.pdf
BUILD_OUT_COVERED = $(BUILD_DIR)/output-covered.pdf
BUILD_DOCKERCOMPOSE = $(BUILD_DIR)/docker-compose.yml

REPORT_DIR = reports
REPORT = $(REPORT_DIR)/report.pdf
REPORT_COVERED = $(REPORT_DIR)/report-covered.pdf

all: clean $(BUILD_DIR) $(REPORT_DIR) $(REPORT)

all-covered: all $(REPORT_COVERED)

pull: $(BUILD) $(BUILD_DOCKERCOMPOSE)
	cd "$(PWD)/$(BUILD_DIR)" && \
	docker-compose -f "$(PWD)/$(BUILD_DOCKERCOMPOSE)" pull

$(REPORT_COVERED): $(BUILD_OUT_COVERED)
	cp $^ $@

$(REPORT): $(BUILD_OUT)
	cp $^ $@

$(BUILD_OUT) $(BUILD_OUT_COVERED): $(BUILD_DIR)
	cd "$(PWD)/$(BUILD_DIR)" && $(MAKE) -f "$(PWD)/$(BUILD_MK)"

$(BUILD_DIR): $(CONFIG_DIR) $(SRC_DIR)
	cp -r $(CONFIG_DIR) $@
	cp -r $(SRC_DIR)/* $@

$(REPORT_DIR):
	mkdir $@

clean:
	rm -rf $(BUILD_DIR) $(REPORT_DIR)
