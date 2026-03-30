import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AccountCard } from '@/features/accounts/AccountCard';
import { Account } from '@/core/db/schema';

vi.mock('@/features/accounts/store', () => ({
  useAccountStore: () => ({
    globalTimeOffset: 0,
  }),
}));

vi.mock('react-hot-toast', () => ({
  default: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

function makeAccount(overrides: Partial<Account> = {}): Account {
  return {
    id: 1,
    uuid: 'test-uuid',
    type: 'totp',
    issuer: 'Google',
    label: 'user@example.com',
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

describe('AccountCard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders issuer name', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ issuer: 'GitHub' })} index={0} />
      </MemoryRouter>
    );

    expect(screen.getByText('GitHub')).toBeInTheDocument();
  });

  it('renders label', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ label: 'dev@test.com' })} index={0} />
      </MemoryRouter>
    );

    expect(screen.getByText('dev@test.com')).toBeInTheDocument();
  });

  it('renders issuer initial in icon', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ issuer: 'Google' })} index={0} />
      </MemoryRouter>
    );

    expect(screen.getByText('G')).toBeInTheDocument();
  });

  it('shows OTP code when revealed', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ tapToReveal: false })} index={0} />
      </MemoryRouter>
    );

    const codeElement = document.querySelector('.otp-code');
    expect(codeElement).toBeInTheDocument();
    expect(codeElement?.textContent).toMatch(/^\d{3}\s\d{3}$/);
  });

  it('hides code when tapToReveal is true', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ tapToReveal: true })} index={0} />
      </MemoryRouter>
    );

    const hiddenDots = document.querySelector('.text-gray-500');
    expect(hiddenDots).toBeInTheDocument();
    expect(hiddenDots?.textContent).toContain('•');
  });

  it('reveals code on tap when tapToReveal', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ tapToReveal: true })} index={0} />
      </MemoryRouter>
    );

    const card = document.querySelector('.cursor-pointer')!;
    fireEvent.click(card);

    const codeElement = document.querySelector('.otp-code');
    expect(codeElement).toBeInTheDocument();
  });

  it('shows favorite star when favorited', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ favorite: true })} index={0} />
      </MemoryRouter>
    );

    const starIcon = document.querySelector('.fill-amber-400');
    expect(starIcon).toBeInTheDocument();
  });

  it('does not show star when not favorited', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ favorite: false })} index={0} />
      </MemoryRouter>
    );

    const starIcon = document.querySelector('.fill-amber-400');
    expect(starIcon).not.toBeInTheDocument();
  });

  it('shows next code preview when revealed', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount({ tapToReveal: false })} index={0} />
      </MemoryRouter>
    );

    expect(screen.getByText('Next:')).toBeInTheDocument();
  });

  it('renders progress ring with remaining seconds', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount()} index={0} />
      </MemoryRouter>
    );

    const remainingSpan = document.querySelector('.absolute.inset-0');
    expect(remainingSpan).toBeInTheDocument();
    expect(remainingSpan?.textContent).toMatch(/^\d+$/);
  });

  it('renders menu button', () => {
    render(
      <MemoryRouter>
        <AccountCard account={makeAccount()} index={0} />
      </MemoryRouter>
    );

    const menuBtn = document.querySelector('button.p-2');
    expect(menuBtn).toBeInTheDocument();
  });
});
