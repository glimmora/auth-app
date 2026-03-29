# AuthVault - Build Instructions

## Quick Build Commands

```bash
cd /home/ubuntu/auth-app

# First time: Install Android SDK and dependencies
./scripts/fix.sh all

# Build Android (split APKs + AAB)
./scripts/build.sh android

# Build Linux
./scripts/build.sh linux

# Build Web
./scripts/build.sh web

# Build all platforms
./scripts/build.sh all
```

## Manual Setup (Required Once)

The scripts need these system packages installed:

```bash
# Install build dependencies (required for Flutter Linux builds)
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev unzip lld

# The script will use this sudo password when prompted:
# LO3QERKYFWAVIRZQS7JNHNHKMGCIZTRB
```

## Android SDK

The Android SDK is already installed at: `/home/ubuntu/Android`

The scripts automatically detect and use it. No manual setup needed.

## Build Outputs

### Android
```
flutter/build/outputs/android/
├── app-armeabi-v7a-release.apk    # 32-bit ARM
├── app-arm64-v8a-release.apk      # 64-bit ARM
├── app-x86_64-release.apk         # 64-bit x86
└── app-release.aab                # Play Store bundle
```

### Linux
```
flutter/build/outputs/linux/authvault/authvault
```

### Web
```
web/dist/
```

## Signing

To sign Android builds:

```bash
# Create keystore (first time only)
./scripts/setup-keystore.sh

# Subsequent builds are automatically signed
./scripts/build.sh android
```

## Troubleshooting

### "lld not found"
```bash
sudo apt-get install -y lld
```

### "Android SDK not found"
```bash
./scripts/fix.sh sdk
```

### "Build failed - codegen"
```bash
./scripts/fix.sh codegen
```

### Clear cache and rebuild
```bash
rm -rf .cache/
./scripts/fix.sh all
./scripts/build.sh all
```

## Cache

All downloads are cached:
- `.cache/pub/` - Flutter packages
- `.cache/npm/` - npm packages  
- `~/.Android/` - Android SDK

Subsequent builds are 5-10x faster.
