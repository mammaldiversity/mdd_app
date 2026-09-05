import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

class DecadeBarChart extends StatelessWidget {
  const DecadeBarChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  Widget build(BuildContext context) {
    if (stats.discoveryDecade.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesByDiscoveryDecadeResult> data = stats.discoveryDecade;
    final double maxY =
        data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = data.length * (12.0 + 6.0) + 50.0;

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
                  groupsSpace: 6,
                  maxY: maxY * 1.15,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          colorScheme.surfaceContainerHighest,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final xAxisLabel =
                            '${data[group.x.toInt()].decade?.toInt() ?? 0}s';
                        return BarTooltipItem(
                          '$xAxisLabel\n',
                          TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} descriptions',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
                          if (index % 2 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Transform.rotate(
                              angle: -0.7,
                              child: Text(
                                '${data[index].decade?.toInt() ?? 0}s',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        },
                        reservedSize: 48,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 46,
                        interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.count.toDouble(),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.orange,
                              Color(0xFFFFB74D),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
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
