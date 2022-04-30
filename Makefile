BUILD_DIR = .temp
OUTPUT_DIR = reports

all: clean $(BUILD_DIR) docker-build $(OUTPUT_DIR) $(OUTPUT_DIR)/covered.pdf $(OUTPUT_DIR)/uncovered.pdf

$(OUTPUT_DIR)/covered.pdf: $(BUILD_DIR)/output-covered.pdf
	cp $^ $@

$(OUTPUT_DIR)/uncovered.pdf: $(BUILD_DIR)/output-uncovered.pdf
	cp $^ $@

$(BUILD_DIR)/output-%.pdf: src/main.md $(BUILD_DIR)
	cd "$(PWD)/$(BUILD_DIR)" && make

$(BUILD_DIR):
	cp -r .config $(BUILD_DIR)
	cp -r src/* $(BUILD_DIR)

$(OUTPUT_DIR):
	mkdir $(OUTPUT_DIR)

docker-build:
	cd "$(PWD)/$(BUILD_DIR)" && docker-compose build

clean:
	rm -rf $(BUILD_DIR) $(OUTPUT_DIR)
