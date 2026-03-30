import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { TimeOffsetScreen } from '@/features/settings/TimeOffsetScreen';

const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

describe('TimeOffsetScreen', () => {
  it('renders time offset title', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Time Offset')).toBeInTheDocument();
  });

  it('renders offset slider', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const slider = screen.getByRole('slider');
    expect(slider).toBeInTheDocument();
    expect(slider).toHaveAttribute('min', '-300');
    expect(slider).toHaveAttribute('max', '300');
  });

  it('renders fine adjustment buttons', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('−')).toBeInTheDocument();
    expect(screen.getByText('+')).toBeInTheDocument();
  });

  it('renders NTP drift section', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('NTP Time Sync')).toBeInTheDocument();
    expect(screen.getByText('Measure NTP Drift')).toBeInTheDocument();
  });

  it('renders preview section', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Preview with Current Offset')).toBeInTheDocument();
  });

  it('renders reset and apply buttons', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    expect(screen.getByText('Reset to 0')).toBeInTheDocument();
    expect(screen.getByText('Apply')).toBeInTheDocument();
  });

  it('shows current offset value in slider area', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const sliderArea = document.querySelector('.text-2xl.font-bold');
    expect(sliderArea).toBeInTheDocument();
    expect(sliderArea?.textContent).toContain('0s');
  });

  it('increments offset with + button', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const plusBtn = screen.getByText('+');
    fireEvent.click(plusBtn);

    const sliderArea = document.querySelector('.text-2xl.font-bold');
    expect(sliderArea?.textContent).toContain('+1s');
  });

  it('decrements offset with - button', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const minusBtn = screen.getByText('−');
    fireEvent.click(minusBtn);

    const sliderArea = document.querySelector('.text-2xl.font-bold');
    expect(sliderArea?.textContent).toContain('-1s');
  });

  it('measures NTP drift and shows result', async () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const measureBtn = screen.getByText('Measure NTP Drift');
    fireEvent.click(measureBtn);

    expect(screen.getByText('Measuring...')).toBeInTheDocument();

    // Wait for the 2s simulated measurement to complete
    await waitFor(
      () => {
        expect(screen.getByText(/NTP diff detected/)).toBeInTheDocument();
      },
      { timeout: 5000 }
    );
  });

  it('navigates back to settings', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const backBtn = screen.getAllByRole('button')[0];
    fireEvent.click(backBtn);

    expect(mockNavigate).toHaveBeenCalledWith('/settings');
  });

  it('shows warning banner when offset is active', () => {
    render(
      <MemoryRouter>
        <TimeOffsetScreen />
      </MemoryRouter>
    );

    const plusBtn = screen.getByText('+');
    fireEvent.click(plusBtn);

    expect(screen.getByText(/Offset active/)).toBeInTheDocument();
  });
});
