BUILD_DIR = temp

all: clean $(BUILD_DIR) output.pdf

$(BUILD_DIR):
	cp -r config $(BUILD_DIR)
	cp -r src/* $(BUILD_DIR)

output.pdf: $(BUILD_DIR)/output.pdf
	cp $^ $@

$(BUILD_DIR)/output.pdf: src/main.md
	cd "$(PWD)/$(BUILD_DIR)" && make

clean:
	rm -rf $(BUILD_DIR)
