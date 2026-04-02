import { useState, useEffect } from 'react';
import { generateTOTP, getNextTOTP, getRemainingSeconds, getPeriodProgress } from '@/core/crypto/totp';
import { Account } from '@/core/db/schema';

export interface TOTPState {
  code: string;
  remaining: number;
  nextCode: string;
  progress: number;
}

export function useTOTP(account: Account, globalOffset: number = 0): TOTPState {
  const [state, setState] = useState<TOTPState>(() =>
    computeState(account, globalOffset)
  );

  useEffect(() => {
    const computeAndSet = () => {
      setState(computeState(account, globalOffset));
    };

    computeAndSet();

    const interval = setInterval(computeAndSet, 1000);

    return () => clearInterval(interval);
  }, [account.uuid, account.period, globalOffset, account.timeOffset]);

  return state;
}

function computeState(account: Account, globalOffset: number): TOTPState {
  const totalOffset = (account.timeOffset || 0) + globalOffset;
  const period = account.period || 30;

  const secret = getSecret(account);

  const code = generateTOTP({
    secret,
    digits: account.digits,
    period,
    algorithm: account.algorithm as any,
    offset: totalOffset,
  });

  const nextCode = getNextTOTP({
    secret,
    digits: account.digits,
    period,
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

function getSecret(account: Account): string {
  if (account.encryptedPayload && account.encryptedPayload.length > 0) {
    try {
      const decoder = new TextDecoder();
      return decoder.decode(account.encryptedPayload);
    } catch {
      return '';
    }
  }
  return '';
}
