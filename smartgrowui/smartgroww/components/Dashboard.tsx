
import React, { useState, useEffect, useMemo } from 'react';
import { 
  Plus, 
  Thermometer, 
  Droplets, 
  Sun, 
  Wind, 
  ArrowRight,
  ChevronRight,
  Sparkles,
  Zap,
  Target,
  Leaf,
  TrendingUp,
  Activity,
  Trophy,
  CheckCircle2,
  User,
  UserRound,
  CircleUser,
  Smile,
  UserCheck,
  UserPlus,
  Users,
  UserCog,
  Contact,
  UserSearch,
  History as HistoryIcon,
  MessageSquare,
  Clock
} from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { DiagnosisResult, MonitoringSession, UserStats, Language, EnvironmentalData } from '../types';
import { TRANSLATIONS, FARMER_TIPS } from '../constants';

const PERSONAS: Record<string, { icon: any, color: string, label: string }> = {
  Persona1: { icon: User, color: 'bg-emerald-500', label: 'The Botanist' },
  Persona2: { icon: UserCheck, color: 'bg-blue-500', label: 'The Plant Doc' },
  Persona3: { icon: Smile, color: 'bg-yellow-500', label: 'Happy Harvester' },
  Persona4: { icon: UserPlus, color: 'bg-orange-500', label: 'Seed Sower' },
  Persona5: { icon: Contact, color: 'bg-purple-500', label: 'Garden Guide' },
  Persona6: { icon: CircleUser, color: 'bg-pink-500', label: 'Flora Fanatic' },
  Persona7: { icon: UserCog, color: 'bg-slate-500', label: 'Soil Scientist' },
  Persona8: { icon: UserRound, color: 'bg-indigo-500', label: 'Nature Ninja' },
  Persona9: { icon: Users, color: 'bg-teal-500', label: 'Bloom Buddy' },
  Persona10: { icon: UserSearch, color: 'bg-red-500', label: 'Leaf Legend' },
};

