# AuthVault - Secure 2FA Authenticator App

[![Build Status](https://img.shields.io/github/actions/workflow/status/authvault/authvault/build.yml)](https://github.com/authvault/authvault/actions)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Web-lightgrey)](https://github.com/authvault/authvault)

**AuthVault** is a cross-platform TOTP/HOTP authenticator application with military-grade encryption, intelligent caching for fast builds, and a beautiful modern UI.

![Features](https://img.shields.io/badge/features-TOTP%2FHOTP%20%7C%20Steam%20Guard%20%7C%20Biometric%20Lock%20%7C%20Encrypted%20Backup-green)

---

## 🚀 Quick Start

### First Time Setup (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/authvault/authvault.git
cd auth-app

# 2. Fix everything (auto-installs Android SDK + dependencies, all cached)
./scripts/fix.sh all

# 3. Create Android signing key (first time only)
./scripts/setup-keystore.sh

# 4. Build for Android (split APKs + AAB)
./scripts/build.sh android
```

### Platform-Specific Builds

```bash
# Android (split APKs by ABI + AAB)
./scripts/build_android.sh

# Linux/Ubuntu desktop
./scripts/build_ubuntu.sh

# Windows desktop
./scripts/build_windows.sh

# Web PWA
./scripts/build_web.sh

# All platforms at once
./scripts/build.sh all
```

### Run Development Server

```bash
# Full pipeline: fix → test → build → run
./scripts/run.sh all linux

# Just run web dev server
./scripts/run.sh run web

# Just run tests
./scripts/test.sh full
```

---

## 📱 Features

### 🔐 Authentication
- **TOTP** (RFC 6238) - Time-based one-time passwords
- **HOTP** (RFC 4226) - Counter-based one-time passwords  
- **Steam Guard** - Steam-specific 5-character codes
- **6/7/8 digit codes** - Configurable code length
- **SHA-1/256/512** - Multiple hash algorithms

### 🛡️ Security
- **AES-256-GCM** encryption at rest
- **PBKDF2** key derivation (310,000 iterations)
- **Biometric authentication** (Fingerprint/Face ID)
- **PIN lock** (4-6 digits)
- **Auto-lock timer** (configurable)
- **Brute-force protection** with exponential backoff
- **Screenshot prevention** (Android FLAG_SECURE)
- **Clipboard auto-clear** (30s default)

### 📦 Account Management
- **QR code scanner** - Add accounts instantly
- **Image import** - Import from screenshots
- **Manual entry** - Type in details manually
- **Groups & tags** - Organize accounts
- **Favorites** - Pin important accounts
- **Search** - Find accounts quickly
- **Drag & drop** - Reorder accounts
- **Custom icons** - 500+ built-in icons

### 💾 Backup & Sync
- **Encrypted .avx files** - Native backup format
- **Cloud backup** - Google Drive, Dropbox, iCloud
- **Import from competitors** - Google Authenticator, Aegis, 2FAS, Authy
- **QR batch export** - Transfer to new device
- **Auto-backup reminders** - Never lose data

### 🎨 User Interface
- **Dark/Light/AMOLED themes**
- **Material You** dynamic colors (Android 12+)
- **Tap-to-reveal** - Hide codes by default
- **Progress ring timer** - Visual countdown
- **Next code preview** - See upcoming code
- **Haptic feedback** - Tactile responses
- **Accessibility** - Full screen reader support

---

## 📁 Project Structure

```
auth-app/
├── flutter/                     # Flutter mobile/desktop app
│   ├── lib/
│   │   ├── core/               # Core utilities, crypto, database
│   │   │   ├── crypto/         # TOTP/HOTP engine, encryption
│   │   │   ├── database/       # Drift SQLite database
│   │   │   ├── providers/      # Riverpod state management
│   │   │   └── router/         # GoRouter navigation
│   │   ├── features/           # Feature modules
│   │   │   ├── accounts/       # Account management
│   │   │   ├── auth_lock/      # PIN/biometric lock
│   │   │   ├── backup/         # Backup/restore
│   │   │   └── settings/       # App settings
│   │   ├── shared/             # Shared widgets
│   │   └── main.dart           # App entry point
│   ├── android/                # Android platform code
│   ├── ios/                    # iOS platform code  
│   ├── windows/                # Windows platform code
│   ├── linux/                  # Linux platform code
│   └── pubspec.yaml            # Flutter dependencies
│
├── scripts/                     # Automation scripts
│   ├── fix.sh                  # Auto-fix issues (cached)
│   ├── build.sh                # Wrapper for all builds
│   ├── build_android.sh        # Android-specific build
│   ├── build_ubuntu.sh         # Linux-specific build
│   ├── build_windows.sh        # Windows-specific build
│   ├── build_web.sh            # Web-specific build
│   ├── test.sh                 # Run tests (cached)
│   ├── run.sh                  # Full pipeline
│   └── setup-keystore.sh       # Android signing setup
│
├── .cache/                      # Cached dependencies (gitignored)
│   ├── pub/                    # Flutter packages
│   ├── npm/                    # npm packages
│   └── test/                   # Test results
│
└── dist/                        # Build outputs (gitignored)
    ├── android/                # Android APKs/AAB
    ├── linux/                  # Linux binaries
    ├── windows/                # Windows executables
    └── web/                    # Web build
```

---

## 🛠️ Scripts Reference

### Build Scripts

| Script | Description | Output |
|--------|-------------|--------|
| `build_android.sh` | Build Android APKs + AAB | `dist/android/` |
| `build_ubuntu.sh` | Build Linux desktop + AppImage | `dist/linux/` |
| `build_windows.sh` | Build Windows desktop + installer | `dist/windows/` |
| `build_web.sh` | Build Web PWA + deploy configs | `dist/web/` |
| `build.sh all` | Build all platforms | `dist/` |

### Build Options

```bash
# Android builds
./scripts/build_android.sh              # Release with split APKs
./scripts/build_android.sh debug        # Debug build
./scripts/build_android.sh release nosplit  # Universal APK

# Linux builds  
./scripts/build_ubuntu.sh               # Release build
./scripts/build_ubuntu.sh release package  # + AppImage/DEB

# Windows builds
./scripts/build_windows.sh              # Release build
./scripts/build_windows.sh release installer  # + Inno Setup installer

# Web builds
./scripts/build_web.sh                  # Release build
./scripts/build_web.sh release / firebase  # + Firebase config
```

### Utility Scripts

| Script | Description |
|--------|-------------|
| `fix.sh all` | Fix everything (dependencies, SDK, codegen) |
| `fix.sh sdk` | Install Android SDK only |
| `fix.sh deps` | Fix Flutter/Web dependencies |
| `fix.sh codegen` | Run code generation |
| `test.sh full` | Run all tests |
| `test.sh quick` | Quick tests only |
| `run.sh all linux` | Full pipeline for Linux |
| `setup-keystore.sh` | Create Android signing key |

---

## 📦 Dependencies

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Linux (Ubuntu 22.04+), Windows 10+, macOS 12+ |
| **RAM** | 8GB minimum (16GB recommended) |
| **Storage** | 10GB free space |
| **Flutter** | 3.24+ (auto-installed) |
| **Node.js** | 18+ (auto-installed) |

### Auto-Installed & Cached

All dependencies are automatically installed and cached permanently:

| Software | Cache Location | Size |
|----------|----------------|------|
| Flutter packages | `.cache/pub/` | ~200MB |
| npm packages | `.cache/npm/` | ~150MB |
| Android SDK | `~/.Android/` | ~3GB |

### Cache Performance

| Operation | First Run | Cached | Speedup |
|-----------|-----------|--------|---------|
| `fix.sh all` | 5-10 min | 1-2 min | **5-10x** |
| `build.sh android` | 3-5 min | 30s | **6-10x** |
| `test.sh full` | 5-10 min | 1-3 min | **3-5x** |

### Cache Management

```bash
# View cache size
du -sh .cache/

# Clear test cache only
rm -rf .cache/test/

# Clear all (will re-download)
rm -rf .cache/
```

---

## 🔐 Security Architecture

### Encryption Stack

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│   (PIN/Biometric Authentication)        │
├─────────────────────────────────────────┤
│       Key Derivation Layer              │
│   PBKDF2 (310,000 iterations)           │
│   Salt: 16 bytes random                 │
├─────────────────────────────────────────┤
│       Encryption Layer                  │
│   AES-256-GCM                           │
│   Unique IV per encryption              │
│   HMAC-SHA256 integrity                 │
├─────────────────────────────────────────┤
│       Storage Layer                     │
│   Android: Keystore                     │
│   iOS: Secure Enclave                   │
│   Web: Web Crypto API                   │
│   Linux: Secret Service API             │
└─────────────────────────────────────────┘
```

### Security Features

- ✅ **No network access** - All crypto on-device
- ✅ **Forward secrecy** - Unique IV per encryption
- ✅ **Integrity verification** - HMAC-SHA256 tags
- ✅ **Brute-force protection** - Exponential backoff
- ✅ **Tamper detection** - Hash-chained audit log
- ✅ **Screenshot prevention** - Platform-specific

---

## 📤 Build Outputs

### Android (Split APKs)

```
dist/android/
├── app-armeabi-v7a-release.apk   (~14 MB)  # 32-bit ARM
├── app-arm64-v8a-release.apk     (~15 MB)  # 64-bit ARM
├── app-x86_64-release.apk        (~16 MB)  # 64-bit x86
├── app-release.apk               (~36 MB)  # Universal APK
└── app-release.aab               (~38 MB)  # Play Store Bundle
```

### Linux

```
dist/linux/
├── authvault/                    # Application bundle
│   ├── authvault                 # Executable
│   └── data/                     # Resources
├── AuthVault-1.0.0-x86_64.AppImage  # AppImage
└── authvault_1.0.0_amd64.deb        # DEB package
```

### Windows

```
dist/windows/
├── authvault.exe                 # Main executable
├── flutter_windows.dll           # Flutter runtime
└── data/                         # Resources
```

### Web (PWA)

```
dist/web/
├── index.html
├── main.dart.js
├── flutter.js
├── flutter_service_worker.js
├── manifest.json
└── assets/
```

---

## 🧪 Testing

### Flutter Tests

```bash
cd flutter

# Run all tests
flutter test

# With coverage
flutter test --coverage

# Specific test file
flutter test test/unit/totp_test.dart
```

### Web Tests

```bash
cd web

# Run all tests
npx vitest run

# Watch mode
npx vitest

# Coverage
npx vitest run --coverage
```

### Test Coverage

| Module | Tests | Status |
|--------|-------|--------|
| TOTP/HOTP Engine | 7 | ✅ |
| AES-256-GCM Crypto | 14 | ✅ |
| IndexedDB Schema | 23 | ✅ |
| Time Offset Service | 14 | ✅ |
| Account Store | 8 | ✅ |
| LockScreen | 10 | ✅ |
| SettingsScreen | 10 | ✅ |

---

## 📸 Screenshots

| Home Screen | Add Account | Settings |
|-------------|-------------|----------|
| ![Home](screenshots/home.png) | ![Add](screenshots/add.png) | ![Settings](screenshots/settings.png) |

---

## 📄 License

**GNU General Public License v2.0**

AuthVault is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version.

See [LICENSE](LICENSE) for full text.

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Start for Contributors

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/authvault.git
cd auth-app

# Install dependencies
./scripts/fix.sh all

# Create feature branch
git checkout -b feature/your-feature

# Make changes and test
./scripts/test.sh full

# Commit and push
git commit -m "feat: add your feature"
git push origin feature/your-feature
```

---

## 📞 Support

- **Documentation:** [Wiki](https://github.com/authvault/authvault/wiki)
- **Issues:** [GitHub Issues](https://github.com/authvault/authvault/issues)
- **Discussions:** [GitHub Discussions](https://github.com/authvault/authvault/discussions)
- **Security:** [Security Policy](SECURITY.md)

---

## 📝 Changelog

### Version 1.0.0 (2026)

**Initial Release**

- ✅ TOTP/HOTP/Steam Guard support
- ✅ Biometric + PIN authentication
- ✅ Encrypted backup/restore
- ✅ Import from competitors
- ✅ Dark/Light themes
- ✅ Cross-platform builds

---

## 🏆 Credits

**AuthVault** is built with love using:

- [Flutter](https://flutter.dev) - Cross-platform UI framework
- [Riverpod](https://riverpod.dev) - State management
- [Drift](https://drift.simonbinder.eu) - SQLite database
- [PointyCastle](https://github.com/PointyCastle/pointycastle) - Cryptography
- [GoRouter](https://pub.dev/packages/go_router) - Navigation

---

*AuthVault — Secure by design. Open by default.*

**Copyright © 2025-2026 AuthVault Team**
