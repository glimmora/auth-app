# AuthVault - Complete Feature List

> A cross-platform, security-focused TOTP/HOTP authenticator application built with **Flutter** for Android, iOS, Windows, and Linux.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-GPL%20v2-green)

---

## Table of Contents

1. [Core Authentication](#1-core-authentication)
2. [Security Features](#2-security-features)
3. [Account Management](#3-account-management)
4. [User Interface](#4-user-interface)
5. [Backup & Sync](#5-backup--sync)
6. [Platform Features](#6-platform-features)
7. [Advanced Features](#7-advanced-features)
8. [Developer Tools](#8-developer-tools)
9. [Feature Matrix](#9-feature-matrix)

---

## 1. Core Authentication

### TOTP Support (RFC 6238) ✅

- Standard 30-second time step
- Custom periods: 15s, 30s, 60s, 90s, 120s
- Code lengths: 6, 7, or 8 digits
- Algorithms: SHA-1, SHA-256, SHA-512
- Real-time code generation
- Animated countdown timer

### HOTP Support (RFC 4226) ✅

- Counter-based OTP generation
- Manual counter increment button
- 6/7/8 digit codes
- All standard algorithms

### Steam Guard Support ✅

- Steam-specific TOTP variant
- 5-character alphanumeric codes
- Custom Steam alphabet encoding
- Matches official Steam Mobile format

### Code Display Features

- [x] Real-time code generation (1-second refresh)
- [x] Animated circular progress ring
- [x] Seconds remaining display
- [x] Next code preview
- [x] Copy to clipboard on tap
- [x] Tap-to-reveal mode (hide by default)
- [x] Code formatting (123 456)
- [x] Color-coded timer (green→orange→red)

---

## 2. Security Features

### Encryption ✅

- **AES-256-GCM** encryption at rest
- **PBKDF2** key derivation (310,000 iterations)
- **Unique IV** per encryption operation
- **HMAC-SHA256** integrity verification
- **Key wrapping** with platform keystore

### Authentication ✅

| Method | Status | Platforms |
|--------|--------|-----------|
| **PIN Lock** | ✅ | All |
| **Fingerprint** | ✅ | Android, Windows, Linux |
| **Face ID** | ✅ | iOS |
| **Touch ID** | ✅ | macOS |
| **Windows Hello** | ✅ | Windows |

### Lock Configuration

- [x] Configurable PIN (4-6 digits)
- [x] Biometric toggle (enable/disable)
- [x] Auto-lock timer (15s, 30s, 60s, 2min, 5min)
- [x] Lock on app switch
- [x] Lock on background

### Brute-Force Protection ✅

- 5 failed attempts → 30 second cooldown
- Exponential backoff (60s, 120s, 240s...)
- Optional data wipe after 10 failures (future)
- Failed attempt logging

### Clipboard Security ✅

- Auto-clear clipboard (30 seconds)
- Configurable timer (15s-120s)
- Clear notification toast

### Screen Protection ✅

- Android: `FLAG_SECURE` (blocks screenshots)
- iOS: Background blur overlay
- Linux/Windows: Privacy mode option

### Key Storage ✅

| Platform | Storage |
|----------|---------|
| Android | Android Keystore |
| iOS | Secure Enclave |
| Windows | Windows Hello / DPAPI |
| Linux | Secret Service API (libsecret) |
| Web | Web Crypto API (SubtleCrypto) |

### Audit Log ✅

Security events tracked:

- [x] Unlock attempts (success/failure)
- [x] Code copies
- [x] Export/import actions
- [x] Settings changes
- [x] Account modifications
- [x] Hash-chained entries (tamper-proof)

---

## 3. Account Management

### Add Accounts ✅

| Method | Description |
|--------|-------------|
| **QR Scanner** | Use camera to scan otpauth:// QR codes |
| **Image Import** | Select screenshot with QR code |
| **Manual Entry** | Type issuer, label, and secret |
| **Secret Generator** | Generate random Base32 secret |

### Account Types ✅

- TOTP accounts (time-based)
- HOTP accounts (counter-based)
- Steam Guard accounts
- Custom accounts (any otpauth:// URI)

### Organization ✅

- [x] Groups/folders
- [x] Tags/labels
- [x] Favorites (star/pin accounts)
- [x] Custom sorting (drag & drop)
- [x] Search (by issuer, label, or code)
- [x] Filter by group
- [x] Filter by favorites only

### Account Details ✅

- Issuer name (e.g., "Google", "GitHub")
- Account label (e.g., email)
- Secret key (Base32, encrypted)
- Algorithm (SHA1/256/512)
- Digits (6/7/8)
- Period (15/30/60/90/120 seconds)
- Custom time offset (±300 seconds)
- Custom icon (500+ built-in)
- Icon color

### Icons ✅

- 500+ built-in service icons
- Auto-detect by issuer name
- Manual icon selection
- Custom icon upload (SVG/PNG)
- Letter avatar fallback

---

## 4. User Interface

### Themes ✅

- [x] Light theme
- [x] Dark theme
- [x] AMOLED black theme (true black)
- [x] System theme detection
- [x] Material You dynamic colors (Android 12+)
- [x] Custom accent colors
- [x] Smooth theme transitions

### Typography ✅

- **Inter** font for UI text
- **JetBrains Mono** for OTP codes
- Scalable text sizes
- High contrast mode support

### Layout Options ✅

- Card-based account tiles
- List view
- Grid view (future)
- Compact mode
- Detailed mode
- Custom account sorting

### Animations ✅

- Smooth page transitions
- Progress ring countdown
- Swipe gestures (swipe to copy)
- Haptic feedback
- Loading skeletons
- Pull-to-refresh

### Accessibility ✅

- Screen reader support (TalkBack/VoiceOver)
- High contrast mode
- Large text support (up to 200%)
- Keyboard navigation
- Focus indicators
- ARIA labels (Web)
- Reduced motion option

---

## 5. Backup & Sync

### Local Backup ✅

- **Encrypted .avx files** (native format)
- Password-protected backups
- Backup to device storage
- Restore from .avx file
- Automatic backup reminders (weekly)

### Cloud Backup ✅

| Provider | Status | Notes |
|----------|--------|-------|
| **Google Drive** | ✅ | Android + Web |
| **Dropbox** | ✅ | All platforms |
| **iCloud** | ⚠️ | iOS only (planned) |
| **OneDrive** | ⏳ | Planned |

- End-to-end encrypted cloud storage
- Automatic scheduled backups
- Version history (30 days)

### Import From Competitors ✅

| Source | Method | Status |
|--------|--------|--------|
| **Google Authenticator** | QR migration / otpauth-migration:// | ✅ |
| **Aegis** | JSON import | ✅ |
| **2FAS** | JSON import | ✅ |
| **Authy** | Export + import | ✅ |
| **Bitwarden** | CSV import | ✅ |
| **Raivo OTP** | Import | ✅ |
| **Generic otpauth://** | URI import | ✅ |

### Export Options ✅

- Export to .avx (encrypted native format)
- Export to Aegis JSON (unencrypted/encrypted)
- Export as batch QR codes (paginated)
- Export individual otpauth:// URIs
- Export to Google Authenticator (QR)

### QR Transfer Protocol ✅

- Batch QR export (20 accounts per page)
- Session-based transfer
- Transfer PIN protection
- Auto-expire after 5 minutes
- Progress tracking
- Secure deletion after transfer

---

## 6. Platform Features

### Android ✅

| Feature | Status | Details |
|---------|--------|---------|
| **Minimum SDK** | ✅ | Android 8.0 (API 26) |
| **Target SDK** | ✅ | Android 15 (API 35) |
| **Split APKs** | ✅ | armeabi-v7a, arm64-v8a, x86_64 |
| **AAB Bundle** | ✅ | Play Store ready |
| **Keystore** | ✅ | Android Keystore integration |
| **Home Widget** | ✅ | Configurable, quick copy |
| **Adaptive Icons** | ✅ | Android 8.0+ |
| **Quick Settings Tile** | ✅ | One-tap access |
| **Share Intent** | ✅ | Import from other apps |
| **Biometric Prompt** | ✅ | Android 10+ |

### iOS 📋 (Planned)

- Minimum iOS 16.0
- Secure Enclave integration
- iCloud Keychain sync
- App Clips support
- iOS Widgets (WidgetKit)
- Siri Shortcuts
- Face ID / Touch ID

### Windows ✅

| Feature | Status | Details |
|---------|--------|---------|
| **Minimum Version** | ✅ | Windows 10 1903 |
| **Windows Hello** | ✅ | Biometric auth |
| **System Tray** | ✅ | Quick-access menu |
| **MSIX Package** | ✅ | Microsoft Store ready |
| **Auto-start** | ✅ | Optional |
| **Inno Setup** | ✅ | Traditional installer |

### Linux ✅

| Feature | Status | Details |
|---------|--------|---------|
| **GTK+ Theming** | ✅ | Native look |
| **Secret Service** | ✅ | libsecret integration |
| **DEB Package** | ✅ | Debian/Ubuntu |
| **RPM Package** | ✅ | Fedora/RHEL |
| **AppImage** | ✅ | Universal Linux |
| **System Tray** | ✅ | AppIndicator |
| **Desktop File** | ✅ | Menu integration |

---

## 7. Advanced Features

### Time Offset Feature ✅

For clocks with drift:

- [x] Custom offset (±300 seconds)
- [x] NTP drift measurement
- [x] One-tap suggested offset
- [x] Per-account override
- [x] Live preview with offset
- [x] Warning indicator when active
- [x] Reset to auto (zero offset)

### Code Preview ✅

- Next code preview (upcoming)
- Time until next code
- Multiple future codes (optional)

### Notifications ✅

- Backup reminders (weekly)
- Security alerts
- Auto-lock notifications
- Update notifications

### Search & Filter ✅

- Full-text search
- Search by issuer
- Search by label
- Filter by group
- Filter by favorites
- Recent accounts
- Frequently used

---

## 8. Developer Tools

### Build System ✅

- Automated build scripts
- Code signing automation
- Release automation
- Version management
- Multi-platform builds

### Testing ✅

| Type | Coverage | Tool |
|------|----------|------|
| **Unit Tests** | TOTP/HOTP engine | flutter_test |
| **Widget Tests** | UI components | flutter_test |
| **Integration Tests** | Full flows | integration_test |
| **E2E Tests** | User journeys | Playwright (planned) |

### CI/CD ✅

- GitHub Actions workflows
- Test on PR
- Build on tag
- Automated signing
- Release notes generation
- Artifact publishing

### Code Quality ✅

- Linting (dart analyze)
- Formatting (dart format)
- Type checking (Dart)
- Static analysis
- Dependency auditing

---

## 9. Feature Matrix

### Core Features

| Feature | Android | iOS | Windows | Linux | Web |
|---------|---------|-----|---------|-------|-----|
| **TOTP (RFC 6238)** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **HOTP (RFC 4226)** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Steam Guard** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **6/7/8 digit codes** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **SHA-1/256/512** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Custom time offset** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **QR scanner** | ✅ | 📋 | ⚠️ | ⚠️ | 📋 |
| **Image import** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Manual entry** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Groups/tags** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Drag reorder** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Search** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Favorites** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Custom icons** | ✅ | 📋 | ✅ | ✅ | 📋 |

### Security Features

| Feature | Android | iOS | Windows | Linux | Web |
|---------|---------|-----|---------|-------|-----|
| **Dark/Light/AMOLED** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Biometric lock** | ✅ | 📋 | ✅ | ⚠️ | ❌ |
| **PIN lock** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Auto-lock** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Screenshot protection** | ✅ | 📋 | ⚠️ | ⚠️ | ❌ |
| **Encrypted backup (.avx)** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Google Drive backup** | ✅ | ❌ | ❌ | ❌ | ✅ |
| **Dropbox backup** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Import competitors** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **QR batch export** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Next-code preview** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Copy on tap** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Tap-to-reveal** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Offline-first** | ✅ | 📋 | ✅ | ✅ | 📋 |
| **Home widget** | ✅ | 📋 | ❌ | ❌ | ❌ |
| **System tray** | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Audit log** | ✅ | 📋 | ✅ | ✅ | 📋 |

**Legend:**
- ✅ = Fully supported
- ⚠️ = Partially supported / limitations apply
- ❌ = Not available
- 📋 = Planned (iOS/Web pending)

---

## Roadmap

### Phase 1 - Core ✅ (Completed)

- [x] TOTP/HOTP engine
- [x] Basic UI
- [x] Encrypted storage
- [x] PIN/Biometric lock
- [x] Backup/restore

### Phase 2 - Security & UX ✅ (Completed)

- [x] Custom time offset
- [x] Tap-to-reveal
- [x] Groups & favorites
- [x] Icon library
- [x] Themes
- [x] Split APK builds

### Phase 3 - Platform Expansion 🚧 (In Progress)

- [ ] iOS app
- [ ] Web PWA
- [ ] Browser extensions
- [ ] Wear OS companion

### Phase 4 - Advanced 📋 (Planned)

- [ ] Hardware key support (YubiKey)
- [ ] FIDO2 / Passkey integration
- [ ] Team vault sharing (E2EE)
- [ ] Admin console (enterprise)

---

## Technical Specifications

### Cryptography

| Component | Standard/Algorithm |
|-----------|-------------------|
| **TOTP** | RFC 6238 |
| **HOTP** | RFC 4226 |
| **Encryption** | AES-256-GCM |
| **Key Derivation** | PBKDF2 (310k iterations) |
| **Hashing** | SHA-1, SHA-256, SHA-512 |
| **Random** | CSPRNG (dart:math) |

### Storage

| Platform | Database | Secure Storage |
|----------|----------|----------------|
| **Android/iOS** | SQLite (drift) | Flutter Secure Storage |
| **Windows/Linux** | SQLite (drift) | System keyring |
| **Backup** | AVX format (ZIP + AES-256-GCM) |

### Build Targets

| Platform | Format | Store |
|----------|--------|-------|
| **Android** | APK (split), AAB | Google Play |
| **Windows** | EXE, MSIX | Microsoft Store |
| **Linux** | DEB, RPM, AppImage | Snap, Flatpak |
| **Web** | PWA | Netlify, Vercel |

---

*AuthVault — Secure by design. Open by default.*

**Version:** 1.0.0  
**Last Updated:** April 2026
