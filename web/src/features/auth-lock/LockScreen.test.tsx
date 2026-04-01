import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { LockScreen } from '@/features/auth-lock/LockScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('LockScreen', () => {
  beforeEach(() => {
    mockNavigate.mockClear();
  });

  it('renders the lock screen with title', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('AuthVault')).toBeInTheDocument();
    expect(screen.getByText('Enter your PIN to unlock')).toBeInTheDocument();
  });

  it('renders PIN input field', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const input = screen.getByPlaceholderText('• • • •');
    expect(input).toBeInTheDocument();
    expect(input).toHaveAttribute('type', 'password');
    expect(input).toHaveAttribute('maxLength', '6');
  });

  it('renders unlock button', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    expect(screen.getByRole('button', { name: /unlock/i })).toBeInTheDocument();
  });

  it('renders biometric button', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    expect(screen.getByRole('button', { name: /use biometrics/i })).toBeInTheDocument();
  });

  it('renders forgot PIN link', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Forgot PIN?')).toBeInTheDocument();
  });

  it('shows error on wrong PIN', async () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const input = screen.getByPlaceholderText('• • • •');
    fireEvent.change(input, { target: { value: '0000' } });

    const submitBtn = screen.getByRole('button', { name: /unlock/i });
    fireEvent.click(submitBtn);

    await waitFor(() => {
      expect(screen.getByText('Incorrect PIN')).toBeInTheDocument();
    });
    expect(mockNavigate).not.toHaveBeenCalled();
  });

  it('navigates to home on correct PIN', async () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const input = screen.getByPlaceholderText('• • • •');
    fireEvent.change(input, { target: { value: '1234' } });

    const submitBtn = screen.getByRole('button', { name: /unlock/i });
    fireEvent.click(submitBtn);

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/home');
    });
  });

  it('shows lockout after 5 failed attempts', async () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const input = screen.getByPlaceholderText('• • • •');

    for (let i = 0; i < 5; i++) {
      fireEvent.change(input, { target: { value: '0000' } });
      const submitBtn = screen.getByRole('button', { name: /unlock/i });
      fireEvent.click(submitBtn);
      await waitFor(() => {
        expect(input).toHaveValue('');
      });
    }

    await waitFor(() => {
      expect(screen.getByText(/too many attempts/i)).toBeInTheDocument();
    });
  });

  it('only accepts numeric input', () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const input = screen.getByPlaceholderText('• • • •');
    fireEvent.change(input, { target: { value: 'abc123' } });

    expect(input).toHaveValue('123');
  });

  it('navigates to home on biometric success', async () => {
    render(
      <MemoryRouter>
        <LockScreen />
      </MemoryRouter>
    );

    const biometricBtn = screen.getByRole('button', { name: /use biometrics/i });
    fireEvent.click(biometricBtn);

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/home');
    });
  });
});
