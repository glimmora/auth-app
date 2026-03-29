import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// JsonConverter for Uint8List to Base64 string
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    if (json == null) return null;
    return base64Decode(json);
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null) return null;
    return base64Encode(object);
  }
}

/// Account domain model
///
/// Represents a TOTP/HOTP/Steam account with all configuration
@freezed
class Account with _$Account {
  const factory Account({
    required int id,
    required String uuid,
    required AccountType type,
    required String issuer,
    required String label,
    required String encryptedSecret,
    required String algorithm,
    required int digits,
    required int period,
    required int counter,
    required int timeOffset,
    int? groupId,
    String? iconName,
    @Uint8ListConverter() Uint8List? iconCustom,
    required int sortOrder,
    required bool favorite,
    required bool tapToReveal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

/// Account type enumeration
enum AccountType {
  totp,
  hotp,
  steam,
}

extension AccountTypeExtension on AccountType {
  String get name {
    switch (this) {
      case AccountType.totp:
        return 'totp';
      case AccountType.hotp:
        return 'hotp';
      case AccountType.steam:
        return 'steam';
    }
  }

  static AccountType fromName(String name) {
    switch (name.toLowerCase()) {
      case 'totp':
        return AccountType.totp;
      case 'hotp':
        return AccountType.hotp;
      case 'steam':
        return AccountType.steam;
      default:
        return AccountType.totp;
    }
  }
}

/// Group domain model
@freezed
class Group with _$Group {
  const factory Group({
    required int id,
    required String uuid,
    required String name,
    required String color,
    required int sortOrder,
    required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

/// Settings domain model
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required String theme,
    required bool lockEnabled,
    required int globalTimeOffset,
    required bool tapToReveal,
    required int clipboardClearSeconds,
    required bool biometricEnabled,
    required String? pinHash,
    @Uint8ListConverter() Uint8List? pinSalt,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
