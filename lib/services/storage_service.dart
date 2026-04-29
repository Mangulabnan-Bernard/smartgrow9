import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_stats.dart';
import '../models/scan_result.dart';

class StorageService {
  // Helper method to get current user email
  static String? getCurrentUserEmail() {
    final email = FirebaseAuth.instance.currentUser?.email;
    print('StorageService Debug: Current user email: $email');
    return email;
  }

  // Helper method to create user-specific keys
  static String _getUserKey(String baseKey, String? userEmail) {
    final email = userEmail ?? getCurrentUserEmail();
    if (email == null) {
      print('StorageService Error: No user email available for storage operation');
      throw Exception('No user email available for storage operation');
    }
    final userKey = '${baseKey}_$email';
    print('StorageService Debug: Using user-specific key: $userKey');
    return userKey;
  }

  static const String _userStatsKey = 'smartgrow_user_stats';
  static const String _scansKey = 'smartgrow_scans';
  static const String _sessionsKey = 'smartgrow_sessions';
  static const String _alertsKey = 'smartgrow_alerts';

  static final ValueNotifier<int> scanUpdated = ValueNotifier(0);
  static final ValueNotifier<int> scansUpdated = ValueNotifier(0); // Add this for profile page
  static final ValueNotifier<int> monitoringUpdated = ValueNotifier(0);

  static Future<SharedPreferences> get _prefs async => 
      await SharedPreferences.getInstance();

  // User Stats
  static Future<UserStats> getUserStats({String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_userStatsKey, userEmail);
    final statsJson = prefs.getString(userKey);
    
    if (statsJson == null) {
      return const UserStats(
        xp: 0,
        level: 1,
        scansCount: 0,
        sessionsCount: 0,
        username: 'Farmer',
        profileIcon: 'Persona1',
        themeColor: 'green',
      );
    }
    
    return UserStats.fromJson(jsonDecode(statsJson));
  }

  static Future<void> saveUserStats(UserStats stats, {String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_userStatsKey, userEmail);
    await prefs.setString(userKey, jsonEncode(stats.toJson()));
  }

  // Update user stats based on current data
  static Future<void> updateUserStats({String? userEmail}) async {
    final scans = await getScans(userEmail: userEmail);
    final sessions = await getMonitoring(userEmail: userEmail);

    // Calculate current stats
    final scansCount = scans.length;
    final sessionsCount = sessions.where((s) => s.status != SessionStatus.archived).length;
    final completedSessionsCount = sessions.where((s) => s.status == SessionStatus.recovered).length;

    // Enhanced XP calculation with multiple earning methods
    int xp = 0;

    // 1. Scanning plants (25 XP per scan - increased from 10)
    xp += scansCount * 25;

    // 2. Starting monitoring sessions (75 XP per session - increased from 50)
    xp += sessionsCount * 75;

    // 3. Completing 7-day monitoring (200 XP bonus per completion)
    xp += completedSessionsCount * 200;

    // 4. Daily login bonus (simulated - 15 XP per day for active users)
    // This would be tracked separately in a real implementation
    xp += (sessionsCount * 15); // Rough estimate based on monitoring activity

    // 5. Healthy plant bonus (10 XP per healthy plant identified)
    final healthyScansCount = scans.where((s) => !s.archived && s.severity == Severity.healthy).length;
    xp += healthyScansCount * 10;

    // 6. Plant variety bonus (5 XP per unique plant type scanned)
    final uniquePlants = scans.map((s) => s.plantName).toSet().length;
    xp += uniquePlants * 5;

    // 7. Consistency bonus (50 XP for having 3+ active monitoring sessions)
    if (sessionsCount >= 3) xp += 50;

    // Calculate level based on XP (level up every 1000 XP - easier progression)
    final level = (xp / 1000).floor() + 1;

    // Get current user stats or create default
    final currentStats = await getUserStats();

    final updatedStats = UserStats(
      xp: xp,
      level: level,
      scansCount: scansCount,
      sessionsCount: sessionsCount,
      username: currentStats.username,
      profileIcon: currentStats.profileIcon,
      themeColor: currentStats.themeColor,
    );

    await saveUserStats(updatedStats);
  }

  // Scan Results
  static Future<List<ScanResult>> getScans({String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_scansKey, userEmail);
    final scansJson = prefs.getString(userKey);
    
    if (scansJson == null) return [];
    
    final List<dynamic> scansList = jsonDecode(scansJson);
    return scansList.map((scan) => ScanResult.fromJson(scan)).toList();
  }

