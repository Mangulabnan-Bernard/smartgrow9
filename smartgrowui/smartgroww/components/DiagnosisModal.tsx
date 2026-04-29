
import React, { useState } from 'react';
import { X, Check, Activity, ShieldAlert, Sparkles, BookOpen, Share2, Thermometer, Droplets, Sun, AlertCircle } from 'lucide-react';
import { DiagnosisResult, Language } from '../types';
import { TRANSLATIONS } from '../constants';

interface DiagnosisModalProps {
  result: DiagnosisResult;
  lang: Language;
  onClose: () => void;
  onSave: (result: DiagnosisResult, monitor: boolean) => void;
}

const DiagnosisModal: React.FC<DiagnosisModalProps> = ({ result, lang, onClose, onSave }) => {
  const [activeTab, setActiveTab] = useState<'overview' | 'treatment' | 'prevention'>('overview');
  const t = TRANSLATIONS[lang];

  const severityColor = {
    Healthy: 'text-[var(--primary-600)] bg-[var(--primary-50)]',
    Mild: 'text-yellow-600 bg-yellow-50',
    Moderate: 'text-orange-600 bg-orange-50',
    Severe: 'text-red-600 bg-red-50'
  };

  const isRecognized = result.isPlant !== false;

  return (
    <div className="fixed inset-0 z-[200] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-md" onClick={onClose}></div>
      
      <div className="bg-white w-full max-w-2xl rounded-[2.5rem] shadow-2xl relative overflow-hidden flex flex-col max-h-[90vh]">
        <div className="relative h-48 bg-slate-100 flex-shrink-0">
          {result.imageUrl ? (
            <img src={result.imageUrl} alt="Scan Result" className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-slate-300">
              <Activity className="w-12 h-12" />
            </div>
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent"></div>
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 bg-white/20 backdrop-blur-lg text-white p-2 rounded-full hover:bg-white/40 z-20"
          >
            <X className="w-6 h-6" />
          </button>
          
          <div className="absolute bottom-6 left-8 right-8">
            {isRecognized ? (
              <>
                <span className={`px-4 py-1.5 rounded-full text-xs font-black uppercase tracking-widest ${severityColor[result.severity]}`}>
                  {TRANSLATIONS[lang][result.severity.toLowerCase()] || result.severity}
                </span>
                <h2 className="text-white text-3xl font-black mt-2 leading-tight">{result.plantName}</h2>
              </>
            ) : (
              <h2 className="text-white text-3xl font-black mt-2 leading-tight">Not Recognized</h2>
            )}
          </div>
        </div>

        {isRecognized ? (
          <>
            <div className="bg-white px-6 py-4 flex-shrink-0">
              <div className="bg-slate-50 p-1.5 rounded-2xl flex gap-1 overflow-x-auto whitespace-nowrap scrollbar-hide">
                {[
                  { id: 'overview', label: 'The Report', icon: Activity },
                  { id: 'treatment', label: t.treatment, icon: ShieldAlert },
                  { id: 'prevention', label: t.prevention, icon: BookOpen },
                ].map(tab => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id as any)}
                    className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 rounded-[1.2rem] text-sm font-black transition-all duration-300 ${
                      activeTab === tab.id 
                        ? 'bg-white text-[var(--primary-700)] shadow-md shadow-slate-200/50 translate-y-0' 
                        : 'text-slate-400 hover:text-slate-600 hover:bg-white/50'
                    }`}
                  >
                    <tab.icon className={`w-4 h-4 ${activeTab === tab.id ? 'text-[var(--primary-500)]' : 'text-slate-400'}`} />
                    {tab.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="flex-1 overflow-y-auto p-8 pt-4 space-y-8">
              {activeTab === 'overview' && (
                <div className="space-y-8 animate-in fade-in slide-in-from-bottom-2 duration-300">
                  <section>
                    <h4 className="text-slate-400 text-[10px] font-black uppercase tracking-widest mb-3">{t.diagnosis}</h4>
                    <p className="text-xl font-bold text-slate-800 leading-relaxed">{result.diagnosis}</p>
                    <div className="mt-4 flex items-center gap-4 text-xs text-slate-500 bg-slate-50 p-4 rounded-2xl border border-slate-100">
                      <span className="font-bold text-[var(--primary-600)]">{Math.round(result.confidence * 100)}% Certain</span>
                      {result.stressFactor && <span className="text-slate-300">|</span>}
                      {result.stressFactor && <span className="font-medium">Why: {result.stressFactor}</span>}
                    </div>
                  </section>

                  {result.environment && (
                    <section>
                      <h4 className="text-slate-400 text-[10px] font-black uppercase tracking-widest mb-4">Room Info</h4>
                      <div className="grid grid-cols-4 gap-4">
                        <div className="p-4 bg-orange-50 rounded-2xl text-center">
                          <Thermometer className="w-5 h-5 text-orange-500 mx-auto mb-2" />
                          <p className="text-[9px] font-black text-orange-400 uppercase tracking-tighter">Heat</p>
                          <p className="text-sm font-black text-orange-700">{result.environment.temperature}°C</p>
                        </div>
                        <div className="p-4 bg-blue-50 rounded-2xl text-center">
                          <Droplets className="w-5 h-5 text-blue-500 mx-auto mb-2" />
                          <p className="text-[9px] font-black text-blue-400 uppercase tracking-tighter">Hum</p>
                          <p className="text-sm font-black text-blue-700">{result.environment.humidity}%</p>
                        </div>
                        <div className="p-4 bg-[var(--primary-50)] rounded-2xl text-center">
                          <Droplets className="w-5 h-5 text-[var(--primary-500)] mx-auto mb-2" />
                          <p className="text-[9px] font-black text-[var(--primary-400)] uppercase tracking-tighter">Soil</p>
                          <p className="text-sm font-black text-[var(--primary-700)]">{result.environment.soilMoisture}%</p>
                        </div>
                        <div className="p-4 bg-yellow-50 rounded-2xl text-center">
                          <Sun className="w-5 h-5 text-yellow-500 mx-auto mb-2" />
                          <p className="text-[9px] font-black text-yellow-400 uppercase tracking-tighter">Sun</p>
                          <p className="text-sm font-black text-yellow-700">{result.environment.light}lx</p>
                        </div>
                      </div>
                    </section>
                  )}

                  <section>
                    <h4 className="text-slate-400 text-[10px] font-black uppercase tracking-widest mb-3">Expert Tips</h4>
                    <div className="grid gap-3">
                      {result.powerTips.map((tip, i) => (
                        <div key={i} className="flex gap-4 bg-[var(--primary-50)]/50 p-5 rounded-2xl border border-[var(--primary-100)]/50">
                          <Sparkles className="w-5 h-5 text-[var(--primary-500)] flex-shrink-0" />
                          <p className="text-slate-700 text-sm font-medium leading-relaxed">{tip}</p>
                        </div>
                      ))}
                    </div>
                  </section>
                </div>
              )}

              {activeTab === 'treatment' && (
                <div className="space-y-8 animate-in fade-in slide-in-from-bottom-2 duration-300">
                  <div className="bg-[var(--primary-50)] p-8 rounded-[2.5rem] border border-[var(--primary-100)] transition-colors duration-500">
                    <h4 className="text-[var(--primary-800)] font-black mb-4 flex items-center gap-3">
                      <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-[var(--primary-600)] shadow-sm transition-colors duration-500">
                        <Check className="w-6 h-6" />
                      </div>
                      {t.organic} Ways
                    </h4>
                    <p className="text-slate-700 leading-relaxed font-medium">{result.organicTreatment}</p>
                  </div>

                  <div className="bg-red-50 p-8 rounded-[2.5rem] border border-red-100">
                    <h4 className="text-red-800 font-black mb-4 flex items-center gap-3">
                      <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-red-600 shadow-sm">
                        <ShieldAlert className="w-6 h-6" />
                      </div>
                      {t.chemical} Ways
                    </h4>
                    <p className="text-slate-700 leading-relaxed font-medium">{result.chemicalTreatment}</p>
                  </div>
                </div>
              )}

              {activeTab === 'prevention' && (
                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-2 duration-300">
                  <div className="p-8 bg-blue-50 border border-blue-100 rounded-[2.5rem]">
                    <h4 className="text-blue-800 font-black mb-4 flex items-center gap-3">
                       <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-blue-600 shadow-sm">
                        <BookOpen className="w-6 h-6" />
                      </div>
                      How to Protect
                    </h4>
                    <p className="text-slate-700 leading-relaxed font-medium">{result.prevention}</p>
                  </div>
                </div>
              )}
            </div>

            <div className="p-8 border-t border-slate-100 bg-white flex-shrink-0">
              <div className="flex flex-col md:flex-row gap-3">
                <button 
                  onClick={() => onSave(result, true)}
                  className="flex-1 bg-[var(--primary-600)] text-white px-8 py-5 rounded-3xl font-black text-lg shadow-xl shadow-[var(--primary-200)] hover:bg-[var(--primary-700)] active:scale-95 transition-all flex items-center justify-center gap-3 duration-500"
                >
                  <Activity className="w-6 h-6" />
                  {t.startMonitoring}
                </button>
                <button 
                  onClick={() => onSave(result, false)}
                  className="px-8 py-5 bg-slate-100 text-slate-700 rounded-3xl font-bold hover:bg-slate-200 transition-colors"
                >
                  {t.save}
                </button>
              </div>
            </div>
          </>
        ) : (
          <div className="flex-1 flex flex-col items-center justify-center p-12 text-center space-y-6">
            <div className="w-20 h-20 bg-red-50 text-red-500 rounded-full flex items-center justify-center">
              <AlertCircle className="w-12 h-12" />
            </div>
            <div className="space-y-2">
              <h3 className="text-2xl font-black text-slate-800">
                {lang === 'tl' ? 'Hindi Makilala' : 'Image Not Recognized'}
              </h3>
              <p className="text-slate-500 font-medium">
                {lang === 'tl' 
                  ? 'Paumanhin, hindi namin makita ang anumang halaman sa larawan. Siguraduhing malinaw ang pagkakakuha.' 
                  : 'We couldn\'t detect any recognizable plant features in this image. Please try again with a clearer shot.'}
              </p>
            </div>
            <button 
              onClick={onClose}
              className="w-full py-5 bg-slate-900 text-white rounded-3xl font-black text-lg shadow-xl hover:bg-slate-800 active:scale-95 transition-all"
            >
              Exit
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default DiagnosisModal;
