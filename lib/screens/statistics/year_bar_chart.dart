import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/database/mdd_query.dart';

class YearBarChart extends StatelessWidget {
  final MddStatistics stats;

  const YearBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.discoveryYear.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesByDiscoveryYearResult> data = stats.discoveryYear;
    double maxY =
        data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    final textColor = Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = data.length * (16.0 + 10.0) + 50.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: requiredWidth > constraints.maxWidth
                ? requiredWidth
                : constraints.maxWidth,
            alignment: Alignment.center,
            child: SizedBox(
              width: requiredWidth,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  groupsSpace: 10,
                  maxY: maxY * 1.1,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blueGrey.shade800,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final xAxisLabel =
                            '${data[group.x.toInt()].year?.toInt() ?? 0}';
                        return BarTooltipItem(
                          '$xAxisLabel\n',
                          const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
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
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -1.0,
                              child: Text('${data[index].year?.toInt() ?? 0}',
                                  style: TextStyle(
                                      fontSize: 10, color: textColor)),
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
                              style: TextStyle(fontSize: 10, color: textColor),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.count.toDouble(),
                          color: Colors.deepPurpleAccent,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
