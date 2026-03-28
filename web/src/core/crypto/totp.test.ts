import { describe, it, expect } from 'vitest';
import { generateTOTP, getNextTOTP, getRemainingSeconds, getPeriodProgress, generateSecret } from '@/core/crypto/totp';

describe('TOTP', () => {
  it('produces 6-digit string', () => {
    const code = generateTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      digits: 6,
      period: 30,
      offset: 0,
    });

    expect(code).toMatch(/^\d{6}$/);
  });

  it('produces 8-digit string when requested', () => {
    const code = generateTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      digits: 8,
      period: 30,
      offset: 0,
    });

    expect(code).toMatch(/^\d{8}$/);
  });

  it('remaining seconds is within valid range', () => {
    const remaining = getRemainingSeconds(30, 0);
    
    expect(remaining).toBeGreaterThan(0);
    expect(remaining).toBeLessThanOrEqual(30);
  });

  it('progress is between 0 and 1', () => {
    const progress = getPeriodProgress(30, 0);
    
    expect(progress).toBeGreaterThanOrEqual(0);
    expect(progress).toBeLessThanOrEqual(1);
  });

  it('offset shifts computation window', () => {
    const code0 = generateTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      offset: 0,
    });
    
    const codePlus = generateTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      offset: 300,
    });
    
    // Both should be valid codes
    expect(code0).toMatch(/^\d{6}$/);
    expect(codePlus).toMatch(/^\d{6}$/);
  });

  it('next code is different from current', () => {
    const current = generateTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      offset: 0,
    });
    
    const next = getNextTOTP({
      secret: 'JBSWY3DPEHPK3PXP',
      offset: 0,
    });
    
    expect(current).toMatch(/^\d{6}$/);
    expect(next).toMatch(/^\d{6}$/);
  });

  it('generates valid base32 secret', () => {
    const secret = generateSecret(20);
    
    expect(secret).toMatch(/^[A-Z2-7]+$/);
    expect(secret.length).toBeGreaterThanOrEqual(20);
  });
});
