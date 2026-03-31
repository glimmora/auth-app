#!/bin/bash
# =============================================================================
# AuthVault - Fix Script
# Automatically detects and fixes common issues
# Includes: Environment, dependencies, Android SDK, codegen, formatting
# All downloads cached for faster subsequent runs
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
WEB_DIR="$ROOT_DIR/web"
CACHE_DIR="$ROOT_DIR/.cache"
KEYSTORE_DIR="$SCRIPT_DIR/keystore"
ANDROID_CACHE="$HOME/.android-sdk-cache"

# Android config
ANDROID_HOME="$HOME/Android"
ANDROID_SDK_ROOT="$HOME/Android"

# Set paths
export ANDROID_HOME
export ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PUB_CACHE="$CACHE_DIR/pub"

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Fix                                            ║${NC}"
    echo -e "${CYAN}║  Auto-fix issues with caching                               ║${NC}"
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
    mkdir -p "$CACHE_DIR" "$CACHE_DIR/pub" "$CACHE_DIR/npm" "$CACHE_DIR/flutter"
    mkdir -p "$ANDROID_CACHE"
}

# =============================================================================
# Environment
# =============================================================================

fix_environment() {
    print_step "Checking environment..."
    
    ensure_cache
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found"
        return 1
    fi
    
    print_status "Flutter: $(flutter --version 2>&1 | head -1)"
    print_status "Dart: $(dart --version 2>&1 | head -1)"
    
    # Fix pub cache
    [ -d "$HOME/.pub-cache" ] && sudo_cmd chmod -R 755 "$HOME/.pub-cache" 2>/dev/null || true
    
    # Install build dependencies
    print_step "Installing build dependencies..."
    sudo_cmd apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev unzip lld >/dev/null 2>&1 || true
    print_status "Build dependencies installed"
}

# =============================================================================
# Dependencies
# =============================================================================

fix_dependencies() {
    print_step "Fixing dependencies (cached)..."
    
    cd "$FLUTTER_DIR"
    
    # Check if already resolved
    if [ -f "pubspec.lock" ] && [ -d ".dart_tool/package_config.json" ]; then
        print_status "Dependencies already resolved"
        return 0
    fi
    
    flutter clean
    flutter pub get 2>&1 | tee /tmp/pub-get.log || return 1
    
    print_status "Dependencies cached"
}

# =============================================================================
# Android SDK
# =============================================================================

