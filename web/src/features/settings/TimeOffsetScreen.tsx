import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, RotateCw, AlertTriangle } from 'lucide-react';
import toast from 'react-hot-toast';

export function TimeOffsetScreen() {
  const navigate = useNavigate();
  const [currentOffset, setCurrentOffset] = useState(0);
  const [suggestedOffset, setSuggestedOffset] = useState(0);
  const [isMeasuring, setIsMeasuring] = useState(false);

  const handleMeasure = async () => {
    setIsMeasuring(true);
    // Simulate NTP measurement
    await new Promise((resolve) => setTimeout(resolve, 2000));
    setSuggestedOffset(12);
    setIsMeasuring(false);
  };

  const applyOffset = (offset: number) => {
    setCurrentOffset(offset);
    toast.success(`Time offset set to ${offset > 0 ? '+' : ''}${offset}s`);
  };

  const resetOffset = () => {
    setCurrentOffset(0);
    toast.success('Time offset reset to 0s');
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="flex items-center gap-4 px-4 py-4 border-b border-gray-800">
        <button
          onClick={() => navigate('/settings')}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-xl font-bold text-white">Time Offset</h1>
      </header>

      <main className="p-4 space-y-6">
        {/* Warning banner */}
        {currentOffset !== 0 && (
          <div className="bg-amber-900/50 border border-amber-700 rounded-xl p-4 flex items-center gap-3">
            <AlertTriangle className="w-5 h-5 text-amber-400 flex-shrink-0" />
            <p className="text-amber-100">
              Offset active: {currentOffset > 0 ? '+' : ''}{currentOffset} seconds
            </p>
          </div>
        )}

        {/* Slider */}
        <div className="bg-surface rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-6">Adjust Time Offset</h2>
          
          <input
            type="range"
            min="-300"
            max="300"
            value={currentOffset}
            onChange={(e) => setCurrentOffset(parseInt(e.target.value))}
            className="w-full h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-primary"
          />
          
          <div className="flex justify-between mt-2 text-sm text-gray-500">
            <span>-300s</span>
            <span>0s</span>
            <span>+300s</span>
          </div>

          {/* Fine adjustment */}
          <div className="flex items-center justify-center gap-4 mt-6">
            <button
              onClick={() => setCurrentOffset((prev) => Math.max(-300, prev - 1))}
              className="w-10 h-10 rounded-lg bg-gray-700 hover:bg-gray-600 flex items-center justify-center transition-colors"
            >
              <span className="text-xl">−</span>
            </button>
            <span className="text-2xl font-bold w-24 text-center">
              {currentOffset > 0 ? '+' : ''}{currentOffset}s
            </span>
            <button
              onClick={() => setCurrentOffset((prev) => Math.min(300, prev + 1))}
              className="w-10 h-10 rounded-lg bg-gray-700 hover:bg-gray-600 flex items-center justify-center transition-colors"
            >
              <span className="text-xl">+</span>
            </button>
          </div>
        </div>

        {/* NTP Sync */}
        <div className="bg-surface rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-2">NTP Time Sync</h2>
          <p className="text-sm text-gray-400 mb-4">
            Measure the difference between your device clock and NTP server time.
          </p>

          <button
            onClick={handleMeasure}
            disabled={isMeasuring}
            className="w-full py-3 px-4 bg-primary hover:bg-primary/90 disabled:bg-gray-700 text-white rounded-lg font-semibold transition-colors flex items-center justify-center gap-2"
          >
            {isMeasuring ? (
              <>
                <RotateCw className="w-5 h-5 animate-spin" />
                Measuring...
              </>
            ) : (
              <>
                <RotateCw className="w-5 h-5" />
                Measure NTP Drift
              </>
            )}
          </button>

          {suggestedOffset !== 0 && (
            <div className="mt-4 p-4 bg-blue-900/50 border border-blue-700 rounded-lg">
              <p className="text-blue-100 text-center">
                NTP diff detected: {suggestedOffset > 0 ? '+' : ''}{suggestedOffset}s
              </p>
              <button
                onClick={() => applyOffset(suggestedOffset)}
                className="mt-2 w-full py-2 text-blue-100 hover:text-white transition-colors"
              >
                Apply suggested: {suggestedOffset > 0 ? '+' : ''}{suggestedOffset}s
              </button>
            </div>
          )}
        </div>

        {/* Preview */}
        <div className="bg-surface rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Preview with Current Offset</h2>
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-gray-400">Current:</span>
              <span className="font-mono text-xl font-bold">123 456</span>
              <span className="text-sm text-gray-500">(28s)</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-gray-400">Next:</span>
              <span className="font-mono text-xl font-bold">789 012</span>
            </div>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex gap-4">
          <button
            onClick={resetOffset}
            className="flex-1 py-3 px-4 border border-gray-600 hover:border-gray-500 text-white rounded-lg font-semibold transition-colors"
          >
            Reset to 0
          </button>
          <button
            onClick={() => applyOffset(currentOffset)}
            className="flex-1 py-3 px-4 bg-primary hover:bg-primary/90 text-white rounded-lg font-semibold transition-colors"
          >
            Apply
          </button>
        </div>
      </main>
    </div>
  );
}
