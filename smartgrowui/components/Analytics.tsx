
import React from 'react';
import { 
  ChevronLeft, 
  BarChart3, 
  PieChart as PieIcon, 
  Activity, 
  Calendar,
  TrendingUp,
  AlertCircle
} from 'lucide-react';
import { 
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, 
  LineChart, Line, PieChart, Pie, Cell, CartesianGrid, AreaChart, Area
} from 'recharts';
import { DiagnosisResult, MonitoringSession } from '../types';

interface AnalyticsProps {
  scans: DiagnosisResult[];
  sessions: MonitoringSession[];
  onBack: () => void;
}

const Analytics: React.FC<AnalyticsProps> = ({ scans, sessions, onBack }) => {
  const severityData = [
    { name: 'Healthy', value: scans.filter(s => s.severity === 'Healthy').length },
    { name: 'Mild', value: scans.filter(s => s.severity === 'Mild').length },
    { name: 'Moderate', value: scans.filter(s => s.severity === 'Moderate').length },
    { name: 'Severe', value: scans.filter(s => s.severity === 'Severe').length },
  ].filter(d => d.value > 0);

  const scanTrendData = Array.from({ length: 7 }).map((_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    const label = d.toLocaleDateString(undefined, { weekday: 'short' });
    const count = scans.filter(s => new Date(s.timestamp).toLocaleDateString() === d.toLocaleDateString()).length;
    return { name: label, scans: count };
  });

  // Use CSS Variables for primary colors so they update with the theme
  const COLORS = ['var(--primary-500)', '#eab308', '#f97316', '#ef4444'];

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4 mb-4">
        <button onClick={onBack} className="p-3 bg-white rounded-2xl shadow-sm border border-slate-100 hover:bg-slate-50 transition-colors">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <div>
            <h2 className="text-2xl font-black text-slate-800 tracking-tight">Analytics</h2>
            <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Performance Insights</p>
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        {/* Severity Distribution */}
        <div className="bg-white p-7 rounded-[2.5rem] shadow-sm border border-slate-100">
          <h3 className="font-black text-slate-800 mb-6 flex items-center gap-3">
            <PieIcon className="w-5 h-5 text-[var(--primary-500)] transition-colors duration-500" />
            Health Distribution
          </h3>
          <div className="h-64" style={{ height: '256px' }}>
            {severityData.length > 0 ? (
              <ResponsiveContainer width="100%" height={256}>
                <PieChart>
                  <Pie
                    data={severityData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                    animationDuration={1500}
                  >
                    {severityData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} strokeWidth={0} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 25px -5px rgba(0,0,0,0.1)' }} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-slate-300 italic text-sm">No data recorded.</div>
            )}
          </div>
          <div className="flex flex-wrap justify-center gap-4 mt-4">
            {severityData.map((d, i) => (
              <div key={i} className="flex items-center gap-2 bg-slate-50 px-3 py-1 rounded-full border border-slate-100">
                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: COLORS[i] }}></div>
                <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">{d.name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Scan Frequency */}
        <div className="bg-white p-7 rounded-[2.5rem] shadow-sm border border-slate-100">
          <h3 className="font-black text-slate-800 mb-6 flex items-center gap-3">
            <TrendingUp className="w-5 h-5 text-[var(--primary-500)] transition-colors duration-500" />
            7-Day Activity Trend
          </h3>
          <div className="h-64" style={{ height: '256px' }}>
            <ResponsiveContainer width="100%" height={256}>
              <AreaChart data={scanTrendData}>
                <defs>
                  <linearGradient id="colorScans" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--primary-500)" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="var(--primary-500)" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#94a3b8', fontWeight: 700 }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 10, fill: '#94a3b8', fontWeight: 700 }} />
                <Tooltip contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 25px -5px rgba(0,0,0,0.1)' }} />
                <Area type="monotone" dataKey="scans" stroke="var(--primary-500)" fillOpacity={1} fill="url(#colorScans)" strokeWidth={4} animationDuration={1500} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-7 rounded-[2rem] border border-slate-100 shadow-sm flex items-center gap-5">
          <div className="w-14 h-14 bg-[var(--primary-50)] text-[var(--primary-600)] rounded-2xl flex items-center justify-center transition-colors duration-500 shadow-inner">
            <Calendar className="w-7 h-7" />
          </div>
          <div>
            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Lifetime History</p>
            <p className="text-xl font-black text-slate-800">{scans.length} Scans</p>
          </div>
        </div>
        
        <div className="bg-white p-7 rounded-[2rem] border border-slate-100 shadow-sm flex items-center gap-5">
          <div className="w-14 h-14 bg-[var(--primary-50)] text-[var(--primary-600)] rounded-2xl flex items-center justify-center transition-colors duration-500 shadow-inner">
            <Activity className="w-7 h-7" />
          </div>
          <div>
            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Success Rate</p>
            <p className="text-xl font-black text-slate-800">
              {scans.length > 0 ? Math.round((scans.filter(s => s.severity === 'Healthy').length / scans.length) * 100) : 0}%
            </p>
          </div>
        </div>

        <div className="bg-white p-7 rounded-[2rem] border border-slate-100 shadow-sm flex items-center gap-5">
          <div className="w-14 h-14 bg-red-50 text-red-600 rounded-2xl flex items-center justify-center shadow-inner">
            <AlertCircle className="w-7 h-7" />
          </div>
          <div>
            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Critical Cases</p>
            <p className="text-xl font-black text-slate-800">
              {scans.filter(s => s.severity === 'Severe').length}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
