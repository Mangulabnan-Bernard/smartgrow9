import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import '../services/language_service.dart';
import '../pages/crop_detection_page.dart';

class AssessmentDetailPage extends StatefulWidget {
  final MonitoringSession session;
  final DailyRecord? dayRecord;

  const AssessmentDetailPage({super.key, required this.session, this.dayRecord});

  @override
  State<AssessmentDetailPage> createState() => _AssessmentDetailPageState();
}

class _AssessmentDetailPageState extends State<AssessmentDetailPage> {
  late MonitoringSession _session;
  DailyRecord? _dayRecord;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _dayRecord = widget.dayRecord;
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getOverallTrend() {
    // Simple trend calculation based on completed days
    final completedDays = _session.dailyRecords.where((record) => record.result != null).length;
    if (completedDays == 0) return 'Not started';

    final lastResult = _session.dailyRecords
        .where((record) => record.result != null)
        .last.result!;

    if (lastResult.severity == Severity.healthy) {
      return 'Improving';
    } else if (lastResult.severity == Severity.mild) {
      return 'Stable';
    } else {
      return 'Needs attention';
    }
  }

  String _getOverallStatus(MonitoringSession session) {
    final completedDays = session.dailyRecords.where((record) => record.result != null).length;
    if (completedDays == 0) return 'Not started';

    final lastResult = session.dailyRecords
        .where((record) => record.result != null)
        .last.result!;

    if (lastResult.severity == Severity.healthy) {
      return 'Healthy';
    } else if (lastResult.severity == Severity.mild) {
      return 'Improving';
    } else {
      return 'Needs attention';
    }
  }

  Future<void> _addScanForDay(int day) async {
    setState(() => _isLoading = true);

    try {
      final result = await Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => CropDetectionPage(isFromMonitoring: true),
        ),
      );

