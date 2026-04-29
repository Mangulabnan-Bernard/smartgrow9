import 'package:flutter/cupertino.dart';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import '../services/language_service.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  List<ScanResult> _archivedScans = [];
  List<MonitoringSession> _archivedSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArchivedItems();

    // Listen for storage updates
    StorageService.monitoringUpdated.addListener(_onStorageUpdate);
    StorageService.scansUpdated.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    StorageService.monitoringUpdated.removeListener(_onStorageUpdate);
    StorageService.scansUpdated.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    if (mounted) {
      _loadArchivedItems();
    }
  }

  Future<void> _loadArchivedItems() async {
    try {
      final scans = await StorageService.getScans();
      final sessions = await StorageService.getMonitoring();

      if (mounted) {
        setState(() {
          _archivedScans = scans.where((s) => s.archived).toList();
          _archivedSessions = sessions.where((s) => s.status == SessionStatus.archived).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper to handle the logic of the dialogs and actions
  Future<void> _handleAction(String id, bool isScan, bool isDelete, String lang) async {
    String title;
    String content;
    String confirmText;
    String cancelText = lang == 'tl' ? 'Hindi' : 'No';

    if (isDelete) {
      title = lang == 'tl' ? 'Burahin Permanenteng?' : 'Delete Permanently?';
      content = lang == 'tl'
          ? 'Sigurado ka ba na burahin permanenteng ito? Hindi na ito mababawi.'
          : 'Are you sure? This action cannot be undone.';
      confirmText = lang == 'tl' ? 'Oo, Burahin' : 'Yes, Delete';
    } else {
      title = lang == 'tl' ? 'Ibalik?' : 'Restore?';
      content = lang == 'tl'
          ? 'Ibabalik ang item na ito sa iyong aktibong listahan.'
          : 'This item will be restored to your active list.';
      confirmText = lang == 'tl' ? 'Oo, Ibalik' : 'Yes, Restore';
    }

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(child: Text(cancelText), onPressed: () => Navigator.pop(context, false)),
          CupertinoDialogAction(
            isDestructiveAction: isDelete,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (result == true) {
      if (isScan) {
        isDelete ? await StorageService.deleteScan(id) : await StorageService.toggleArchiveScan(id);
      } else {
        isDelete ? await StorageService.deleteMonitoring(id) : await StorageService.restoreMonitoring(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, lang, _) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            backgroundColor: CupertinoColors.systemBackground,
            middle: Text(lang == 'tl' ? 'Archive' : 'Archive'),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : _archivedScans.isEmpty && _archivedSessions.isEmpty
                ? _buildEmptyState(lang)
                : _buildArchiveList(lang),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.archivebox, size: 60, color: CupertinoColors.systemGrey4),
          const SizedBox(height: 16),
          Text(lang == 'tl' ? 'Walang Archived na Item' : 'No Archived Items'),
        ],
      ),
    );
  }

  Widget _buildArchiveList(String lang) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _archivedScans.length + _archivedSessions.length,
      itemBuilder: (context, index) {
        if (index < _archivedScans.length) {
          return _buildScanItem(_archivedScans[index], lang);
        } else {
          return _buildSessionItem(_archivedSessions[index - _archivedScans.length], lang);
        }
      },
    );
  }

  Widget _buildScanItem(ScanResult scan, String lang) {
    return _buildBaseItem(
      title: scan.plantName,
      subtitle: _formatDate(scan.timestamp),
      icon: _getSeverityIcon(scan.severity),
      iconColor: _getSeverityColor(scan.severity),
      lang: lang,
      onRestore: () => _handleAction(scan.id, true, false, lang),
      onDelete: () => _handleAction(scan.id, true, true, lang),
    );
  }

  Widget _buildSessionItem(MonitoringSession session, String lang) {
    return _buildBaseItem(
      title: session.plantName,
      subtitle: '${lang == 'tl' ? 'Araw' : 'Day'} ${session.currentDay}',
      icon: CupertinoIcons.calendar,
      iconColor: CupertinoColors.systemBlue,
      lang: lang,
      onRestore: () => _handleAction(session.id, false, false, lang),
      onDelete: () => _handleAction(session.id, false, true, lang),
    );
  }

  Widget _buildBaseItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String lang,
    required VoidCallback onRestore,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey6),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
              ],
            ),
          ),
          CupertinoButton(padding: EdgeInsets.zero, onPressed: onRestore, child: const Icon(CupertinoIcons.refresh_thick, size: 20)),
          CupertinoButton(padding: EdgeInsets.zero, onPressed: onDelete, child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20)),
        ],
      ),
    );
  }

  // ... (Include your helper methods _getSeverityColor, _getSeverityIcon, _formatDate)
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

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}