import { useState, useEffect } from 'react';
import { generateTOTP, getNextTOTP, getRemainingSeconds, getPeriodProgress } from '@/core/crypto/totp';
import { Account } from '@/core/db/schema';

export interface TOTPState {
  code: string;
  remaining: number;
  nextCode: string;
  progress: number;
}

/**
 * React hook for reactive TOTP code generation
 * Updates every second
 */
export function useTOTP(account: Account, globalOffset: number = 0): TOTPState {
  const [state, setState] = useState<TOTPState>(() =>
    computeState(account, globalOffset)
  );

  useEffect(() => {
    const computeAndSet = () => {
      setState(computeState(account, globalOffset));
    };

    // Compute immediately
    computeAndSet();

    // Update every second
    const interval = setInterval(computeAndSet, 1000);

    return () => clearInterval(interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [account.uuid, account.period, globalOffset, account.timeOffset]);

  return state;
}

function computeState(account: Account, globalOffset: number): TOTPState {
  const totalOffset = (account.timeOffset || 0) + globalOffset;
  const period = account.period || 30;

  const code = generateTOTP({
    secret: 'JBSWY3DPEHPK3PXP', // Placeholder - would decrypt from account.encryptedPayload
    digits: account.digits,
    period,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    algorithm: account.algorithm as any,
    offset: totalOffset,
  });

  const nextCode = getNextTOTP({
    secret: 'JBSWY3DPEHPK3PXP',
    digits: account.digits,
    period,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    algorithm: account.algorithm as any,
    offset: totalOffset,
  });

  const remaining = getRemainingSeconds(period, totalOffset);
  const progress = getPeriodProgress(period, totalOffset);

  return {
    code,
    remaining,
    nextCode,
    progress,
  };
}