  static Future<void> saveScan(ScanResult scan, {String? userEmail}) async {
    final scans = await getScans(userEmail: userEmail);
    scans.insert(0, scan); // Add to beginning
    
    // Keep only last 100 scans
    if (scans.length > 100) {
      scans.removeRange(100, scans.length);
    }
    
    final prefs = await _prefs;
    final userKey = _getUserKey(_scansKey, userEmail);
    await prefs.setString(userKey, jsonEncode(scans.map((s) => s.toJson()).toList()));
    
    scanUpdated.value++;
    scansUpdated.value++;
    await updateUserStats();
  }

  static Future<void> deleteScan(String id, {String? userEmail}) async {
    final scans = await getScans(userEmail: userEmail);
    scans.removeWhere((scan) => scan.id == id);
    
    final prefs = await _prefs;
    final userKey = _getUserKey(_scansKey, userEmail);
    await prefs.setString(userKey, jsonEncode(scans.map((s) => s.toJson()).toList()));
    scanUpdated.value++;
    scansUpdated.value++;
    
    // Update user stats to reflect deleted scan
    await updateUserStats();
  }

  static Future<void> archiveScan(String id, {String? userEmail}) async {
    final scans = await getScans(userEmail: userEmail);
    final scanIndex = scans.indexWhere((scan) => scan.id == id);
    
    if (scanIndex != -1) {
      scans[scanIndex] = scans[scanIndex].copyWith(archived: true);
      
      final prefs = await _prefs;
      final userKey = _getUserKey(_scansKey, userEmail);
      await prefs.setString(userKey, jsonEncode(scans.map((s) => s.toJson()).toList()));
      scanUpdated.value++;
      scansUpdated.value++; // Add this for profile page updates
    }
  }

  static Future<void> toggleArchiveScan(String id, {String? userEmail}) async {
    final scans = await getScans(userEmail: userEmail);
    final scanIndex = scans.indexWhere((scan) => scan.id == id);
    
    if (scanIndex != -1) {
      scans[scanIndex] = scans[scanIndex].copyWith(archived: !scans[scanIndex].archived);
      
      final prefs = await _prefs;
      final userKey = _getUserKey(_scansKey, userEmail);
      await prefs.setString(userKey, jsonEncode(scans.map((s) => s.toJson()).toList()));
      
      print('StorageService Debug: toggleArchiveScan completed');
      print('StorageService Debug: Notifying scanUpdated listeners');
      scanUpdated.value++;
      print('StorageService Debug: Notifying scansUpdated listeners (value: ${scansUpdated.value})');
      scansUpdated.value++; // Add this for profile page updates
    } else {
      print('StorageService Debug: toggleArchiveScan - scan not found with id: $id');
    }
  }

  // Monitoring Sessions
  static Future<List<MonitoringSession>> getMonitoring({String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_sessionsKey, userEmail);
    final sessionsJson = prefs.getString(userKey);
    
    if (sessionsJson == null) return [];
    
    final List<dynamic> sessionsList = jsonDecode(sessionsJson);
    return sessionsList.map((session) => MonitoringSession.fromJson(session)).toList();
  }

  static Future<void> saveMonitoring(MonitoringSession session, {String? userEmail}) async {
    final sessions = await getMonitoring(userEmail: userEmail);
    final existingIndex = sessions.indexWhere((s) => s.id == session.id);
    
    if (existingIndex != -1) {
      sessions[existingIndex] = session;
    } else {
      sessions.add(session);
    }
    
    final prefs = await _prefs;
    final userKey = _getUserKey(_sessionsKey, userEmail);
    await prefs.setString(userKey, jsonEncode(sessions.map((s) => s.toJson()).toList()));
    
    monitoringUpdated.value++;
    await updateUserStats();
  }

  static Future<void> archiveMonitoring(String id, {String? userEmail}) async {
    final sessions = await getMonitoring(userEmail: userEmail);
    final sessionIndex = sessions.indexWhere((s) => s.id == id);
    
    if (sessionIndex != -1) {
      final updatedSession = sessions[sessionIndex].copyWith(
        status: SessionStatus.archived,
      );
      sessions[sessionIndex] = updatedSession;
      
      final prefs = await _prefs;
      final userKey = _getUserKey(_sessionsKey, userEmail);
      await prefs.setString(userKey, jsonEncode(sessions.map((s) => s.toJson()).toList()));
      monitoringUpdated.value++;
      
      // Update user stats to reflect archived session (removes from active count)
      await updateUserStats();
    }
  }

