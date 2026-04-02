import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';

import { LockScreen } from '@/features/auth-lock/LockScreen';
import { AccountsScreen } from '@/features/accounts/AccountsScreen';
import { AddAccountScreen } from '@/features/accounts/AddAccountScreen';
import { QRScannerScreen } from '@/features/accounts/QRScannerScreen';
import { ManualEntryScreen } from '@/features/accounts/ManualEntryScreen';
import { SettingsScreen } from '@/features/settings/SettingsScreen';
import { TimeOffsetScreen } from '@/features/settings/TimeOffsetScreen';
import { BackupScreen } from '@/features/backup/BackupScreen';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/lock" replace />} />
        <Route path="/lock" element={<LockScreen />} />
        <Route path="/home" element={<AccountsScreen />} />
        <Route path="/account/add" element={<AddAccountScreen />} />
        <Route path="/account/add/scan" element={<QRScannerScreen />} />
        <Route path="/account/add/manual" element={<ManualEntryScreen />} />
        <Route path="/settings" element={<SettingsScreen />} />
        <Route path="/settings/time-offset" element={<TimeOffsetScreen />} />
        <Route path="/backup" element={<BackupScreen />} />
      </Routes>
      <Toaster
        position="bottom-center"
        toastOptions={{
          duration: 2000,
          style: {
            background: '#1A1A2E',
            color: '#fff',
          },
        }}
      />
    </BrowserRouter>
  );
}
