import 'package:drift/drift.dart';
import 'tables/accounts_table.dart';

part 'app_database.g.dart';

/// Main application database
/// 
/// Uses SQLite via drift with full encryption at rest
@DriftDatabase(tables: [Accounts, Groups, Settings, AuditLog])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Migration strategy for future schema changes
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert default settings
        await into(settings).insert(
          SettingsCompanion(
            key: const Value('theme'),
            value: const Value('system'),
          ),
        );
        await into(settings).insert(
          SettingsCompanion(
            key: const Value('lock_enabled'),
            value: const Value('true'),
          ),
        );
        await into(settings).insert(
          SettingsCompanion(
            key: const Value('global_time_offset'),
            value: const Value('0'),
          ),
        );
        await into(settings).insert(
          SettingsCompanion(
            key: const Value('tap_to_reveal'),
            value: const Value('false'),
          ),
        );
        await into(settings).insert(
          SettingsCompanion(
            key: const Value('clipboard_clear_seconds'),
            value: const Value('30'),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations
        if (from < 2) {
          // Example: await m.addColumn(accounts, newColumn);
        }
      },
    );
  }

  // Account queries
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  
  Future<List<Account>> getFavoriteAccounts() {
    return (select(accounts)..where((t) => t.favorite.equals(true)))
        .get();
  }
  
  Future<Account?> getAccountByUuid(String uuid) {
    return (select(accounts)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }
  
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }
  
  Future<bool> updateAccount(AccountsCompanion account) {
    return update(accounts).replace(account);
  }
  
  Future<int> deleteAccount(String uuid) {
    return (delete(accounts)..where((t) => t.uuid.equals(uuid))).go();
  }
  
  Future<void> reorderAccounts(List<int> ids) async {
    await transaction(() async {
      for (var i = 0; i < ids.length; i++) {
        await (update(accounts)..where((t) => t.id.equals(ids[i])))
            .write(AccountsCompanion(sortOrder: Value(i)));
      }
    });
  }

  // Group queries
  Future<List<Group>> getAllGroups() => select(groups).get();
  
  Future<Group?> getGroupByUuid(String uuid) {
    return (select(groups)..where((t) => t.uuid.equals(uuid)))
        .getSingleOrNull();
  }
  
  Future<int> insertGroup(GroupsCompanion group) {
    return into(groups).insert(group);
  }
  
  Future<bool> updateGroup(GroupsCompanion group) {
    return update(groups).replace(group);
  }
  
  Future<int> deleteGroup(String uuid) {
    return (delete(groups)..where((t) => t.uuid.equals(uuid))).go();
  }

  // Settings queries
  Future<String?> getSetting(String key) async {
    final setting = await (select(settings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }
  
  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(
        key: Value(key),
        value: Value(value),
      ),
    );
  }
  
  Future<int> getGlobalTimeOffset() async {
    final value = await getSetting('global_time_offset');
    return value != null ? int.parse(value) : 0;
  }
  
  Future<void> setGlobalTimeOffset(int seconds) async {
    await setSetting('global_time_offset', seconds.toString());
  }

  // Audit log queries
  Future<List<AuditLog>> getAuditLog({int limit = 100}) {
    return (select(auditLog)
          ..orderBy([
            (t) => OrderingTerm.desc(t.timestamp),
          ])
          ..limit(limit))
        .get();
  }
  
  Future<void> logAction(String action, {String? accountUuid, String? details}) {
    return into(auditLog).insert(
      AuditLogCompanion(
        action: Value(action),
        accountUuid: Value(accountUuid),
        details: Value(details),
        timestamp: Value(DateTime.now()),
      ),
    );
  }
  
  Future<void> clearAuditLog() {
    return delete(auditLog).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'authvault.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
