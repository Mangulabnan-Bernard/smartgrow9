import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'gemini_ai_service.dart';

class PredictionResult {
  final String label;
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.confidence,
  });
}

class AiModelService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _initialized = false;
  static bool _useGemini = false;

  static Future<void> initialize() async {
    try {
      print("STEP 1: Initializing both AI models");
      
      // Always initialize TFLite first (offline capability)
      print("STEP 2: Initializing TFLite model");
      await _initializeTFLite();
      
      // Try to initialize Gemini AI (online capability)
      print("STEP 3: Checking internet and initializing Gemini AI");
      _useGemini = await GeminiAiService.hasInternetConnection();
      
      if (_useGemini) {
        try {
          await GeminiAiService.initialize();
          print("STEP 4: Both Gemini AI and TFLite initialized successfully");
        } catch (e) {
          print("Gemini AI initialization failed, using TFLite only: $e");
          _useGemini = false;
        }
      } else {
        print("STEP 4: No internet, using TFLite only");
      }
      
      _initialized = true;
      print("AI Service initialized. Using: ${_useGemini ? 'Gemini AI + TFLite' : 'TFLite only'}");
    } catch (e) {
      print("AI INITIALIZATION FAILED: $e");
      // If TFLite fails, we can't continue
      throw Exception('Failed to initialize AI service: $e');
    }
  }

  static Future<void> _initializeTFLite() async {
    try {
      print("Initializing TFLite model");
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'assets/models/crop_model.tflite',
        options: options,
      );
      print("TFLite Model loaded! Input shape: ${_interpreter!.getInputTensor(0).shape}");

      print("Loading TFLite labels");
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print("TFLite labels loaded successfully");
    } catch (e) {
      throw Exception('Failed to load TFLite model: $e');
    }
  }

  static Future<dynamic> predict(img.Image image) async {
    if (!_initialized) {
      await initialize();
    }

    // Check internet connection at prediction time for real-time fallback
    final hasInternet = await GeminiAiService.hasInternetConnection();
    
    if (hasInternet && _useGemini) {
      print("Using Gemini AI for prediction (internet available)");
      try {
        final result = await GeminiAiService.analyzeImage(image);
        if (result != null) {
          return result;
        }
        print("Gemini AI failed, falling back to TFLite");
      } catch (e) {
        print("Gemini AI error: $e, falling back to TFLite");
      }
    }
    
    // Fallback to TFLite
    print("Using TFLite for prediction");
    return await _predictWithTFLite(image);
  }

  static Future<PredictionResult?> _predictWithTFLite(img.Image image) async {
    if (_interpreter == null || _labels == null) {
      throw Exception("TFLite model not initialized");
    }

    // 1. Preprocess: Resize to 224x224
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    
    // 2. Convert image to tensor input with proper normalization
    final input = List.generate(224 * 224 * 3, (index) {
      final y = (index ~/ (224 * 3));
      final x = (index % (224 * 3)) ~/ 3;
      final pixel = resizedImage.getPixel(x, y);
      final channel = index % 3;
      switch (channel) {
        case 0: return (pixel.r / 127.5) - 1.0; // Red - proper normalization
        case 1: return (pixel.g / 127.5) - 1.0; // Green
        case 2: return (pixel.b / 127.5) - 1.0; // Blue
        default: return 0.0;
      }
    });

    // 3. Define output buffer - exactly 7 classes
    final output = List<double>.filled(7, 0.0).reshape([1, 7]);
    
    // 4. Run inference
    _interpreter!.run(input.reshape([1, 224, 224, 3]), output);

    // 5. Get results and apply confidence scaling
    final scores = output[0];
    double maxScore = 0.0;
    int maxIndex = 0;
    
    for (int i = 0; i < scores.length; i++) {
      double scaledConfidence = _scaleConfidence(scores[i]);
      if (scaledConfidence > maxScore) {
        maxScore = scaledConfidence;
        maxIndex = i;
      }
    }

    // 6. Check confidence threshold
    if (maxScore < 0.60) {
      return null; // Below threshold
    }

    final label = _labels![maxIndex];
    return PredictionResult(label: label, confidence: maxScore);
  }

  static double _scaleConfidence(double rawConfidence) {
    // Keep 96% as maximum confidence cap
    if (rawConfidence >= 1.00) return 0.96; // MAX = 96%
    if (rawConfidence >= 0.99) return 0.96; // 99% → 96%
    if (rawConfidence >= 0.98) return 0.96; // 98% → 96%
    if (rawConfidence >= 0.97) return 0.96; // 97% → 96%
    if (rawConfidence >= 0.96) return 0.96; // 96% stays 96%
    if (rawConfidence >= 0.95) return 0.95; // 95% stays 95%
    if (rawConfidence >= 0.94) return 0.94; // 94% stays 94%
    if (rawConfidence >= 0.93) return 0.93; // 93% stays 93%
    if (rawConfidence >= 0.92) return 0.92; // 92% stays 92%
    if (rawConfidence >= 0.91) return 0.91; // 91% stays 91%
    if (rawConfidence >= 0.90) return 0.90; // 90% stays 90%
    
    // Keep existing scaling for lower values
    if (rawConfidence >= 0.83) return 0.70;
    if (rawConfidence >= 0.82) return 0.79;
    if (rawConfidence >= 0.81) return 0.78;
    if (rawConfidence >= 0.80) return 0.77;
    if (rawConfidence >= 0.79) return 0.76;
    if (rawConfidence >= 0.78) return 0.75;
    
    return rawConfidence; // For values below 0.78
  }

  static Future<bool> hasInternetConnection() async {
    return await GeminiAiService.hasInternetConnection();
  }

  static String get currentAIModel => _useGemini ? 'Gemini AI' : 'TFLite';

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    GeminiAiService.dispose();
    _initialized = false;
  }

  static bool get isInitialized => _initialized;
  static List<String> get labels => _labels ?? [];
}
