import 'package:flutter/cupertino.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            )
          else
            const CupertinoActivityIndicator(
              radius: 12,
              color: CupertinoColors.systemGrey,
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