interface DashboardProps {
  scans: DiagnosisResult[];
  sessions: MonitoringSession[];
  lang: Language;
  userStats: UserStats;
  envData: EnvironmentalData;
  onScanNow: () => void;
  onOpenPlantGuide: () => void;
  onOpenAnalytics: () => void;
  onOpenProfile: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ 
  scans, 
  sessions, 
  lang, 
  userStats, 
  envData,
  onScanNow, 
  onOpenPlantGuide, 
  onOpenAnalytics,
  onOpenProfile
}) => {
  const [tipIndex, setTipIndex] = useState(0);
  const localizedTips = FARMER_TIPS[lang] || FARMER_TIPS.en;

  useEffect(() => {
    const tipInterval = setInterval(() => {
      setTipIndex(prev => (prev + 1) % localizedTips.length);
    }, 6000);
    return () => clearInterval(tipInterval);
  }, [localizedTips.length]);

  const healthScore = useMemo(() => {
    if (scans.length === 0) return 0;
    const healthyCount = scans.filter(s => s.severity === 'Healthy').length;
    return Math.round((healthyCount / scans.length) * 100);
  }, [scans]);

  const lastScan = useMemo(() => scans[0] || null, [scans]);
  
  const persona = PERSONAS[userStats.profileIcon] || PERSONAS.Persona1;
  const PersonaIcon = persona.icon;

  const chartData = useMemo(() => {
    const counts = { Healthy: 0, Mild: 0, Moderate: 0, Severe: 0 };
    scans.forEach(s => {
        if (s.severity in counts) {
            counts[s.severity as keyof typeof counts]++;
        }
    });
    return Object.entries(counts).map(([name, value]) => ({ name, value })).filter(v => v.value > 0);
  }, [scans]);

  // COLORS based on health severity
  const COLORS = ['#22c55e', '#f59e0b', '#f97316', '#ef4444'];

  // Utility to capitalize first letter of each word
  const formatName = (name: string) => {
    if (!name) return '';
    return name.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ');
  };

  const displayName = formatName(userStats.fullName || userStats.username);

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <header className="relative overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-[var(--primary-600)] via-[var(--primary-700)] to-[var(--primary-800)] text-white p-7 md:p-10 shadow-2xl shadow-[var(--primary-900)]/30 transition-colors duration-500">
        {/* Header Top Row: Name/Level (Left) and Profile (Right) */}
        <div className="flex justify-between items-start mb-10 relative z-10">
          <div className="space-y-2 min-w-0">
            <div className="flex items-center gap-2">
              <div className="bg-white/10 backdrop-blur-md px-3 py-1 rounded-lg text-[10px] font-black uppercase tracking-widest whitespace-nowrap border border-white/5">
                Level {userStats.level}
              </div>
              <span className="text-[var(--primary-100)]/60 text-[9px] font-black uppercase tracking-widest">{healthScore}% Health</span>
            </div>
            <h1 className="text-4xl md:text-6xl font-black leading-tight tracking-tight truncate">
              {displayName}
            </h1>
            <p className="text-[var(--primary-100)]/70 text-sm font-medium">{TRANSLATIONS[lang].welcome}</p>
          </div>

          <button 
            onClick={onOpenProfile}
            className={`w-14 h-14 md:w-20 md:h-20 rounded-[2rem] ${persona.color} border-4 border-white/20 flex items-center justify-center hover:scale-105 transition-all active:scale-95 shadow-2xl shrink-0 group overflow-hidden relative`}
          >
            <PersonaIcon className="w-8 h-8 md:w-10 md:h-10 text-white transition-transform group-hover:rotate-6" />
            <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
          </button>
        </div>

        {/* Info Grid below the main header row */}
        <div className="relative z-10 grid md:grid-cols-2 gap-4">
          <div className="bg-white/10 backdrop-blur-xl border border-white/10 rounded-[2rem] p-5 shadow-lg flex flex-col min-w-0 overflow-hidden">
            <div className="flex items-center justify-between mb-3 flex-shrink-0">
              <h4 className="text-[9px] font-black text-[var(--primary-200)] uppercase tracking-widest whitespace-nowrap">Latest Scan</h4>
              <div className="w-1.5 h-1.5 rounded-full bg-[var(--primary-400)] animate-pulse flex-shrink-0"></div>
            </div>
            
            {lastScan ? (
              <div className="flex items-center gap-4 min-w-0">
                <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center border border-white/20 flex-shrink-0">
                  <Leaf className="w-5 h-5 text-white" />
                </div>
                <div className="min-w-0 flex-1 overflow-hidden">
                  <p className="text-sm font-black text-white truncate w-full">{lastScan.plantName}</p>
                  <p className="text-[10px] font-medium text-[var(--primary-100)]/60 truncate uppercase tracking-tight w-full">
                    {lastScan.diagnosis}
                  </p>
                </div>
                <ChevronRight className="w-4 h-4 text-white/40 flex-shrink-0" />
              </div>
            ) : (
              <p className="text-[10px] text-white/40 italic whitespace-nowrap">No scans yet.</p>
            )}
          </div>

          <div className="bg-[var(--primary-500)]/20 backdrop-blur-md rounded-[2rem] p-5 border border-white/5 flex items-center justify-between group min-w-0 overflow-hidden">
            <div className="flex items-center gap-4 min-w-0 flex-1 overflow-hidden">
              <div className="w-10 h-10 rounded-xl bg-[var(--primary-400)]/20 flex items-center justify-center flex-shrink-0">
                <Clock className="w-5 h-5 text-[var(--primary-200)]" />
              </div>
              <div className="min-w-0 flex-1 overflow-hidden">
                  <p className="text-[8px] font-black text-[var(--primary-200)] uppercase tracking-widest opacity-60 whitespace-nowrap">Recent Activity</p>
                  <p className="text-sm font-bold text-white truncate w-full">{userStats.lastAction || 'Started fresh'}</p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Quick Tip Section */}
      <div className="bg-[var(--primary-600)] p-8 rounded-[2.5rem] shadow-xl shadow-[var(--primary-900)]/10 text-white relative overflow-hidden flex flex-col justify-center transition-colors duration-500">
        <Sparkles className="absolute -top-6 -right-6 w-20 h-20 text-white/10" />
        <h4 className="text-[var(--primary-200)] font-black mb-3 text-[9px] uppercase tracking-widest">Quick Tip</h4>
        <p className="text-white text-base md:text-lg font-bold leading-relaxed italic line-clamp-2 md:line-clamp-none">
          "{localizedTips[tipIndex]}"
        </p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6">
        {[
          { label: TRANSLATIONS[lang].statHealth, value: `${healthScore}%`, icon: Activity, color: 'text-[var(--primary-600)]', bg: 'bg-[var(--primary-50)]' },
          { label: TRANSLATIONS[lang].statTracking, value: sessions.filter(s => s.status === 'Active').length, icon: Leaf, color: 'text-[var(--primary-600)]', bg: 'bg-[var(--primary-50)]' },
          { label: TRANSLATIONS[lang].statChecks, value: userStats.scansCount, icon: HistoryIcon, color: 'text-blue-600', bg: 'bg-blue-50' },
          { label: TRANSLATIONS[lang].status, value: persona.label.split(' ').pop() || 'Rank', icon: Trophy, color: 'text-yellow-600', bg: 'bg-yellow-50' },
        ].map((stat, i) => (
          <div key={i} className="bg-white p-5 rounded-[2rem] shadow-sm border border-slate-100 flex flex-col gap-3 group hover:shadow-md transition-all min-w-0 overflow-hidden">
            <div className={`${stat.bg} ${stat.color} w-10 h-10 rounded-xl flex items-center justify-center group-hover:scale-110 transition-all flex-shrink-0`}>
              {React.createElement(stat.icon as any, { className: 'w-5 h-5' })}
            </div>
            <div className="min-w-0">
              <p className="text-slate-400 text-[9px] font-black uppercase tracking-widest mb-0.5 truncate">{stat.label}</p>
              <p className="text-lg font-black text-slate-800 truncate">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="grid md:grid-cols-1 gap-6">
          <section className="bg-white p-7 md:p-10 rounded-[2.5rem] shadow-sm border border-slate-100 flex flex-col overflow-hidden">
            <div className="flex justify-between items-center mb-8">
              <h2 className="text-lg font-black flex items-center gap-3 text-slate-800">
                <Wind className="w-5 h-5 text-[var(--primary-500)]" />
                {TRANSLATIONS[lang].environment}
              </h2>
              <span className="text-[9px] text-slate-400 font-black uppercase tracking-widest bg-slate-50 px-4 py-1.5 rounded-full border border-slate-100">Live Status</span>
            </div>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-10">
              {[
                { icon: Thermometer, label: TRANSLATIONS[lang].temp, val: `${envData.temperature}°C`, col: 'text-orange-500' },
                { icon: Droplets, label: TRANSLATIONS[lang].hum, val: `${envData.humidity}%`, col: 'text-blue-500' },
                { icon: Droplets, label: TRANSLATIONS[lang].soil, val: `${envData.soilMoisture}%`, col: 'text-[var(--primary-500)]' },
                { icon: Sun, label: TRANSLATIONS[lang].light, val: `${envData.light}lx`, col: 'text-yellow-500' },
              ].map((env, i) => (
                <div key={i} className="flex flex-col items-center gap-3 min-w-0">
                  <div className="w-14 h-14 md:w-20 md:h-20 rounded-[1.5rem] md:rounded-[2rem] bg-slate-50 flex items-center justify-center shadow-inner group hover:bg-white hover:shadow-xl transition-all border border-transparent hover:border-slate-100 flex-shrink-0">
                    <env.icon className={`w-7 h-7 md:w-10 md:h-10 ${env.col}`} />
                  </div>
                  <div className="text-center min-w-0 w-full">
                      <p className="text-[10px] font-black text-slate-300 uppercase tracking-widest truncate">{env.label}</p>
                      <p className="text-base md:text-xl font-black text-slate-700 truncate">{env.val}</p>
                  </div>
                </div>
              ))}
            </div>
          </section>
      </div>

      <div className="grid md:grid-cols-2 gap-6 pb-4">
        <div className="bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100 flex flex-col min-h-[280px] overflow-hidden">
          <h3 className="text-lg font-black text-slate-800 mb-6">{TRANSLATIONS[lang].analytics}</h3>
          <div className="w-full" style={{ height: '200px', width: '100%' }}>
            {chartData.length > 0 ? (
                <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                    <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    innerRadius={45}
                    outerRadius={65}
                    paddingAngle={8}
                    dataKey="value"
                    animationBegin={0}
                    animationDuration={1500}
                    >
                    {chartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} strokeWidth={0} />
                    ))}
                    </Pie>
                    <Tooltip contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 8px 16px -4px rgba(0,0,0,0.1)' }} />
                </PieChart>
                </ResponsiveContainer>
            ) : (
                <div className="h-full flex items-center justify-center text-slate-300 italic text-sm">No data yet.</div>
            )}
          </div>
          <button 
            onClick={onOpenAnalytics}
            className="mt-6 w-full py-4 rounded-xl bg-slate-50 text-slate-600 font-black text-[10px] uppercase tracking-widest flex items-center justify-center gap-2 hover:bg-slate-100 transition-all active:scale-95"
          >
            See More <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <button 
            onClick={onOpenPlantGuide}
            className="group bg-white p-8 rounded-[2.5rem] shadow-sm border border-slate-100 flex flex-col justify-between items-start text-left hover:border-[var(--primary-300)] transition-all relative overflow-hidden min-w-0"
        >
            <div className="absolute top-0 right-0 w-40 h-40 bg-[var(--primary-50)] rounded-full blur-[60px] -mr-20 -mt-20 group-hover:bg-[var(--primary-100)] transition-all"></div>
            <div className="w-12 h-12 bg-[var(--primary-100)] text-[var(--primary-600)] rounded-2xl flex items-center justify-center mb-6 group-hover:bg-[var(--primary-600)] group-hover:text-white transition-all shadow-lg shadow-[var(--primary-600)]/10 flex-shrink-0">
                <Leaf className="w-6 h-6" />
            </div>
            <div className="min-w-0 w-full">
                <h4 className="text-2xl font-black text-slate-800 mb-2 truncate">Plant Guide</h4>
                <p className="text-slate-400 font-medium text-sm leading-relaxed line-clamp-2">Learn about breeding and neighbors.</p>
            </div>
            <div className="mt-8 flex items-center gap-2 text-[var(--primary-600)] font-black text-[10px] uppercase tracking-widest whitespace-nowrap">
                Open Guide <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-1 transition-transform" />
            </div>
        </button>
      </div>
    </div>
  );
};

export default Dashboard;
