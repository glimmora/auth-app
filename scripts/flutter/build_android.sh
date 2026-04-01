#!/usr/bin/env bash
# =============================================================================
# AuthVault — Android Build Script
# Usage: ./build_android.sh [apk|aab|both] [debug|profile|release]
# Outputs: auth-app/dist/android/
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$ROOT/dist/android"
ENV_FILE="$ROOT/scripts/env/.env.android"

if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

BUILD_TYPE="${1:-aab}"   # apk | aab | both
FLAVOR="${2:-release}"   # debug | profile | release

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

echo ">>> Cleaning..."
flutter clean

echo ">>> Getting dependencies..."
flutter pub get

echo ">>> Running code generation..."
dart run build_runner build --delete-conflicting-outputs

if [[ "$BUILD_TYPE" == "apk" || "$BUILD_TYPE" == "both" ]]; then
  echo ">>> Building APK ($FLAVOR)..."
  flutter build apk \
    --"$FLAVOR" \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info-apk" \
    --split-per-abi

  cp build/app/outputs/flutter-apk/*.apk "$OUTPUT_DIR/"
  echo "✅ APK built: $OUTPUT_DIR/"
fi

if [[ "$BUILD_TYPE" == "aab" || "$BUILD_TYPE" == "both" ]]; then
  echo ">>> Building AAB ($FLAVOR)..."
  flutter build appbundle \
    --"$FLAVOR" \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info-aab"

  cp build/app/outputs/bundle/"$FLAVOR"/*.aab "$OUTPUT_DIR/"
  echo "✅ AAB built: $OUTPUT_DIR/"
fi

echo ">>> Build complete. Outputs in $OUTPUT_DIR"