      if (result != null && result is ScanResult) {
        // Build updated records list
        var records = _session.dailyRecords.toList();
        final existingIndex = records.indexWhere((r) => r.day == day);

        final newRecord = DailyRecord(
          day: day,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: RecordStatus.stable,
          notes: '',
          result: result,
        );

        if (existingIndex >= 0) {
          // Update existing record
          records[existingIndex] = newRecord;
        } else {
          // Day didn't exist in list — add it
          records.add(newRecord);
          records.sort((a, b) => a.day.compareTo(b.day));
        }

        var updatedSession = _session.copyWith(
          dailyRecords: records,
          currentDay: day == _session.currentDay
              ? (day + 1).clamp(1, 7)
              : _session.currentDay,
        );

        await StorageService.saveMonitoring(updatedSession);

        setState(() {
          _session = updatedSession;
          // Also update _dayRecord so UI refreshes
          _dayRecord = newRecord;
        });
      }
    } catch (e) {
      // handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          '${_session.plantName} Assessment',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.black,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(),
            Expanded(child: _buildProfessionalTimeline()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Assessment sections at top
          Row(
            children: [
              Icon(
                CupertinoIcons.camera_viewfinder,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Analyze & Detect',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AI-powered plant health analysis with comprehensive treatment recommendations',
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Plant info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemGreen,
                      CupertinoColors.systemGreen.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  CupertinoIcons.leaf_arrow_circlepath,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _session.plantName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Started ${_formatDate(_session.startDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_getOverallStatus(_session)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(_getOverallStatus(_session)).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getOverallStatus(_session),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(_getOverallStatus(_session)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTimeline() {
    // Show only the selected day, not all 7 days
    final selectedDay = _dayRecord?.day ?? 1;
    
    // Find the correct record for the selected day
    DailyRecord record;
    try {
      record = _session.dailyRecords.firstWhere(
        (record) => record.day == selectedDay,
      );
    } catch (e) {
      // If no record exists for this day, create empty one
      record = DailyRecord(
        day: selectedDay,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: RecordStatus.stable,
        notes: 'Day $selectedDay assessment',
        result: null,
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildProfessionalDayCard(selectedDay, record),
    );
  }

  Widget _buildProfessionalDayCard(int day, DailyRecord record) {
    final isCompleted = record.result != null;

    // Use same 6 AM cycle logic as MonitoringPage
    final now = DateTime.now();
    final startDate = DateTime.fromMillisecondsSinceEpoch(_session.startDate);
    final sessionStartDay = DateTime(startDate.year, startDate.month, startDate.day, 6, 0, 0);
    final today6AM = DateTime(now.year, now.month, now.day, 6, 0, 0);

    int daysElapsed = 0;
    DateTime cycleDay = sessionStartDay;
    while (cycleDay.isBefore(today6AM)) {
      daysElapsed++;
      cycleDay = cycleDay.add(const Duration(days: 1));
    }

    final shouldBeEnabled = isCompleted || (daysElapsed + 1 >= day);
    final isCurrentDay = day == _session.currentDay;
    final isFutureDay = !shouldBeEnabled;

    // Different card layouts based on status
    if (isFutureDay) {
      // Smaller locked card
      return Container(
        margin: const EdgeInsets.only(bottom: 8), // Smaller margin
        child: Container(
          padding: const EdgeInsets.all(12), // Much smaller padding
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: CupertinoColors.systemGrey4.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Day $day',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                CupertinoIcons.lock,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
            ],
          ),
        ),
      );
    }

    // Full-size cards for completed and current days
    final cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isCompleted
              ? CupertinoColors.systemGreen.withOpacity(0.3)
              : isCurrentDay
                  ? CupertinoColors.systemBlue.withOpacity(0.3)
                  : CupertinoColors.systemGrey4.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? CupertinoColors.systemGreen.withOpacity(0.1)
                      : isCurrentDay
                          ? CupertinoColors.systemBlue.withOpacity(0.1)
                          : CupertinoColors.systemGrey4.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day $day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? CupertinoColors.systemGreen
                        : isCurrentDay
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.white,
                    size: 14,
                  ),
                )
              else if (isFutureDay)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    CupertinoIcons.lock,
                    color: CupertinoColors.systemGrey,
                    size: 14,
                  ),
                ),
            ],
          ),

          if (isCompleted) ...[
            const SizedBox(height: 16),

            // Plant image if available
            if (record.result!.imageUrl != null && record.result!.imageUrl!.isNotEmpty) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(record.result!.imageUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Diagnosis and severity
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.result!.diagnosis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: record.result!.severity == Severity.healthy
                          ? CupertinoColors.systemGreen
                          : record.result!.severity == Severity.mild
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      record.result!.severity.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isCurrentDay || (day == (_dayRecord?.day ?? 1) && !isCompleted)) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _isLoading ? null : () => _addScanForDay(day),
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'Add Today\'s Scan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Make completed cards clickable to show details
    if (isCompleted) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showProfessionalScanDetails(record.result!),
        child: cardContent,
      );
    }

    return cardContent;
  }

  void _showProfessionalScanDetails(ScanResult result) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'Scan Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              'Done',
              style: TextStyle(
                color: CupertinoColors.systemBlue,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: CupertinoColors.systemBackground,
          border: null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant image if available
                if (result.imageUrl != null && result.imageUrl!.isNotEmpty) ...[
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(result.imageUrl!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Diagnosis and severity in a clean card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.diagnosis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: result.severity == Severity.healthy
                              ? CupertinoColors.systemGreen
                              : result.severity == Severity.mild
                                  ? CupertinoColors.systemBlue
                                  : CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          result.severity.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Treatment recommendations in clean sections
                ValueListenableBuilder<String>(
                  valueListenable: LanguageService.currentLanguage,
                  builder: (context, lang, _) {
                    final treatmentData = _getTreatmentData(result.plantName, result.diagnosis, lang);
                    return Column(
                      children: [
                        _buildCleanDetailSection(
                          lang == 'tl' ? 'Pangkalahatan' : 'Overview', 
                          treatmentData['overview'], 
                          CupertinoColors.systemGreen
                        ),
                        _buildCleanDetailSection(
                          lang == 'tl' ? 'Payo' : 'Advice', 
                          treatmentData['advise'], 
                          CupertinoColors.systemBlue
                        ),
                        _buildCleanDetailSection(
                          lang == 'tl' ? 'Rekomendasyon' : 'Recommendation', 
                          treatmentData['recommendation'], 
                          CupertinoColors.systemPurple
                        ),
                      ],
                    );
                  },
                ),

                // Power tips if available
                if (result.powerTips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: ValueListenableBuilder<String>(
                      valueListenable: LanguageService.currentLanguage,
                      builder: (context, lang, _) {
                        final treatmentData = _getTreatmentData(result.plantName, result.diagnosis, lang);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'tl' ? 'Mga Power Tips' : 'Power Tips',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(treatmentData['tips'] as List<String>).map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.black,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getTreatmentData(String plant, String diagnosis, String lang) {
    if (lang == 'tl') {
      return {
        'overview': 'Ito ay isang pagsusuri ng kalagayan ng halaman base sa larawan na kinuha.',
        'advise': 'Regular na obserbahan ang halaman at siguraduhing sapat ang tubig at sikat ng araw.',
        'recommendation': 'Tanggalin ang mga apektadong dahon at gumamit ng tamang pest o disease control kung kinakailangan.',
        'tips': [
          'Panatilihing malinis ang paligid ng halaman.',
          'Siguraduhing may sapat na tubig ang lupa.',
          'Regular na suriin ang halaman para sa mga sintomas ng sakit.'
        ]
      };
    } else {
      return {
        'overview': 'This is an analysis of the plant condition based on the captured image.',
        'advise': 'Regularly observe the plant and ensure it receives enough water and sunlight.',
        'recommendation': 'Remove affected leaves and apply appropriate pest or disease control if necessary.',
        'tips': [
          'Keep the plant area clean.',
          'Ensure proper watering of the soil.',
          'Regularly inspect the plant for disease symptoms.'
        ]
      };
    }
  }

  Widget _buildCleanDetailSection(String title, String content, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.black,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentDescription() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'About 7-Day Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The 7-day plant health assessment is a comprehensive monitoring program designed to track your plant\'s recovery progress over time. By taking daily photos and analyzing changes, you can observe treatment effectiveness, identify improvement trends, and ensure complete recovery from diseases or stress conditions.',
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Regular monitoring helps prevent disease recurrence and provides valuable data for optimizing your plant care routine. The assessment creates a visual timeline of your plant\'s health journey.',
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.systemGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Healthy':
        return CupertinoColors.systemGreen;
      case 'Improving':
        return CupertinoColors.systemBlue;
      case 'Needs attention':
        return CupertinoColors.systemOrange;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}