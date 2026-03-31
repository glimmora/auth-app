# AuthVault — Build Instructions

## Quick Build

```bash
cd auth-app

# Build Android (split APKs by ABI, signed with release key)
flutter build apk --release --split-per-abi --android-skip-build-dependency-validation

# Build Web (PWA)
cd flutter && flutter build web --no-wasm-dry-run
```

Or use the automation scripts:

```bash
./scripts/fix.sh all          # Install all dependencies (cached)
./scripts/build.sh android    # Android build (split + signed)
./scripts/build.sh web        # Web build
./scripts/build.sh all        # All platforms
```

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Flutter | 3.43+ (master channel) | See `flutter --version` |
| Dart | 3.10+ | Bundled with Flutter |
| Java | 17+ | `java -version` |
| Android SDK | API 35, Build Tools 35.0.0, NDK 27.x | Auto-installed by `fix.sh sdk` |
| Node.js | 18+ | For web dev server (optional) |

## Android Signing

Release APKs are signed using a keystore configured via `flutter/android/key.properties`:

```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=authvault
storeFile=../keystore/release.jks
```

Create the keystore:

```bash
keytool -genkey -v \
  -keystore flutter/android/keystore/release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias authvault
```

## Build Outputs

### Android — ABI-split APKs

```
flutter/build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk   # 32-bit ARM  (~22 MB)
├── app-arm64-v8a-release.apk     # 64-bit ARM  (~26 MB)
└── app-x86_64-release.apk        # 64-bit x86  (~28 MB)
```

### Web (Flutter)

```
flutter/build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_service_worker.js
├── assets/
└── canvaskit/
```

### Web (React/Vite)

```
web/dist/
├── index.html
└── assets/
```

## Verify APK Signature

```bash
$ANDROID_HOME/build-tools/35.0.0/apksigner verify \
  --verbose flutter/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Android SDK not found" | `export ANDROID_HOME=$HOME/sdk/android` |
| "Keystore file not found" | Check `key.properties` path is relative to `app/` |
| Kotlin version mismatch | Ensure `settings.gradle` and `build.gradle` use same Kotlin version |
| Gradle cache corruption | `rm -rf ~/.gradle/caches/` then rebuild |
| "flex_color_scheme" compile error | Upgrade to `^8.3.0` in `pubspec.yaml` |
| Web platform not configured | `cd flutter && flutter create . --platforms web` |

## Kotlin / Gradle Versions

| Component | Version | Configured in |
|-----------|---------|---------------|
| Kotlin | 2.1.0 | `android/settings.gradle`, `android/build.gradle` |
| Gradle | 8.11.1 | `android/gradle/wrapper/gradle-wrapper.properties` |
| AGP | 8.9.1 | `android/settings.gradle` |
| NDK | 27.0.12077973 | Auto-downloaded by Gradle |
