import 'package:flutter/cupertino.dart';
import '../models/user_stats.dart';

class StatsOverviewWidget extends StatelessWidget {
  final UserStats stats;

  const StatsOverviewWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 20),
          
          // Level Progress
          _buildProgressRow(
            title: 'Level ${stats.level}',
            subtitle: '${stats.xp} / ${stats.nextLevelXp} XP',
            progress: stats.xpProgress,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Scans',
                  value: '${stats.scansCount}',
                  icon: CupertinoIcons.camera,
                  color: CupertinoColors.systemGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  title: 'Sessions',
                  value: '${stats.sessionsCount}',
                  icon: CupertinoIcons.tree,
                  color: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          
          if (stats.lastAction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last action: ${stats.lastAction}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
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
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
