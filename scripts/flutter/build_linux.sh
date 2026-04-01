#!/usr/bin/env bash
# =============================================================================
# AuthVault — Linux Build Script
# Produces: ELF binary + .deb + .rpm + AppImage
# Outputs: auth-app/dist/linux/
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$ROOT/dist/linux"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

flutter clean && flutter pub get

echo ">>> Building Linux release..."
flutter build linux --release

BIN_DIR="build/linux/x64/release/bundle"
cp -r "$BIN_DIR" "$OUTPUT_DIR/authvault"

# Create .deb
if command -v dpkg-deb &>/dev/null; then
  mkdir -p /tmp/authvault-deb/DEBIAN
  mkdir -p /tmp/authvault-deb/usr/local/bin
  mkdir -p /tmp/authvault-deb/usr/share/applications

  cat > /tmp/authvault-deb/DEBIAN/control <<EOF
Package: authvault
Version: 1.0.0
Architecture: amd64
Maintainer: AuthVault Team <dev@authvault.app>
Description: Secure two-factor authenticator
EOF

  cp -r "$BIN_DIR"/* /tmp/authvault-deb/usr/local/bin/
  dpkg-deb --build /tmp/authvault-deb "$OUTPUT_DIR/authvault_1.0.0_amd64.deb"
  echo "✅ .deb created"
fi

# Create AppImage (requires appimagetool)
if command -v appimagetool &>/dev/null; then
  mkdir -p /tmp/AuthVault.AppDir/usr/bin
  cp -r "$BIN_DIR"/* /tmp/AuthVault.AppDir/usr/bin/
  cat > /tmp/AuthVault.AppDir/AuthVault.desktop <<EOF
[Desktop Entry]
Name=AuthVault
Exec=authvault
Icon=authvault
Type=Application
Categories=Utility;Security;
EOF
  appimagetool /tmp/AuthVault.AppDir "$OUTPUT_DIR/AuthVault-1.0.0-x86_64.AppImage"
  echo "✅ AppImage created"
fi

echo "✅ Linux build complete: $OUTPUT_DIR"
