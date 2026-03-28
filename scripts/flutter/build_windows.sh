#!/usr/bin/env bash
# =============================================================================
# AuthVault — Windows Build Script
# Must run on Windows with Flutter Windows support enabled
# Produces MSIX package
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/windows"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

flutter clean && flutter pub get

echo ">>> Building Windows release..."
flutter build windows --release

# Package as MSIX (requires msix pub package configured in pubspec.yaml)
dart run msix:create

cp -r build/windows/x64/runner/Release/* "$OUTPUT_DIR/"
echo "✅ Windows build: $OUTPUT_DIR/"
