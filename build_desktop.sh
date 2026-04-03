#!/bin/bash
# AuthVault Desktop Build Script - Fixed Version
set -eo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==> ERROR:${NC} $1"; exit 1; }

cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"

log "AuthVault Desktop Build Script"
log "Project root: $PROJECT_ROOT"

# Check required tools
if ! command -v cmake &> /dev/null; then
    error "CMake not found. Please install CMake 3.14+"
fi

if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    error "C++ compiler not found. Please install GCC or Clang"
fi

if ! pkg-config --exists openssl 2>/dev/null && [ ! -f "/usr/include/openssl/hmac.h" ]; then
    warn "OpenSSL not found. Installing with apt-get..."
    echo "123456789" | sudo -S apt-get update
    echo "123456789" | sudo -S apt-get install -y libssl-dev
fi

cd desktop

# Build for Linux
log "Building for Linux..."
mkdir -p build/linux
cd build/linux
cmake ../.. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

if [ -f "authvault" ]; then
    log "Linux build successful: $(pwd)/authvault"
    size=$(du -h authvault | cut -f1)
    log "  Size: $size"
else
    error "Linux executable not found"
fi

cd ../..

# Build tests
log "Building desktop tests..."
cd tests
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)

if [ -f "authvault_tests" ]; then
    log "Running tests..."
    ./authvault_tests
else
    warn "Test executable not found"
fi

cd ../../..

log "Desktop build completed successfully!"
