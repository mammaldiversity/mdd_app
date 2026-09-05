import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/screens/statistics/indicator.dart';
import 'package:mdd/services/statistics.dart';

class TypeKindPieChart extends StatefulWidget {
  const TypeKindPieChart({super.key, required this.stats});

  final MddStatistics stats;

  @override
  State<TypeKindPieChart> createState() => _TypeKindPieChartState();
}

class _TypeKindPieChartState extends State<TypeKindPieChart> {
  int _touchedIndex = -1;
  bool _isDonut = true;

  // Okabe-Ito colorblind-friendly palette
  static const colors = [
    Color(0xFFE69F00), // Orange
    Color(0xFF56B4E9), // Sky Blue
    Color(0xFF009E73), // Bluish Green
    Color(0xFFF0E442), // Yellow
    Color(0xFF0072B2), // Blue
    Color(0xFFD55E00), // Vermilion
    Color(0xFFCC79A7), // Reddish Purple
    Color(0xFF332288), // Indigo
    Color(0xFF88CCEE), // Light Blue
    Color(0xFF117733), // Green
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> data = widget.stats.typeKindProportion;
    if (data.isEmpty) return const SizedBox.shrink();

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
              SegmentedButton<bool>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Donut', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Pie', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_isDonut},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _isDonut = newSelection.first;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: _isDonut ? 38 : 0,
                      sections: _showingSections(data),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.asMap().entries.map((e) {
                      final pct = total > 0
                          ? (e.value.value / total * 100).toStringAsFixed(1)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Indicator(
                          color: colors[e.key % colors.length],
                          text: '${e.value.key}: ${e.value.value} ($pct%)',
                          isSquare: true,
                          textColor: colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections(
    List<MapEntry<String, int>> data,
  ) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 66.0 : 58.0;

      final count = e.value;
      final isLarge = count > 300 || isTouched;
      final color = colors[i % colors.length];
      final textColor =
          color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

      return PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: isLarge ? '$count' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
    }).toList();
  }
}
