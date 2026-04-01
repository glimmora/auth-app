#!/bin/bash
# =============================================================================
# AuthVault - Build Script (Wrapper)
# Unified entry point for all platform builds
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

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Build                                          ║${NC}"
    echo -e "${CYAN}║  Multi-platform Build System                                ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

# =============================================================================
# Usage
# =============================================================================

usage() {
    echo "Usage: $0 [platform] [options]"
    echo ""
    echo "Platforms:"
    echo "  all              Build all platforms (default)"
    echo "  android          Android (APK split + AAB)"
    echo "  ubuntu, linux    Linux/Ubuntu desktop"
    echo "  windows          Windows desktop"
    echo "  web              Web (PWA)"
    echo ""
    echo "Options:"
    echo "  release          Build release version (default)"
    echo "  debug            Build debug version"
    echo "  split            Split APKs by ABI (Android, default: true)"
    echo "  nosplit          Universal APK (Android)"
    echo "  package          Create installer/package (Ubuntu/Windows)"
    echo ""
    echo "Examples:"
    echo "  $0                          # Build all platforms (release)"
    echo "  $0 android                  # Android only"
    echo "  $0 android debug            # Android debug"
    echo "  $0 android release nosplit  # Android universal APK"
    echo "  $0 ubuntu package           # Ubuntu with AppImage/DEB"
    echo "  $0 web release /app         # Web with base URL"
    echo ""
    echo "Platform-specific scripts:"
    echo "  ./scripts/build_android.sh [release|debug] [split|nosplit]"
    echo "  ./scripts/build_ubuntu.sh [release|debug] [package]"
    echo "  ./scripts/build_windows.sh [release|debug] [installer|msix]"
    echo "  ./scripts/build_web.sh [release|debug] [base-url] [deploy-target]"
    echo ""
}

# =============================================================================
# Build Functions
# =============================================================================

build_android() {
    local flavor="${1:-release}"
    local split="${2:-true}"
    
    # Convert options
    [ "$flavor" = "nosplit" ] && split="false"
    [ "$flavor" = "split" ] && split="true"
    
    bash "$SCRIPT_DIR/build_android.sh" "$flavor" "$split"
}

build_ubuntu() {
    local flavor="${1:-release}"
    local package="${2:-false}"
    
    bash "$SCRIPT_DIR/build_ubuntu.sh" "$flavor" "$package"
}

build_linux() {
    build_ubuntu "$@"
}

build_windows() {
    local flavor="${1:-release}"
    local package="${2:-false}"
    
    bash "$SCRIPT_DIR/build_windows.sh" "$flavor" "$package"
}

build_web() {
    local flavor="${1:-release}"
    local base_url="${2:-/}"
    local deploy="${3:-false}"
    
    bash "$SCRIPT_DIR/build_web.sh" "$flavor" "$base_url" "$deploy"
}

build_all() {
    local flavor="${1:-release}"
    
    print_step "Building all platforms..."
    echo ""
    
    # Android
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    build_android "$flavor" "true"
    echo ""
    
    # Linux
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    build_ubuntu "$flavor"
    echo ""
    
    # Windows (skip on non-Windows)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
        build_windows "$flavor"
        echo ""
    else
        print_warning "Skipping Windows build (requires Windows host)"
        echo ""
    fi
    
    # Web
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    build_web "$flavor"
    echo ""
    
    print_status "All builds complete!"
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header

    local platform="${1:-all}"
    shift || true
    
    case "$platform" in
        all)
            build_all "$@"
            ;;
        android)
            build_android "$@"
            ;;
        ubuntu|linux)
            build_ubuntu "$@"
            ;;
        windows)
            build_windows "$@"
            ;;
        web)
            build_web "$@"
            ;;
        help|-h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown platform: $platform"
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
