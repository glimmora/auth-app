import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AddAccountScreen } from '@/features/accounts/AddAccountScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('AddAccountScreen', () => {
  it('renders add account title', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Add Account')).toBeInTheDocument();
  });

  it('renders QR code scan option', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Scan QR Code')).toBeInTheDocument();
    expect(screen.getByText('Use camera to scan a QR code')).toBeInTheDocument();
  });

  it('renders image import option', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Import from Image')).toBeInTheDocument();
    expect(screen.getByText('Select an image with QR code')).toBeInTheDocument();
  });

  it('renders manual entry option', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Manual Entry')).toBeInTheDocument();
    expect(screen.getByText('Enter details manually')).toBeInTheDocument();
  });

  it('renders info text', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    expect(
      screen.getByText(/You can add accounts from any service that supports TOTP or HOTP/)
    ).toBeInTheDocument();
  });

  it('navigates to QR scan on scan button click', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    const scanBtn = screen.getByText('Scan QR Code').closest('button')!;
    fireEvent.click(scanBtn);

    expect(mockNavigate).toHaveBeenCalledWith('/account/add/scan');
  });

  it('navigates to manual entry on manual button click', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    const manualBtn = screen.getByText('Manual Entry').closest('button')!;
    fireEvent.click(manualBtn);

    expect(mockNavigate).toHaveBeenCalledWith('/account/add/manual');
  });

  it('navigates back on back button click', () => {
    render(
      <MemoryRouter>
        <AddAccountScreen />
      </MemoryRouter>
    );

    const backBtn = screen.getAllByRole('button')[0];
    fireEvent.click(backBtn);

    expect(mockNavigate).toHaveBeenCalledWith(-1);
  });
});
