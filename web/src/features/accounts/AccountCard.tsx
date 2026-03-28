import { useState } from 'react';
import { useTOTP } from '@/hooks/useTOTP';
import { Account } from '@/core/db/schema';
import { Star, MoreVertical } from 'lucide-react';
import { useAccountStore } from './store';
import toast from 'react-hot-toast';

interface AccountCardProps {
  account: Account;
  index: number;
}

export function AccountCard({ account, index }: AccountCardProps) {
  const { globalTimeOffset } = useAccountStore();
  const { code, remaining, nextCode, progress } = useTOTP(account, globalTimeOffset);
  const [isRevealed, setIsRevealed] = useState(!account.tapToReveal);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    toast.success('Code copied to clipboard');
    
    // Auto-clear after 30 seconds
    setTimeout(() => {
      navigator.clipboard.writeText('');
    }, 30000);
  };

  const handleTap = () => {
    if (account.tapToReveal) {
      setIsRevealed(!isRevealed);
    } else {
      handleCopy();
    }
  };

  return (
    <div
      className="bg-surface rounded-xl p-4 cursor-pointer hover:bg-surface/80 transition-colors"
      onClick={handleTap}
    >
      <div className="flex items-start gap-4">
        {/* Icon */}
        <div className="w-12 h-12 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
          {account.iconCustom ? (
            <img
              src={URL.createObjectURL(new Blob([account.iconCustom as unknown as ArrayBuffer]))}
              alt={account.issuer}
              className="w-full h-full object-cover rounded-full"
            />
          ) : (
            <span className="text-white font-bold text-lg">
              {account.issuer[0]?.toUpperCase()}
            </span>
          )}
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between mb-1">
            <h3 className="font-semibold text-white truncate">{account.issuer}</h3>
            {account.favorite && (
              <Star className="w-4 h-4 text-amber-400 fill-amber-400" />
            )}
          </div>
          <p className="text-sm text-gray-400 truncate mb-3">{account.label}</p>

          <div className="flex items-center gap-4">
            {/* OTP Code */}
            <div className="font-mono text-2xl font-bold tracking-wider">
              {isRevealed ? (
                <span className="otp-code text-white">
                  {code.slice(0, 3)} {code.slice(3)}
                </span>
              ) : (
                <span className="text-gray-500">• • •   • • •</span>
              )}
            </div>

            {/* Progress Ring */}
            <div className="relative w-12 h-12">
              <svg className="w-full h-full -rotate-90" viewBox="0 0 36 36">
                <circle
                  cx="18"
                  cy="18"
                  r="16"
                  fill="none"
                  stroke="#374151"
                  strokeWidth="3"
                />
                <circle
                  cx="18"
                  cy="18"
                  r="16"
                  fill="none"
                  stroke={getProgressColor(progress)}
                  strokeWidth="3"
                  strokeDasharray="100"
                  strokeDashoffset={100 - progress * 100}
                  strokeLinecap="round"
                  className="transition-all duration-1000"
                />
              </svg>
              <span className={`absolute inset-0 flex items-center justify-center text-xs font-bold ${
                remaining <= 5 ? 'text-red-400' : 'text-gray-300'
              }`}>
                {remaining}
              </span>
            </div>
          </div>

          {/* Next code preview */}
          {isRevealed && (
            <p className="text-xs text-gray-500 mt-2">
              Next: <span className="font-mono">{nextCode}</span>
            </p>
          )}
        </div>

        {/* Menu button */}
        <button
          onClick={(e) => {
            e.stopPropagation();
          }}
          className="p-2 hover:bg-gray-700 rounded-lg transition-colors"
        >
          <MoreVertical className="w-5 h-5 text-gray-400" />
        </button>
      </div>
    </div>
  );
}

function getProgressColor(progress: number): string {
  if (progress > 0.5) return '#4ade80';
  if (progress > 0.2) return '#fb923c';
  return '#f87171';
}
