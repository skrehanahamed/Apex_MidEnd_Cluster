QT_DIR ?= /Users/reno/Qt/6.11.1/macos
BUILD_DIR = build
TARGET = $(BUILD_DIR)/ApexClusterApp

.PHONY: all build run clean rebuild package help

all: build

build:
	@mkdir -p $(BUILD_DIR)
	@export PATH="$(QT_DIR)/bin:$$PATH" && \
	cd $(BUILD_DIR) && \
	cmake -GNinja -DCMAKE_PREFIX_PATH="$(QT_DIR)" .. && \
	ninja

run: build
	@echo "Launching APEX Horizon Digital Instrument Cluster..."
	@./$(TARGET)

clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)

rebuild: clean build

package: build
	@./scripts/package.sh

help:
	@echo "APEX Horizon AMT Cluster Build Commands:"
	@echo "  make        - Build the Qt 6 application"
	@echo "  make run    - Build and launch the cluster application"
	@echo "  make package- Build and generate standalone .zip archive"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make rebuild- Clean and build from scratch"
