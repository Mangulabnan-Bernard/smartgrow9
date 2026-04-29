import 'package:flutter/cupertino.dart';
import '../services/storage_service.dart';
import '../models/user_stats.dart';
import '../models/scan_result.dart';
import '../widgets/stats_card.dart';
import '../widgets/health_score_chart.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/farmer_tips_widget.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback? onScanNow;
  final VoidCallback? onViewHistory;
  final VoidCallback? onOpenAnalytics;

  const DashboardPage({
    super.key,
    this.onScanNow,
    this.onViewHistory,
    this.onOpenAnalytics,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserStats? _userStats;
  List<ScanResult> _scans = [];
  List<MonitoringSession> _sessions = [];
  UserProfile? _userProfile;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();

    StorageService.scansUpdated.addListener(_onStorageUpdate);
    StorageService.monitoringUpdated.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    StorageService.scansUpdated.removeListener(_onStorageUpdate);
    StorageService.monitoringUpdated.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        _userProfile = await AuthService.getUserProfile(currentUser.uid);
      }

      final stats = await StorageService.getUserStats();
      final allScans = await StorageService.getScans();
      final allSessions = await StorageService.getMonitoring();

      final scans = allScans.where((s) => !s.archived).toList();
      final sessions =
      allSessions.where((s) => s.status != SessionStatus.archived).toList();

      if (mounted) {
        setState(() {
          _userStats = stats;
          _scans = scans;
          _sessions = sessions;
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  double get _healthScore {
    if (_scans.isEmpty) return 0.0;
    final healthyCount =
        _scans.where((s) => s.severity == Severity.healthy).length;
    return (healthyCount / _scans.length) * 100;
  }

  ScanResult? get _lastScan => _scans.isNotEmpty ? _scans.first : null;

  Map<String, int> get _severityData {
    final counts = {
      'Healthy': 0,
      'Mild': 0,
      'Moderate': 0,
      'Severe': 0,
    };

    for (final scan in _scans) {
      counts[scan.severity.displayName] =
          (counts[scan.severity.displayName] ?? 0) + 1;
    }

    return counts;
  }

  Color _getHealthScoreColor() {
    if (_healthScore >= 70) return ThemeService().currentColor;
    if (_healthScore >= 40) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  String _getRecentActivity() {
    if (_lastScan != null) {
      final time = DateTime.fromMillisecondsSinceEpoch(_lastScan!.timestamp);
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final timeStr = '$displayHour:${minute.toString().padLeft(2, '0')}$period';
      return '${_lastScan!.plantName}|$timeStr';
    }

    if (_sessions.isNotEmpty) {
      final latestSession =
      _sessions.reduce((a, b) => a.startDate > b.startDate ? a : b);
      return 'Added ${latestSession.plantName}| ';
    }

    return 'No recent activity| ';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          const FarmerTipsWidget(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildHealthScoreSection(),
          const SizedBox(height: 24),
          QuickActionsWidget(
            onScanNow: widget.onScanNow ?? () {},
            onViewHistory: widget.onViewHistory ?? () {},
            onOpenAnalytics: widget.onOpenAnalytics ?? () {},
          ),
          const SizedBox(height: 24),
          if (_lastScan != null) _buildLastScanSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeService().currentColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 35,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${_userProfile?.name ?? _userStats?.username ?? LanguageService.translate("farmer")}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _userStats?.xpProgress ?? 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.translate('your_garden_stats'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // First row: Total Scans and Track
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: LanguageService.translate('total_scans'),
                    value: _isDataLoaded ? '${_scans.length + _sessions.length}' : null,
                    icon: CupertinoIcons.camera,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: LanguageService.translate('track'),
                    value: _isDataLoaded
                        ? '${_sessions.where((s) => s.status == SessionStatus.active).length}'
                        : null,
                    icon: CupertinoIcons.tree,
                    color: ThemeService().currentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Second row: Health Score and Recent Activity
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: LanguageService.translate('health_score'),
                    value: _isDataLoaded ? '${_healthScore.toInt()}%' : null,
                    icon: CupertinoIcons.heart_fill,
                    color: _getHealthScoreColor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Recent Activity',
                    value: _isDataLoaded ? _getRecentActivityDisplay() : null,
                    icon: CupertinoIcons.clock_fill,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getRecentActivityDisplay() {
    if (_lastScan != null) {
      final time = DateTime.fromMillisecondsSinceEpoch(_lastScan!.timestamp);
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')}$period';
    }

    if (_sessions.isNotEmpty) {
      final latestSession =
      _sessions.reduce((a, b) => a.startDate > b.startDate ? a : b);
      return 'Added';
    }

    return 'None';
  }

  Widget _buildHealthScoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 200,
        child: _scans.isNotEmpty
            ? HealthScoreChart(data: _severityData)
            : const Center(
          child: Text(
            'No scans yet\nStart scanning to see your health data',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLastScanSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(_lastScan!.plantName),
    );
  }
}