# AuthVault Scripts

Automation scripts for building, testing, and deploying AuthVault with intelligent caching.

## Quick Start

```bash
# First time: Fix everything (installs Android SDK, dependencies)
./scripts/fix.sh all

# Build Android app (split APKs + AAB, signed if keystore exists)
./scripts/build.sh android

# Run full pipeline: fix → test → build
./scripts/run.sh all linux

# Run tests
./scripts/test.sh full
```

## Scripts Reference

### 1. fix.sh
**Purpose:** Auto-fix issues and install dependencies (all cached)

```bash
./scripts/fix.sh all            # Fix everything (recommended first run)
./scripts/fix.sh sdk            # Install Android SDK only
./scripts/fix.sh deps           # Fix Flutter/Web dependencies
./scripts/fix.sh codegen        # Run code generation
./scripts/fix.sh format         # Format code
./scripts/fix.sh web            # Fix web project
```

**What it does:**
- ✅ Installs Flutter/Dart dependencies → cached in `.cache/pub/`
- ✅ Installs npm packages → cached in `.cache/npm/`
- ✅ **Installs Android SDK** → cached in `~/.Android/` (permanent)
- ✅ Runs code generation (build_runner)
- ✅ Formats code (dart format)
- ✅ Fixes imports and analysis issues
- ✅ Checks Android signing config

**Cache:** All downloads are cached permanently. Subsequent runs are 5-10x faster.

---

### 2. build.sh
**Purpose:** Build for all platforms (builds cached)

```bash
./scripts/build.sh all                  # Build all platforms
./scripts/build.sh android              # Android (split APKs + AAB)
./scripts/build.sh android release      # Android release build
./scripts/build.sh android debug true   # Android debug with split
./scripts/build.sh linux                # Linux desktop
./scripts/build.sh web                  # Web PWA
```

**Android Output:**
```
flutter/build/outputs/android/
├── app-armeabi-v7a-release.apk    # 32-bit ARM
├── app-arm64-v8a-release.apk      # 64-bit ARM (modern phones)
├── app-x86_64-release.apk         # 64-bit x86 (emulators)
└── app-release.aab                # Google Play bundle
```

**Signing:**
- Automatically signs if `scripts/keystore/authvault.keystore` exists
- Creates unsigned builds if no keystore
- Create keystore: `./scripts/setup-keystore.sh`

**Cache:** Build outputs are cached. Re-builds skip if outputs exist.

---

### 3. test.sh
**Purpose:** Run comprehensive tests (results cached 1 hour)

```bash
./scripts/test.sh full          # All tests
./scripts/test.sh quick         # Quick tests (analysis + unit)
./scripts/test.sh unit          # Unit tests only
./scripts/test.sh widget        # Widget tests
./scripts/test.sh security      # Security check (cached 24h)
./scripts/test.sh web           # Web tests (lint + types)
```

**Cache Duration:**
- Test results: 1 hour
- Security check: 24 hours

**Clear cache:** `rm -rf .cache/test/`

---

### 4. run.sh
**Purpose:** Full pipeline or run specific operations

```bash
./scripts/run.sh all linux          # Full pipeline: fix → test → build
./scripts/run.sh all android        # Full pipeline for Android
./scripts/run.sh fix                # Fix issues only
./scripts/run.sh test               # Run tests only
./scripts/run.sh build android      # Build Android only
./scripts/run.sh run linux          # Run Linux app
./scripts/run.sh run web            # Start web dev server
./scripts/run.sh run web-preview    # Start web preview server
```

**Pipeline:** `fix → test → build → (optional run)`

---

### 5. setup-keystore.sh
**Purpose:** Create and manage Android signing keystore

```bash
./scripts/setup-keystore.sh         # Create new keystore
./scripts/setup-keystore.sh info    # View keystore details
./scripts/setup-keystore.sh backup  # Create backup
./scripts/setup-keystore.sh verify app.apk  # Verify APK
```

**Keystore location:** `scripts/keystore/authvault.keystore`

---

## Cache System

### What's Cached

| Item | Location | Duration |
|------|----------|----------|
| Flutter pub packages | `.cache/pub/` | Permanent |
| npm packages | `.cache/npm/` | Permanent |
| Android SDK | `~/.Android/` | Permanent |
| Build outputs | `build/outputs/` | Until clean |
| Test results | `.cache/test/` | 1 hour |
| Security check | `.cache/test/` | 24 hours |

### Cache Performance

| Operation | First Run | Cached | Speedup |
|-----------|-----------|--------|---------|
| `fix.sh all` | 5-10 min | 1-2 min | 5-10x |
| `build.sh android` | 3-5 min | 30s | 6-10x |
| `test.sh full` | 5-10 min | 1-3 min | 3-5x |

### Cache Management

```bash
# View cache size
du -sh .cache/

# Clear specific cache
rm -rf .cache/test/      # Clear test results
rm -rf .cache/pub/       # Clear Flutter packages
rm -rf .cache/npm/       # Clear npm packages

# Clear all cache (re-download everything)
rm -rf .cache/

# Android SDK is cached in ~/.Android (don't delete)
```

---

## Android SDK Auto-Install

The scripts automatically install Android SDK on first run:

```bash
# This downloads and installs Android SDK (cached permanently)
./scripts/fix.sh sdk
```

**SDK installed to:** `~/.Android/`
**Includes:**
- platform-tools
- platforms;android-34
- build-tools;34.0.0
- cmdline-tools

**Manual setup (if auto-install fails):**

Add to `~/.bashrc`:
```bash
export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$PATH:$HOME/Android/cmdline-tools/latest/bin:$HOME/Android/platform-tools"
```

---

## Usage Examples

### First Time Setup

```bash
# 1. Fix everything (installs Android SDK, dependencies)
./scripts/fix.sh all

# 2. Create signing keystore (for Android releases)
./scripts/setup-keystore.sh

# 3. Build Android app
./scripts/build.sh android

# 4. Run full pipeline
./scripts/run.sh all linux
```

### Daily Development

```bash
# Quick fix and build
./scripts/run.sh all linux

# Just build Android
./scripts/build.sh android

# Run tests
./scripts/test.sh full

# Start web dev server
./scripts/run.sh run web
```

### CI/CD

```bash
# Fix (cached dependencies)
./scripts/fix.sh all

# Test (cached results)
./scripts/test.sh full

# Build all platforms
./scripts/build.sh all
```

---

## Troubleshooting

### "No Android SDK found"

```bash
# Auto-install (cached)
./scripts/fix.sh sdk
```

### "Signing not configured"

```bash
# Create keystore
./scripts/setup-keystore.sh
```

### "Build failed - undefined identifier"

```bash
# Re-run codegen
./scripts/fix.sh codegen
```

### "Test cache stale"

```bash
# Clear test cache
rm -rf .cache/test/

# Re-run tests
./scripts/test.sh full
```

### "Dependencies conflict"

```bash
# Clear and re-install
rm -rf .cache/pub/
rm -rf .cache/npm/
./scripts/fix.sh deps
```

---

## Environment Variables

Add to `~/.bashrc` for persistent setup:

```bash
# Android SDK
export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$PATH:$HOME/Android/cmdline-tools/latest/bin:$HOME/Android/platform-tools"

# Flutter
export PATH="$PATH:$HOME/flutter/bin"

# Caches
export PUB_CACHE="$HOME/auth-app/.cache/pub"
```

---

## Copyright

Copyright 2025-2026 AuthVault Team
