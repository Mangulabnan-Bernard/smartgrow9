import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import '../services/language_service.dart';
import 'assessment_detail_page.dart';

class MonitoringPage extends StatefulWidget {
  final VoidCallback? onStartScan;

  const MonitoringPage({super.key, this.onStartScan});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> with WidgetsBindingObserver {
  List<MonitoringSession> _sessions = [];
  List<AppAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    StorageService.monitoringUpdated.addListener(_loadData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StorageService.monitoringUpdated.removeListener(_loadData);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData(); // Refresh when app comes to foreground
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData(); // Refresh when page becomes visible
  }

  Future<void> _loadData() async {
    try {
      final sessions = await StorageService.getMonitoring();
      final alerts = await StorageService.getAlerts();

      setState(() {
        _sessions = sessions.where((s) => s.status != SessionStatus.archived).toList();
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- Helper Methods (Defined before use to avoid reference errors) ---

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    // Only show "Today" or "Yesterday" for very recent dates within the same day
    // For sessions started on previous dates, always show the actual date
    if (difference.inDays == 0 && date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    }
    if (difference.inDays == 1 && date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      return 'Yesterday';
    }
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.healthy: return CupertinoColors.systemGreen;
      case Severity.mild: return CupertinoColors.systemYellow;
      case Severity.moderate: return CupertinoColors.systemOrange;
      case Severity.severe: return CupertinoColors.systemRed;
    }
  }

  IconData _getSeverityIcon(Severity severity) {
    switch (severity) {
      case Severity.healthy: return CupertinoIcons.heart_fill;
      case Severity.mild: return CupertinoIcons.exclamationmark_triangle;
      case Severity.moderate: return CupertinoIcons.exclamationmark_triangle_fill;
      case Severity.severe: return CupertinoIcons.xmark_circle_fill;
    }
  }

  Widget _getLatestScanImage(MonitoringSession session) {
    final completedRecords = session.dailyRecords
        .where((record) => record.result != null && record.result!.imageUrl != null)
        .toList();

    if (completedRecords.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          CupertinoIcons.camera,
          color: CupertinoColors.systemGrey3,
          size: 24,
        ),
      );
    }

    final latestScan = completedRecords.last.result!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(latestScan.imageUrl!),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: _getSeverityColor(latestScan.severity).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSeverityIcon(latestScan.severity),
              color: _getSeverityColor(latestScan.severity),
              size: 24,
            ),
          );
        },
      ),
    );
  }

  void _showDayDetails(MonitoringSession session, int selectedDay) {
    final dayRecord = session.dailyRecords.firstWhere(
          (record) => record.day == selectedDay,
      orElse: () => DailyRecord(
        day: selectedDay,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: RecordStatus.stable,
        notes: '',
      ),
    );

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => AssessmentDetailPage(
          session: session,
          dayRecord: dayRecord,
        ),
      ),
    );
  }

  // --- Logic Methods ---

  Future<void> _deleteSession(MonitoringSession session) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Session?'),
        content: const Text('Are you sure you want to delete this session? It will be moved to archive in settings.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await StorageService.archiveMonitoring(session.id);
        _loadData();
        await _checkAndShowFirstCompletion();
      } catch (e) {
        _showToast('Failed to archive session');
      }
    }
  }

  Future<void> _checkAndShowFirstCompletion() async {
    final sessions = await StorageService.getMonitoring();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.recovered).length;

    if (completedSessions == 1) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showFirstCompletionModal();
      }
    }
  }

  void _showFirstCompletionModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '🎉 Congratulations!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 80,
                      color: CupertinoColors.systemYellow,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'First 7-Day Monitoring Complete!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You\'ve successfully completed your first plant health monitoring session! This shows your dedication to plant care.',
                      style: TextStyle(fontSize: 16, color: CupertinoColors.secondaryLabel, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CupertinoColors.systemGreen.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎁 Bonus Reward',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.systemGreen),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '200 XP awarded for completing your first monitoring session!',
                            style: TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildNotificationPanel(),
    );
  }

  void _showToast(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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

  // --- UI Building Methods ---

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: _isLoading ? _buildLoading() : _buildContent(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 20),
          SizedBox(height: 16),
          Text('Loading tracking sessions...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: CupertinoColors.systemBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check Your Plants', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('7-Day Recovery Checks', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
                ],
              ),
              CupertinoButton(
                onPressed: _showNotifications,
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    const Icon(CupertinoIcons.bell, color: CupertinoColors.systemBlue, size: 24),
                    if (_alerts.isNotEmpty)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: CupertinoColors.systemRed, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _sessions.isEmpty ? _buildEmptyState() : _buildSessionsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, currentLang, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.tree, size: 80, color: CupertinoColors.systemGrey3),
                const SizedBox(height: 24),
                Text(
                  currentLang == 'tl' ? 'Walang Aktibong Pagsusuri' : 'No Active Tracking',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  currentLang == 'tl'
                      ? 'Simulan ang plant health scan upang magsimula ang pagsusuri sa progreso.'
                      : 'Start a plant health scan to begin tracking recovery progress.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: widget.onStartScan,
                  child: Text(currentLang == 'tl' ? 'Simulan ang Unang Scan' : 'Start First Scan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildDayByDayTracking(_sessions[index]),
      ),
    );
  }

  Widget _buildDayByDayTracking(MonitoringSession session) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4))),
            child: Row(
              children: [
                _getLatestScanImage(session),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.plantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Started ${_formatDate(DateTime.fromMillisecondsSinceEpoch(session.startDate))}',
                          style: const TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel)),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () => _deleteSession(session),
                  child: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final dayRecord = session.dailyRecords.firstWhere(
                      (r) => r.day == dayNum,
                  orElse: () => DailyRecord(day: dayNum, timestamp: 0, status: RecordStatus.stable, notes: ''),
                );
                final isCompleted = dayRecord.result != null;
                final isCurrent = session.currentDay == dayNum;
                
                // Calculate days elapsed since session started
                final now = DateTime.now();
                final startDate = DateTime.fromMillisecondsSinceEpoch(session.startDate);
                
                // Simple calculation: count full days since session start
                // Each new day starts at 6 AM
                final sessionStartDay = DateTime(startDate.year, startDate.month, startDate.day, 6, 0, 0);
                final today6AM = DateTime(now.year, now.month, now.day, 6, 0, 0);
                
                // Calculate how many full 6 AM cycles have passed
                int daysElapsed = 0;
                DateTime currentDay = sessionStartDay;
                
                while (currentDay.isBefore(today6AM)) {
                  daysElapsed++;
                  currentDay = currentDay.add(const Duration(days: 1));
                }
                
                // Alternative simpler logic:
                // - Day is enabled if it's completed
                // - Day is enabled if it's the current day (regardless of time)
                // - Day is enabled if enough time has passed (daysElapsed + 1 >= dayNum)
                final shouldBeEnabled = isCompleted || 
                                     isCurrent || 
                                     (daysElapsed + 1 >= dayNum);
                
                final isDisabled = !shouldBeEnabled;

                return Expanded(
                  child: GestureDetector(
                    onTap: isDisabled ? null : () => _showDayDetails(session, dayNum),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDisabled ? CupertinoColors.systemGrey6 : isCompleted ? CupertinoColors.systemGreen.withValues(alpha: 0.1) : isCurrent ? CupertinoColors.systemBlue.withValues(alpha: 0.1) : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent ? Border.all(color: CupertinoColors.systemBlue) : null,
                      ),
                      child: Column(
                        children: [
                          Text('D$dayNum', style: const TextStyle(fontSize: 10)),
                          const SizedBox(height: 4),
                          Icon(
                            isCompleted ? CupertinoIcons.checkmark_alt : isCurrent ? CupertinoIcons.camera : isDisabled ? CupertinoIcons.lock : CupertinoIcons.minus,
                            size: 14,
                            color: isDisabled ? CupertinoColors.systemGrey3 : isCompleted ? CupertinoColors.systemGreen : isCurrent ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPanel() {
    return Container(
      height: 500,
      decoration: const BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(context), child: const Icon(CupertinoIcons.xmark)),
              ],
            ),
          ),
          Expanded(
            child: _alerts.isEmpty
                ? const Center(child: Text('No notifications'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _alerts.length,
              itemBuilder: (context, index) => _buildNotificationItem(_alerts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(alert.message, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
        ],
      ),
    );
  }
}