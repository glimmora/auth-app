import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { Account } from '@/core/db/schema';

interface AccountStore {
  accounts: Account[];
  loading: boolean;
  globalTimeOffset: number;

  // Actions
  addAccount: (account: Omit<Account, 'id'>) => Promise<void>;
  deleteAccount: (uuid: string) => Promise<void>;
  updateAccount: (uuid: string, patch: Partial<Account>) => Promise<void>;
  reorderAccounts: (from: number, to: number) => Promise<void>;
  setGlobalTimeOffset: (seconds: number) => void;
  loadAccounts: () => Promise<void>;
}

export const useAccountStore = create<AccountStore>()(
  immer((set, get) => ({
    accounts: [],
    loading: false,
    globalTimeOffset: 0,

    loadAccounts: async () => {
      set({ loading: true });
      try {
        const { getAllAccounts, getGlobalTimeOffset } = await import('@/core/db/schema');
        const accounts = await getAllAccounts();
        const offset = await getGlobalTimeOffset();
        set({ accounts, globalTimeOffset: offset, loading: false });
      } catch (error) {
        console.error('Failed to load accounts:', error);
        set({ loading: false });
      }
    },

    addAccount: async (account) => {
      const { addAccount } = await import('@/core/db/schema');
      const id = await addAccount(account);
      set((state) => {
        state.accounts.push({ ...account, id } as Account);
      });
    },

    deleteAccount: async (uuid) => {
      const { deleteAccount } = await import('@/core/db/schema');
      await deleteAccount(uuid);
      set((state) => {
        state.accounts = state.accounts.filter((a) => a.uuid !== uuid);
      });
    },

    updateAccount: async (uuid, patch) => {
      const { updateAccount } = await import('@/core/db/schema');
      await updateAccount(uuid, patch);
      set((state) => {
        const index = state.accounts.findIndex((a) => a.uuid === uuid);
        if (index !== -1) {
          state.accounts[index] = { ...state.accounts[index], ...patch };
        }
      });
    },

    reorderAccounts: async (from, to) => {
      const { reorderAccounts } = await import('@/core/db/schema');
      set((state) => {
        const [removed] = state.accounts.splice(from, 1);
        state.accounts.splice(to, 0, removed);
        const ids = state.accounts.map((a) => a.id!).filter(Boolean) as number[];
        reorderAccounts(ids);
      });
    },

    setGlobalTimeOffset: (seconds) => {
      set({ globalTimeOffset: seconds });
    },
  }))
);
