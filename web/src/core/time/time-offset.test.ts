import { describe, it, expect, beforeEach } from 'vitest';
import {
  getOffset,
  setOffset,
  resetToAuto,
  measureNTPDrift,
  isValidOffset,
  formatOffset,
} from '@/core/time/time-offset';

describe('Time Offset Service', () => {
  beforeEach(async () => {
    await resetToAuto();
  });

  describe('getOffset', () => {
    it('returns 0 by default', () => {
      expect(getOffset()).toBe(0);
    });
  });

  describe('setOffset', () => {
    it('sets positive offset', async () => {
      await setOffset(60);
      expect(getOffset()).toBe(60);
    });

    it('sets negative offset', async () => {
      await setOffset(-60);
      expect(getOffset()).toBe(-60);
    });

    it('throws for offset exceeding max', async () => {
      await expect(setOffset(301)).rejects.toThrow(
        'Offset must be between -300 and 300 seconds'
      );
    });

    it('throws for offset below min', async () => {
      await expect(setOffset(-301)).rejects.toThrow(
        'Offset must be between -300 and 300 seconds'
      );
    });

    it('accepts boundary values', async () => {
      await setOffset(300);
      expect(getOffset()).toBe(300);

      await setOffset(-300);
      expect(getOffset()).toBe(-300);
    });
  });

  describe('resetToAuto', () => {
    it('resets offset to 0', async () => {
      await setOffset(120);
      await resetToAuto();
      expect(getOffset()).toBe(0);
    });
  });

  describe('measureNTPDrift', () => {
    it('returns a number', async () => {
      const drift = await measureNTPDrift();
      expect(typeof drift).toBe('number');
    });

    it('returns 0 in simplified implementation', async () => {
      const drift = await measureNTPDrift();
      expect(drift).toBe(0);
    });
  });

  describe('isValidOffset', () => {
    it('returns true for valid offsets', () => {
      expect(isValidOffset(0)).toBe(true);
      expect(isValidOffset(100)).toBe(true);
      expect(isValidOffset(-100)).toBe(true);
      expect(isValidOffset(300)).toBe(true);
      expect(isValidOffset(-300)).toBe(true);
    });

    it('returns false for invalid offsets', () => {
      expect(isValidOffset(301)).toBe(false);
      expect(isValidOffset(-301)).toBe(false);
      expect(isValidOffset(1000)).toBe(false);
    });
  });

  describe('formatOffset', () => {
    it('formats zero offset', () => {
      expect(formatOffset(0)).toBe('0s');
    });

    it('formats positive offset', () => {
      expect(formatOffset(60)).toBe('+60s');
    });

    it('formats negative offset', () => {
      expect(formatOffset(-60)).toBe('-60s');
    });
  });
});
