#!/bin/bash
# =============================================================================
# AuthVault - Run Script
# Full pipeline: fix → build → test → run
# All operations cached for fastest subsequent runs
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

# Android config
ANDROID_HOME="$HOME/Android"
ANDROID_KEYSTORE="$KEYSTORE_DIR/authvault.keystore"

# Results
declare -A RESULTS

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Run                                            ║${NC}"
    echo -e "${CYAN}║  Full pipeline with caching                                 ║${NC}"
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
    mkdir -p "$CACHE_DIR" "$CACHE_DIR/pub" "$CACHE_DIR/npm"
}

# =============================================================================
# Fix (Wrapper)
# =============================================================================

run_fix() {
    print_step "Running fix (cached)..."
    "$SCRIPT_DIR/fix.sh" all 2>&1 | tail -20
}

# =============================================================================
# Test (Wrapper)
# =============================================================================

run_test() {
    print_step "Running tests (cached)..."
    "$SCRIPT_DIR/test.sh" full 2>&1 | tail -30
}

# =============================================================================
# Build (Wrapper)
# =============================================================================

run_build() {
    local platform="$1"
    local flavor="$2"
    
    print_step "Building $platform ($flavor)..."
    "$SCRIPT_DIR/build.sh" "$platform" "$flavor" 2>&1 | tail -30
}

# =============================================================================
# Run Linux
# =============================================================================

run_linux() {
    print_step "Running Linux app..."
    
    local output="$FLUTTER_DIR/build/outputs/linux/authvault"
    
    if [ -f "$output/authvault" ]; then
        print_info "Starting: $output/authvault"
        "$output/authvault" &
        print_status "App started"
    else
        print_error "Build not found, run: $0 build linux"
        return 1
    fi
}

# =============================================================================
# Run Web Dev
# =============================================================================

run_web() {
    print_step "Starting web dev server..."
    
    cd "$WEB_DIR"
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js not found"
        return 1
    fi
    
    [ ! -d "node_modules" ] && { print_step "Installing..."; npm ci || npm install; }
    
    print_info "Server: http://localhost:5173"
    npm run dev &
    print_status "Web dev server started"
}

# =============================================================================
# Run Web Preview
# =============================================================================

run_web_preview() {
    print_step "Starting web preview..."
    
    cd "$WEB_DIR"
    
    [ ! -d "dist" ] && { print_step "Building..."; npm run build; }
    
    print_info "Preview: http://localhost:4173"
    npm run preview &
    print_status "Web preview started"
}

# =============================================================================
# Summary
# =============================================================================

summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Summary                                                     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for step in "${!RESULTS[@]}"; do
        case "${RESULTS[$step]}" in
            OK) echo -e "  ${GREEN}✓${NC} $step" ;;
            SKIP) echo -e "  ${YELLOW}○${NC} $step" ;;
        esac
    done
    
    echo ""
    [ -d "$CACHE_DIR" ] && print_info "Cache: $(du -sh $CACHE_DIR 2>/dev/null | cut -f1)"
    print_info "All downloads cached for future runs"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header
    
    local mode="${1:-all}"
    local platform="${2:-linux}"
    local flavor="${3:-release}"
    
    ensure_cache
    
    case "$mode" in
        all)
            # Full pipeline
            run_fix
            RESULTS["fix"]="OK"
            echo ""
            
            run_test
            RESULTS["test"]="OK"
            echo ""
            
            run_build "$platform" "$flavor"
            RESULTS["build"]="OK"
            echo ""
            
            if [ "$platform" = "linux" ]; then
                print_info "To run: $0 run linux"
            fi
            ;;
        
        fix)
            run_fix
            RESULTS["fix"]="OK"
            ;;
        
        test)
            run_test
            RESULTS["test"]="OK"
            ;;
        
        build)
            run_build "$platform" "$flavor"
            RESULTS["build"]="OK"
            ;;
        
        run)
            case "$platform" in
                linux) run_linux ;;
                web) run_web ;;
                web-preview) run_web_preview ;;
                *) print_error "Unknown: $platform"; exit 1 ;;
            esac
            RESULTS["run"]="OK"
            ;;
        
        *)
            echo "Usage: $0 [all|fix|test|build|run] [platform] [flavor]"
            echo ""
            echo "Modes:"
            echo "  all          - Full pipeline (fix → test → build)"
            echo "  fix          - Fix issues only"
            echo "  test         - Run tests only"
            echo "  build        - Build only"
            echo "  run          - Run app"
            echo ""
            echo "Platforms:"
            echo "  linux        - Linux desktop"
            echo "  android      - Android (split APKs + AAB)"
            echo "  web          - Web PWA"
            echo "  web-preview  - Web preview server"
            echo ""
            echo "Flavors:"
            echo "  release      - Release build"
            echo "  debug        - Debug build"
            echo ""
            echo "Examples:"
            echo "  $0 all linux release    - Full pipeline for Linux"
            echo "  $0 build android        - Build Android"
            echo "  $0 run web              - Run web dev server"
            echo "  $0 run linux            - Run Linux app"
            exit 1
            ;;
    esac
    
    summary
}

main "$@"
