import React from 'react';

interface LoadingScreenProps {
  message?: string;
}

const LoadingScreen: React.FC<LoadingScreenProps> = ({ message = "Authenticating with SmartGrow AI..." }) => {
  return (
    <div className="fixed inset-0 bg-gradient-to-br from-green-50 to-emerald-100 flex items-center justify-center z-50 safe-area-inset-top safe-area-inset-bottom pwa-full-height">
      <div className="text-center">
        {/* Animated plant icon using CSS only */}
        <div className="mb-6">
          <div className="relative w-16 h-16 mx-auto">
            <div className="absolute inset-0 bg-green-500 rounded-full animate-pulse"></div>
            <div className="absolute inset-2 bg-green-600 rounded-full animate-ping"></div>
            <div className="absolute inset-4 bg-white rounded-full flex items-center justify-center">
              {/* Plant symbol using CSS */}
              <div className="w-8 h-8 bg-green-500 rounded-t-full relative">
                <div className="absolute bottom-0 left-1/2 transform -translate-x-1/2 translate-y-1/2 w-6 h-6 bg-green-600 rounded-full"></div>
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-4 h-4 bg-green-400 rounded-full"></div>
                <div className="absolute top-0 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-2 h-2 bg-green-300 rounded-full"></div>
              </div>
            </div>
          </div>
        </div>
        
        {/* Loading text */}
        <div className="space-y-2">
          <h2 className="text-xl font-semibold text-gray-800 animate-pulse">
            {message}
          </h2>
          <div className="flex justify-center space-x-2">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
            <div className="w-2 h-2 bg-green-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
            <div className="w-2 h-2 bg-green-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
          </div>
        </div>
        
        {/* Progress indicator */}
        <div className="mt-8 w-64 mx-auto">
          <div className="h-1 bg-gray-200 rounded-full overflow-hidden">
            <div className="h-full bg-gradient-to-r from-green-400 to-green-600 rounded-full animate-pulse" style={{ width: '60%' }}></div>
          </div>
        </div>
        
        {/* Firebase connection status */}
        <div className="mt-6 text-sm text-gray-600">
          <div className="animate-pulse">🔐 Securing connection...</div>
        </div>
      </div>
      
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-10 -left-10 w-32 h-32 bg-green-200 rounded-full opacity-20 animate-float"></div>
        <div className="absolute -bottom-10 -right-10 w-40 h-40 bg-emerald-200 rounded-full opacity-20 animate-float" style={{ animationDelay: '2s' }}></div>
        <div className="absolute top-1/2 left-1/4 w-24 h-24 bg-green-100 rounded-full opacity-10 animate-float" style={{ animationDelay: '1s' }}></div>
      </div>
    </div>
  );
};

export default LoadingScreen;
