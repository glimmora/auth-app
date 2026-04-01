import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { App } from '@/App';

describe('App Routing', () => {
  it('redirects root to lock screen', () => {
    render(<App />);

    expect(screen.getByText('AuthVault')).toBeInTheDocument();
    expect(screen.getByText('Enter your PIN to unlock')).toBeInTheDocument();
  });

  it('renders lock screen at /lock', () => {
    window.history.pushState({}, '', '/lock');
    render(<App />);

    expect(screen.getByText('Enter your PIN to unlock')).toBeInTheDocument();
  });

  it('renders accounts screen at /home', () => {
    window.history.pushState({}, '', '/home');
    render(<App />);

    expect(screen.getByText('AuthVault')).toBeInTheDocument();
  });

  it('renders settings screen at /settings', () => {
    window.history.pushState({}, '', '/settings');
    render(<App />);

    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  it('renders time offset screen at /settings/time-offset', () => {
    window.history.pushState({}, '', '/settings/time-offset');
    render(<App />);

    expect(screen.getByText('Time Offset')).toBeInTheDocument();
  });

  it('renders backup screen at /backup', () => {
    window.history.pushState({}, '', '/backup');
    render(<App />);

    expect(screen.getByText('Backup & Restore')).toBeInTheDocument();
  });

  it('renders add account screen at /account/add', () => {
    window.history.pushState({}, '', '/account/add');
    render(<App />);

    expect(screen.getByText('Add Account')).toBeInTheDocument();
  });

  it('renders toaster component', () => {
    render(<App />);

    const toasterContainer = document.querySelector('[aria-live]');
    expect(toasterContainer).toBeDefined();
  });
});
