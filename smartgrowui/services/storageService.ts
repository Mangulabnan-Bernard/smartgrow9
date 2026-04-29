
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

// Helper to sync data with cloud
const syncToCloud = async (dataType: 'scans' | 'monitoring' | 'alerts' | 'stats', data: any) => {
  const user = firebaseService.getCurrentUser();
  if (user) {
    try {
      await firebaseService.saveUserData(user.uid, dataType, data);
    } catch (error) {
      console.error('Failed to sync to cloud:', error);
    }
  }
};

export const storageService = {
  getScans: (): DiagnosisResult[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.SCANS));
    return data ? JSON.parse(data) : [];
  },
  saveScan: async (scan: DiagnosisResult) => {
    const scans = storageService.getScans();
    const index = scans.findIndex(s => s.id === scan.id);
    if (index >= 0) {
      scans[index] = scan;
    } else {
      scans.unshift(scan);
    }
    localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
    await syncToCloud('scans', scans);
  },
  toggleArchiveScan: async (id: string) => {
    const scans = storageService.getScans();
    const index = scans.findIndex(s => s.id === id);
    if (index >= 0) {
      scans[index].archived = !scans[index].archived;
      localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
      await syncToCloud('scans', scans);
    }
  },
  deleteScan: async (id: string) => {
    const scans = storageService.getScans().filter(s => s.id !== id);
    localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(scans));
    await syncToCloud('scans', scans);
  },
  getMonitoring: (): MonitoringSession[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.MONITORING));
    return data ? JSON.parse(data) : [];
  },
  saveMonitoring: async (session: MonitoringSession) => {
    const sessions = storageService.getMonitoring();
    const index = sessions.findIndex(s => s.id === session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.push(session);
    }
    localStorage.setItem(getUserKey(STORAGE_KEYS.MONITORING), JSON.stringify(sessions));
    await syncToCloud('monitoring', sessions);
  },
  deleteSession: async (id: string) => {
    const sessions = storageService.getMonitoring().filter(s => s.id !== id);
    localStorage.setItem(getUserKey(STORAGE_KEYS.MONITORING), JSON.stringify(sessions));
    await syncToCloud('monitoring', sessions);
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
  saveUserStats: async (stats: UserStats) => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.USER_STATS), JSON.stringify(stats));
    await syncToCloud('stats', stats);
  },
  getAlerts: (): AppAlert[] => {
    const data = localStorage.getItem(getUserKey(STORAGE_KEYS.ALERTS));
    return data ? JSON.parse(data) : [];
  },
  saveAlerts: async (alerts: AppAlert[]) => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify(alerts));
    await syncToCloud('alerts', alerts);
  },
  addAlert: async (alert: AppAlert) => {
    const alerts = storageService.getAlerts();
    const updatedAlerts = [alert, ...alerts];
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify(updatedAlerts));
    await syncToCloud('alerts', updatedAlerts);
  },
  clearAlerts: async () => {
    localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify([]));
    await syncToCloud('alerts', []);
  },
  // Sync data from cloud to local storage
  syncFromCloud: async () => {
    const user = firebaseService.getCurrentUser();
    if (user) {
      try {
        const cloudData = await firebaseService.syncDataFromCloud(user.uid);
        
        if (cloudData.scans && cloudData.scans.length > 0) {
          localStorage.setItem(getUserKey(STORAGE_KEYS.SCANS), JSON.stringify(cloudData.scans));
        }
        
        if (cloudData.monitoring && cloudData.monitoring.length > 0) {
          localStorage.setItem(getUserKey(STORAGE_KEYS.MONITORING), JSON.stringify(cloudData.monitoring));
        }
        
        if (cloudData.alerts && cloudData.alerts.length > 0) {
          localStorage.setItem(getUserKey(STORAGE_KEYS.ALERTS), JSON.stringify(cloudData.alerts));
        }
        
        if (cloudData.stats) {
          localStorage.setItem(getUserKey(STORAGE_KEYS.USER_STATS), JSON.stringify(cloudData.stats));
        }
        
        return cloudData;
      } catch (error) {
        console.error('Failed to sync from cloud:', error);
        return null;
      }
    }
    return null;
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
