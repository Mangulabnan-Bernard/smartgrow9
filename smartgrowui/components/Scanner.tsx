import React, { useRef, useState, useCallback, useEffect } from 'react';
import { Camera, Upload, X, Loader2, RefreshCcw, Leaf, Image as ImageIcon, Wifi, WifiOff, Cpu } from 'lucide-react';
import { analyzePlant } from '../services/aiService';
import { DiagnosisResult, Language } from '../types';

interface ScannerProps {
  lang: Language;
  onResult: (result: Partial<DiagnosisResult>) => void;
  onBack: () => void;
}

const Scanner: React.FC<ScannerProps> = ({ lang, onResult, onBack }) => {
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [facingMode, setFacingMode] = useState<'user' | 'environment'>('environment');

  // SPLIT INTO THREE SEPARATE ERROR STATES
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [notRecognized, setNotRecognized] = useState(false);
  const [offlineError, setOfflineError] = useState(false);
  const [inferenceMethod, setInferenceMethod] = useState<'tflite' | 'gemini' | null>(null);

  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
  }, [stream]);

  const startCamera = useCallback(async () => {
    stopCamera();

    // Release camera completely before requesting again
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    // Wait for OS to release camera
    await new Promise(resolve => setTimeout(resolve, 500));

    setCameraError(null);

    const constraintSets = [
      { video: { facingMode: { ideal: facingMode }, width: { ideal: 1280 }, height: { ideal: 720 } } },
      { video: { facingMode: { ideal: facingMode } } },
      { video: { facingMode } }
    ];

    let lastError = null;
    for (const constraints of constraintSets) {
      try {
        const newStream = await navigator.mediaDevices.getUserMedia(constraints);
        setStream(newStream);
        if (videoRef.current) videoRef.current.srcObject = newStream;
        setCameraError(null);
        return;
      } catch (err) {
        lastError = err;
      }
    }

    if (lastError instanceof DOMException && lastError.name === 'NotAllowedError') {
      setCameraError('📷 Camera access needed. Please allow camera access to scan plants.');
    } else if (lastError instanceof DOMException && lastError.name === 'NotReadableError') {
      setCameraError('📷 Camera is busy. Please close other apps using the camera.');
    } else {
      setCameraError('📷 Unable to access camera. Please check your device settings.');
    }
  }, [facingMode, stopCamera]);

  useEffect(() => {
    const timer = setTimeout(() => startCamera(), 100);
    return () => {
      clearTimeout(timer);
      stopCamera();
    };
  }, [facingMode]);

  const handleCapture = async () => {
    if (!videoRef.current || !canvasRef.current || isAnalyzing) return;
    const canvas = canvasRef.current;
    const video = videoRef.current;
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    canvas.getContext('2d')?.drawImage(video, 0, 0);
    const imageB64 = canvas.toDataURL('image/jpeg', 0.85);
    processImage(imageB64);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      setCameraError('Please upload an image file.');
      return;
    }
    const reader = new FileReader();
    reader.onload = (event) => {
      processImage(event.target?.result as string);
    };
    reader.readAsDataURL(file);
  };

  const processImage = async (imageB64: string) => {
    setIsAnalyzing(true);
    setCameraError(null);
    setNotRecognized(false);
    setOfflineError(false);
    setInferenceMethod(null);

    try {
      const { result, error: aiError } = await analyzePlant(imageB64, lang);

      // ================================
      // CASE 1: NO INTERNET (TFLite failed too)
      // ================================
      if (aiError === 'OFFLINE') {
        console.warn('⚠️ Device is offline and TFLite unavailable');
        setOfflineError(true);
        return;
      }

      // ================================
      // CASE 2: API or Scan Error
      // ================================
      if (aiError === 'SCAN_FAILED' || aiError === 'API_ERROR' || !result) {
        setCameraError('Scan failed. Please check your internet and try again.');
        return;
      }

      // ================================
      // CASE 3: Plant not recognized
      // ================================
      if (aiError === 'NOT_RECOGNIZED' || (result && result.isPlant === false)) {
        setNotRecognized(true);
        return;
      }

      // ================================
      // CASE 4: Valid plant detected
      // ================================
      // Always show TFLite method since we're testing TFLite-only mode
      setInferenceMethod('tflite');
      
      stopCamera();
      onResult({ ...result, imageUrl: imageB64 });

    } catch (err: any) {
      console.error('Unexpected error:', err);
      setCameraError(err.message || 'Analysis failed. Please try again.');
    } finally {
      setIsAnalyzing(false);
    }
  };

  const toggleCamera = () => {
    setFacingMode(prev => prev === 'user' ? 'environment' : 'user');
  };

  const handleTryAgain = () => {
    setNotRecognized(false);
    setCameraError(null);
    setOfflineError(false);
    setInferenceMethod(null);
  };

  return (
    <div className="fixed inset-0 bg-black z-[200] flex flex-col text-white animate-in fade-in duration-300">

      {/* Header */}
      <div className="p-6 flex justify-between items-center z-10 bg-gradient-to-b from-black/80 to-transparent">
        <button
          onClick={() => { stopCamera(); onBack(); }}
          className="p-3 bg-white/10 backdrop-blur-md rounded-2xl hover:bg-white/20 transition-all"
        >
          <X className="w-6 h-6" />
        </button>
        <div className="flex flex-col items-center">
          <h2 className="text-sm font-black uppercase tracking-widest text-[var(--primary-400)]">Smart Scanner</h2>
          <p className="text-[10px] text-white/60 font-medium">Point at plant leaves</p>
        </div>
        <button
          onClick={toggleCamera}
          className="p-3 bg-white/10 backdrop-blur-md rounded-2xl hover:bg-white/20 transition-all"
        >
          <RefreshCcw className="w-6 h-6" />
        </button>
      </div>

      {/* Viewport */}
      <div className="flex-1 relative flex items-center justify-center overflow-hidden bg-slate-950">

        {/* Camera feed */}
        <video
          ref={videoRef}
          autoPlay
          playsInline
          muted
          className="w-full h-full object-cover"
          style={{ transform: facingMode === 'user' ? 'scaleX(-1)' : 'scaleX(1)' }}
        />

        {/* Analyzing overlay */}
        {isAnalyzing && (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-[var(--primary-950)]/80 backdrop-blur-lg z-20 p-10 text-center">
            <div className="relative mb-8">
              <div className="w-24 h-24 border-4 border-[var(--primary-500)]/30 rounded-full animate-ping absolute inset-0"></div>
              <div className="w-24 h-24 bg-[var(--primary-500)] rounded-full flex items-center justify-center relative">
                <Leaf className="w-10 h-10 text-white animate-pulse" />
              </div>
            </div>
            <h3 className="text-2xl font-black mb-2">Analyzing Sample...</h3>
            <p className="text-[var(--primary-300)]/60 text-sm font-medium max-w-xs mb-4">
              Identifying species and health markers.
            </p>
            
            {/* Inference method indicator */}
            <div className="flex items-center gap-2 px-4 py-2 bg-white/10 rounded-full backdrop-blur-sm">
              {inferenceMethod === 'tflite' ? (
                <>
                  <Cpu className="w-4 h-4 text-green-400" />
                  <span className="text-xs text-green-400 font-medium">Offline AI (TensorFlow)</span>
                </>
              ) : inferenceMethod === 'gemini' ? (
                <>
                  <Wifi className="w-4 h-4 text-blue-400" />
                  <span className="text-xs text-blue-400 font-medium">Online AI (Gemini)</span>
                </>
              ) : (
                <>
                  <Loader2 className="w-4 h-4 text-white/60 animate-spin" />
                  <span className="text-xs text-white/60">Initializing AI...</span>
                </>
              )}
            </div>
          </div>
        )}

        {/* ================================ */}
        {/* OFFLINE ERROR MODAL              */}
        {/* Only shows when no internet     */}
        {/* ================================ */}
        {offlineError && (
          <div className="absolute inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/90 backdrop-blur-md">
            <div className="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl p-8 text-center">
              {/* Icon */}
              <div className="w-20 h-20 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <WifiOff className="w-10 h-10 text-yellow-600" />
              </div>

              <h3 className="text-xl font-bold text-slate-800 mb-2">
                No Internet Connection
              </h3>
              <p className="text-slate-600 text-sm mb-6">
                Plant analysis requires an internet connection. Please connect to Wi-Fi or mobile data and try again.
              </p>

              {/* Status indicator */}
              <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-4 mb-6">
                <p className="text-yellow-800 text-xs font-medium">
                  📡 Waiting for connection...
                </p>
              </div>

              {/* Retry button */}
              <button
                onClick={handleTryAgain}
                className="bg-[var(--primary-600)] text-white px-8 py-3 rounded-2xl font-bold hover:bg-[var(--primary-700)] transition-colors w-full"
              >
                Try Again
              </button>

              {/* Or upload */}
              <button
                onClick={() => fileInputRef.current?.click()}
                className="mt-3 text-[var(--primary-600)] font-medium hover:text-[var(--primary-700)] transition-colors block w-full"
              >
                Or Upload Photo Instead
              </button>
            </div>
          </div>
        )}

        {/* ================================ */}
        {/* NOT RECOGNIZED MODAL             */}
        {/* Only shows for wrong plants      */}
        {/* ================================ */}
        {notRecognized && !offlineError && (
          <div className="absolute inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/90 backdrop-blur-md">
            <div className="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl p-8 text-center">

              {/* Icon */}
              <div className="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-4xl">🚫</span>
              </div>

              <h3 className="text-xl font-bold text-slate-800 mb-2">
                Not Recognized
              </h3>
              <p className="text-slate-500 text-sm mb-6">
                This is not available.<br />
                This app only supports:
              </p>

              {/* The 3 supported plants */}
              <div className="flex justify-center gap-6 mb-8">
                <div className="flex flex-col items-center gap-1">
                  <span className="text-4xl">🍅</span>
                  <span className="text-xs font-bold text-slate-700">Tomato</span>
                </div>
                <div className="flex flex-col items-center gap-1">
                  <span className="text-4xl">🧄</span>
                  <span className="text-xs font-bold text-slate-700">Garlic</span>
                </div>
                <div className="flex flex-col items-center gap-1">
                  <span className="text-4xl">🧅</span>
                  <span className="text-xs font-bold text-slate-700">Red Onion</span>
                </div>
              </div>

              {/* Try Again */}
              <button
                onClick={handleTryAgain}
                className="bg-green-500 text-white px-8 py-3 rounded-2xl font-bold hover:bg-green-600 transition-colors w-full mb-3"
              >
                Try Again
              </button>

              <button
                onClick={() => fileInputRef.current?.click()}
                className="text-green-600 font-medium hover:text-green-700 transition-colors text-sm"
              >
                Or Upload Photo Instead
              </button>

            </div>
          </div>
        )}

        {/* ================================ */}
        {/* CAMERA ERROR MODAL               */}
        {/* Only shows for camera problems   */}
        {/* ================================ */}
        {cameraError && !notRecognized && !offlineError && (
          <div className="absolute inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/80 backdrop-blur-md">
            <div className="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl p-8 text-center">
              <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <RefreshCcw className="w-8 h-8 text-orange-500" />
              </div>
              <h3 className="text-xl font-bold text-slate-800 mb-2">Camera Access</h3>
              <p className="text-slate-600 mb-6">{cameraError}</p>
              <button
                onClick={() => { setCameraError(null); startCamera(); }}
                className="bg-[var(--primary-600)] text-white px-8 py-3 rounded-2xl font-bold hover:bg-[var(--primary-700)] transition-colors w-full"
              >
                Try Again
              </button>
              <button
                onClick={() => fileInputRef.current?.click()}
                className="mt-3 text-[var(--primary-600)] font-medium hover:text-[var(--primary-700)] transition-colors block w-full"
              >
                Or Upload Photo Instead
              </button>
            </div>
          </div>
        )}

      </div>

      {/* Shutter Bar */}
      <div className="p-10 pb-16 flex items-center justify-around bg-gradient-to-t from-black/90 to-transparent">
        <button
          onClick={() => fileInputRef.current?.click()}
          className="flex flex-col items-center gap-2 group"
        >
          <div className="p-4 bg-white/10 rounded-2xl group-hover:bg-white/20 transition-all border border-white/5">
            <ImageIcon className="w-6 h-6 text-white" />
          </div>
          <span className="text-[10px] font-black uppercase tracking-widest text-white/50 group-hover:text-white">Gallery</span>
        </button>

        <input
          type="file"
          ref={fileInputRef}
          className="hidden"
          accept="image/*"
          onChange={handleFileUpload}
        />

        <button
          onClick={handleCapture}
          disabled={isAnalyzing}
          className="w-20 h-20 rounded-full border-[4px] border-white/30 flex items-center justify-center p-1 group active:scale-95 transition-all disabled:opacity-50"
        >
          <div className="w-full h-full bg-white rounded-full group-hover:scale-95 transition-transform shadow-2xl"></div>
        </button>

        <div className="w-16"></div>
      </div>

      <canvas ref={canvasRef} className="hidden" />
    </div>
  );
};

export default Scanner;