import React from 'react';

interface LoadingScreenProps {
  message?: string;
}

const LoadingScreen: React.FC<LoadingScreenProps> = ({ message = "Loading..." }) => {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-slate-50 safe-area-inset-top safe-area-inset-bottom pwa-full-height">
      <div className="text-center">
        {/* Simple loading spinner */}
        <div className="w-12 h-12 border-4 border-slate-200 border-t-slate-600 rounded-full animate-spin mb-4"></div>
        
        {/* Loading message */}
        <div className="text-lg text-slate-600 font-medium">
          {message}
        </div>
      </div>
    </div>
  );
};

export default LoadingScreen;