  static Future<void> restoreMonitoring(String id, {String? userEmail}) async {
    final sessions = await getMonitoring(userEmail: userEmail);
    final sessionIndex = sessions.indexWhere((s) => s.id == id);
    
    if (sessionIndex != -1) {
      final updatedSession = sessions[sessionIndex].copyWith(
        status: SessionStatus.active,
      );
      sessions[sessionIndex] = updatedSession;
      
      final prefs = await _prefs;
      final userKey = _getUserKey(_sessionsKey, userEmail);
      await prefs.setString(userKey, jsonEncode(sessions.map((s) => s.toJson()).toList()));
      monitoringUpdated.value++;
      
      // Update user stats to reflect restored session (adds to active count)
      await updateUserStats();
    }
  }

  static Future<void> deleteMonitoring(String id, {String? userEmail}) async {
    final sessions = await getMonitoring(userEmail: userEmail);
    sessions.removeWhere((session) => session.id == id);
    
    final prefs = await _prefs;
    final userKey = _getUserKey(_sessionsKey, userEmail);
    await prefs.setString(userKey, jsonEncode(sessions.map((s) => s.toJson()).toList()));
    monitoringUpdated.value++;
    
    // Update user stats to reflect deleted session
    await updateUserStats();
  }

  // Alerts
  static Future<List<AppAlert>> getAlerts({String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_alertsKey, userEmail);
    final alertsJson = prefs.getString(userKey);
    
    if (alertsJson == null) return [];
    
    final List<dynamic> alertsList = jsonDecode(alertsJson);
    return alertsList.map((alert) => AppAlert.fromJson(alert)).toList();
  }

  static Future<void> saveAlert(AppAlert alert, {String? userEmail}) async {
    final alerts = await getAlerts(userEmail: userEmail);
    alerts.insert(0, alert);
    
    // Keep only last 15 alerts
    if (alerts.length > 15) {
      alerts.removeRange(15, alerts.length);
    }
    
    final prefs = await _prefs;
    final userKey = _getUserKey(_alertsKey, userEmail);
    await prefs.setString(userKey, jsonEncode(alerts.map((a) => a.toJson()).toList()));
  }

  static Future<void> clearAlerts({String? userEmail}) async {
    final prefs = await _prefs;
    final userKey = _getUserKey(_alertsKey, userEmail);
    await prefs.remove(userKey);
  }

  // Utility Methods
  static Future<void> clearAllData({String? userEmail}) async {
    final prefs = await _prefs;
    final userEmailStr = userEmail ?? getCurrentUserEmail();
    if (userEmailStr != null) {
      // Clear user-specific data
      await prefs.remove(_getUserKey(_userStatsKey, userEmailStr));
      await prefs.remove(_getUserKey(_scansKey, userEmailStr));
      await prefs.remove(_getUserKey(_sessionsKey, userEmailStr));
      await prefs.remove(_getUserKey(_alertsKey, userEmailStr));
    } else {
      // Clear all data (fallback)
      await prefs.remove(_userStatsKey);
      await prefs.remove(_scansKey);
      await prefs.remove(_sessionsKey);
      await prefs.remove(_alertsKey);
    }
  }

  static Future<Map<String, dynamic>> exportData({String? userEmail}) async {
    final stats = await getUserStats(userEmail: userEmail);
    final scans = await getScans(userEmail: userEmail);
    final sessions = await getMonitoring(userEmail: userEmail);
    final alerts = await getAlerts(userEmail: userEmail);

    return {
      'userStats': stats.toJson(),
      'scans': scans.map((s) => s.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'userEmail': userEmail ?? getCurrentUserEmail(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    if (data.containsKey('userStats')) {
      await saveUserStats(UserStats.fromJson(data['userStats']));
    }
    
    if (data.containsKey('scans')) {
      final prefs = await _prefs;
      await prefs.setString(_scansKey, jsonEncode(data['scans']));
    }
    
    if (data.containsKey('sessions')) {
      final prefs = await _prefs;
      await prefs.setString(_sessionsKey, jsonEncode(data['sessions']));
    }
    
    if (data.containsKey('alerts')) {
      final prefs = await _prefs;
      await prefs.setString(_alertsKey, jsonEncode(data['alerts']));
    }
  }
}
