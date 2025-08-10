# WorkQueueCLI PowerShell Installer
# This script installs WorkQueueCLI globally on Windows systems

param(
    [Parameter(Mandatory=$false)]
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\WorkQueueCLI",
    
    [Parameter(Mandatory=$false)]
    [switch]$Uninstall = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help = $false
)

# Colors for output (Windows PowerShell compatible)
$colors = @{
    Red = "Red"
    Green = "Green" 
    Yellow = "Yellow"
    Blue = "Blue"
    White = "White"
}

function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [string]$Prefix = ""
    )
    
    if ($Prefix) {
        Write-Host "[$Prefix] " -ForegroundColor $Color -NoNewline
    }
    Write-Host $Message -ForegroundColor White
}

function Write-Status {
    param([string]$Message)
    Write-ColoredOutput -Message $Message -Color $colors.Blue -Prefix "INFO"
}

function Write-Success {
    param([string]$Message)
    Write-ColoredOutput -Message $Message -Color $colors.Green -Prefix "SUCCESS"
}

function Write-Warning {
    param([string]$Message)
    Write-ColoredOutput -Message $Message -Color $colors.Yellow -Prefix "WARNING"
}

function Write-Error {
    param([string]$Message)
    Write-ColoredOutput -Message $Message -Color $colors.Red -Prefix "ERROR"
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Show-Help {
    Write-Host "WorkQueueCLI Windows Installer" -ForegroundColor $colors.Blue
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -InstallDir <path>  Custom installation directory"
    Write-Host "                      (default: $env:LOCALAPPDATA\Programs\WorkQueueCLI)"
    Write-Host "  -Uninstall          Uninstall WorkQueueCLI"
    Write-Host "  -Help               Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\install.ps1                                    # Install WorkQueueCLI"
    Write-Host "  .\install.ps1 -InstallDir C:\Tools\WorkQueueCLI  # Install to custom directory"
    Write-Host "  .\install.ps1 -Uninstall                         # Uninstall WorkQueueCLI"
}

function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    if (-not (Test-CommandExists "go")) {
        Write-Error "Go is not installed. Please install Go 1.23.2 or later."
        Write-Status "Visit https://golang.org/doc/install for installation instructions."
        exit 1
    }
    
    $goVersion = (go version) -replace "go version go", "" -replace " .*", ""
    Write-Success "Go $goVersion is installed"
    
    if (-not (Test-CommandExists "git")) {
        Write-Error "Git is not installed. Please install Git."
        Write-Status "Visit https://git-scm.com/downloads for installation instructions."
        exit 1
    }
    
    Write-Success "Git is installed"
}

function Install-FromSource {
    Write-Status "Installing WorkQueueCLI from source..."
    
    $binaryName = "workqueue.exe"
    $repoUrl = "https://github.com/IsaacDSC/WorkQueueCLI"
    
    # Check if we're in the project directory
    if ((Test-Path "go.mod") -and (Test-Path "cmd\cli\main.go")) {
        Write-Status "Installing from current directory..."
        
        # Build the binary
        Write-Status "Building binary..."
        & go build -ldflags "-s -w" -o $binaryName .\cmd\cli\main.go
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to build binary"
            exit 1
        }
    }
    else {
        Write-Status "Cloning repository..."
        
        # Create temporary directory
        $tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        try {
            Set-Location $tempDir
            
            # Clone repository
            & git clone $repoUrl .
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to clone repository"
                exit 1
            }
            
            # Build the binary
            Write-Status "Building binary..."
            & go build -ldflags "-s -w" -o $binaryName .\cmd\cli\main.go
            
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to build binary"
                exit 1
            }
        }
        finally {
            # Return to original directory and cleanup
            Set-Location $PSScriptRoot
            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # Create installation directory
    Write-Status "Creating installation directory: $InstallDir"
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    
    # Move binary to install directory
    $targetPath = Join-Path $InstallDir $binaryName
    if (Test-Path $binaryName) {
        Move-Item $binaryName $targetPath -Force
        Write-Success "Binary installed to: $targetPath"
    }
    else {
        Write-Error "Binary not found after build"
        exit 1
    }
}

