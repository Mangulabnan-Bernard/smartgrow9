
import React, { useState, useMemo } from 'react';
import { 
  User, 
  Settings as SettingsIcon, 
  LogOut, 
  Leaf, 
  Trophy, 
  ChevronRight,
  Globe,
  Award,
  BookOpen,
  Info,
  X,
  Zap,
  UserRound,
  CircleUser,
  UserCheck,
  UserPlus,
  Users,
  UserCog,
  Contact,
  UserSearch,
  CheckCircle2,
  HeartHandshake,
  Archive,
  Bell,
  Palette,
  Check
} from 'lucide-react';
import { UserStats, Language, AppAlert } from '../types';
import { TRANSLATIONS } from '../constants';

// Helper to handle missing icons
const Smile = ({ className }: { className?: string }) => <CircleUser className={className} />;

const PERSONAS = [
  { id: 'Persona1', icon: User, color: 'bg-emerald-500', label: 'The Botanist' },
  { id: 'Persona2', icon: UserCheck, color: 'bg-blue-500', label: 'The Plant Doc' },
  { id: 'Persona3', icon: Smile, color: 'bg-yellow-500', label: 'Happy Harvester' },
  { id: 'Persona4', icon: UserPlus, color: 'bg-orange-500', label: 'Seed Sower' },
  { id: 'Persona5', icon: Contact, color: 'bg-purple-500', label: 'Garden Guide' },
  { id: 'Persona6', icon: CircleUser, color: 'bg-pink-500', label: 'Flora Fanatic' },
  { id: 'Persona7', icon: UserCog, color: 'bg-slate-500', label: 'Soil Scientist' },
  { id: 'Persona8', icon: UserRound, color: 'bg-indigo-500', label: 'Nature Ninja' },
  { id: 'Persona9', icon: Users, color: 'bg-teal-500', label: 'Bloom Buddy' },
  { id: 'Persona10', icon: UserSearch, color: 'bg-red-500', label: 'Leaf Legend' },
];

const THEME_OPTIONS = [
  { id: 'green', color: '#16a34a', label: 'Botanical Green' },
  { id: 'blue', color: '#2563eb', label: 'Ocean Blue' },
  { id: 'purple', color: '#9333ea', label: 'Royal Purple' },
  { id: 'rose', color: '#e11d48', label: 'Velvet Rose' },
  { id: 'orange', color: '#ea580c', label: 'Sunset Orange' },
  { id: 'teal', color: '#0d9488', label: 'Midnight Teal' },
];

const PERSONA_MAP: Record<string, any> = {
  Persona1: PERSONAS[0],
  Persona2: PERSONAS[1],
  Persona3: PERSONAS[2],
  Persona4: PERSONAS[3],
  Persona5: PERSONAS[4],
  Persona6: PERSONAS[5],
  Persona7: PERSONAS[6],
  Persona8: PERSONAS[7],
  Persona9: PERSONAS[8],
  Persona10: PERSONAS[9],
};

interface ProfileProps {
  lang: Language;
  stats: UserStats;
  alerts: AppAlert[];
  onLanguageToggle: () => void;
  onLogout: () => void;
  onUpdateStats: (stats: UserStats) => void;
  onOpenArchive: () => void;
  onOpenNotifications: () => void;
}

