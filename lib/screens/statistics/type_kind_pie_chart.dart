import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/screens/statistics/indicator.dart';

class TypeKindPieChart extends StatefulWidget {
  final MddStatistics stats;

  const TypeKindPieChart({super.key, required this.stats});

  @override
  State<TypeKindPieChart> createState() => _TypeKindPieChartState();
}

class _TypeKindPieChartState extends State<TypeKindPieChart> {
  int touchedIndex = -1;
  // Okabe-Ito colorblind-friendly palette
  final colors = [
    const Color(0xFFE69F00), // Orange
    const Color(0xFF56B4E9), // Sky Blue
    const Color(0xFF009E73), // Bluish Green
    const Color(0xFFF0E442), // Yellow
    const Color(0xFF0072B2), // Blue
    const Color(0xFFD55E00), // Vermilion
    const Color(0xFFCC79A7), // Reddish Purple
    const Color(0xFF332288), // Indigo
    const Color(0xFF88CCEE), // Light Blue
    const Color(0xFF117733), // Green
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> data = widget.stats.typeKindProportion;
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.3,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: double.nan,
                        sections: showingSections(data),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Indicator(
                              color: colors[e.key % colors.length],
                              text: '${e.value.key} (${e.value.value})',
                              isSquare: true,
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
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(List<MapEntry<String, int>> data) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 10.0;
      final radius = isTouched ? 70.0 : 60.0;

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
