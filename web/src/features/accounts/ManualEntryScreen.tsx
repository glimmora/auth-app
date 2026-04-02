import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Dice5, ClipboardPaste } from 'lucide-react';
import { useAccountStore } from './store';
import { generateSecret } from '@/core/crypto/totp';
import toast from 'react-hot-toast';

export function ManualEntryScreen() {
  const navigate = useNavigate();
  const [issuer, setIssuer] = useState('');
  const [label, setLabel] = useState('');
  const [secret, setSecret] = useState('');
  const [accountType, setAccountType] = useState<'totp' | 'hotp' | 'steam'>('totp');
  const [algorithm, setAlgorithm] = useState('SHA1');
  const [digits, setDigits] = useState(6);
  const [period, setPeriod] = useState(30);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!issuer || !label || !secret) {
      toast.error('Please fill in all required fields');
      return;
    }

    if (!/^[A-Z2-7]+$/i.test(secret)) {
      toast.error('Invalid base32 format');
      return;
    }

    setIsSubmitting(true);

    try {
      const encoder = new TextEncoder();
      const encryptedPayload = encoder.encode(secret.toUpperCase());

      await useAccountStore.getState().addAccount({
        uuid: crypto.randomUUID(),
        type: accountType,
        issuer: issuer.trim(),
        label: label.trim(),
        encryptedPayload,
        algorithm,
        digits,
        period: accountType === 'totp' ? period : 30,
        counter: accountType === 'hotp' ? 0 : 0,
        timeOffset: 0,
        sortOrder: 0,
        favorite: false,
        tapToReveal: false,
        iconName: getIconForIssuer(issuer),
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      toast.success('Account added successfully');
      navigate('/home');
    } catch (error) {
      toast.error('Failed to add account');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleGenerateSecret = () => {
    setSecret(generateSecret(20));
  };

  const handlePaste = async () => {
    try {
      const text = await navigator.clipboard.readText();
      setSecret(text.toUpperCase().replace(/[^A-Z2-7]/g, ''));
    } catch {
      toast.error('Failed to read clipboard');
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center gap-4 px-4 py-4 border-b border-gray-800">
        <button
          onClick={() => navigate(-1)}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-xl font-bold text-white">Manual Entry</h1>
      </header>

      <main className="p-4 max-w-md mx-auto">
        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Account Type */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Account Type</label>
            <select
              value={accountType}
              onChange={(e) => setAccountType(e.target.value as 'totp' | 'hotp' | 'steam')}
              className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white"
            >
              <option value="totp">Time-based (TOTP)</option>
              <option value="hotp">Counter-based (HOTP)</option>
              <option value="steam">Steam Guard</option>
            </select>
          </div>

          {/* Issuer */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Issuer *</label>
            <input
              type="text"
              value={issuer}
              onChange={(e) => setIssuer(e.target.value)}
              placeholder="e.g., Google, GitHub"
              className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white placeholder-gray-500"
              required
            />
          </div>

          {/* Label */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Label *</label>
            <input
              type="text"
              value={label}
              onChange={(e) => setLabel(e.target.value)}
              placeholder="e.g., your@email.com"
              className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white placeholder-gray-500"
              required
            />
          </div>

          {/* Secret */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Secret Key *</label>
            <div className="relative">
              <input
                type="text"
                value={secret}
                onChange={(e) => setSecret(e.target.value.toUpperCase())}
                placeholder="Base32-encoded secret"
                className="w-full px-3 py-2 pr-20 bg-surface border border-gray-700 rounded-lg text-white placeholder-gray-500 uppercase"
                required
              />
              <div className="absolute right-2 top-1/2 -translate-y-1/2 flex gap-1">
                <button
                  type="button"
                  onClick={handlePaste}
                  className="p-1 hover:bg-gray-700 rounded"
                  title="Paste"
                >
                  <ClipboardPaste className="w-4 h-4 text-gray-400" />
                </button>
                <button
                  type="button"
                  onClick={handleGenerateSecret}
                  className="p-1 hover:bg-gray-700 rounded"
                  title="Generate"
                >
                  <Dice5 className="w-4 h-4 text-gray-400" />
                </button>
              </div>
            </div>
          </div>

          {accountType !== 'steam' && (
            <>
              {/* Algorithm */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">Algorithm</label>
                <select
                  value={algorithm}
                  onChange={(e) => setAlgorithm(e.target.value)}
                  className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white"
                >
                  <option value="SHA1">SHA1</option>
                  <option value="SHA256">SHA256</option>
                  <option value="SHA512">SHA512</option>
                </select>
              </div>

              {/* Digits */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">Digits</label>
                <select
                  value={digits}
                  onChange={(e) => setDigits(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white"
                >
                  <option value={6}>6 digits</option>
                  <option value={7}>7 digits</option>
                  <option value={8}>8 digits</option>
                </select>
              </div>

              {accountType === 'totp' && (
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">Period (seconds)</label>
                  <select
                    value={period}
                    onChange={(e) => setPeriod(Number(e.target.value))}
                    className="w-full px-3 py-2 bg-surface border border-gray-700 rounded-lg text-white"
                  >
                    <option value={15}>15 seconds</option>
                    <option value={30}>30 seconds</option>
                    <option value={60}>60 seconds</option>
                    <option value={90}>90 seconds</option>
                    <option value={120}>120 seconds</option>
                  </select>
                </div>
              )}
            </>
          )}

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors disabled:opacity-50"
          >
            {isSubmitting ? 'Adding...' : 'Add Account'}
          </button>
        </form>
      </main>
    </div>
  );
}

function getIconForIssuer(issuer: string): string | undefined {
  const lower = issuer.toLowerCase();
  if (lower.includes('google')) return 'google';
  if (lower.includes('github')) return 'github';
  if (lower.includes('microsoft')) return 'microsoft';
  if (lower.includes('amazon')) return 'amazon';
  if (lower.includes('facebook')) return 'facebook';
  if (lower.includes('twitter')) return 'twitter';
  if (lower.includes('apple')) return 'apple';
  return undefined;
}