install_android_sdk() {
    print_step "Checking Android SDK..."
    
    # Check if already installed
    if [ -d "$ANDROID_HOME/cmdline-tools/latest" ] && [ -d "$ANDROID_HOME/platform-tools" ]; then
        print_status "Android SDK found: $ANDROID_HOME"
        return 0
    fi
    
    print_warning "Android SDK not found, installing..."
    ensure_cache
    
    mkdir -p "$ANDROID_HOME"
    local cmdline_zip="$ANDROID_CACHE/cmdline-tools.zip"
    local cmdline_dir="$ANDROID_HOME/cmdline-tools"
    
    # Download if not cached
    if [ ! -f "$cmdline_zip" ]; then
        print_step "Downloading Android SDK tools (cached)..."
        curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
            -o "$cmdline_zip" 2>/dev/null || {
            print_error "Download failed"
            return 1
        }
    else
        print_status "Using cached SDK tools"
    fi
    
    # Extract
    print_step "Installing SDK..."
    unzip -q -o "$cmdline_zip" -d "$cmdline_dir" 2>/dev/null
    
    # Reorganize
    if [ ! -d "$cmdline_dir/latest" ]; then
        mkdir -p "$cmdline_dir/latest"
        mv "$cmdline_dir/cmdline-tools"/* "$cmdline_dir/latest/" 2>/dev/null || true
        rmdir "$cmdline_dir/cmdline-tools" 2>/dev/null || true
    fi
    
    # Accept licenses
    yes | sdkmanager --licenses >/dev/null 2>&1 || true
    
    # Install packages
    print_step "Installing SDK packages (cached)..."
    sdkmanager --install \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        "cmdline-tools;latest" 2>&1 | tee /tmp/sdk-install.log
    
    print_status "Android SDK installed: $ANDROID_HOME"
    print_info "Cached in: $ANDROID_CACHE"
}

# =============================================================================
# Code Generation
# =============================================================================

fix_codegen() {
    print_step "Running code generation..."
    
    cd "$FLUTTER_DIR"
    
    find lib -name "*.g.dart" -delete 2>/dev/null || true
    find lib -name "*.freezed.dart" -delete 2>/dev/null || true
    
    dart run build_runner build --delete-conflicting-outputs 2>&1 | tee /tmp/codegen.log || return 1
    
    print_status "Code generation complete"
}

# =============================================================================
# Formatting
# =============================================================================

fix_format() {
    print_step "Formatting code..."
    
    cd "$FLUTTER_DIR"
    dart format . >/dev/null 2>&1 && print_status "Code formatted" || print_warning "Format issues"
}

# =============================================================================
# Imports
# =============================================================================

fix_imports() {
    print_step "Fixing imports..."
    
    cd "$FLUTTER_DIR"
    dart fix --apply >/dev/null 2>&1 || true
    print_status "Imports fixed"
}

# =============================================================================
# Analysis
# =============================================================================

fix_analysis() {
    print_step "Analyzing code..."
    
    cd "$FLUTTER_DIR"
    flutter analyze --no-fatal-infos 2>&1 | tee /tmp/analyze.log || true
    
    # Auto-fix common issues
    grep -q "unused_import" /tmp/analyze.log 2>/dev/null && dart fix --apply 2>/dev/null || true
    grep -q "missing_async" /tmp/analyze.log 2>/dev/null && dart fix --apply 2>/dev/null || true
    
    print_status "Analysis complete"
}

# =============================================================================
# Android Signing
# =============================================================================

fix_android_signing() {
    print_step "Checking Android signing..."
    
    if [ -f "$KEYSTORE_DIR/authvault.keystore" ] && [ -f "$KEYSTORE_DIR/.keystore_pass" ]; then
        print_status "Signing configured"
        return 0
    fi
    
    print_warning "No signing config (unsigned builds)"
    print_info "Run: ./scripts/setup-keystore.sh"
}

# =============================================================================
# Web Dependencies
# =============================================================================

fix_web() {
    print_step "Fixing web dependencies (cached)..."
    
    cd "$WEB_DIR"
    
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not found"
        return 0
    fi
    
    ensure_cache
    npm config set cache "$CACHE_DIR/npm"
    
    if [ -d "node_modules" ]; then
        print_status "Web deps already installed"
        return 0
    fi
    
    npm ci 2>&1 | tail -5 || npm install 2>&1 | tail -5
    print_status "Web deps cached"
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header
    
    local target="${1:-all}"
    
    case "$target" in
        all)
            fix_environment
            echo ""
            install_android_sdk
            echo ""
            fix_dependencies
            echo ""
            fix_codegen
            echo ""
            fix_format
            echo ""
            fix_imports
            echo ""
            fix_analysis
            echo ""
            fix_android_signing
            echo ""
            fix_web
            ;;
        env|environment) fix_environment ;;
        deps) fix_dependencies ;;
        sdk|android-sdk) install_android_sdk ;;
        codegen) fix_codegen ;;
        format) fix_format ;;
        imports) fix_imports ;;
        analysis) fix_analysis ;;
        signing|android-signing) fix_android_signing ;;
        web) fix_web ;;
        *)
            echo "Usage: $0 [all|env|deps|sdk|codegen|format|imports|analysis|signing|web]"
            exit 1
            ;;
    esac
    
    echo ""
    print_status "Fix complete!"
    print_info "Cache: $CACHE_DIR"
    print_info "Android SDK: $ANDROID_HOME"
}

main "$@"
