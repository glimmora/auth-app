#!/bin/bash
# AuthVault Android Build Script - Fixed Version
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==> ERROR:${NC} $1"; exit 1; }

# Change to project root
cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"

log "AuthVault Android Build Script"
log "Project root: $PROJECT_ROOT"

# Check required tools
if ! command -v java &> /dev/null; then
    error "Java not found. Please install Java 17+"
fi

if ! command -v gradle &> /dev/null && [ ! -f "android/gradlew" ]; then
    log "Downloading Gradle wrapper..."
    cd android
    wget -q https://services.gradle.org/distributions/gradle-8.6-bin.zip
    unzip -q gradle-8.6-bin.zip
    mv gradle-8.6/bin/gradle ./gradlew
    chmod +x gradlew
    cd ..
fi

cd android

# Clean previous builds
log "Cleaning previous builds..."
./gradlew clean

# Build APK with split ABI
log "Building release APK with ABI split..."
./gradlew assembleRelease

# Find output files
APK_DIR="$PROJECT_ROOT/build/app/outputs/apk/release"
if [ ! -d "$APK_DIR" ]; then
    APK_DIR="$PROJECT_ROOT/android/app/build/outputs/apk/release"
fi

if [ -d "$APK_DIR" ]; then
    log "Build successful! Output:"
    ls -lh "$APK_DIR"
    
    echo ""
    log "Generated APK files:"
    for apk in "$APK_DIR"/app-*-release*.apk; do
        filename=$(basename "$apk")
        size=$(du -h "$apk" | cut -f1)
        log "  - $filename ($size)"
    done
else
    error "APK output directory not found"
fi

log "Android build completed successfully!"
