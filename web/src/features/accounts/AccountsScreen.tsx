import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Search, Star, Settings } from 'lucide-react';
import { useAccountStore } from './store';
import { AccountCard } from './AccountCard';

export function AccountsScreen() {
  const navigate = useNavigate();
  const { accounts, loading, loadAccounts } = useAccountStore();

  useEffect(() => {
    loadAccounts();
  }, [loadAccounts]);

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Header onSearch={() => {}} onFavorites={() => {}} onMenu={() => {}} />
        <div className="p-4 space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="animate-pulse">
              <div className="bg-surface rounded-xl p-4">
                <div className="h-4 bg-gray-700 rounded w-1/3 mb-2"></div>
                <div className="h-3 bg-gray-700 rounded w-1/2 mb-4"></div>
                <div className="h-8 bg-gray-700 rounded w-1/4"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Header
        onSearch={() => {}}
        onFavorites={() => {}}
        onMenu={(action) => {
          if (action === 'settings') navigate('/settings');
          if (action === 'backup') navigate('/backup');
        }}
      />

      <main className="pb-24">
        {accounts.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 px-4">
            <Star className="w-16 h-16 text-gray-600 mb-4" />
            <h2 className="text-xl font-semibold text-white mb-2">No accounts yet</h2>
            <p className="text-gray-400 text-center mb-6">
              Add your first account to get started
            </p>
            <button
              onClick={() => navigate('/account/add')}
              className="px-6 py-3 bg-primary hover:bg-primary/90 text-white rounded-lg font-semibold transition-colors"
            >
              Add Account
            </button>
          </div>
        ) : (
          <div className="p-4 space-y-3">
            {accounts.map((account, index) => (
              <AccountCard key={account.uuid} account={account} index={index} />
            ))}
          </div>
        )}
      </main>

      <button
        onClick={() => navigate('/account/add')}
        className="fixed bottom-6 right-6 w-14 h-14 bg-primary hover:bg-primary/90 text-white rounded-full shadow-lg flex items-center justify-center transition-colors"
      >
        <Plus className="w-6 h-6" />
      </button>
    </div>
  );
}

interface HeaderProps {
  onSearch: () => void;
  onFavorites: () => void;
  onMenu: (action: string) => void;
}

function Header({ onSearch, onFavorites, onMenu }: HeaderProps) {
  return (
    <header className="sticky top-0 z-10 bg-background/95 backdrop-blur border-b border-gray-800">
      <div className="flex items-center justify-between px-4 py-4">
        <h1 className="text-2xl font-bold text-white">AuthVault</h1>
        <div className="flex items-center gap-2">
          <button
            onClick={onSearch}
            className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
          >
            <Search className="w-5 h-5 text-gray-400" />
          </button>
          <button
            onClick={onFavorites}
            className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
          >
            <Star className="w-5 h-5 text-gray-400" />
          </button>
          <div className="relative">
            <button
              onClick={() => onMenu('settings')}
              className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
            >
              <Settings className="w-5 h-5 text-gray-400" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
}
