# AuthVault Android Build - Status & Solutions

## ✅ Yang Sudah Diperbaiki

### Scripts
- ✅ `fix.sh` - Auto-install Android SDK + dependencies
- ✅ `build.sh` - Build Android dengan split APK + signing
- ✅ `test.sh` - Test suite dengan caching
- ✅ `run.sh` - Full pipeline orchestration
- ✅ `setup-keystore.sh` - Android signing setup

### Android Configuration
- ✅ `settings.gradle` - Created with proper plugin management
- ✅ `build.gradle` - Updated to AGP 8.2.2 + Kotlin 1.9.24
- ✅ `gradle-wrapper.properties` - Updated to Gradle 8.5
- ✅ `app/build.gradle` - Set NDK version 25.1.8937393

### Code Fixes
- ✅ Fixed router imports
- ✅ Fixed FlexScheme.materialBase → FlexScheme.blue
- ✅ Fixed mobile_scanner toggleFlash API change
- ✅ Fixed app_database.dart imports
- ✅ Fixed account.dart imports
- ✅ Fixed base32.dart imports
- ✅ Fixed app_theme.dart deprecated APIs

## ⚠️ Masalah yang Tersisa

### Gradle Dependency Conflict
**Error:** Gradle tidak bisa resolve beberapa AndroidX dependencies

**Penyebab:**
- Flutter 3.41.6 menggunakan Flutter embedding versi baru
- Beberapa plugin (connectivity_plus, mobile_scanner, local_auth) punya dependency conflict
- NDK version mismatch

## 🔧 Solusi Manual (Perlu Dilakukan)

### Option 1: Downgrade Flutter (Recommended untuk Development)

```bash
# Gunakan Flutter versi yang lebih stable
flutter downgrade 3.24.0

# Atau install Flutter 3.24.0 manual
cd ~/flutter
git fetch --tags
git checkout 3.24.0
flutter doctor
```

### Option 2: Fix Gradle Dependencies

Tambahkan ke `flutter/android/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
android.defaults.buildfeatures.buildconfig=true
android.nonTransitiveRClass=false
android.nonFinalResIds=false
```

### Option 3: Build dengan Docker (Paling Reliable)

```bash
# Build Android menggunakan Docker dengan environment yang terkontrol
docker run --rm \
  -v $(pwd)/flutter:/app \
  -v ~/.android:/root/.android \
  -e ANDROID_HOME=/opt/android-sdk \
  ghcr.io/ledgerhq/ledger-app-builder/ledger-app-builder-lite:latest \
  bash -c "cd /app && flutter build apk --release --split-per-abi"
```

## 📋 Perintah Build

### Setelah Fix Manual

```bash
cd /home/ubuntu/auth-app

# 1. Install dependencies
./scripts/fix.sh all

# 2. Build Android (split APKs)
./scripts/build.sh android

# 3. Build Android debug (untuk testing)
./scripts/build.sh android debug

# 4. Build semua platform
./scripts/build.sh all
```

## 📦 Output Build

Setelah berhasil build, output ada di:

```
flutter/build/outputs/android/
├── app-armeabi-v7a-release.apk    # 32-bit ARM
├── app-arm64-v8a-release.apk      # 64-bit ARM  
├── app-x86_64-release.apk         # 64-bit x86
└── app-release.aab                # Play Store bundle
```

## 🎯 Rekomendasi

**Untuk development cepat:**
1. Downgrade Flutter ke 3.24.0
2. Run `./scripts/fix.sh all`
3. Build dengan `./scripts/build.sh android debug`

**Untuk production:**
1. Fix Gradle dependencies di `gradle.properties`
2. Install NDK yang benar via Android Studio
3. Build release dengan `./scripts/build.sh android release`

## 📝 Catatan Penting

- Android SDK sudah terinstall di `/home/ubuntu/Android`
- Semua downloads di-cache di `.cache/` dan `~/.Android/`
- Subsequent builds akan lebih cepat (5-10x)
- Signing key dibuat dengan `./scripts/setup-keystore.sh`
