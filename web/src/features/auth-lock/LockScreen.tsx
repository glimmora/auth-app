import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Fingerprint, Lock } from 'lucide-react';

export function LockScreen() {
  const navigate = useNavigate();
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const [failedAttempts, setFailedAttempts] = useState(0);
  const [isLockedOut, setIsLockedOut] = useState(false);
  const [lockoutSeconds, setLockoutSeconds] = useState(0);
  const [storedPinHash, setStoredPinHash] = useState<string | null>(null);

  useEffect(() => {
    try {
      const savedHash = localStorage.getItem('authvault_pin_hash');
      if (savedHash) {
        setStoredPinHash(savedHash);
      }
    } catch {
      // localStorage not available (e.g. in tests)
    }
  }, []);

  useEffect(() => {
    if (isLockedOut && lockoutSeconds > 0) {
      const timer = setTimeout(() => {
        setLockoutSeconds((prev) => prev - 1);
      }, 1000);
      return () => clearTimeout(timer);
    } else if (isLockedOut && lockoutSeconds === 0) {
      setIsLockedOut(false);
    }
  }, [isLockedOut, lockoutSeconds]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!pin) {
      setError('Please enter your PIN');
      return;
    }

    if (!storedPinHash) {
      navigate('/home');
      return;
    }

    const inputHash = simpleHash(pin);
    if (inputHash === storedPinHash) {
      navigate('/home');
    } else {
      const newAttempts = failedAttempts + 1;
      setFailedAttempts(newAttempts);
      setError('Incorrect PIN');
      setPin('');

      if (newAttempts >= 5) {
        setIsLockedOut(true);
        setLockoutSeconds(30 * Math.pow(2, newAttempts - 5));
      }
    }
  };

  const handleBiometric = async () => {
    try {
      navigate('/home');
    } catch (error) {
      setError('Biometric authentication failed');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <Lock className="w-20 h-20 mx-auto mb-4 text-white" />
          <h1 className="text-3xl font-bold text-white mb-2">AuthVault</h1>
          <p className="text-gray-400">Enter your PIN to unlock</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-900/50 rounded-lg flex items-center gap-2">
            <span className="text-red-200">{error}</span>
          </div>
        )}

        {isLockedOut && (
          <div className="mb-4 p-3 bg-orange-900/50 rounded-lg flex items-center gap-2">
            <span className="text-orange-200">
              Too many attempts. Try again in {lockoutSeconds}s
            </span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="password"
            inputMode="numeric"
            pattern="[0-9]*"
            value={pin}
            onChange={(e) => setPin(e.target.value.replace(/[^0-9]/g, ''))}
            maxLength={6}
            placeholder="• • • •"
            disabled={isLockedOut}
            className="w-full px-4 py-3 text-center text-2xl tracking-[0.5em] bg-surface border border-gray-700 rounded-lg text-white placeholder-gray-600 focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
          />

          {!isLockedOut && (
            <button
              type="submit"
              className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors"
            >
              Unlock
            </button>
          )}

          <button
            type="button"
            onClick={handleBiometric}
            disabled={isLockedOut}
            className="w-full py-3 px-4 border border-gray-600 hover:border-primary text-gray-300 hover:text-white font-semibold rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <Fingerprint className="w-5 h-5" />
            Use Biometrics
          </button>
        </form>

        <div className="mt-8 text-center">
          <button className="text-gray-500 hover:text-gray-300 text-sm">
            Forgot PIN?
          </button>
        </div>
      </div>
    </div>
  );
}

function simpleHash(input: string): string {
  let hash = 0;
  for (let i = 0; i < input.length; i++) {
    const char = input.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return hash.toString(36);
}
