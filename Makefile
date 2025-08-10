# Makefile for WorkQueueCLI

# Variables
BINARY_NAME := workqueue
PACKAGE := github.com/IsaacDSC/WorkQueueCLI
MAIN_PATH := ./cmd/cli/main.go
BUILD_DIR := ./build
INSTALL_DIR := /usr/local/bin

# Go variables
GOCMD := go
GOBUILD := $(GOCMD) build
GOCLEAN := $(GOCMD) clean
GOTEST := $(GOCMD) test
GOGET := $(GOCMD) get
GOMOD := $(GOCMD) mod

# Build flags
LDFLAGS := -s -w
BUILD_FLAGS := -ldflags "$(LDFLAGS)"

# Git variables
GIT_COMMIT := $(shell git rev-parse --short HEAD)
GIT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)

# Enhanced build flags with version info
VERSION_LDFLAGS := -X main.Version=$(GIT_TAG) -X main.GitCommit=$(GIT_COMMIT) -X main.BuildDate=$(BUILD_DATE)
FULL_LDFLAGS := -s -w $(VERSION_LDFLAGS)
FULL_BUILD_FLAGS := -ldflags "$(FULL_LDFLAGS)"

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM := darwin
endif

ifeq ($(UNAME_M),x86_64)
    ARCH := amd64
endif
ifeq ($(UNAME_M),arm64)
    ARCH := arm64
endif
ifeq ($(UNAME_M),aarch64)
    ARCH := arm64
endif

# Default target
.PHONY: all
all: clean build

# Help target
.PHONY: help
help: ## Show this help message
	@echo "WorkQueueCLI Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# Clean target
.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY_NAME)

# Dependencies
.PHONY: deps
deps: ## Download and verify dependencies
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) verify
	$(GOMOD) tidy

# Build target
.PHONY: build
build: deps ## Build the binary
	@echo "Building $(BINARY_NAME)..."
	$(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BINARY_NAME) $(MAIN_PATH)

# Build for production
.PHONY: build-prod
build-prod: clean deps ## Build optimized binary for production
	@echo "Building $(BINARY_NAME) for production..."
	CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -a -installsuffix cgo -o $(BINARY_NAME) $(MAIN_PATH)

