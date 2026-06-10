import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/database/mdd_query.dart';

class FamilyBarChart extends StatelessWidget {
  final MddStatistics stats;

  const FamilyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.speciesPerFamily.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesPerFamilyResult> data = stats.speciesPerFamily.take(15).toList();
    double maxY = data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    final textColor = Theme.of(context).colorScheme.onSurface;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final xAxisLabel = data[group.x.toInt()].name ?? '';
              return BarTooltipItem(
                '$xAxisLabel\n',
                const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                
                String text = data[index].name ?? '';
                if (text.length > 11) text = '${text.substring(0, 9)}...';

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -1.0,
                    child: Text(text, style: TextStyle(fontSize: 10, color: textColor)),
                  ),
                );
              },
              reservedSize: 80,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.count.toDouble(),
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
