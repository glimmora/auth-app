# AuthVault - Secure Authenticator App

Cross-platform TOTP/HOTP authenticator with intelligent caching for fast builds.

## 🚀 Quick Start

### First Time Setup

```bash
# 1. Fix everything (auto-installs Android SDK + dependencies, all cached)
./scripts/fix.sh all

# 2. Create Android signing key (first time only)
./scripts/setup-keystore.sh

# 3. Build and run
./scripts/run.sh all linux
```

### Common Commands

```bash
# Fix all issues (dependencies cached)
./scripts/fix.sh all

# Build Android app (split APKs by ABI + AAB, signed)
./scripts/build.sh android

# Run full pipeline: fix → test → build
./scripts/run.sh all linux

# Run tests (results cached 1 hour)
./scripts/test.sh full

# Start web dev server
./scripts/run.sh run web
```

## 📁 Project Structure

```
auth-app/
├── flutter/                 # Flutter mobile/desktop app
│   ├── lib/
│   │   ├── core/           # Core utilities, crypto, database
│   │   ├── features/       # Feature modules
│   │   └── main.dart       # App entry point
│   ├── android/            # Android platform code
│   ├── ios/                # iOS platform code
│   └── pubspec.yaml        # Flutter dependencies
│
├── web/                     # React web app (Vite + TypeScript)
│   ├── src/
│   │   ├── core/           # Core utilities
│   │   ├── features/       # Feature components
│   │   └── main.tsx        # Web entry point
│   ├── dist/               # Build output (gitignored)
│   └── package.json        # Web dependencies
│
├── scripts/                 # Automation scripts
│   ├── fix.sh              # Auto-fix issues (cached)
│   ├── build.sh            # Build all platforms (cached)
│   ├── test.sh             # Run tests (cached results)
│   ├── run.sh              # Full pipeline
│   └── setup-keystore.sh   # Android signing setup
│
├── .cache/                  # Cached dependencies (gitignored)
│   ├── pub/                # Flutter packages
│   ├── npm/                # npm packages
│   └── test/               # Test results
│
└── .gitignore               # Comprehensive ignore rules
```

## 🛠️ Scripts

### fix.sh
Auto-fix issues and install dependencies (all cached).

```bash
./scripts/fix.sh all            # Fix everything
./scripts/fix.sh sdk            # Install Android SDK (cached in ~/.Android)
./scripts/fix.sh deps           # Fix Flutter/Web dependencies
./scripts/fix.sh codegen        # Run code generation
./scripts/fix.sh format         # Format code
./scripts/fix.sh web            # Fix web project
```

### build.sh
Build for all platforms (builds cached).

```bash
./scripts/build.sh all                  # All platforms
./scripts/build.sh android              # Android (split APKs + AAB)
./scripts/build.sh android release      # Release build
./scripts/build.sh linux                # Linux desktop
./scripts/build.sh web                  # Web PWA
```

### test.sh
Run comprehensive tests (results cached 1 hour).

```bash
./scripts/test.sh full          # All tests
./scripts/test.sh quick         # Quick tests
./scripts/test.sh unit          # Unit tests
./scripts/test.sh web           # Web tests
```

### run.sh
Full pipeline or run specific operations.

```bash
./scripts/run.sh all linux          # Full pipeline
./scripts/run.sh fix                # Fix only
./scripts/run.sh test               # Test only
./scripts/run.sh build android      # Build Android
./scripts/run.sh run web            # Run web dev server
```

### setup-keystore.sh
Create Android signing keystore.

```bash
./scripts/setup-keystore.sh         # Create keystore
./scripts/setup-keystore.sh info    # View info
./scripts/setup-keystore.sh backup  # Create backup
```

## 📦 Dependencies

### System Requirements

- **OS:** Linux (Ubuntu 22.04+)
- **RAM:** 8GB minimum
- **Storage:** 10GB free

### Auto-Installed

All dependencies automatically installed and cached:

| Software | Cache Location | Re-download |
|----------|----------------|-------------|
| Flutter packages | `.cache/pub/` | Never |
| npm packages | `.cache/npm/` | Never |
| Android SDK | `~/.Android/` | Never |

### Manual Install (if needed)

```bash
# Flutter
sudo snap install flutter --classic

# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Then run fix.sh to cache everything
./scripts/fix.sh all
```

## 🔐 Security

- **Encryption:** AES-256-GCM
- **Key Derivation:** PBKDF2 (200k iterations)
- **Platform Security:** Android Keystore, iOS Secure Enclave
- **No Network:** All crypto on-device
- **Biometric:** Fingerprint/Face ID support

## 📤 Build Outputs

### Android
```
flutter/build/outputs/android/
├── app-armeabi-v7a-release.apk   # 32-bit ARM
├── app-arm64-v8a-release.apk     # 64-bit ARM
├── app-x86_64-release.apk        # 64-bit x86
└── app-release.aab               # Play Store
```

### Linux
```
flutter/build/outputs/linux/authvault/
└── authvault                     # Binary
```

### Web
```
web/dist/
├── index.html
├── assets/
└── sw.js                         # Service worker
```

## ⚡ Cache Performance

| Operation | First Run | Cached | Speedup |
|-----------|-----------|--------|---------|
| `fix.sh all` | 5-10 min | 1-2 min | 5-10x |
| `build.sh android` | 3-5 min | 30s | 6-10x |
| `test.sh full` | 5-10 min | 1-3 min | 3-5x |

### Cache Management

```bash
# View cache
du -sh .cache/

# Clear test cache only
rm -rf .cache/test/

# Clear all (re-download)
rm -rf .cache/
```

## 🧪 Testing

### Web Tests (Vitest)

154 unit and integration tests covering all core modules, hooks, stores, and UI components.

```bash
cd web

# Run all tests
npx vitest run

# Watch mode
npx vitest

# Run specific test file
npx vitest run src/core/crypto/totp.test.ts
```

**Test Coverage:**

| Module | Tests | File |
|--------|-------|------|
| TOTP/HOTP Engine | 7 | `core/crypto/totp.test.ts` |
| AES-256-GCM Crypto | 14 | `core/crypto/aes-gcm.test.ts` |
| IndexedDB Schema | 23 | `core/db/schema.test.ts` |
| Time Offset Service | 14 | `core/time/time-offset.test.ts` |
| AVX Backup Encoder | 5 | `core/avx/encoder.test.ts` |
| useTOTP Hook | 6 | `hooks/useTOTP.test.ts` |
| Account Store (Zustand) | 8 | `features/accounts/store.test.ts` |
| LockScreen | 10 | `features/auth-lock/LockScreen.test.tsx` |
| AccountCard | 11 | `features/accounts/AccountCard.test.tsx` |
| AccountsScreen | 7 | `features/accounts/AccountsScreen.test.tsx` |
| AddAccountScreen | 8 | `features/accounts/AddAccountScreen.test.tsx` |
| SettingsScreen | 10 | `features/settings/SettingsScreen.test.tsx` |
| TimeOffsetScreen | 12 | `features/settings/TimeOffsetScreen.test.tsx` |
| BackupScreen | 11 | `features/backup/BackupScreen.test.tsx` |
| App Routing | 8 | `App.test.tsx` |

### Flutter Tests

```bash
cd flutter

# Run all tests
flutter test

# With coverage
flutter test --coverage
```

### Lint & Type Check

```bash
cd web

# ESLint
npx eslint src/ --ext .ts,.tsx

# TypeScript type check
npx tsc --noEmit
```

## 📄 License

GNU General Public License v2.0

## 📞 Support

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions

## 📝 Copyright

Copyright 2025-2026 AuthVault Team
