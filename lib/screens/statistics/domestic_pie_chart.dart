import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/services/statistics.dart';

class DomesticPieChart extends StatefulWidget {
  const DomesticPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<DomesticPieChart> createState() => _DomesticPieChartState();
}

class _DomesticPieChartState extends State<DomesticPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  @override
  Widget build(BuildContext context) {
    final List<StatDomesticSpeciesResult> data = widget.stats.domesticSpecies;
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold<int>(0, (sum, e) => sum + e.count);
    final colorScheme = Theme.of(context).colorScheme;
    final domesticColors = ChartPalette.getDomesticColors(context);

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
                                    sections: _showingSections(
                                      data,
                                      colorScheme,
                                      domesticColors,
                                    ),
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
                                    children: data.map((e) {
                                      final isDomestic = e.isDomestic == 1;
                                      final pct = total > 0
                                          ? (e.count / total * 100)
                                              .toStringAsFixed(1)
                                          : '0';
                                      final label =
                                          isDomestic ? 'Domestic' : 'Wild';
                                      final color = isDomestic
                                          ? domesticColors.domestic
                                          : domesticColors.wild;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Indicator(
                                          color: color,
                                          text: '$label: ${e.count} ($pct%)',
                                          isSquare: true,
                                          textColor: colorScheme.onSurface,
                                        ),
                                      );
                                    }).toList(),
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
              : _buildBarChart(data, colorScheme),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<StatDomesticSpeciesResult> data,
    ColorScheme colorScheme,
  ) {
    final double maxY = data.isEmpty
        ? 1
        : data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
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
              final item = data[group.x.toInt()];
              final isDomestic = item.isDomestic == 1;
              final label = isDomestic ? 'Domestic' : 'Wild';
              return BarTooltipItem(
                '$label\n',
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
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                final label = data[idx].isDomestic == 1 ? 'Domestic' : 'Wild';
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label,
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
        barGroups: List.generate(data.length, (i) {
          final item = data[i];
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

  List<PieChartSectionData> _showingSections(
    List<StatDomesticSpeciesResult> data,
    ColorScheme colorScheme,
    ({Color domestic, Color wild}) domesticColors,
  ) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 66.0 : 58.0;

      final isDomestic = e.isDomestic == 1;
      final count = e.count;
      final color = isDomestic ? domesticColors.domestic : domesticColors.wild;

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
    }).toList();
  }
}
