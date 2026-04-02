import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Html5Qrcode } from 'html5-qrcode';
import { ArrowLeft } from 'lucide-react';
import { useAccountStore } from './store';
import { generateSecret } from '@/core/crypto/totp';
import toast from 'react-hot-toast';

export function QRScannerScreen() {
  const navigate = useNavigate();
  const [error, setError] = useState('');
  const [scanning, setScanning] = useState(true);

  const handleScan = (decodedText: string) => {
    setScanning(false);
    try {
      parseAndAddAccount(decodedText);
    } catch (e) {
      setError('Failed to parse QR code');
      setScanning(true);
    }
  };

  const handleError = (errorMessage: string) => {
    // Ignore common scanning errors
  };

  useState(() => {
    const scanner = new Html5Qrcode('qr-reader');
    scanner.start(
      { facingMode: 'environment' },
      { fps: 10, qrbox: { width: 250, height: 250 } },
      handleScan,
      handleError
    ).catch((err) => {
      setError('Camera not available: ' + err);
      setScanning(false);
    });

    return () => {
      scanner.stop().catch(() => {});
    };
  });

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center gap-4 px-4 py-4 border-b border-gray-800">
        <button
          onClick={() => navigate(-1)}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-xl font-bold text-white">Scan QR Code</h1>
      </header>

      <main className="p-4">
        {error ? (
          <div className="text-center">
            <p className="text-red-400 mb-4">{error}</p>
            <button
              onClick={() => navigate('/account/add/manual')}
              className="px-4 py-2 bg-primary text-white rounded-lg"
            >
              Enter Manually
            </button>
          </div>
        ) : (
          <div id="qr-reader" className="max-w-sm mx-auto" />
        )}
      </main>
    </div>
  );
}

function parseAndAddAccount(uri: string) {
  const parsed = new URL(uri);
  const pathParts = parsed.pathname.split('/').filter(Boolean);

  let issuer = '';
  let label = '';

  if (pathParts.length >= 2) {
    issuer = decodeURIComponent(pathParts[0]);
    label = decodeURIComponent(pathParts[1]);
  } else if (pathParts.length === 1) {
    label = decodeURIComponent(pathParts[0]);
  }

  const secret = parsed.searchParams.get('secret') || '';
  const algorithm = (parsed.searchParams.get('algorithm') || 'SHA1').toUpperCase();
  const digits = parseInt(parsed.searchParams.get('digits') || '6', 10);
  const period = parseInt(parsed.searchParams.get('period') || '30', 10);
  const counter = parseInt(parsed.searchParams.get('counter') || '0', 10);

  if (!secret) {
    toast.error('No secret found in QR code');
    return;
  }

  const encoder = new TextEncoder();
  const encryptedPayload = encoder.encode(secret.toUpperCase());

  const accountType = parsed.protocol.replace(':', '') as 'totp' | 'hotp' | 'steam';

  useAccountStore.getState().addAccount({
    uuid: crypto.randomUUID(),
    type: accountType,
    issuer,
    label,
    encryptedPayload,
    algorithm,
    digits,
    period,
    counter,
    timeOffset: 0,
    sortOrder: 0,
    favorite: false,
    tapToReveal: false,
    iconName: getIconForIssuer(issuer) ?? undefined,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  toast.success('Account added successfully');
}

function getIconForIssuer(issuer: string): string | null {
  const lower = issuer.toLowerCase();
  if (lower.includes('google')) return 'google';
  if (lower.includes('github')) return 'github';
  if (lower.includes('microsoft')) return 'microsoft';
  if (lower.includes('amazon')) return 'amazon';
  if (lower.includes('facebook')) return 'facebook';
  if (lower.includes('twitter')) return 'twitter';
  if (lower.includes('apple')) return 'apple';
  return null;
}
