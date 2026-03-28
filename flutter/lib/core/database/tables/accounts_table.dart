import 'package:drift/drift.dart';

/// Accounts table - stores TOTP/HOTP account information
/// All sensitive fields are encrypted at rest
class Accounts extends Table {
  /// Primary key (auto-increment)
  IntColumn get id => integer().autoIncrement()();
  
  /// Unique identifier (UUID)
  TextColumn get uuid => text().unique()();
  
  /// Account type: totp, hotp, or steam
  TextColumn get type => text()();
  
  /// Service issuer (e.g., "GitHub", "Google")
  TextColumn get issuer => text()();
  
  /// Account label (e.g., user email)
  TextColumn get label => text()();
  
  /// Encrypted secret (Base32-encoded, then AES-256-GCM encrypted)
  TextColumn get encryptedSecret => text()();
  
  /// Hash algorithm: SHA1, SHA256, SHA512
  TextColumn get algorithm => text().withDefault(const Constant('SHA1'))();
  
  /// Number of digits in the code (6, 7, or 8)
  IntColumn get digits => integer().withDefault(const Constant(6))();
  
  /// Time period in seconds (15, 30, 60, 90, 120)
  IntColumn get period => integer().withDefault(const Constant(30))();
  
  /// Counter value (for HOTP only)
  IntColumn get counter => integer().withDefault(const Constant(0))();
  
  /// Custom time offset in seconds (±300 max)
  IntColumn get timeOffset => integer().withDefault(const Constant(0))();
  
  /// Foreign key to groups table
  IntColumn get groupId => integer().nullable().references(Groups, #id)();
  
  /// Built-in icon name
  TextColumn get iconName => text().nullable()();
  
  /// Custom icon (SVG/PNG as bytes, stored as base64)
  BlobColumn get iconCustom => blob().nullable()();
  
  /// Sort order in the list
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  /// Whether account is favorited (pinned to top)
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  
  /// Whether tap-to-reveal mode is enabled
  BoolColumn get tapToReveal => boolean().withDefault(const Constant(false))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime()();
}

/// Groups table - for organizing accounts
class Groups extends Table {
  /// Primary key (auto-increment)
  IntColumn get id => integer().autoIncrement()();
  
  /// Unique identifier (UUID)
  TextColumn get uuid => text().unique()();
  
  /// Group name
  TextColumn get name => text()();
  
  /// Group color (hex string)
  TextColumn get color => text().withDefault(const Constant('#2196F3'))();
  
  /// Sort order
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
}

/// Settings table - key-value store for app settings
class Settings extends Table {
  /// Setting key
  TextColumn get key => text()();
  
  /// Setting value (JSON-encoded)
  TextColumn get value => text()();
  
  @override
  Set<Column> get primaryKey => {key};
}

/// Audit log table - tracks security-relevant actions
class AuditLog extends Table {
  /// Primary key (auto-increment)
  IntColumn get id => integer().autoIncrement()();
  
  /// Action type: UNLOCK, COPY_CODE, EXPORT, IMPORT, DELETE, etc.
  TextColumn get action => text()();
  
  /// Associated account UUID (nullable)
  TextColumn get accountUuid => text().nullable()();
  
  /// Additional details (JSON-encoded)
  TextColumn get details => text().nullable()();
  
  /// Timestamp
  DateTimeColumn get timestamp => dateTime()();
}
