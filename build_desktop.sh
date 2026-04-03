#!/bin/bash
# Build script untuk Desktop C++ dengan CMake
# Jalankan di lingkungan lokal dengan CMake dan OpenSSL terinstall

set -e

echo "=== AuthVault Desktop Build Script ==="

# Masuk ke direktori desktop
cd "$(dirname "$0")/desktop"

# Build untuk Linux
echo "Building untuk Linux..."
mkdir -p build/linux
cd build/linux
cmake ../..
make -j$(nproc)

echo ""
echo "=== Hasil Build Linux ==="
ls -lh authvault

# Kembali ke direktori desktop
cd ../..

# Build untuk Windows (cross-compile atau native)
echo ""
echo "Building untuk Windows..."
mkdir -p build/windows
cd build/windows
cmake ../.. -DCMAKE_TOOLCHAIN_FILE=../cmake/windows-toolchain.cmake 2>/dev/null || cmake ../..
make -j$(nproc) 2>/dev/null || echo "Windows build memerlukan toolchain cross-compile"

echo ""
echo "=== Hasil Build ==="
echo "Linux: desktop/build/linux/authvault"
echo "Windows: desktop/build/windows/authvault.exe (jika berhasil)"
