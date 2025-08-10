# Install WorkQueueCLI

This document provides comprehensive installation instructions for WorkQueueCLI across different platforms and methods.

## Quick Install (Recommended)

### macOS and Linux

```bash
# Download and run the installer script
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash

# Or download and run manually
wget https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh
chmod +x install.sh
./install.sh
```

### Windows

```powershell
# Download and run the PowerShell installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.ps1" -OutFile "install.ps1"
.\install.ps1

# Or run directly (requires PowerShell 3.0+)
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.ps1'))
```

## Installation Methods

### Method 1: Automated Installation Script

The automated installer handles everything for you including dependency checks, building, and PATH configuration.

#### macOS/Linux Script Features:
- ✅ Automatic dependency verification (Go, Git)
- ✅ Platform detection (Linux/macOS, amd64/arm64)
- ✅ Builds from source with optimizations
- ✅ Installs to `/usr/local/bin` (or custom directory)
- ✅ Handles sudo requirements automatically
- ✅ Installation verification
- ✅ Uninstall support

#### Windows Script Features:
- ✅ Automatic dependency verification (Go, Git)
- ✅ Builds from source with optimizations
- ✅ Installs to `%LOCALAPPDATA%\Programs\WorkQueueCLI`
- ✅ Automatic PATH configuration
- ✅ Installation verification
- ✅ Uninstall support

#### Script Usage Examples:

```bash
# Basic installation
./install.sh

# Install to custom directory
./install.sh --install-dir ~/.local/bin

# Uninstall
./install.sh --uninstall

# Show help
./install.sh --help
```

### Method 2: Using Makefile

If you have the source code, you can use the provided Makefile for installation:

```bash
# Clone the repository
git clone https://github.com/IsaacDSC/WorkQueueCLI.git
cd WorkQueueCLI

# Install globally (requires sudo on macOS/Linux)
make install

# Install to user directory (no sudo required)
make install-user

# Build only (without installing)
make build

# Build for all platforms
make build-all

# Show all available targets
make help
```

### Method 3: Manual Installation

#### Prerequisites
- Go 1.23.2 or later
- Git (for cloning)

#### Steps:

```bash
# 1. Clone the repository
git clone https://github.com/IsaacDSC/WorkQueueCLI.git
cd WorkQueueCLI

# 2. Build the binary
go build -ldflags "-s -w" -o workqueue ./cmd/cli/main.go

# 3. Move to a directory in your PATH
# macOS/Linux:
sudo mv workqueue /usr/local/bin/
# Or for user-only installation:
mkdir -p ~/.local/bin
mv workqueue ~/.local/bin/

# Windows (PowerShell as Administrator):
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\Programs\WorkQueueCLI"
Move-Item workqueue.exe "$env:LOCALAPPDATA\Programs\WorkQueueCLI\"
```

### Method 4: Go Install (From Source)

If you have Go installed, you can install directly from source:

```bash
# Install latest version
go install github.com/IsaacDSC/WorkQueueCLI/cmd/cli@latest

# The binary will be installed as 'cli' in your GOBIN directory
# You might want to create a symlink or alias for 'workqueue'
```

### Method 5: Download Pre-built Binaries

Download pre-built binaries from the GitHub releases page:

