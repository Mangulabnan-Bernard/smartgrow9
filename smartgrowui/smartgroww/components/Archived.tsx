
import React, { useState } from 'react';
import { ChevronLeft, Trash2, RefreshCw, Leaf, Clock, Archive, AlertCircle, X } from 'lucide-react';
import { DiagnosisResult, MonitoringSession, Language } from '../types';
import { TRANSLATIONS } from '../constants';

interface ArchivedProps {
  lang: Language;
  scans: DiagnosisResult[];
  sessions: MonitoringSession[];
  onRestoreScan: (id: string) => void;
  onDeleteScan: (id: string) => void;
  onDeleteSession: (id: string) => void;
  onBack: () => void;
}

const Archived: React.FC<ArchivedProps> = ({ lang, scans, sessions, onRestoreScan, onDeleteScan, onDeleteSession, onBack }) => {
  const t = TRANSLATIONS[lang];
  const archivedScans = scans.filter(s => s.archived);
  const archivedSessions = sessions.filter(s => s.status === 'Archived');
  
  const [confirmTarget, setConfirmTarget] = useState<{ id: string; type: 'scan' | 'session'; name: string } | null>(null);

  const handleDeleteTrigger = (id: string, type: 'scan' | 'session', name: string) => {
    setConfirmTarget({ id, type, name });
  };

  const handleConfirmDelete = () => {
    if (!confirmTarget) return;
    if (confirmTarget.type === 'scan') {
      onDeleteScan(confirmTarget.id);
    } else {
      onDeleteSession(confirmTarget.id);
    }
    setConfirmTarget(null);
  };

  return (
    <div className="space-y-8 animate-in slide-in-from-right duration-300 pb-20">
      <div className="flex items-center gap-4 mb-4">
        <button onClick={onBack} className="p-3 bg-white rounded-2xl shadow-sm border border-slate-100 hover:bg-slate-50 transition-colors">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <div>
          <h2 className="text-2xl font-black text-slate-800 tracking-tight">{t.archived}</h2>
          <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">{t.manageArchive}</p>
        </div>
      </div>

      {/* Sessions Section */}
      <section className="space-y-4">
        <h3 className="px-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Archived Tracks</h3>
        <div className="grid gap-4">
          {archivedSessions.map(session => (
            <div key={session.id} className="bg-white p-6 rounded-[2rem] border border-slate-100 flex items-center gap-4 shadow-sm group">
              <div className="w-12 h-12 bg-slate-50 text-slate-400 rounded-xl flex items-center justify-center">
                <Clock className="w-6 h-6" />
              </div>
              <div className="flex-1">
                <h4 className="font-bold text-slate-800">{session.plantName}</h4>
                <p className="text-[10px] text-slate-400 font-medium">Stopped on {new Date(session.startDate).toLocaleDateString()}</p>
              </div>
              <button 
                onClick={() => handleDeleteTrigger(session.id, 'session', session.plantName)}
                className="p-3 text-red-200 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all"
                title={t.deletePermanently}
              >
                <Trash2 className="w-5 h-5" />
              </button>
            </div>
          ))}
          {archivedSessions.length === 0 && (
             <p className="text-center py-6 text-slate-300 text-xs italic">No archived tracks.</p>
          )}
        </div>
      </section>

      {/* Scans Section */}
      <section className="space-y-4">
        <h3 className="px-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Archived History</h3>
        <div className="grid gap-4">
          {archivedScans.map(scan => (
            <div key={scan.id} className="bg-white p-6 rounded-[2rem] border border-slate-100 flex items-center gap-4 shadow-sm group">
              <div className="w-12 h-12 bg-slate-50 text-slate-400 rounded-xl flex items-center justify-center overflow-hidden">
                {scan.imageUrl ? (
                    <img src={scan.imageUrl} className="w-full h-full object-cover opacity-50" />
                ) : (
                    <Leaf className="w-6 h-6" />
                )}
              </div>
              <div className="flex-1">
                <h4 className="font-bold text-slate-800">{scan.plantName}</h4>
                <p className="text-[10px] text-slate-400 font-medium">{scan.diagnosis}</p>
              </div>
              <div className="flex gap-2">
                <button 
                    onClick={() => onRestoreScan(scan.id)}
                    className="p-3 text-blue-300 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all"
                    title={t.restore}
                >
                    <RefreshCw className="w-5 h-5" />
                </button>
                <button 
                    onClick={() => handleDeleteTrigger(scan.id, 'scan', scan.plantName)}
                    className="p-3 text-red-300 hover:text-red-600 hover:bg-red-50 rounded-xl transition-all"
                    title={t.deletePermanently}
                >
                    <Trash2 className="w-5 h-5" />
                </button>
              </div>
            </div>
          ))}
          {archivedScans.length === 0 && (
             <p className="text-center py-6 text-slate-300 text-xs italic">{t.emptyArchive}</p>
          )}
        </div>
      </section>

      {/* Confirmation Modal */}
      {confirmTarget && (
        <div className="fixed inset-0 z-[600] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-md" onClick={() => setConfirmTarget(null)}></div>
          <div className="bg-white w-full max-w-sm rounded-[2.5rem] shadow-2xl relative overflow-hidden p-8 text-center animate-in zoom-in-95 duration-200">
            <div className="w-16 h-16 bg-orange-50 text-orange-500 rounded-full flex items-center justify-center mx-auto mb-6">
              <AlertCircle className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-black text-slate-800 mb-2">Delete {confirmTarget.name}?</h3>
            <p className="text-sm text-slate-500 font-medium mb-8">
              This will permanently delete the selected item. This action cannot be undone.
            </p>
            <div className="flex flex-col gap-3">
              <button 
                onClick={handleConfirmDelete}
                className="w-full py-4 bg-red-600 text-white font-black rounded-2xl shadow-lg shadow-red-100 hover:bg-red-700 active:scale-95 transition-all"
              >
                Yes, Delete
              </button>
              <button 
                onClick={() => setConfirmTarget(null)}
                className="w-full py-4 bg-slate-100 text-slate-600 font-bold rounded-2xl hover:bg-slate-200 transition-all"
              >
                No, Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Archived;