# Build for all platforms
.PHONY: build-all
build-all: clean deps ## Build binaries for all supported platforms
	@echo "Building for all platforms..."
	@mkdir -p $(BUILD_DIR)
	
	# Linux builds
	@echo "Building for Linux amd64..."
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(MAIN_PATH)
	
	@echo "Building for Linux arm64..."
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(MAIN_PATH)
	
	@echo "Building for Linux arm..."
	GOOS=linux GOARCH=arm CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm $(MAIN_PATH)
	
	# macOS builds
	@echo "Building for macOS amd64..."
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(MAIN_PATH)
	
	@echo "Building for macOS arm64..."
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(MAIN_PATH)
	
	# Windows builds
	@echo "Building for Windows amd64..."
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(MAIN_PATH)
	
	@echo "Building for Windows arm64..."
	GOOS=windows GOARCH=arm64 CGO_ENABLED=0 $(GOBUILD) $(FULL_BUILD_FLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe $(MAIN_PATH)
	
	@echo "All builds completed successfully!"
	@ls -la $(BUILD_DIR)/

# Test target
.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	$(GOTEST) -v ./...

# Test with coverage
.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	$(GOTEST) -v -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Install target
.PHONY: install
install: build ## Install binary to system PATH
	@echo "Installing $(BINARY_NAME) to $(INSTALL_DIR)..."
	@if [ -w "$(INSTALL_DIR)" ]; then \
		cp $(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME); \
		chmod +x $(INSTALL_DIR)/$(BINARY_NAME); \
	else \
		sudo cp $(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME); \
		sudo chmod +x $(INSTALL_DIR)/$(BINARY_NAME); \
	fi
	@echo "$(BINARY_NAME) installed successfully!"
	@echo "Run '$(BINARY_NAME) event --help' to get started."

# Install with custom directory
.PHONY: install-user
install-user: build ## Install binary to user's local bin directory
	@echo "Installing $(BINARY_NAME) to ~/.local/bin..."
	@mkdir -p ~/.local/bin
	cp $(BINARY_NAME) ~/.local/bin/$(BINARY_NAME)
	chmod +x ~/.local/bin/$(BINARY_NAME)
	@echo "$(BINARY_NAME) installed to ~/.local/bin!"
	@echo "Make sure ~/.local/bin is in your PATH."
	@echo "Add 'export PATH=\"\$$HOME/.local/bin:\$$PATH\"' to your shell profile if needed."

# Uninstall target
.PHONY: uninstall
uninstall: ## Uninstall binary from system
	@echo "Uninstalling $(BINARY_NAME)..."
	@if [ -f "$(INSTALL_DIR)/$(BINARY_NAME)" ]; then \
		if [ -w "$(INSTALL_DIR)" ]; then \
			rm $(INSTALL_DIR)/$(BINARY_NAME); \
		else \
			sudo rm $(INSTALL_DIR)/$(BINARY_NAME); \
		fi; \
		echo "$(BINARY_NAME) uninstalled successfully!"; \
	else \
		echo "$(BINARY_NAME) is not installed in $(INSTALL_DIR)"; \
	fi

# Run target
.PHONY: run
run: ## Run the application
	@echo "Running $(BINARY_NAME)..."
	$(GOCMD) run $(MAIN_PATH)

# Run with arguments
.PHONY: run-help
run-help: ## Run the application with help command
	$(GOCMD) run $(MAIN_PATH) event --help

# Development targets
.PHONY: dev-build
dev-build: ## Quick build for development
	$(GOBUILD) -o $(BINARY_NAME) $(MAIN_PATH)

.PHONY: dev-run
dev-run: dev-build ## Build and run for development
	./$(BINARY_NAME)

# Format code
.PHONY: fmt
fmt: ## Format Go code
	@echo "Formatting code..."
	$(GOCMD) fmt ./...

# Lint code
.PHONY: lint
lint: ## Lint Go code (requires golangci-lint)
	@echo "Linting code..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found. Install it with:"; \
		echo "  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

# Security scan
.PHONY: security
security: ## Run security scan (requires gosec)
	@echo "Running security scan..."
	@if command -v gosec >/dev/null 2>&1; then \
		gosec ./...; \
	else \
		echo "gosec not found. Install it with:"; \
		echo "  go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest"; \
	fi

# Create release archive
.PHONY: release
release: build-all ## Create release archives for all platforms
	@echo "Creating release archives..."
	@mkdir -p $(BUILD_DIR)/releases
	
	# Create archives for each platform
	@for binary in $(BUILD_DIR)/$(BINARY_NAME)-*; do \
		if [ -f "$$binary" ]; then \
			platform=$$(basename "$$binary" | sed 's/$(BINARY_NAME)-//'); \
			echo "Creating archive for $$platform..."; \
			if [[ "$$platform" == *"windows"* ]]; then \
				cd $(BUILD_DIR) && zip "releases/$(BINARY_NAME)-$$platform.zip" "$$(basename "$$binary")" && cd ..; \
			else \
				cd $(BUILD_DIR) && tar -czf "releases/$(BINARY_NAME)-$$platform.tar.gz" "$$(basename "$$binary")" && cd ..; \
			fi; \
		fi; \
	done
	
	@echo "Release archives created in $(BUILD_DIR)/releases/"
	@ls -la $(BUILD_DIR)/releases/

# Check if binary exists and show info
.PHONY: info
info: ## Show build information
	@echo "WorkQueueCLI Build Information"
	@echo "=============================="
	@echo "Binary name: $(BINARY_NAME)"
	@echo "Package: $(PACKAGE)"
	@echo "Platform: $(PLATFORM)-$(ARCH)"
	@echo "Git tag: $(GIT_TAG)"
	@echo "Git commit: $(GIT_COMMIT)"
	@echo "Build date: $(BUILD_DATE)"
	@echo ""
	@if [ -f "$(BINARY_NAME)" ]; then \
		echo "Binary exists: ✓"; \
		echo "Binary size: $$(du -h $(BINARY_NAME) | cut -f1)"; \
	else \
		echo "Binary exists: ✗ (run 'make build' to create)"; \
	fi
	@echo ""
	@if command -v $(BINARY_NAME) >/dev/null 2>&1; then \
		echo "Installed globally: ✓"; \
		echo "Install location: $$(which $(BINARY_NAME))"; \
	else \
		echo "Installed globally: ✗ (run 'make install' to install)"; \
	fi
