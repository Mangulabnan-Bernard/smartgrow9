import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class GeminiAnalysisResult {
  final String plantName;
  final String localName;
  final String overview;
  final String advice;
  final String recommendation;
  final String powerTips;
  final double confidence;

  const GeminiAnalysisResult({
    required this.plantName,
    required this.localName,
    required this.overview,
    required this.advice,
    required this.recommendation,
    required this.powerTips,
    required this.confidence,
  });
}

class GeminiAiService {
  static GenerativeModel? _model;
  static bool _initialized = false;
  static const String _apiKey = 'AIzaSyCbZFIfVGLP2WGqRwbNZYwgNWqlMRun18E';

  // Philippines/local plant names mapping
  static const Map<String, String> _localPlantNames = {
    'garlic': 'Bawang',
    'onion': 'Sibuyas',
    'tomato': 'Kamatis',
    'pepper': 'Sili',
    'cabbage': 'Repolyo',
    'lettuce': 'Lettuce',
    'spinach': 'Spinach',
    'carrot': 'Karot',
    'potato': 'Patatas',
    'eggplant': 'Talong',
    'bitter melon': 'Ampalaya',
    'long beans': 'Sitaw',
    'okra': 'Okra',
    'squash': 'Kalabasa',
    'ginger': 'Luya',
    'corn': 'Mais',
    'rice': 'Palay',
  };

  static Future<void> initialize() async {
    try {
      print("STEP 1: Initializing Gemini AI");
      _model = GenerativeModel(
        model: "gemini-2.5-flash",
        apiKey: _apiKey,
      );
      _initialized = true;
      print('Gemini AI initialized successfully');
    } catch (e) {
      print("GEMINI INITIALIZATION FAILED: $e");
      throw Exception('Failed to initialize Gemini AI: ');
    }
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check - try to connect to Google
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<GeminiAnalysisResult?> analyzeImage(img.Image image) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Check internet connection first
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        print("No internet connection - Gemini AI unavailable");
        return null;
      }

      print("STEP 2: Converting image to base64");
      // Convert image to JPEG bytes
      final jpegBytes = img.encodeJpg(image, quality: 85);
      final base64Image = base64Encode(jpegBytes);

      print("STEP 3: Preparing Gemini prompt");
      final prompt = """
      Analyze this plant image and provide concise analysis in the following format:

      PLANT_NAME: [Plant species name]
      LOCAL_NAME: [Filipino/local name if applicable]
      OVERVIEW: [1-2 sentence health assessment]
      ADVICE: [1-2 sentence care instructions]
      RECOMMENDATION: [1-2 sentence treatment suggestions]
      POWER_TIPS: [1-2 sentence advanced tips]

      Be direct and concise. Use local Filipino farming context when relevant.
      """;


      print("STEP 4: Calling Gemini AI");
      final content = [
        Content.text(prompt),
        Content.data('image/jpeg', base64Decode(base64Image))
      ];

      final response = await _model!.generateContent(content);
      final text = response.text;

      if (text == null || text.isEmpty) {
        print("Empty response from Gemini AI");
        return null;
      }

      print("STEP 5: Parsing Gemini response");
      return _parseGeminiResponse(text);

    } catch (e) {
      print("GEMINI ANALYSIS FAILED: $e");
      return null;
    }
  }

  static GeminiAnalysisResult _parseGeminiResponse(String response) {
    try {
      // Extract sections from response
      final plantNameMatch = RegExp(r'PLANT_NAME:\s*(.+?)(?=\n|$)').firstMatch(response);
      final localNameMatch = RegExp(r'LOCAL_NAME:\s*(.+?)(?=\n|$)').firstMatch(response);
      final overviewMatch = RegExp(r'OVERVIEW:\s*(.+?)(?=\n|$)').firstMatch(response);
      final adviceMatch = RegExp(r'ADVICE:\s*(.+?)(?=\n|$)').firstMatch(response);
      final recommendationMatch = RegExp(r'RECOMMENDATION:\s*(.+?)(?=\n|$)').firstMatch(response);
      final powerTipsMatch = RegExp(r'POWER_TIPS:\s*(.+?)(?=\n|$)').firstMatch(response);

      final plantName = plantNameMatch?.group(1)?.trim() ?? 'Unknown Plant';
      var localName = localNameMatch?.group(1)?.trim() ?? '';
      
      // Try to get local name from mapping if not provided
      if (localName.isEmpty) {
        final lowerPlantName = plantName.toLowerCase();
        localName = _localPlantNames[lowerPlantName] ?? plantName;
      }

      return GeminiAnalysisResult(
        plantName: plantName,
        localName: localName,
        overview: overviewMatch?.group(1)?.trim() ?? 'Analysis unavailable',
        advice: adviceMatch?.group(1)?.trim() ?? 'Care advice unavailable',
        recommendation: recommendationMatch?.group(1)?.trim() ?? 'No specific recommendations',
        powerTips: powerTipsMatch?.group(1)?.trim() ?? 'No additional tips available',
        confidence: 0.96, // High confidence for Gemini AI (increased to 96 as requested)
      );
    } catch (e) {
      print("ERROR PARSING GEMINI RESPONSE: $e");
      // Return fallback result
      return GeminiAnalysisResult(
        plantName: 'Analysis Error',
        localName: 'Error',
        overview: 'Failed to parse AI response',
        advice: 'Please try again',
        recommendation: 'Check image quality and retry',
        powerTips: 'Ensure good lighting and focus',
        confidence: 0.0,
      );
    }
  }

  static void dispose() {
    _model = null;
    _initialized = false;
  }

  static bool get isInitialized => _initialized;
}
