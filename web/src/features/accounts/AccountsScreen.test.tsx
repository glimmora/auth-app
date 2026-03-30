import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AccountsScreen } from '@/features/accounts/AccountsScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

const mockLoadAccounts = vi.fn();
const mockStore: any = {
  accounts: [] as any[],
  loading: false,
  globalTimeOffset: 0,
  loadAccounts: mockLoadAccounts,
  addAccount: vi.fn(),
  deleteAccount: vi.fn(),
  updateAccount: vi.fn(),
  reorderAccounts: vi.fn(),
  setGlobalTimeOffset: vi.fn(),
};

vi.mock('@/features/accounts/store', () => ({
  useAccountStore: () => mockStore,
}));

vi.mock('@/features/accounts/AccountCard', () => ({
  AccountCard: ({ account }: any) => (
    <div data-testid="account-card">{account.issuer}</div>
  ),
}));

describe('AccountsScreen', () => {
  beforeEach(() => {
    mockNavigate.mockClear();
    mockLoadAccounts.mockClear();
    mockStore.accounts = [];
    mockStore.loading = false;
  });

  it('renders the app title', () => {
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('AuthVault')).toBeInTheDocument();
  });

  it('calls loadAccounts on mount', () => {
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    expect(mockLoadAccounts).toHaveBeenCalled();
  });

  it('shows loading skeletons when loading', () => {
    mockStore.loading = true;
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('AuthVault')).toBeInTheDocument();
    const pulseElements = document.querySelectorAll('.animate-pulse');
    expect(pulseElements.length).toBeGreaterThan(0);
  });

  it('shows empty state when no accounts', () => {
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('No accounts yet')).toBeInTheDocument();
    expect(screen.getByText('Add your first account to get started')).toBeInTheDocument();
    expect(screen.getByText('Add Account')).toBeInTheDocument();
  });

  it('renders account cards when accounts exist', () => {
    mockStore.accounts = [
      {
        id: 1,
        uuid: 'acc-1',
        type: 'totp',
        issuer: 'Google',
        label: 'user@example.com',
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
        uuid: 'acc-2',
        type: 'totp',
        issuer: 'GitHub',
        label: 'dev@example.com',
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
    ];

    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    const cards = screen.getAllByTestId('account-card');
    expect(cards.length).toBe(2);
    expect(screen.getByText('Google')).toBeInTheDocument();
    expect(screen.getByText('GitHub')).toBeInTheDocument();
  });

  it('renders header action buttons', () => {
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    const buttons = screen.getAllByRole('button');
    expect(buttons.length).toBeGreaterThanOrEqual(3); // search, star, settings, FAB
  });

  it('renders floating action button for adding accounts', () => {
    render(
      <MemoryRouter>
        <AccountsScreen />
      </MemoryRouter>
    );

    const fabButtons = screen.getAllByRole('button');
    const fab = fabButtons.find(btn => btn.querySelector('svg'));
    expect(fab).toBeDefined();
  });
});
