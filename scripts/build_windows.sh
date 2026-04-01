#!/bin/bash
# =============================================================================
# AuthVault - Windows Build Script
# Builds Windows desktop application
# Copyright 2025-2026 AuthVault Team
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FLUTTER_DIR="$ROOT_DIR/flutter"
CACHE_DIR="$ROOT_DIR/.cache"
DIST_DIR="$ROOT_DIR/dist"

# Use manual Flutter SDK if available
if [ -d "$HOME/sdk/flutter/bin" ]; then
    export PATH="$HOME/sdk/flutter/bin:$PATH"
fi

export PUB_CACHE="$CACHE_DIR/pub"

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Windows Build                                  ║${NC}"
    echo -e "${CYAN}║  Desktop Executable                                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

ensure_cache() {
    mkdir -p "$CACHE_DIR" "$CACHE_DIR/pub" "$CACHE_DIR/build"
}

# =============================================================================
# Setup
# =============================================================================

setup() {
    print_step "Setting up..."

    ensure_cache

    # Check Flutter
    command -v flutter &> /dev/null || { print_error "Flutter not found"; return 1; }
    print_status "Flutter: $(flutter --version 2>&1 | head -1)"

    # Check if running on Windows
    if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "win32" ]]; then
        print_warning "Windows build typically requires Windows host"
        print_info "Cross-compilation may not work properly"
    fi

    # Setup pub cache
    export PUB_CACHE="$CACHE_DIR/pub"
    print_status "Setup complete"
}

# =============================================================================
# Prepare Flutter
# =============================================================================

prepare() {
    cd "$FLUTTER_DIR"

    # Check if deps exist
    if [ -d ".dart_tool/package_config.json" ]; then
        print_status "Dependencies cached"
    else
        flutter clean
        flutter pub get
    fi

    # Codegen if needed
    if [ -z "$(find lib -name '*.g.dart' -type f 2>/dev/null | head -1)" ]; then
        print_step "Running codegen..."
        dart run build_runner build --delete-conflicting-outputs >/dev/null 2>&1 || print_warning "Codegen skipped"
    fi
}

# =============================================================================
# Windows Build
# =============================================================================

build_windows() {
    local flavor="${1:-release}"
    local output="$DIST_DIR/windows"

    print_step "Building Windows ($flavor)..."

    prepare

    # Build
    if flutter build windows --"$flavor" 2>&1 | tee /tmp/build-windows.log; then
        mkdir -p "$output"
        cp "build/windows/${flavor}/bundle/authvault.exe" "$output/" 2>/dev/null || true
        
        if [ -f "$output/authvault.exe" ]; then
            print_status "Windows: $output/authvault.exe"
            
            # Copy additional files
            cp -r "build/windows/${flavor}/bundle/data" "$output/" 2>/dev/null || true
            cp -r "build/windows/${flavor}/bundle/flutter_windows.dll" "$output/" 2>/dev/null || true
        fi
    else
        print_error "Windows build failed"
        return 1
    fi

    print_status "Windows build complete!"
    print_info "Output: $DIST_DIR/windows"
}

# =============================================================================
# Create Installer (Inno Setup)
# =============================================================================

create_installer() {
    local output="$DIST_DIR/windows"
    local version="1.0.0"
    
    print_step "Creating installer..."
    
    # Check for Inno Setup
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        local iscc_path="$(which iscc 2>/dev/null || echo "")"
        if [ -z "$iscc_path" ]; then
            print_warning "Inno Setup Compiler (iscc) not found"
            print_info "Download: https://jrsoftware.org/isdl.php"
            return 0
        fi
        
        # Create ISS script
        cat > "$output/authvault.iss" << EOF
[Setup]
AppName=AuthVault
AppVersion=$version
AppPublisher=AuthVault Team
DefaultDirName={autopf}\\AuthVault
DefaultGroupName=AuthVault
OutputDir=$output\\installer
OutputBaseFilename=AuthVault-Setup-$version
Compression=lzma
SolidCompression=yes

[Files]
Source: "$output\\authvault.exe"; DestDir: "{app}"
Source: "$output\\data\\*"; DestDir: "{app}\\data"; Flags: recursesubdirs
Source: "$output\\flutter_windows.dll"; DestDir: "{app}"

[Icons]
Name: "{group}\\AuthVault"; Filename: "{app}\\authvault.exe"
Name: "{commondesktop}\\AuthVault"; Filename: "{app}\\authvault.exe"

[Run]
Filename: "{app}\\authvault.exe"; Description: "Launch AuthVault"; Flags: nowait postinstall skipifsilent
EOF
        
        # Compile installer
        iscc "$output/authvault.iss" 2>&1 | tee /tmp/installer.log
        [ -f "$output/installer"/*.exe ] && print_status "Installer: $output/installer/*.exe"
    else
        print_warning "Installer creation requires Windows host with Inno Setup"
    fi
}

# =============================================================================
# Create MSIX (Modern Windows Package)
# =============================================================================

create_msix() {
    local output="$DIST_DIR/windows"
    
    print_step "Creating MSIX package..."
    
    cd "$FLUTTER_DIR"
    
    # Check if flutter_msix is available
    if ! flutter pub global list 2>/dev/null | grep -q msix; then
        print_warning "msix not installed. Run: flutter pub global activate msix"
        return 0
    fi
    
    # Create msix_config.yaml if not exists
    if [ ! -f "msix_config.yaml" ]; then
        cat > "msix_config.yaml" << EOF
display_name: AuthVault
publisher_name: AuthVault Team
publisher_display_name: AuthVault
identity_name: AuthVaultTeam.AuthVault
logo_path: assets/icons/icon.png
capabilities: internetClient
EOF
    fi
    
    # Build MSIX
    if flutter pub global run msix:create --output-path "$output" 2>&1 | tee /tmp/msix.log; then
        [ -f "$output"/*.msix ] && print_status "MSIX: $output/*.msix"
    else
        print_warning "MSIX creation failed"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header

    local flavor="${1:-release}"
    local package="${2:-false}"

    setup || exit 1
    build_windows "$flavor"
    
    # Optional packaging
    if [ "$package" = "true" ] || [ "$package" = "installer" ]; then
        echo ""
        create_installer
    fi
    
    if [ "$package" = "msix" ]; then
        echo ""
        create_msix
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Build Complete                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    ls -lh "$DIST_DIR/windows/"*.exe 2>/dev/null || true
    echo ""
}

main "$@"
