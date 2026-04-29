
import { DiagnosisResult, MonitoringSession, AppAlert, UserStats } from '../types';
import { firebaseService } from './firebaseService';

// Get user-specific storage key
const getUserKey = (baseKey: string): string => {
  const user = firebaseService.getCurrentUser();
  if (user) {
    return `${baseKey}_${user.uid}`;
  }
  // Fallback to generic key for non-authenticated users
  return baseKey;
};

const STORAGE_KEYS = {
  SCANS: 'smartgrow_scans',
  MONITORING: 'smartgrow_monitoring',
  ALERTS: 'smartgrow_alerts',
  USER_STATS: 'smartgrow_user_stats'
};

export const storageService = {
  getScans: (): DiagnosisResult[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.SCANS));
    return data ? JSON.parse(data) : [];
  },
  saveScan: (scan: DiagnosisResult) => {
    const scans = storageService.getScans();
    const index = scans.findIndex(s => s.id === scan.id);
    if (index >= 0) {
      scans[index] = scan;
    } else {
      scans.unshift(scan);
    }
    localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
  },
  toggleArchiveScan: (id: string) => {
    const scans = storageService.getScans();
    const index = scans.findIndex(s => s.id === id);
    if (index >= 0) {
      scans[index].archived = !scans[index].archived;
      localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
    }
  },
  deleteScan: (id: string) => {
    const scans = storageService.getScans().filter(s => s.id !== id);
    localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
  },
  getMonitoring: (): MonitoringSession[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.MONITORING));
    return data ? JSON.parse(data) : [];
  },
  saveMonitoring: (session: MonitoringSession) => {
    const sessions = storageService.getMonitoring();
    const index = sessions.findIndex(s => s.id === session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.push(session);
    }
    localStorage.setItem(getUserKey(STORAGE_KEYS.MONITORING), JSON.stringify(sessions));
  },
  deleteSession: (id: string) => {
    const sessions = storageService.getMonitoring().filter(s => s.id !== id);
    localStorage.setItem(getUserKey(STORAGE_KEYS.MONITORING), JSON.stringify(sessions));
  },
  getUserStats: (): UserStats => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.USER_STATS));
    return data ? JSON.parse(data) : { 
      xp: 0, 
      level: 1, 
      scansCount: 0, 
      sessionsCount: 0, 
      username: 'Botanist',
      profileIcon: 'Persona1',
      lastAction: 'Welcome to SmartGrow!'
    };
  },
  saveUserStats: (stats: UserStats) => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.USER_STATS), JSON.stringify(stats));
  },
  getAlerts: (): AppAlert[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.ALERTS));
    return data ? JSON.parse(data) : [];
  },
  saveAlerts: (alerts: AppAlert[]) => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify(alerts));
  },
  addAlert: (alert: AppAlert) => {
    const alerts = storageService.getAlerts();
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify([alert, ...alerts]));
  },
  clearAlerts: () => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify([]));
  },
  // Clear all user-specific data (useful for testing or data migration)
  clearUserData: () => {
    const user = firebaseService.getCurrentUser();
    if (user) {
      Object.values(STORAGE_KEYS).forEach(key => {
        localStorage.removeItem(`${key}_${user.uid}`);
      });
    }
  }
};
