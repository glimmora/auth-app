import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart' as drift;
import '../crypto/otp_algorithm_impl.dart';
import '../../features/accounts/domain/account.dart' as domain;

/// Database provider
final databaseProvider = Provider<drift.AppDatabase>((ref) {
  return drift.AppDatabase();
});

/// OTP Algorithm provider
final otpAlgorithmProvider = Provider<OtpAlgorithm>((ref) {
  return OtpAlgorithm();
});

/// Settings provider - watches all settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, domain.AppSettings>((ref) {
  return SettingsNotifier(ref.watch(databaseProvider));
});

/// Settings notifier
class SettingsNotifier extends StateNotifier<domain.AppSettings> {
  final drift.AppDatabase _db;

  SettingsNotifier(this._db)
      : super(const domain.AppSettings(
          theme: 'system',
          lockEnabled: true,
          globalTimeOffset: 0,
          tapToReveal: false,
          clipboardClearSeconds: 30,
          biometricEnabled: true,
          pinHash: null,
          pinSalt: null,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await _db.getSetting('theme') ?? 'system';
    final lockEnabled = (await _db.getSetting('lock_enabled')) == 'true';
    final globalTimeOffset = await _db.getGlobalTimeOffset();
    final tapToReveal = (await _db.getSetting('tap_to_reveal')) == 'true';
    final clipboardClearSeconds =
        int.parse(await _db.getSetting('clipboard_clear_seconds') ?? '30');
    final biometricEnabled =
        (await _db.getSetting('biometric_enabled')) == 'true';
    final pinHash = await _db.getSetting('pin_hash');
    final pinSaltBase64 = await _db.getSetting('pin_salt');
    final pinSalt =
        pinSaltBase64 != null ? base64Decode(pinSaltBase64) : null;

    state = domain.AppSettings(
      theme: theme,
      lockEnabled: lockEnabled,
      globalTimeOffset: globalTimeOffset,
      tapToReveal: tapToReveal,
      clipboardClearSeconds: clipboardClearSeconds,
      biometricEnabled: biometricEnabled,
      pinHash: pinHash,
      pinSalt: pinSalt,
    );
  }

  Future<void> setTheme(String theme) async {
    await _db.setSetting('theme', theme);
    state = state.copyWith(theme: theme);
  }

  Future<void> setLockEnabled(bool enabled) async {
    await _db.setSetting('lock_enabled', enabled.toString());
    state = state.copyWith(lockEnabled: enabled);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _db.setSetting('biometric_enabled', enabled.toString());
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> setGlobalTimeOffset(int seconds) async {
    await _db.setGlobalTimeOffset(seconds);
    state = state.copyWith(globalTimeOffset: seconds);
  }

  Future<void> setTapToReveal(bool enabled) async {
    await _db.setSetting('tap_to_reveal', enabled.toString());
    state = state.copyWith(tapToReveal: enabled);
  }

  Future<void> setClipboardClearSeconds(int seconds) async {
    await _db.setSetting('clipboard_clear_seconds', seconds.toString());
    state = state.copyWith(clipboardClearSeconds: seconds);
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _db.setSetting('pin_hash', hash);
    await _db.setSetting('pin_salt', base64Encode(salt));
    state = state.copyWith(pinHash: hash, pinSalt: salt);
  }

  Future<bool> verifyPin(String pin) async {
    if (state.pinHash == null || state.pinSalt == null) {
      return false;
    }
    final hash = _hashPin(pin, state.pinSalt!);
    return hash == state.pinHash;
  }

  bool get hasPin => state.pinHash != null;

  String _hashPin(String pin, Uint8List salt) {
    final saltedPin = Uint8List.fromList(
      [...salt, ...utf8.encode(pin)],
    );
    return sha256.convert(saltedPin).toString();
  }

  Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
  }
}

/// Accounts provider - watches all accounts
final accountsProvider = StateNotifierProvider<AccountsNotifier, List<domain.Account>>((ref) {
  return AccountsNotifier(ref.watch(databaseProvider));
});

/// Accounts notifier
class AccountsNotifier extends StateNotifier<List<domain.Account>> {
  final drift.AppDatabase _db;
  final OtpAlgorithm _otp;

