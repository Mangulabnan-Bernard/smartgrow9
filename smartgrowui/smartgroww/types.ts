
export type Severity = 'Healthy' | 'Mild' | 'Moderate' | 'Severe';

export interface EnvironmentalData {
  temperature: number;
  humidity: number;
  soilMoisture: number;
  light: number;
}

export interface DiagnosisResult {
  id: string;
  timestamp: number;
  plantName: string;
  diagnosis: string;
  confidence: number;
  severity: Severity;
  organicTreatment: string;
  chemicalTreatment: string;
  prevention: string;
  imageUrl?: string;
  environment?: EnvironmentalData;
  stressFactor?: string;
  powerTips: string[];
  archived?: boolean;
  isPlant?: boolean; // New field to verify identification
}

export interface DailyRecord {
  day: number;
  timestamp: number;
  status: 'Improving' | 'Stable' | 'Worsening' | 'Recovered';
  notes: string;
  result?: DiagnosisResult;
}

export interface MonitoringSession {
  id: string;
  plantName: string;
  startDate: number;
  currentDay: number;
  status: 'Active' | 'Recovered' | 'Archived';
  dailyRecords: DailyRecord[];
}

export interface AppAlert {
  id: string;
  title: string;
  message: string;
  severity: 'info' | 'warning' | 'error';
  timestamp: number;
}

export interface UserStats {
  xp: number;
  level: number;
  scansCount: number;
  sessionsCount: number;
  username: string;
  fullName?: string;
  profileIcon: string;
  lastAction?: string; // Track the latest activity log
  themeColor?: string; // e.g., 'green', 'blue', 'purple'
}

export type Language = 'en' | 'tl';
export type Page = 'dashboard' | 'scanner' | 'history' | 'profile' | 'compatibility' | 'analytics' | 'monitoring' | 'archived';
