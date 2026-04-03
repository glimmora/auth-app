# AuthVault — Build Instructions

## Quick Build

```bash
cd auth-app

# Build Android (split APKs by ABI)
./build_android.sh

# Build Desktop (Linux/Windows)
./build_desktop.sh
```

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Android SDK | API 26-34 | Android Studio or command-line tools |
| Java JDK | 17+ | Required for Android build |
| Gradle | 8.x | Build automation for Android |
| CMake | 3.14+ | Required for Desktop build |
| C++17 Compiler | GCC/Clang/MSVC | Required for Desktop build |
| OpenSSL | 1.1+ | Cryptographic library for Desktop |

## Android Signing

Release APKs can be signed by configuring `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            storeFile file("../keystore/release.jks")
            storePassword "your-password"
            keyAlias "authvault"
            keyPassword "your-password"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

Create the keystore:

```bash
keytool -genkey -v \
  -keystore android/keystore/release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias authvault
```

## Build Outputs

### Android — ABI-split APKs

```
android/app/build/outputs/apk/release/
├── app-armeabi-v7a-release.apk   # 32-bit ARM
├── app-arm64-v8a-release.apk     # 64-bit ARM
├── app-x86_64-release.apk        # 64-bit x86
└── app-release.apk               # Universal APK
```

### Desktop

```
desktop/build/linux/authvault     # Linux executable
desktop/build/windows/authvault.exe  # Windows executable
```

## Verify APK Signature

```bash
apksigner verify --verbose android/app/build/outputs/apk/release/app-arm64-v8a-release.apk
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Android SDK not found" | Set `ANDROID_HOME` environment variable |
| "Keystore file not found" | Check path in `build.gradle` |
| "Gradle not found" | Install Gradle or use wrapper |
| "CMake not found" | Install CMake 3.14+ |
| "OpenSSL not found" | Install OpenSSL development libraries |

## Architecture

### Android (Kotlin)
- TOTP/HOTP engine in `android/app/src/main/java/com/authvault/authapp/crypto/`
- Base32 decoder for secret keys
- Clean architecture with separated modules

### Desktop (C++)
- TOTP/HOTP engine in `desktop/src/totp_engine.cpp`
- OpenSSL for HMAC-SHA1 operations
- CMake build system for cross-platform support
