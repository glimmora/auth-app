#!/bin/bash
# =============================================================================
# AuthVault - Android Build Script
# Builds Android APKs (split by ABI) + AAB
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
KEYSTORE_DIR="$SCRIPT_DIR/keystore"
DIST_DIR="$ROOT_DIR/dist"

# Android config - check multiple locations
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android}"
if [ -d "$HOME/Android/Sdk" ]; then
    ANDROID_HOME="$HOME/Android/Sdk"
    ANDROID_SDK_ROOT="$HOME/Android/Sdk"
fi

# Use manual Flutter SDK if available (avoids snap issues)
if [ -d "$HOME/sdk/flutter/bin" ]; then
    export PATH="$HOME/sdk/flutter/bin:$PATH"
fi

ANDROID_KEYSTORE="$KEYSTORE_DIR/authvault.keystore"
ANDROID_KEY_ALIAS="authvault"
ANDROID_KEYSTORE_PASS="$KEYSTORE_DIR/.keystore_pass"

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
    echo -e "${CYAN}║  AuthVault - Android Build                                  ║${NC}"
    echo -e "${CYAN}║  Split APKs + AAB                                           ║${NC}"
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
    command -v flutter &> /dev/null || { print_error "Flutter not found. Run: ./scripts/fix.sh all"; return 1; }
    print_status "Flutter: $(flutter --version 2>&1 | head -1)"

    # Check Android SDK
    local sdk_found=false
    if [ -d "$ANDROID_HOME" ]; then
        sdk_found=true
    elif [ -d "$ANDROID_SDK_ROOT" ]; then
        sdk_found=true
    elif [ -d "$HOME/Android" ]; then
        ANDROID_HOME="$HOME/Android"
        ANDROID_SDK_ROOT="$HOME/Android"
        export ANDROID_HOME ANDROID_SDK_ROOT
        sdk_found=true
    fi

    if [ "$sdk_found" = true ]; then
        print_status "Android SDK: $ANDROID_HOME"
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    else
        print_error "Android SDK not found"
        print_info "Run: ./scripts/fix.sh sdk"
        return 1
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
# Android Build
# =============================================================================

build_android() {
    local flavor="${1:-release}"
    local split="${2:-true}"
    local output="$DIST_DIR/android"

    print_step "Building Android ($flavor)..."

    prepare

    # Signing config
    local sign_args=""
    if [ -f "$ANDROID_KEYSTORE" ] && [ -f "$ANDROID_KEYSTORE_PASS" ]; then
        local pass=$(cat "$ANDROID_KEYSTORE_PASS")
        sign_args="-PstoreFile=$ANDROID_KEYSTORE -PstorePassword=$pass -PkeyAlias=$ANDROID_KEY_ALIAS -PkeyPassword=$pass"
        print_status "Signing configured"
    else
        print_warning "Unsigned build (run ./scripts/setup-keystore.sh)"
    fi

    mkdir -p "$output"

    # Split APKs by ABI
    if [ "$split" = "true" ]; then
        print_step "Building split APKs (armeabi-v7a, arm64-v8a, x86_64)..."
        if flutter build apk --"$flavor" --split-per-abi $sign_args 2>&1 | tee /tmp/build-apk.log; then
            cp build/app/outputs/flutter-apk/*-*.apk "$output/" 2>/dev/null || true
            local apk_count=$(ls -1 "$output"/*-*.apk 2>/dev/null | wc -l)
            print_status "Split APKs: $apk_count files"
            ls -lh "$output"/*.apk 2>/dev/null | while read line; do echo "    $line"; done
        else
            print_error "Split APK build failed"
            return 1
        fi
    else
        # Universal APK
        print_step "Building universal APK..."
        if flutter build apk --"$flavor" $sign_args 2>&1 | tee /tmp/build-apk.log; then
            cp build/app/outputs/flutter-apk/*.apk "$output/app-universal-release.apk" 2>/dev/null || true
            [ -f "$output/app-universal-release.apk" ] && print_status "Universal APK: $output/app-universal-release.apk"
        else
            print_error "Universal APK build failed"
            return 1
        fi
    fi

    # AAB (Android App Bundle for Play Store)
    print_step "Building AAB..."
    if flutter build appbundle --"$flavor" $sign_args 2>&1 | tee /tmp/build-aab.log; then
        cp build/app/outputs/bundle/"${flavor}"App/*.aab "$output/" 2>/dev/null || true
        [ -f "$output"/*.aab ] && print_status "AAB: $output/*.aab"
    else
        print_warning "AAB build failed"
    fi

    print_status "Android build complete!"
    print_info "Output: $DIST_DIR/android"
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header

    local flavor="${1:-release}"
    local split="${2:-true}"
    
    # Handle "split" and "nosplit" as first argument too
    if [ "$flavor" = "split" ]; then
        flavor="release"
        split="true"
    elif [ "$flavor" = "nosplit" ]; then
        flavor="release"
        split="false"
    fi

    setup || exit 1
    build_android "$flavor" "$split"

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Build Complete                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    ls -lh "$DIST_DIR/android/"*.apk 2>/dev/null || true
    ls -lh "$DIST_DIR/android/"*.aab 2>/dev/null || true
    echo ""
}

main "$@"
