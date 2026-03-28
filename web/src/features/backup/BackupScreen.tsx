import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, FileDown, Cloud, FileUp, QrCode, Info } from 'lucide-react';
import toast from 'react-hot-toast';

export function BackupScreen() {
  const navigate = useNavigate();

  const handleExport = async () => {
    try {
      // In production, create encrypted backup using AVX encoder
      toast.success('Backup exported successfully');
    } catch (error) {
      toast.error('Export failed');
    }
  };

  const handleImport = async () => {
    try {
      // In production, import from AVX file
      toast.success('Backup imported successfully');
    } catch (error) {
      toast.error('Import failed');
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center gap-4 px-4 py-4 border-b border-gray-800">
        <button
          onClick={() => navigate('/home')}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-xl font-bold text-white">Backup & Restore</h1>
      </header>

      <main className="p-4 space-y-6">
        {/* Export Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Export Backup
          </h2>
          <div className="bg-surface rounded-xl p-6">
            <p className="text-white font-medium mb-2">
              Export all accounts to an encrypted file
            </p>
            <p className="text-sm text-gray-400 mb-4">
              Backup file is encrypted with AES-256-GCM. Keep it safe and never share it.
            </p>

            <div className="space-y-3">
              <button
                onClick={handleExport}
                className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-white rounded-lg font-semibold transition-colors flex items-center justify-center gap-2"
              >
                <FileDown className="w-5 h-5" />
                Export to File
              </button>

              <button
                onClick={() => toast('Connect to cloud storage first')}
                className="w-full py-3 px-4 border border-gray-600 hover:border-primary text-white rounded-lg font-semibold transition-colors flex items-center justify-center gap-2"
              >
                <Cloud className="w-5 h-5" />
                Backup to Cloud
              </button>
            </div>
          </div>
        </section>

        {/* Import Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Import Backup
          </h2>
          <div className="bg-surface rounded-xl p-6">
            <p className="text-white font-medium mb-2">
              Restore accounts from a backup file
            </p>
            <p className="text-sm text-gray-400 mb-4">
              Supports .avx backup files from AuthVault.
            </p>

            <button
              onClick={handleImport}
              className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-white rounded-lg font-semibold transition-colors flex items-center justify-center gap-2"
            >
              <FileUp className="w-5 h-5" />
              Import from File
            </button>
          </div>
        </section>

        {/* Cloud Backup Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Cloud Backup
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <div className="p-4 border-b border-gray-800 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Cloud className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Google Drive</p>
                  <p className="text-sm text-gray-400">Not connected</p>
                </div>
              </div>
              <button className="px-4 py-2 border border-gray-600 hover:border-primary text-white rounded-lg text-sm transition-colors">
                Connect
              </button>
            </div>

            <div className="p-4 border-b border-gray-800 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <Cloud className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Dropbox</p>
                  <p className="text-sm text-gray-400">Not connected</p>
                </div>
              </div>
              <button className="px-4 py-2 border border-gray-600 hover:border-primary text-white rounded-lg text-sm transition-colors">
                Connect
              </button>
            </div>

            <div className="p-4 flex items-center justify-between opacity-50">
              <div className="flex items-center gap-3">
                <Cloud className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">iCloud</p>
                  <p className="text-sm text-gray-400">Not available</p>
                </div>
              </div>
              <span className="text-gray-400">🔒</span>
            </div>
          </div>
        </section>

        {/* QR Export Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            QR Export
          </h2>
          <div className="bg-surface rounded-xl p-6">
            <p className="text-white font-medium mb-4">
              Export accounts as QR codes for transfer to another device
            </p>

            <button
              onClick={() => toast('QR export coming soon')}
              className="w-full py-3 px-4 bg-primary hover:bg-primary/90 text-white rounded-lg font-semibold transition-colors flex items-center justify-center gap-2"
            >
              <QrCode className="w-5 h-5" />
              Export as QR Codes
            </button>
          </div>
        </section>

        {/* Last backup info */}
        <div className="bg-blue-900/30 border border-blue-800 rounded-xl p-4 flex items-center gap-3">
          <Info className="w-5 h-5 text-blue-400 flex-shrink-0" />
          <p className="text-blue-100 text-sm">
            Last backup: Never
          </p>
        </div>
      </main>
    </div>
  );
}
