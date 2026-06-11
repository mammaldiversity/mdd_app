import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mdd/services/statistics.dart';
import 'package:mdd/services/database/mdd_query.dart';
import 'package:mdd/screens/statistics/indicator.dart';

class ExtinctPieChart extends StatefulWidget {
  final MddStatistics stats;

  const ExtinctPieChart({super.key, required this.stats});

  @override
  State<ExtinctPieChart> createState() => _ExtinctPieChartState();
}

class _ExtinctPieChartState extends State<ExtinctPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<StatExtinctSpeciesResult> data = widget.stats.extinctSpecies;
    if (data.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((e) {
              final isExtinct = e.isExtinct == 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Indicator(
                  color: isExtinct ? Colors.redAccent : Colors.lightGreen,
                  text: isExtinct ? 'Extinct' : 'Extant',
                  isSquare: true,
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      List<StatExtinctSpeciesResult> data) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black87, blurRadius: 4)];

      final isExtinct = e.isExtinct == 1;
      final count = e.count;

      return PieChartSectionData(
        color: isExtinct ? Colors.redAccent : Colors.lightGreen,
        value: count.toDouble(),
        title: '$count',
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
