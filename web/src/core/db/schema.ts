import Dexie, { Table } from 'dexie';

export interface Account {
  id?: number;
  uuid: string;
  type: 'totp' | 'hotp' | 'steam';
  issuer: string;
  label: string;
  encryptedPayload: Uint8Array; // Encrypted secret + metadata
  algorithm: string;
  digits: number;
  period: number;
  counter: number;
  timeOffset: number;
  groupId?: number;
  iconName?: string;
  iconCustom?: Uint8Array;
  sortOrder: number;
  favorite: boolean;
  tapToReveal: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface Group {
  id?: number;
  uuid: string;
  name: string;
  color: string;
  sortOrder: number;
  createdAt: Date;
}

export interface Setting {
  key: string;
  value: string;
}

export interface AuditLog {
  id?: number;
  action: string;
  accountUuid?: string;
  details?: string;
  timestamp: Date;
}

class AuthVaultDB extends Dexie {
  accounts!: Table<Account, number>;
  groups!: Table<Group, number>;
  settings!: Table<Setting, string>;
  auditLog!: Table<AuditLog, number>;

  constructor() {
    super('AuthVaultDB');

    this.version(1).stores({
      accounts: '++id, uuid, issuer, label, groupId, sortOrder, favorite, createdAt',
      groups: '++id, uuid, name, color, sortOrder, createdAt',
      settings: 'key',
      auditLog: '++id, action, accountUuid, timestamp',
    });
  }
}

export const db = new AuthVaultDB();

/**
 * Account operations
 */
export async function getAllAccounts(): Promise<Account[]> {
  return await db.accounts.orderBy('sortOrder').toArray();
}

export async function getFavoriteAccounts(): Promise<Account[]> {
  return await db.accounts.where('favorite').equals(1).toArray();
}

export async function getAccountByUuid(uuid: string): Promise<Account | undefined> {
  return await db.accounts.where('uuid').equals(uuid).first();
}

export async function addAccount(account: Omit<Account, 'id'>): Promise<number> {
  return await db.accounts.add(account as Account);
}

export async function updateAccount(
  uuid: string,
  updates: Partial<Account>
): Promise<void> {
  const account = await getAccountByUuid(uuid);
  if (account && account.id) {
    await db.accounts.update(account.id, {
      ...updates,
      updatedAt: new Date(),
    });
  }
}

export async function deleteAccount(uuid: string): Promise<void> {
  const account = await getAccountByUuid(uuid);
  if (account && account.id) {
    await db.accounts.delete(account.id);
  }
}

export async function reorderAccounts(ids: number[]): Promise<void> {
  await db.transaction('rw', db.accounts, async () => {
    for (let i = 0; i < ids.length; i++) {
      await db.accounts.update(ids[i], { sortOrder: i });
    }
  });
}

/**
 * Group operations
 */
export async function getAllGroups(): Promise<Group[]> {
  return await db.groups.orderBy('sortOrder').toArray();
}

export async function getGroupByUuid(uuid: string): Promise<Group | undefined> {
  return await db.groups.where('uuid').equals(uuid).first();
}

export async function addGroup(group: Omit<Group, 'id'>): Promise<number> {
  return await db.groups.add(group as Group);
}

export async function updateGroup(
  uuid: string,
  updates: Partial<Group>
): Promise<void> {
  const group = await getGroupByUuid(uuid);
  if (group && group.id) {
    await db.groups.update(group.id, updates);
  }
}

export async function deleteGroup(uuid: string): Promise<void> {
  const group = await getGroupByUuid(uuid);
  if (group && group.id) {
    await db.groups.delete(group.id);
  }
}

/**
 * Settings operations
 */
export async function getSetting(key: string): Promise<string | undefined> {
  const setting = await db.settings.get(key);
  return setting?.value;
}

export async function setSetting(key: string, value: string): Promise<void> {
  await db.settings.put({ key, value });
}

export async function getGlobalTimeOffset(): Promise<number> {
  const value = await getSetting('global_time_offset');
  return value ? parseInt(value, 10) : 0;
}

export async function setGlobalTimeOffset(seconds: number): Promise<void> {
  await setSetting('global_time_offset', seconds.toString());
}

/**
 * Audit log operations
 */
export async function getAuditLog(limit: number = 100): Promise<AuditLog[]> {
  return await db.auditLog.orderBy('timestamp').reverse().limit(limit).toArray();
}

export async function logAction(
  action: string,
  options?: { accountUuid?: string; details?: string }
): Promise<void> {
  await db.auditLog.add({
    action,
    accountUuid: options?.accountUuid,
    details: options?.details,
    timestamp: new Date(),
  });
}

export async function clearAuditLog(): Promise<void> {
  await db.auditLog.clear();
}
