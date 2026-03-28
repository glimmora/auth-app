# AuthVault

A cross-platform, feature-rich TOTP/HOTP authenticator application surpassing Google Authenticator, 2FAS, and Aegis. Built with **Flutter** (Android · iOS · Windows · Linux) and **React + Vite** (Web PWA), with full interoperability via encrypted import/export.

## Features

### Core Features
- ✅ TOTP (RFC 6238) & HOTP (RFC 4226)
- ✅ Steam Guard support
- ✅ 6/7/8 digit codes
- ✅ 15s/30s/60s/90s/120s periods
- ✅ SHA-1/SHA-256/SHA-512 algorithms
- ✅ **Custom time offset (±N seconds)** for clock drift correction
- ✅ QR code scanner & image import
- ✅ Manual entry

### Security
- ✅ AES-256-GCM encryption at rest
- ✅ PBKDF2 (310,000 iterations) key derivation
- ✅ Biometric lock (Face/Touch ID, Windows Hello)
- ✅ PIN lock with brute-force protection
- ✅ Screenshot protection
- ✅ Auto-lock with configurable delay
- ✅ Clipboard auto-clear

### UX Features
- ✅ Groups/tags for accounts
- ✅ Drag-and-drop reorder
- ✅ Search & favorites
- ✅ Custom icons (500+ built-in + upload)
- ✅ Dark/Light/AMOLED themes
- ✅ Material You dynamic color
- ✅ Tap-to-reveal mode
- ✅ Next-code preview
- ✅ Copy on tap with haptic feedback

### Backup & Sync
- ✅ Encrypted .avx backup format
- ✅ Google Drive / iCloud / Dropbox backup
- ✅ Import from Google Authenticator, Aegis, 2FAS, Authy
- ✅ QR batch export for phone-to-phone transfer

## Project Structure

```
auth-app/
├── flutter/                    # Flutter app (Android · iOS · Windows · Linux)
│   ├── lib/
│   │   ├── core/               # Crypto, database, security, time services
│   │   ├── features/           # Feature modules (accounts, settings, backup)
│   │   ├── shared/             # Shared widgets and utilities
│   │   └── main.dart
│   ├── test/                   # Unit and widget tests
│   └── pubspec.yaml
│
├── web/                        # Vite + React PWA
│   ├── src/
│   │   ├── core/               # Crypto, IndexedDB, AVX encoder
│   │   ├── features/           # React components
│   │   ├── hooks/              # Custom React hooks
│   │   └── App.tsx
│   ├── test/                   # Vitest tests
│   └── package.json
│
├── scripts/                    # Build and deployment scripts
│   ├── flutter/
│   │   ├── build_android.sh
│   │   ├── build_ios.sh
│   │   ├── build_windows.sh
│   │   └── build_linux.sh
│   ├── web/
│   │   ├── build_web.sh
│   │   └── deploy_web.sh
│   └── env/                    # Environment templates
│
└── README.md
```

## Quick Start

### Prerequisites

```bash
# Flutter
flutter --version   # >= 3.22.0
dart --version      # >= 3.4.0

# Web
node --version      # >= 20.0.0
npm --version       # >= 10.0.0

# Android
java --version      # JDK 17+
# Set ANDROID_HOME

# iOS (macOS only)
xcode-select --version   # >= 15.0
pod --version            # >= 1.15.0
```

### Flutter App

```bash
cd flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d android   # or -d ios, -d windows, -d linux
```

### Web App

```bash
cd web
npm install
npm run dev          # http://localhost:5173
npm run build        # production build → dist/
```

### Running Tests

```bash
# Flutter
cd flutter && flutter test --coverage

# Web
cd web && npm test
```

### Building Releases

```bash
# Android (APK + AAB)
bash scripts/flutter/build_android.sh both release

# iOS (requires macOS)
bash scripts/flutter/build_ios.sh archive

# Web
bash scripts/web/build_web.sh production

# All platforms
bash scripts/flutter/release_all.sh 1.0.0
```

## Security

- All cryptographic operations happen on-device
- Secrets are encrypted with AES-256-GCM at rest
- Master key is wrapped with platform Keystore/Secure Enclave
- PBKDF2 with 310,000 iterations (OWASP 2023 minimum)
- No network access required (offline-first)
- Optional cloud backup with end-to-end encryption

## Roadmap

- [ ] Wear OS / watchOS companion apps
- [ ] Browser extension for web auto-fill
- [ ] Hardware key (YubiKey) support
- [ ] FIDO2 / Passkey integration
- [ ] Team/Enterprise vault sharing (E2EE)

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

*AuthVault — Secure by design. Open by default.*
# auth-app
# auth-app
