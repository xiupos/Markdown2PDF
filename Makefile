BUILD_DIR = temp

build: $(BUILD_DIR) output.pdf

$(BUILD_DIR):
	cp -r config $(BUILD_DIR)
	cp -r src/* $(BUILD_DIR)

output.pdf: $(BUILD_DIR)/output.pdf
	cp $^ $@

$(BUILD_DIR)/output.pdf: src/main.md
	cd "$(PWD)/$(BUILD_DIR)" && make

output-coverless.pdf: $(BUILD_DIR)/latexmk_out.pdf
	cp $^ $@

docker-build:
	cd "$(PWD)/$(BUILD_DIR)" && docker-compose build

all: clean $(BUILD_DIR) docker-build output.pdf

all-coverless: all output-coverless.pdf

clean:
	rm -rf $(BUILD_DIR) output.pdf output-coverless.pdf
