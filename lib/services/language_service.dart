import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static final ValueNotifier<String> currentLanguage = ValueNotifier('en');

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'en';
    currentLanguage.value = savedLanguage;
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    currentLanguage.value = languageCode;
  }

  static String translate(String key) {
    final translations = _getTranslations();
    return translations[currentLanguage.value]?[key] ?? translations['en']?[key] ?? key;
  }

  static Map<String, Map<String, String>> _getTranslations() {
    return {
      'en': {
        // Navigation
        'home': 'Home',
        'track': 'Track',
        'scan': 'Scan',
        'history': 'History',
        'settings': 'Settings',
        
        // Dashboard
        'welcome_back': 'Welcome back',
        'farmer': 'Farmer',
        'level': 'Level',
        'xp': 'XP',
        'your_garden_stats': 'Your Garden Stats',
        'total_scans': 'Total Scans',
        'active_tracking': 'Active Tracking',
        'health_score': 'Health Score',
        'next_level': 'Next Level',
        'quick_actions': 'Quick Actions',
        'scan_now': 'Scan Now',
        'view_history': 'View History',
        'farmer_tips': 'Farmer Tips',
        
        // Scan Page
        'take_photo': 'Take Photo',
        'choose_from_gallery': 'Choose from Gallery',
        'analyzing': 'Analyzing...',
        'analysis_failed': 'Analysis Failed',
        'low_confidence': 'Low confidence detection.',
        'better_lighting': '• Better lighting',
        'plant_centered': '• Plant centered in frame',
        'minimal_noise': '• Minimal background noise',
        'supported_plants': 'Supported plants: Tomato, Garlic, Red Onion',
        'save_to_history': 'Save to History',
        'start_7_day_check': 'Start 7-Day Check',
        'what_would_you_like_to_do': 'What would you like to do?',
        'success': 'Success',
        'scan_saved_to_history': 'Scan saved to history!',
        
        // Track Page
        'check_your_plants': 'Check Your Plants',
        '7_day_recovery_checks': '7-Day Recovery Checks',
        'view_details': 'View Details',
        'delete': 'Delete',
        'delete_session': 'Delete Session?',
        'are_you_sure_delete_session': 'Are you sure you want to delete this session? It will be moved to archive in settings.',
        'no': 'No',
        'yes': 'Yes',
        'session_archived': 'Session archived',
        'failed_to_archive_session': 'Failed to archive session',
        'day': 'Day',
        'completed': 'Completed',
        'current': 'Current',
        'upcoming': 'Upcoming',
        
        // History Page
        'loading_history': 'Loading history...',
        'no_scans_yet': 'No scans yet',
        'start_first_scan': 'Start your first plant scan',
        'delete_record': 'Delete Record',
        'are_you_sure_delete_record': 'Are you sure you want to delete this record? It will be moved to archive in settings.',
        'record_archived': 'Record archived',
        'failed_to_archive_record': 'Failed to archive record',
        
        // Settings Page
        'archive_records': 'Archive Records',
        'archived_scans': 'Archived Scans',
        'archived_sessions': 'Archived Sessions',
        'restore': 'Restore',
        'started': 'Started',
        
        // Monitoring/Track Page
        'track': 'Track',
        'monitoring': 'Monitoring',
        'active_tracking': 'Active Monitoring',
        'view_details': 'View Details',
        'delete': 'Delete',
        'day': 'Day',
        'recovery_progress': 'Recovery Progress',
        'add_todays_scan': 'Add Today\'s Scan',
        'no_sessions_yet': 'No Sessions Yet',
        'start_monitoring': 'Start Monitoring',
        
        // History Page
        'history': 'History',
        'scan_history': 'Scan History',
        'no_scans_yet': 'No Scans Yet',
        'start_scanning': 'Start Scanning',
        'scan_date': 'Scan Date',
        'plant_name': 'Plant Name',
        'diagnosis': 'Diagnosis',
        'severity': 'Severity',
        'healthy': 'Healthy',
        'mild': 'Mild',
        'moderate': 'Moderate',
        'severe': 'Severe',
        
        // Common
        'ok': 'OK',
        'cancel': 'Cancel',
        'loading': 'Loading...',
        'error': 'Error',
        'close': 'Close',
        'view': 'View',
        'items': 'items',
      },
      'tl': {
        // Navigation
        'home': 'Bahay',
        'track': 'Subaybayan',
        'scan': 'I-scan',
        'history': 'Kasaysayan',
        'settings': 'Mga Setting',
        
        // Dashboard
        'welcome_back': 'Maligayang pagbabalik',
        'farmer': 'Magsasaka',
        'level': 'Antas',
        'xp': 'XP',
        'your_garden_stats': 'Iyong Stats sa Hardin',
        'total_scans': 'Kabuuang Scan',
        'active_tracking': 'Aktibong Subaybay',
        'health_score': 'Score ng Kalusugan',
        'next_level': 'Susunod na Antas',
        'quick_actions': 'Mabilis na Aksyon',
        'scan_now': 'I-scan Ngayon',
        'view_history': 'Tingnan ang Kasaysayan',
        'farmer_tips': 'Mga Tip sa Magsasaka',
        
        // Scan Page
        'take_photo': 'Kumuha ng Litrato',
        'choose_from_gallery': 'Pumili mula sa Gallery',
        'analyzing': 'Sinasuri...',
        'analysis_failed': 'Bigo ang Pagsusuri',
        'low_confidence': 'Mababa ang kumpiyansa.',
        'better_lighting': '• Mas mabuting ilaw',
        'plant_centered': '• Halaman ay nasa gitna',
        'minimal_noise': '• Kaunting background noise',
        'supported_plants': 'Suportadong halaman: Kamatis, Bawang, Sibuyas na Pula',
        'save_to_history': 'I-save sa Kasaysayan',
        'start_7_day_check': 'Magsimula ng 7-Araw na Check',
        'what_would_you_like_to_do': 'Ano ang gusto mong gawin?',
        'success': 'Tagumpay',
        'scan_saved_to_history': 'Na-save ang scan sa kasaysayan!',
        
        // Track Page
        'check_your_plants': 'Surihin ang Iyong mga Halaman',
        '7_day_recovery_checks': '7-Araw na Check sa Paggaling',
        'view_details': 'Tingnan ang Detalye',
        'delete': 'Burahin',
        'delete_session': 'Burahin ang Session?',
        'are_you_sure_delete_session': 'Sigurado ka ba na gusto mong burahin ang session na ito? Ito ay ililipat sa archive sa settings.',
        'no': 'Hindi',
        'yes': 'Oo',
        'session_archived': 'Na-archive ang session',
        'failed_to_archive_session': 'Bigo ang pag-archive sa session',
        'day': 'Araw',
        'completed': 'Nakumpleto',
        'current': 'Kasalukuyan',
        'upcoming': 'Darating',
        
        // History Page
        'loading_history': 'Naglo-load ang kasaysayan...',
        'no_scans_yet': 'Walang scan pa',
        'start_first_scan': 'Magsimula ng iyong unang scan sa halaman',
        'delete_record': 'Burahin ang Tala',
        'are_you_sure_delete_record': 'Sigurado ka ba na gusto mong burahin ang tala na ito? Ito ay ililipat sa archive sa settings.',
        'record_archived': 'Na-archive ang tala',
        'failed_to_archive_record': 'Bigo ang pag-archive sa tala',
        
        // Settings Page
        'archive_records': 'Mga Archived na Tala',
        'archived_scans': 'Mga Na-archive na Scan',
        'archived_sessions': 'Mga Na-archive na Session',
        'restore': 'Ibalik',
        'started': 'Nagsimula',
        
        // Common
        'ok': 'OK',
        'cancel': 'Kanselahin',
        'loading': 'Naglo-load...',
        
        // Tagalog additions
        'quick_actions_tl': 'Mabilisang Mabilis',
        'scan_now_tl': 'I-scan Ngayon',
        'view_history_tl': 'Tingnan Kasaysayan',
        'error': 'Mali',
        'close': 'Isara',
      },
    };
  }
}
