import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
      print('Environment variables loaded successfully');
    } catch (e) {
      print('Failed to load .env file: $e');
      // Continue with empty env for development
      await dotenv.load(fileName: '.env.example');
      print('Loaded .env.example as fallback');
    }
  }

  // Gemini AI API Key
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty || key == 'your_gemini_api_key_here') {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    return key;
  }

  // Firebase Configuration
  static String get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'] ?? 'smartgrow9';
  }

  static String get firebaseApiKey {
    return dotenv.env['FIREBASE_API_KEY'] ?? '';
  }

  static String get firebaseAuthDomain {
    return dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  }

  static String get firebaseDatabaseUrl {
    return dotenv.env['FIREBASE_DATABASE_URL'] ?? '';
  }

  static String get firebaseStorageBucket {
    return dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  }

  static String get firebaseMessagingSenderId {
    return dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  }

  static String get firebaseAppId {
    return dotenv.env['FIREBASE_APP_ID'] ?? '';
  }

  // App Configuration
  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'SmartGrow9';
  }

  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  static bool get debugMode {
    return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  }

  // API Configuration
  static String get baseApiUrl {
    return dotenv.env['BASE_API_URL'] ?? 'https://api.smartgrow9.com';
  }

  static int get apiTimeout {
    final timeout = dotenv.env['API_TIMEOUT'] ?? '30000';
    return int.tryParse(timeout) ?? 30000;
  }

  // Check if all required environment variables are set
  static bool get isConfigured {
    try {
      geminiApiKey; // Will throw if not configured
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all environment variables for debugging (only in debug mode)
  static Map<String, String> get allEnvVars {
    if (!debugMode) return {};
    
    return Map.from(dotenv.env)..forEach((key, value) {
      // Mask sensitive values
      if (key.toLowerCase().contains('key') || 
          key.toLowerCase().contains('secret') ||
          key.toLowerCase().contains('password')) {
        dotenv.env[key] = value.isNotEmpty ? '${value.substring(0, 4)}***' : '';
      }
    });
  }
}
