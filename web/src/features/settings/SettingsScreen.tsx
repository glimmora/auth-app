import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Fingerprint, Timer, Palette, Info, Shield, Download, Upload, HardDrive, RotateCcw } from 'lucide-react';

export function SettingsScreen() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center gap-4 px-4 py-4 border-b border-gray-800">
        <button
          onClick={() => navigate('/home')}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-xl font-bold text-white">Settings</h1>
      </header>

      <main className="p-4 space-y-6">
        {/* Security Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Security
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <div className="flex items-center justify-between p-4 border-b border-gray-800">
              <div className="flex items-center gap-3">
                <Fingerprint className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Biometric Unlock</p>
                  <p className="text-sm text-gray-400">Use fingerprint or face to unlock</p>
                </div>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" defaultChecked className="sr-only peer" />
                <div className="w-11 h-6 bg-gray-700 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-primary/20 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
              </label>
            </div>
            <button className="w-full flex items-center gap-3 p-4 hover:bg-gray-800 transition-colors text-left">
              <Timer className="w-5 h-5 text-gray-400" />
              <div>
                <p className="font-medium text-white">Auto-Lock</p>
                <p className="text-sm text-gray-400">After 30 seconds</p>
              </div>
            </button>
          </div>
        </section>

        {/* Time Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Time
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <button
              onClick={() => navigate('/settings/time-offset')}
              className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left"
            >
              <div className="flex items-center gap-3">
                <Timer className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Time Offset</p>
                  <p className="text-sm text-gray-400">Adjust for clock drift</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>
        </section>

        {/* Appearance Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Appearance
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <Palette className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Theme</p>
                  <p className="text-sm text-gray-400">Dark</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>
        </section>

        {/* Backup Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Backup & Sync
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <button
              onClick={() => navigate('/backup')}
              className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left"
            >
              <div className="flex items-center gap-3">
                <HardDrive className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Backup</p>
                  <p className="text-sm text-gray-400">Last backup: Never</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <RotateCcw className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Restore</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>
        </section>

        {/* Data Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            Data
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <Download className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Import</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <Upload className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Export</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>
        </section>

        {/* About Section */}
        <section>
          <h2 className="text-sm font-semibold text-primary mb-3 uppercase tracking-wider">
            About
          </h2>
          <div className="bg-surface rounded-xl overflow-hidden">
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <Info className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">About AuthVault</p>
                  <p className="text-sm text-gray-400">Version 1.0.0</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
            <button className="w-full flex items-center justify-between p-4 hover:bg-gray-800 transition-colors text-left">
              <div className="flex items-center gap-3">
                <Shield className="w-5 h-5 text-gray-400" />
                <div>
                  <p className="font-medium text-white">Privacy Policy</p>
                </div>
              </div>
              <span className="text-gray-400">›</span>
            </button>
          </div>
        </section>
      </main>
    </div>
  );
}
