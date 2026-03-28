# AuthVault - Complete Feature List

> A cross-platform, feature-rich TOTP/HOTP authenticator application built with **Flutter** (Android · iOS · Windows · Linux) and **React + Vite** (Web PWA).

---

## Table of Contents

1. [Core Authentication Features](#1-core-authentication-features)
2. [Security Features](#2-security-features)
3. [User Interface Features](#3-user-interface-features)
4. [Backup & Sync Features](#4-backup--sync-features)
5. [Platform-Specific Features](#5-platform-specific-features)
6. [Advanced Features](#6-advanced-features)
7. [Developer Features](#7-developer-features)
8. [Feature Comparison Matrix](#8-feature-comparison-matrix)

---

## 1. Core Authentication Features

### TOTP Support (RFC 6238)
- [x] Standard 30-second time step
- [x] Custom time steps: 15s, 30s, 60s, 90s, 120s
- [x] 6-digit codes (default)
- [x] 7-digit codes
- [x] 8-digit codes
- [x] SHA-1 algorithm
- [x] SHA-256 algorithm
- [x] SHA-512 algorithm

### HOTP Support (RFC 4226)
- [x] Counter-based OTP generation
- [x] Manual counter increment
- [x] 6/7/8 digit codes
- [x] SHA-1/SHA-256/SHA-512 algorithms

### Steam Guard Support
- [x] Steam-specific TOTP variant
- [x] 5-character alphanumeric codes
- [x] Custom Steam alphabet encoding

### Account Management
- [x] Add accounts via QR code scan
- [x] Add accounts via image import
- [x] Add accounts via manual entry
- [x] Edit account details
- [x] Delete accounts
- [x] Group accounts into categories
- [x] Favorite/pin accounts
- [x] Drag-and-drop reordering
- [x] Search accounts
- [x] Account icons (500+ built-in)
- [x] Custom icon upload

### Code Display
- [x] Real-time code generation
- [x] Animated countdown timer
- [x] Circular progress ring
- [x] Next code preview
- [x] Seconds remaining display
- [x] Copy to clipboard on tap
- [x] Tap-to-reveal mode (hide codes by default)
- [x] Code formatting with space (123 456)

---

## 2. Security Features

### Encryption
- [x] AES-256-GCM encryption at rest
- [x] PBKDF2 key derivation (310,000 iterations)
- [x] Argon2id support (optional)
- [x] Unique IV per encryption
- [x] HMAC-SHA256 integrity verification
- [x] Master key wrapped with platform keystore

### Authentication
- [x] PIN lock (4-6 digits)
- [x] Biometric authentication
  - [x] Fingerprint (Android/Windows)
  - [x] Face ID (iOS)
  - [x] Touch ID (macOS)
  - [x] Windows Hello
- [x] Auto-lock timer (configurable)
- [x] Brute-force protection
  - [x] 5 failed attempts → 30s cooldown
  - [x] Exponential backoff
  - [x] Optional data wipe after 10 failures
- [x] Biometric re-authentication on change

### Clipboard Security
- [x] Auto-clear clipboard (30s default)
- [x] Configurable clear timer
- [x] Clipboard clear notification

### Screen Protection
- [x] Screenshot prevention (Android FLAG_SECURE)
- [x] Background blur/overlay (iOS)
- [x] Privacy screen option

### Key Storage
- [x] Android Keystore
- [x] iOS Secure Enclave
- [x] Windows Hello
- [x] Linux Secret Service API
- [x] Web Crypto API (SubtleCrypto)

### Audit & Monitoring
- [x] Audit log (all security events)
  - [x] Unlock attempts
  - [x] Code copies
  - [x] Export/import actions
  - [x] Settings changes
- [x] Tamper detection
- [x] Hash-chained log entries

---

## 3. User Interface Features

### Themes
- [x] Light theme
- [x] Dark theme
- [x] AMOLED black theme
- [x] System theme detection
- [x] Material You dynamic color (Android 12+)
- [x] Custom accent colors

### Typography
- [x] Inter font (UI)
- [x] JetBrains Mono (OTP codes)
- [x] Scalable text sizes
- [x] High contrast mode support

### Navigation
- [x] Bottom navigation bar
- [x] Drawer menu
- [x] Gesture navigation
- [x] Deep linking support
- [x] Breadcrumb navigation

### Account Display
- [x] Card-based layout
- [x] List view
- [x] Grid view
- [x] Compact mode
- [x] Detailed mode
- [x] Custom account sorting
- [x] Filter by group
- [x] Filter by favorite

### Animations
- [x] Smooth transitions
- [x] Progress ring animation
- [x] Swipe gestures
- [x] Haptic feedback
- [x] Loading skeletons
- [x] Pull-to-refresh

### Accessibility
- [x] Screen reader support (TalkBack/VoiceOver)
- [x] High contrast mode
- [x] Large text support
- [x] Keyboard navigation
- [x] Focus indicators
- [x] ARIA labels (Web)

---

## 4. Backup & Sync Features

### Local Backup
- [x] Encrypted .avx file format
- [x] Password-protected backups
- [x] Automatic backup reminders
- [x] Backup to device storage
- [x] Restore from .avx file

### Cloud Backup
- [x] Google Drive backup
- [x] iCloud backup (iOS)
- [x] Dropbox backup
- [x] OneDrive backup
- [x] Automatic scheduled backups
- [x] End-to-end encrypted cloud storage

### Import Options
- [x] Google Authenticator import
  - [x] QR code migration
  - [x] otpauth-migration:// URI
- [x] Aegis import (Android)
- [x] 2FAS import
- [x] Authy import (via export)
- [x] Bitwarden import
- [x] Raivo OTP import
- [x] Generic otpauth:// URI import

### Export Options
- [x] Export to .avx (native format)
- [x] Export to Aegis JSON
- [x] Export as QR codes (batch)
- [x] Export individual otpauth:// URIs
- [x] Export to Google Authenticator

### QR Transfer Protocol
- [x] Batch QR export (paginated)
- [x] Session-based transfer
- [x] Transfer PIN protection
- [x] Auto-expire after 5 minutes
- [x] Progress tracking

---

## 5. Platform-Specific Features

### Android
- [x] Minimum SDK 26 (Android 8.0)
- [x] Target SDK 35
- [x] Android Keystore integration
- [x] Home screen widget
  - [x] Show N accounts
  - [x] Quick code copy
  - [x] Configurable refresh rate
- [x] Adaptive icons
- [x] Per-account notification channel
- [x] Quick Settings tile
- [x] Share intent support
- [x] Biometric prompt (Android 10+)

### iOS
- [x] Minimum iOS 16.0
- [x] Secure Enclave integration
- [x] iCloud Keychain sync
- [x] App Clips support
- [x] iOS Widgets (WidgetKit)
  - [x] Small widget
  - [x] Medium widget
  - [x] Lock screen widget (iOS 16+)
- [x] Siri Shortcuts
- [x] Face ID / Touch ID
- [x] App Store distribution

### Windows
- [x] Minimum Windows 10 1903
- [x] Windows Hello integration
- [x] System tray icon
- [x] Quick-access menu
- [x] MSIX packaging
- [x] Microsoft Store ready
- [x] Auto-start on boot (optional)

### Linux
- [x] GTK+ theming
- [x] Secret Service API (libsecret)
- [x] .deb package (Debian/Ubuntu)
- [x] .rpm package (Fedora/RHEL)
- [x] AppImage (universal)
- [x] System tray support
- [x] Desktop file integration

### Web (PWA)
- [x] Progressive Web App
- [x] Offline-first architecture
- [x] IndexedDB storage
- [x] Service Worker caching
- [x] Install prompt
- [x] Full-screen standalone mode
- [x] Web Crypto API (SubtleCrypto)
- [x] WebAuthn support
- [x] Responsive design
- [x] Cross-browser support
  - [x] Chrome/Edge
  - [x] Firefox
  - [x] Safari
  - [x] Opera

---

## 6. Advanced Features

### Time Offset Feature
- [x] Custom time offset (±300 seconds)
- [x] NTP drift measurement
- [x] One-tap suggested offset apply
- [x] Per-account offset override
- [x] Live preview with offset
- [x] Warning indicator when active
- [x] Reset to auto (zero offset)

### Code Preview
- [x] Next code preview
- [x] Time until next code
- [x] Multiple future codes (optional)

### Account Organization
- [x] Groups/folders
- [x] Tags/labels
- [x] Color coding
- [x] Custom group icons
- [x] Nested groups (future)

### Search & Filter
- [x] Full-text search
- [x] Search by issuer
- [x] Search by label
- [x] Filter by group
- [x] Filter by favorite
- [x] Recent accounts
- [x] Frequently used accounts

### Notifications
- [x] Backup reminders
- [x] Security alerts
- [x] Code expiry warnings (optional)
- [x] Auto-lock notifications

### Widgets
- [x] Android home widget
- [x] iOS WidgetKit
- [x] Configurable accounts
- [x] Quick copy action
- [x] Auto-refresh

### Browser Integration (Future)
- [ ] Browser extension
  - [ ] Chrome
  - [ ] Firefox
  - [ ] Edge
  - [ ] Safari
- [ ] WebAuthn bridge
- [ ] Auto-fill support

---

## 7. Developer Features

### Build System
- [x] Automated build scripts
  - [x] Android (APK/AAB)
  - [x] iOS (IPA)
  - [x] Windows (MSIX)
  - [x] Linux (.deb/.rpm/AppImage)
  - [x] Web (Vite)
- [x] Code signing scripts
- [x] Release automation
- [x] Version management

### Testing
- [x] Unit tests (TOTP/HOTP engine)
- [x] Unit tests (crypto functions)
- [x] Widget tests (Flutter)
- [x] Component tests (React)
- [x] Integration tests
- [x] E2E tests (Playwright)
- [x] Test coverage reports

### CI/CD
- [x] GitHub Actions workflows
  - [x] Test on PR
  - [x] Build on tag
  - [x] Deploy to stores
- [x] Automated code signing
- [x] Release notes generation
- [x] Artifact publishing

### Documentation
- [x] API documentation
- [x] Architecture documentation
- [x] Security audit checklist
- [x] Contributing guidelines
- [x] Code of conduct

### Code Quality
- [x] Linting (ESLint, dart analyze)
- [x] Formatting (Prettier, dart format)
- [x] Type checking (TypeScript, Dart)
- [x] Static analysis
- [x] Dependency auditing

---

## 8. Feature Comparison Matrix

| Feature | Flutter Android | Flutter iOS | Flutter Windows | Flutter Linux | Web PWA |
|---------|----------------|-------------|-----------------|---------------|---------|
| **TOTP (RFC 6238)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **HOTP (RFC 4226)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Steam Guard** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **6/7/8 digit codes** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SHA-1/256/512** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Custom time offset** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **QR scanner** | ✅ | ✅ | ⚠️ Webcam | ⚠️ Webcam | ⚠️ Webcam |
| **Image import** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Manual entry** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Groups/tags** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Drag reorder** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Search** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Favorites** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Custom icons** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Dark/Light/AMOLED** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Biometric lock** | ✅ | ✅ | ✅ | ⚠️ | ❌ |
| **PIN lock** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Auto-lock** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Screenshot protection** | ✅ | ✅ | ⚠️ | ⚠️ | ❌ |
| **Encrypted backup (.avx)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Google Drive backup** | ✅ | ❌ | ❌ | ❌ | ✅ |
| **iCloud backup** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Dropbox backup** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Import Google Authenticator** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Import Aegis** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Import 2FAS** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Export to AVX** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **QR batch export** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Next-code preview** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Copy on tap** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Tap-to-reveal** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Offline-first** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **PWA installable** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Material You** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Home widget** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **System tray** | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Notification reminders** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Audit log** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **NTP drift check** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Multi-language (i18n)** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Accessibility (a11y)** | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- ✅ = Fully supported
- ⚠️ = Partially supported / limitations apply
- ❌ = Not available on this platform

---

## Roadmap (Future Features)

### Phase 1 - Core (Completed ✅)
- [x] TOTP/HOTP engine
- [x] Basic UI
- [x] Encrypted storage
- [x] PIN/Biometric lock

### Phase 2 - Security & UX (Completed ✅)
- [x] Custom time offset
- [x] Tap-to-reveal
- [x] Groups & favorites
- [x] Icon library
- [x] Themes

### Phase 3 - Backup & Import/Export (Completed ✅)
- [x] AVX format
- [x] Local backup
- [x] Import from competitors
- [x] QR batch transfer

### Phase 4 - Advanced (In Progress 🚧)
- [ ] Wear OS / watchOS companion
- [ ] Browser extension
- [ ] Hardware key (YubiKey) support
- [ ] FIDO2 / Passkey integration

### Phase 5 - Enterprise (Planned 📋)
- [ ] Team vault sharing (E2EE)
- [ ] Admin console
- [ ] Compliance reporting
- [ ] SSO integration

---

## Technical Specifications

### Cryptography
- **TOTP**: RFC 6238
- **HOTP**: RFC 4226
- **Encryption**: AES-256-GCM
- **Key Derivation**: PBKDF2 (310k iterations) / Argon2id
- **Hashing**: SHA-1, SHA-256, SHA-512
- **Random**: CSPRNG (crypto.getRandomValues / dart:math)

### Storage
- **Flutter**: SQLite (drift) + Flutter Secure Storage
- **Web**: IndexedDB (Dexie.js) + Web Crypto API
- **Backup**: AVX format (ZIP + AES-256-GCM + PBKDF2)

### Build Targets
- **Android**: APK, AAB (Play Store ready)
- **iOS**: IPA (App Store ready)
- **Windows**: MSIX (Microsoft Store ready)
- **Linux**: .deb, .rpm, AppImage
- **Web**: PWA (Netlify, Vercel, S3+CloudFront)

---

*AuthVault — Secure by design. Open by default.*
*Version: 1.0.0*
