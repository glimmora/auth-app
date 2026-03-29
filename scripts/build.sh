#!/bin/bash
# =============================================================================
# AuthVault - Build Script
# Builds for all platforms with caching
# Android: Split APKs by ABI + AAB (signed if keystore exists)
# Linux, Windows, Web with caching
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

# Sudo password
SUDO_PASS="LO3QERKYFWAVIRZQS7JNHNHKMGCIZTRB"

# Android config - check multiple locations
ANDROID_HOME="${ANDROID_HOME:-$HOME/Android}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android}"
if [ -d "$HOME/Android/Sdk" ]; then
    ANDROID_HOME="$HOME/Android/Sdk"
    ANDROID_SDK_ROOT="$HOME/Android/Sdk"
fi

ANDROID_KEYSTORE="$KEYSTORE_DIR/authvault.keystore"
ANDROID_KEY_ALIAS="authvault"
ANDROID_KEYSTORE_PASS="$KEYSTORE_DIR/.keystore_pass"

# Set paths
export ANDROID_HOME
export ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PUB_CACHE="$CACHE_DIR/pub"

# Results
declare -A RESULTS

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Build                                          ║${NC}"
    echo -e "${CYAN}║  Multi-platform with caching                                ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

sudo_cmd() {
    if echo "$SUDO_PASS" | sudo -S echo "" 2>/dev/null; then
        echo "$SUDO_PASS" | sudo -S "$@" 2>/dev/null
    else
        "$@" 2>/dev/null || true
    fi
}

ensure_cache() {
    mkdir -p "$CACHE_DIR" "$CACHE_DIR/pub" "$CACHE_DIR/npm" "$CACHE_DIR/build"
}

log_result() {
    RESULTS["$1"]="$2"
}

# =============================================================================
# Setup
# =============================================================================

setup() {
    print_step "Setting up (cached)..."
    
    ensure_cache
    
    # Check Flutter
    command -v flutter &> /dev/null || { print_error "Flutter not found. Run: ./scripts/fix.sh all"; return 1; }
    print_status "Flutter: $(flutter --version 2>&1 | head -1)"
    
    # Check Android SDK in multiple locations
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
        print_status "Android SDK: $ANDROID_HOME (cached)"
        # Update PATH
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    else
        print_warning "Android SDK not found"
        print_info "Run: ./scripts/fix.sh sdk"
    fi
    
    # Check Node
    command -v node &> /dev/null && print_status "Node: $(node --version)" || print_warning "Node not found"
    
    # Setup caches
    export PUB_CACHE="$CACHE_DIR/pub"
    command -v node &> /dev/null && npm config set cache "$CACHE_DIR/npm" 2>/dev/null || true
    
    # Install Linux deps
    sudo_cmd apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev unzip >/dev/null 2>&1 || true
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
    local output="$FLUTTER_DIR/build/outputs/linux"
    
    print_step "Building Linux ($flavor)..."
    
    # Check cache
    if [ -f "$output/authvault/authvault" ]; then
        print_status "Linux build cached"
        log_result "linux" "CACHED"
        return 0
    fi
    
    prepare
    flutter build linux --"$flavor" 2>&1 | tee /tmp/build-linux.log || {
        log_result "linux" "FAILED"
        return 1
    }
    
    mkdir -p "$output"
    cp -r "build/linux/x64/${flavor}/bundle" "$output/authvault"
    print_status "Linux: $output/authvault"
    log_result "linux" "OK"
}

# =============================================================================
# Windows Build
# =============================================================================

build_windows() {
    local flavor="${1:-release}"
    local output="$FLUTTER_DIR/build/outputs/windows"
    
    print_step "Building Windows ($flavor)..."
    
    # Windows requires Windows host
    if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "win32" ]]; then
        print_warning "Windows build requires Windows host - skipping"
        log_result "windows" "SKIP"
        return 0
    fi
    
    # Check cache
    if [ -f "$output/authvault.exe" ]; then
        print_status "Windows build cached"
        log_result "windows" "CACHED"
        return 0
    fi
    
    prepare
    flutter build windows --"$flavor" 2>&1 | tee /tmp/build-windows.log || {
        log_result "windows" "FAILED"
        return 1
    }
    
    mkdir -p "$output"
    cp "build/windows/${flavor}/bundle/authvault.exe" "$output/" 2>/dev/null || true
    [ -f "$output/authvault.exe" ] && print_status "Windows: $output/authvault.exe"
    log_result "windows" "OK"
}

