import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/database/mdd_query.dart';

class OrderBarChart extends StatelessWidget {
  final MddStatistics stats;

  const OrderBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.speciesPerOrder.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesPerOrderResult> data =
        stats.speciesPerOrder.take(10).toList();
    double maxY =
        data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

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
                '$xAxisLabel\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(data[index].name ?? '',
                        style: const TextStyle(fontSize: 10)),
                  ),
                );
              },
              reservedSize: 60,
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value.count).toDouble(),
                color: Colors.deepPurpleAccent,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