  AccountsNotifier(this._db)
      : _otp = OtpAlgorithm(),
        super([]) {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _db.getAllAccounts();
    state = accounts.map((a) => domain.Account.fromJson(a.toJson())).toList();
  }

  Future<void> addAccount({
    required String issuer,
    required String label,
    required String secret,
    required domain.AccountType type,
    String algorithm = 'SHA1',
    int digits = 6,
    int period = 30,
    int counter = 0,
    String? iconName,
    Uint8List? iconCustom,
  }) async {
    final account = drift.AccountsCompanion(
      uuid: Value(const Uuid().v4()),
      type: Value(type.name),
      issuer: Value(issuer),
      label: Value(label),
      encryptedSecret: Value(secret),
      algorithm: Value(algorithm),
      digits: Value(digits),
      period: Value(period),
      counter: Value(counter),
      timeOffset: Value(0),
      groupId: const Value(null),
      iconName: Value(iconName),
      iconCustom: Value(iconCustom),
      sortOrder: Value(state.length),
      favorite: const Value(false),
      tapToReveal: const Value(false),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    await _db.insertAccount(account);
    await _loadAccounts();
  }

  Future<void> deleteAccount(String uuid) async {
    await _db.deleteAccount(uuid);
    await _loadAccounts();
  }

  Future<void> toggleFavorite(String uuid) async {
    final account = state.firstWhere((a) => a.uuid == uuid);
    await _db.updateAccount(
      drift.AccountsCompanion(
        favorite: Value(!account.favorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _loadAccounts();
  }

  Future<void> updateAccount(String uuid, domain.Account account) async {
    await _db.updateAccount(
      drift.AccountsCompanion(
        issuer: Value(account.issuer),
        label: Value(account.label),
        encryptedSecret: Value(account.encryptedSecret),
        algorithm: Value(account.algorithm),
        digits: Value(account.digits),
        period: Value(account.period),
        counter: Value(account.counter),
        timeOffset: Value(account.timeOffset),
        iconName: Value(account.iconName),
        iconCustom: Value(account.iconCustom),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _loadAccounts();
  }

  String generateTOTP(domain.Account account) {
    return _otp.generateTOTP(
      secret: account.encryptedSecret,
      algorithm: account.algorithm,
      digits: account.digits,
      period: account.period,
      timeOffset: account.timeOffset,
    );
  }

  int getTimeRemaining(domain.Account account) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final period = account.period;
    return period - (now % period);
  }
}

/// Lock state provider
final lockStateProvider = StateNotifierProvider<LockStateNotifier, LockState>((ref) {
  return LockStateNotifier();
});

/// Lock state
enum LockState {
  unlocked,
  locked,
  setupRequired,
}

/// Lock state notifier
class LockStateNotifier extends StateNotifier<LockState> {
  LockStateNotifier() : super(LockState.setupRequired);

  void setUnlocked() {
    state = LockState.unlocked;
  }

  void setLocked() {
    state = LockState.locked;
  }

  void setSetupRequired() {
    state = LockState.setupRequired;
  }
}

/// Current OTP codes provider (auto-refreshing)
final otpCodesProvider = StreamProvider<Map<String, String>>((ref) async* {
  final accounts = ref.watch(accountsProvider);
  final accountsNotifier = ref.read(accountsProvider.notifier);

  while (true) {
    final codes = <String, String>{};
    for (final account in accounts) {
      try {
        codes[account.uuid] = accountsNotifier.generateTOTP(account);
      } catch (e) {
        codes[account.uuid] = 'Error';
      }
    }
    yield codes;
    await Future.delayed(const Duration(seconds: 1));
  }
});
