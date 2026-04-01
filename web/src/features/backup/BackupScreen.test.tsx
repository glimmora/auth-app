import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { BackupScreen } from '@/features/backup/BackupScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('BackupScreen', () => {
  it('renders backup title', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Backup & Restore')).toBeInTheDocument();
  });

  it('renders export section', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Export Backup')).toBeInTheDocument();
    expect(screen.getByText('Export to File')).toBeInTheDocument();
    expect(screen.getByText('Backup to Cloud')).toBeInTheDocument();
  });

  it('renders import section', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Import Backup')).toBeInTheDocument();
    expect(screen.getByText('Import from File')).toBeInTheDocument();
  });

  it('renders cloud backup section', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Cloud Backup')).toBeInTheDocument();
    expect(screen.getByText('Google Drive')).toBeInTheDocument();
    expect(screen.getByText('Dropbox')).toBeInTheDocument();
    expect(screen.getByText('iCloud')).toBeInTheDocument();
  });

  it('renders QR export section', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('QR Export')).toBeInTheDocument();
    expect(screen.getByText('Export as QR Codes')).toBeInTheDocument();
  });

  it('renders last backup info', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Last backup: Never')).toBeInTheDocument();
  });

  it('navigates back to home', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    const backBtn = screen.getAllByRole('button')[0];
    fireEvent.click(backBtn);

    expect(mockNavigate).toHaveBeenCalledWith('/home');
  });

  it('handles export click', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    const exportBtn = screen.getByText('Export to File');
    fireEvent.click(exportBtn);
  });

  it('handles import click', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    const importBtn = screen.getByText('Import from File');
    fireEvent.click(importBtn);
  });

  it('shows not connected status for cloud services', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    const notConnected = screen.getAllByText('Not connected');
    expect(notConnected.length).toBe(2); // Google Drive and Dropbox
  });

  it('shows iCloud as not available', () => {
    render(
      <MemoryRouter>
        <BackupScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Not available')).toBeInTheDocument();
  });
});
