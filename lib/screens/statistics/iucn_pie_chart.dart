import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/chart_palette.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/statistics.dart';

class IucnPieChart extends StatefulWidget {
  const IucnPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<IucnPieChart> createState() => _IucnPieChartState();
}

class _IucnPieChartState extends State<IucnPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  static const Map<String, int> iucnOrder = {
    'EX': 0,
    'EW': 1,
    'CR': 2,
    'EN': 3,
    'VU': 4,
    'NT': 5,
    'LC': 6,
    'DD': 7,
    'NE': 8,
  };

  static String _getFullIucnName(String code) {
    const map = {
      'EX': 'Extinct',
      'EW': 'Extinct in Wild',
      'CR': 'Critically Endangered',
      'EN': 'Endangered',
      'VU': 'Vulnerable',
      'NT': 'Near Threatened',
      'LC': 'Least Concern',
      'DD': 'Data Deficient',
      'NE': 'Not Evaluated',
    };
    return map[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> rawData = widget.stats.iucnStatus;
    if (rawData.isEmpty) return const SizedBox.shrink();

    final List<MapEntry<String, int>> data = List.from(rawData)
      ..sort((a, b) {
        final orderA = iucnOrder[a.key] ?? 99;
        final orderB = iucnOrder[b.key] ?? 99;
        return orderA.compareTo(orderB);
      });

    final total = data.fold<int>(0, (sum, e) => sum + e.value);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      context,
                                      colorScheme,
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
                                      final pct = total > 0
                                          ? (e.value / total * 100)
                                              .toStringAsFixed(1)
                                          : '0';
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Indicator(
                                          color: ChartPalette.getIucnColor(
                                            e.key,
                                            context,
                                          ),
                                          text:
                                              '${e.key} - ${_getFullIucnName(e.key)}: ${e.value} ($pct%)',
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
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "Note: Caveats (e.g. 'VU (as Species A)') are aggregated into primary status.",
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<MapEntry<String, int>> data,
    ColorScheme colorScheme,
  ) {
    final double maxY =
        data.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    // In bar plot mode, all bars use a single theme-harmonious accessible color
    final barColor = colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = data.length * 36.0 + 40.0;
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
                  alignment: BarChartAlignment.spaceAround,
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
                        return BarTooltipItem(
                          '${_getFullIucnName(item.key)} (${item.key})\n',
                          TextStyle(
                            color: colorScheme.onInverseSurface
                                .withValues(alpha: 0.8),
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
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(
                              data[idx].key,
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
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
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
                  barGroups: List.generate(data.length, (i) {
                    final item = data[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: item.value.toDouble(),
                          gradient: LinearGradient(
                            colors: [
                              barColor.withValues(alpha: 0.85),
                              barColor,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _showingSections(
    List<MapEntry<String, int>> data,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 66.0 : 58.0;
      final color = ChartPalette.getIucnColor(e.key, context);

      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
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
