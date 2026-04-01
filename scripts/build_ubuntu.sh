#!/bin/bash
# =============================================================================
# AuthVault - Linux (Ubuntu) Build Script
# Builds Linux desktop application
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

# Use manual Flutter SDK if available (avoids snap issues)
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
    echo -e "${CYAN}║  AuthVault - Linux Build                                    ║${NC}"
    echo -e "${CYAN}║  Ubuntu/Desktop                                             ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

sudo_cmd() {
    sudo "$@"
}

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
    command -v flutter &> /dev/null || { print_error "Flutter not found. Run: ./scripts/fix.sh all"; return 1; }
    print_status "Flutter: $(flutter --version 2>&1 | head -1)"

    # Install Linux dependencies
    print_step "Installing Linux dependencies..."
    sudo_cmd apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev unzip lld >/dev/null 2>&1 || {
        print_warning "Some dependencies may be missing"
    }

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
# Linux Build
# =============================================================================

build_linux() {
    local flavor="${1:-release}"
    local output="$DIST_DIR/linux"

    print_step "Building Linux ($flavor)..."

    prepare

    # Build
    if flutter build linux --"$flavor" 2>&1 | tee /tmp/build-linux.log; then
        mkdir -p "$output"
        cp -r "build/linux/x64/${flavor}/bundle" "$output/authvault"
        print_status "Linux: $output/authvault"
    else
        print_error "Linux build failed"
        return 1
    fi

    print_status "Linux build complete!"
    print_info "Output: $DIST_DIR/linux"
}

# =============================================================================
# Create AppImage (optional)
# =============================================================================

create_appimage() {
    local output="$DIST_DIR/linux"
    
    print_step "Creating AppImage..."
    
    # Check if linuxdeploy is available
    if ! command -v linuxdeploy &> /dev/null; then
        print_warning "linuxdeploy not found, skipping AppImage creation"
        print_info "Install: wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
        return 0
    fi
    
    cd "$output/authvault"
    
    # Create AppDir structure
    mkdir -p AppDir/usr/bin
    mkdir -p AppDir/usr/lib
    mkdir -p AppDir/usr/share/icons/hicolor/512x512/apps
    
    cp authvault AppDir/usr/bin/
    cp -r data/flutter_assets AppDir/usr/lib/ 2>/dev/null || true
    cp -r data/icudtl.dat AppDir/usr/lib/ 2>/dev/null || true
    
    # Create desktop file
    cat > AppDir/authvault.desktop << 'EOF'
[Desktop Entry]
Name=AuthVault
Comment=Secure 2FA Authenticator
Exec=authvault
Icon=authvault
Type=Application
Categories=Utility;Security;
EOF
    
    # Create AppRun
    cat > AppDir/AppRun << 'EOF'
#!/bin/sh
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
exec "${HERE}/usr/bin/authvault" "$@"
EOF
    chmod +x AppDir/AppRun
    
    # Build AppImage
    if linuxdeploy --appdir AppDir --output appimage 2>&1 | tee /tmp/appimage.log; then
        mv *.AppImage "$output/" 2>/dev/null || true
        [ -f "$output"/*.AppImage ] && print_status "AppImage: $output/*.AppImage"
    else
        print_warning "AppImage creation failed"
    fi
}

# =============================================================================
# Create DEB Package (optional)
# =============================================================================

create_deb() {
    local output="$DIST_DIR/linux"
    local version="1.0.0"
    
    print_step "Creating DEB package..."
    
    # Create package structure
    local pkg_name="authvault_${version}_amd64"
    local pkg_dir="$output/$pkg_name"
    
    mkdir -p "$pkg_dir/DEBIAN"
    mkdir -p "$pkg_dir/usr/bin"
    mkdir -p "$pkg_dir/usr/share/authvault"
    mkdir -p "$pkg_dir/usr/share/applications"
    mkdir -p "$pkg_dir/usr/share/icons/hicolor/512x512/apps"
    
    # Create control file
    cat > "$pkg_dir/DEBIAN/control" << EOF
Package: authvault
Version: $version
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libblkid1, liblzma5
Maintainer: AuthVault Team
Description: Secure 2FA Authenticator
 A secure two-factor authenticator app with TOTP/HOTP support.
EOF
    
    # Copy files
    cp "$output/authvault/authvault" "$pkg_dir/usr/bin/"
    cp -r "$output/authvault/data" "$pkg_dir/usr/share/authvault/"
    
    # Create desktop file
    cat > "$pkg_dir/usr/share/applications/authvault.desktop" << 'EOF'
[Desktop Entry]
Name=AuthVault
Comment=Secure 2FA Authenticator
Exec=/usr/bin/authvault
Icon=authvault
Type=Application
Categories=Utility;Security;
EOF
    
    # Build DEB
    cd "$output"
    if command -v dpkg-deb &> /dev/null; then
        dpkg-deb --build "$pkg_dir" 2>&1 | tee /tmp/deb.log
        [ -f "$pkg_dir.deb" ] && print_status "DEB: $pkg_dir.deb"
    else
        print_warning "dpkg-deb not found"
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
    build_linux "$flavor"
    
    # Optional packaging
    if [ "$package" = "true" ] || [ "$package" = "appimage" ]; then
        echo ""
        create_appimage
    fi
    
    if [ "$package" = "true" ] || [ "$package" = "deb" ]; then
        echo ""
        create_deb
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Build Complete                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    ls -lh "$DIST_DIR/linux/authvault/" 2>/dev/null | head -10 || true
    echo ""
}

main "$@"