function Add-ToPath {
    Write-Status "Adding installation directory to PATH..."
    
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    
    # Check if already in PATH
    if ($currentPath -split ";" -contains $InstallDir) {
        Write-Warning "Installation directory is already in PATH"
        return
    }
    
    # Add to PATH
    $newPath = if ($currentPath) { "$currentPath;$InstallDir" } else { $InstallDir }
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
    
    # Update current session PATH
    $env:Path = "$env:Path;$InstallDir"
    
    Write-Success "Installation directory added to PATH"
    Write-Warning "You may need to restart your terminal for PATH changes to take effect"
}

function Test-Installation {
    Write-Status "Verifying installation..."
    
    $binaryPath = Join-Path $InstallDir "workqueue.exe"
    
    if (Test-Path $binaryPath) {
        Write-Success "WorkQueueCLI installed successfully!"
        Write-Status "Installation path: $binaryPath"
        Write-Status ""
        Write-Status "Usage examples:"
        Write-Status "  workqueue event add-event --name `"My Event`" --serviceName `"my-service`" --repoUrl `"https://github.com/example/repo`""
        Write-Status "  workqueue event add-consumer --json_file .\consumer.json"
        Write-Status "  workqueue event test-producer --json_file .\payload.json"
    }
    else {
        Write-Error "Installation verification failed. Binary not found at $binaryPath"
        exit 1
    }
}

function Uninstall-WorkQueueCLI {
    Write-Status "Uninstalling WorkQueueCLI..."
    
    $binaryPath = Join-Path $InstallDir "workqueue.exe"
    
    if (Test-Path $binaryPath) {
        Remove-Item $binaryPath -Force
        Write-Success "Binary removed: $binaryPath"
    }
    else {
        Write-Warning "Binary not found at: $binaryPath"
    }
    
    # Remove from PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    if ($currentPath -split ";" -contains $InstallDir) {
        $newPath = ($currentPath -split ";" | Where-Object { $_ -ne $InstallDir }) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
        Write-Success "Removed from PATH"
    }
    
    # Remove directory if empty
    if ((Test-Path $InstallDir) -and ((Get-ChildItem $InstallDir).Count -eq 0)) {
        Remove-Item $InstallDir -Force
        Write-Success "Removed installation directory: $InstallDir"
    }
    
    Write-Success "WorkQueueCLI uninstalled successfully!"
}

function Main {
    Write-Host "╔══════════════════════════════════════════════╗" -ForegroundColor $colors.Blue
    Write-Host "║            WorkQueueCLI Installer            ║" -ForegroundColor $colors.Blue
    Write-Host "║                 (Windows)                    ║" -ForegroundColor $colors.Blue
    Write-Host "╚══════════════════════════════════════════════╝" -ForegroundColor $colors.Blue
    Write-Host ""
    
    if ($Help) {
        Show-Help
        return
    }
    
    if ($Uninstall) {
        Uninstall-WorkQueueCLI
        return
    }
    
    # Check if already installed
    $binaryPath = Join-Path $InstallDir "workqueue.exe"
    if (Test-Path $binaryPath) {
        Write-Warning "WorkQueueCLI is already installed at: $binaryPath"
        $response = Read-Host "Do you want to reinstall? [y/N]"
        if ($response -notmatch "^[Yy]$") {
            Write-Status "Installation cancelled."
            return
        }
    }
    
    Test-Prerequisites
    Install-FromSource
    Add-ToPath
    Test-Installation
    
    Write-Success "Installation completed!"
    Write-Status ""
    Write-Status "Next steps:"
    Write-Status "1. Restart your terminal or PowerShell session"
    Write-Status "2. Run 'workqueue event --help' to see available commands"
    Write-Status "3. Check the README.md for usage examples"
}

# Run main function
Main
