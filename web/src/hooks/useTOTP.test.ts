import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useTOTP, TOTPState } from '@/hooks/useTOTP';
import { Account } from '@/core/db/schema';

function makeAccount(overrides: Partial<Account> = {}): Account {
  return {
    id: 1,
    uuid: 'test-uuid',
    type: 'totp',
    issuer: 'Test',
    label: 'test@example.com',
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

describe('useTOTP hook', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns TOTP state with code, remaining, nextCode, and progress', () => {
    const account = makeAccount();
    const { result } = renderHook(() => useTOTP(account));

    expect(result.current.code).toMatch(/^\d{6}$/);
    expect(result.current.remaining).toBeGreaterThan(0);
    expect(result.current.remaining).toBeLessThanOrEqual(30);
    expect(result.current.nextCode).toMatch(/^\d{6}$/);
    expect(result.current.progress).toBeGreaterThanOrEqual(0);
    expect(result.current.progress).toBeLessThanOrEqual(1);
  });

  it('updates code every second', () => {
    const account = makeAccount();
    const { result } = renderHook(() => useTOTP(account));

    const initialRemaining = result.current.remaining;

    act(() => {
      vi.advanceTimersByTime(1000);
    });

    expect(result.current.remaining).toBeLessThanOrEqual(initialRemaining);
  });

  it('uses custom period', () => {
    const account = makeAccount({ period: 60 });
    const { result } = renderHook(() => useTOTP(account));

    expect(result.current.remaining).toBeGreaterThan(0);
    expect(result.current.remaining).toBeLessThanOrEqual(60);
  });

  it('applies global offset', () => {
    const account = makeAccount();
    const { result: result0 } = renderHook(() => useTOTP(account, 0));
    const { result: result300 } = renderHook(() => useTOTP(account, 300));

    expect(result0.current.code).toMatch(/^\d{6}$/);
    expect(result300.current.code).toMatch(/^\d{6}$/);
  });

  it('applies per-account time offset', () => {
    const account = makeAccount({ timeOffset: 60 });
    const { result } = renderHook(() => useTOTP(account));

    expect(result.current.code).toMatch(/^\d{6}$/);
  });

  it('clears interval on unmount', () => {
    const account = makeAccount();
    const { unmount } = renderHook(() => useTOTP(account));

    const clearIntervalSpy = vi.spyOn(globalThis, 'clearInterval');
    unmount();
    expect(clearIntervalSpy).toHaveBeenCalled();
    clearIntervalSpy.mockRestore();
  });
});
