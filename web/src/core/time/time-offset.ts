/**
 * Time Offset Service
 * Manages custom time offset for TOTP/HOTP synchronization
 * Range: -300 to +300 seconds (±5 minutes)
 */

const MAX_OFFSET = 300;
const MIN_OFFSET = -300;

let currentOffset = 0;

export function getOffset(): number {
  return currentOffset;
}

export async function setOffset(seconds: number): Promise<void> {
  if (seconds < MIN_OFFSET || seconds > MAX_OFFSET) {
    throw new Error(`Offset must be between ${MIN_OFFSET} and ${MAX_OFFSET} seconds`);
  }
  currentOffset = seconds;
  // Persist to settings
  const { setGlobalTimeOffset } = await import('../db/schema');
  await setGlobalTimeOffset(seconds);
}

export async function resetToAuto(): Promise<void> {
  await setOffset(0);
}

/**
 * Measure NTP drift (simplified - would use NTP protocol in production)
 */
export async function measureNTPDrift(): Promise<number> {
  try {
    // In production, query pool.ntp.org via NTP protocol
    // For now, return 0 (no adjustment)
    return 0;
  } catch (error) {
    console.error('Error measuring NTP drift:', error);
    return 0;
  }
}

export function isValidOffset(seconds: number): boolean {
  return seconds >= MIN_OFFSET && seconds <= MAX_OFFSET;
}

export function formatOffset(seconds: number): string {
  if (seconds === 0) return '0s';
  return seconds > 0 ? `+${seconds}s` : `${seconds}s`;
}
