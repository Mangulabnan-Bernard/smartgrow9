import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  String _currentTheme = 'green';
  
  // Theme color mappings
  static const Map<String, Color> _themeColors = {
    'green': CupertinoColors.systemGreen,
    'blue': CupertinoColors.systemBlue,
    'red': CupertinoColors.systemRed,
    'orange': CupertinoColors.systemOrange,
    'purple': CupertinoColors.systemPurple,
    'pink': CupertinoColors.systemPink,
    'teal': CupertinoColors.systemTeal,
  };

  String get currentTheme => _currentTheme;
  
  Color get currentColor => _themeColors[_currentTheme] ?? CupertinoColors.systemGreen;
  
  // Get theme color with alpha
  Color currentColorWithAlpha(double alpha) {
    return currentColor.withValues(alpha: alpha);
  }

  // Initialize theme from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString('app_theme') ?? 'green';
    notifyListeners();
  }

  // Change theme
  Future<void> changeTheme(String themeName) async {
    if (_themeColors.containsKey(themeName)) {
      _currentTheme = themeName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_theme', themeName);
      notifyListeners();
    }
  }

  // Get all available theme colors
  Map<String, Color> get availableThemes => Map.from(_themeColors);

  // Get theme color by name
  Color? getThemeColor(String themeName) {
    return _themeColors[themeName];
  }
}
