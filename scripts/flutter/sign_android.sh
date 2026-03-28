#!/usr/bin/env bash
# =============================================================================
# AuthVault — Android Signing Script
# Requires: KEYSTORE_PATH, KEYSTORE_PASS, KEY_ALIAS, KEY_PASS in .env.android
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/android"
ENV_FILE="$SCRIPTS_DIR/env/.env.android"

set -a; source "$ENV_FILE"; set +a

# Verify required vars
: "${KEYSTORE_PATH:?Need KEYSTORE_PATH in .env.android}"
: "${KEYSTORE_PASS:?Need KEYSTORE_PASS in .env.android}"
: "${KEY_ALIAS:?Need KEY_ALIAS in .env.android}"
: "${KEY_PASS:?Need KEY_PASS in .env.android}"

echo ">>> Signing APKs in $OUTPUT_DIR..."

for APK in "$OUTPUT_DIR"/*.apk; do
  [[ -f "$APK" ]] || continue
  SIGNED="${APK%.apk}-signed.apk"
  echo "   Signing: $(basename "$APK")"
  jarsigner \
    -verbose \
    -sigalg SHA256withRSA \
    -digestalg SHA-256 \
    -keystore "$KEYSTORE_PATH" \
    -storepass "$KEYSTORE_PASS" \
    -keypass "$KEY_PASS" \
    -signedjar "$SIGNED" \
    "$APK" \
    "$KEY_ALIAS"

  zipalign -v 4 "$SIGNED" "${SIGNED%.apk}-aligned.apk"
  echo "✅ Signed: $(basename "${SIGNED%.apk}-aligned.apk")"
done

echo ">>> Signing complete."
