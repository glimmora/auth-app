#!/usr/bin/env bash
# =============================================================================
# AuthVault — iOS Build Script
# Must run on macOS with Xcode installed
# Usage: ./build_ios.sh [ipa|archive]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/ios"
ENV_FILE="$ROOT/scripts/env/.env.ios"

set -a; source "$ENV_FILE"; set +a

BUILD_TYPE="${1:-ipa}"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

echo ">>> Cleaning..."
flutter clean && flutter pub get

echo ">>> Building iOS ($BUILD_TYPE)..."
if [[ "$BUILD_TYPE" == "ipa" ]]; then
  flutter build ipa \
    --release \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info" \
    --export-options-plist="$ROOT/scripts/ios/ExportOptions.plist"

  cp build/ios/ipa/*.ipa "$OUTPUT_DIR/"
  echo "✅ IPA built: $OUTPUT_DIR/"
else
  flutter build ios --release --no-codesign
  # Archive via xcodebuild
  xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$OUTPUT_DIR/AuthVault.xcarchive" \
    DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    CODE_SIGN_STYLE=Manual \
    PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE"
  echo "✅ Archive: $OUTPUT_DIR/AuthVault.xcarchive"
fi
