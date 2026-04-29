import 'package:flutter/cupertino.dart';
import '../models/scan_result.dart';

class ScanResultWidget extends StatelessWidget {
  final ScanResult result;
  final bool showActions;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleArchive;

  const ScanResultWidget({
    super.key,
    required this.result,
    this.showActions = false,
    this.onDelete,
    this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with plant name and severity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.plantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        result.diagnosis,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(result.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(result.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Confidence and Status Row
            Row(
              children: [
                Text(
                  'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getConfidenceColor(result.severity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Status: ${result.severity.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _getSeverityColor(result.severity),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Date
            Text(
              _formatDate(result.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            
            if (result.stressFactor != null) ...[
              const SizedBox(height: 8),
              Text(
                'Stress Factor: ${result.stressFactor}',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.label,
                ),
              ),
            ],
            
            // Overview/Prevention
            if (result.prevention.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Overview',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                result.prevention,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.label,
                ),
              ),
            ],
            
            // Treatment Recommendations
            if (result.organicTreatment.isNotEmpty || result.chemicalTreatment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Recommendations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 4),
              if (result.organicTreatment.isNotEmpty) ...[
                Text(
                  'Organic: ${result.organicTreatment}',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (result.chemicalTreatment.isNotEmpty) ...[
                Text(
                  'Chemical: ${result.chemicalTreatment}',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
            
            // Tips/Advice
            if (result.powerTips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Advice',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 4),
              ...result.powerTips.take(2).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],

            if (showActions) ...[
              const SizedBox(height: 12),
              if (onDelete != null && onToggleArchive != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Text(
                        'Restore',
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: onToggleArchive,
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                )
              else if (onDelete != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 32,
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.destructiveRed,
                      size: 22,
                    ),
                    onPressed: onDelete,
                  ),
                ),
            ],
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

  Color _getConfidenceColor(Severity severity) {
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

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
