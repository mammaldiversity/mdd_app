import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/statistics.dart';

class ImagesPieChart extends StatefulWidget {
  const ImagesPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<ImagesPieChart> createState() => _ImagesPieChartState();
}

class _ImagesPieChartState extends State<ImagesPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  @override
  Widget build(BuildContext context) {
    if (widget.stats.totalSpeciesCount == 0) return const SizedBox.shrink();
    final withImages = widget.stats.speciesWithImagesCount;
    final total = widget.stats.totalSpeciesCount;
    final withoutImages = total - withImages;
    final withPct =
        total > 0 ? (withImages / total * 100).toStringAsFixed(1) : '0';
    final withoutPct =
        total > 0 ? (withoutImages / total * 100).toStringAsFixed(1) : '0';
    final colorScheme = Theme.of(context).colorScheme;
    final imgColors = ChartPalette.getImagesColors(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _isDonut ? Icons.bar_chart : Icons.donut_large,
                  size: 20,
                ),
                tooltip:
                    _isDonut ? 'Switch to bar chart' : 'Switch to donut chart',
                onPressed: () {
                  setState(() {
                    _isDonut = !_isDonut;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isDonut
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final chartWidth = constraints.maxWidth < 380.0
                        ? 380.0
                        : constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: chartWidth,
                        height: constraints.maxHeight,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            _touchedIndex = -1;
                                            return;
                                          }
                                          _touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 38,
                                    sections: [
                                      _buildSection(
                                        0,
                                        withImages,
                                        imgColors.withImages,
                                        colorScheme,
                                      ),
                                      _buildSection(
                                        1,
                                        withoutImages,
                                        imgColors.withoutImages,
                                        colorScheme,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Indicator(
                                          color: imgColors.withImages,
                                          text: 'With: $withImages ($withPct%)',
                                          isSquare: true,
                                          textColor: colorScheme.onSurface,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Indicator(
                                          color: imgColors.withoutImages,
                                          text:
                                              'Without: $withoutImages ($withoutPct%)',
                                          isSquare: true,
                                          textColor: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : _buildBarChart(
                  withImages,
                  withoutImages,
                  colorScheme,
                ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    int withImages,
    int withoutImages,
    ColorScheme colorScheme,
  ) {
    final double maxY =
        (withImages > withoutImages ? withImages : withoutImages).toDouble();
    final items = [
      (label: 'With Images', count: withImages),
      (label: 'Without Images', count: withoutImages),
    ];
    final barColor = colorScheme.primary;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        groupsSpace: 48,
        maxY: maxY * 1.15,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.inverseSurface,
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = items[group.x.toInt()];
              return BarTooltipItem(
                '${item.label}\n',
                TextStyle(
                  color: colorScheme.onInverseSurface.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} species',
                    style: TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontSize: 13,
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
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= items.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    items[idx].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
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
          horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(items.length, (i) {
          final item = items[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: item.count.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    barColor.withValues(alpha: 0.85),
                    barColor,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 28,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  PieChartSectionData _buildSection(
    int index,
    int count,
    Color color,
    ColorScheme colorScheme,
  ) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? 66.0 : 58.0;

    return PieChartSectionData(
      color: color,
      value: count.toDouble(),
      title: '',
      radius: radius,
      borderSide: BorderSide(
        color: colorScheme.surface,
        width: 1.5,
      ),
    );
  }
}
