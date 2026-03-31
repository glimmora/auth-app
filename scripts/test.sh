#!/bin/bash
# =============================================================================
# AuthVault - Test Script
# Comprehensive testing with result caching
# Unit, Widget, Integration, Security, Web tests
# Results cached for 1 hour for faster subsequent runs
# Copyright 2025-2026 AuthVault Team
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FLUTTER_DIR="$ROOT_DIR/flutter"
WEB_DIR="$ROOT_DIR/web"
CACHE_DIR="$ROOT_DIR/.cache"

# Results
declare -A RESULTS
PASSED=0
FAILED=0

# Cache TTL (1 hour = 3600 seconds)
CACHE_TTL=3600

# =============================================================================
# Helpers
# =============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  AuthVault - Test                                           ║${NC}"
    echo -e "${CYAN}║  Comprehensive testing with caching                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_step() { echo -e "${CYAN}▸${NC} $1"; }
print_test() { echo -e "${MAGENTA}◆${NC} $1"; }

sudo_cmd() {
    sudo "$@"
}

ensure_cache() {
    mkdir -p "$CACHE_DIR/test"
}

check_cache() {
    local cache_file="$CACHE_DIR/test/$1.result"
    if [ -f "$cache_file" ]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [ $age -lt $CACHE_TTL ]; then
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

save_cache() {
    local name="$1"
    local result="$2"
    echo "$result" > "$CACHE_DIR/test/$name.result"
}

log_result() {
    RESULTS["$1"]="$2"
    [ "$2" = "PASS" ] && ((PASSED++)) || ((FAILED++))
}

# =============================================================================
# Setup
# =============================================================================

setup() {
    print_step "Setting up test environment..."
    
    ensure_cache
    
    cd "$FLUTTER_DIR"
    
    # Check cache
    if [ -d ".dart_tool/package_config.json" ]; then
        print_status "Dependencies ready"
        return 0
    fi
    
    flutter clean
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs >/dev/null 2>&1 || true
}

# =============================================================================
# Analysis
# =============================================================================

test_analysis() {
    print_test "Running analysis..."
    
    if check_cache "analysis"; then
        print_status "Analysis cached"
        log_result "analysis" "CACHED"
        return 0
    fi
    
    cd "$FLUTTER_DIR"
    
    if flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 | tee /tmp/analyze.log; then
        print_status "Analysis passed"
        save_cache "analysis" "PASS"
        log_result "analysis" "PASS"
    else
        print_warning "Analysis issues found"
        save_cache "analysis" "WARN"
        log_result "analysis" "WARN"
    fi
}

# =============================================================================
# Format
# =============================================================================

test_format() {
    print_test "Checking format..."
    
    if check_cache "format"; then
        print_status "Format cached"
        log_result "format" "CACHED"
        return 0
    fi
    
    cd "$FLUTTER_DIR"
    
    if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
        print_status "Format OK"
        save_cache "format" "PASS"
        log_result "format" "PASS"
    else
        print_warning "Format issues"
        save_cache "format" "WARN"
        log_result "format" "WARN"
    fi
}

# =============================================================================
# Unit Tests
# =============================================================================

test_unit() {
    print_test "Running unit tests..."
    
    if check_cache "unit"; then
        print_status "Unit tests cached"
        log_result "unit" "CACHED"
        return 0
    fi
    
    cd "$FLUTTER_DIR"
    
    if flutter test --coverage 2>&1 | tee /tmp/unit.log; then
        print_status "Unit tests passed"
        save_cache "unit" "PASS"
        log_result "unit" "PASS"
        cp coverage/lcov.info "$CACHE_DIR/" 2>/dev/null || true
    else
        print_error "Unit tests failed"
        save_cache "unit" "FAIL"
        log_result "unit" "FAIL"
    fi
}

# =============================================================================
# Widget Tests
# =============================================================================

test_widget() {
    print_test "Running widget tests..."
    
    if check_cache "widget"; then
        print_status "Widget tests cached"
        log_result "widget" "CACHED"
        return 0
    fi
    
    cd "$FLUTTER_DIR"
    
    if flutter test --plain-name "widget" 2>&1 | tee /tmp/widget.log; then
        print_status "Widget tests passed"
        save_cache "widget" "PASS"
        log_result "widget" "PASS"
    else
        print_warning "Widget tests issues"
        save_cache "widget" "WARN"
        log_result "widget" "WARN"
    fi
}

# =============================================================================
# Security
# =============================================================================

test_security() {
    print_test "Running security check..."
    
    # Cache for 24 hours
    local cache_file="$CACHE_DIR/test/security.result"
    if [ -f "$cache_file" ]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [ $age -lt 86400 ]; then
            print_status "Security check cached"
            log_result "security" "CACHED"
            return 0
        fi
    fi
    
    cd "$FLUTTER_DIR"
    
    local issues=0
    
    grep -r "password\s*=\s*['\"]" lib/ 2>/dev/null | grep -v ".g.dart" | grep -v ".freezed.dart" && ((issues++)) || true
    grep -r "api_key\s*=\s*['\"]" lib/ 2>/dev/null | grep -v ".g.dart" | grep -v ".freezed.dart" && ((issues++)) || true
    grep -r "secret\s*=\s*['\"]" lib/ 2>/dev/null | grep -v ".g.dart" | grep -v ".freezed.dart" && ((issues++)) || true
    
    if [ $issues -eq 0 ]; then
        print_status "Security check passed"
        echo "PASS" > "$cache_file"
        log_result "security" "PASS"
    else
        print_warning "Security: $issues potential issues"
        echo "WARN" > "$cache_file"
        log_result "security" "WARN"
    fi
}

# =============================================================================
# Web Tests
# =============================================================================

test_web() {
    print_test "Running web tests..."
    
    cd "$WEB_DIR"
    
    if ! command -v node &> /dev/null; then
        print_warning "Node not found, skipping web"
        log_result "web" "SKIP"
        return 0
    fi
    
    # Lint
    if check_cache "web_lint"; then
        print_status "Web lint cached"
        log_result "web_lint" "CACHED"
    elif npm run lint >/dev/null 2>&1; then
        print_status "Web lint passed"
        save_cache "web_lint" "PASS"
        log_result "web_lint" "PASS"
    else
        print_warning "Web lint issues"
        save_cache "web_lint" "WARN"
        log_result "web_lint" "WARN"
    fi
    
    # Type check
    if check_cache "web_types"; then
        print_status "Web types cached"
        log_result "web_types" "CACHED"
    elif npm run type-check >/dev/null 2>&1; then
        print_status "Web types passed"
        save_cache "web_types" "PASS"
        log_result "web_types" "PASS"
    else
        print_warning "Web type issues"
        save_cache "web_types" "WARN"
        log_result "web_types" "WARN"
    fi
}

# =============================================================================
# Coverage
# =============================================================================

test_coverage() {
    print_test "Generating coverage..."
    
    cd "$FLUTTER_DIR"
    
    if [ -f "$CACHE_DIR/lcov.info" ] || [ -f "coverage/lcov.info" ]; then
        [ ! -f "coverage/lcov.info" ] && cp "$CACHE_DIR/lcov.info" coverage/ 2>/dev/null || true
        
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html >/dev/null 2>&1 || true
            print_status "Coverage: coverage/html/index.html"
        fi
        
        log_result "coverage" "OK"
    else
        print_warning "No coverage data"
        log_result "coverage" "SKIP"
    fi
}

# =============================================================================
# Summary
# =============================================================================

summary() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Test Results                                                ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    for test in "${!RESULTS[@]}"; do
        case "${RESULTS[$test]}" in
            PASS) echo -e "  ${GREEN}✓${NC} $test: ${RESULTS[$test]}" ;;
            CACHED) echo -e "  ${GREEN}✓${NC} $test: ${RESULTS[$test]}" ;;
            WARN) echo -e "  ${YELLOW}⚠${NC} $test: ${RESULTS[$test]}" ;;
            FAIL) echo -e "  ${RED}✗${NC} $test: ${RESULTS[$test]}" ;;
            SKIP) echo -e "  ${YELLOW}○${NC} $test: ${RESULTS[$test]}" ;;
        esac
    done
    
    echo ""
    echo -e "  ${GREEN}Passed${NC}: $PASSED  |  ${RED}Failed${NC}: $FAILED"
    echo ""
    
    [ -d "$CACHE_DIR/test" ] && print_info "Test cache: $(du -sh $CACHE_DIR/test 2>/dev/null | cut -f1)"
    print_info "Cache TTL: 1 hour (clear with: rm -rf $CACHE_DIR/test/)"
    echo ""
    
    [ $FAILED -gt 0 ] && return 1 || return 0
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_header
    
    local mode="${1:-full}"
    
    setup
    
    case "$mode" in
        full)
            test_analysis
            test_format
            test_unit
            test_widget
            test_security
            test_coverage
            test_web
            ;;
        quick)
            test_analysis
            test_unit
            ;;
        analysis) test_analysis ;;
        format) test_format ;;
        unit) test_unit ;;
        widget) test_widget ;;
        security) test_security ;;
        web) test_web ;;
        coverage) test_coverage ;;
        *)
            echo "Usage: $0 [full|quick|analysis|format|unit|widget|security|web|coverage]"
            exit 1
            ;;
    esac
    
    summary
}

main "$@"
