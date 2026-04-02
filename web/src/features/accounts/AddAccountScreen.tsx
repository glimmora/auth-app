import React, { useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, QrCode, Image, Edit } from 'lucide-react';
import { Html5Qrcode } from 'html5-qrcode';
import toast from 'react-hot-toast';

export function AddAccountScreen() {
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImageImport = async () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    try {
      const scanner = new Html5Qrcode('hidden-qr-reader');
      const result = await scanner.scanFile(file, false);
      if (result && result.startsWith('otpauth://')) {
        navigate('/account/add/manual');
        toast.success('QR code found from image');
      } else {
        toast.error('No valid otpauth:// QR code found in image');
      }
    } catch {
      toast.error('No QR code detected in image');
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
        <h1 className="text-xl font-bold text-white">Add Account</h1>
      </header>

      <main className="p-4 space-y-4">
        <button
          onClick={() => navigate('/account/add/scan')}
          className="w-full bg-surface rounded-xl p-4 flex items-center gap-4 hover:bg-surface/80 transition-colors"
        >
          <div className="w-12 h-12 rounded-full bg-blue-600 flex items-center justify-center">
            <QrCode className="w-6 h-6 text-white" />
          </div>
          <div className="flex-1 text-left">
            <h3 className="font-semibold text-white">Scan QR Code</h3>
            <p className="text-sm text-gray-400">Use camera to scan a QR code</p>
          </div>
        </button>

        <button
          onClick={handleImageImport}
          className="w-full bg-surface rounded-xl p-4 flex items-center gap-4 hover:bg-surface/80 transition-colors"
        >
          <div className="w-12 h-12 rounded-full bg-green-600 flex items-center justify-center">
            <Image className="w-6 h-6 text-white" />
          </div>
          <div className="flex-1 text-left">
            <h3 className="font-semibold text-white">Import from Image</h3>
            <p className="text-sm text-gray-400">Select an image with QR code</p>
          </div>
        </button>

        <button
          onClick={() => navigate('/account/add/manual')}
          className="w-full bg-surface rounded-xl p-4 flex items-center gap-4 hover:bg-surface/80 transition-colors"
        >
          <div className="w-12 h-12 rounded-full bg-purple-600 flex items-center justify-center">
            <Edit className="w-6 h-6 text-white" />
          </div>
          <div className="flex-1 text-left">
            <h3 className="font-semibold text-white">Manual Entry</h3>
            <p className="text-sm text-gray-400">Enter details manually</p>
          </div>
        </button>

        <div className="mt-8 p-4 bg-surface/50 rounded-xl">
          <p className="text-sm text-gray-400 text-center">
            You can add accounts from any service that supports TOTP or HOTP,
            including Google, GitHub, Microsoft, and more.
          </p>
        </div>
      </main>

      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />
      <div id="hidden-qr-reader" className="hidden" />
    </div>
  );
}
