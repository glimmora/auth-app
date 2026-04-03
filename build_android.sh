#!/bin/bash
# Build script untuk Android APK dengan split ABI
# Jalankan di lingkungan lokal dengan Android SDK dan Gradle terinstall

set -e

echo "=== AuthVault Android Build Script ==="

# Masuk ke direktori Android
cd "$(dirname "$0")/android"

# Tambahkan konfigurasi split ABI ke app/build.gradle
if ! grep -q "splits" app/build.gradle; then
    cat >> app/build.gradle << 'EOF'

android {
    splits {
        abi {
            enable true
            reset()
            include "armeabi-v7a", "arm64-v8a", "x86_64"
            universalApk true
        }
    }
}
EOF
fi

# Download Gradle wrapper jika tidak ada
if [ ! -f "gradlew" ]; then
    echo "Downloading Gradle wrapper..."
    wget -q https://raw.githubusercontent.com/gradle/gradle/master/gradlew -O gradlew
    chmod +x gradlew
fi

# Build APK release
echo "Building APK release dengan split ABI..."
./gradlew clean assembleRelease

# Tampilkan hasil build
echo ""
echo "=== Hasil Build ==="
ls -lh ../build/app/outputs/apk/release/

echo ""
echo "APK berhasil dibuat di:"
echo "  - build/app/outputs/apk/release/"
echo ""
echo "File yang dihasilkan:"
echo "  - app-armeabi-v7a-release-unsigned.apk (32-bit ARM)"
echo "  - app-arm64-v8a-release-unsigned.apk (64-bit ARM)"
echo "  - app-x86_64-release-unsigned.apk (64-bit x86)"
echo "  - app-universal-release-unsigned.apk (Universal APK)"
