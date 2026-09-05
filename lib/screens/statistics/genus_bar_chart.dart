import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

class GenusBarChart extends StatefulWidget {
  const GenusBarChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<GenusBarChart> createState() => _GenusBarChartState();
}

class _GenusBarChartState extends State<GenusBarChart> {
  int _topN = 15;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.speciesPerGenus.isEmpty) return const SizedBox.shrink();
    final List<StatSpeciesPerGenusResult> data =
        widget.stats.speciesPerGenus.take(_topN).toList();
    final double maxY =
        data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final barColor = ChartPalette.getGenusColor(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Show: ',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SegmentedButton<int>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                    value: 10,
                    label: Text('10', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 15,
                    label: Text('15', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: 25,
                    label: Text('25', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_topN},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _topN = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final requiredWidth = data.length * (20.0 + 10.0) + 50.0;

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
                        maxY: maxY * 1.15,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) =>
                                colorScheme.inverseSurface,
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final xAxisLabel =
                                  data[group.x.toInt()].name ?? '';
                              return BarTooltipItem(
                                '$xAxisLabel\n',
                                TextStyle(
                                  color: colorScheme.onInverseSurface
                                      .withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${rod.toY.toInt()} species',
                                    style: TextStyle(
                                      color: colorScheme.onInverseSurface,
                                      fontSize: 14,
                                      fontStyle: FontStyle.normal,
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

                                String text = data[index].name ?? '';
                                if (text.length > 12) {
                                  text = '${text.substring(0, 10)}...';
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Transform.rotate(
                                    angle: -0.7,
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 72,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              interval:
                                  maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
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
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.35),
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
                                toY: (e.value.count).toDouble(),
                                gradient: LinearGradient(
                                  colors: [
                                    barColor,
                                    barColor.withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
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
          ),
        ),
      ],
    );
  }
}
