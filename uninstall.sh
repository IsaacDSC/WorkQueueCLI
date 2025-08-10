#!/bin/bash

# WorkQueueCLI Uninstaller Script
# This script removes WorkQueueCLI from your system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BINARY_NAME="workqueue"

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

# Function to find installation locations
find_installations() {
    local locations=()
    
    # Check common installation directories
    local common_dirs=(
        "/usr/local/bin"
        "/usr/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
    )
    
    for dir in "${common_dirs[@]}"; do
        if [[ -f "$dir/$BINARY_NAME" ]]; then
            locations+=("$dir/$BINARY_NAME")
        fi
    done
    
    # Check PATH for any other locations
    if command_exists "$BINARY_NAME"; then
        local which_result=$(which "$BINARY_NAME" 2>/dev/null || true)
        if [[ -n "$which_result" ]]; then
            # Add to locations if not already present
            local found=false
            for loc in "${locations[@]}"; do
                if [[ "$loc" == "$which_result" ]]; then
                    found=true
                    break
                fi
            done
            if [[ "$found" == false ]]; then
                locations+=("$which_result")
            fi
        fi
    fi
    
    echo "${locations[@]}"
}

# Function to remove binary
remove_binary() {
    local binary_path="$1"
    local dir=$(dirname "$binary_path")
    
    print_status "Removing $binary_path..."
    
    if [[ -w "$dir" ]]; then
        rm "$binary_path"
    else
        print_status "Need sudo privileges to remove from $dir"
        sudo rm "$binary_path"
    fi
    
    print_success "Removed $binary_path"
}

# Function to remove completions
remove_completions() {
    local completion_files=(
        "/usr/local/share/bash-completion/completions/workqueue"
        "/etc/bash_completion.d/workqueue"
        "/usr/local/share/zsh/site-functions/_workqueue"
        "$HOME/.local/share/bash-completion/completions/workqueue"
        "$HOME/.oh-my-zsh/completions/_workqueue"
    )
    
    local removed=false
    
    for file in "${completion_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Removing completion file: $file"
            if [[ -w "$(dirname "$file")" ]]; then
                rm "$file"
            else
                sudo rm "$file" 2>/dev/null || true
            fi
            removed=true
        fi
    done
    
    if [[ "$removed" == true ]]; then
        print_success "Removed completion files"
    fi
}

# Main uninstall function
main() {
    echo "╔══════════════════════════════════════════════╗"
    echo "║           WorkQueueCLI Uninstaller           ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    # Find all installations
    local installations=($(find_installations))
    
    if [[ ${#installations[@]} -eq 0 ]]; then
        print_warning "WorkQueueCLI is not installed on this system."
        print_status "Checked common installation directories:"
        print_status "  - /usr/local/bin"
        print_status "  - /usr/bin"
        print_status "  - ~/.local/bin"
        print_status "  - ~/bin"
        exit 0
    fi
    
    print_status "Found WorkQueueCLI installations:"
    for installation in "${installations[@]}"; do
        print_status "  - $installation"
    done
    echo ""
    
    # Confirm uninstall
    read -p "Do you want to remove all installations? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled."
        exit 0
    fi
    
    # Remove each installation
    for installation in "${installations[@]}"; do
        if [[ -f "$installation" ]]; then
            remove_binary "$installation"
        fi
    done
    
    # Remove completion files
    remove_completions
    
    # Final verification
    if command_exists "$BINARY_NAME"; then
        print_warning "Warning: '$BINARY_NAME' command is still available."
        print_status "There may be other installations in your PATH."
        print_status "Run 'which $BINARY_NAME' to find remaining installations."
    else
        print_success "WorkQueueCLI has been completely removed from your system!"
    fi
    
    print_status ""
    print_status "Thank you for using WorkQueueCLI!"
}

# Show help
show_help() {
    echo "WorkQueueCLI Uninstaller"
    echo ""
    echo "This script removes all WorkQueueCLI installations from your system."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Remove without confirmation"
    echo ""
    echo "The uninstaller will:"
    echo "  - Find all WorkQueueCLI installations"
    echo "  - Remove binary files"
    echo "  - Remove shell completion files"
    echo "  - Verify complete removal"
}

# Parse arguments
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
if [[ "$FORCE" == true ]]; then
    # Force mode - skip confirmation
    REPLY="y"
fi

main
