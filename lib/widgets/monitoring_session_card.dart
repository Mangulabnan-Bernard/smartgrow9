import 'package:flutter/cupertino.dart';
import '../models/scan_result.dart';

class MonitoringSessionCard extends StatelessWidget {
  final MonitoringSession session;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const MonitoringSessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with plant name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.plantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(session.status),
                    ],
                  ),
                ),
                _buildProgressIndicator(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Info
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
                const SizedBox(width: 8),
                Text(
                  'Day ${session.currentDay} of 7',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(session.currentDay / 7 * 100).toInt()}% Complete',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: session.currentDay / 7.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getStatusColor(session.status),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: onTap,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.eye,
                          color: CupertinoColors.systemBlue,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: CupertinoColors.systemBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CupertinoButton(
                  onPressed: onArchive,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.archivebox,
                    color: CupertinoColors.systemOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  onPressed: onDelete,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.systemRed,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SessionStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case SessionStatus.active:
        backgroundColor = CupertinoColors.systemGreen.withValues(alpha: 0.1);
        textColor = CupertinoColors.systemGreen;
        text = 'Active';
        break;
      case SessionStatus.recovered:
        backgroundColor = CupertinoColors.systemBlue.withValues(alpha: 0.1);
        textColor = CupertinoColors.systemBlue;
        text = 'Recovered';
        break;
      case SessionStatus.archived:
        backgroundColor = CupertinoColors.systemGrey.withValues(alpha: 0.1);
        textColor = CupertinoColors.systemGrey;
        text = 'Archived';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getStatusColor(session.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(session.status),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${session.currentDay}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getStatusColor(session.status),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return CupertinoColors.systemGreen;
      case SessionStatus.recovered:
        return CupertinoColors.systemBlue;
      case SessionStatus.archived:
        return CupertinoColors.systemGrey;
    }
  }
}
