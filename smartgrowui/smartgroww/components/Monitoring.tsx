
import React from 'react';
import { Leaf, Clock, CheckCircle2, AlertTriangle, ChevronRight, Archive } from 'lucide-react';
import { MonitoringSession, Language } from '../types';
import { TRANSLATIONS } from '../constants';

interface MonitoringProps {
  sessions: MonitoringSession[];
  lang: Language;
  onScanForDay: (sessionId: string, day: number) => void;
  onArchiveSession: (id: string) => void;
}

const Monitoring: React.FC<MonitoringProps> = ({ sessions, lang, onScanForDay, onArchiveSession }) => {
  const activeSessions = sessions.filter(s => s.status === 'Active').sort((a, b) => b.startDate - a.startDate);
  const t = TRANSLATIONS[lang];

  const handleArchiveWithConfirm = (id: string, name: string) => {
      const confirmed = window.confirm(`Are you sure you want to stop tracking ${name}? This will archive the recovery session.`);
      if (confirmed) {
          onArchiveSession(id);
      }
  };

  return (
    <div className="space-y-4">
      {activeSessions.length === 0 ? (
        <div className="bg-white p-10 rounded-[2rem] shadow-sm border border-slate-100 text-center space-y-4">
          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto">
            <Leaf className="w-8 h-8 text-slate-200" />
          </div>
          <h3 className="text-lg font-bold text-slate-800">No active recovery plans</h3>
          <p className="text-slate-400 text-sm max-w-xs mx-auto font-medium">Start a scan and select "Start 7-Day Plan" to track progress here.</p>
        </div>
      ) : (
        activeSessions.map(session => (
          <div key={session.id} className="bg-white p-5 md:p-7 rounded-[2rem] shadow-sm border border-slate-100 transition-colors duration-500">
            <div className="flex justify-between items-start mb-6">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-[var(--primary-50)] text-[var(--primary-600)] rounded-2xl flex items-center justify-center shadow-inner transition-colors duration-500">
                  <Leaf className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-lg font-black text-slate-800 leading-tight">{session.plantName}</h3>
                  <p className="text-slate-400 text-[10px] font-bold uppercase tracking-wider">Started {new Date(session.startDate).toLocaleDateString()}</p>
                </div>
              </div>
              <button 
                onClick={() => handleArchiveWithConfirm(session.id, session.plantName)}
                className="p-2 text-slate-300 hover:text-red-500 transition-colors"
                title="Archive Session"
              >
                <Archive className="w-4 h-4" />
              </button>
            </div>

            {/* Progress Bar */}
            <div className="mb-6">
              <div className="flex justify-between text-[9px] font-black uppercase tracking-widest text-slate-400 mb-2">
                <span>Day {session.currentDay} of 7</span>
                <span>{Math.round((session.currentDay / 7) * 100)}% Complete</span>
              </div>
              <div className="h-2 bg-slate-100 rounded-full overflow-hidden flex">
                <div 
                  className="h-full bg-[var(--primary-500)] transition-all duration-1000 shadow-[0_0_15px_rgba(var(--primary-rgb),0.3)]" 
                  style={{ width: `${(session.currentDay / 7) * 100}%` }}
                ></div>
              </div>
            </div>

            {/* Day Selector */}
            <div className="grid grid-cols-7 gap-2 mb-6">
              {Array.from({ length: 7 }).map((_, i) => {
                const day = i + 1;
                const isLocked = day > session.currentDay;
                const isCurrent = day === session.currentDay;
                const isPast = day < session.currentDay;

                return (
                  <button
                    key={day}
                    disabled={isLocked}
                    onClick={() => isCurrent && onScanForDay(session.id, day)}
                    className={`h-11 md:h-14 rounded-xl flex flex-col items-center justify-center transition-all ${
                      isCurrent ? 'bg-[var(--primary-600)] text-white shadow-lg ring-2 ring-[var(--primary-100)] scale-105 z-10' :
                      isPast ? 'bg-[var(--primary-50)] text-[var(--primary-600)] border border-[var(--primary-100)]' :
                      'bg-slate-50 text-slate-300 border border-slate-100 opacity-50'
                    }`}
                  >
                    <span className="text-[8px] font-black uppercase">{day}</span>
                    {isPast ? <CheckCircle2 className="w-3.5 h-3.5 mt-0.5" /> : <Clock className="w-3.5 h-3.5 mt-0.5" />}
                  </button>
                );
              })}
            </div>

            {/* Current Day Action */}
            <div className="bg-slate-50 rounded-[1.5rem] p-4 border border-slate-100 flex flex-col md:flex-row items-center justify-between gap-3">
              <div className="flex items-center gap-3 text-center md:text-left">
                <div className="bg-white p-2.5 rounded-xl shadow-sm">
                  <AlertTriangle className="w-4 h-4 text-yellow-500" />
                </div>
                <div>
                  <h4 className="font-bold text-slate-800 text-sm">
                    {session.currentDay === 1 ? 'Initial Assessment' : `Day ${session.currentDay} Progress Scan`}
                  </h4>
                  <p className="text-[10px] text-slate-500 font-medium">Log your status and earn +100 XP</p>
                </div>
              </div>
              <button 
                onClick={() => onScanForDay(session.id, session.currentDay)}
                className="w-full md:w-auto px-6 py-2 bg-white border border-slate-200 rounded-xl font-black text-[10px] uppercase tracking-widest text-slate-700 shadow-sm hover:shadow-md transition-all active:scale-95 flex items-center justify-center gap-2"
              >
                Perform Scan <ChevronRight className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        ))
      )}
    </div>
  );
};

export default Monitoring;