# =============================================================================
# Android Build
# =============================================================================

build_android() {
    local flavor="${1:-release}"
    local split="${2:-true}"
    local output="$FLUTTER_DIR/build/outputs/android"
    
    print_step "Building Android ($flavor)..."
    
    # Check cache
    if [ -n "$(ls $output/*.apk 2>/dev/null | head -1)" ]; then
        print_status "Android build cached"
        log_result "android" "CACHED"
        return 0
    fi
    
    prepare
    
    # Check Android SDK
    if [ ! -d "$ANDROID_HOME" ]; then
        print_error "Android SDK not found. Run: ./scripts/fix.sh sdk"
        log_result "android" "FAILED"
        return 1
    fi
    
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
            print_warning "Split APK build failed"
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
    
    log_result "android" "OK"
}

# =============================================================================
# Web Build
# =============================================================================

build_web() {
    print_step "Building Web..."
    
    cd "$WEB_DIR"
    
    # Check Node
    command -v node &> /dev/null || {
        print_warning "Node not found, skipping web"
        log_result "web" "SKIP"
        return 0
    }
    
    # Check cache
    if [ -d "dist" ] && [ -n "$(ls -A dist 2>/dev/null)" ]; then
        print_status "Web build cached"
        log_result "web" "CACHED"
        return 0
    fi
    
    ensure_cache
    npm config set cache "$CACHE_DIR/npm"
    
    # Install deps if needed
    if [ ! -d "node_modules" ]; then
        print_step "Installing deps..."
        npm ci 2>&1 | tail -5 || npm install 2>&1 | tail -5
    fi
    
    # Build with npm run build
    print_step "Running npm run build..."
    if npm run build 2>&1 | tee /tmp/build-web.log; then
        print_status "Web: $WEB_DIR/dist"
        log_result "web" "OK"
    else
        log_result "web" "FAILED"
        return 1
    fi
}

# =============================================================================
# Summary
# =============================================================================

summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Build Summary                                               ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for platform in "${!RESULTS[@]}"; do
        case "${RESULTS[$platform]}" in
            OK) echo -e "  ${GREEN}✓${NC} $platform: ${RESULTS[$platform]}" ;;
            CACHED) echo -e "  ${GREEN}✓${NC} $platform: ${RESULTS[$platform]}" ;;
            FAILED) echo -e "  ${RED}✗${NC} $platform: ${RESULTS[$platform]}" ;;
            SKIP) echo -e "  ${YELLOW}○${NC} $platform: ${RESULTS[$platform]}" ;;
        esac
    done
    
    echo ""
    [ -d "$CACHE_DIR" ] && print_info "Cache: $(du -sh $CACHE_DIR 2>/dev/null | cut -f1)"
    print_info "All builds cached - subsequent builds are faster"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header
    
    local platform="${1:-all}"
    local flavor="${2:-release}"
    local split="${3:-true}"
    
    setup || exit 1
    
    case "$platform" in
        all)
            build_linux "$flavor"
            echo ""
            build_android "$flavor" "$split"
            echo ""
            build_windows "$flavor"
            echo ""
            build_web
            ;;
        linux) build_linux "$flavor" ;;
        android) build_android "$flavor" "$split" ;;
        windows) build_windows "$flavor" ;;
        web) build_web ;;
        *)
            echo "Usage: $0 [all|linux|android|windows|web] [release|debug] [split:true|false]"
            echo ""
            echo "Examples:"
            echo "  $0 all                    # Build all platforms"
            echo "  $0 android release        # Android release with split APKs"
            echo "  $0 android debug false    # Android debug universal APK"
            echo "  $0 web                    # Web only"
            exit 1
            ;;
    esac
    
    summary
}

main "$@"
