import { describe, it, expect, vi } from 'vitest';

vi.mock('file-saver', () => ({
  saveAs: vi.fn(),
}));

import { exportToAVX, importFromAVX, AVXData } from '@/core/avx/encoder';

function makeTestData(): AVXData {
  return {
    accounts: [
      {
        uuid: 'acc-001',
        type: 'totp',
        issuer: 'Google',
        label: 'user@example.com',
        secret: 'JBSWY3DPEHPK3PXP',
        algorithm: 'SHA1',
        digits: 6,
        period: 30,
        counter: 0,
        time_offset: 0,
        sort_order: 0,
        favorite: false,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
      },
      {
        uuid: 'acc-002',
        type: 'hotp',
        issuer: 'GitHub',
        label: 'developer@example.com',
        secret: 'GEZDGNBVGY3TQOJQ',
        algorithm: 'SHA256',
        digits: 6,
        period: 30,
        counter: 5,
        time_offset: 0,
        sort_order: 1,
        favorite: true,
        created_at: '2024-01-02T00:00:00Z',
        updated_at: '2024-01-02T00:00:00Z',
      },
    ],
    groups: [
      {
        uuid: 'grp-001',
        name: 'Work',
        color: '#FF5733',
        sort_order: 0,
      },
    ],
    settings: {
      global_time_offset: 0,
      theme: 'dark',
      tap_to_reveal: true,
    },
  };
}

describe('AVX Encoder', () => {
  it('exports and imports data round-trip', async () => {
    const data = makeTestData();
    const password = 'testPassword123';

    const blob = await exportToAVX(data, password);
    expect(blob).toBeInstanceOf(Blob);
    expect(blob.size).toBeGreaterThan(0);

    const file = new File([blob], 'backup.avx', { type: 'application/octet-stream' });
    const imported = await importFromAVX(file, password);

    expect(imported.accounts.length).toBe(2);
    expect(imported.accounts[0].issuer).toBe('Google');
    expect(imported.accounts[0].label).toBe('user@example.com');
    expect(imported.accounts[1].issuer).toBe('GitHub');
    expect(imported.accounts[1].counter).toBe(5);
    expect(imported.groups.length).toBe(1);
    expect(imported.groups[0].name).toBe('Work');
    expect(imported.settings.theme).toBe('dark');
    expect(imported.settings.tap_to_reveal).toBe(true);
  });

  it('fails to import with wrong password', async () => {
    const data = makeTestData();
    const blob = await exportToAVX(data, 'correctPassword');

    const file = new File([blob], 'backup.avx', { type: 'application/octet-stream' });

    await expect(importFromAVX(file, 'wrongPassword')).rejects.toThrow();
  });

  it('handles empty accounts list', async () => {
    const data: AVXData = {
      accounts: [],
      groups: [],
      settings: {
        global_time_offset: 0,
        theme: 'light',
        tap_to_reveal: false,
      },
    };

    const blob = await exportToAVX(data, 'password');
    const file = new File([blob], 'backup.avx', { type: 'application/octet-stream' });
    const imported = await importFromAVX(file, 'password');

    expect(imported.accounts.length).toBe(0);
    expect(imported.groups.length).toBe(0);
  });

  it('preserves all account fields', async () => {
    const data = makeTestData();
    const blob = await exportToAVX(data, 'pass');
    const file = new File([blob], 'backup.avx', { type: 'application/octet-stream' });
    const imported = await importFromAVX(file, 'pass');

    const acc = imported.accounts[0];
    expect(acc.uuid).toBe('acc-001');
    expect(acc.type).toBe('totp');
    expect(acc.algorithm).toBe('SHA1');
    expect(acc.digits).toBe(6);
    expect(acc.period).toBe(30);
    expect(acc.counter).toBe(0);
    expect(acc.time_offset).toBe(0);
    expect(acc.favorite).toBe(false);
  });

  it('throws for invalid AVX file', async () => {
    const invalidBlob = new Blob(['not a zip file'], { type: 'application/octet-stream' });
    const file = new File([invalidBlob], 'invalid.avx', { type: 'application/octet-stream' });

    await expect(importFromAVX(file, 'password')).rejects.toThrow();
  });
});
