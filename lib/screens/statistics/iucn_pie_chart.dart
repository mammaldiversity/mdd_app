import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';

import 'package:mdd/screens/statistics/indicator.dart';

class IucnPieChart extends StatefulWidget {
  final MddStatistics stats;

  const IucnPieChart({super.key, required this.stats});

  @override
  State<IucnPieChart> createState() => _IucnPieChartState();
}

class _IucnPieChartState extends State<IucnPieChart> {
  int touchedIndex = -1;

  final Map<String, Color> iucnColors = {
    'EX': Colors.black87,
    'EW': Colors.purple.shade900,
    'CR': Colors.red,
    'EN': Colors.orange,
    'VU': Colors.yellow.shade800,
    'NT': Colors.lightGreen,
    'LC': Colors.green,
    'DD': Colors.grey,
    'NE': Colors.blueGrey,
  };

  final Map<String, int> iucnOrder = {
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
                              color: iucnColors[e.value.key] ?? Colors.grey,
                              text:
                                  '${_getFullIucnName(e.value.key)} (${e.value.value})',
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
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Note: Species with taxonomic caveats (e.g. 'VU (as Species A)') are aggregated into their primary status category.",
            style: TextStyle(
                fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
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
      final color = iucnColors[e.key] ?? Colors.grey;
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

  String _getFullIucnName(String code) {
    const map = {
      'EX': 'Extinct',
      'EW': 'Extinct in the Wild',
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
}
