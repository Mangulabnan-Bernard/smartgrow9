import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import '../widgets/scan_result_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin {
  List<ScanResult> _scans = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadScans();

    // Listen for storage updates to refresh when scans are saved/archived
    StorageService.scansUpdated.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    // Remove listeners when page is destroyed to prevent memory leaks
    StorageService.scansUpdated.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    if (mounted) {
      _loadScans();
    }
  }

  @override
  void didUpdateWidget(HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data when returning to this tab
    _loadScans();
  }

  Future<void> _loadScans() async {
    try {
      final scans = await StorageService.getScans();
      // Reverse order to show newest scans first
      final reversedScans = scans.where((s) => !s.archived).toList().reversed.toList();
      setState(() {
        _scans = reversedScans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteScan(String id) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record? It will be moved to archive in settings.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await StorageService.toggleArchiveScan(id); // Archive instead of delete
        _loadScans();
      } catch (e) {
        _showErrorDialog('Failed to archive scan');
      }
    }
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
  Widget build(BuildContext context) {
    super.build(context);
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
          Text('Loading history...', style: TextStyle(fontSize: 16)),
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
          ),
          _scans.isEmpty
              ? _buildEmptyState()
              : _buildScansList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CupertinoColors.systemGrey4, style: BorderStyle.solid),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No botanical history recorded yet.',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScansList() {
    return Column(
      children: _scans.map((scan) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildCompactScanItem(scan),
        );
      }).toList(),
    );
  }

  Widget _buildCompactScanItem(ScanResult scan) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showScanDetails(scan),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          children: [
            // Scan image thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: CupertinoColors.systemGrey6,
              ),
              child: scan.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(scan.imageUrl!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getSeverityColor(scan.severity).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getSeverityIcon(scan.severity),
                              color: _getSeverityColor(scan.severity),
                              size: 24,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: _getSeverityColor(scan.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSeverityIcon(scan.severity),
                        color: _getSeverityColor(scan.severity),
                        size: 24,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.plantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scan.diagnosis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),

            // Right side info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(scan.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getSeverityColor(scan.severity),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(scan.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey3,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showScanDetails(ScanResult scan) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Scan Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ScanResultWidget(
                  result: scan,
                  showActions: true,
                  onDelete: () {
                    Navigator.of(context).pop();
                    _deleteScan(scan.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  IconData _getSeverityIcon(Severity severity) {
    switch (severity) {
      case Severity.healthy:
        return CupertinoIcons.heart_fill;
      case Severity.mild:
        return CupertinoIcons.exclamationmark_triangle;
      case Severity.moderate:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case Severity.severe:
        return CupertinoIcons.xmark_circle_fill;
    }
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
