# AuthVault — Flutter App

Cross-platform TOTP/HOTP authenticator for Android, iOS, Windows, and Linux.

## Structure

```
lib/
├── core/
│   ├── crypto/        # TOTP/HOTP engine, AES-256-GCM, key derivation
│   ├── database/      # SQLite (drift) schema and queries
│   ├── router/        # go_router configuration
│   ├── theme/         # FlexColorScheme themes (light/dark/AMOLED)
│   ├── time/          # Time offset and NTP drift service
│   └── utils/         # Base32, Steam Guard, helpers
├── features/
│   ├── accounts/      # Account list, add/edit, QR scan, manual entry
│   ├── auth_lock/     # PIN setup, lock screen, biometric
│   ├── backup/        # AVX export/import, cloud backup
│   └── settings/      # Settings, time offset, theme picker
└── main.dart          # App entry point
```

## Build

```bash
# Android (split APKs, signed)
flutter build apk --release --split-per-abi --android-skip-build-dependency-validation

# Web
flutter build web --no-wasm-dry-run

# Debug run
flutter run
```

## Dependencies

Key packages:

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing |
| `drift` | SQLite ORM |
| `flutter_secure_storage` | Encrypted key storage |
| `local_auth` | Biometric authentication |
| `mobile_scanner` | QR code scanning |
| `flex_color_scheme` | Material 3 theming |
| `cryptography` | AES-256-GCM encryption |
| `pointycastle` | HOTP/TOTP crypto primitives |

Run `flutter pub get` to install all dependencies.

## Testing

```bash
flutter test              # Unit + widget tests
flutter test --coverage   # With coverage report
```
