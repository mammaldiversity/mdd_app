import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/database/mdd_query.dart';

class DecadeBarChart extends StatelessWidget {
  final MddStatistics stats;

  const DecadeBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.discoveryDecade.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesByDiscoveryDecadeResult> data = stats.discoveryDecade;
    double maxY = data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final xAxisLabel = '${data[group.x.toInt()].decade?.toInt() ?? 0}s';
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
                if (index % 2 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text('${data[index].decade?.toInt() ?? 0}s', style: const TextStyle(fontSize: 10)),
                  ),
                );
              },
              reservedSize: 40,
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
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
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
                color: Colors.orangeAccent,
                width: 8,
                borderRadius: BorderRadius.circular(2),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
