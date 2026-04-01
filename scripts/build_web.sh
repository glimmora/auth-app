#!/bin/bash
# =============================================================================
# AuthVault - Web Build Script
# Builds progressive web app (PWA)
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
DIST_DIR="$ROOT_DIR/dist"

# Use manual Flutter SDK if available
if [ -d "$HOME/sdk/flutter/bin" ]; then
    export PATH="$HOME/sdk/flutter/bin:$PATH"
fi

export PUB_CACHE="$CACHE_DIR/pub"
export npm_cache="$CACHE_DIR/npm"

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Web Build                                      ║${NC}"
    echo -e "${CYAN}║  PWA / Static Files                                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }

ensure_cache() {
    mkdir -p "$CACHE_DIR" "$CACHE_DIR/pub" "$CACHE_DIR/npm" "$CACHE_DIR/build"
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

    # Check Node.js
    command -v node &> /dev/null || { print_error "Node.js not found"; return 1; }
    print_status "Node: $(node --version)"

    # Check npm
    command -v npm &> /dev/null || { print_error "npm not found"; return 1; }
    print_status "npm: $(npm --version)"

    # Setup caches
    export PUB_CACHE="$CACHE_DIR/pub"
    npm config set cache "$CACHE_DIR/npm" 2>/dev/null || true
    
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
# Web Build
# =============================================================================

build_web() {
    local flavor="${1:-release}"
    local output="$DIST_DIR/web"
    local base_url="${2:-/}"

    print_step "Building Web ($flavor)..."

    prepare

    # Create output directory
    mkdir -p "$output"

    # Build with Flutter
    print_step "Running Flutter web build..."
    if flutter build web --"$flavor" --base-url="$base_url" 2>&1 | tee /tmp/build-web.log; then
        # Copy build output
        cp -r "build/web/"* "$output/"
        print_status "Web: $output"
        
        # Show build size
        local size=$(du -sh "$output" | cut -f1)
        print_info "Build size: $size"
    else
        print_error "Web build failed"
        return 1
    fi

    print_status "Web build complete!"
}

# =============================================================================
# Build with Custom Options
# =============================================================================

build_web_custom() {
    local output="$DIST_DIR/web"
    local renderer="${1:-canvaskit}"
    local optimization="${2:-O3}"
    
    print_step "Building Web with custom options..."
    print_info "Renderer: $renderer"
    print_info "Optimization: $optimization"
    
    cd "$FLUTTER_DIR"
    
    mkdir -p "$output"
    
    # Build with custom renderer and optimization
    if flutter build web --release \
        --web-renderer="$renderer" \
        --optimization="$optimization" \
        --csp-header="Strict-Transport-Security: max-age=31536000; includeSubDomains" \
        2>&1 | tee /tmp/build-web-custom.log; then
        
        cp -r "build/web/"* "$output/"
        print_status "Web: $output"
        
        local size=$(du -sh "$output" | cut -f1)
        print_info "Build size: $size"
    else
        print_error "Custom web build failed"
        return 1
    fi
}

# =============================================================================
# Generate Service Worker
# =============================================================================

generate_sw() {
    local output="$DIST_DIR/web"
    
    print_step "Generating service worker..."
    
    cd "$FLUTTER_DIR"
    
    # Use Flutter's built-in service worker generation
    if [ -d "build/web" ]; then
        # Check if service worker exists
        if [ -f "build/web/flutter_service_worker.js" ]; then
            cp "build/web/flutter_service_worker.js" "$output/" 2>/dev/null || true
            print_status "Service worker generated"
        else
            print_warning "Service worker not found"
        fi
    fi
}

# =============================================================================
# Deploy Preparation
# =============================================================================

prepare_deploy() {
    local output="$DIST_DIR/web"
    local target="${1:-firebase}"
    
    print_step "Preparing deployment for $target..."
    
    case "$target" in
        firebase)
            # Create firebase.json if not exists
            if [ ! -f "$output/firebase.json" ]; then
                cat > "$output/firebase.json" << 'EOF'
{
  "hosting": {
    "public": ".",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
EOF
            fi
            print_status "Firebase config created"
            print_info "Deploy: firebase deploy --only hosting"
            ;;
        github)
            # Create workflow file
            mkdir -p "$ROOT_DIR/.github/workflows"
            cat > "$ROOT_DIR/.github/workflows/deploy-web.yml" << 'EOF'
name: Deploy Web

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter config --enable-web
      - run: flutter build web --release
      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: build/web
EOF
            print_status "GitHub Pages workflow created"
            ;;
        netlify)
            # Create netlify.toml
            cat > "$output/netlify.toml" << 'EOF'
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "max-age=31536000"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "max-age=31536000"
EOF
            print_status "Netlify config created"
            print_info "Deploy: netlify deploy --prod --dir=dist/web"
            ;;
        *)
            print_warning "Unknown target: $target"
            ;;
    esac
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header

    local flavor="${1:-release}"
    local base_url="${2:-/}"
    local deploy="${3:-false}"

    setup || exit 1
    
    if [ "$flavor" = "custom" ]; then
        build_web_custom "${base_url:-canvaskit}" "${deploy:-O3}"
    else
        build_web "$flavor" "$base_url"
    fi
    
    generate_sw
    
    if [ "$deploy" != "false" ] && [ "$deploy" != "O3" ]; then
        echo ""
        prepare_deploy "$deploy"
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Build Complete                                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    ls -lh "$DIST_DIR/web/" | head -15 || true
    echo ""
    
    # Show how to serve
    print_info "To test locally:"
    echo "    cd $DIST_DIR/web && python3 -m http.server 8080"
    echo "    Or: npx serve $DIST_DIR/web"
    echo ""
}

main "$@"
