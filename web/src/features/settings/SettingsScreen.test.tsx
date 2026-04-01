import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { SettingsScreen } from '@/features/settings/SettingsScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('SettingsScreen', () => {
  it('renders settings title', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  it('renders security section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Security')).toBeInTheDocument();
    expect(screen.getByText('Biometric Unlock')).toBeInTheDocument();
    expect(screen.getByText('Auto-Lock')).toBeInTheDocument();
  });

  it('renders time section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Time')).toBeInTheDocument();
    expect(screen.getByText('Time Offset')).toBeInTheDocument();
    expect(screen.getByText('Adjust for clock drift')).toBeInTheDocument();
  });

  it('renders appearance section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Appearance')).toBeInTheDocument();
    expect(screen.getByText('Theme')).toBeInTheDocument();
    expect(screen.getByText('Dark')).toBeInTheDocument();
  });

  it('renders backup section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Backup & Sync')).toBeInTheDocument();
    expect(screen.getByText('Backup')).toBeInTheDocument();
    expect(screen.getByText('Restore')).toBeInTheDocument();
  });

  it('renders data section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Data')).toBeInTheDocument();
    expect(screen.getByText('Import')).toBeInTheDocument();
    expect(screen.getByText('Export')).toBeInTheDocument();
  });

  it('renders about section', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('About')).toBeInTheDocument();
    expect(screen.getByText('About AuthVault')).toBeInTheDocument();
    expect(screen.getByText('Version 1.0.0')).toBeInTheDocument();
    expect(screen.getByText('Privacy Policy')).toBeInTheDocument();
  });

  it('navigates back to home on back button click', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    const backBtn = screen.getAllByRole('button')[0];
    fireEvent.click(backBtn);

    expect(mockNavigate).toHaveBeenCalledWith('/home');
  });

  it('navigates to time offset screen', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    const timeOffsetBtn = screen.getByText('Time Offset');
    fireEvent.click(timeOffsetBtn.closest('button')!);

    expect(mockNavigate).toHaveBeenCalledWith('/settings/time-offset');
  });

  it('navigates to backup screen', () => {
    render(
      <MemoryRouter>
        <SettingsScreen />
      </MemoryRouter>
    );

    const backupBtn = screen.getByText('Backup');
    fireEvent.click(backupBtn.closest('button')!);

    expect(mockNavigate).toHaveBeenCalledWith('/backup');
  });
});
