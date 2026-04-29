import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const AnalyticsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Safely extract items list
    final List<dynamic> itemsList = data['items'] ?? [];
    final List<Map<String, dynamic>> items = itemsList.cast<Map<String, dynamic>>();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      );
    }

    return Container(
      color: CupertinoColors.white,
      child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        // Ensure maxY is a double
        maxY: items.isNotEmpty
            ? items.map((item) => (item['value'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2
            : 100.0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => CupertinoColors.black,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = items[group.x.toInt()];
              return BarTooltipItem(
                '${item['label']}: ${item['value']}',
                const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= items.length) {
                  return const SizedBox.shrink();
                }
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item['label'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          Color barColor;
          try {
            barColor = Color(int.parse(item['color'].toString().replaceFirst('#', '0xFF')));
          } catch (e) {
            // Fallback to a professional emerald/teal shade
            barColor = const Color(0xFF10B981);
          }

          return BarChartGroupData(
            x: index, // Fixed: x expects an int in most fl_chart configurations
            barRods: [
              BarChartRodData(
                toY: (item['value'] as num).toDouble(), // Fixed: toY must be a double
                color: barColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
      ),
    );
  }
}