const Profile: React.FC<ProfileProps> = ({ 
  lang, stats, alerts, onLanguageToggle, onLogout, onUpdateStats, onOpenArchive, onOpenNotifications 
}) => {
  const t = TRANSLATIONS[lang];
  const [modalType, setModalType] = useState<'none' | 'about' | 'avatars'>('none');

  const currentPersona = PERSONA_MAP[stats.profileIcon] || PERSONAS[0];
  const PersonaIcon = currentPersona.icon;

  const nextLevelXp = stats.level * 1000;
  const xpProgress = useMemo(() => Math.min(100, (stats.xp / nextLevelXp) * 100), [stats.xp, nextLevelXp]);

  const handleAvatarChange = (avatarId: string) => {
    const persona = PERSONA_MAP[avatarId];
    onUpdateStats({ 
        ...stats, 
        profileIcon: avatarId, 
        lastAction: `Became ${persona.label}` 
    });
    setModalType('none');
  };

  const handleThemeChange = (themeId: string) => {
    console.log('Theme change requested:', themeId);
    onUpdateStats({
      ...stats,
      themeColor: themeId,
      lastAction: `Changed theme to ${themeId}`
    });
    console.log('Theme change completed');
  };

  const formatName = (name: string) => {
    if (!name) return '';
    return name.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ');
  };

  const displayName = formatName(stats.fullName || stats.username);

  const AboutModal = () => (
    <div className="fixed inset-0 z-[500] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-md" onClick={() => setModalType('none')}></div>
      <div className="bg-white w-full max-w-lg rounded-[3rem] shadow-2xl relative overflow-hidden p-8">
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-[var(--primary-100)] text-[var(--primary-600)] rounded-2xl flex items-center justify-center">
                <HeartHandshake className="w-6 h-6" />
            </div>
            <div>
                <h3 className="text-xl font-black text-slate-800 tracking-tight">{t.about}</h3>
                <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-0.5">Version 2.5.0</p>
            </div>
          </div>
          <button onClick={() => setModalType('none')} className="p-2.5 bg-slate-100 hover:bg-slate-200 rounded-xl transition-all">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>
        <div className="prose prose-slate prose-sm max-w-none">
            <p className="text-slate-600 leading-relaxed font-medium">
                {t.aboutContent}
            </p>
            <div className="mt-8 pt-8 border-t border-slate-100">
                <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">Core Principles</p>
                <div className="grid grid-cols-2 gap-4">
                    <div className="p-4 bg-slate-50 rounded-2xl">
                        <p className="font-bold text-slate-800 text-xs mb-1">AI Powered</p>
                        <p className="text-[10px] text-slate-500 leading-tight">State-of-the-art</p>
                    </div>
                    <div className="p-4 bg-slate-50 rounded-2xl">
                        <p className="font-bold text-slate-800 text-xs mb-1">Sustainable</p>
                        <p className="text-[10px] text-slate-500 leading-tight">Focusing on organic and natural recovery.</p>
                    </div>
                </div>
            </div>
        </div>
      </div>
    </div>
  );

  const AvatarModal = () => (
    <div className="fixed inset-0 z-[500] flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-md" onClick={() => setModalType('none')}></div>
      <div className="bg-white w-full max-w-lg rounded-[3rem] shadow-2xl relative overflow-hidden p-8">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h3 className="text-xl font-black text-slate-800 tracking-tight">Identity</h3>
            <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-0.5">Select a Persona</p>
          </div>
          <button onClick={() => setModalType('none')} className="p-2.5 bg-slate-100 hover:bg-slate-200 rounded-xl transition-all">
            <X className="w-5 h-5 text-slate-500" />
          </button>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          {PERSONAS.map((p) => (
            <button 
              key={p.id}
              onClick={() => handleAvatarChange(p.id)}
              className={`group flex flex-col items-center gap-2 transition-all ${
                stats.profileIcon === p.id ? 'scale-105' : 'hover:scale-105 opacity-60 hover:opacity-100'
              }`}
            >
              <div className={`w-14 h-14 rounded-2xl ${p.color} flex items-center justify-center shadow-lg relative transition-all ${
                stats.profileIcon === p.id ? 'ring-4 ring-[var(--primary-100)]' : ''
              }`}>
                <p.icon className="w-7 h-7 text-white" />
                {stats.profileIcon === p.id && (
                    <div className="absolute bottom-1 right-1 bg-white rounded-full p-0.5 shadow-md">
                        <CheckCircle2 className="w-3 h-3 text-[var(--primary-600)]" />
                    </div>
                )}
              </div>
              <span className={`text-[9px] font-black uppercase tracking-tight text-center truncate w-full ${stats.profileIcon === p.id ? 'text-[var(--primary-600)]' : 'text-slate-400'}`}>
                {p.label.split(' ').pop()}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );

  return (
    <div className="max-w-2xl mx-auto space-y-8 animate-in fade-in duration-500 pb-10 pt-4">
      <div className="bg-white p-8 md:p-12 rounded-[2.5rem] shadow-sm border border-slate-100 relative overflow-hidden">
        <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-[var(--primary-50)]/50 to-transparent transition-colors duration-500"></div>
        <div className="relative z-10 flex items-center justify-between gap-6">
          {/* Left Side: Name and Level */}
          <div className="flex flex-col text-left space-y-3 flex-1">
            <div>
              <h2 className="text-3xl font-black text-slate-800 tracking-tight leading-none">{displayName}</h2>
              <div className="inline-flex items-center gap-2 bg-[var(--primary-50)] text-[var(--primary-700)] px-3 py-1 rounded-full text-[9px] font-black mt-3 uppercase tracking-widest border border-[var(--primary-100)] shadow-sm transition-colors duration-500">
                <Trophy className="w-3 h-3" />
                LEVEL {stats.level}
              </div>
            </div>

            <div className="w-full">
              <div className="flex justify-between items-center mb-1.5">
                 <div className="flex items-center gap-1.5">
                    <Zap className="w-3 h-3 text-[var(--primary-500)] fill-current transition-colors duration-500" />
                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Growth</span>
                 </div>
                 <span className="text-[9px] font-bold text-slate-600">{stats.xp} / {nextLevelXp} XP</span>
              </div>
              <div className="h-2 bg-slate-100 rounded-full overflow-hidden border border-slate-50 shadow-inner">
                <div 
                  className="h-full bg-gradient-to-r from-[var(--primary-400)] to-[var(--primary-600)] rounded-full transition-all duration-1000 shadow-sm" 
                  style={{ width: `${xpProgress}%` }}
                ></div>
              </div>
            </div>
          </div>

          {/* Right Side: Profile Icon */}
          <button 
            onClick={() => setModalType('avatars')}
            className={`w-20 h-20 md:w-28 md:h-28 ${currentPersona.color} rounded-[2.5rem] border-[4px] border-white shadow-xl flex items-center justify-center text-white transition-all hover:scale-105 group relative shrink-0`}
          >
            <PersonaIcon className="w-8 h-8 md:w-12 md:h-12" />
            <div className="absolute -bottom-0.5 -right-0.5 bg-[var(--primary-500)] text-white p-1.5 rounded-lg shadow-lg border-2 border-white transition-colors duration-500">
                <SettingsIcon className="w-3 h-3" />
            </div>
          </button>
        </div>
        
        <div className="grid grid-cols-2 gap-4 mt-10 w-full relative z-10">
          <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100 flex flex-col items-center">
            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Checks Done</p>
            <p className="text-lg font-black text-slate-800">{stats.scansCount}</p>
          </div>
          <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100 flex flex-col items-center">
            <p className="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1">Plants Cured</p>
            <p className="text-lg font-black text-slate-800">{stats.sessionsCount}</p>
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <h3 className="px-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Preferences</h3>
        
        <div className="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-5 md:p-6 border-b border-slate-50">
             <div className="flex items-center gap-4 mb-5">
                <div className="w-10 h-10 bg-[var(--primary-50)] text-[var(--primary-600)] rounded-xl flex items-center justify-center shadow-sm transition-colors duration-500">
                   <Palette className="w-5 h-5" />
                </div>
                <div>
                  <h4 className="font-bold text-slate-800 text-sm">{t.changeTheme}</h4>
                  <p className="text-[10px] text-slate-500 font-medium">Personalize your botanical dashboard</p>
                </div>
             </div>
             <div className="flex flex-wrap gap-3">
                {THEME_OPTIONS.map(theme => (
                  <button 
                    key={theme.id}
                    onClick={() => handleThemeChange(theme.id)}
                    className={`w-10 h-10 rounded-full flex items-center justify-center transition-all hover:scale-110 active:scale-90 border-2 ${
                      (stats.themeColor || 'green') === theme.id ? 'border-slate-800 ring-4 ring-slate-100 shadow-lg' : 'border-transparent'
                    }`}
                    style={{ backgroundColor: theme.color }}
                  >
                    {(stats.themeColor || 'green') === theme.id && <Check className="w-4 h-4 text-white" />}
                  </button>
                ))}
             </div>
          </div>

          <button 
            onClick={onOpenNotifications}
            className="w-full flex items-center justify-between p-5 md:p-6 hover:bg-slate-50 transition-colors border-b border-slate-50 group"
          >
            <div className="flex items-center gap-4 text-left">
              <div className="w-10 h-10 bg-orange-50 text-orange-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform shadow-sm relative">
                <Bell className="w-5 h-5" />
                {alerts.length > 0 && <div className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full border border-white"></div>}
              </div>
              <div>
                <h4 className="font-bold text-slate-800 text-sm">Notifications</h4>
                <p className="text-[10px] text-slate-500 font-medium">History: {alerts.length} messages</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-slate-300" />
          </button>

          <button 
            onClick={onLanguageToggle}
            className="w-full flex items-center justify-between p-5 md:p-6 hover:bg-slate-50 transition-colors border-b border-slate-50 group"
          >
            <div className="flex items-center gap-4 text-left">
              <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform shadow-sm">
                <Globe className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800 text-sm">Language</h4>
                <p className="text-[10px] text-slate-500 font-medium">{lang === 'en' ? 'English' : 'Tagalog'}</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-slate-300" />
          </button>

          <button 
            onClick={onOpenArchive}
            className="w-full flex items-center justify-between p-5 md:p-6 hover:bg-slate-50 transition-colors border-b border-slate-50 group"
          >
            <div className="flex items-center gap-4 text-left">
              <div className="w-10 h-10 bg-slate-900 text-white rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform shadow-sm">
                <Archive className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800 text-sm">{t.manageArchive}</h4>
                <p className="text-[10px] text-slate-500 font-medium">Clean history & tracks</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-slate-300" />
          </button>

          <button 
            onClick={() => setModalType('about')}
            className="w-full flex items-center justify-between p-5 md:p-6 hover:bg-slate-50 transition-colors group"
          >
            <div className="flex items-center gap-4 text-left">
              <div className="w-10 h-10 bg-slate-50 text-slate-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform shadow-sm">
                <Info className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-800 text-sm">{t.about}</h4>
                <p className="text-[10px] text-slate-500 font-medium">SmartGrow platform details</p>
              </div>
            </div>
            <ChevronRight className="w-5 h-5 text-slate-300" />
          </button>
        </div>

        <div className="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
          <button 
            onClick={onLogout}
            className="w-full flex items-center justify-between p-5 md:p-6 hover:bg-red-50 transition-colors group"
          >
            <div className="flex items-center gap-4 text-left">
              <div className="w-10 h-10 bg-red-50 text-red-600 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform shadow-sm">
                <LogOut className="w-5 h-5" />
              </div>
              <h4 className="font-bold text-red-600 text-sm">Sign Out</h4>
            </div>
            <ChevronRight className="w-5 h-5 text-red-200" />
          </button>
        </div>
      </div>

      {modalType === 'avatars' && <AvatarModal />}
      {modalType === 'about' && <AboutModal />}
    </div>
  );
};

export default Profile;
