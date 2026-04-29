import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../models/scan_result.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../services/ai_model_service.dart';
import '../services/language_service.dart';
import '../services/gemini_ai_service.dart';
import '../pages/home_page.dart';
import '../widgets/scan_result_widget.dart';
import '../pages/dashboard_page.dart';

class CropDetectionPage extends StatefulWidget {
  final bool isFromMonitoring;

  const CropDetectionPage({super.key, this.isFromMonitoring = false});

  @override
  State<CropDetectionPage> createState() => _CropDetectionPageState();
}

class _CropDetectionPageState extends State<CropDetectionPage> {
  final ImagePicker _imagePicker = ImagePicker();
  ScanResult? _scanResult;
  bool _isAnalyzing = false;
  bool _isPickingImage = false;
  XFile? _selectedImage;
  bool _showSaveOptions = false;
  bool _modelReady = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await AiModelService.initialize();
      setState(() => _modelReady = true);
    } catch (e) {
      _showErrorDialog('Failed to load AI model: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (!_modelReady || _isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      if (image != null) {
        _selectedImage = image;
        _analyzeImage(image);
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _pickImage() async {
    if (!_modelReady || _isPickingImage) return;
    _isPickingImage = true;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      if (image != null) {
        final isDuplicate = await _checkForDuplicateImage(image);
        if (isDuplicate) {
          _showErrorDialog('This image has already been scanned. Please select a different image.');
          return;
        }
        await _analyzeImage(image);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    } finally {
      _isPickingImage = false;
    }
  }

  Future<bool> _checkForDuplicateImage(XFile image) async {
    try {
      final imageHash = await _generateImageHash(image);
      print('CropDetection Debug: Generated image hash: $imageHash');

      final scans = await StorageService.getScans();
      // Only check non-archived scans for duplicates
      for (final scan in scans) {
        if (!scan.archived && scan.imageHash == imageHash) {
          print('CropDetection Debug: Found duplicate scan with hash: $imageHash');
          return true;
        }
      }

      final sessions = await StorageService.getMonitoring();
      // Only check active monitoring sessions for duplicates
      for (final session in sessions) {
        if (session.status == SessionStatus.active) {
          for (final record in session.dailyRecords) {
            if (record.imageHash == imageHash) {
              print('CropDetection Debug: Found duplicate monitoring record with hash: $imageHash');
              return true;
            }
          }
        }
      }

      print('CropDetection Debug: No duplicate found for hash: $imageHash');
      return false;
    } catch (e) {
      print('CropDetection Debug: Error checking for duplicate image: $e');
      return false;
    }
  }

  Future<String> _generateImageHash(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final hash = crypto.sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      print('CropDetection Debug: Error generating image hash: $e');
      final hash = crypto.sha256.convert(utf8.encode(image.path));
      return hash.toString();
    }
  }

  Future<void> _analyzeImage(XFile image) async {
    setState(() {
      _isAnalyzing = true;
      _scanResult = null;
      _showSaveOptions = false;
    });

    _selectedImage = image;

    try {
      final imageBytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage == null) {
        throw Exception('Could not decode image');
      }

      final prediction = await AiModelService.predict(decodedImage);

      if (prediction == null) {
        setState(() => _isAnalyzing = false);
        _showErrorDialog(
          'Low confidence detection.\n\n'
          'Please take a clearer photo with:\n'
          '• Better lighting\n'
          '• Plant centered in frame\n'
          '• Minimal background noise\n\n'
          'Supported plants: Tomato, Garlic, Red Onion',
        );
        return;
      }

      final imageHash = await _generateImageHash(image);
      final scanResult = _createScanResultFromPrediction(prediction, image.path, imageHash);

      // Check if result is Unknown and show helpful dialog
      if (scanResult.plantName == 'Unknown') {
        setState(() => _isAnalyzing = false);
        _showUnknownResultDialog();
        return;
      }

      setState(() {
        _scanResult = scanResult;
        _isAnalyzing = false;
        
        // If called from monitoring, skip dialog and return result directly
        if (widget.isFromMonitoring) {
          Navigator.of(context).pop(scanResult);
        } else {
          _showSaveOptions = scanResult.isPlant && scanResult.plantName != 'Unknown';
        }
      });

    } catch (e) {
      setState(() => _isAnalyzing = false);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Analysis Failed'),
          content: Text('Failed to analyze image: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSaveOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        children: [
          const Text(
            'What would you like to do?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  color: CupertinoColors.black,
                  onPressed: _saveToHistory,
                  child: const Text(
                    'Save to History',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  color: CupertinoColors.black,
                  onPressed: _startAssessment,
                  child: const Text(
                    'Start 7-Day Check',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveToHistory() async {
    setState(() => _isAnalyzing = true);
    try {
      if (_scanResult != null) {
        // Check if result is Unknown
        if (_scanResult!.plantName == 'Unknown') {
          _showErrorDialog('Unable to save unknown');
          return;
        }
        
        await StorageService.saveScan(_scanResult!);

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Scan saved to history!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate back to HomePage and switch to history tab (index 3)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  HomePage.pendingTabIndex = 3; // History tab
                  setState(() {
                    _scanResult = null;
                    _showSaveOptions = false;
                    _selectedImage = null;
                  });
                },
              ),
            ],
          ),
        );
        setState(() => _showSaveOptions = false);
      } else {
        _showErrorDialog('No scan result to save');
      }
    } catch (e) {
      _showErrorDialog('Failed to save: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _startAssessment() async {
    setState(() => _isAnalyzing = true);
    try {
      if (_scanResult != null) {
        // Check if result is Unknown
        if (_scanResult!.plantName == 'Unknown') {
          _showErrorDialog('Unable to save unknown');
          return;
        }
        
        final session = MonitoringSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          plantName: _scanResult!.plantName,
          startDate: DateTime.now().millisecondsSinceEpoch,
          currentDay: 1,
          status: SessionStatus.active,
          dailyRecords: [
            DailyRecord(
              day: 1,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              status: _scanResult!.severity == Severity.healthy ? RecordStatus.recovered : RecordStatus.stable,
              notes: 'Initial scan',
              result: _scanResult,
            ),
          ],
        );

        await StorageService.saveMonitoring(session);

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Assessment Started'),
            content: const Text('7-day check has been started! Switch to the Track tab to monitor progress.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate back to HomePage and switch to track tab (index 1)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  HomePage.pendingTabIndex = 1; // Track tab
                  setState(() {
                    _scanResult = null;
                    _showSaveOptions = false;
                    _selectedImage = null;
                  });
                },
              ),
            ],
          ),
        );
        setState(() => _showSaveOptions = false);
      } else {
        _showErrorDialog('No scan result to start assessment');
      }
    } catch (e) {
      _showErrorDialog('Failed to start assessment: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showUnknownResultDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unknown Plant'),
        content: const Text(
          'I couldn\'t identify this plant clearly. Please retake the image with:\n\n'
          '• Better lighting\n'
          '• Closer to the plant\n'
          '• Center the plant in frame\n'
          '• Less background clutter\n\n'
          'Supported plants: Tomato, Garlic, Red Onion',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear the current image and reset for new scan
              setState(() {
                _selectedImage = null;
                _scanResult = null;
              });
            },
            child: const Text('Retake Photo'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AiModelService.dispose();
    super.dispose();
  }

  ScanResult _createScanResultFromPrediction(dynamic prediction, String? imagePath, String? imageHash) {
    if (prediction is GeminiAnalysisResult) {
      final geminiResult = prediction as GeminiAnalysisResult;

      print('Scan Debug: Gemini AI Analysis - Plant: ${geminiResult.plantName}, Local: ${geminiResult.localName}');

      return ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        plantName: geminiResult.plantName,
        diagnosis: geminiResult.overview,
        severity: _getSeverityFromOverview(geminiResult.overview),
        organicTreatment: geminiResult.advice,
        chemicalTreatment: geminiResult.recommendation,
        prevention: geminiResult.powerTips,
        powerTips: [geminiResult.powerTips],
        stressFactor: '',
        imageUrl: imagePath,
        isPlant: true,
        confidence: geminiResult.confidence,
        imageHash: imageHash,
      );
    }

    if (prediction is! PredictionResult) {
      return ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        plantName: 'Error',
        diagnosis: 'Invalid prediction type',
        severity: Severity.mild,
        organicTreatment: '',
        chemicalTreatment: '',
        prevention: '',
        powerTips: [],
        stressFactor: '',
        imageUrl: imagePath,
        isPlant: false,
        confidence: 0.0,
        imageHash: imageHash,
      );
    }

    final tfliteResult = prediction as PredictionResult;
    final label = tfliteResult.label;
    final confidence = tfliteResult.confidence;

    final parts = label.split('_');
    final plantName = parts[0];
    final condition = parts.length > 1 ? parts[1] : 'Unknown';

    // Handle Unknown case
    if (label == 'Unknown' || plantName == 'Unknown') {
      print('Scan Debug: Plant classified as UNKNOWN');
      return ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        plantName: 'Unknown',
        diagnosis: 'Unknown',
        severity: Severity.mild,
        organicTreatment: 'Unknown',
        chemicalTreatment: 'Unknown',
        prevention: 'Unknown',
        powerTips: ['Unknown'],
        stressFactor: 'Unknown',
        imageUrl: imagePath,
        isPlant: false,
        confidence: confidence,
        imageHash: imageHash,
      );
    }

    Severity severity;
    if (condition.toLowerCase() == 'healthy') {
      severity = Severity.healthy;
      print('Scan Debug: Plant $plantName classified as HEALTHY');
    } else {
      if (confidence >= 0.8) {
        severity = Severity.severe;
        print('Scan Debug: Plant $plantName classified as SEVERE (confidence: $confidence)');
      } else if (confidence >= 0.6) {
        severity = Severity.moderate;
        print('Scan Debug: Plant $plantName classified as MODERATE (confidence: $confidence)');
      } else {
        severity = Severity.mild;
        print('Scan Debug: Plant $plantName classified as MILD (confidence: $confidence)');
      }
    }

    print('Scan Debug: Creating scan - Plant: $plantName, Condition: $condition, Severity: $severity, Confidence: $confidence');

    final treatmentData = _getTreatmentData(plantName, condition);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
      plantName: plantName,
      diagnosis: condition == 'Healthy' ? 'Healthy plant' : '$plantName - $condition',
      severity: severity,
      organicTreatment: treatmentData['overview'] ?? '',
      chemicalTreatment: treatmentData['advise'] ?? '',
      prevention: treatmentData['recommendation'] ?? '',
      powerTips: treatmentData['tips'] ?? [],
      stressFactor: treatmentData['stressFactor'] ?? '',
      imageUrl: imagePath,
      isPlant: true,
      confidence: confidence,
      imageHash: imageHash,
    );
  }

  Severity _getSeverityFromOverview(String overview) {
    final lowerOverview = overview.toLowerCase();
    if (lowerOverview.contains('healthy') || lowerOverview.contains('good health')) {
      return Severity.healthy;
    } else if (lowerOverview.contains('severe') || lowerOverview.contains('serious')) {
      return Severity.severe;
    } else if (lowerOverview.contains('moderate') || lowerOverview.contains('moderate')) {
      return Severity.moderate;
    } else {
      return Severity.mild;
    }
  }

  Map<String, dynamic> _getTreatmentData(String plant, String condition) {
    final plantKey = plant.toLowerCase();
    final conditionKey = condition.toLowerCase();

    if (conditionKey == 'healthy') {
      final lang = LanguageService.currentLanguage.value;
      return {
        'overview': lang == 'tl'
          ? 'Ang halaman na ito ay nasa mahusay na kalusugan na walang nakikitang senyales ng sakit o stress. Ang mga dahon ay masisigla at ang pattern ng paglaki ay normal para sa species.'
          : 'This plant is in excellent health with no visible signs of disease or stress. The leaves are vibrant and the growth pattern is normal for the species.',
        'advise': lang == 'tl'
          ? 'Ipagpatuloy ang iyong kasalukuyang routine ng pag-aalaga kabilang ang regular na pagdidilig, tamang sikat ng araw, at paminsan-minsan na pagpupunla. Bantayan ang anumang pagbabago sa kulay ng dahon o pattern ng paglaki.'
          : 'Continue your current care routine including regular watering, proper sunlight, and occasional fertilization. Monitor for any changes in leaf color or growth pattern.',
        'recommendation': lang == 'tl'
          ? 'Panatilihin ang regular na pagmomonitoro at preventive care. Isaisip ang pagdokumento ng progreso ng paglaki at pagpapatupad ng consistent na schedule ng pag-aalaga.'
          : 'Maintain regular monitoring and preventive care. Consider documenting growth progress and implementing a consistent care schedule.',
        'tips': lang == 'tl'
          ? ['Suriin ang halumay ng lupa araw-araw', 'Magbigay ng 6-8 oras ng sikat ng araw', 'Punla nang regular', 'Bantayan ang peste linggu-linggo']
          : ['Check soil moisture daily', 'Provide 6-8 hours of sunlight', 'Prune regularly', 'Monitor for pests weekly'],
        'stressFactor': lang == 'tl' ? 'Wala - Malusog ang halaman' : 'None - Plant is healthy',
      };
    }

    if (plantKey == 'tomato') {
      final lang = LanguageService.currentLanguage.value;
      return {
        'overview': lang == 'tl'
          ? 'Ang halamang kamatis na ito ay nagpapakita ng senyales ng fungal o bacterial disease, na mabilis kumalat sa humid na kondisyon. Ang maagang interbensyon ay mahalaga upang maiwasan ang kumpletong pagkawala ng ani.'
          : 'This tomato plant is showing signs of fungal or bacterial disease, which can spread quickly in humid conditions. Early intervention is crucial to prevent complete crop loss.',
        'advise': lang == 'tl'
          ? 'Agad na alisin at itapon ang lahat ng apektadong dahon at tangkay upang maiwasan ang pagkalat ng sakit. Linisin ang mga pruning tools gamit ang disinfectant sa pagitan ng mga pagputol.'
          : 'Immediately remove and dispose of all affected leaves and stems to prevent disease spread. Clean pruning tools with disinfectant between cuts.',
        'recommendation': lang == 'tl'
          ? 'Mag-apply ng copper-based fungicide ayon sa package instructions at paibutihin ang air circulation sa pamamagitan ng paglalayo ng mga halaman. Iwasan ang overhead watering upang mabawasan ang halumay sa dahon.'
          : 'Apply a copper-based fungicide according to package instructions and improve air circulation by spacing plants farther apart. Avoid overhead watering to reduce leaf moisture.',
        'tips': lang == 'tl'
          ? ['Alisin ang impektadong dahon agad', 'Disinfect ang tools sa pagitan ng mga halaman', 'Bantayan ang antas ng humidity', 'Paibutihin ang air circulation', 'Mag-apply ng fungicide nang preventive']
          : ['Remove infected leaves immediately', 'Disinfect tools between plants', 'Monitor humidity levels', 'Improve air circulation', 'Apply fungicide preventively'],
        'stressFactor': lang == 'tl' ? 'Nakadetect ang sakit - Kailangan ang paggamot' : 'Disease detected - Treatment required',
      };
    } else if (plantKey == 'garlic') {
      final lang = LanguageService.currentLanguage.value;
      return {
        'overview': lang == 'tl'
          ? 'Ang halamang bawang na ito ay apektado ng fungal infection, na karaniwang sanhi ng sobrang halumay at mahinang drainage. Ang pag-unlad ng bulb ay maaaring mabayaran kung hindi agad na lulutasin.'
          : 'This garlic plant is affected by fungal infection, commonly caused by excessive moisture and poor drainage. The bulb development may be compromised if not addressed promptly.',
        'advise': lang == 'tl'
          ? 'Agad na bawasan ang frequency ng pagdidilig at tiyakin na ang lupa ay may tamang drainage. Alisin ang anumang mulch na maaaring nagreretain ng sobrang halumay sa paligid ng base.'
          : 'Reduce watering frequency immediately and ensure soil has proper drainage. Remove any mulch that may be retaining excessive moisture around the base.',
        'recommendation': lang == 'tl'
          ? 'Mag-apply ng systemic fungicide at paibutihin ang soil drainage sa pamamagitan ng pagdagdag ng sand o perlite. Isaisip ang paglipat sa mas mabuting lokasyon kung ang mga problema sa drainage ay nagpapatuloy.'
          : 'Apply a systemic fungicide and improve soil drainage by amending with sand or perlite. Consider transplanting to a better location if drainage issues persist.',
        'tips': lang == 'tl'
          ? ['Bawasan ang frequency ng pagdidilig', 'Paibutihin ang soil drainage', 'Bantayan ang mold', 'Alisin ang apektadong panlabas na layer', 'Mag-apply ng fungicide sa lupa']
          : ['Reduce watering frequency', 'Improve soil drainage', 'Monitor for mold', 'Remove affected outer layers', 'Apply fungicide to soil'],
        'stressFactor': lang == 'tl' ? 'Nakadetect ang fungal infection' : 'Fungal infection detected',
      };
    } else if (plantKey == 'redonion') {
      final lang = LanguageService.currentLanguage.value;
      return {
        'overview': lang == 'tl'
          ? 'Ang pulang sibuyas na ito ay nagdudusa ng bulb rot o fungal infection, na karaniwang nangyayari sa mahinang drained na lupa o sa panahon ng sobrang pag-ulan. Ang kalidad ng pag-iimbak ng mga bulb ay maaaring maapektuhan.'
          : 'This red onion is experiencing bulb rot or fungal infection, which typically occurs in poorly drained soil or during periods of excessive rainfall. The storage quality of bulbs may be affected.',
        'advise': lang == 'tl'
          ? 'Itigil ang pagdidilig agad at payagan ang lupa na maging tuyo. Dahan-dahang alisin ang top layer ng lupa upang paibutihin ang air circulation sa paligid ng bulb.'
          : 'Stop watering immediately and allow the soil to dry out. Gently remove the top layer of soil to improve air circulation around the bulb.',
        'recommendation': lang == 'tl'
          ? 'Mag-apply ng fungicidal drench sa lupa at isagawa ang crop rotation sa mga kinabukasan. Anihin nang maaga kung malubha ang impeksyon upang maligtas ang maaari mong maligtas.'
          : 'Apply a fungicidal drench to the soil and practice crop rotation in future plantings. Harvest early if infection is severe to salvage what you can.',
        'tips': lang == 'tl'
          ? ['Bawasan ang pagdidilig', 'Paibutihin ang bentilasyon', 'Alisin ang mga apektadong halaman', 'Mag-apply ng soil fungicide', 'Isagawa ang crop rotation']
          : ['Reduce watering', 'Improve ventilation', 'Remove affected plants', 'Apply soil fungicide', 'Practice crop rotation'],
        'stressFactor': lang == 'tl' ? 'Nakadetect ang sakit sa bulb' : 'Bulb disease detected',
      };
    }

    final lang = LanguageService.currentLanguage.value;
    return {
      'overview': lang == 'tl'
        ? 'Ang halaman na ito ay nagpapakita ng senyales ng stress o sakit na nangangailangan ng agarang pansin. Ang mga sintomas ay nagmumungkahing sa posible na nutrient deficiency, pinsala sa peste, o environmental stress factors.'
        : 'This plant is showing signs of stress or disease that requires immediate attention. The symptoms suggest possible nutrient deficiency, pest damage, or environmental stress factors.',
      'advise': lang == 'tl'
        ? 'Ihiwalay ang apektadong halaman sa mga malusog at masusingang bantayan nang maingat para sa karagdagang sintomas. Suriin ang soil pH, moisture levels, at mga kamakailang environmental changes.'
        : 'Isolate the affected plant from healthy ones and carefully observe for additional symptoms. Check soil pH, moisture levels, and recent environmental changes.',
      'recommendation': lang == 'tl'
        ? 'Kumunsulta sa lokal na agricultural extension services o plant specialists para sa tumpak na diagnosis at treatment recommendations na spesipiko sa iyong growing conditions.'
        : 'Consult with local agricultural extension services or plant specialists for accurate diagnosis and treatment recommendations specific to your growing conditions.',
      'tips': lang == 'tl'
        ? ['Bantayan araw-araw para sa mga pagbabago', 'Dokumentahin ang mga sintomas gamit ang mga litrato', 'Suriin ang soil conditions', 'Humingi ng expert advice kung kailangan', 'Ihiwalay ang mga apektadong halaman']
        : ['Monitor daily for changes', 'Document symptoms with photos', 'Check soil conditions', 'Seek expert advice if needed', 'Isolate affected plants'],
      'stressFactor': lang == 'tl' ? 'Kailangan ang general monitoring' : 'General monitoring required',
    };
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Fixed header with title and status
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Smart Grow AI • Instant Analysis',
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CupertinoColors.systemGreen),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.wifi_slash, size: 14, color: CupertinoColors.systemGreen),
                        SizedBox(width: 4),
                        Text(
                          'Always Available',
                          style: TextStyle(
                            color: CupertinoColors.systemGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content area with camera in middle
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Camera Interface in the middle
                    _buildCameraInterface(),
                    
                    const SizedBox(height: 20),
                    
                    // Show selected image if available (below camera)
                    if (_selectedImage != null)
                      Container(
                        width: 300,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CupertinoColors.systemGrey4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    // Analysis section
                    if (_isAnalyzing)
                      const Column(
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(height: 16),
                          Text('Analyzing...'),
                        ],
                      ),
                    
                    if (_scanResult != null)
                      ScanResultWidget(result: _scanResult!),
                    
                    if (_showSaveOptions)
                      _buildSaveOptions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraInterface() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.systemBlue.withOpacity(0.1),
            CupertinoColors.systemGreen.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera Icon with animation effect
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemBlue.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.camera_fill,
              size: 55,
              color: CupertinoColors.systemBlue,
            ),
          ),

          const SizedBox(height: 25),

          // Title
          const Text(
            'Smart Grow AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'AI-powered plant health analysis',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),

          const SizedBox(height: 30),

          // Scan Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemBlue,
                      CupertinoColors.systemBlue.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemBlue.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  onPressed: _isPickingImage ? null : _takePhoto,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.camera_fill,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Gallery Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemGreen,
                      CupertinoColors.systemGreen.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGreen.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  onPressed: _isPickingImage ? null : _pickImage,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.photo_fill,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tips
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: CupertinoColors.systemYellow,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For best results: Use good lighting and focus clearly on the plant',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