1. Go to [GitHub Releases](https://github.com/IsaacDSC/WorkQueueCLI/releases)
2. Download the appropriate binary for your platform:
   - `workqueue-linux-amd64` (Linux 64-bit)
   - `workqueue-linux-arm64` (Linux ARM64)
   - `workqueue-darwin-amd64` (macOS Intel)
   - `workqueue-darwin-arm64` (macOS Apple Silicon)
   - `workqueue-windows-amd64.exe` (Windows 64-bit)
3. Make it executable and move to PATH:

```bash
# macOS/Linux
chmod +x workqueue-*
sudo mv workqueue-* /usr/local/bin/workqueue

# Windows (rename to workqueue.exe and move to a directory in PATH)
```

## Platform-Specific Instructions

### macOS

#### Using Homebrew (if you create a tap):
```bash
# Future: when homebrew tap is available
brew install isacdsc/tap/workqueue-cli
```

#### Manual macOS Installation:
```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh -o install.sh
chmod +x install.sh

# Install globally (requires sudo)
./install.sh

# Or install to user directory
./install.sh --install-dir ~/.local/bin
```

### Linux

#### Ubuntu/Debian:
```bash
# Install dependencies
sudo apt update
sudo apt install -y golang-go git curl

# Run installer
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash
```

#### CentOS/RHEL/Fedora:
```bash
# Install dependencies
sudo yum install -y golang git curl
# or for newer versions:
sudo dnf install -y golang git curl

# Run installer
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash
```

#### Arch Linux:
```bash
# Install dependencies
sudo pacman -S go git curl

# Run installer
curl -fsSL https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.sh | bash
```

### Windows

#### Prerequisites:
- Install Go from https://golang.org/doc/install
- Install Git from https://git-scm.com/downloads

#### PowerShell Installation:
```powershell
# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Download and run installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/IsaacDSC/WorkQueueCLI/main/install.ps1" -OutFile "install.ps1"
.\install.ps1

# Or install to custom directory
.\install.ps1 -InstallDir "C:\Tools\WorkQueueCLI"
```

#### Manual Windows Installation:
```cmd
# Clone repository
git clone https://github.com/IsaacDSC/WorkQueueCLI.git
cd WorkQueueCLI

# Build binary
go build -ldflags "-s -w" -o workqueue.exe .\cmd\cli\main.go

# Move to a directory in PATH (as Administrator)
move workqueue.exe "C:\Program Files\WorkQueueCLI\"
```

## Docker Installation

Run WorkQueueCLI in a Docker container:

```dockerfile
# Create a Dockerfile
FROM golang:1.23.2-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -ldflags "-s -w" -o workqueue ./cmd/cli/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/workqueue .
ENTRYPOINT ["./workqueue"]
```

```bash
# Build and run
docker build -t workqueue-cli .
docker run --rm workqueue-cli event --help

# Or create an alias
echo 'alias workqueue="docker run --rm -v $(pwd):/workspace workqueue-cli"' >> ~/.bashrc
```

## Verification

After installation, verify it works:

```bash
# Check version
workqueue version

# Show help
workqueue --help

# Test basic functionality
workqueue event --help
```

## Uninstallation

### Using the installer scripts:
```bash
# macOS/Linux
./install.sh --uninstall

# Windows
.\install.ps1 -Uninstall
```

### Using Makefile:
```bash
make uninstall
```

### Manual uninstallation:
```bash
# Remove binary
sudo rm /usr/local/bin/workqueue
# or
rm ~/.local/bin/workqueue

# Windows
Remove-Item "$env:LOCALAPPDATA\Programs\WorkQueueCLI\workqueue.exe"
```

## Troubleshooting

### Common Issues:

#### "command not found: workqueue"
- Ensure the installation directory is in your PATH
- Try running `which workqueue` (macOS/Linux) or `where workqueue` (Windows)
- Restart your terminal after installation

#### Permission denied errors:
```bash
# Fix permissions (macOS/Linux)
chmod +x /usr/local/bin/workqueue
```

#### Go version issues:
- Ensure you have Go 1.23.2 or later installed
- Check with `go version`

#### PATH issues on macOS/Linux:
```bash
# Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export PATH="$PATH:/usr/local/bin"
# or for user installation:
export PATH="$PATH:$HOME/.local/bin"
```

#### PATH issues on Windows:
- The installer should handle PATH automatically
- Manually add the installation directory to your PATH in System Environment Variables

### Getting Help:

- Check the main README.md for usage instructions
- Run `workqueue --help` for command help
- Open an issue on [GitHub](https://github.com/IsaacDSC/WorkQueueCLI/issues)

## Development Installation

For development purposes:

```bash
# Clone and setup
git clone https://github.com/IsaacDSC/WorkQueueCLI.git
cd WorkQueueCLI

# Install dependencies
make deps

# Build for development
make dev-build

# Run tests
make test

# Run with live reload (if you have air installed)
air
```
