#!/bin/bash

# WorkQueueCLI Installer Script
# This script installs the WorkQueueCLI globally on your system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BINARY_NAME="workqueue"
REPO_URL="https://github.com/IsaacDSC/WorkQueueCLI"
INSTALL_DIR="/usr/local/bin"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case $arch in
        x86_64)
            arch="amd64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        armv7l)
            arch="arm"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    case $os in
        linux)
            PLATFORM="linux-$arch"
            ;;
        darwin)
            PLATFORM="darwin-$arch"
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
    
    print_status "Detected platform: $PLATFORM"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists "go"; then
        print_error "Go is not installed. Please install Go 1.23.2 or later."
        print_status "Visit https://golang.org/doc/install for installation instructions."
        exit 1
    fi
    
    local go_version=$(go version | awk '{print $3}' | sed 's/go//')
    print_success "Go $go_version is installed"
}

# Function to install from source
install_from_source() {
    print_status "Installing WorkQueueCLI from source..."
    
    # Check if we're in the project directory
    if [[ -f "go.mod" && -f "cmd/cli/main.go" ]]; then
        print_status "Installing from current directory..."
        
        # Build the binary
        print_status "Building binary..."
        go build -ldflags "-s -w" -o "$BINARY_NAME" ./cmd/cli/main.go
        
        # Move binary to install directory
        if [[ -w "$INSTALL_DIR" ]]; then
            mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
        else
            print_status "Need sudo privileges to install to $INSTALL_DIR"
            sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
            sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
        fi
        
    else
        print_status "Cloning repository..."
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Clone repository
        git clone "$REPO_URL" .
        
        # Build the binary
        print_status "Building binary..."
        go build -ldflags "-s -w" -o "$BINARY_NAME" ./cmd/cli/main.go
        
        # Move binary to install directory
        if [[ -w "$INSTALL_DIR" ]]; then
            mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
        else
            print_status "Need sudo privileges to install to $INSTALL_DIR"
            sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
            sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
        fi
        
        # Cleanup
        cd /
        rm -rf "$TEMP_DIR"
    fi
}

# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if command_exists "$BINARY_NAME"; then
        print_success "WorkQueueCLI installed successfully!"
        print_status "Version information:"
        "$BINARY_NAME" --help 2>/dev/null || echo "  Binary is installed and executable"
        print_status ""
        print_status "Usage examples:"
        print_status "  $BINARY_NAME event add-event --name \"My Event\" --serviceName \"my-service\" --repoUrl \"https://github.com/example/repo\""
        print_status "  $BINARY_NAME event add-consumer --json_file ./consumer.json"
        print_status "  $BINARY_NAME event test-producer --json_file ./payload.json"
    else
        print_error "Installation verification failed. $BINARY_NAME command not found."
        print_status "Please check that $INSTALL_DIR is in your PATH."
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "WorkQueueCLI Installer"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -u, --uninstall Uninstall WorkQueueCLI"
    echo "  --install-dir  Custom installation directory (default: $INSTALL_DIR)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Install WorkQueueCLI"
    echo "  $0 --install-dir ~/.local/bin # Install to custom directory"
    echo "  $0 --uninstall               # Uninstall WorkQueueCLI"
}

# Function to uninstall
uninstall() {
    print_status "Uninstalling WorkQueueCLI..."
    
    if [[ -f "$INSTALL_DIR/$BINARY_NAME" ]]; then
        if [[ -w "$INSTALL_DIR" ]]; then
            rm "$INSTALL_DIR/$BINARY_NAME"
        else
            sudo rm "$INSTALL_DIR/$BINARY_NAME"
        fi
        print_success "WorkQueueCLI uninstalled successfully!"
    else
        print_warning "WorkQueueCLI is not installed in $INSTALL_DIR"
    fi
}

# Main installation function
main() {
    echo "╔══════════════════════════════════════════════╗"
    echo "║            WorkQueueCLI Installer            ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--uninstall)
                uninstall
                exit 0
                ;;
            --install-dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check if already installed
    if command_exists "$BINARY_NAME"; then
        print_warning "WorkQueueCLI is already installed."
        read -p "Do you want to reinstall? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled."
            exit 0
        fi
    fi
    
    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        print_status "Creating installation directory: $INSTALL_DIR"
        if [[ -w "$(dirname "$INSTALL_DIR")" ]]; then
            mkdir -p "$INSTALL_DIR"
        else
            sudo mkdir -p "$INSTALL_DIR"
        fi
    fi
    
    detect_platform
    check_prerequisites
    install_from_source
    verify_installation
    
    print_success "Installation completed!"
    print_status ""
    print_status "Next steps:"
    print_status "1. Make sure $INSTALL_DIR is in your PATH"
    print_status "2. Run '$BINARY_NAME event --help' to see available commands"
    print_status "3. Check the README.md for usage examples"
}

# Run main function
main "$@"
