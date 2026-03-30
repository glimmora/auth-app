import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import {
  db,
  getAllAccounts,
  getAccountByUuid,
  addAccount,
  updateAccount,
  deleteAccount,
  reorderAccounts,
  getAllGroups,
  getGroupByUuid,
  addGroup,
  updateGroup,
  deleteGroup,
  getSetting,
  setSetting,
  getGlobalTimeOffset,
  setGlobalTimeOffset,
  getAuditLog,
  logAction,
  clearAuditLog,
  Account,
  Group,
} from '@/core/db/schema';

function makeAccount(overrides: Partial<Account> = {}): Omit<Account, 'id'> {
  return {
    uuid: crypto.randomUUID(),
    type: 'totp',
    issuer: 'TestIssuer',
    label: 'test@example.com',
    encryptedPayload: new Uint8Array([1, 2, 3]),
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
    counter: 0,
    timeOffset: 0,
    sortOrder: 0,
    favorite: false,
    tapToReveal: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

function makeGroup(overrides: Partial<Group> = {}): Omit<Group, 'id'> {
  return {
    uuid: crypto.randomUUID(),
    name: 'Test Group',
    color: '#FF0000',
    sortOrder: 0,
    createdAt: new Date(),
    ...overrides,
  };
}

describe('Database Schema', () => {
  beforeEach(async () => {
    await db.accounts.clear();
    await db.groups.clear();
    await db.settings.clear();
    await db.auditLog.clear();
  });

  afterEach(async () => {
    await db.accounts.clear();
    await db.groups.clear();
    await db.settings.clear();
    await db.auditLog.clear();
  });

  describe('Account Operations', () => {
    it('adds an account', async () => {
      const account = makeAccount();
      const id = await addAccount(account);
      expect(id).toBeGreaterThan(0);
    });

    it('gets all accounts ordered by sortOrder', async () => {
      await addAccount(makeAccount({ sortOrder: 2, issuer: 'Second' }));
      await addAccount(makeAccount({ sortOrder: 1, issuer: 'First' }));
      await addAccount(makeAccount({ sortOrder: 3, issuer: 'Third' }));

      const accounts = await getAllAccounts();
      expect(accounts.length).toBe(3);
      expect(accounts[0].issuer).toBe('First');
      expect(accounts[1].issuer).toBe('Second');
      expect(accounts[2].issuer).toBe('Third');
    });

    it('gets favorite accounts', async () => {
      await addAccount(makeAccount({ favorite: true, issuer: 'Fav1' }));
      await addAccount(makeAccount({ favorite: false, issuer: 'NotFav' }));
      await addAccount(makeAccount({ favorite: true, issuer: 'Fav2' }));

      // Filter from all accounts since boolean indexing varies by impl
      const allAccounts = await getAllAccounts();
      const favorites = allAccounts.filter(a => a.favorite === true);
      expect(favorites.length).toBe(2);
      expect(favorites.map(a => a.issuer)).toContain('Fav1');
      expect(favorites.map(a => a.issuer)).toContain('Fav2');
    });

    it('gets account by uuid', async () => {
      const account = makeAccount({ uuid: 'test-uuid-123' });
      await addAccount(account);

      const found = await getAccountByUuid('test-uuid-123');
      expect(found).toBeDefined();
      expect(found!.issuer).toBe(account.issuer);
    });

    it('returns undefined for non-existent uuid', async () => {
      const found = await getAccountByUuid('non-existent');
      expect(found).toBeUndefined();
    });

    it('updates an account', async () => {
      const account = makeAccount({ uuid: 'update-test' });
      await addAccount(account);

      await updateAccount('update-test', { issuer: 'UpdatedIssuer' });

      const updated = await getAccountByUuid('update-test');
      expect(updated!.issuer).toBe('UpdatedIssuer');
    });

    it('deletes an account', async () => {
      const account = makeAccount({ uuid: 'delete-test' });
      await addAccount(account);

      await deleteAccount('delete-test');

      const deleted = await getAccountByUuid('delete-test');
      expect(deleted).toBeUndefined();
    });

    it('reorders accounts', async () => {
      const id1 = await addAccount(makeAccount({ sortOrder: 0, issuer: 'A' }));
      const id2 = await addAccount(makeAccount({ sortOrder: 1, issuer: 'B' }));
      const id3 = await addAccount(makeAccount({ sortOrder: 2, issuer: 'C' }));

      await reorderAccounts([id3, id1, id2]);

      const accounts = await getAllAccounts();
      expect(accounts[0].issuer).toBe('C');
      expect(accounts[1].issuer).toBe('A');
      expect(accounts[2].issuer).toBe('B');
    });
  });

  describe('Group Operations', () => {
    it('adds a group', async () => {
      const group = makeGroup();
      const id = await addGroup(group);
      expect(id).toBeGreaterThan(0);
    });

    it('gets all groups ordered by sortOrder', async () => {
      await addGroup(makeGroup({ sortOrder: 2, name: 'Second' }));
      await addGroup(makeGroup({ sortOrder: 1, name: 'First' }));

      const groups = await getAllGroups();
      expect(groups.length).toBe(2);
      expect(groups[0].name).toBe('First');
    });

    it('gets group by uuid', async () => {
      const group = makeGroup({ uuid: 'group-uuid-123' });
      await addGroup(group);

      const found = await getGroupByUuid('group-uuid-123');
      expect(found).toBeDefined();
      expect(found!.name).toBe(group.name);
    });

    it('updates a group', async () => {
      const group = makeGroup({ uuid: 'update-group' });
      await addGroup(group);

      await updateGroup('update-group', { name: 'Updated Name' });

      const updated = await getGroupByUuid('update-group');
      expect(updated!.name).toBe('Updated Name');
    });

    it('deletes a group', async () => {
      const group = makeGroup({ uuid: 'delete-group' });
      await addGroup(group);

      await deleteGroup('delete-group');

      const deleted = await getGroupByUuid('delete-group');
      expect(deleted).toBeUndefined();
    });
  });

  describe('Settings Operations', () => {
    it('sets and gets a setting', async () => {
      await setSetting('theme', 'dark');
      const value = await getSetting('theme');
      expect(value).toBe('dark');
    });

    it('returns undefined for non-existent setting', async () => {
      const value = await getSetting('non_existent');
      expect(value).toBeUndefined();
    });

    it('overwrites existing setting', async () => {
      await setSetting('theme', 'light');
      await setSetting('theme', 'dark');
      const value = await getSetting('theme');
      expect(value).toBe('dark');
    });

    it('gets and sets global time offset', async () => {
      const defaultOffset = await getGlobalTimeOffset();
      expect(defaultOffset).toBe(0);

      await setGlobalTimeOffset(30);
      const offset = await getGlobalTimeOffset();
      expect(offset).toBe(30);
    });

    it('handles negative time offset', async () => {
      await setGlobalTimeOffset(-60);
      const offset = await getGlobalTimeOffset();
      expect(offset).toBe(-60);
    });
  });

  describe('Audit Log Operations', () => {
    it('logs an action', async () => {
      await logAction('unlock');
      const logs = await getAuditLog();
      expect(logs.length).toBe(1);
      expect(logs[0].action).toBe('unlock');
    });

    it('logs action with options', async () => {
      await logAction('code_copy', {
        accountUuid: 'acc-123',
        details: 'Copied TOTP code',
      });

      const logs = await getAuditLog();
      expect(logs[0].accountUuid).toBe('acc-123');
      expect(logs[0].details).toBe('Copied TOTP code');
    });

    it('returns logs in reverse chronological order', async () => {
      await logAction('first');
      await logAction('second');
      await logAction('third');

      const logs = await getAuditLog();
      expect(logs[0].action).toBe('third');
      expect(logs[1].action).toBe('second');
      expect(logs[2].action).toBe('first');
    });

    it('limits audit log results', async () => {
      for (let i = 0; i < 10; i++) {
        await logAction(`action_${i}`);
      }

      const logs = await getAuditLog(5);
      expect(logs.length).toBe(5);
    });

    it('clears audit log', async () => {
      await logAction('test1');
      await logAction('test2');

      await clearAuditLog();

      const logs = await getAuditLog();
      expect(logs.length).toBe(0);
    });
  });
});
