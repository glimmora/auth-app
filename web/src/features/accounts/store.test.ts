import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAccountStore } from '@/features/accounts/store';

vi.mock('@/core/db/schema', () => ({
  getAllAccounts: vi.fn().mockResolvedValue([
    {
      id: 1,
      uuid: 'acc-1',
      type: 'totp',
      issuer: 'Google',
      label: 'user@test.com',
      encryptedPayload: new Uint8Array(),
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
    },
  ]),
  getGlobalTimeOffset: vi.fn().mockResolvedValue(0),
  addAccount: vi.fn().mockResolvedValue(1),
  deleteAccount: vi.fn().mockResolvedValue(undefined),
  updateAccount: vi.fn().mockResolvedValue(undefined),
  reorderAccounts: vi.fn().mockResolvedValue(undefined),
}));

describe('Account Store', () => {
  beforeEach(() => {
    useAccountStore.setState({
      accounts: [],
      loading: false,
      globalTimeOffset: 0,
    });
  });

  it('initializes with empty state', () => {
    const state = useAccountStore.getState();
    expect(state.accounts).toEqual([]);
    expect(state.loading).toBe(false);
    expect(state.globalTimeOffset).toBe(0);
  });

  it('sets global time offset', () => {
    useAccountStore.getState().setGlobalTimeOffset(30);
    expect(useAccountStore.getState().globalTimeOffset).toBe(30);
  });

  it('loads accounts', async () => {
    const { getAllAccounts, getGlobalTimeOffset } = await import('@/core/db/schema');

    await useAccountStore.getState().loadAccounts();

    expect(getAllAccounts).toHaveBeenCalled();
    expect(getGlobalTimeOffset).toHaveBeenCalled();

    const state = useAccountStore.getState();
    expect(state.accounts.length).toBe(1);
    expect(state.accounts[0].issuer).toBe('Google');
    expect(state.loading).toBe(false);
  });

  it('adds an account', async () => {
    const { addAccount } = await import('@/core/db/schema');

    const newAccount = {
      uuid: 'new-acc',
      type: 'totp' as const,
      issuer: 'GitHub',
      label: 'dev@test.com',
      encryptedPayload: new Uint8Array(),
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
    };

    await useAccountStore.getState().addAccount(newAccount);

    expect(addAccount).toHaveBeenCalledWith(newAccount);
    expect(useAccountStore.getState().accounts.length).toBe(1);
  });

  it('deletes an account', async () => {
    const { deleteAccount } = await import('@/core/db/schema');

    useAccountStore.setState({
      accounts: [
        {
          id: 1,
          uuid: 'acc-to-delete',
          type: 'totp',
          issuer: 'DeleteMe',
          label: 'test',
          encryptedPayload: new Uint8Array(),
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
        },
      ],
    });

    await useAccountStore.getState().deleteAccount('acc-to-delete');

    expect(deleteAccount).toHaveBeenCalledWith('acc-to-delete');
    expect(useAccountStore.getState().accounts.length).toBe(0);
  });

  it('updates an account', async () => {
    const { updateAccount } = await import('@/core/db/schema');

    useAccountStore.setState({
      accounts: [
        {
          id: 1,
          uuid: 'acc-to-update',
          type: 'totp',
          issuer: 'OldName',
          label: 'test',
          encryptedPayload: new Uint8Array(),
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
        },
      ],
    });

    await useAccountStore.getState().updateAccount('acc-to-update', { issuer: 'NewName' });

    expect(updateAccount).toHaveBeenCalledWith('acc-to-update', { issuer: 'NewName' });
    expect(useAccountStore.getState().accounts[0].issuer).toBe('NewName');
  });

  it('reorders accounts', async () => {
    const { reorderAccounts } = await import('@/core/db/schema');

    useAccountStore.setState({
      accounts: [
        {
          id: 1,
          uuid: 'a',
          type: 'totp',
          issuer: 'First',
          label: '',
          encryptedPayload: new Uint8Array(),
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
        },
        {
          id: 2,
          uuid: 'b',
          type: 'totp',
          issuer: 'Second',
          label: '',
          encryptedPayload: new Uint8Array(),
          algorithm: 'SHA1',
          digits: 6,
          period: 30,
          counter: 0,
          timeOffset: 0,
          sortOrder: 1,
          favorite: false,
          tapToReveal: false,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ],
    });

    await useAccountStore.getState().reorderAccounts(0, 1);

    expect(reorderAccounts).toHaveBeenCalled();
    expect(useAccountStore.getState().accounts[0].issuer).toBe('Second');
    expect(useAccountStore.getState().accounts[1].issuer).toBe('First');
  });

  it('handles loadAccounts failure gracefully', async () => {
    const { getAllAccounts } = await import('@/core/db/schema');
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (getAllAccounts as any).mockRejectedValueOnce(new Error('DB error'));

    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

    await useAccountStore.getState().loadAccounts();

    expect(consoleSpy).toHaveBeenCalled();
    expect(useAccountStore.getState().loading).toBe(false);

    consoleSpy.mockRestore();
  });
});
