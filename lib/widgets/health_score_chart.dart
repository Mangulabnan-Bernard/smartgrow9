import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScoreChart extends StatelessWidget {
  final Map<String, int> data;

  const HealthScoreChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = data.entries.where((e) => e.value > 0).toList();
    
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 14,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = _getColorForSeverity(item.key);
          
          return PieChartSectionData(
            color: color,
            value: item.value.toDouble(),
            title: '${item.value}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        centerSpaceColor: CupertinoColors.systemBackground,
      ),
    );
  }

  Color _getColorForSeverity(String severity) {
    switch (severity) {
      case 'Healthy':
        return CupertinoColors.systemGreen;
      case 'Mild':
        return CupertinoColors.systemYellow;
      case 'Moderate':
        return CupertinoColors.systemOrange;
      case 'Severe':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}
