import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';

import 'package:mdd/screens/statistics/indicator.dart';

class RealmPieChart extends StatefulWidget {
  final MddStatistics stats;

  const RealmPieChart({super.key, required this.stats});

  @override
  State<RealmPieChart> createState() => _RealmPieChartState();
}

class _RealmPieChartState extends State<RealmPieChart> {
  int touchedIndex = -1;
  final colors = [
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.brown,
    Colors.lime,
    Colors.pink
  ];

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> data = widget.stats.biogeographicRealm;
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
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
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
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Note: Realms with uncertain occurrence ('?') have been aggregated into their primary realm.",
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
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
      const shadows = [Shadow(color: Colors.black87, blurRadius: 4)];

      final count = e.value;
      final isLarge = count > 300 || isTouched;

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: count.toDouble(),
        title: isLarge ? '$count' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }
}
