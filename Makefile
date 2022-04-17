BUILD_DIR = temp

all: clean $(BUILD_DIR) docker-build output-covered.pdf output-uncovered.pdf

output-covered.pdf: $(BUILD_DIR)/output-covered.pdf
	cp $^ $@

output-uncovered.pdf: $(BUILD_DIR)/output-uncovered.pdf
	cp $^ $@

$(BUILD_DIR)/output-%.pdf: src/main.md $(BUILD_DIR)
	cd "$(PWD)/$(BUILD_DIR)" && make

$(BUILD_DIR):
	cp -r config $(BUILD_DIR)
	cp -r src/* $(BUILD_DIR)

docker-build:
	cd "$(PWD)/$(BUILD_DIR)" && docker-compose build

clean:
	rm -rf $(BUILD_DIR) output-covered.pdf output-uncovered.pdf
