
import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { 
  LayoutDashboard, 
  Scan, 
  History, 
  User, 
  Leaf, 
  TrendingUp, 
  Plus, 
  Settings as SettingsIcon,
  Bell,
  Languages,
  LogOut,
  ChevronRight,
  Info,
  Archive,
  X,
  AlertTriangle,
  Thermometer,
  Droplets,
  CheckCircle2,
  Trash2
} from 'lucide-react';
import Dashboard from './components/Dashboard';
import Scanner from './components/Scanner';
import Monitoring from './components/Monitoring';
import DiagnosisModal from './components/DiagnosisModal';
import Profile from './components/Profile';
import PlantCompatibility from './components/PlantCompatibility';
import Analytics from './components/Analytics';
import AuthModal from './components/AuthModal';
import Archived from './components/Archived';
import LoadingScreen from './components/LoadingScreen';
import { storageService } from './services/storageService';
import { requestNotificationPermission, onMessageListener } from './services/firebase';
import { DiagnosisResult, MonitoringSession, AppAlert, UserStats, Language, EnvironmentalData, Page } from './types';
import { TRANSLATIONS, THEME_CONFIGS } from './constants';

interface MonitoringContext {
  sessionId: string;
  day: number;
}

const App: React.FC = () => {
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');
  const [scans, setScans] = useState<DiagnosisResult[]>([]);
  const [sessions, setSessions] = useState<MonitoringSession[]>([]);
  const [alerts, setAlerts] = useState<AppAlert[]>([]);
  const [userStats, setUserStats] = useState<UserStats>(storageService.getUserStats());
  const [language, setLanguage] = useState<Language>('en');
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(() => {
    // Check if Firebase user is authenticated
    return false; // Will be updated by auth state listener
  });
  const [activeDiagnosis, setActiveDiagnosis] = useState<DiagnosisResult | null>(null);
  const [monitoringCtx, setMonitoringCtx] = useState<MonitoringContext | null>(null);
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  
  const [envData, setEnvData] = useState<EnvironmentalData>({
    temperature: 28.4,
    humidity: 62,
    soilMoisture: 45,
    light: 840
  });

  // Apply Theme CSS Variables
  useEffect(() => {
    const themeKey = userStats.themeColor || 'green';
    const config = THEME_CONFIGS[themeKey] || THEME_CONFIGS.green;
    const root = document.documentElement;
    
    Object.entries(config).forEach(([key, value]) => {
      root.style.setProperty(`--primary-${key}`, value);
    });
  }, [userStats.themeColor]);

  // Capitalize name helper
  const formatName = (name: string) => {
    if (!name) return '';
    return name.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()).join(' ');
  };

  // Initialize app and check Firebase auth state
  useEffect(() => {
    const initializeApp = async () => {
      // Initialize Firebase Analytics
      if (typeof window !== 'undefined') {
        const { getAnalytics } = await import('firebase/analytics');
        const analytics = getAnalytics();
        console.log('Firebase Analytics initialized');
      }
      
      // Request notification permission
      requestNotificationPermission().then(result => {
        if (result) {
          console.log('FCM Token obtained:', result);
        }
      });
      
      // Set up push message listener
      onMessageListener().then(payload => {
        if (payload) {
          console.log('Push message received:', payload);
          // Show in-app notification for foreground messages
          addAlert(
            payload.notification?.title || 'SmartGrow AI Alert', 
            payload.notification?.body || 'You have a new notification', 
            'info'
          );
        }
      });
      
      // Simulate app initialization
      await new Promise(resolve => setTimeout(resolve, 1500));
      setIsLoading(false);
    };
    
    initializeApp();
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      setScans(storageService.getScans());
      setSessions(storageService.getMonitoring());
      setAlerts(storageService.getAlerts());
      setUserStats(storageService.getUserStats());
    }

    const envInterval = setInterval(() => {
      setEnvData(prev => {
        const nextTemp = +(prev.temperature + (Math.random() - 0.5) * 0.4).toFixed(1);
        const nextSoil = Math.max(0, Math.min(100, +(prev.soilMoisture + (Math.random() - 0.5) * 0.8).toFixed(0)));
        
        // Dynamic Alert Triggering
        if (nextTemp > 31 && prev.temperature <= 31) {
            addAlert('Heat Warning', `Temperature reached ${nextTemp}°C. Ensure your plants have shade.`, 'warning');
        } else if (nextTemp < 22 && prev.temperature >= 22) {
            addAlert('Cooling Alert', `It's getting chilly (${nextTemp}°C). Monitor tropical plants.`, 'info');
        }

        if (nextSoil < 30 && prev.soilMoisture >= 30) {
            addAlert('Thirsty Plants', `Soil moisture dropped to ${nextSoil}%. Consider watering.`, 'warning');
        }

        return {
          temperature: nextTemp,
          humidity: Math.max(0, Math.min(100, +(prev.humidity + (Math.random() - 0.5) * 1).toFixed(0))),
          soilMoisture: nextSoil,
          light: Math.max(0, +(prev.light + (Math.random() - 0.5) * 20).toFixed(0))
        };
      });
    }, 5000);

    return () => clearInterval(envInterval);
  }, [isAuthenticated]);

  const addAlert = (title: string, message: string, severity: 'info' | 'warning' | 'error') => {
    const newAlert: AppAlert = {
        id: Math.random().toString(36).substr(2, 9),
        title,
        message,
        severity,
        timestamp: Date.now()
    };
    setAlerts(prev => {
        const updated = [newAlert, ...prev].slice(0, 15); // Keep last 15 in storage
        storageService.saveAlerts(updated);
        return updated;
    });
  };

  const clearAlerts = () => {
    setAlerts([]);
    storageService.clearAlerts();
  };

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleUpdateStats = (newStats: UserStats) => {
    setUserStats(newStats);
    storageService.saveUserStats(newStats);
  };

  const handleAuthSuccess = () => {
    setIsAuthenticated(true);
    showToast('Login Successful!');
    addAlert('Welcome aboard!', `Hey User, we're ready to grow!`, 'info');
  };

  const handleLogout = async () => {
    try {
      // Add logout logic here if needed
      setIsAuthenticated(false);
      setCurrentPage('dashboard');
      showToast('Logged out successfully');
    } catch (error) {
      console.error('Logout error:', error);
      // Still logout locally even if Firebase fails
      setIsAuthenticated(false);
      setCurrentPage('dashboard');
    }
  };

  const handleSaveDiagnosis = (result: DiagnosisResult, startMonitoring: boolean) => {
    const XP_TARGET = userStats.level * 1000;
    
    if (monitoringCtx) {
      const updatedSessions = sessions.map(s => {
        if (s.id === monitoringCtx.sessionId) {
          const newDay = Math.min(7, monitoringCtx.day + 1);
          const newRecords = [...s.dailyRecords];
          newRecords.push({
            day: monitoringCtx.day,
            timestamp: Date.now(),
            status: result.severity === 'Healthy' ? 'Recovered' : 'Stable',
            notes: `Check day ${monitoringCtx.day}`,
            result
          });

          if (result.severity === 'Healthy') {
              addAlert('Recovery Success!', `Great news! ${result.plantName} has fully recovered.`, 'info');
          } else if (result.severity === 'Mild') {
              addAlert('Getting Better', `Keep it up! ${result.plantName} is showing signs of recovery.`, 'info');
          }

          return {
            ...s,
            currentDay: newDay,
            dailyRecords: newRecords,
            status: result.severity === 'Healthy' ? 'Recovered' as const : s.status
          };
        }
        return s;
      });
      setSessions(updatedSessions);
      const sessionToSave = updatedSessions.find(s => s.id === monitoringCtx.sessionId);
      if (sessionToSave) storageService.saveMonitoring(sessionToSave);
      
      setMonitoringCtx(null);
      showToast('Progress Logged! +150 XP');
      
      const newStats = { 
          ...userStats, 
          xp: userStats.xp + 150,
          lastAction: `Logged recovery for ${result.plantName}`
      };
      if (newStats.xp >= XP_TARGET) {
        newStats.level += 1;
        newStats.xp -= XP_TARGET; 
        showToast(`Rank Up! Level ${newStats.level}`);
      }
      handleUpdateStats(newStats);
    } else {
      storageService.saveScan(result);
      setScans(prev => [result, ...prev]);
      
      const newStats = { 
          ...userStats, 
          scansCount: userStats.scansCount + 1, 
          xp: userStats.xp + 80,
          lastAction: `Just scanned ${result.plantName}`
      };
      if (newStats.xp >= XP_TARGET) {
        newStats.level += 1;
        newStats.xp -= XP_TARGET;
        showToast(`Level Up! Level ${newStats.level}`);
      }
      handleUpdateStats(newStats);

      if (startMonitoring) {
        const newSession: MonitoringSession = {
          id: Math.random().toString(36).substr(2, 9),
          plantName: result.plantName,
          startDate: Date.now(),
          currentDay: 2,
          status: 'Active',
          dailyRecords: [{
            day: 1,
            timestamp: Date.now(),
            status: result.severity === 'Healthy' ? 'Recovered' : 'Stable',
            notes: 'Initial scan',
            result
          }]
        };
        storageService.saveMonitoring(newSession);
        setSessions(prev => [...prev, newSession]);
        showToast('Tracking active!');
      }
    }
    setActiveDiagnosis(null);
  };

  const handleArchiveScan = (id: string) => {
    storageService.toggleArchiveScan(id);
    setScans(storageService.getScans());
    showToast('Moved to Archive');
  };

  const handleDeleteScan = (id: string) => {
    const scan = scans.find(s => s.id === id);
    const scanName = scan?.plantName || 'this scan';
    
    if (confirm(`Delete "${scanName}" from history?`)) {
      storageService.deleteScan(id);
      setScans(storageService.getScans());
      showToast('Deleted from history');
    }
  };

  const handleDeleteSession = (id: string) => {
    const session = sessions.find(s => s.id === id);
    const sessionName = session?.plantName || `Session ${id.slice(0, 8)}`;
    
    if (confirm(`Delete "${sessionName}" monitoring session?`)) {
      storageService.deleteSession(id);
      setSessions(storageService.getMonitoring());
      showToast('Session deleted');
    }
  };

  const NotificationPanel = () => {
    const visibleAlerts = alerts.slice(0, 8);
    return (
      <div className="fixed inset-0 z-[1000] flex items-end md:items-center justify-center p-4">
          <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-md" onClick={() => setIsNotificationOpen(false)}></div>
          <div className="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl relative overflow-hidden flex flex-col max-h-[80vh] animate-in slide-in-from-bottom-5 duration-300">
              <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-white sticky top-0 z-10">
                  <div>
                      <h3 className="text-xl font-black text-slate-800">Notifications</h3>
                      <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Recent activity</p>
                  </div>
                  <button onClick={() => setIsNotificationOpen(false)} className="p-2.5 bg-slate-100 text-slate-500 rounded-xl hover:bg-slate-200">
                      <X className="w-5 h-5" />
                  </button>
              </div>
              <div className="flex-1 overflow-y-auto p-4 space-y-3 scrollbar-hide">
                  {visibleAlerts.length === 0 ? (
                      <div className="py-20 text-center space-y-4">
                          <div className="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mx-auto">
                              <Bell className="w-8 h-8 text-slate-200" />
                          </div>
                          <p className="text-slate-400 font-medium italic">No notifications yet.</p>
                      </div>
                  ) : (
                      visibleAlerts.map(alert => (
                          <div key={alert.id} className={`p-5 rounded-3xl border flex gap-4 ${
                              alert.severity === 'warning' ? 'bg-orange-50 border-orange-100' : 
                              alert.severity === 'error' ? 'bg-red-50 border-red-100' : 'bg-blue-50 border-blue-100'
                          }`}>
                              <div className={`w-10 h-10 rounded-2xl flex items-center justify-center flex-shrink-0 ${
                                  alert.severity === 'warning' ? 'bg-white text-orange-500 shadow-orange-200/50' : 
                                  alert.severity === 'error' ? 'bg-white text-red-500 shadow-red-200/50' : 'bg-white text-blue-500 shadow-blue-200/50'
                              } shadow-lg`}>
                                  {alert.title.toLowerCase().includes('heat') ? <Thermometer className="w-5 h-5" /> : 
                                   alert.title.toLowerCase().includes('water') ? <Droplets className="w-5 h-5" /> :
                                   alert.title.toLowerCase().includes('recovery') ? <CheckCircle2 className="w-5 h-5" /> : <Bell className="w-5 h-5" />}
                              </div>
                              <div className="flex-1 min-w-0">
                                  <div className="flex justify-between items-start mb-0.5">
                                      <h4 className="font-black text-slate-800 text-sm truncate pr-2">{alert.title}</h4>
                                      <span className="text-[8px] font-black text-slate-400 whitespace-nowrap uppercase">
                                          {new Date(alert.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                      </span>
                                  </div>
                                  <p className="text-xs text-slate-600 font-medium leading-relaxed">{alert.message}</p>
                              </div>
                          </div>
                      ))
                  )}
              </div>
          </div>
      </div>
    );
  };

  if (!isAuthenticated) {
    return (
      <AuthModal 
        lang={language} 
        onSuccess={handleAuthSuccess} 
      />
    );
  }

  const navItems = [
    { id: 'dashboard', icon: LayoutDashboard, label: TRANSLATIONS[language].dashboard },
    { id: 'monitoring', icon: Leaf, label: TRANSLATIONS[language].activeMonitoring },
    { id: 'history', icon: History, label: TRANSLATIONS[language].history },
    { id: 'profile', icon: SettingsIcon, label: TRANSLATIONS[language].settings },
  ];

  // Show loading screen initially
  if (isLoading) {
    return <LoadingScreen message="Authenticating with SmartGrow AI..." />;
  }

  return (
    <div className="flex flex-col min-h-screen bg-slate-50 text-slate-900 pb-32 md:pb-0 md:pl-64 safe-area-inset-top safe-area-inset-bottom pwa-full-height">
      <aside className="hidden md:flex flex-col fixed left-0 top-0 bottom-0 w-64 bg-[var(--primary-900)] text-white p-6 shadow-2xl z-50 transition-colors duration-500">
        <div className="flex items-center gap-3 mb-10">
          <div className="bg-[var(--primary-500)] p-2 rounded-xl">
            <Leaf className="w-6 h-6 text-white" />
          </div>
          <h1 className="text-xl font-black tracking-tight">SmartGrow AI</h1>
        </div>

        <nav className="flex-1 space-y-2">
          {navItems.map((item) => (
            <button
              key={item.id}
              onClick={() => setCurrentPage(item.id as Page)}
              className={`w-full flex items-center gap-4 px-4 py-3 rounded-xl transition-all ${
                currentPage === item.id 
                  ? 'bg-white/10 text-white font-bold' 
                  : 'text-slate-800 hover:text-white hover:bg-white/5'
              }`}
            >
              <item.icon className="w-5 h-5" />
              <span>{item.label}</span>
            </button>
          ))}
        </nav>

        <div className="mt-auto pt-6 border-t border-[var(--primary-800)]">
          <button 
            onClick={() => {
                const newLang = language === 'en' ? 'tl' : 'en';
                setLanguage(newLang);
                handleUpdateStats({...userStats, lastAction: `Changed language to ${newLang === 'en' ? 'English' : 'Tagalog'}`});
            }}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-white/10 text-[var(--primary-100)] transition-all text-sm font-bold"
          >
            <Languages className="w-4 h-4" />
            <span>{TRANSLATIONS[language].languageToggle}</span>
          </button>
        </div>
      </aside>

      <main className="flex-1 max-w-6xl mx-auto w-full p-4 md:p-12 relative">
        {currentPage === 'dashboard' && (
          <Dashboard 
            scans={scans}
            sessions={sessions}
            lang={language}
            userStats={userStats}
            envData={envData}
            onScanNow={() => setCurrentPage('scanner')}
            onOpenPlantGuide={() => setCurrentPage('compatibility')}
            onOpenAnalytics={() => setCurrentPage('analytics')}
            onOpenProfile={() => setCurrentPage('profile')}
          />
        )}
        {currentPage === 'scanner' && (
          <Scanner 
            lang={language}
            onResult={(res) => { 
              // Add alert for new plant analysis
              if (res.severity === 'Severe') {
                addAlert('🚨 SmartGrow AI Alert!', `${res.plantName} needs immediate attention! ${res.diagnosis}`, 'error');
              } else if (res.severity === 'Moderate') {
                addAlert('⚠️ SmartGrow AI Warning', `${res.plantName} shows moderate symptoms: ${res.diagnosis}`, 'warning');
              } else if (res.severity === 'Mild') {
                addAlert('🌱 SmartGrow AI Check', `${res.plantName} has mild symptoms: ${res.diagnosis}`, 'info');
              } else if (res.severity === 'Healthy') {
                addAlert('✅ SmartGrow AI Healthy!', `${res.plantName} is in great condition!`, 'info');
              }
              
              setActiveDiagnosis({ ...res, environment: { ...envData } } as DiagnosisResult); 
              setCurrentPage('dashboard'); 
            }}
            onBack={() => setCurrentPage('dashboard')}
          />
        )}
        {currentPage === 'monitoring' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center mb-2">
                 <div>
                    <h2 className="text-3xl font-black text-slate-800">{TRANSLATIONS[language].monitoringTitle}</h2>
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1">Recovery Tracking</p>
                 </div>
                 <button onClick={() => setIsNotificationOpen(true)} className="p-3 bg-white rounded-2xl shadow-sm border border-slate-100 relative hover:shadow-md transition-all active:scale-95">
                    <Bell className="w-6 h-6 text-slate-600" />
                    {alerts.length > 0 && <div className="absolute top-2 right-2 w-3 h-3 bg-red-500 border-2 border-white rounded-full"></div>}
                 </button>
            </div>
            <Monitoring 
                sessions={sessions}
                lang={language}
                onScanForDay={(sessionId, day) => { setMonitoringCtx({ sessionId, day }); setCurrentPage('scanner'); }}
                onArchiveSession={(id) => {
                const updated = sessions.map(s => s.id === id ? { ...s, status: 'Archived' as const } : s);
                setSessions(updated);
                const session = updated.find(s => id === id);
                if (session) storageService.saveMonitoring(session);
                handleUpdateStats({...userStats, lastAction: `Archived session for ${session?.plantName}`});
                showToast('Archived');
                }}
            />
          </div>
        )}
        {currentPage === 'history' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h2 className="text-3xl font-black text-slate-800">History</h2>
                    <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1">Previous Diagnosis</p>
                </div>
                <button onClick={() => setIsNotificationOpen(true)} className="p-3 bg-white rounded-2xl shadow-sm border border-slate-100 relative hover:shadow-md transition-all active:scale-95">
                    <Bell className="w-6 h-6 text-slate-600" />
                    {alerts.length > 0 && <div className="absolute top-2 right-2 w-3 h-3 bg-red-500 border-2 border-white rounded-full"></div>}
                 </button>
            </div>
            <div className="space-y-4 max-h-96 overflow-y-auto">
              {scans.filter(s => !s.archived).map(scan => (
                <div 
                  key={scan.id} 
                  className="bg-white p-6 rounded-[2.5rem] border border-slate-100 flex items-center gap-6 hover:border-[var(--primary-200)] transition-all shadow-sm hover:shadow-md group"
                >
                  <button 
                    onClick={() => setActiveDiagnosis(scan)}
                    className="flex-1 flex items-center gap-6 text-left"
                  >
                    <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${scan.severity === 'Healthy' ? 'bg-[var(--primary-50)] text-[var(--primary-600)]' : 'bg-red-50 text-red-600'}`}>
                      <Leaf className="w-8 h-8" />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-bold text-slate-800 text-lg">{scan.plantName}</h4>
                      <p className="text-sm text-slate-400">{scan.diagnosis}</p>
                    </div>
                  </button>
                  <button 
                    onClick={() => handleArchiveScan(scan.id)}
                    className="p-3 text-slate-300 hover:text-blue-500 hover:bg-blue-50 rounded-xl transition-all"
                    title="Archive"
                  >
                    <Archive className="w-5 h-5" />
                  </button>
                  <ChevronRight className="w-6 h-6 text-slate-200" />
                </div>
              ))}
              {scans.filter(s => !s.archived).length === 0 && (
                  <div className="text-center py-20 bg-white rounded-[3rem] border border-dashed border-slate-200">
                      <p className="text-slate-400 font-medium">No botanical history recorded yet.</p>
                  </div>
              )}
            </div>
          </div>
        )}
        {currentPage === 'profile' && (
          <Profile 
            lang={language}
            stats={userStats}
            alerts={alerts}
            onLanguageToggle={() => {
                const newLang = language === 'en' ? 'tl' : 'en';
                setLanguage(newLang);
                handleUpdateStats({...userStats, lastAction: `Changed language to ${newLang === 'en' ? 'English' : 'Tagalog'}`});
            }}
            onLogout={handleLogout}
            onUpdateStats={handleUpdateStats}
            onOpenArchive={() => setCurrentPage('archived')}
            onOpenNotifications={() => setIsNotificationOpen(true)}
          />
        )}
        {currentPage === 'archived' && (
          <Archived 
            lang={language}
            scans={scans}
            sessions={sessions}
            onRestoreScan={handleArchiveScan}
            onDeleteScan={handleDeleteScan}
            onDeleteSession={handleDeleteSession}
            onBack={() => setCurrentPage('profile')}
          />
        )}
        {currentPage === 'compatibility' && <PlantCompatibility lang={language} onBack={() => {
             setCurrentPage('dashboard');
             handleUpdateStats({...userStats, lastAction: 'Explored plant guide'});
        }} />}
        {currentPage === 'analytics' && <Analytics scans={scans} sessions={sessions} onBack={() => {
            setCurrentPage('dashboard');
            handleUpdateStats({...userStats, lastAction: 'Reviewed analytics'});
        }} />}
      </main>

      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200 px-2 pt-4 pb-6 flex justify-around items-center z-[60] h-20 safe-area-inset-bottom">
        <button onClick={() => setCurrentPage('dashboard')} className={`flex flex-col items-center gap-1 flex-1 ${currentPage === 'dashboard' ? 'text-[var(--primary-600)]' : 'text-slate-800'}`}>
          <LayoutDashboard className="w-5 h-5" />
          <span className="text-[9px] uppercase font-black">Home</span>
        </button>
        <button onClick={() => setCurrentPage('monitoring')} className={`flex flex-col items-center gap-1 flex-1 ${currentPage === 'monitoring' ? 'text-[var(--primary-600)]' : 'text-slate-800'}`}>
          <Leaf className="w-5 h-5" />
          <span className="text-[9px] uppercase font-black">Track</span>
        </button>
        <div className="w-14 relative flex justify-center flex-1">
          <button onClick={() => setCurrentPage('scanner')} className="absolute -top-12 bg-[var(--primary-600)] text-white p-3 rounded-full shadow-2xl border-2 border-[var(--primary-900)] z-[70] transition-colors duration-500">
            <Scan className="w-5 h-5" />
          </button>
        </div>
        <button onClick={() => setCurrentPage('history')} className={`flex flex-col items-center gap-1 flex-1 ${currentPage === 'history' ? 'text-[var(--primary-600)]' : 'text-slate-800'}`}>
          <History className="w-5 h-5" />
          <span className="text-[9px] uppercase font-black">History</span>
        </button>
        <button onClick={() => setCurrentPage('profile')} className={`flex flex-col items-center gap-1 flex-1 ${currentPage === 'profile' ? 'text-[var(--primary-600)]' : 'text-slate-800'}`}>
          <SettingsIcon className="w-5 h-5" />
          <span className="text-[9px] uppercase font-black">Settings</span>
        </button>
      </nav>

      {activeDiagnosis && (
        <DiagnosisModal 
          result={activeDiagnosis}
          lang={language}
          onClose={() => setActiveDiagnosis(null)}
          onSave={(res, monitor) => handleSaveDiagnosis(res, monitor)}
        />
      )}

      {isNotificationOpen && <NotificationPanel />}

      {toast && (
        <div className="fixed bottom-24 left-1/2 -translate-x-1/2 px-8 py-4 rounded-3xl shadow-2xl text-white z-[999] bg-slate-900 font-bold animate-in slide-in-from-bottom-5">
          {toast.message}
        </div>
      )}
    </div>
  );
};

export default App;
