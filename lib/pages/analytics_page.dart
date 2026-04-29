import 'package:flutter/cupertino.dart';
import '../services/storage_service.dart';
import '../models/scan_result.dart';
import '../widgets/analytics_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<ScanResult> _scans = [];
  List<MonitoringSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Analytics Debug: initState called - registering listeners');
    _loadData();
    
    // Listen for real-time updates when scans or monitoring sessions are saved
    print('Analytics Debug: Adding scansUpdated listener');
    StorageService.scansUpdated.addListener(_onStorageUpdate);
    print('Analytics Debug: Adding monitoringUpdated listener');
    StorageService.monitoringUpdated.addListener(_onStorageUpdate);
    print('Analytics Debug: Listeners registered successfully');
  }

  @override
  void dispose() {
    print('Analytics Debug: dispose called - removing listeners');
    // Remove listeners to prevent memory leaks
    StorageService.scansUpdated.removeListener(_onStorageUpdate);
    print('Analytics Debug: Removed scansUpdated listener');
    StorageService.monitoringUpdated.removeListener(_onStorageUpdate);
    print('Analytics Debug: Removed monitoringUpdated listener');
    super.dispose();
  }

  void _onStorageUpdate() {
    print('Analytics Debug: Storage update triggered - checking if mounted...');
    print('Analytics Debug: mounted = $mounted');
    if (mounted) {
      print('Analytics Debug: Calling _loadData()...');
      _loadData();
    } else {
      print('Analytics Debug: Widget not mounted, skipping refresh');
    }
  }

  Future<void> _loadData() async {
    print('Analytics Debug: Starting _loadData()...');
    try {
      final allScans = await StorageService.getScans();
      final allSessions = await StorageService.getMonitoring();

      // Filter out archived items for analytics (only show active items)
      final scans = allScans.where((s) => !s.archived).toList();
      final sessions = allSessions.where((s) => s.status != SessionStatus.archived).toList();

      // Debug logging
      final totalScans = scans.length;
      final totalSessions = sessions.length;
      final activeSessions = sessions.where((s) => s.status == SessionStatus.active).length;

      print('Analytics Debug:');
      print('- Total scans: $totalScans');
      print('- Total sessions: $totalSessions');
      print('- Active sessions: $activeSessions');

      print('Analytics Debug: Calling setState...');
      setState(() {
        _scans = scans;
        _sessions = sessions;
        _isLoading = false;
      });
      print('Analytics Debug: setState completed successfully');

    } catch (e) {
      print('Analytics Debug: Load error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Farm Analytics',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.white,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ),
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
          Text('Loading analytics...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time insights from your plant data',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 24),

          // Analytics Cards
          _buildAnalyticsGrid(),
          const SizedBox(height: 24),

          // Charts Section
          _buildChartsSection(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(child: _buildAnalyticsCard('Total Scans', '${_scans.length + _sessions.length}', CupertinoIcons.photo, CupertinoColors.systemBlue)),
            const SizedBox(width: 12),
            Expanded(child: _buildAnalyticsCard('Active Sessions', '${_sessions.where((s) => s.status == SessionStatus.active).length}', CupertinoIcons.chart_bar_alt_fill, CupertinoColors.systemGreen)),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2
        Row(
          children: [
            Expanded(child: _buildAnalyticsCard('Healthy Plants', '${_scans.where((s) => s.severity == Severity.healthy).length}', CupertinoIcons.heart_fill, CupertinoColors.systemGreen)),
            const SizedBox(width: 12),
            Expanded(child: _buildAnalyticsCard('Need Attention', '${_scans.where((s) => s.severity == Severity.severe || s.severity == Severity.moderate).length}', CupertinoIcons.exclamationmark_triangle_fill, CupertinoColors.systemOrange)),
          ],
        ),
        const SizedBox(height: 12),
        // Row 3
        Row(
          children: [
            Expanded(child: _buildAnalyticsCard('Avg Confidence', '${_getAverageConfidence().toStringAsFixed(1)}%', CupertinoIcons.checkmark_circle, CupertinoColors.systemPurple)),
            const SizedBox(width: 12),
            Expanded(child: _buildAnalyticsCard('Most Common', _getMostCommonPlant(), CupertinoIcons.tree, CupertinoColors.systemTeal)),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Visualization',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 16),
        
        // Severity Distribution Chart
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
              const Text(
                'Plant Health Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: AnalyticsChart(data: {"items": _getSeverityData()}),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Recent Activity
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
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final recentScans = _scans.take(5).toList();
    
    if (recentScans.isEmpty) {
      return const Text(
        'No recent activity',
        style: TextStyle(
          fontSize: 14,
          color: CupertinoColors.secondaryLabel,
        ),
      );
    }
    
    return Column(
      children: recentScans.map((scan) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getSeverityColor(scan.severity),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.plantName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.label,
                      ),
                    ),
                    Text(
                      scan.diagnosis,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(scan.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _getAverageConfidence() {
    if (_scans.isEmpty) return 0.0;
    final totalConfidence = _scans.fold<double>(0.0, (sum, scan) => sum + scan.confidence);
    return (totalConfidence / _scans.length) * 100;
  }

  String _getMostCommonPlant() {
    if (_scans.isEmpty) return 'None';
    
    final plantCounts = <String, int>{};
    for (final scan in _scans) {
      plantCounts[scan.plantName] = (plantCounts[scan.plantName] ?? 0) + 1;
    }
    
    if (plantCounts.isEmpty) return 'None';
    
    final mostCommon = plantCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostCommon.key;
  }

  List<Map<String, dynamic>> _getSeverityData() {
    final severityCounts = <String, int>{
      'Healthy': _scans.where((s) => s.severity == Severity.healthy).length,
      'Mild': _scans.where((s) => s.severity == Severity.mild).length,
      'Moderate': _scans.where((s) => s.severity == Severity.moderate).length,
      'Severe': _scans.where((s) => s.severity == Severity.severe).length,
    };
    
    return severityCounts.entries.map((entry) => {
      'label': entry.key,
      'value': entry.value.toDouble(),
      'color': _getSeverityColorString(entry.key),
    }).toList();
  }

  Color _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.healthy:
        return CupertinoColors.systemGreen;
      case Severity.mild:
        return CupertinoColors.systemYellow;
      case Severity.moderate:
        return CupertinoColors.systemOrange;
      case Severity.severe:
        return CupertinoColors.systemRed;
    }
  }

  String _getSeverityColorString(String severity) {
    switch (severity) {
      case 'Healthy':
        return '#34C759';
      case 'Mild':
        return '#FFCC00';
      case 'Moderate':
        return '#FF9500';
      case 'Severe':
        return '#FF3B30';
      default:
        return '#8E8E93';
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
