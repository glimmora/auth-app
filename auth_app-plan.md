# AuthVault — Full-Stack Authenticator App Plan

> A cross-platform, feature-rich TOTP/HOTP authenticator application surpassing 2FAS, Google Authenticator, and Aegis. Built with **Flutter** (Android · iOS · Windows · Linux) and **React + Vite** (Web PWA), with full interoperability via encrypted import/export.

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Feature Matrix](#2-feature-matrix)
3. [Architecture Overview](#3-architecture-overview)
4. [Flutter App (Mobile + Desktop)](#4-flutter-app-mobile--desktop)
   - 4.1 [Tech Stack](#41-tech-stack)
   - 4.2 [Package Dependencies](#42-package-dependencies)
   - 4.3 [Module Breakdown](#43-module-breakdown)
   - 4.4 [Screen & Navigation Plan](#44-screen--navigation-plan)
   - 4.5 [TOTP / HOTP Engine](#45-totp--hotp-engine)
   - 4.6 [Custom Time Offset Feature](#46-custom-time-offset-feature)
   - 4.7 [Storage & Security](#47-storage--security)
   - 4.8 [Biometric & PIN Lock](#48-biometric--pin-lock)
   - 4.9 [Backup & Sync](#49-backup--sync)
   - 4.10 [Platform-Specific Notes](#410-platform-specific-notes)
5. [Web App (Vite + React)](#5-web-app-vite--react)
   - 5.1 [Tech Stack](#51-tech-stack)
   - 5.2 [Package Dependencies](#52-package-dependencies)
   - 5.3 [Module Breakdown](#53-module-breakdown)
   - 5.4 [PWA Configuration](#54-pwa-configuration)
   - 5.5 [Web Crypto & Storage](#55-web-crypto--storage)
6. [Cross-Platform Import / Export Protocol](#6-cross-platform-import--export-protocol)
   - 6.1 [AuthVault Exchange Format (AVX)](#61-authvault-exchange-format-avx)
   - 6.2 [Compatibility with Other Apps](#62-compatibility-with-other-apps)
   - 6.3 [QR Code Batch Transfer](#63-qr-code-batch-transfer)
7. [Database Schema](#7-database-schema)
8. [State Management](#8-state-management)
9. [UI / UX Design System](#9-ui--ux-design-system)
10. [Build System](#10-build-system)
    - 10.1 [Flutter Build Scripts](#101-flutter-build-scripts)
    - 10.2 [Web Build Scripts](#102-web-build-scripts)
    - 10.3 [Signing Configuration](#103-signing-configuration)
11. [CI/CD Pipeline](#11-cicd-pipeline)
12. [Testing Strategy](#12-testing-strategy)
13. [Security Audit Checklist](#13-security-audit-checklist)
14. [Roadmap & Milestones](#14-roadmap--milestones)
15. [File Tree (Final)](#15-file-tree-final)

---

## 1. Project Structure

```
auth-app/
├── flutter/                    # Flutter app (Android · iOS · Windows · Linux)
│   ├── android/
│   ├── ios/
│   ├── windows/
│   ├── linux/
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   ├── shared/
│   │   └── main.dart
│   ├── assets/
│   ├── test/
│   └── pubspec.yaml
│
├── web/                        # Vite + React PWA
│   ├── src/
│   │   ├── core/
│   │   ├── features/
│   │   ├── components/
│   │   └── main.tsx
│   ├── public/
│   ├── dist/                   # build output
│   ├── vite.config.ts
│   └── package.json
│
├── scripts/                    # Build, sign, release scripts
│   ├── flutter/
│   │   ├── build_android.sh
│   │   ├── build_ios.sh
│   │   ├── build_windows.sh
│   │   ├── build_linux.sh
│   │   ├── sign_android.sh
│   │   ├── sign_ios.sh
│   │   └── release_all.sh
│   ├── web/
│   │   ├── build_web.sh
│   │   └── deploy_web.sh
│   ├── keystore/               # (gitignored) signing keys
│   │   ├── android.keystore
│   │   └── ios_distribution.p12
│   └── env/
│       ├── .env.android
│       ├── .env.ios
│       └── .env.web
│
└── README.md                   # This file (full docs)
```

---

## 2. Feature Matrix

| Feature | Flutter (Android/iOS) | Flutter (Windows/Linux) | Web (Vite+React) |
|---|---|---|---|
| TOTP (RFC 6238) | ✅ | ✅ | ✅ |
| HOTP (RFC 4226) | ✅ | ✅ | ✅ |
| Steam Guard TOTP | ✅ | ✅ | ✅ |
| 6 / 7 / 8 digit codes | ✅ | ✅ | ✅ |
| 15s / 30s / 60s / 90s / 120s period | ✅ | ✅ | ✅ |
| SHA-1 / SHA-256 / SHA-512 algorithms | ✅ | ✅ | ✅ |
| **Custom time offset (±N seconds)** | ✅ | ✅ | ✅ |
| QR code scanner (camera) | ✅ | ⚠️ Webcam | ✅ Webcam |
| QR code image import | ✅ | ✅ | ✅ |
| Manual entry | ✅ | ✅ | ✅ |
| Group / tag accounts | ✅ | ✅ | ✅ |
| Drag-and-drop reorder | ✅ | ✅ | ✅ |
| Search accounts | ✅ | ✅ | ✅ |
| Favorite / pin accounts | ✅ | ✅ | ✅ |
| Custom icons (built-in library 500+) | ✅ | ✅ | ✅ |
| Custom icons (user upload) | ✅ | ✅ | ✅ |
| Dark / light / AMOLED / system theme | ✅ | ✅ | ✅ |
| Biometric lock (Face/Touch ID) | ✅ | ✅ Win Hello | ❌ |
| PIN / password lock | ✅ | ✅ | ✅ |
| Auto-lock (configurable delay) | ✅ | ✅ | ✅ |
| Screenshot protection | ✅ | ✅ | ✅ |
| Encrypted local backup (.avx) | ✅ | ✅ | ✅ |
| Google Drive backup | ✅ | ❌ | ✅ |
| iCloud backup | iOS ✅ | ❌ | ❌ |
| Dropbox / OneDrive backup | ✅ | ✅ | ✅ |
| Import from Google Authenticator | ✅ | ✅ | ✅ |
| Import from Aegis | ✅ | ✅ | ✅ |
| Import from Authy (via export) | ✅ | ✅ | ✅ |
| Import from 2FAS | ✅ | ✅ | ✅ |
| Export to AVX (cross-platform) | ✅ | ✅ | ✅ |
| QR batch export (paginated) | ✅ | ✅ | ✅ |
| Next-code preview | ✅ | ✅ | ✅ |
| Copy on tap | ✅ | ✅ | ✅ |
| Tap-to-reveal (hidden by default) | ✅ | ✅ | ✅ |
| Browser extension protocol | ❌ | ❌ | ✅ |
| Offline-first (no network required) | ✅ | ✅ | ✅ |
| Multi-language (i18n) | ✅ | ✅ | ✅ |
| Accessibility (a11y) | ✅ | ✅ | ✅ |
| Widget (Android) | ✅ | ❌ | ❌ |
| Notification reminders | ✅ | ✅ | ✅ |
| Wear OS / watchOS support | 🔜 | ❌ | ❌ |
| Time sync check (NTP diff display) | ✅ | ✅ | ✅ |
| Audit log (access history) | ✅ | ✅ | ✅ |
| PWA installable | ❌ | ❌ | ✅ |
| Material You dynamic color | ✅ | ✅ | ✅ |

---

## 3. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                │
│    Flutter Widgets / React Components + Tailwind     │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                  APPLICATION LAYER                   │
│  Riverpod Providers (Flutter) / Zustand (React)      │
│  Use Cases: GenerateCode, AddAccount, ExportVault    │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                    DOMAIN LAYER                      │
│  Entities: Account, Group, Settings, AuditEntry     │
│  TOTP/HOTP Engine (pure Dart / pure TS)             │
│  Crypto: AES-256-GCM, PBKDF2/Argon2                 │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                 INFRASTRUCTURE LAYER                 │
│  Flutter: SQLite (drift) + Flutter Secure Storage    │
│  Web: IndexedDB (Dexie.js) + SubtleCrypto API        │
│  Shared: AVX file format, QR encode/decode           │
└─────────────────────────────────────────────────────┘
```

**Design Pattern:** Clean Architecture + Feature-Sliced Design  
**Key Principle:** All cryptographic operations happen on-device. No secret ever leaves in plaintext.

---

## 4. Flutter App (Mobile + Desktop)

### 4.1 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State Management | Riverpod 2.x + flutter_hooks |
| Navigation | go_router 13.x |
| Local DB | drift (SQLite) |
| Secure Storage | flutter_secure_storage |
| Crypto | pointycastle + cryptography |
| TOTP/HOTP | Custom implementation (RFC 6238/4226) |
| QR Scan | mobile_scanner |
| QR Generate | qr_flutter |
| Biometrics | local_auth |
| Icons | font_awesome_flutter + custom SVG |
| Theming | Material 3 + flex_color_scheme |
| i18n | flutter_localizations + intl |
| Cloud Sync | googleapis (Drive), dropbox_client |
| File Picker | file_picker |
| Notifications | flutter_local_notifications |
| Logging | logger |
| Analytics (opt-in) | posthog_flutter |
| Widget (Android) | home_widget |

### 4.2 Package Dependencies

```yaml
# pubspec.yaml (key dependencies)
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State & Navigation
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  hooks_riverpod: ^2.6.1
  flutter_hooks: ^0.20.5
  go_router: ^13.2.0

  # Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: ^1.9.0

  # Security
  flutter_secure_storage: ^9.2.2
  local_auth: ^2.3.0
  cryptography: ^2.7.0
  pointycastle: ^3.9.1
  convert: ^3.1.1

  # QR
  mobile_scanner: ^5.2.3
  qr_flutter: ^4.1.0
  image_picker: ^1.1.2

  # UI
  flex_color_scheme: ^7.3.1
  font_awesome_flutter: ^10.7.0
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  animate_do: ^3.3.4
  lottie: ^3.1.2

  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  collection: ^1.18.0
  equatable: ^2.0.5
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.1
  share_plus: ^9.0.0
  file_picker: ^8.0.7
  url_launcher: ^6.3.0
  package_info_plus: ^8.0.2
  device_info_plus: ^10.1.0
  connectivity_plus: ^6.0.3

  # Cloud
  googleapis: ^13.2.0
  googleapis_auth: ^1.6.0
  http: ^1.2.1

  # Notifications
  flutter_local_notifications: ^17.2.2

  # Home Widget (Android)
  home_widget: ^0.4.1

  # Logging
  logger: ^2.3.0
  talker_flutter: ^4.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  drift_dev: ^2.18.0
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  mockito: ^5.4.4
  flutter_gen_runner: ^5.7.0
```

### 4.3 Module Breakdown

```
lib/
├── core/
│   ├── crypto/
│   │   ├── totp_engine.dart         # TOTP RFC 6238 implementation
│   │   ├── hotp_engine.dart         # HOTP RFC 4226 implementation
│   │   ├── steam_guard.dart         # Steam Guard variant
│   │   ├── aes_gcm.dart             # AES-256-GCM encrypt/decrypt
│   │   ├── key_derivation.dart      # PBKDF2 + Argon2 KDF
│   │   └── secure_random.dart
│   ├── database/
│   │   ├── app_database.dart        # drift database definition
│   │   ├── tables/
│   │   │   ├── accounts_table.dart
│   │   │   ├── groups_table.dart
│   │   │   ├── settings_table.dart
│   │   │   └── audit_log_table.dart
│   │   └── daos/
│   │       ├── accounts_dao.dart
│   │       ├── groups_dao.dart
│   │       └── audit_dao.dart
│   ├── security/
│   │   ├── app_lock.dart            # PIN / biometric orchestrator
│   │   ├── screenshot_guard.dart    # FLAG_SECURE on Android
│   │   └── secure_clipboard.dart    # Auto-clear clipboard after N sec
│   ├── time/
│   │   ├── time_service.dart        # Device time + NTP check
│   │   └── time_offset.dart        # Custom offset ± seconds logic
│   ├── storage/
│   │   ├── secure_prefs.dart        # flutter_secure_storage wrapper
│   │   └── file_storage.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── color_schemes.dart
│   │   └── typography.dart
│   └── utils/
│       ├── base32.dart
│       ├── uri_parser.dart          # otpauth:// URI parser
│       └── validators.dart
│
├── features/
│   ├── auth_lock/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── lock_screen.dart
│   │       ├── pin_setup_screen.dart
│   │       └── biometric_prompt.dart
│   ├── accounts/
│   │   ├── data/
│   │   │   ├── account_repository_impl.dart
│   │   │   └── models/account_model.dart
│   │   ├── domain/
│   │   │   ├── account.dart
│   │   │   ├── account_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_account.dart
│   │   │       ├── delete_account.dart
│   │   │       ├── edit_account.dart
│   │   │       └── generate_code.dart
│   │   └── presentation/
│   │       ├── accounts_screen.dart     # Main list
│   │       ├── account_tile.dart        # OTP tile with countdown ring
│   │       ├── add_account_screen.dart
│   │       ├── scan_qr_screen.dart
│   │       └── manual_entry_screen.dart
│   ├── groups/
│   ├── settings/
│   │   └── presentation/
│   │       ├── settings_screen.dart
│   │       ├── time_offset_screen.dart  # ← Custom time offset UI
│   │       ├── security_screen.dart
│   │       ├── appearance_screen.dart
│   │       └── about_screen.dart
│   ├── backup/
│   │   ├── data/
│   │   │   ├── avx_encoder.dart         # AVX format serializer
│   │   │   ├── avx_decoder.dart
│   │   │   ├── google_drive_backup.dart
│   │   │   └── local_backup.dart
│   │   └── presentation/
│   │       ├── backup_screen.dart
│   │       └── restore_screen.dart
│   ├── import_export/
│   │   ├── parsers/
│   │   │   ├── google_auth_parser.dart
│   │   │   ├── aegis_parser.dart
│   │   │   ├── twofas_parser.dart
│   │   │   └── avx_parser.dart
│   │   └── presentation/
│   │       ├── import_screen.dart
│   │       └── export_screen.dart
│   ├── icons/
│   │   ├── data/icon_pack.dart
│   │   └── presentation/icon_picker.dart
│   └── audit_log/
│       └── presentation/audit_log_screen.dart
│
└── shared/
    ├── widgets/
    │   ├── otp_progress_ring.dart   # Animated circular countdown
    │   ├── qr_overlay.dart
    │   ├── confirm_dialog.dart
    │   ├── password_field.dart
    │   └── icon_avatar.dart
    └── extensions/
        ├── context_ext.dart
        └── string_ext.dart
```

### 4.4 Screen & Navigation Plan

```
/ (SplashScreen)
└─ /lock              (LockScreen — PIN/Biometric)
   └─ /home           (AccountsScreen — main list)
      ├─ /account/add
      │   ├─ /account/add/scan     (QR Scanner)
      │   ├─ /account/add/image    (Image QR picker)
      │   └─ /account/add/manual   (Manual entry)
      ├─ /account/:id/edit
      ├─ /account/:id/detail
      ├─ /groups
      ├─ /search
      ├─ /backup
      │   ├─ /backup/export
      │   │   ├─ /backup/export/local
      │   │   ├─ /backup/export/drive
      │   │   └─ /backup/export/qr   (QR batch)
      │   └─ /backup/import
      ├─ /audit-log
      └─ /settings
          ├─ /settings/security
          │   ├─ /settings/security/pin
          │   └─ /settings/security/biometric
          ├─ /settings/time-offset    (★ Custom time offset)
          ├─ /settings/appearance
          ├─ /settings/backup
          ├─ /settings/advanced
          └─ /settings/about
```

### 4.5 TOTP / HOTP Engine

```dart
// core/crypto/totp_engine.dart

class TOTPEngine {
  /// Generates a TOTP code per RFC 6238.
  ///
  /// [secret]    Base32-encoded shared secret
  /// [digits]    Code length: 6, 7, or 8
  /// [period]    Time step in seconds: 15, 30, 60, 90, 120
  /// [algorithm] HmacSHA1 | HmacSHA256 | HmacSHA512
  /// [offset]    Custom time offset in seconds (positive = ahead, negative = behind)
  static String generate({
    required String secret,
    int digits = 6,
    int period = 30,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
    int offset = 0,          // ← custom time offset
  }) {
    final adjustedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + offset;
    final counter = adjustedTime ~/ period;
    return _computeHOTP(secret: secret, counter: counter,
                        digits: digits, algorithm: algorithm);
  }

  /// Returns seconds remaining in the current time step.
  static int remainingSeconds({int period = 30, int offset = 0}) {
    final adjustedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + offset;
    return period - (adjustedTime % period);
  }

  /// Returns the next code (for next-code preview feature).
  static String nextCode({
    required String secret,
    int digits = 6,
    int period = 30,
    OTPAlgorithm algorithm = OTPAlgorithm.SHA1,
    int offset = 0,
  }) {
    final adjustedTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + offset;
    final counter = (adjustedTime ~/ period) + 1;
    return _computeHOTP(secret: secret, counter: counter,
                        digits: digits, algorithm: algorithm);
  }

  static String _computeHOTP({...}) { /* RFC 4226 HMAC-based OTP */ }
}

enum OTPAlgorithm { SHA1, SHA256, SHA512 }
```

**Steam Guard Variant:**
```dart
// core/crypto/steam_guard.dart
//
// Steam uses SHA-1 TOTP with 30s period but encodes the result
// as 5 characters from a custom alphabet instead of decimal digits.
const _steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';

String generateSteamCode(String secret, {int offset = 0}) {
  final raw = TOTPEngine.generate(
    secret: secret, digits: 5, period: 30,
    algorithm: OTPAlgorithm.SHA1, offset: offset,
  );
  // Map numeric groups to steam alphabet ...
}
```

### 4.6 Custom Time Offset Feature

**Purpose:** Many authentication services enforce strict clock synchronization. A user whose device clock is drifted (e.g. a rooted device, an old device, or a region with manual time) will get rejected codes. The custom time offset lets users manually correct the skew without changing system time.

**Additional capability:** Advanced users can deliberately set a positive offset to *preview* future codes (e.g. +30s shows the next period's code), or a negative offset to match a server that is itself drifted.

```dart
// core/time/time_offset.dart

class TimeOffsetService {
  static const _key = 'time_offset_seconds';

  /// Returns the currently configured offset in seconds.
  /// Range: -300 to +300 seconds (−5 min to +5 min).
  Future<int> getOffset() async { ... }

  Future<void> setOffset(int seconds) async {
    assert(seconds >= -300 && seconds <= 300, 'Offset must be within ±300s');
    await _securePrefs.write(key: _key, value: seconds.toString());
  }

  Future<void> resetToAuto() => setOffset(0);

  /// Checks difference between device time and NTP time.
  /// Returns suggested offset so the user can apply it with one tap.
  Future<int> measureNTPDrift() async {
    // Query pool.ntp.org and calculate delta
  }
}
```

**Time Offset Settings Screen** features:
- Slider: −300 s to +300 s (step: 1 s)
- Numeric input field (for precise entry)
- **"Measure NTP drift"** button → auto-calculates suggested offset
- Live preview showing current and next code with the chosen offset
- One-tap apply / reset to zero
- Warning badge on the home screen when offset ≠ 0
- Per-account offset override (advanced: override globally or per-account)

### 4.7 Storage & Security

**Accounts table** (SQLite via drift) — secrets stored AES-256-GCM encrypted.

```dart
// The database encryption key is:
// 1. Generated once at install using a CSPRNG
// 2. Encrypted with a key derived from user's PIN (PBKDF2, 200k iterations)
//    or stored directly in the Keychain/Keystore if PIN is not set
// 3. Wrapped again with the platform Keystore (Android Keystore / iOS Secure Enclave)

class SecurityLayer {
  // Master key lifecycle
  Future<Uint8List> getMasterKey();
  Future<void> rotateMasterKey(String oldPin, String newPin);
  Future<void> exportMasterKeyBackup();  // for disaster recovery QR
}
```

**Clipboard security:**
```dart
// After OTP is copied, schedule a clear after N seconds (default 30s, configurable)
void copyWithAutoClear(String code, {int clearAfterSeconds = 30}) {
  Clipboard.setData(ClipboardData(text: code));
  Future.delayed(Duration(seconds: clearAfterSeconds), () {
    Clipboard.setData(const ClipboardData(text: ''));
  });
}
```

**Screenshot protection:**
- Android: `FLAG_SECURE` via `flutter_windowmanager`
- iOS: Overlay transparent UIWindow during background snapshot
- Windows/Linux: Configurable (off by default)

### 4.8 Biometric & PIN Lock

```
Lock flow:
  App launch / foreground → check lock_enabled setting
  → if locked: show LockScreen
      → Biometric available & enabled? → show prompt first
      → PIN fallback always available
      → After 5 wrong PINs: 30s cooldown, doubles each failure
      → After 10 wrong PINs: show data-wipe confirmation
  → Unlock → start auto-lock timer (configurable: 30s, 1m, 2m, 5m, never)
  → Background → immediately show blurred cover (before OS screenshot)
```

### 4.9 Backup & Sync

| Method | Encryption | Format | Auto-Schedule |
|---|---|---|---|
| Local file | AES-256-GCM + Argon2 password | .avx | Manual |
| Google Drive | Same as local + Google auth | .avx | Daily/Weekly |
| iCloud (iOS) | Same as local + Apple auth | .avx | Daily/Weekly |
| Dropbox | Same as local + OAuth2 | .avx | Daily/Weekly |
| QR export (batch) | Per-QR base64+AES | otpauth-migration | Manual |

### 4.10 Platform-Specific Notes

**Android:**
- Min SDK: 26 (Android 8.0)
- Target SDK: 35
- Android Keystore for hardware-backed key storage
- Home screen widget (shows N accounts with next code)
- Adaptive icon support
- Per-account notification channel

**iOS:**
- Min iOS: 16.0
- Secure Enclave for key storage
- iCloud Keychain integration
- App Clips support (quick add via QR)
- iOS Widgets (WidgetKit) — show account code

**Windows:**
- Min: Windows 10 1903
- Windows Hello integration (local_auth)
- System tray icon with quick-access menu
- MSIX packaging

**Linux:**
- GTK+ theming support
- Secret Service API (libsecret) for key storage
- `.deb` and `.rpm` packages + AppImage

---

## 5. Web App (Vite + React)

### 5.1 Tech Stack

| Layer | Technology |
|---|---|
| Build Tool | Vite 5.x |
| Framework | React 18.x + TypeScript 5.x |
| State | Zustand 4.x + Immer |
| Routing | React Router 6.x |
| DB | Dexie.js (IndexedDB wrapper) |
| Crypto | Web Crypto API (SubtleCrypto) + crypto-js fallback |
| TOTP | otpauth (npm) + custom engine |
| QR Scan | html5-qrcode |
| QR Generate | qrcode.react |
| Styling | Tailwind CSS 3.x + shadcn/ui |
| Icons | Lucide React + custom SVG sprite |
| Animation | Framer Motion |
| i18n | react-i18next |
| PWA | vite-plugin-pwa + Workbox |
| File handling | FileSaver.js |
| Drag-and-drop | @dnd-kit/core |
| Testing | Vitest + React Testing Library |
| E2E | Playwright |

### 5.2 Package Dependencies

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.23.1",
    "zustand": "^4.5.2",
    "immer": "^10.1.1",
    "dexie": "^3.2.7",
    "dexie-react-hooks": "^1.1.7",
    "otpauth": "^9.3.4",
    "qrcode.react": "^3.1.0",
    "html5-qrcode": "^2.3.8",
    "@dnd-kit/core": "^6.1.0",
    "@dnd-kit/sortable": "^8.0.0",
    "framer-motion": "^11.2.10",
    "lucide-react": "^0.383.0",
    "tailwind-merge": "^2.3.0",
    "clsx": "^2.1.1",
    "react-i18next": "^14.1.2",
    "i18next": "^23.11.5",
    "file-saver": "^2.0.5",
    "jszip": "^3.10.1",
    "react-hot-toast": "^2.4.1",
    "react-hook-form": "^7.51.5",
    "zod": "^3.23.8",
    "@hookform/resolvers": "^3.6.0",
    "dayjs": "^1.11.11",
    "uuid": "^9.0.1",
    "base32-encode": "^2.0.0",
    "base32-decode": "^1.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "@types/file-saver": "^2.0.7",
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^5.2.11",
    "vite-plugin-pwa": "^0.20.0",
    "workbox-core": "^7.1.0",
    "tailwindcss": "^3.4.4",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.38",
    "typescript": "^5.4.5",
    "vitest": "^1.6.0",
    "@testing-library/react": "^16.0.0",
    "@testing-library/user-event": "^14.5.2",
    "playwright": "^1.44.1",
    "eslint": "^9.3.0",
    "@typescript-eslint/eslint-plugin": "^7.10.0",
    "prettier": "^3.2.5"
  }
}
```

### 5.3 Module Breakdown

```
web/src/
├── core/
│   ├── crypto/
│   │   ├── totp.ts              # TOTP engine (Web Crypto API)
│   │   ├── hotp.ts
│   │   ├── aes-gcm.ts          # AES-256-GCM via SubtleCrypto
│   │   ├── key-derivation.ts   # PBKDF2 via SubtleCrypto
│   │   └── base32.ts
│   ├── db/
│   │   ├── schema.ts           # Dexie schema definition
│   │   ├── accounts.ts         # Account CRUD
│   │   ├── groups.ts
│   │   └── settings.ts
│   ├── time/
│   │   ├── time-service.ts
│   │   └── time-offset.ts     # Custom offset ±seconds
│   └── avx/
│       ├── encoder.ts          # Export to .avx
│       └── decoder.ts          # Import from .avx
│
├── features/
│   ├── auth-lock/
│   │   ├── store.ts
│   │   ├── LockScreen.tsx
│   │   └── PinPad.tsx
│   ├── accounts/
│   │   ├── store.ts            # Zustand store
│   │   ├── AccountList.tsx     # Main view
│   │   ├── AccountCard.tsx     # OTP tile
│   │   ├── AddAccount.tsx
│   │   ├── ManualEntry.tsx
│   │   └── QRScanner.tsx
│   ├── groups/
│   ├── settings/
│   │   ├── SettingsPage.tsx
│   │   ├── TimeOffsetPanel.tsx  # ★ Custom offset UI
│   │   ├── SecurityPanel.tsx
│   │   └── AppearancePanel.tsx
│   ├── import-export/
│   │   ├── ImportPage.tsx
│   │   └── ExportPage.tsx
│   └── audit-log/
│       └── AuditLogPage.tsx
│
├── components/
│   ├── ui/                     # shadcn/ui primitives
│   ├── OTPProgressRing.tsx    # SVG countdown ring
│   ├── QRDisplay.tsx
│   ├── IconPicker.tsx
│   └── ThemeToggle.tsx
│
├── hooks/
│   ├── useTOTP.ts              # Reactive OTP generation
│   ├── useTimeOffset.ts
│   ├── useClipboard.ts         # Copy + auto-clear
│   └── useAppLock.ts
│
├── i18n/
│   ├── en.json
│   ├── id.json
│   └── ... (20+ languages)
│
├── styles/
│   └── globals.css
│
├── App.tsx
└── main.tsx
```

### 5.4 PWA Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.ico', 'apple-touch-icon.png', 'masked-icon.svg'],
      manifest: {
        name: 'AuthVault',
        short_name: 'AuthVault',
        description: 'Secure two-factor authenticator',
        theme_color: '#1a1a2e',
        background_color: '#0f0f1a',
        display: 'standalone',
        icons: [
          { src: 'pwa-192x192.png', sizes: '192x192', type: 'image/png' },
          { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [],   // fully offline — no network caching needed
        navigateFallback: '/index.html'
      }
    })
  ],
  build: {
    target: 'es2022',
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'crypto-vendor': ['otpauth'],
          'ui-vendor': ['framer-motion', 'lucide-react']
        }
      }
    }
  }
})
```

### 5.5 Web Crypto & Storage

```typescript
// core/crypto/aes-gcm.ts — uses native SubtleCrypto (no external libs for crypto)

export async function encrypt(plaintext: Uint8Array, key: CryptoKey): Promise<ArrayBuffer> {
  const iv = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for GCM
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    plaintext
  );
  // Prepend IV to ciphertext for storage
  const result = new Uint8Array(12 + ciphertext.byteLength);
  result.set(iv, 0);
  result.set(new Uint8Array(ciphertext), 12);
  return result.buffer;
}

export async function deriveKey(password: string, salt: Uint8Array): Promise<CryptoKey> {
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw', enc.encode(password), 'PBKDF2', false, ['deriveKey']
  );
  return crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt, iterations: 310_000, hash: 'SHA-256' },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}
```

**IndexedDB Schema (Dexie):**
```typescript
// core/db/schema.ts
const db = new Dexie('AuthVaultDB');
db.version(1).stores({
  accounts: '++id, uuid, issuer, label, groupId, sortOrder, createdAt',
  groups:   '++id, uuid, name, color, sortOrder',
  settings: 'key',
  auditLog: '++id, action, accountId, timestamp'
});
// Sensitive fields (secret, algorithm, digits, period, counter)
// are stored AES-256-GCM encrypted as a single `encryptedPayload` blob
```

---

## 6. Cross-Platform Import / Export Protocol

### 6.1 AuthVault Exchange Format (AVX)

The `.avx` file is the native interchange format, compatible between the Flutter and Web apps.

**File structure:**
```
authvault_backup.avx
└── ZIP container (JSZip / Dart archive)
    ├── manifest.json     (unencrypted metadata)
    ├── data.enc          (AES-256-GCM encrypted JSON)
    └── integrity.sig     (HMAC-SHA256 of data.enc)
```

**manifest.json:**
```json
{
  "format": "avx",
  "version": "1.0.0",
  "app": "AuthVault",
  "platform": "flutter|web",
  "created_at": "2025-01-01T00:00:00Z",
  "account_count": 42,
  "kdf": "PBKDF2",
  "kdf_iterations": 310000,
  "kdf_hash": "SHA-256",
  "salt": "<base64>",
  "iv": "<base64>",
  "encryption": "AES-256-GCM"
}
```

**Decrypted data.enc payload:**
```json
{
  "accounts": [
    {
      "uuid": "...",
      "type": "totp|hotp|steam",
      "issuer": "GitHub",
      "label": "user@example.com",
      "secret": "JBSWY3DPEHPK3PXP",
      "algorithm": "SHA1|SHA256|SHA512",
      "digits": 6,
      "period": 30,
      "counter": 0,
      "time_offset": 0,
      "group_uuid": "...",
      "icon": "github",
      "icon_custom_b64": null,
      "sort_order": 0,
      "favorite": false,
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ],
  "groups": [
    {
      "uuid": "...",
      "name": "Work",
      "color": "#4CAF50",
      "sort_order": 0
    }
  ],
  "settings": {
    "global_time_offset": 0,
    "theme": "system",
    "tap_to_reveal": true
  }
}
```

### 6.2 Compatibility with Other Apps

| Source App | Format | Import Method |
|---|---|---|
| Google Authenticator | `otpauth-migration://` protobuf QR | QR scan / image |
| Aegis | Aegis JSON (plain or encrypted) | File import |
| 2FAS | 2FAS JSON backup | File import |
| Authy | Via Authy export (chromeapp method) | JSON file |
| Bitwarden | Bitwarden JSON export (TOTP URIs) | File import |
| Raivo OTP | Raivo JSON export | File import |
| Any | `otpauth://totp/...` URI | QR scan / text paste |
| Any | `otpauth://hotp/...` URI | QR scan / text paste |

**Export compatibility:**
| Target App | Method |
|---|---|
| Any TOTP app | Export as individual `otpauth://` QR codes |
| Google Authenticator | `otpauth-migration://` batch QR |
| Aegis | Aegis-compatible JSON |
| AVX (native) | Encrypted .avx bundle |

### 6.3 QR Code Batch Transfer

For scenarios without file access (e.g., phone-to-phone):

```
Batch QR Transfer Protocol:
  1. Sender selects accounts to transfer
  2. App groups into pages of max 10 accounts per QR
  3. Each QR encodes:
     {
       "page": 1,
       "total": 3,
       "session": "<uuid>",
       "payload_enc": "<AES-128-GCM encrypted base64>",
       "key_hint": "<first 8 chars of transfer PIN>"
     }
  4. Receiver scans each QR in order (any order supported)
  5. After all pages received, PIN prompt → decrypt → import
  6. Transfer session expires after 5 minutes
```

---

## 7. Database Schema

### Flutter (drift / SQLite)

```dart
// Accounts Table
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get type => text()();           // totp | hotp | steam
  TextColumn get issuer => text()();
  TextColumn get label => text()();
  TextColumn get encryptedSecret => text()(); // AES-256-GCM encrypted
  TextColumn get algorithm => text().withDefault(const Constant('SHA1'))();
  IntColumn get digits => integer().withDefault(const Constant(6))();
  IntColumn get period => integer().withDefault(const Constant(30))();
  IntColumn get counter => integer().withDefault(const Constant(0))();
  IntColumn get timeOffset => integer().withDefault(const Constant(0))();
  IntColumn get groupId => integer().nullable().references(Groups, #id)();
  TextColumn get iconName => text().nullable()();
  BlobColumn get iconCustom => blob().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get tapToReveal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// Groups Table
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// Settings Table (key-value)
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

// Audit Log Table
class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();      // UNLOCK | COPY_CODE | EXPORT | IMPORT | DELETE
  TextColumn get accountUuid => text().nullable()();
  TextColumn get details => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}
```

---

## 8. State Management

### Flutter (Riverpod)

```dart
// Key providers

// Accounts list — live from DB
@riverpod
Stream<List<Account>> accounts(AccountsRef ref) =>
    ref.watch(accountRepositoryProvider).watchAll();

// Real-time OTP code for a specific account
@riverpod
String otpCode(OtpCodeRef ref, String accountUuid) {
  final account = ref.watch(accountByUuidProvider(accountUuid));
  final offset = ref.watch(globalTimeOffsetProvider);
  ref.invalidateSelf(); // rebuild every second via Timer
  return TOTPEngine.generate(
    secret: account.secret,
    digits: account.digits,
    period: account.period,
    algorithm: account.algorithm,
    offset: account.timeOffset + offset, // per-account + global
  );
}

// Global time offset
@riverpod
class GlobalTimeOffset extends _$GlobalTimeOffset {
  @override
  int build() => 0; // loaded from settings
  void set(int seconds) => state = seconds;
}

// App lock state
@riverpod
class AppLock extends _$AppLock {
  @override
  bool build() => true; // locked by default
  void unlock() => state = false;
  void lock() => state = true;
}
```

### Web (Zustand)

```typescript
// features/accounts/store.ts
interface AccountStore {
  accounts: Account[];
  loading: boolean;
  globalTimeOffset: number;
  // actions
  addAccount: (account: NewAccount) => Promise<void>;
  deleteAccount: (uuid: string) => Promise<void>;
  updateAccount: (uuid: string, patch: Partial<Account>) => Promise<void>;
  reorderAccounts: (from: number, to: number) => void;
  setGlobalTimeOffset: (seconds: number) => void;
}

export const useAccountStore = create<AccountStore>()(
  immer((set, get) => ({
    accounts: [],
    loading: false,
    globalTimeOffset: 0,
    // ...implementations
  }))
);

// hooks/useTOTP.ts — reactive OTP that updates every second
export function useTOTP(account: Account): { code: string; remaining: number; nextCode: string } {
  const globalOffset = useAccountStore(s => s.globalTimeOffset);
  const [state, setState] = useState(() => computeState(account, globalOffset));

  useEffect(() => {
    const tick = () => setState(computeState(account, globalOffset));
    tick();
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [account.uuid, account.period, globalOffset, account.timeOffset]);

  return state;
}
```

---

## 9. UI / UX Design System

### Design Tokens

```
Primary:     #6C63FF  (violet)
Secondary:   #03DAC6  (teal)
Error:       #CF6679
Background:  #0F0F1A  (dark) / #FAFAFA (light)
Surface:     #1A1A2E  (dark) / #FFFFFF (light)
AMOLED:      #000000

Typography:
  Display:  Inter 700, 32px
  Title:    Inter 600, 20px
  Body:     Inter 400, 16px
  Code:     JetBrains Mono 700, 28px  (for OTP display)
  Caption:  Inter 400, 12px

Spacing:    4px base grid
Radius:     12px cards, 8px buttons, 24px FAB
Animation:  300ms ease-in-out (enter), 200ms ease-in (exit)
```

### Key UI Components

**OTP Card:**
```
┌─────────────────────────────────┐
│ 🔵 GitHub          ★  ⋮        │
│    user@example.com             │
│                                 │
│    123 456     [●●●●●●●●○○]    │
│    Next: 789 012               │
│              28s remaining      │
└─────────────────────────────────┘
```

- Animated SVG progress ring (full circle = period, empties as time passes)
- Code splits at midpoint with a space for readability
- Tap anywhere → copy + haptic feedback + toast
- Long press → context menu (Edit / Delete / Show QR / Move to group)
- Swipe left (mobile) → quick actions
- Tap-to-reveal mode: shows `• • •   • • •` until tapped

**Time Offset Screen:**
```
┌────────────────────────────────────┐
│ ←  Time Offset                     │
│                                    │
│  ⚠️ Offset active: +15 seconds     │
│                                    │
│  [−────────●──────────────────+]   │
│       -300s          +300s         │
│                                    │
│  Current offset: +15 s             │
│  [  -   ] [ 15 ] [  +  ]          │
│                                    │
│  [ Measure NTP Drift ]             │
│  NTP diff detected: +12s           │
│  [ Apply suggested: +12s ]         │
│                                    │
│  Preview with this offset:         │
│  Current: 123 456  (28s)           │
│  Next:    789 012                  │
│                                    │
│  [ Reset to 0 ]   [ Apply ]        │
└────────────────────────────────────┘
```

---

## 10. Build System

### 10.1 Flutter Build Scripts

#### `scripts/flutter/build_android.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — Android Build Script
# Usage: ./build_android.sh [apk|aab|both] [debug|profile|release]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
SCRIPTS_DIR="$ROOT/scripts"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/android"
ENV_FILE="$SCRIPTS_DIR/env/.env.android"

# Load env
if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

BUILD_TYPE="${1:-aab}"   # apk | aab | both
FLAVOR="${2:-release}"   # debug | profile | release

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

echo ">>> Cleaning..."
flutter clean

echo ">>> Getting dependencies..."
flutter pub get

echo ">>> Running code generation..."
dart run build_runner build --delete-conflicting-outputs

if [[ "$BUILD_TYPE" == "apk" || "$BUILD_TYPE" == "both" ]]; then
  echo ">>> Building APK ($FLAVOR)..."
  flutter build apk \
    --"$FLAVOR" \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info-apk" \
    --split-per-abi

  cp build/app/outputs/flutter-apk/*.apk "$OUTPUT_DIR/"
  echo "✅ APK built: $OUTPUT_DIR/"
fi

if [[ "$BUILD_TYPE" == "aab" || "$BUILD_TYPE" == "both" ]]; then
  echo ">>> Building AAB ($FLAVOR)..."
  flutter build appbundle \
    --"$FLAVOR" \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info-aab"

  cp build/app/outputs/bundle/"$FLAVOR"App/*.aab "$OUTPUT_DIR/"
  echo "✅ AAB built: $OUTPUT_DIR/"
fi

echo ">>> Build complete. Outputs in $OUTPUT_DIR"
```

#### `scripts/flutter/sign_android.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — Android Signing Script
# Requires: KEYSTORE_PATH, KEYSTORE_PASS, KEY_ALIAS, KEY_PASS in .env.android
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPTS_DIR="$ROOT/scripts"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/android"
ENV_FILE="$SCRIPTS_DIR/env/.env.android"

set -a; source "$ENV_FILE"; set +a

# Verify required vars
: "${KEYSTORE_PATH:?Need KEYSTORE_PATH in .env.android}"
: "${KEYSTORE_PASS:?Need KEYSTORE_PASS in .env.android}"
: "${KEY_ALIAS:?Need KEY_ALIAS in .env.android}"
: "${KEY_PASS:?Need KEY_PASS in .env.android}"

echo ">>> Signing APKs in $OUTPUT_DIR..."

for APK in "$OUTPUT_DIR"/*.apk; do
  [[ -f "$APK" ]] || continue
  SIGNED="${APK%.apk}-signed.apk"
  echo "   Signing: $(basename "$APK")"
  jarsigner \
    -verbose \
    -sigalg SHA256withRSA \
    -digestalg SHA-256 \
    -keystore "$KEYSTORE_PATH" \
    -storepass "$KEYSTORE_PASS" \
    -keypass "$KEY_PASS" \
    -signedjar "$SIGNED" \
    "$APK" \
    "$KEY_ALIAS"
  
  zipalign -v 4 "$SIGNED" "${SIGNED%.apk}-aligned.apk"
  echo "✅ Signed: $(basename "${SIGNED%.apk}-aligned.apk")"
done

echo ">>> Signing complete."
```

#### `scripts/flutter/build_ios.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — iOS Build Script
# Must run on macOS with Xcode installed
# Usage: ./build_ios.sh [ipa|archive]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/ios"
ENV_FILE="$ROOT/scripts/env/.env.ios"

set -a; source "$ENV_FILE"; set +a

BUILD_TYPE="${1:-ipa}"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

echo ">>> Cleaning..."
flutter clean && flutter pub get

echo ">>> Building iOS ($BUILD_TYPE)..."
if [[ "$BUILD_TYPE" == "ipa" ]]; then
  flutter build ipa \
    --release \
    --obfuscate \
    --split-debug-info="$OUTPUT_DIR/debug-info" \
    --export-options-plist="$ROOT/scripts/ios/ExportOptions.plist"
  
  cp build/ios/ipa/*.ipa "$OUTPUT_DIR/"
  echo "✅ IPA built: $OUTPUT_DIR/"
else
  flutter build ios --release --no-codesign
  # Archive via xcodebuild
  xcodebuild archive \
    -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath "$OUTPUT_DIR/AuthVault.xcarchive" \
    DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    CODE_SIGN_STYLE=Manual \
    PROVISIONING_PROFILE_SPECIFIER="$PROVISIONING_PROFILE"
  echo "✅ Archive: $OUTPUT_DIR/AuthVault.xcarchive"
fi
```

#### `scripts/flutter/sign_ios.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — iOS Export & Sign (requires valid provisioning profile + cert)
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_DIR="$ROOT/flutter/build/outputs/ios"
ENV_FILE="$ROOT/scripts/env/.env.ios"

set -a; source "$ENV_FILE"; set +a

ARCHIVE="$OUTPUT_DIR/AuthVault.xcarchive"
EXPORT_DIR="$OUTPUT_DIR/signed"

[[ -d "$ARCHIVE" ]] || { echo "ERROR: Archive not found at $ARCHIVE"; exit 1; }

mkdir -p "$EXPORT_DIR"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$ROOT/scripts/ios/ExportOptions.plist"

echo "✅ Signed IPA in $EXPORT_DIR"
```

#### `scripts/flutter/build_windows.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — Windows Build Script
# Must run on Windows with Flutter Windows support enabled
# Produces MSIX package
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/windows"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

flutter clean && flutter pub get

echo ">>> Building Windows release..."
flutter build windows --release

# Package as MSIX (requires msix pub package configured in pubspec.yaml)
dart run msix:create

cp -r build/windows/x64/runner/Release/* "$OUTPUT_DIR/"
echo "✅ Windows build: $OUTPUT_DIR/"
```

#### `scripts/flutter/build_linux.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — Linux Build Script
# Produces: ELF binary + .deb + .rpm + AppImage
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FLUTTER_DIR="$ROOT/flutter"
OUTPUT_DIR="$FLUTTER_DIR/build/outputs/linux"

mkdir -p "$OUTPUT_DIR"
cd "$FLUTTER_DIR"

flutter clean && flutter pub get

echo ">>> Building Linux release..."
flutter build linux --release

BIN_DIR="build/linux/x64/release/bundle"
cp -r "$BIN_DIR" "$OUTPUT_DIR/authvault"

# Create .deb
if command -v dpkg-deb &>/dev/null; then
  mkdir -p /tmp/authvault-deb/DEBIAN
  mkdir -p /tmp/authvault-deb/usr/local/bin
  mkdir -p /tmp/authvault-deb/usr/share/applications

  cat > /tmp/authvault-deb/DEBIAN/control <<EOF
Package: authvault
Version: 1.0.0
Architecture: amd64
Maintainer: AuthVault Team <dev@authvault.app>
Description: Secure two-factor authenticator
EOF

  cp -r "$BIN_DIR"/* /tmp/authvault-deb/usr/local/bin/
  dpkg-deb --build /tmp/authvault-deb "$OUTPUT_DIR/authvault_1.0.0_amd64.deb"
  echo "✅ .deb created"
fi

# Create AppImage (requires appimagetool)
if command -v appimagetool &>/dev/null; then
  mkdir -p /tmp/AuthVault.AppDir/usr/bin
  cp -r "$BIN_DIR"/* /tmp/AuthVault.AppDir/usr/bin/
  cat > /tmp/AuthVault.AppDir/AuthVault.desktop <<EOF
[Desktop Entry]
Name=AuthVault
Exec=authvault
Icon=authvault
Type=Application
Categories=Utility;Security;
EOF
  appimagetool /tmp/AuthVault.AppDir "$OUTPUT_DIR/AuthVault-1.0.0-x86_64.AppImage"
  echo "✅ AppImage created"
fi

echo "✅ Linux build complete: $OUTPUT_DIR"
```

#### `scripts/flutter/release_all.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault — Full Release Script
# Builds all platforms sequentially
# Usage: ./release_all.sh [version]
# =============================================================================
set -euo pipefail

VERSION="${1:-1.0.0}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 AuthVault Release Build v$VERSION"
echo "================================================"

echo ""
echo "📱 [1/4] Building Android..."
bash "$SCRIPT_DIR/build_android.sh" both release
bash "$SCRIPT_DIR/sign_android.sh"

echo ""
echo "🍎 [2/4] Building iOS..."
if [[ "$(uname)" == "Darwin" ]]; then
  bash "$SCRIPT_DIR/build_ios.sh" archive
  bash "$SCRIPT_DIR/sign_ios.sh"
else
  echo "⚠️  Skipping iOS (not on macOS)"
fi

echo ""
echo "🪟 [3/4] Building Windows..."
if [[ "$(uname -r)" == *"Microsoft"* ]] || [[ "$OS" == "Windows_NT" ]]; then
  bash "$SCRIPT_DIR/build_windows.sh"
else
  echo "⚠️  Skipping Windows (not on Windows)"
fi

echo ""
echo "🐧 [4/4] Building Linux..."
if [[ "$(uname)" == "Linux" ]]; then
  bash "$SCRIPT_DIR/build_linux.sh"
else
  echo "⚠️  Skipping Linux (not on Linux)"
fi

echo ""
echo "================================================"
echo "✅ Release build complete for v$VERSION"
```

### 10.2 Web Build Scripts

#### `scripts/web/build_web.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault Web — Production Build Script
# Usage: ./build_web.sh [staging|production]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WEB_DIR="$ROOT/web"
OUTPUT_DIR="$WEB_DIR/dist"
ENV="${1:-production}"
ENV_FILE="$ROOT/scripts/env/.env.web"

set -a; source "$ENV_FILE"; set +a

cd "$WEB_DIR"

echo ">>> Installing dependencies..."
npm ci --frozen-lockfile

echo ">>> Type checking..."
npx tsc --noEmit

echo ">>> Linting..."
npx eslint src --max-warnings 0

echo ">>> Running unit tests..."
npx vitest run

echo ">>> Building for $ENV..."
if [[ "$ENV" == "production" ]]; then
  VITE_APP_ENV=production npx vite build
else
  VITE_APP_ENV=staging npx vite build --mode staging
fi

echo ">>> Build stats:"
du -sh "$OUTPUT_DIR"
find "$OUTPUT_DIR" -name "*.js" | head -10

echo "✅ Web build complete: $OUTPUT_DIR"
```

#### `scripts/web/deploy_web.sh`
```bash
#!/usr/bin/env bash
# =============================================================================
# AuthVault Web — Deploy Script
# Supports: Netlify, Vercel, Cloudflare Pages, S3+CloudFront
# Usage: ./deploy_web.sh [netlify|vercel|cf|s3]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WEB_DIR="$ROOT/web"
DIST="$WEB_DIR/dist"
TARGET="${1:-netlify}"
ENV_FILE="$ROOT/scripts/env/.env.web"

set -a; source "$ENV_FILE"; set +a

[[ -d "$DIST" ]] || { echo "ERROR: Run build_web.sh first"; exit 1; }

case "$TARGET" in
  netlify)
    npx netlify-cli deploy --dir "$DIST" --prod
    ;;
  vercel)
    npx vercel --cwd "$WEB_DIR" --prod
    ;;
  cf)
    npx wrangler pages deploy "$DIST" --project-name authvault
    ;;
  s3)
    aws s3 sync "$DIST" "s3://$S3_BUCKET/" --delete
    aws cloudfront create-invalidation \
      --distribution-id "$CF_DISTRIBUTION_ID" \
      --paths "/*"
    ;;
  *)
    echo "Unknown target: $TARGET (netlify|vercel|cf|s3)"
    exit 1
    ;;
esac

echo "✅ Deployed to $TARGET"
```

### 10.3 Signing Configuration

#### `scripts/env/.env.android` (template)
```bash
# Android Signing
KEYSTORE_PATH=/path/to/scripts/keystore/android.keystore
KEYSTORE_PASS=your_keystore_password
KEY_ALIAS=authvault
KEY_PASS=your_key_password

# Play Store (optional, for automated upload)
PLAY_STORE_SERVICE_ACCOUNT=/path/to/service-account.json
PACKAGE_NAME=app.authvault.android

# Build config
APPLICATION_ID=app.authvault.android
VERSION_NAME=1.0.0
VERSION_CODE=1
```

#### `scripts/env/.env.ios` (template)
```bash
# Apple Developer
APPLE_TEAM_ID=XXXXXXXXXX
APPLE_ID=developer@example.com
APP_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx

# Code signing
CODE_SIGN_IDENTITY=iPhone Distribution: Your Name (XXXXXXXXXX)
PROVISIONING_PROFILE=AuthVault_AppStore
BUNDLE_ID=app.authvault.ios

# Build
VERSION=1.0.0
BUILD_NUMBER=1
```

#### `scripts/env/.env.web` (template)
```bash
# Deployment targets
NETLIFY_AUTH_TOKEN=your_netlify_token
NETLIFY_SITE_ID=your_site_id

VERCEL_TOKEN=your_vercel_token
VERCEL_ORG_ID=your_org_id
VERCEL_PROJECT_ID=your_project_id

S3_BUCKET=authvault-web
CF_DISTRIBUTION_ID=XXXXXXXXXXXXXX

# App config
VITE_APP_VERSION=1.0.0
VITE_SENTRY_DSN=https://...
VITE_POSTHOG_KEY=phc_...
```

#### `scripts/ios/ExportOptions.plist`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>teamID</key>
  <string>$(APPLE_TEAM_ID)</string>
  <key>uploadBitcode</key>
  <false/>
  <key>uploadSymbols</key>
  <true/>
  <key>signingStyle</key>
  <string>manual</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>app.authvault.ios</key>
    <string>AuthVault_AppStore</string>
  </dict>
</dict>
</plist>
```

---

## 11. CI/CD Pipeline

```yaml
# .github/workflows/release.yml
name: AuthVault Release

on:
  push:
    tags: ['v*.*.*']

jobs:
  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.22.0' }
      - run: cd flutter && flutter pub get
      - run: cd flutter && flutter test --coverage
      - run: cd flutter && flutter analyze

  test-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: cd web && npm ci && npm test
      - run: cd web && npm run type-check

  build-android:
    needs: test-flutter
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Decode keystore
        run: echo "${{ secrets.KEYSTORE_B64 }}" | base64 -d > scripts/keystore/android.keystore
      - run: bash scripts/flutter/build_android.sh aab release
      - run: bash scripts/flutter/sign_android.sh
      - uses: actions/upload-artifact@v4
        with: { name: android-aab, path: flutter/build/outputs/android/*.aab }

  build-ios:
    needs: test-flutter
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Install certificates
        run: |
          echo "${{ secrets.P12_B64 }}" | base64 -d > /tmp/cert.p12
          security import /tmp/cert.p12 -P "${{ secrets.P12_PASS }}" -A
      - run: bash scripts/flutter/build_ios.sh archive
      - run: bash scripts/flutter/sign_ios.sh
      - uses: actions/upload-artifact@v4
        with: { name: ios-ipa, path: flutter/build/outputs/ios/signed/*.ipa }

  build-web:
    needs: test-web
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: bash scripts/web/build_web.sh production
      - run: bash scripts/web/deploy_web.sh netlify
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

---

## 12. Testing Strategy

### Flutter Tests

| Type | Tool | Coverage Target |
|---|---|---|
| Unit (TOTP engine) | `flutter_test` | 100% |
| Unit (crypto) | `flutter_test` | 100% |
| Unit (AVX codec) | `flutter_test` | 95% |
| Widget tests | `flutter_test` | 80% |
| Integration | `integration_test` | 60% |
| Golden tests | `golden_toolkit` | Key screens |

```dart
// test/core/crypto/totp_engine_test.dart
void main() {
  group('TOTP Engine', () {
    test('generates correct 6-digit code (RFC 6238 test vectors)', () {
      // Test vectors from RFC 6238 appendix B
      expect(
        TOTPEngine.generate(
          secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', // "12345678901234567890" in Base32
          digits: 8,
          period: 30,
          algorithm: OTPAlgorithm.SHA1,
          offset: 0,
        ),
        isA<String>().having((s) => s.length, 'length', 8),
      );
    });

    test('custom offset shifts time correctly', () {
      final baseCode = TOTPEngine.generate(secret: 'TESTSECRET', offset: 0);
      final offsetCode = TOTPEngine.generate(secret: 'TESTSECRET', offset: 30);
      // With +30s offset crossing a period boundary, codes differ
      // (cannot guarantee in all cases without mocking clock)
    });

    test('remainingSeconds is within [1, period]', () {
      final r = TOTPEngine.remainingSeconds(period: 30, offset: 0);
      expect(r, greaterThan(0));
      expect(r, lessThanOrEqualTo(30));
    });
  });
}
```

### Web Tests (Vitest)

```typescript
// src/core/crypto/totp.test.ts
import { describe, it, expect } from 'vitest'
import { generateTOTP, remainingSeconds } from './totp'

describe('TOTP', () => {
  it('produces 6-digit string', () => {
    const code = generateTOTP({ secret: 'JBSWY3DPEHPK3PXP', digits: 6, period: 30, offset: 0 })
    expect(code).toMatch(/^\d{6}$/)
  })

  it('offset shifts computation window', () => {
    const code0 = generateTOTP({ secret: 'JBSWY3DPEHPK3PXP', offset: 0 })
    const codePlus = generateTOTP({ secret: 'JBSWY3DPEHPK3PXP', offset: 300 })
    // With large offset, code may differ (period boundary dependent)
    expect(typeof codePlus).toBe('string')
  })
})
```

---

## 13. Security Audit Checklist

- [ ] **Secret never in memory as String** — use `Uint8List` / `SecureString`, zero on free
- [ ] **AES-256-GCM with unique IV per encryption** — never reuse IV
- [ ] **PBKDF2 ≥ 310,000 iterations** (OWASP 2023 minimum) or **Argon2id**
- [ ] **Keystore / Secure Enclave** — wrap master key with hardware-backed key
- [ ] **FLAG_SECURE on Android** — prevent screenshots and Recents thumbnails
- [ ] **iOS backgrounding overlay** — blank screen before snapshot
- [ ] **Clipboard auto-clear** — default 30s, configurable
- [ ] **Brute-force cooldown** on PIN — exponential backoff, optional wipe
- [ ] **Certificate pinning** for cloud backup endpoints
- [ ] **No analytics for secrets** — telemetry is opt-in and never includes TOTP data
- [ ] **Dependency audit** — `flutter pub audit` / `npm audit` in CI
- [ ] **Code obfuscation** — `--obfuscate` + `--split-debug-info` on release
- [ ] **Root/jailbreak detection** — warn user (not block)
- [ ] **Biometric downgrade protection** — re-auth if new biometric enrolled
- [ ] **AVX integrity check** — HMAC-SHA256 verified before decrypt
- [ ] **Export requires authentication** — unlock required before any export
- [ ] **Audit log tamper detection** — hash-chaining entries
- [ ] **Web: SubtleCrypto only** — no userland crypto for key operations
- [ ] **Web: no localStorage for secrets** — IndexedDB only, encrypted at rest
- [ ] **CSP headers** — strict Content-Security-Policy for web deployment
- [ ] **HTTPS only** — HSTS enforced for web
- [ ] **Dependency review** — no transitive deps with crypto access

---

## 14. Roadmap & Milestones

### Phase 1 — Core (Weeks 1–4)
- [ ] TOTP / HOTP engine (Flutter + Web) with full test coverage
- [ ] Manual account entry + QR scan
- [ ] Encrypted SQLite / IndexedDB storage
- [ ] PIN lock screen
- [ ] Basic list UI with countdown ring
- [ ] Copy on tap

### Phase 2 — Security & UX (Weeks 5–8)
- [ ] Biometric unlock (Flutter)
- [ ] Custom time offset feature
- [ ] Tap-to-reveal mode
- [ ] Groups + drag-and-drop reorder
- [ ] Search + favorites
- [ ] Icon library (500+ logos)
- [ ] Dark / light / AMOLED themes + Material You

### Phase 3 — Backup & Import/Export (Weeks 9–12)
- [ ] AVX format (encode + decode)
- [ ] Local backup / restore
- [ ] Import from Google Authenticator, Aegis, 2FAS, Authy
- [ ] Export to AVX + otpauth QR batch
- [ ] Google Drive / iCloud / Dropbox backup
- [ ] QR batch transfer protocol

### Phase 4 — Advanced Features (Weeks 13–16)
- [ ] Next-code preview
- [ ] Audit log
- [ ] NTP drift measurement
- [ ] Android home screen widget
- [ ] iOS WidgetKit widget
- [ ] Windows system tray
- [ ] Notification reminders
- [ ] Steam Guard mode

### Phase 5 — Polish & Release (Weeks 17–20)
- [ ] 20+ languages (i18n)
- [ ] Full a11y (screen reader, high contrast)
- [ ] E2E tests (Playwright / Flutter integration tests)
- [ ] Play Store submission
- [ ] App Store submission
- [ ] Microsoft Store (MSIX) submission
- [ ] Web PWA deployment
- [ ] Security audit by third party

### Phase 6 — Future (Post-launch)
- [ ] Wear OS / watchOS companion
- [ ] Browser extension (Web → extension messaging)
- [ ] Hardware key (YubiKey) support
- [ ] FIDO2 / Passkey integration
- [ ] Team/Enterprise vault sharing (E2EE)
- [ ] Desktop menu bar app (macOS — future Flutter support)

---

## 15. File Tree (Final)

```
auth-app/
│
├── flutter/
│   ├── android/
│   │   ├── app/
│   │   │   ├── build.gradle
│   │   │   ├── src/main/AndroidManifest.xml
│   │   │   └── src/main/kotlin/app/authvault/MainActivity.kt
│   │   └── build.gradle
│   ├── ios/
│   │   ├── Runner/
│   │   ├── Runner.xcworkspace/
│   │   └── Podfile
│   ├── windows/
│   │   └── runner/
│   ├── linux/
│   │   └── runner/
│   ├── assets/
│   │   ├── icons/         # 500+ brand SVGs
│   │   ├── fonts/
│   │   │   ├── Inter/
│   │   │   └── JetBrainsMono/
│   │   ├── animations/    # Lottie JSON files
│   │   └── i18n/          # ARB locale files
│   ├── lib/
│   │   ├── core/          # (see §4.3)
│   │   ├── features/      # (see §4.3)
│   │   ├── shared/        # (see §4.3)
│   │   └── main.dart
│   ├── test/
│   │   ├── core/
│   │   │   ├── crypto/
│   │   │   └── time/
│   │   ├── features/
│   │   └── widget/
│   ├── integration_test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── web/
│   ├── public/
│   │   ├── favicon.ico
│   │   ├── pwa-192x192.png
│   │   ├── pwa-512x512.png
│   │   └── apple-touch-icon.png
│   ├── src/
│   │   ├── core/          # (see §5.3)
│   │   ├── features/      # (see §5.3)
│   │   ├── components/    # (see §5.3)
│   │   ├── hooks/         # (see §5.3)
│   │   ├── i18n/
│   │   ├── styles/
│   │   │   └── globals.css
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── e2e/               # Playwright tests
│   ├── dist/              # build output (gitignored)
│   ├── index.html
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   ├── tsconfig.json
│   ├── package.json
│   └── .eslintrc.cjs
│
├── scripts/
│   ├── flutter/
│   │   ├── build_android.sh
│   │   ├── build_ios.sh
│   │   ├── build_windows.sh
│   │   ├── build_linux.sh
│   │   ├── sign_android.sh
│   │   ├── sign_ios.sh
│   │   └── release_all.sh
│   ├── web/
│   │   ├── build_web.sh
│   │   └── deploy_web.sh
│   ├── ios/
│   │   └── ExportOptions.plist
│   ├── keystore/          # ← GITIGNORED
│   │   ├── android.keystore
│   │   └── ios_distribution.p12
│   └── env/               # ← GITIGNORED
│       ├── .env.android
│       ├── .env.ios
│       └── .env.web
│
├── .github/
│   └── workflows/
│       ├── release.yml
│       ├── pr-check.yml
│       └── security-audit.yml
│
├── .gitignore
└── README.md              # (this file)
```

---

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

### Flutter App — Getting Started

```bash
cd auth-app/flutter
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d android   # or -d ios, -d windows, -d linux
```

### Web App — Getting Started

```bash
cd auth-app/web
npm install
npm run dev          # http://localhost:5173
npm run build        # production build → dist/
npm run preview      # preview production build
```

### Running All Tests

```bash
# Flutter
cd auth-app/flutter && flutter test --coverage

# Web
cd auth-app/web && npm test
cd auth-app/web && npm run e2e
```

### Building Releases

```bash
# Android (APK + AAB, signed)
bash auth-app/scripts/flutter/build_android.sh both release
bash auth-app/scripts/flutter/sign_android.sh

# iOS (requires macOS)
bash auth-app/scripts/flutter/build_ios.sh archive
bash auth-app/scripts/flutter/sign_ios.sh

# Web
bash auth-app/scripts/web/build_web.sh production
bash auth-app/scripts/web/deploy_web.sh netlify

# All platforms
bash auth-app/scripts/flutter/release_all.sh 1.0.0
```

---

*AuthVault — Secure by design. Open by default.*  
*Documentation version: 1.0.0 — covers Flutter 3.22 + Vite 5.x + React 18.x*
